local logging = require("colorbox.commons.logging")
local numbers = require("colorbox.commons.numbers")
local strings = require("colorbox.commons.strings")

local configs = require("colorbox.configs")
local builtin_policy = require("colorbox.policy.builtin")
local util = require("colorbox.util")

local M = {}

--- @param po colorbox.Options?
--- @return boolean
M.is_fixed_interval_policy = function(po)
  return type(po) == "table" and numbers.gt(po.seconds, 0) and strings.not_empty(po.implement)
end

M.run = function()
  local confs = configs.get()
  assert(
    M.is_fixed_interval_policy(confs.policy),
    string.format("invalid policy %s for 'interval' timing!", vim.inspect(confs.policy))
  )
  local later = confs.policy.seconds > 0 and (confs.policy.seconds * 1000) or numbers.INT32_MAX

  local function impl()
    local f = builtin_policy[confs.policy.implement]
    if vim.is_callable(f) then
      f()
      util.sync_syntax()
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
