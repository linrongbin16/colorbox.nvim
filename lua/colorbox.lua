local logger = require("colorbox.logger")
local LogLevels = require("colorbox.logger").LogLevels
local json = require("colorbox.json")

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

--- @class ColorSpec
--- @field name string
--- @field path string
--- @field colors string[]
local ColorSpec = {}

--- @param name string
--- @param path string
--- @param colors string[]|nil
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

local ColorSpecs = {}
local ColorSpecsMap = {}

local function build_index()
    local cwd = vim.fn["colorbox#base_dir"]()
    local packopt = string.format("%s/pack/colorbox/opt", cwd)
    logger.debug(
        "|colorbox.build| cwd:%s, pack:%s",
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
        local tmp = pack_dir:readdir()
        if type(tmp) == "table" and #tmp > 0 then
            for _, ttmp in ipairs(tmp) do
                if
                    type(ttmp) == "table"
                    and type(ttmp.name) == "string"
                    and ttmp.type == "directory"
                then
                    local spec = ColorSpec:new(
                        ttmp.name,
                        string.format("%s/%s", packopt, ttmp.name)
                    )
                    table.insert(ColorSpecs, spec)
                    ColorSpecsMap[spec.name] = spec
                end
            end
        else
            break
        end
    end
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

    build_index()
end

local M = { setup = setup }

return M
