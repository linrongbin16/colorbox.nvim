local logger = require("logger")
local candidates = require("colorswitch.candidates")

local defaults = {
    include = nil,
    exclude = nil,
    primary = true,
}
local config = {}

local function setup(option)
    config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), option or {})
    math.randomseed(os.clock() * 100000000000)
    logger.setup({
        level = option.debug and "DEBUG" or "INFO",
        name = "colorswitch",
    })

    -- include colors
    if type(config.include) == "table" and #config.include > 0 then
        for _, inc in ipairs(config.include) do
            logger.debug("include color:%s", vim.inspect(inc))
            assert(type(inc) == "string" and string.len(inc) > 0)
            table.insert(candidates, inc)
        end
    end
    -- exclude colors
    local new_candidates = {}
    if type(config.exclude) == "table" then
        for _, can in ipairs(candidates) do
            assert(type(can) == "string" and string.len(can) > 0)
            if config.exclude[can] then
                logger.debug("exclude color:%s", vim.inspect(can))
            else
                table.insert(new_candidates, can)
            end
        end
    end
    candidates = new_candidates
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
                string.format("switched to colorscheme %s forcibly!", color)
            )
        else
            logger.info(string.format("switched to colorscheme %s", color))
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
