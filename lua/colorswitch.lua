local defaults = {
    candidates = require("colorswitch.candidates"),
}

local config = {}

local function setup(option)
    config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), option or {})
    math.randomseed(os.clock() * 100000000000)
end

-- random integer in [0, n)
local function randint(n)
    return math.random(0, n - 1)
end

local function switch(option)
    local function impl(color)
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
        local index = randint(#config.candidates)
        impl(#config.candidates[index])
    end
end

local M = {
    setup = setup,
    switch = switch,
}

return M
