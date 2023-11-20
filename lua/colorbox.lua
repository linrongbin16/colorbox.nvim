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
    logger.debug("|colorbox.scan_modules| cwd:%s", vim.inspect(cwd))
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
                    -- logger.debug(
                    --     "|colorbox.scan_modules| %d:%s",
                    --     n + 1,
                    --     vim.inspect(m)
                    -- )
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
    -- logger.debug("|colorbox.scan_modules| modules:%s", vim.inspect(modules))
    logger.debug(
        "|colorbox.scan_modules| modules_path:%s",
        vim.inspect(modules_path)
    )
    vim.opt.runtimepath:append(modules_dir)
    for _, p in ipairs(modules_path) do
        vim.opt.runtimepath:append(p)
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

    build()
end

local M = { setup = setup }

return M
