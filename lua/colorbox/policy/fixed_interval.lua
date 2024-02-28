local logging = require("colorbox.commons.logging")
local LogLevels = require("colorbox.commons.logging").LogLevels
local jsons = require("colorbox.commons.jsons")
local uv = require("colorbox.commons.uv")
local numbers = require("colorbox.commons.numbers")
local fileios = require("colorbox.commons.fileios")
local strings = require("colorbox.commons.strings")
local apis = require("colorbox.commons.apis")
local async = require("colorbox.commons.async")

local configs = require("colorbox.configs")
local builtin_policies = require("colorbox.policy.builtin")
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
    local f = builtin_policies[confs.policy.implement]
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
