local logger = require("colorbox.logger")
local LogLevels = require("colorbox.logger").LogLevels
local utils = require("colorbox.utils")
local json = require("colorbox.json")

--- @alias colorbox.Options table<any, any>
--- @type colorbox.Options
local Defaults = {
    -- shuffle playback
    --- @alias ShufflePolicyConfig "shuffle"
    ---
    --- in order
    --- @alias InOrderPolicyConfig "in_order"
    ---
    --- reverse order
    --- @alias ReverseOrderPolicyConfig "reverse_order"
    ---
    --- single cycle
    --- @alias SinglePolicyConfig "single"
    ---
    -- by filetype policy: filetype => color name
    --- @alias ByFileTypePolicyConfigFileType string
    --- @alias ByFileTypePolicyConfigColorName string
    --- @alias ByFileTypePolicyConfig {name:"filetype",mapping:table<ByFileTypePolicyConfigFileType, ByFileTypePolicyConfigColorName>}
    ---
    -- fixed interval seconds
    --- @alias FixedIntervalPolicyConfig {name:"interval",seconds:integer,implement:ShufflePolicyConfig|InOrderPolicyConfig|ReverseOrderPolicyConfig|SinglePolicyConfig}
    ---
    --- @alias PolicyConfig ShufflePolicyConfig|InOrderPolicyConfig|ReverseOrderPolicyConfig|SinglePolicyConfig|ByFileTypePolicyConfig|FixedIntervalPolicyConfig
    --- @type PolicyConfig
    policy = "shuffle",

    --- @type "startup"|"interval"|"filetype"
    timing = "startup",

    --- @type "primary"|fun(color:string,spec:colorbox.ColorSpec):boolean|nil
    filter = nil,

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

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _primary_color_name_filter(color_name, spec)
    local unique = #spec.color_names <= 1
    local shortest = string.len(color_name)
        == utils.min(spec.color_names, string.len)
    local handle_splits =
        vim.split(spec.handle, "/", { plain = true, trimempty = true })
    local matched = handle_splits[1]:lower() == color_name:lower()
        or handle_splits[2]:lower() == color_name:lower()
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

local function _before_running_colorscheme_hook()
    if Configs.background == "dark" or Configs.background == "light" then
        vim.opt.background = Configs.background
    end
end

local function _after_running_colorscheme_hook()
    vim.cmd([[syntax sync fromstart]])
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
        _before_running_colorscheme_hook()
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
        _before_running_colorscheme_hook()
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
        _before_running_colorscheme_hook()
        vim.cmd(string.format([[color %s]], color))
        _save_previous_track(color, i)
    end
end

--- @param po colorbox.Options?
local function _is_fixed_interval_policy(po)
    return type(po) == "table"
        and po.name == "interval"
        and type(po.seconds) == "number"
        and po.seconds >= 0
        and type(po.implement) == "string"
        and string.len(po.implement) > 0
end

local function _policy_fixed_interval()
    local later = Configs.policy.seconds > 0 and (Configs.policy.seconds * 1000)
        or utils.int32_max

    local function impl()
        if Configs.policy.implement == "shuffle" then
            _policy_shuffle()
            _after_running_colorscheme_hook()
        elseif Configs.policy.implement == "in_order" then
            _policy_in_order()
            _after_running_colorscheme_hook()
        elseif Configs.policy.implement == "reverse_order" then
            _policy_reverse_order()
            _after_running_colorscheme_hook()
            -- elseif Configs.policy.implement == "single" then
            --     -- TODO: implement single cycle
        end
        vim.defer_fn(impl, later)
    end
    impl()
end

local function _policy()
    if Configs.policy == "shuffle" then
        _policy_shuffle()
    elseif Configs.policy == "in_order" then
        _policy_in_order()
    elseif Configs.policy == "reverse_order" then
        _policy_reverse_order()
    elseif _is_fixed_interval_policy(Configs.policy) then
        _policy_fixed_interval()
    end
end

local function _timing_startup()
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = _policy,
    })
end

local function _timing_interval()
    -- Configs.timing
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
    end
end

--- @param opts {concurrency:integer}?
local function update(opts)
    opts = opts or { concurrency = 4 }
    opts.concurrency = type(opts.concurrency) == "number"
            and math.max(opts.concurrency, 1)
        or 4

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
    logger.info("started %s jobs", vim.inspect(prepared_count))

    for handle, spec in pairs(HandleToColorSpecsMap) do
        local function _on_output(chanid, data, name)
            if type(data) == "table" then
                logger.debug(
                    "(%s) %s: %s",
                    vim.inspect(name),
                    vim.inspect(handle),
                    vim.inspect(data)
                )
                local lines = {}
                for _, d in ipairs(data) do
                    if type(d) == "string" and string.len(vim.trim(d)) > 0 then
                        table.insert(lines, d)
                    end
                end
                if #lines > 0 then
                    logger.info("%s: %s", handle, table.concat(lines, ""))
                end
            end
        end
        local function _on_exit(jid, exitcode, name)
            logger.debug(
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
                logger.err(
                    "failed to remove job id %s from jobs_working_queue: %s",
                    vim.inspect(jid),
                    vim.inspect(jobs_working_queue)
                )
            end
            if jobid_to_jobs_map[jid] == nil then
                logger.err(
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
                logger.info("finished %s jobs", vim.inspect(finished_count))
                logger.close_file_mode_w()
            end
        end

        local param = nil
        if
            vim.fn.isdirectory(spec.full_pack_path) > 0
            and vim.fn.isdirectory(spec.full_pack_path .. "/.git") > 0
        then
            param = {
                handle = handle,
                cmd = (
                    type(spec.git_branch) == "string"
                    and string.len(spec.git_branch) > 0
                )
                        and string.format(
                            "git checkout -b %s && git pull",
                            spec.git_branch
                        )
                    or string.format("git pull"),
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
    local opened_dir, opendir_err = vim.loop.fs_opendir(full_pack_dir)
    if not opened_dir then
        logger.debug(
            "directory %s not found, error: %s",
            vim.inspect(shorten_pack_dir),
            vim.inspect(opendir_err)
        )
        return
    end
    if vim.fn.executable("rm") > 0 then
        local jobid = vim.fn.jobstart({ "rm", "-rf", full_pack_dir }, {
            detach = false,
            stdout_buffered = true,
            stderr_buffered = true,
            on_stdout = function(chanid, data, name)
                logger.debug(
                    "clean job(%s) data:%s",
                    vim.inspect(name),
                    vim.inspect(data)
                )
            end,
            on_stderr = function(chanid, data, name)
                logger.debug(
                    "clean job(%s) data:%s",
                    vim.inspect(name),
                    vim.inspect(data)
                )
            end,
            on_exit = function(jid, exitcode, name)
                logger.debug(
                    "clean job(%s) done:%s",
                    vim.inspect(name),
                    vim.inspect(exitcode)
                )
            end,
        })
        vim.fn.jobwait({ jobid })
        logger.info("cleaned directory: %s", shorten_pack_dir)
    else
        logger.warn("no 'rm' command found, skip cleaning...")
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

    vim.api.nvim_create_user_command(
        Configs.command.name,
        function(command_opts)
            -- logger.debug(
            --     "|colorbox.setup| command opts:%s",
            --     vim.inspect(command_opts)
            -- )
            local args = vim.trim(command_opts.args)
            local args_splits =
                vim.split(args, " ", { plain = true, trimempty = true })
            logger.debug(
                "|colorbox.setup| command args:%s, splits:%s",
                vim.inspect(args),
                vim.inspect(args_splits)
            )
            if #args_splits == 0 then
                logger.warn("missing parameter.")
                return
            end
            if type(CONTROLLERS_MAP[args_splits[1]]) == "function" then
                local fn = CONTROLLERS_MAP[args_splits[1]]
                local sub_args = args:sub(string.len(args_splits[1]) + 1)
                fn(sub_args)
            else
                logger.warn("unknown parameter %s.", args_splits[1])
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

local M = { setup = setup, update = update, install = install }

return M
