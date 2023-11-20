local logger = require("colorbox.logger")
local LogLevels = require("colorbox.logger").LogLevels
local json = require("colorbox.json")

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

--- @alias colorbox.Options table<any, any>
--- @type colorbox.Options
local Defaults = {
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

-- plugin name => spec
--- @type table<string, colorbox.ColorSpec>
local ColorSpecs = {}

-- color name => spec
--- @type table<string, colorbox.ColorSpec>
local ColorNameSpecs = {}

local function _init()
    local cwd = vim.fn["colorbox#base_dir"]()
    local packopt = string.format("%s/pack/colorbox/opt", cwd)
    logger.debug(
        "|colorbox.init| cwd:%s, pack:%s",
        vim.inspect(cwd),
        vim.inspect(packopt)
    )
    vim.opt.packpath:append(cwd)
    -- vim.opt.packpath:append(cwd .. "/pack")
    -- vim.opt.packpath:append(cwd .. "/pack/colorbox")
    -- vim.opt.packpath:append(cwd .. "/pack/colorbox/opt")
    -- vim.cmd([[packadd catppuccin-nvim]])

    local pack_dir = vim.loop.fs_opendir(packopt) --[[@as luv_dir_t]]
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
                        string.format("%s/%s", packopt, pack_ttmp.name)
                    )
                    ColorSpecs[spec.name] = spec
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
                                    ColorNameSpecs[color] = spec
                                end
                            end
                        else
                            break
                        end
                    end
                    logger.debug("|colorbox.init| spec:%s", vim.inspect(spec))
                    -- vim.cmd(string.format([[packadd %s]], spec.name))
                end
            end
        else
            break
        end
    end

    vim.api.nvim_create_autocmd("ColorSchemePre", {
        callback = function(event)
            logger.debug("|colorbox.init| event:%s", vim.inspect(event))
            if type(event) ~= "table" or ColorNameSpecs[event.match] == nil then
                return
            end
            local spec = ColorNameSpecs[event.match]
            vim.cmd(string.format([[packadd %s]], spec.name))
        end,
    })
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
end

--- @return colorbox.ColorSpec[]
local function list()
    local results = {}
    for _, spec in pairs(ColorSpecs) do
        table.insert(results, spec)
    end
    return results
end

local M = { setup = setup, list = list }

return M
