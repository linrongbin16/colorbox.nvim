local logging = require("colorbox.commons.logging")
local LogLevels = require("colorbox.commons.logging").LogLevels
local jsons = require("colorbox.commons.jsons")
local uv = require("colorbox.commons.uv")
local numbers = require("colorbox.commons.numbers")
local fileios = require("colorbox.commons.fileios")
local strings = require("colorbox.commons.strings")

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

    --- @type "startup"|"interval"|"bufferchanged"
    timing = "startup",

    -- (Optional) filters that disable some colors that you don't want.
    --
    -- builtin filter
    --- @alias colorbox.BuiltinFilterConfig "primary"
    ---
    -- function-based filter, disabled if function return true.
    --- @alias colorbox.FunctionFilterConfig fun(color:string, spec:colorbox.ColorSpec):boolean
    ---
    ---list-based filter, disabled if any of filter hit the conditions.
    --- @alias colorbox.AnyFilterConfig (colorbox.BuiltinFilterConfig|colorbox.FunctionFilterConfig)[]
    ---
    --- @alias colorbox.FilterConfig colorbox.BuiltinFilterConfig|colorbox.FunctionFilterConfig|colorbox.AnyFilterConfig
    --- @type colorbox.FilterConfig?
    filter = "primary",

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

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _primary_color_name_filter(color_name, spec)
    local unique = #spec.color_names <= 1
    local shortest = string.len(color_name)
        == numbers.min(string.len, unpack(spec.color_names))
    local handle_splits =
        vim.split(spec.handle, "/", { plain = true, trimempty = true })
    local matched = handle_splits[1]:lower() == color_name:lower()
        or handle_splits[2]:lower() == color_name:lower()
    -- logger.debug(
    --     "|colorbox._primary_color_name_filter| color:%s, spec:%s, unique:%s, shortest: %s, matched:%s",
    --     vim.inspect(color_name),
    --     vim.inspect(spec),
    --     vim.inspect(unique),
    --     vim.inspect(shortest),
    --     vim.inspect(matched)
    -- )
    return not unique and not shortest and not matched
end

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _should_filter(color_name, spec)
    if Configs.filter == nil or type(Configs.filter) == "boolean" then
        return Configs.filter or false
    end
    if Configs.filter == "primary" then
        return _primary_color_name_filter(color_name, spec)
    elseif type(Configs.filter) == "function" then
        return Configs.filter(color_name)
    elseif type(Configs.filter) == "table" then
        for _, f in ipairs(Configs.filter) do
            if f(color_name, spec) then
                return true
            end
        end
        return false
    end
    assert(
        false,
        string.format(
            "unknown 'filter' option: %s",
            vim.inspect(Configs.filter)
        )
    )
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
        if not _should_filter(color_name, spec) and pack_exist then
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

--- @alias PreviousTrack {color_name:string,color_number:integer}
--- @param color_name string
local function _save_track(color_name)
    if
        type(color_name) ~= "string"
        or string.len(vim.trim(color_name)) == 0
    then
        return
    end
    -- start from 0, end with #FilteredColorNamesList-1
    local color_number = FilteredColorNameToIndexMap[color_name] or 0
    vim.schedule(function()
        local content = jsons.encode({
            color_name = color_name,
            color_number = color_number,
        }) --[[@as string]]
        fileios.writefile(Configs.previous_track_cache, content)
    end)
end

--- @return PreviousTrack?
local function _load_previous_track()
    local content = fileios.readfile(Configs.previous_track_cache)
    if content == nil then
        return nil
    end
    return jsons.decode(content) --[[@as PreviousTrack]]
end

--- @param idx integer
--- @return string
local function _get_next_color_name_by_idx(idx)
    assert(type(idx) == "number" and idx > 0)
    idx = idx + 1
    if idx > #FilteredColorNamesList then
        idx = 1
    end
    return FilteredColorNamesList[idx]
end

--- @param idx integer
--- @return string
local function _get_prev_color_name_by_idx(idx)
    assert(type(idx) == "number" and idx > 0)
    idx = idx - 1
    if idx < 1 then
        idx = #FilteredColorNamesList
    end
    return FilteredColorNamesList[idx]
end

local function randint(n)
    local secs, millis = uv.gettimeofday()
    local pid = uv.os_getpid()

    secs = tonumber(secs) or math.random(n)
    millis = tonumber(millis) or math.random(n)
    pid = tonumber(pid) or math.random(n)

    local total = numbers.mod(
        numbers.mod(secs + millis, numbers.INT32_MAX) + pid,
        numbers.INT32_MAX
    )

    local chars = strings.tochars(tostring(total))
    chars = numbers.shuffle(chars)
    chars = table.concat(chars, "")
    return numbers.mod(tonumber(chars) or math.random(n), n) + 1
end

local function _policy_shuffle()
    if #FilteredColorNamesList > 0 then
        local i = randint(#FilteredColorNamesList)
        local color = _get_next_color_name_by_idx(i)
        logging.get("colorbox"):debug(
            "|_policy_shuffle| color:%s, FilteredColorNamesList:%s (%d), i:%d",
            vim.inspect(color),
            vim.inspect(FilteredColorNamesList),
            vim.inspect(#FilteredColorNamesList),
            vim.inspect(i)
        )
        local ok, err = pcall(
            vim.cmd --[[@as function]],
            string.format([[color %s]], color)
        )
        assert(ok, err)
    end
end

local function _policy_in_order()
    if #FilteredColorNamesList > 0 then
        local previous_track = _load_previous_track() --[[@as PreviousTrack]]
        local i = previous_track ~= nil and previous_track.color_number or 0
        local color = _get_next_color_name_by_idx(i)
        ---@diagnostic disable-next-line: param-type-mismatch
        local ok, err = pcall(vim.cmd, string.format([[color %s]], color))
        assert(ok, err)
    end
end

local function _policy_reverse_order()
    if #FilteredColorNamesList > 0 then
        local previous_track = _load_previous_track() --[[@as PreviousTrack]]
        local i = previous_track ~= nil and previous_track.color_number
            or (#FilteredColorNamesList + 1)
        local color = _get_prev_color_name_by_idx(i)
        ---@diagnostic disable-next-line: param-type-mismatch
        local ok, err = pcall(vim.cmd, string.format([[color %s]], color))
        assert(ok, err)
    end
end

local function _policy_single()
    if #FilteredColorNamesList > 0 then
        local previous_track = _load_previous_track() --[[@as PreviousTrack]]
        local color = nil
        if previous_track then
            color = previous_track.color_name
        else
            color = _get_next_color_name_by_idx(0)
        end
        if color ~= vim.g.colors_name then
            ---@diagnostic disable-next-line: param-type-mismatch
            local ok, err = pcall(vim.cmd, string.format([[color %s]], color))
            assert(ok, err)
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
                ---@diagnostic disable-next-line: param-type-mismatch
                vim.cmd,
                string.format([[color %s]], Configs.policy.mapping[ft])
            )
            assert(ok, err)
        else
            local ok, err =
                ---@diagnostic disable-next-line: param-type-mismatch
                pcall(
                    vim.cmd,
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

local function _timing_buffer_changed()
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
    elseif Configs.timing == "bufferchanged" then
        assert(
            _is_by_filetype_policy(Configs.policy),
            string.format(
                "invalid policy %s for 'bufferchanged' timing!",
                vim.inspect(Configs.policy)
            )
        )
        _timing_buffer_changed()
    else
        error(string.format("invalid timing %s!", vim.inspect(Configs.timing)))
    end
end

--- @param opts {concurrency:integer}?
local function update(opts)
    opts = opts or { concurrency = 4 }
    opts.concurrency = type(opts.concurrency) == "number"
            and math.max(opts.concurrency, 1)
        or 4

    logging.setup({
        name = "colorbox-update",
        level = LogLevels.DEBUG,
        console_log = true,
        file_log = true,
        file_log_name = "colorbox_update.log",
        file_log_mode = "w",
    })
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

    -- a list of job params
    --- @type colorbox.Options[]
    local jobs_pending_queue = {}

    -- a list of job id
    --- @type integer[]
    local jobs_working_queue = {}

    -- job id to job params map
    --- @type table<integer, colorbox.Options>
    local jobid_to_jobs_map = {}

    local prepared_count = 0
    local finished_count = 0

    for handle, spec in pairs(HandleToColorSpecsMap) do
        prepared_count = prepared_count + 1
    end
    logging
        .get("colorbox-update")
        :info("started %s jobs", vim.inspect(prepared_count))

    for handle, spec in pairs(HandleToColorSpecsMap) do
        local function _on_output(chanid, data, name)
            if type(data) == "table" then
                logger:debug(
                    "(%s) %s: %s",
                    vim.inspect(name),
                    vim.inspect(handle),
                    vim.inspect(data)
                )
                for _, d in ipairs(data) do
                    if type(d) == "string" and string.len(vim.trim(d)) > 0 then
                        logger:info("%s: %s", handle, d)
                    end
                end
            end
        end
        local function _on_exit(jid, exitcode, name)
            logger:debug(
                "(%s-%s) %s: exit with %s",
                vim.inspect(name),
                vim.inspect(jid),
                vim.inspect(handle),
                vim.inspect(exitcode)
            )

            local removed_from_working_queue = false
            for i, working_jobid in ipairs(jobs_working_queue) do
                if working_jobid == jid then
                    table.remove(jobs_working_queue, i)
                    removed_from_working_queue = true
                    break
                end
            end
            if not removed_from_working_queue then
                logger:err(
                    "failed to remove job id %s from jobs_working_queue: %s",
                    vim.inspect(jid),
                    vim.inspect(jobs_working_queue)
                )
            end
            if jobid_to_jobs_map[jid] == nil then
                logger:err(
                    "failed to remove job id %s from jobid_to_jobs_map: %s",
                    vim.inspect(jid),
                    vim.inspect(jobid_to_jobs_map)
                )
            end
            jobid_to_jobs_map[jid] = nil

            if #jobs_pending_queue > 0 then
                local waiting_job_param = jobs_pending_queue[1]
                table.remove(jobs_pending_queue, 1)

                local new_jobid = vim.fn.jobstart(
                    waiting_job_param.cmd,
                    waiting_job_param.opts
                )
                table.insert(jobs_working_queue, new_jobid)
                jobid_to_jobs_map[new_jobid] = waiting_job_param

                finished_count = finished_count + 1
            else
                logging
                    .get("colorbox-update")
                    :info("finished %s jobs", vim.inspect(finished_count))
            end
        end

        local param = nil
        if
            vim.fn.isdirectory(spec.full_pack_path) > 0
            and vim.fn.isdirectory(spec.full_pack_path .. "/.git") > 0
        then
            param = {
                handle = handle,
                cmd = "git pull",
                opts = {
                    cwd = spec.full_pack_path,
                    detach = true,
                    stdout_buffered = true,
                    stderr_buffered = true,
                    on_stdout = _on_output,
                    on_stderr = _on_output,
                    on_exit = _on_exit,
                },
            }
        else
            param = {
                handle = handle,
                cmd = (
                    type(spec.git_branch) == "string"
                    and string.len(spec.git_branch) > 0
                )
                        and {
                            "git",
                            "clone",
                            "--branch",
                            spec.git_branch,
                            "--depth=1",
                            spec.url,
                            spec.pack_path,
                        }
                    or { "git", "clone", "--depth=1", spec.url, spec.pack_path },
                opts = {
                    cwd = home_dir,
                    detach = true,
                    stdout_buffered = true,
                    stderr_buffered = true,
                    on_stdout = _on_output,
                    on_stderr = _on_output,
                    on_exit = _on_exit,
                },
            }
        end

        table.insert(jobs_pending_queue, param)

        if #jobs_working_queue < opts.concurrency then
            local waiting_job_param = jobs_pending_queue[1]
            table.remove(jobs_pending_queue, 1)

            local new_jobid =
                vim.fn.jobstart(waiting_job_param.cmd, waiting_job_param.opts)
            table.insert(jobs_working_queue, new_jobid)
            jobid_to_jobs_map[new_jobid] = waiting_job_param

            finished_count = finished_count + 1
        end
    end
end

--- @deprecated
local function install(opts)
    return update(opts)
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
local function _parse_update_args(args)
    local opts = nil
    if type(args) == "string" and string.len(vim.trim(args)) > 0 then
        local args_splits =
            vim.split(args, "=", { plain = true, trimempty = true })
        if args_splits[1] == "concurrency" then
            opts = { concurrency = tonumber(args_splits[2]) }
        end
    end
    return opts
end

--- @param args string
local function _update(args)
    update(_parse_update_args(args))
end

--- @param args string
local function _reinstall(args)
    _clean()
    update(_parse_update_args(args))
end

local CONTROLLERS_MAP = {
    update = _update,
    reinstall = _reinstall,
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
                return { "update", "reinstall" }
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

local M = { setup = setup, update = update, install = install }

return M
