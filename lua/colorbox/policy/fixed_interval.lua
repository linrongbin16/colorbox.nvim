local logging = require("colorbox.commons.logging")
local numbers = require("colorbox.commons.numbers")
local strings = require("colorbox.commons.strings")
local tables = require("colorbox.commons.tables")

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
  local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]
  logger:ensure(
    M.is_fixed_interval_policy(confs.policy),
    string.format("invalid policy %s for 'interval' timing!", vim.inspect(confs.policy))
  )
  local later = confs.policy.seconds > 0 and (confs.policy.seconds * 1000) or numbers.INT32_MAX
  local implement_policy = tables.tbl_get(confs, "policy", "implement")
  logger:ensure(
    not strings.empty(implement_policy),
    string.format("invalid policy %s for 'interval' timing!", vim.inspect(confs.policy))
  )
  local fn = builtin_policy[implement_policy]
  logger:ensure(
    vim.is_callable(fn),
    string.format("invalid policy %s for 'interval' timing!", vim.inspect(confs.policy))
  )

  local function impl()
    fn()
    util.sync_syntax()
    vim.defer_fn(impl, later)
  end
  impl()
end

return M
