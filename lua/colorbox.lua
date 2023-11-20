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
    local modules_dir = vim.loop.fs_opendir(cwd .. "/pack/colorbox/opt") --[[@as luv_dir_t]]
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
                    --     "|colorbox.build| %d:%s",
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
    logger.debug("|colorbox.build| modules:%s", vim.inspect(modules))
    logger.debug("|colorbox.build| modules_path:%s", vim.inspect(modules_path))
    vim.opt.runtimepath:append(cwd)
    vim.opt.runtimepath:append(cwd .. '/pack')
    vim.opt.runtimepath:append(cwd .. '/pack/colorbox')
    vim.opt.runtimepath:append(cwd .. '/pack/colorbox/opt')
    for _, p in ipairs(modules_path) do
        vim.opt.runtimepath:append(p)
    end
    for _, m in ipairs(modules) do
        local ok, err = pcall(vim.cmd, string.format("packadd! %s", m.name))
        logger.ensure(ok, err)
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
