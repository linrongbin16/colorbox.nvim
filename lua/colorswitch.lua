local logger = require("logger")
local candidates = require("colorswitch.candidates")

local defaults = {
    plugin_path = nil,
}
local config = {}
local loaded_rtp = {}

local function setup(option)
    config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), option or {})
    math.randomseed(os.clock() * 100000000000)
    logger.setup({
        log_level = option.debug and "DEBUG" or "INFO",
        name = "colorswitch",
    })
end

-- random integer in [0, n)
local function randint(n)
    return math.random(0, n - 1)
end

local function append_rtp(submodule)
    local submodule_path = config.plugin_path
        .. "/colowswitch.nvim/"
        .. submodule
    if loaded_rtp[submodule_path] then
        logger.debug("submodule %s already loaded on rtp", submodule_path)
        return
    end
    vim.opt.runtimepath:append(submodule_path)
    loaded_rtp[submodule_path] = true
    logger.debug("load submodule %s on rtp", submodule_path)
end

local function switch(option)
    local function impl(color)
        local submodule = candidates[color]
        append_rtp(submodule)
        vim.cmd(string.format("colorscheme %s", color))
        if option and option["force"] then
            vim.cmd([[
                diffupdate
                syntax sync fromstart
            ]])
        end
    end

    if option and option["color"] and string.len(option["color"]) > 0 then
        impl(option["color"])
    else
        local index = randint(#candidates)
        impl(#candidates[index])
    end
end

local M = {
    setup = setup,
    switch = switch,
}

return M
