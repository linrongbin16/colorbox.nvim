local strings = require("colorbox.commons.strings")

local configs = require("colorbox.configs")
local track = require("colorbox.track")
local loader = require("colorbox.loader")

local M = {}

--- @param po colorbox.Options?
--- @return boolean
M.is_filetype_policy = function(po)
  return type(po) == "table"
    and type(po.mapping) == "table"
    and (strings.not_empty(po.empty) or po.empty == nil)
    and (strings.not_empty(po.fallback) or po.fallback == nil)
end

M.run = function()
  local policy_config = configs.get().policy
  assert(
    M.is_filetype_policy(policy_config),
    string.format("invalid policy %s for 'filetype' timing!", vim.inspect(policy_config))
  )

  vim.defer_fn(function()
    local confs = configs.get()
    local ft = vim.bo.filetype or ""

    if strings.not_empty(confs.policy.mapping[ft]) then
      loader.load(confs.policy.mapping[ft])
      track.sync_syntax()
    elseif strings.empty(ft) and strings.not_empty(confs.policy.empty) then
      loader.load(confs.policy.empty)
      track.sync_syntax()
    elseif strings.not_empty(confs.policy.fallback) then
      loader.load(confs.policy.fallback)
      track.sync_syntax()
    end
  end, 10)
end

return M
