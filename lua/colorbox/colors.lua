local logger = require("colorbox.logger")

--- @class colorbox.ColorSpec
--- @field plugin string
--- @field plugin_url string
--- @field module_path string
--- @field colors string[]
local ColorSpec = {}

--- @type colorbox.ColorSpec[]
local ColorSpecList = {}

--- @param opts colorbox.Options?
local function setup(opts)
    local cwd = vim.fn["colorbox#base_dir"]()
    logger.debug("|colorbox.colors.setup| cwd:%s", vim.inspect(cwd))
    local modules_dir = vim.loop.fs_opendir(cwd .. "/modules") --[[@as luv_dir_t]]
    local modules = {}
    local modules_path = {}
    local n = 0
    while true do
        local m = modules_dir:readdir()
        if type(m) == "table" and #m > 0 then
            for _, mm in ipairs(m) do
                if
                    type(mm) == "table"
                    and type(mm.name) == "string"
                    and string.len(mm.name) > 0
                    and mm.type == "directory"
                then
                    logger.debug(
                        "|colorbox.colors.setup| %d:%s",
                        n + 1,
                        vim.inspect(m)
                    )
                    table.insert(modules, mm)
                    table.insert(
                        modules_path,
                        string.format("%s/modules/%s", cwd, mm.name)
                    )
                    n = n + 1
                end
            end
        else
            break
        end
    end
    logger.debug("|colorbox.colors.setup| modules:%s", vim.inspect(modules))
    logger.debug(
        "|colorbox.colors.setup| modules_path:%s",
        vim.inspect(modules_path)
    )
    for _, p in ipairs(modules_path) do
        vim.opt.runtimepath:append(p)
    end
end

local M = {
    setup = setup,
}

return M
