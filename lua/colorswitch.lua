local defaults = {
    candidates = require("colorswitch.candidates"),
    submodules = require("colorswitch.submodules"),
    plugin_path = nil,
}
local config = {}
local loaded_rtp = {}

local function exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

--- Check if a directory exists in this path
local function isdir(path)
    -- "/" works on both Unix and Windows
    return exists(path .. "/")
end

local function append_rtp(submodule)
    local submodule_path = config.plugin_path
        .. "/colowswitch.nvim/"
        .. submodule
        if loaded_rtp[submodule_path] then
            return
        end
end

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
