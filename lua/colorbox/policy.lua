local log = require("colorbox.log")

local configs = require("colorbox.configs")

local builtin_policy = require("colorbox.policy.builtin")
local fixed_interval_policy = require("colorbox.policy.fixed_interval")
local filetype_policy = require("colorbox.policy.filetype")

local M = {}

--- @alias colorbox.PolicyKind "builtin"|"fixed_interval"|"filetype"

--- The kind of `po`, nil when it is not a policy at all.
---
--- A table that fits more than one kind is read as a fixed interval policy, whose
--- shape is the strictest: it needs both `seconds` and `implement`.
--- @param po any
--- @return colorbox.PolicyKind?
M.kind = function(po)
  if builtin_policy.is_builtin_policy(po) then
    return "builtin"
  end
  if fixed_interval_policy.is_fixed_interval_policy(po) then
    return "fixed_interval"
  end
  if filetype_policy.is_filetype_policy(po) then
    return "filetype"
  end
  return nil
end

--- The policy kind each timing drives. These are the only supported pairs, the
--- README "Timing" and "Policy" sections document them.
--- @type table<string, colorbox.PolicyKind>
local TimingPolicyKinds = {
  startup = "builtin",
  interval = "fixed_interval",
  filetype = "filetype",
}

--- The documented timings, in README order, for messages.
--- @type string[]
local Timings = { "startup", "interval", "filetype" }

--- @type table<string, string>
local KindDescriptions = {
  builtin = string.format("a builtin policy (%s)", table.concat(builtin_policy.names(), ", ")),
  fixed_interval = 'a fixed interval policy table ("seconds" and "implement")',
  filetype = 'a filetype policy table ("mapping")',
}

--- Check the `timing`/`policy` pair.
---
--- Every timing drives exactly one kind of policy. The other combinations used to
--- either run the wrong policy, silently do nothing, or fail with a message naming
--- the wrong timing, so they are rejected here with a message that names both
--- options.
--- @param confs colorbox.Options?
--- @return boolean ok
--- @return string? msg
M.validate = function(confs)
  confs = confs or configs.get()
  local timing, po = confs.timing, confs.policy

  local expects = TimingPolicyKinds[timing]
  if expects == nil then
    if timing == "bufferchanged" then
      -- Removed long ago, but a configuration copied from an old README still
      -- mentions it, so it gets a message that says what to use instead.
      return false,
        string.format(
          "invalid 'timing' option: %s, it was renamed to 'filetype' in colorbox 1.13.9.",
          vim.inspect(timing)
        )
    end
    return false,
      string.format(
        "invalid 'timing' option: %s, expects one of %s.",
        vim.inspect(timing),
        table.concat(Timings, ", ")
      )
  end

  local kind = M.kind(po)
  if kind == nil then
    return false,
      string.format(
        "invalid 'policy' option: %s, 'timing' %s expects %s.",
        vim.inspect(po),
        vim.inspect(timing),
        KindDescriptions[expects]
      )
  end

  if kind ~= expects then
    return false,
      string.format(
        "'policy' %s is %s, but 'timing' %s drives %s, this pair is not supported.",
        vim.inspect(po),
        KindDescriptions[kind],
        vim.inspect(timing),
        KindDescriptions[expects]
      )
  end

  return true
end

--- The messages already logged. `run` is called from autocmds, so repeating the
--- notification on every buffer enter would drown it.
--- @type table<string, boolean>
local Reported = {}

--- Report an invalid `timing`/`policy` pair once.
--- @param msg string
M.report = function(msg)
  if Reported[msg] then
    return
  end
  Reported[msg] = true
  log.err(msg)
end

M.run = function()
  local confs = configs.get()
  local ok, msg = M.validate(confs)
  if not ok then
    M.report(msg --[[@as string]])
    return
  end

  local kind = M.kind(confs.policy)
  if kind == "builtin" then
    builtin_policy[confs.policy]()
  elseif kind == "fixed_interval" then
    fixed_interval_policy.run()
  elseif kind == "filetype" then
    filetype_policy.run()
  end
end

return M
