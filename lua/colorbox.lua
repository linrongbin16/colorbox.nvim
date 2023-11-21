local logger = require("colorbox.logger")
local LogLevels = require("colorbox.logger").LogLevels
local json = require("colorbox.json")
local utils = require("colorbox.utils")

--- @alias colorbox.Options table<any, any>
--- @type colorbox.Options
local Defaults = {
    --- @type "shuffle"|"inorder"|"single"
    policy = "shuffle",

    --- @type "startup"|"interval"|"filetype"
    timing = "startup",

    --- @type "primary"|fun(color:string):boolean|nil
    filter = nil,

    setup = {
        ["projekt0n/github-nvim-theme"] = function()
            require("github-theme").setup()
        end,
    },

    --- @type "dark"|"light"|nil
    background = nil,

    -- enable debug
    debug = false,

    -- print log to console (command line)
    console_log = true,

    -- print log to file.
    file_log = false,
}

--- @type colorbox.Options
local Configs = {}

--- @class colorbox.ColorSpec
--- @field url string
--- @field name string pack name
--- @field path string path full path
--- @field colors string[] color file base name
--- @field stars integer
--- @field last_update string
--- @field priority integer
--- @field source string
local ColorSpec = {}

--- @param url string
--- @param name string
--- @param path string
--- @param colors string[]|nil
--- @param stars integer?
--- @param last_update string?
--- @param priority integer?
--- @param source string?
--- @return colorbox.ColorSpec
function ColorSpec:new(
    url,
    name,
    path,
    colors,
    stars,
    last_update,
    priority,
    source
)
    local o = {
        url = url,
        name = name,
        path = path,
        colors = colors or {},
        stars = stars,
        last_update = last_update,
        priority = priority,
        source = source,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

-- color names list
--- @type string[]
local ColorNamesList = {}

--- @param cwd string
--- @return table<string, {url:string,stars:integer,last_update:string,priority:integer,source:string,obj_name:string}>
local function _load_repo_meta_urls_map(cwd)
    local dbfile = string.format("%s/db.json", cwd)
    local fp = io.open(dbfile, "r")
    assert(fp, string.format("failed to read %s", vim.inspect(dbfile)))
    local dbtext = fp:read("*a")
    fp:close()
    local dbdata = json.decode(dbtext) --[[@as table]]
    local repos = {}
    for i, d in pairs(dbdata["_default"]) do
        repos[d.url] = d
    end
    return repos
end

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _primary_color_name_filter(color_name, spec)
    local unique = #spec.colors <= 1
    local variants = spec.colors
    local shortest = string.len(color_name) == utils.min(variants, string.len)
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
    local cwd = vim.fn["colorbox#base_dir"]()
    local pack_dir = "pack/colorbox/start"
    local full_pack_dir = string.format("%s/%s", cwd, pack_dir)
    logger.debug(
        "|colorbox.init| cwd:%s, pack_dir:%s, full_pack_dir:%s",
        vim.inspect(cwd),
        vim.inspect(pack_dir),
        vim.inspect(full_pack_dir)
    )
    vim.opt.packpath:append(cwd)
    -- vim.opt.packpath:append(cwd .. "/pack")
    -- vim.opt.packpath:append(cwd .. "/pack/colorbox")
    -- vim.opt.packpath:append(cwd .. "/pack/colorbox/opt")
    -- vim.cmd([[packadd catppuccin-nvim]])

    local HandleToColorSpecsMap =
        require("colorbox.db").get_handle_to_color_specs_map()
    for handle, spec in pairs(HandleToColorSpecsMap) do
        if
            vim.fn.isdirectory(spec.pack_path) > 0
            and vim.fn.isdirectory(spec.pack_path .. "/.git") > 0
        then
            for _, color_name in ipairs(spec.color_names) do
                if not _should_filter(color_name, spec) then
                    table.insert(ColorNamesList, color_name)
                end
            end
        end
    end
    logger.debug(
        "|colorbox._init| before sort ColorNamesList:%s",
        vim.inspect(ColorNamesList)
    )
    table.sort(ColorNamesList)
    logger.debug(
        "|colorbox._init| ColorNamesList:%s",
        vim.inspect(ColorNamesList)
    )
end

local function _policy_shuffle()
    if #ColorNamesList > 0 then
        local r = utils.randint(#ColorNamesList)
        local color = ColorNamesList[r + 1]
        -- logger.debug(
        --     "|colorbox._policy_shuffle| color:%s, ColorNames:%s (%d), r:%d",
        --     vim.inspect(color),
        --     vim.inspect(ColorNames),
        --     vim.inspect()
        -- )
        vim.cmd(string.format([[color %s]], color))
    end
end

local function _policy()
    if Configs.background == "dark" or Configs.background == "light" then
        vim.opt.background = Configs.background
    end
    _policy_shuffle()
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

local function update()
    logger.setup({
        name = "colorbox",
        level = LogLevels.DEBUG,
        console_log = true,
        file_log = true,
        file_log_name = "colorbox_install.log",
    })

    local cwd = vim.fn["colorbox#base_dir"]()
    local packstart = string.format("%s/pack/colorbox/start", cwd)
    logger.debug(
        "|colorbox.init| cwd:%s, pack:%s",
        vim.inspect(cwd),
        vim.inspect(packstart)
    )
    vim.opt.packpath:append(cwd)

    local jobs = {}

    local HandleToColorSpecsMap =
        require("colorbox.db").get_handle_to_color_specs_map()
    for handle, spec in pairs(HandleToColorSpecsMap) do
        local function _on_output(chanid, data, name)
            if type(data) == "table" then
                logger.debug("%s: %s", vim.inspect(name), vim.inspect(data))
                local lines = {}
                for _, line in ipairs(data) do
                    if string.len(vim.trim(line)) > 0 then
                        table.insert(lines, line)
                    end
                end
                if #lines > 0 then
                    logger.info(table.concat(lines, ""))
                end
            end
        end

        if
            vim.fn.isdirectory(spec.full_pack_path) > 0
            and vim.fn.isdirectory(spec.full_pack_path .. "/.git") > 0
        then
            local cmd = string.format("cd %s && git pull", spec.full_pack_path)
            logger.debug("update command:%s", vim.inspect(cmd))
            local jobid = vim.fn.jobstart(cmd, {
                stdout_buffered = true,
                stderr_buffered = true,
                on_stdout = _on_output,
                on_stderr = _on_output,
            })
            table.insert(jobs, jobid)
        else
            local cmd = string.format(
                "cd %s && git clone --depth=1 %s %s",
                cwd,
                spec.url,
                spec.pack_path
            )
            logger.debug("install command:%s", vim.inspect(cmd))
            local jobid = vim.fn.jobstart(cmd, {
                stdout_buffered = true,
                stderr_buffered = true,
                on_stdout = _on_output,
                on_stderr = _on_output,
            })
            logger.debug("installing %s", vim.inspect(handle))
            table.insert(jobs, jobid)
        end
    end
    vim.fn.jobwait(jobs)
end

local M = { setup = setup, update = update }

return M
