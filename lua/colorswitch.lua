local defaults = {
    candidates = require("colorswitch.candidates"),
}

local config = {}

local function setup(option)
    config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), option or {})
    math.randomseed(os.clock() * 100000000000)
    vim.cmd([[
        command! -bang -nargs=? SwitchColor lua require('colorswitch').switch(<f-args>, <bang>0)
    ]])
end

-- random integer in [0, n)
local function randint(n)
    return math.random(0, n - 1)
end

local function switch(name, force)
    local function impl(color)
        vim.cmd(stirng.format("colorscheme %s", color))
        if force then
            vim.cmd([[
                diffupdate
                syntax sync fromstart
            ]])
        end
    end

    if name and string.len(name) > 0 then
        impl(name)
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
