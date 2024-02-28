local logging = require("colorbox.commons.logging")
local numbers = require("colorbox.commons.numbers")

local configs = require("colorbox.configs")
local builtin_policy = require("colorbox.policy.builtin")
local policy_util = require("colorbox.policy.util")

local M = {}

--- @param po colorbox.Options?
--- @return boolean
M.is_fixed_interval_policy = function(po)
  return type(po) == "table"
    and type(po.seconds) == "number"
    and po.seconds >= 0
    and type(po.implement) == "string"
    and string.len(po.implement) > 0
end

M.run = function()
  local confs = configs.get()
  local later = confs.policy.seconds > 0 and (confs.policy.seconds * 1000) or numbers.INT32_MAX

  local function impl()
    local f = builtin_policy[confs.policy.implement]
    if vim.is_callable(f) then
      f()
      policy_util.sync_syntax()
      vim.defer_fn(impl, later)
    else
      local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]
      logger:err(
        "invalid 'implement' options in fixed interval policy: %s",
        vim.inspect(confs.policy)
      )
    end
  end
  impl()
end

return M
