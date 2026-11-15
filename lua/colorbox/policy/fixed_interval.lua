local types = require("colorbox.types")
local log = require("colorbox.log")

local configs = require("colorbox.configs")
local builtin_policy = require("colorbox.policy.builtin")
local track = require("colorbox.track")

local M = {}

--- @param po colorbox.Options?
--- @return boolean
M.is_fixed_interval_policy = function(po)
  return type(po) == "table"
    and types.greater_than(po.seconds, 0)
    and types.str_not_empty(po.implement)
end

M.run = function()
  local confs = configs.get()
  log.ensure(
    M.is_fixed_interval_policy(confs.policy),
    string.format("invalid policy %s for 'interval' timing!", vim.inspect(confs.policy))
  )
  local later = confs.policy.seconds > 0 and (confs.policy.seconds * 1000) or types.INT32_MAX
  local implement_policy = vim.tbl_get(confs, "policy", "implement")
  log.ensure(
    not types.str_empty(implement_policy),
    string.format("invalid policy %s for 'interval' timing!", vim.inspect(confs.policy))
  )
  local fn = builtin_policy[implement_policy]
  log.ensure(
    vim.is_callable(fn),
    string.format("invalid policy %s for 'interval' timing!", vim.inspect(confs.policy))
  )

  local function impl()
    fn()
    track.sync_syntax()
    vim.defer_fn(impl, later)
  end
  impl()
end

return M
