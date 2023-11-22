-- see: `lua print(vim.inspect(vim.log.levels))`
local LogLevels = {
    TRACE = 0,
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    OFF = 5,
}

local LogLevelNames = {
    [0] = "TRACE",
    [1] = "DEBUG",
    [2] = "INFO",
    [3] = "WARN",
    [4] = "ERROR",
    [5] = "OFF",
}

local LogHighlights = {
    [0] = "Comment",
    [1] = "Comment",
    [2] = "None",
    [3] = "WarningMsg",
    [4] = "ErrorMsg",
    [5] = "ErrorMsg",
}

local PathSeparator = (vim.fn.has("win32") > 0 or vim.fn.has("win64") > 0)
        and "\\"
    or "/"

local Defaults = {
    name = "colorbox",
    level = LogLevels.DEBUG,
    console_log = true,
    file_log = false,
    file_log_name = nil,
    file_log_dir = vim.fn.stdpath("data"),
    _file_log_path = nil,
    --- @type "a"|"w"
    file_log_mode = "a",
}

local Configs = {}

--- @param opts table<any, any>
local function setup(opts)
    Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})
    if type(Configs.level) == "string" then
        Configs.level = LogLevels[Configs.level]
    end
    if Configs.file_log_name and string.len(Configs.file_log_name) > 0 then
        -- For Windows: $env:USERPROFILE\AppData\Local\nvim-data\fzfx.log
        -- For *NIX: ~/.local/share/nvim/fzfx.log
        Configs._file_log_path = string.format(
            "%s%s%s",
            Configs.file_log_dir,
            PathSeparator,
            Configs.file_log_name
        )
    end
    assert(type(Configs.name) == "string")
    assert(string.len(Configs.name) > 0)
    assert(type(Configs.level) == "number")
    assert(LogLevelNames[Configs.level] ~= nil)
    if Configs.file_log then
        assert(type(Configs._file_log_path) == "string")
        assert(string.len(Configs._file_log_path) > 0)
        assert(type(Configs.file_log_name) == "string")
        assert(string.len(Configs.file_log_name) > 0)
        assert(type(Configs.file_log_dir) == "string")
        assert(string.len(Configs.file_log_dir) > 0)
        assert(vim.fn.isdirectory(Configs.file_log_dir) > 0)
        assert(Configs.file_log_mode == "a" or Configs.file_log_mode == "w")
        if Configs.file_log_mode == "w" then
            Configs._file_handle = io.open(Configs._file_log_path, "w")
        end
    end
end

--- @param level integer
--- @param fmt string
--- @param ... any?
local function echo(level, fmt, ...)
    if type(level) == "string" then
        level = LogLevels[level]
    end

    local msg = string.format(fmt, ...)
    local msg_lines = vim.split(msg, "\n", { plain = true })
    local msg_chunks = {}
    local prefix = ""
    if level == LogLevels.ERROR then
        prefix = "error! "
    elseif level == LogLevels.WARN then
        prefix = "warning! "
    end
    for _, line in ipairs(msg_lines) do
        table.insert(msg_chunks, {
            string.format("[%s] %s%s", Configs.name, prefix, line),
            LogHighlights[level],
        })
    end
    vim.api.nvim_echo(msg_chunks, false, {})
end

--- @param level integer
--- @param msg string
local function log(level, msg)
    if level < Configs.level then
        return
    end

    local msg_lines = vim.split(msg, "\n", { plain = true })
    if Configs.console_log and level >= LogLevels.INFO then
        echo(level, msg)
    end
    if Configs.file_log then
        local fp = nil
        if Configs.file_log_mode == "a" then
            fp = io.open(Configs._file_log_path, "a")
        else
            fp = Configs._file_handle
        end
        if fp then
            for _, line in ipairs(msg_lines) do
                fp:write(
                    string.format(
                        "%s [%s]: %s\n",
                        os.date("%Y-%m-%d %H:%M:%S"),
                        LogLevelNames[level],
                        line
                    )
                )
            end
        end
        if Configs.file_log_mode == "a" then
            if fp then
                fp:close()
            end
        end
    end
end

--- @param fmt string
--- @param ... any
local function debug(fmt, ...)
    log(LogLevels.DEBUG, string.format(fmt, ...))
end

--- @param fmt string
--- @param ... any
local function info(fmt, ...)
    log(LogLevels.INFO, string.format(fmt, ...))
end

--- @param fmt string
--- @param ... any
local function warn(fmt, ...)
    log(LogLevels.WARN, string.format(fmt, ...))
end

--- @param fmt string
--- @param ... any
local function err(fmt, ...)
    log(LogLevels.ERROR, string.format(fmt, ...))
end

--- @param fmt string
--- @param ... any
local function throw(fmt, ...)
    err(fmt, ...)
    error(string.format(fmt, ...))
end

--- @param cond boolean
--- @param fmt string
--- @param ... any
local function ensure(cond, fmt, ...)
    if not cond then
        throw(fmt, ...)
    end
end

local M = {
    setup = setup,
    LogLevels = LogLevels,
    LogLevelNames = LogLevelNames,
    echo = echo,
    throw = throw,
    ensure = ensure,
    err = err,
    warn = warn,
    info = info,
    debug = debug,
}

return M
