local logger = require("colorbox.logger")
local LogLevels = require("colorbox.logger").LogLevels
local json = require("colorbox.json")

--- @param l any[]
--- @param f fun(v:any):number
--- @return number
local function minimal_integer(l, f)
    local result = 2 ^ 31 - 1
    for _, i in ipairs(l) do
        result = math.min(result, f(i))
    end
    return result
end

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

--- @enum

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

-- specs
--- @type colorbox.ColorSpec[]
local ColorSpecs = {}

-- plugin name => spec
--- @type table<string, colorbox.ColorSpec>
local ColorSpecsMap = {}

-- plugin url => spec
local ColorSpecUrlsMap = {}

-- color names
--- @type string[]
local ColorNames = {}

-- color name => spec
--- @type table<string, colorbox.ColorSpec>
local ColorNamesMap = {}

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

--- @param color string
--- @param spec colorbox.ColorSpec
--- @return boolean
local function _should_filter(color, spec)
    if Configs.filter == nil then
        return false
    end
    if Configs.filter == "primary" then
        local unique = #spec.colors <= 1
        local variants = spec.colors
        local shortest = string.len(color)
            == minimal_integer(variants, string.len)
        local url_splits =
            vim.split(spec.url, "/", { plain = true, trimempty = true })
        local matched = url_splits[1]:lower() == color:lower()
            or url_splits[2]:lower() == color:lower()
        logger.debug(
            "|colorbox._should_filter| color:%s, spec:%s, unique:%s, shortest: %s, matched:%s",
            vim.inspect(color),
            vim.inspect(spec),
            vim.inspect(unique),
            vim.inspect(shortest),
            vim.inspect(matched)
        )
        return not unique and not shortest and not matched
    elseif type(Configs.filter) == "function" then
        return Configs.filter(color)
    end
end

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

    local repos = _load_repo_meta_urls_map(cwd)
    for url, repo in pairs(repos) do
        local obj_path = string.format("%s/%s", packstart, repo.obj_name)
        if
            vim.fn.isdirectory(obj_path) > 0
            and vim.fn.isdirectory(obj_path .. "/.git") > 0
        then
            local spec = ColorSpec:new(
                url,
                repo.obj_name,
                string.format("%s/%s", packstart, repo.obj_name),
                {},
                repo.stars,
                repo.last_update,
                repo.priority,
                repo.source
            )
            table.insert(ColorSpecs, spec)
            ColorSpecsMap[spec.name] = spec
            ColorSpecUrlsMap[url] = spec
            local color_dir, err = vim.loop.fs_opendir(spec.path .. "/colors") --[[@as luv_dir_t]]
            if not color_dir then
                logger.err(
                    "failed to scan %s directory: %s",
                    vim.inspect(spec.path),
                    vim.inspect(err)
                )
            end
            local color_candidates = {}
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
                                    or string_endswith(color_file, ".lua")
                            )
                            local color = color_file:sub(1, #color_file - 4)
                            table.insert(spec.colors, color)
                            ColorNamesMap[color] = spec
                            table.insert(color_candidates, color)
                        end
                    end
                else
                    break
                end
            end
            for _, c in ipairs(color_candidates) do
                if not _should_filter(c, spec) then
                    table.insert(ColorNames, c)
                end
            end
        end
    end
    logger.debug("|colorbox._init| ColorNames:%s", vim.inspect(ColorNames))
end

local function _policy_shuffle()
    if #ColorNames > 0 then
        local r = math.floor(math.fmod(randint(), #ColorNames))
        local color = ColorNames[r + 1]
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
            if type(event) ~= "table" or ColorNamesMap[event.match] == nil then
                return
            end
            local spec = ColorNamesMap[event.match]
            vim.cmd(string.format([[packadd %s]], spec.name))
            if
                type(Configs.setup) == "table"
                and type(Configs.setup[spec.url]) == "function"
            then
                Configs.setup[spec.url]()
            end
        end,
    })

    _timing()
end

local function update()
    logger.setup({
        name = "colorbox",
        level = LogLevels.INFO,
        console_log = true,
        file_log = false,
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

    local repos = _load_repo_meta_urls_map(cwd)
    local jobs = {}
    for url, repo in pairs(repos) do
        local github_url = string.format("https://github.com/%s", url)
        local install_path =
            string.format("pack/colorbox/start/%s", url:gsub("/", "%-"))
        local full_install_path = string.format("%s/%s", cwd, install_path)
        logger.debug("install_path:%s", vim.inspect(install_path))
        logger.debug("full_install_path:%s", vim.inspect(full_install_path))

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
            vim.fn.isdirectory(full_install_path) > 0
            and vim.fn.isdirectory(full_install_path .. "/.git") > 0
        then
            local cmd = string.format("cd %s && git pull", full_install_path)
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
                github_url,
                install_path
            )
            logger.debug("install command:%s", vim.inspect(cmd))
            local jobid = vim.fn.jobstart(cmd, {
                stdout_buffered = true,
                stderr_buffered = true,
                on_stdout = _on_output,
                on_stderr = _on_output,
            })
            logger.debug("installing %s", vim.inspect(url))
            table.insert(jobs, jobid)
        end
    end
    vim.fn.jobwait(jobs)
end

local M = { setup = setup, update = update }

return M
