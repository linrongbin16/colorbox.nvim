local strings = require("colorbox.commons.strings")

local configs = require("colorbox.configs")
local policy_util = require("colorbox.policy.util")

local M = {}

--- @param po colorbox.Options?
--- @return boolean
M.is_filetype_policy = function(po)
  return type(po) == "table"
    and type(po.mapping) == "table"
    and ((type(po.empty) == "string" and string.len(po.empty) > 0) or po.empty == nil)
    and ((type(po.fallback) == "string" and string.len(po.fallback) > 0) or po.fallback == nil)
end

M.run = function()
  vim.defer_fn(function()
    local confs = configs.get()
    local ft = vim.bo.filetype or ""

    if confs.policy.mapping[ft] then
      local ok, err =
        pcall(vim.cmd --[[@as function]], string.format([[color %s]], confs.policy.mapping[ft]))
      assert(ok, err)
      policy_util.sync_syntax()
    elseif strings.empty(ft) and strings.not_empty(confs.policy.empty) then
      local ok, err =
        pcall(vim.cmd --[[@as function]], string.format([[color %s]], confs.policy.empty))
      assert(ok, err)
      policy_util.sync_syntax()
    elseif strings.not_empty(confs.policy.fallback) then
      local ok, err =
        pcall(vim.cmd --[[@as function]], string.format([[color %s]], confs.policy.fallback))
      assert(ok, err)
      policy_util.sync_syntax()
    end
  end, 10)
end

return M
