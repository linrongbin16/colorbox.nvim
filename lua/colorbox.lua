local logger = require("colorbox.logger")
local LogLevels = require("colorbox.logger").LogLevels
local utils = require("colorbox.utils")
local json = require("colorbox.json")

--- @alias colorbox.Options table<any, any>
--- @type colorbox.Options
local Defaults = {
    --- @type "shuffle"|"in_order"|"reverse_order"|"single"
    policy = "shuffle",

    --- @type "startup"|"interval"|"filetype"
    timing = "startup",

    --- @type "primary"|fun(color:string,spec:colorbox.ColorSpec):boolean|nil
    filter = nil,

    setup = {
        ["projekt0n/github-nvim-theme"] = function()
            require("github-theme").setup()
        end,
    },

    --- @type "dark"|"light"|nil
    background = nil,

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

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _primary_color_name_filter(color_name, spec)
    local unique = #spec.color_names <= 1
    local shortest = string.len(color_name)
        == utils.min(spec.color_names, string.len)
    local url_splits =
        vim.split(spec.url, "/", { plain = true, trimempty = true })
    local matched = url_splits[1]:lower() == color_name:lower()
        or url_splits[2]:lower() == color_name:lower()
    logger.debug(
        "|colorbox._primary_color_name_filter| color:%s, spec:%s, unique:%s, shortest: %s, matched:%s",
        vim.inspect(color_name),
        vim.inspect(spec),
        vim.inspect(unique),
        vim.inspect(shortest),
        vim.inspect(matched)
    )
    return not unique and not shortest and not matched
end

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _should_filter(color_name, spec)
    if Configs.filter == nil then
        return false
    end
    if Configs.filter == "primary" then
        return _primary_color_name_filter(color_name, spec)
    elseif type(Configs.filter) == "function" then
        return Configs.filter(color_name)
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
    local pack_dir = "pack/colorbox/start"
    local full_pack_dir = string.format("%s/%s", home_dir, pack_dir)
    logger.debug(
        "|colorbox.init| home_dir:%s, pack_dir:%s, full_pack_dir:%s",
        vim.inspect(home_dir),
        vim.inspect(pack_dir),
        vim.inspect(full_pack_dir)
    )
    vim.opt.packpath:append(home_dir)
    -- vim.opt.packpath:append(cwd .. "/pack")
    -- vim.opt.packpath:append(cwd .. "/pack/colorbox")
    -- vim.opt.packpath:append(cwd .. "/pack/colorbox/opt")
    -- vim.cmd([[packadd catppuccin-nvim]])

    local ColorNameToColorSpecsMap =
        require("colorbox.db").get_color_name_to_color_specs_map()
    local ColorNamesList = require("colorbox.db").get_color_names_list()
    for _, color_name in pairs(ColorNamesList) do
        local spec = ColorNameToColorSpecsMap[color_name]
        if not _should_filter(color_name, spec) then
            table.insert(FilteredColorNamesList, color_name)
        end
    end
    logger.debug(
        "|colorbox._init| FilteredColorNamesList:%s",
        vim.inspect(FilteredColorNamesList)
    )
end

--- @alias PreviousTrack {color_name:string,color_number:integer}
--- @param color_name string
--- @param color_number integer
local function _save_previous_track(color_name, color_number)
    assert(
        type(color_name) == "string" and string.len(vim.trim(color_name)) > 0,
        string.format("invalid color name %s", vim.inspect(color_name))
    )
    vim.schedule(function()
        local content = json.encode({
            color_name = color_name,
            color_number = color_number,
        }) --[[@as string]]
        utils.writefile(Configs.previous_track_cache, content)
    end)
end

--- @return PreviousTrack?
local function _load_previous_track()
    local content = utils.readfile(Configs.previous_track_cache)
    if content == nil then
        return nil
    end
    return json.decode(content) --[[@as PreviousTrack]]
end

local function _policy_shuffle()
    if #FilteredColorNamesList > 0 then
        local i = utils.randint(#FilteredColorNamesList)
        local color = FilteredColorNamesList[i + 1]
        -- logger.debug(
        --     "|colorbox._policy_shuffle| color:%s, ColorNames:%s (%d), r:%d",
        --     vim.inspect(color),
        --     vim.inspect(ColorNames),
        --     vim.inspect()
        -- )
        vim.cmd(string.format([[color %s]], color))
        _save_previous_track(color, i)
    end
end

local function _policy_in_order()
    if #FilteredColorNamesList > 0 then
        local previous_track = _load_previous_track() --[[@as PreviousTrack]]
        local i = previous_track == nil and 0
            or utils.math_mod(
                previous_track.color_number + 1,
                #FilteredColorNamesList
            )
        local color = FilteredColorNamesList[i + 1]
        vim.cmd(string.format([[color %s]], color))
        _save_previous_track(color, i)
    end
end

local function _policy_reverse_order()
    if #FilteredColorNamesList > 0 then
        local previous_track = _load_previous_track() --[[@as PreviousTrack]]
        local i = previous_track == nil and 0
            or (
                previous_track.color_number - 1 < 0
                    and (#FilteredColorNamesList - 1)
                or previous_track.color_number - 1
            )
        local color = FilteredColorNamesList[i + 1]
        vim.cmd(string.format([[color %s]], color))
        _save_previous_track(color, i)
    end
end

local function _policy()
    if Configs.background == "dark" or Configs.background == "light" then
        vim.cmd(string.format([[set background=%s]], Configs.background))
    end
    if Configs.policy == "shuffle" then
        _policy_shuffle()
    elseif Configs.policy == "in_order" then
        _policy_in_order()
    elseif Configs.policy == "reverse_order" then
        _policy_reverse_order()
    end
end

local function _timing_startup()
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = _policy,
    })
end

local function _timing()
    _timing_startup()
end

--- @param opts colorbox.Options?
local function setup(opts)
    Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})

    logger.setup({
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

    vim.api.nvim_create_autocmd("ColorSchemePre", {
        callback = function(event)
            logger.debug("|colorbox.setup| event:%s", vim.inspect(event))
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
        end,
    })

    _timing()
end

--- @param opts {detach:boolean?,concurrency:boolean}?
local function update(opts)
    opts = opts or { detach = false, concurrency = true }
    opts.detach = type(opts.detach) == "boolean" and opts.detach or false
    opts.concurrency = type(opts.concurrency) == "boolean" and opts.concurrency
        or true

    logger.setup({
        name = "colorbox",
        level = LogLevels.DEBUG,
        console_log = true,
        file_log = true,
        file_log_name = "colorbox_update.log",
        file_log_mode = "w",
    })

    local home_dir = vim.fn["colorbox#base_dir"]()
    local packstart = string.format("%s/pack/colorbox/start", home_dir)
    logger.debug(
        "|colorbox.init| home_dir:%s, pack:%s",
        vim.inspect(home_dir),
        vim.inspect(packstart)
    )
    vim.opt.packpath:append(home_dir)

    local jobs = {}
    local HandleToColorSpecsMap =
        require("colorbox.db").get_handle_to_color_specs_map()
    for handle, spec in pairs(HandleToColorSpecsMap) do
        local function _on_output(chanid, data, name)
            if type(data) == "table" then
                logger.debug(
                    "%s (%s): %s",
                    vim.inspect(handle),
                    vim.inspect(name),
                    vim.inspect(data)
                )
                local lines = {}
                for _, line in ipairs(data) do
                    if string.len(vim.trim(line)) > 0 then
                        table.insert(lines, line)
                    end
                end
                if #lines > 0 then
                    logger.info("%s: %s", handle, table.concat(lines, ""))
                end
            end
        end
        local function _on_exit(jid, exitcode, name)
            logger.debug(
                "%s (%s-%s): exit with %s",
                vim.inspect(handle),
                vim.inspect(jid),
                vim.inspect(name),
                vim.inspect(exitcode)
            )
        end

        if
            vim.fn.isdirectory(spec.full_pack_path) > 0
            and vim.fn.isdirectory(spec.full_pack_path .. "/.git") > 0
        then
            local cmd = { "git", "pull" }
            logger.debug("update command:%s", vim.inspect(cmd))
            local jobid = vim.fn.jobstart(cmd, {
                cwd = spec.full_pack_path,
                detach = opts.detach,
                stdout_buffered = true,
                stderr_buffered = true,
                on_stdout = _on_output,
                on_stderr = _on_output,
                on_exit = _on_exit,
            })
            if opts.concurrency then
                table.insert(jobs, jobid)
            else
                vim.fn.jobwait({ jobid })
            end
        else
            local cmd =
                { "git", "clone", "--depth=1", spec.url, spec.pack_path }
            logger.debug("install command:%s", vim.inspect(cmd))
            local jobid = vim.fn.jobstart(cmd, {
                cwd = home_dir,
                detach = opts.detach,
                stdout_buffered = true,
                stderr_buffered = true,
                on_stdout = _on_output,
                on_stderr = _on_output,
                on_exit = _on_exit,
            })
            if opts.concurrency then
                table.insert(jobs, jobid)
            else
                vim.fn.jobwait({ jobid })
            end
        end
    end
    if not opts.detach and opts.concurrency then
        vim.fn.jobwait(jobs)
    end
end

local M = { setup = setup, update = update }

return M
