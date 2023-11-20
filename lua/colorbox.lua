--- @alias colorbox.Options table<any, any>
--- @type colorbox.Options
local Defaults = {}

--- @type colorbox.Options
local Configs = {}

--- @param opts colorbox.Options?
local function setup(opts)
    Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})
end

local M = { setup = setup }

return M
