local candidates = require("colorswitch.candidates")

local defaults = {
    candidates = candidates,
}

local config = {}

local function setup(option)
    config = vim.deepmerge(defaults, option or {})
end

local function switch(name)
end

local M = {
    setup = setup,
}

return M
