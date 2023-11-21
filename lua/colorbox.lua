local logger = require("colorbox.logger")
local LogLevels = require("colorbox.logger").LogLevels
local json = require("colorbox.json")

local function randint()
    local s1 = vim.loop.getpid()
    local s2, s3 = vim.loop.gettimeofday()
    local s4 = math.random()
    local int32_max = 2 ^ 31 - 1
    local r = math.min(s1, int32_max)
    r = math.min(r + s2, int32_max)
    r = math.min(r + s3, int32_max)
    r = math.min(r + s4, int32_max)
    return math.floor(r)
end

--- @param s string
--- @param t string
--- @return boolean
local function string_endswith(s, t)
    return string.len(s) >= string.len(t) and s:sub(#s - #t + 1) == t
end

--- @param s string
--- @param t string
--- @param start integer?
--- @return integer?
local function string_find(s, t, start)
    -- start = start or 1
    -- local result = vim.fn.stridx(s, t, start - 1)
    -- return result >= 0 and (result + 1) or nil

    start = start or 1
    for i = start, #s do
        local match = true
        for j = 1, #t do
            if i + j - 1 > #s then
                match = false
                break
            end
            local a = string.byte(s, i + j - 1)
            local b = string.byte(t, j)
            if a ~= b then
                match = false
                break
            end
        end
        if match then
            return i
        end
    end
    return nil
end

--- @enum colorbox.PolicyConfigEnum
local PolicyConfigEnum = {
    SHUFFLE = "shuffle",
    INORDER = "inorder",
    SINGLE = "single",
}

--- @enum colorbox.TimingConfigEnum
local TimingConfigEnum = {
    STARTUP = "startup",
    INTERVAL = "interval",
    FILETYPE = "filetype",
}

--- @alias colorbox.Options table<any, any>
--- @type colorbox.Options
local Defaults = {
    policy = PolicyConfigEnum.SHUFFLE,

    timing = TimingConfigEnum.STARTUP,

    filter = function() end,

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
--- @field name string pack name
--- @field path string path full path
--- @field colors string[] color file base name
local ColorSpec = {}

--- @param name string
--- @param path string
--- @param colors string[]|nil
--- @return colorbox.ColorSpec
function ColorSpec:new(name, path, colors)
    local o = {
        name = name,
        path = path,
        colors = colors or {},
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

-- specs
--- @type colorbox.ColorSpec[]
local ColorSpecs = {}

-- plugin name => spec
--- @type table<string, colorbox.ColorSpec>
local ColorSpecsMap = {}

-- color names
--- @type string[]
local ColorNames = {}

-- color name => spec
--- @type table<string, colorbox.ColorSpec>
local ColorNamesMap = {}

local function _init()
    local cwd = vim.fn["colorbox#base_dir"]()
    local packstart = string.format("%s/pack/colorbox/start", cwd)
    logger.debug(
        "|colorbox.init| cwd:%s, pack:%s",
        vim.inspect(cwd),
        vim.inspect(packstart)
    )
    vim.opt.packpath:append(cwd)
    -- vim.opt.packpath:append(cwd .. "/pack")
    -- vim.opt.packpath:append(cwd .. "/pack/colorbox")
    -- vim.opt.packpath:append(cwd .. "/pack/colorbox/opt")
    -- vim.cmd([[packadd catppuccin-nvim]])

    local pack_dir = vim.loop.fs_opendir(packstart) --[[@as luv_dir_t]]
    while true do
        local pack_tmp = pack_dir:readdir()
        if type(pack_tmp) == "table" and #pack_tmp > 0 then
            for i, pack_ttmp in ipairs(pack_tmp) do
                if
                    type(pack_ttmp) == "table"
                    and type(pack_ttmp.name) == "string"
                    and pack_ttmp.type == "directory"
                then
                    local spec = ColorSpec:new(
                        pack_ttmp.name,
                        string.format("%s/%s", packstart, pack_ttmp.name)
                    )
                    table.insert(ColorSpecs, spec)
                    ColorSpecsMap[spec.name] = spec
                    local color_dir, err =
                        vim.loop.fs_opendir(spec.path .. "/colors") --[[@as luv_dir_t]]
                    if not color_dir then
                        logger.err(
                            "failed to scan %s directory: %s",
                            vim.inspect(spec.path),
                            vim.inspect(err)
                        )
                    end
                    while true do
                        local color_tmp = color_dir:readdir()
                        if type(color_tmp) == "table" and #color_tmp > 0 then
                            for j, color_ttmp in ipairs(color_tmp) do
                                -- logger.debug(
                                --     "|colorbox.init| colors_ttmp %d:%s",
                                --     j,
                                --     vim.inspect(color_ttmp)
                                -- )
                                if
                                    type(color_ttmp) == "table"
                                    and type(color_ttmp.name) == "string"
                                    and color_ttmp.type == "file"
                                then
                                    local color_file = color_ttmp.name
                                    assert(
                                        string_endswith(color_file, ".vim")
                                            or string_endswith(
                                                color_file,
                                                ".lua"
                                            )
                                    )
                                    local color =
                                        color_file:sub(1, #color_file - 4)
                                    table.insert(spec.colors, color)
                                    ColorNamesMap[color] = spec
                                    table.insert(ColorNames, color)
                                end
                            end
                        else
                            break
                        end
                    end
                end
            end
        else
            break
        end
    end
end

local function _policy_shuffle()
    local n = 0
    for _, spec in pairs(ColorSpecs) do
        n = n + #spec.colors
    end
    local r = math.floor(math.fmod(randint(), n))
    local color = ColorNames[r]
    vim.cmd(string.format([[color %s]], color))
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
            logger.debug("|colorbox.init| event:%s", vim.inspect(event))
            if type(event) ~= "table" or ColorNamesMap[event.match] == nil then
                return
            end
            local spec = ColorNamesMap[event.match]
            vim.cmd(string.format([[packadd %s]], spec.name))
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

    local dbfile = string.format("%s/db.json", cwd)
    local fp = io.open(dbfile, "r")
    assert(fp, string.format("failed to read %s", vim.inspect(dbfile)))
    local dbtext = fp:read("*a")
    fp:close()
    local dbdata = json.decode(dbtext) --[[@as table]]
    local repos = {}
    local jobs = {}
    for i, d in pairs(dbdata["_default"]) do
        repos[d.url] = d
    end
    for url, repo in pairs(repos) do
        local github_url = string.format("https://github.com/%s", url)
        local install_path =
            string.format("%s/%s", packstart, url:gsub("/", "%-"))
        logger.debug("install_path:%s", vim.inspect(install_path))
        if
            vim.fn.isdirectory(install_path) > 0
            and vim.fn.isdirectory(install_path .. "/.git") > 0
        then
            local cmd = string.format("cd %s && git pull")
            logger.debug("update command:%s", vim.inspect(cmd))
            local jobid = vim.fn.jobstart(cmd, {
                stdout_buffered = true,
                stderr_buffered = true,
                on_stderr = function(chanid, data, name)
                    logger.err(
                        "error when updating %s: %s",
                        vim.inspect(url),
                        vim.inspect(data)
                    )
                end,
            })
            logger.info("updating %s", vim.inspect(url))
            table.insert(jobs, jobid)
        else
            local cmd = {
                "git",
                "clone",
                "--depth=1",
                github_url,
                install_path,
            }
            logger.debug("install command:%s", vim.inspect(cmd))
            local jobid = vim.fn.jobstart(cmd, {
                stdout_buffered = true,
                stderr_buffered = true,
                on_stderr = function(chanid, data, name)
                    logger.err(
                        "error when installing %s: %s",
                        vim.inspect(url),
                        vim.inspect(data)
                    )
                end,
            })
            logger.info("installing %s", vim.inspect(url))
            table.insert(jobs, jobid)
        end
    end
    vim.fn.jobwait(jobs)
end

local M = { setup = setup, update = update }

return M
