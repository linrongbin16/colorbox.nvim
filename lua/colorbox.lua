local logger = require("colorbox.logger")
local LogLevels = require("colorbox.logger").LogLevels

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

local function build()
    local cwd = vim.fn["colorbox#base_dir"]()
    logger.debug("|colorbox.build| cwd:%s", vim.inspect(cwd))
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

    build()
end

local M = { setup = setup }

return M
