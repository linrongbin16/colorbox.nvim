local logging = require("colorbox.commons.logging")
local numbers = require("colorbox.commons.numbers")

local configs = require("colorbox.configs")

local builtin_policy = require("colorbox.policy.builtin")
local fixed_interval_policy = require("colorbox.policy.fixed_interval")
local filetype_policy = require("colorbox.policy.filetype")

local M = {}

M.run = function()
  local confs = configs.get()
  if confs.policy == "shuffle" then
    builtin_policy.shuffle()
  elseif confs.policy == "in_order" then
    builtin_policy.in_order()
  elseif confs.policy == "reverse_order" then
    builtin_policy.reverse_order()
  elseif confs.policy == "single" then
    builtin_policy.single()
  elseif
    confs.timing == "interval" and fixed_interval_policy.is_fixed_interval_policy(confs.policy)
  then
    fixed_interval_policy.run()
  elseif
    confs.timing == "bufferchanged"
    or confs.timing == "filetype" and filetype_policy.is_filetype_policy(confs.policy)
  then
    filetype_policy.run()
  end
end

return M
