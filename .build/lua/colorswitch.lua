local logger = require("logger")
local candidates = require("colorswitch.candidates")
local submodules = require("colorswitch.submodules")

local defaults = {
    include = nil,
    exclude = nil,
    no_variants = true,
    no_dark = false,
    no_light = true,
}
local config = {}

local function setup(option)
    config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), option or {})
    math.randomseed(os.clock() * 100000000000)
    logger.setup({
        level = option.debug and "DEBUG" or "INFO",
        name = "colorswitch",
    })

    -- no variants(primary only)
    if config.no_variants then
        local new_candidates = {}
        for submod, colors in pairs(submodules) do
            local primary_color = nil
            for _, color in ipairs(colors) do
                if
                    (submod == "EdenEast/nightfox.nvim" and color == "nightfox")
                    or (
                        submod == "projekt0n/github-nvim-theme"
                        and color == "github_dark"
                    )
                then
                    primary_color = color
                elseif
                    primary_color == nil
                    or string.len(color) < string.len(primary_color)
                then
                    primary_color = color
                end
            end
            table.insert(new_candidates, primary_color)
        end
        candidates = new_candidates
        logger.debug("no variants candidates:%s", vim.inspect(candidates))
    end
    -- no dark or no light
    if config.no_dark or config.no_light then
        local new_candidates = {}
        for _, can in ipairs(candidates) do
            local lower_can = string.lower(can)
            local is_light = not lower_can:match("day")
                and not lower_can:match("light")
                and not lower_can:match("dawn")
            if config.no_dark and is_light then
                table.insert(new_candidates, can)
            end
            if config.no_light and not is_light then
                table.insert(new_candidates, can)
            end
        end
        candidates = new_candidates
        logger.debug("no dark/light candidates:%s", vim.inspect(candidates))
    end
    -- include colors
    if type(config.include) == "table" and #config.include > 0 then
        for _, inc in ipairs(config.include) do
            logger.debug("include color:%s", vim.inspect(inc))
            assert(type(inc) == "string" and string.len(inc) > 0)
            table.insert(candidates, inc)
        end
        logger.debug("include candidates:%s", vim.inspect(candidates))
    end
    -- exclude colors
    if type(config.exclude) == "table" then
        local new_candidates = {}
        for _, can in ipairs(candidates) do
            assert(type(can) == "string" and string.len(can) > 0)
            if config.exclude[can] then
                logger.debug("exclude color:%s", vim.inspect(can))
            else
                table.insert(new_candidates, can)
            end
        end
        candidates = new_candidates
        logger.debug("exclude candidates:%s", vim.inspect(candidates))
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
        impl(candidates[index])
    end
end

local M = {
    setup = setup,
    switch = switch,
}

return M
