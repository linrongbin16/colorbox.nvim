local logger = require("logger")
local candidates = require("colorswitch.candidates")
local submodules = require("colorswitch.submodules")

local defaults = {
    plugin_path = nil,
}
local config = {}
local loaded_colors = {}

local function setup(option)
    config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), option or {})
    math.randomseed(os.clock() * 100000000000)
    logger.setup({
        log_level = option.debug and "DEBUG" or "INFO",
        name = "colorswitch",
    })
    for color, submodule_paths in pairs(submodules) do
        for _, s in ipairs(submodule_paths) do
            local subpath = config.plugin_path .. "/colowswitch.nvim/" .. s
            logger.debug("submodule runtimepath: %s", subpath)
            vim.opt.runtimepath:append(subpath)
            logger.debug("load submodule rtp %s for color %s", subpath, color)
        end
    end
    logger.debug("setup rtp:%s", vim.inspect(vim.api.nvim_list_runtime_paths()))
end

-- random integer in [0, n)
local function randint(n)
    return math.random(0, n - 1)
end

local function load_color(color, submodule)
    if loaded_colors[color] then
        logger.debug("color %s already loaded on rtp", color)
        return
    end
    for _, s in ipairs(submodule) do
        local submodule_path = config.plugin_path .. "/colowswitch.nvim/" .. s
        logger.debug("submodule runtimepath: %s", submodule_path)
        vim.opt.runtimepath:append(submodule_path)
        logger.debug(
            "load submodule rtp %s for color %s",
            submodule_path,
            color
        )
    end
    loaded_colors[color] = true
    logger.debug("rtp:%s", vim.inspect(vim.api.nvim_list_runtime_paths()))
end

local function switch(option)
    logger.debug("switch with option: %s", vim.inspect(option))
    logger.debug(
        "switch rtp:%s",
        vim.inspect(vim.api.nvim_list_runtime_paths())
    )
    local function impl(color)
        vim.cmd(string.format("colorscheme %s", color))
        if option and option["force"] then
            vim.cmd([[
                diffupdate
                syntax sync fromstart
            ]])
            logger.info(string.format("switched to %s forcibly!", color))
        else
            logger.info(string.format("switched to %s", color))
        end
    end

    if option and option["color"] and string.len(option["color"]) > 0 then
        impl(option["color"])
    else
        local index = randint(#candidates)
        impl(candidates[index])
    end
end

local M = {
    setup = setup,
    switch = switch,
}

return M
