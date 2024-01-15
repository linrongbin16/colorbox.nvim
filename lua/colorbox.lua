local logging = require("colorbox.commons.logging")
local LogLevels = require("colorbox.commons.logging").LogLevels
local jsons = require("colorbox.commons.jsons")
local uv = require("colorbox.commons.uv")
local numbers = require("colorbox.commons.numbers")
local fileios = require("colorbox.commons.fileios")
local strings = require("colorbox.commons.strings")
local apis = require("colorbox.commons.apis")
local async = require("colorbox.commons.async")

--- @alias colorbox.Options table<any, any>
--- @type colorbox.Options
local Defaults = {
    -- builtin policy
    --- @alias colorbox.BuiltinPolicyConfig "shuffle"|"in_order"|"reverse_order"|"single"
    ---
    -- by filetype policy: buffer filetype => color name
    --- @alias colorbox.ByFileTypePolicyConfig {mapping:table<string, string>,fallback:string}
    ---
    -- fixed interval seconds
    --- @alias colorbox.FixedIntervalPolicyConfig {seconds:integer,implement:colorbox.BuiltinPolicyConfig}
    ---
    --- @alias colorbox.PolicyConfig colorbox.BuiltinPolicyConfig|colorbox.ByFileTypePolicyConfig|colorbox.FixedIntervalPolicyConfig
    --- @type colorbox.PolicyConfig
    policy = "shuffle",

    --- @type "startup"|"interval"|"filetype"
    timing = "startup",

    -- (Optional) filters that disable some colors that you don't want.
    --
    -- builtin filter
    --- @alias colorbox.BuiltinFilterConfig "primary"
    ---
    -- function-based filter, enabled if function returns true.
    --- @alias colorbox.FunctionFilterConfig fun(color:string, spec:colorbox.ColorSpec):boolean
    ---
    -- list-based all of filter, a color is enabled if all of inside filters returns true.
    --- @alias colorbox.AllFilterConfig (colorbox.BuiltinFilterConfig|colorbox.FunctionFilterConfig)[]
    ---
    --- @alias colorbox.FilterConfig colorbox.BuiltinFilterConfig|colorbox.FunctionFilterConfig|colorbox.AllFilterConfig
    --- @type colorbox.FilterConfig?
    filter = {
        "primary",
        -- function(color, spec)
        --     return spec.github_stars >= 800
        -- end,
    },

    --- @type table<string, function>
    setup = {
        ["projekt0n/github-nvim-theme"] = function()
            require("github-theme").setup()
        end,
    },

    --- @type "dark"|"light"|nil
    background = nil,

    --- @type colorbox.Options
    command = {
        name = "Colorbox",
        desc = "Colorschemes player controller",
    },

    --- @type string
    cache_dir = string.format("%s/colorbox.nvim", vim.fn.stdpath("data")),

    -- enable debug
    debug = false,

    -- print log to console (command line)
    console_log = true,

    -- print log to file.
    file_log = false,
}

--- @type colorbox.Options
local Configs = {}

-- filtered color names list
--- @type string[]
local FilteredColorNamesList = {}

-- filtered color name to index map, the reverse of FilteredColorNamesList (index => name)
--- @type table<string, integer>
local FilteredColorNameToIndexMap = {}

local function _minimal_color_name_len(spec)
    local n = numbers.INT32_MAX
    for _, c in ipairs(spec.color_names) do
        if string.len(c) < n then
            n = string.len(c)
        end
    end
    return n
end

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return integer
local function _primary_score(color_name, spec)
    local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]

    -- unique
    local unique = #spec.color_names <= 1

    -- shortest
    local current_name_len = string.len(color_name)
    local minimal_name_len = _minimal_color_name_len(spec)
    local shortest = current_name_len == minimal_name_len

    -- match
    local handle_splits = strings.split(spec.handle, "/")
    local handle1 = handle_splits[1]:gsub("%-", "_")
    local handle2 = handle_splits[2]:gsub("%-", "_")
    local normalized_color = color_name:gsub("%-", "_")
    local matched = strings.startswith(
        handle1,
        normalized_color,
        { ignorecase = true }
    ) or strings.startswith(
        handle2,
        normalized_color,
        { ignorecase = true }
    ) or strings.endswith(handle1, normalized_color, { ignorecase = true }) or strings.endswith(
        handle2,
        normalized_color,
        { ignorecase = true }
    )
    logger:debug(
        "|_primary_score| unique:%s, shortest:%s (current:%s, minimal:%s), matched:%s",
        vim.inspect(unique),
        vim.inspect(shortest),
        vim.inspect(current_name_len),
        vim.inspect(minimal_name_len),
        vim.inspect(matched)
    )
    local n = 0
    if unique then
        n = n + 3
    end
    if matched then
        n = n + 2
    end
    if shortest then
        n = n + 1
    end
    return n
end

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _builtin_filter_primary(color_name, spec)
    local color_score = _primary_score(color_name, spec)
    for _, other_color in ipairs(spec.color_names) do
        local other_score = _primary_score(other_color, spec)
        if color_score < other_score then
            return false
        end
    end
    return true
end

--- @param f colorbox.BuiltinFilterConfig
--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _builtin_filter(f, color_name, spec)
    if f == "primary" then
        return _builtin_filter_primary(color_name, spec)
    end
    return false
end

--- @param f colorbox.FunctionFilterConfig
--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _function_filter(f, color_name, spec)
    if type(f) == "function" then
        local ok, result = pcall(f, color_name, spec)
        if ok and type(result) == "boolean" then
            return result
        else
            logging
                .get("colorbox")
                :err(
                    "failed to invoke function filter, please check your config!"
                )
        end
    end
    return false
end

--- @param f colorbox.AllFilterConfig
--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _all_filter(f, color_name, spec)
    if type(f) == "table" then
        for _, f1 in ipairs(f) do
            if type(f1) == "string" then
                local result = _builtin_filter(f1, color_name, spec)
                if not result then
                    return result
                end
            elseif type(f1) == "function" then
                local result = _function_filter(f1, color_name, spec)
                if not result then
                    return result
                end
            end
        end
    end
    return true
end

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _filter(color_name, spec)
    if type(Configs.filter) == "string" then
        return _builtin_filter(Configs.filter, color_name, spec)
    elseif type(Configs.filter) == "function" then
        return _function_filter(Configs.filter, color_name, spec)
    elseif type(Configs.filter) == "table" then
        return _all_filter(Configs.filter, color_name, spec)
    end
    return false
end

local function _init()
    local home_dir = vim.fn["colorbox#base_dir"]()
    -- local pack_dir = "pack/colorbox/start"
    -- local full_pack_dir = string.format("%s/%s", home_dir, pack_dir)
    -- logger.debug(
    --     "|colorbox.init| home_dir:%s, pack_dir:%s, full_pack_dir:%s",
    --     vim.inspect(home_dir),
    --     vim.inspect(pack_dir),
    --     vim.inspect(full_pack_dir)
    -- )
    vim.opt.packpath:append(home_dir)
    -- vim.opt.packpath:append(cwd .. "/pack")
    -- vim.opt.packpath:append(cwd .. "/pack/colorbox")
    -- vim.opt.packpath:append(cwd .. "/pack/colorbox/opt")
    -- vim.cmd([[packadd catppuccin-nvim]])

    local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]
    local ColorNameToColorSpecsMap =
        require("colorbox.db").get_color_name_to_color_specs_map()
    local ColorNamesList = require("colorbox.db").get_color_names_list()
    for _, color_name in pairs(ColorNamesList) do
        local spec = ColorNameToColorSpecsMap[color_name]
        local pack_exist = uv.fs_stat(spec.full_pack_path) ~= nil
        if _filter(color_name, spec) and pack_exist then
            table.insert(FilteredColorNamesList, color_name)
        end
    end
    for i, color_name in ipairs(FilteredColorNamesList) do
        FilteredColorNameToIndexMap[color_name] = i
    end
    logger:debug(
        "|_init| FilteredColorNamesList:%s",
        vim.inspect(FilteredColorNamesList)
    )
    logger:debug(
        "|_init| FilteredColorNameToIndexMap:%s",
        vim.inspect(FilteredColorNameToIndexMap)
    )
end

local function _force_sync_syntax()
    vim.cmd([[syntax sync fromstart]])
end

--- @alias colorbox.PreviousTrack {color_name:string,color_number:integer}
--- @param color_name string
local function _save_track(color_name)
    if strings.blank(color_name) then
        return
    end
    local color_number = FilteredColorNameToIndexMap[color_name] or 1
    vim.schedule(function()
        local content = jsons.encode({
            color_name = color_name,
            color_number = color_number,
        }) --[[@as string]]
        fileios.writefile(Configs.previous_track_cache, content)
    end)
end

--- @return colorbox.PreviousTrack?
local function _load_previous_track()
    local content = fileios.readfile(Configs.previous_track_cache)
    if content == nil then
        return nil
    end
    return jsons.decode(content) --[[@as colorbox.PreviousTrack?]]
end

--- @param idx integer
--- @return string
local function _get_next_color_name_by_idx(idx)
    assert(type(idx) == "number")
    idx = idx + 1
    if idx > #FilteredColorNamesList then
        idx = 1
    end
    return FilteredColorNamesList[numbers.bound(idx, 1, #FilteredColorNamesList)]
end

--- @param idx integer
--- @return string
local function _get_prev_color_name_by_idx(idx)
    assert(type(idx) == "number")
    idx = idx - 1
    if idx < 1 then
        idx = #FilteredColorNamesList
    end
    return FilteredColorNamesList[numbers.bound(idx, 1, #FilteredColorNamesList)]
end

local function _policy_shuffle()
    if #FilteredColorNamesList > 0 then
        local i = numbers.random(#FilteredColorNamesList) --[[@as integer]]
        local color = _get_next_color_name_by_idx(i)
        logging.get("colorbox"):debug(
            "|_policy_shuffle| color:%s, FilteredColorNamesList:%s (%d), i:%d",
            vim.inspect(color),
            vim.inspect(FilteredColorNamesList),
            vim.inspect(#FilteredColorNamesList),
            vim.inspect(i)
        )
        vim.cmd(string.format([[color %s]], color))
    end
end

local function _policy_in_order()
    if #FilteredColorNamesList > 0 then
        local previous_track = _load_previous_track() --[[@as colorbox.PreviousTrack]]
        local i = previous_track ~= nil and previous_track.color_number or 0
        local color = _get_next_color_name_by_idx(i)
        vim.cmd(string.format([[color %s]], color))
    end
end

local function _policy_reverse_order()
    if #FilteredColorNamesList > 0 then
        local previous_track = _load_previous_track() --[[@as colorbox.PreviousTrack]]
        local i = previous_track ~= nil and previous_track.color_number
            or (#FilteredColorNamesList + 1)
        local color = _get_prev_color_name_by_idx(i)
        vim.cmd(string.format([[color %s]], color))
    end
end

local function _policy_single()
    if #FilteredColorNamesList > 0 then
        local previous_track = _load_previous_track() --[[@as colorbox.PreviousTrack]]
        local color = previous_track ~= nil and previous_track.color_name
            or _get_next_color_name_by_idx(0)
        if color ~= vim.g.colors_name then
            vim.cmd(string.format([[color %s]], color))
        end
    end
end

--- @param po colorbox.Options?
--- @return boolean
local function _is_fixed_interval_policy(po)
    return type(po) == "table"
        and type(po.seconds) == "number"
        and po.seconds >= 0
        and type(po.implement) == "string"
        and string.len(po.implement) > 0
end

local function _policy_fixed_interval()
    local later = Configs.policy.seconds > 0 and (Configs.policy.seconds * 1000)
        or numbers.INT32_MAX

    local function impl()
        if Configs.policy.implement == "shuffle" then
            _policy_shuffle()
            _force_sync_syntax()
        elseif Configs.policy.implement == "in_order" then
            _policy_in_order()
            _force_sync_syntax()
        elseif Configs.policy.implement == "reverse_order" then
            _policy_reverse_order()
            _force_sync_syntax()
        elseif Configs.policy.implement == "single" then
            _policy_single()
            _force_sync_syntax()
        end
        vim.defer_fn(impl, later)
    end
    impl()
end

--- @param po colorbox.Options?
--- @return boolean
local function _is_by_filetype_policy(po)
    return type(po) == "table"
        and type(po.mapping) == "table"
        and type(po.fallback) == "string"
        and string.len(po.fallback) > 0
end

local function _policy_by_filetype()
    vim.defer_fn(function()
        local ft = vim.bo.filetype or ""

        if Configs.policy.mapping[ft] then
            local ok, err = pcall(
                vim.cmd --[[@as function]],
                string.format([[color %s]], Configs.policy.mapping[ft])
            )
            assert(ok, err)
        else
            local ok, err = pcall(
                vim.cmd --[[@as function]],
                string.format([[color %s]], Configs.policy.fallback)
            )
            assert(ok, err)
        end
        _force_sync_syntax()
    end, 200)
end

local function _policy()
    if Configs.policy == "shuffle" then
        _policy_shuffle()
    elseif Configs.policy == "in_order" then
        _policy_in_order()
    elseif Configs.policy == "reverse_order" then
        _policy_reverse_order()
    elseif Configs.policy == "single" then
        _policy_single()
    elseif
        Configs.timing == "interval"
        and _is_fixed_interval_policy(Configs.policy)
    then
        _policy_fixed_interval()
    elseif
        Configs.timing == "bufferchanged"
        or Configs.timing == "filetype"
            and _is_by_filetype_policy(Configs.policy)
    then
        _policy_by_filetype()
    end
end

local function _timing_startup()
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = _policy,
    })
end

local function _timing_filetype()
    vim.api.nvim_create_autocmd({ "BufNew", "BufReadPre", "BufNewFile" }, {
        callback = _policy,
    })
end

local function _timing()
    if Configs.timing == "startup" then
        _timing_startup()
    elseif Configs.timing == "interval" then
        assert(
            _is_fixed_interval_policy(Configs.policy),
            string.format(
                "invalid policy %s for 'interval' timing!",
                vim.inspect(Configs.policy)
            )
        )
        _policy_fixed_interval()
    elseif
        Configs.timing == "bufferchanged" or Configs.timing == "filetype"
    then
        assert(
            _is_by_filetype_policy(Configs.policy),
            string.format(
                "invalid policy %s for 'filetype' timing!",
                vim.inspect(Configs.policy)
            )
        )
        _timing_filetype()
    else
        error(string.format("invalid timing %s!", vim.inspect(Configs.timing)))
    end
end

local function update()
    if logging.get("colorbox-update") == nil then
        logging.setup({
            name = "colorbox-update",
            level = LogLevels.DEBUG,
            console_log = true,
            file_log = true,
            file_log_name = "colorbox_update.log",
            file_log_mode = "w",
        })
    end
    local logger = logging.get("colorbox-update") --[[@as commons.logging.Logger]]

    local home_dir = vim.fn["colorbox#base_dir"]()
    -- local packstart = string.format("%s/pack/colorbox/start", home_dir)
    -- logger.debug(
    --     "|colorbox.init| home_dir:%s, pack:%s",
    --     vim.inspect(home_dir),
    --     vim.inspect(packstart)
    -- )
    vim.opt.packpath:append(home_dir)

    local HandleToColorSpecsMap =
        require("colorbox.db").get_handle_to_color_specs_map()

    local prepared_count = 0
    for _, _ in pairs(HandleToColorSpecsMap) do
        prepared_count = prepared_count + 1
    end
    logger:info("started %s jobs", vim.inspect(prepared_count))

    local async_spawn_run = async.wrap(function(acmd, aopts, cb)
        require("colorbox.commons.spawn").run(
            acmd,
            aopts,
            function(completed_obj)
                cb(completed_obj)
            end
        )
    end, 3)

    local finished_count = 0
    async.run(function()
        for handle, spec in pairs(HandleToColorSpecsMap) do
            local function _on_output(line)
                if strings.not_blank(line) then
                    logger:info("%s: %s", handle, line)
                end
            end
            local param = nil
            if
                vim.fn.isdirectory(spec.full_pack_path) > 0
                and vim.fn.isdirectory(spec.full_pack_path .. "/.git") > 0
            then
                param = {
                    cmd = { "git", "pull" },
                    opts = {
                        cwd = spec.full_pack_path,
                        on_stdout = _on_output,
                        on_stderr = _on_output,
                    },
                }
            else
                param = {
                    cmd = strings.not_empty(spec.git_branch) and {
                        "git",
                        "clone",
                        "--branch",
                        spec.git_branch,
                        "--depth=1",
                        spec.url,
                        spec.pack_path,
                    } or {
                        "git",
                        "clone",
                        "--depth=1",
                        spec.url,
                        spec.pack_path,
                    },
                    opts = {
                        cwd = home_dir,
                        on_stdout = _on_output,
                        on_stderr = _on_output,
                    },
                }
            end
            async_spawn_run(param.cmd, param.opts)
            async.scheduler()
            finished_count = finished_count + 1
        end
    end, function()
        logger:info("finished %s jobs", vim.inspect(finished_count))
    end)
end

local function _clean()
    local home_dir = vim.fn["colorbox#base_dir"]()
    local full_pack_dir = string.format("%s/pack", home_dir)
    local shorten_pack_dir = vim.fn.fnamemodify(full_pack_dir, ":~")
    ---@diagnostic disable-next-line: discard-returns, param-type-mismatch
    local opened_dir, opendir_err = uv.fs_opendir(full_pack_dir)
    if not opened_dir then
        -- logger.debug(
        --     "directory %s not found, error: %s",
        --     vim.inspect(shorten_pack_dir),
        --     vim.inspect(opendir_err)
        -- )
        return
    end
    local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]
    if vim.fn.executable("rm") > 0 then
        local jobid = vim.fn.jobstart({ "rm", "-rf", full_pack_dir }, {
            detach = false,
            stdout_buffered = true,
            stderr_buffered = true,
            on_stdout = function(chanid, data, name)
                -- logger.debug(
                --     "clean job(%s) data:%s",
                --     vim.inspect(name),
                --     vim.inspect(data)
                -- )
            end,
            on_stderr = function(chanid, data, name)
                -- logger.debug(
                --     "clean job(%s) data:%s",
                --     vim.inspect(name),
                --     vim.inspect(data)
                -- )
            end,
            on_exit = function(jid, exitcode, name)
                -- logger.debug(
                --     "clean job(%s) done:%s",
                --     vim.inspect(name),
                --     vim.inspect(exitcode)
                -- )
            end,
        })
        vim.fn.jobwait({ jobid })
        logger:info("cleaned directory: %s", shorten_pack_dir)
    else
        logger:warn("no 'rm' command found, skip cleaning...")
    end
end

--- @param args string?
--- @return colorbox.Options?
local function _parse_args(args)
    local opts = nil
    logging.get("colorbox"):debug("|_parse_args| args:%s", vim.inspect(args))
    if strings.not_blank(args) then
        local args_splits = strings.split(
            vim.trim(args --[[@as string]]),
            " ",
            { trimempty = true }
        )
        for _, arg_split in ipairs(args_splits) do
            local item_splits =
                strings.split(vim.trim(arg_split), "=", { trimempty = true })
            if strings.not_blank(item_splits[1]) then
                if opts == nil then
                    opts = {}
                end
                opts[vim.trim(item_splits[1])] = vim.trim(item_splits[2])
            end
        end
    end
    return opts
end

local function _update()
    update()
end

local function _reinstall()
    _clean()
    update()
end

--- @param args string
local function _info(args)
    local opts = _parse_args(args)
    opts = opts or { scale = 0.7 }
    opts.scale = type(opts.scale) == "string" and (tonumber(opts.scale) or 0.7)
        or 0.7
    opts.scale = numbers.bound(opts.scale, 0, 1)
    logging.get("colorbox"):debug("|_info| opts:%s", vim.inspect(opts))

    local total_width = vim.o.columns
    local total_height = vim.o.lines
    local width = math.floor(total_width * opts.scale)
    local height = math.floor(total_height * opts.scale)

    local function get_shift(totalsize, modalsize, offset)
        local base = math.floor((totalsize - modalsize) * 0.5)
        local shift = offset > -1
                and math.ceil((totalsize - modalsize) * offset)
            or offset
        return numbers.bound(base + shift, 0, totalsize - modalsize)
    end

    local row = get_shift(total_height, height, 0)
    local col = get_shift(total_width, width, 0)

    local win_config = {
        anchor = "NW",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        zindex = 51,
    }

    local bufnr = vim.api.nvim_create_buf(false, true)
    apis.set_buf_option(bufnr, "bufhidden", "wipe")
    apis.set_buf_option(bufnr, "buflisted", false)
    apis.set_buf_option(bufnr, "filetype", "markdown")
    vim.keymap.set(
        { "n" },
        "q",
        ":\\<C-U>quit<CR>",
        { silent = true, buffer = bufnr }
    )
    local winnr = vim.api.nvim_open_win(bufnr, true, win_config)

    local HandleToColorSpecsMap =
        require("colorbox.db").get_handle_to_color_specs_map()
    local color_specs_list = {}
    for handle, spec in pairs(HandleToColorSpecsMap) do
        table.insert(color_specs_list, spec)
    end
    table.sort(color_specs_list, function(a, b)
        return a.github_stars > b.github_stars
    end)
    local total_plugins = 0
    local total_colors = 0
    local enabled_plugins = 0
    local enabled_colors = 0
    for i, spec in ipairs(color_specs_list) do
        total_plugins = total_plugins + 1
        local plugin_enabled = false
        for j, color in ipairs(spec.color_names) do
            total_colors = total_colors + 1
            local color_enabled = FilteredColorNameToIndexMap[color] ~= nil
            if color_enabled then
                enabled_colors = enabled_colors + 1
                plugin_enabled = true
            end
        end
        if plugin_enabled then
            enabled_plugins = enabled_plugins + 1
        end
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, 0, true, {
        string.format(
            "# ColorSchemes List (total(colors/plugins): %d/%d, enabled(colors/plugins): %d/%d)",
            total_colors,
            total_plugins,
            enabled_colors,
            enabled_plugins
        ),
    })
    local lineno = 1
    for i, spec in ipairs(color_specs_list) do
        vim.api.nvim_buf_set_lines(bufnr, lineno, lineno, true, {
            string.format(
                "- %s (stars: %s, last update at: %s)",
                vim.inspect(spec.handle),
                vim.inspect(spec.github_stars),
                vim.inspect(spec.last_git_commit)
            ),
        })
        lineno = lineno + 1
        local colornames = vim.deepcopy(spec.color_names)
        table.sort(colornames, function(a, b)
            local a_enabled = FilteredColorNameToIndexMap[a] ~= nil
            return a_enabled
        end)

        for _, color in ipairs(colornames) do
            local enabled = FilteredColorNameToIndexMap[color] ~= nil
            local content = enabled
                    and string.format("  - %s (**enabled**)", color)
                or string.format("  - %s (disabled)", color)
            vim.api.nvim_buf_set_lines(bufnr, lineno, lineno, true, { content })
            lineno = lineno + 1
        end
    end
    vim.schedule(function()
        vim.cmd(string.format([[call setpos('.', [%d, 1, 1])]], bufnr))
    end)
end

local CONTROLLERS_MAP = {
    update = _update,
    reinstall = _reinstall,
    info = _info,
}

--- @param opts colorbox.Options?
local function setup(opts)
    Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})

    logging.setup({
        name = "colorbox",
        level = Configs.debug and LogLevels.DEBUG or LogLevels.INFO,
        console_log = Configs.console_log,
        file_log = Configs.file_log,
        file_log_name = "colorbox.log",
    })

    -- cache
    assert(
        vim.fn.filereadable(Configs.cache_dir) <= 0,
        string.format(
            "%s (cache_dir option) already exist but not a directory!",
            Configs.cache_dir
        )
    )
    vim.fn.mkdir(Configs.cache_dir, "p")
    Configs.previous_track_cache =
        string.format("%s/previous_track_cache", Configs.cache_dir)

    _init()

    vim.api.nvim_create_user_command(
        Configs.command.name,
        function(command_opts)
            local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]

            -- logger.debug(
            --     "|colorbox.setup| command opts:%s",
            --     vim.inspect(command_opts)
            -- )
            local args = vim.trim(command_opts.args)
            local args_splits =
                vim.split(args, " ", { plain = true, trimempty = true })
            -- logger.debug(
            --     "|colorbox.setup| command args:%s, splits:%s",
            --     vim.inspect(args),
            --     vim.inspect(args_splits)
            -- )
            if #args_splits == 0 then
                logger:warn("missing parameter.")
                return
            end
            if type(CONTROLLERS_MAP[args_splits[1]]) == "function" then
                local fn = CONTROLLERS_MAP[args_splits[1]]
                local sub_args = args:sub(string.len(args_splits[1]) + 1)
                fn(sub_args)
            else
                logger:warn("unknown parameter %s.", args_splits[1])
            end
        end,
        {
            nargs = "*",
            range = false,
            bang = true,
            desc = Configs.command.desc,
            complete = function(ArgLead, CmdLine, CursorPos)
                return { "update", "reinstall", "info" }
            end,
        }
    )

    vim.api.nvim_create_autocmd("ColorSchemePre", {
        callback = function(event)
            -- logger.debug(
            --     "|colorbox.setup| ColorSchemePre event:%s",
            --     vim.inspect(event)
            -- )
            local ColorNameToColorSpecsMap =
                require("colorbox.db").get_color_name_to_color_specs_map()
            if
                type(event) ~= "table"
                or ColorNameToColorSpecsMap[event.match] == nil
            then
                return
            end
            local spec = ColorNameToColorSpecsMap[event.match]
            vim.cmd(string.format([[packadd %s]], spec.git_path))
            if
                type(Configs.setup) == "table"
                and type(Configs.setup[spec.handle]) == "function"
            then
                Configs.setup[spec.handle]()
            end
            if
                Configs.background == "dark"
                or Configs.background == "light"
            then
                vim.opt.background = Configs.background
            end
        end,
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function(event)
            -- logger.debug(
            --     "|colorbox.setup| ColorScheme event:%s",
            --     vim.inspect(event)
            -- )
            _save_track(event.match)
        end,
    })

    _timing()
end

local function _get_filtered_color_names_list()
    return FilteredColorNamesList
end

local function _get_filtered_color_name_to_index_map()
    return FilteredColorNameToIndexMap
end

local M = {
    setup = setup,
    update = update,

    -- filter
    _builtin_filter_primary = _builtin_filter_primary,
    _builtin_filter = _builtin_filter,
    _function_filter = _function_filter,
    _all_filter = _all_filter,
    _filter = _filter,

    -- misc
    _force_sync_syntax = _force_sync_syntax,
    _save_track = _save_track,
    _load_previous_track = _load_previous_track,
    _get_next_color_name_by_idx = _get_next_color_name_by_idx,
    _get_prev_color_name_by_idx = _get_prev_color_name_by_idx,
    _get_filtered_color_names_list = _get_filtered_color_names_list,
    _get_filtered_color_name_to_index_map = _get_filtered_color_name_to_index_map,

    -- policy
    _policy_shuffle = _policy_shuffle,
    _policy_in_order = _policy_in_order,
    _policy_reverse_order = _policy_reverse_order,
    _policy_single = _policy_single,
    _policy = _policy,

    -- command
    _parse_args = _parse_args,
}

return M
