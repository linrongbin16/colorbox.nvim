local logger = require("colorbox.logger")

--- @class colorbox.ColorSpec
--- @field plugin string
--- @field plugin_url string
--- @field module_path string
--- @field colors string[]
local ColorSpec = {}

--- @type colorbox.ColorSpec[]
local ColorSpecList = {}

--- @param opts colorbox.Options
local function setup(opts)
    logger.debug(
        "|colorbox.colors.setup| cwd:%s",
        vim.inspect(vim.fn["colorbox#base_dir"]())
    )
end

local M = {
    setup = setup,
}

return M
