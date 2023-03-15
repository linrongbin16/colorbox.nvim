local logger = require("logger")

local defaults = {
    include = nil,
    exclude = nil,
    no_variants = true,
    no_dark = false,
    no_light = true,
    -- DEBUG/INFO/WARN/ERROR
    log_level = "INFO",
}
local config = {}
local candidates = {}

local function setup(option)
    config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), option or {})
    math.randomseed(os.clock() * 100000000000)
    logger.setup({
        level = config.log_level,
        name = "colorswitch",
    })
    logger.debug("config:%s", vim.inspect(config))

    -- no variants, no dark, no light
    candidates = require("colorswitch.candidates")
    local filter1 = {}
    for _, cand in ipairs(candidates) do
        if
            (config.no_variants and not cand.primary)
            or (config.no_dark and cand.dark)
            or (config.no_light and cand.light)
        then
            logger.debug("filtered candidate:%s", vim.inspect(cand))
        else
            table.insert(filter1, cand)
        end
    end
    candidates = filter1
    logger.debug("filter1 candidates:%s", vim.inspect(candidates))

    -- include colors
    if type(config.include) == "table" and #config.include > 0 then
        for _, inc in ipairs(config.include) do
            logger.debug("include color:%s", vim.inspect(inc))
            assert(type(inc) == "string" and string.len(inc) > 0)
            table.insert(candidates, { inc })
        end
        logger.debug("included candidates:%s", vim.inspect(candidates))
    end
    -- exclude colors
    if type(config.exclude) == "table" then
        local filter2 = {}
        for _, cand in ipairs(candidates) do
            if config.exclude[cand[1]] then
                logger.debug("exclude color:%s", vim.inspect(cand))
            else
                table.insert(filter2, cand)
            end
        end
        candidates = filter2
        logger.debug("excluded candidates:%s", vim.inspect(candidates))
    end
    logger.debug("final candidates:%s", vim.inspect(candidates))
    if #candidates <= 0 then
        logger.warn(
            "Warning! No candidate colorschemes, please check your config."
        )
    end
end

-- random integer in [0, n)
local function randint(n)
    return math.random(0, n - 1)
end

-- option: color:string, force:boolean
local function switch(option)
    logger.debug("switch with option: %s", vim.inspect(option))
    local function impl(color)
        vim.cmd(string.format("colorscheme %s", color))
        if option and option["force"] then
            vim.cmd([[
                diffupdate
                syntax sync fromstart
            ]])
            logger.info(
                string.format("Switch to colorscheme %s forcibly!", color)
            )
        else
            logger.info(string.format("Switch to colorscheme %s", color))
        end
    end

    if option and option["color"] and string.len(option["color"]) > 0 then
        impl(option["color"])
    else
        local index = randint(#candidates)
        impl(candidates[index][1])
    end
end

local M = {
    setup = setup,
    switch = switch,
}

return M
