local types = require("colorbox.types")
local log = require("colorbox.log")

local configs = require("colorbox.configs")
local builtin_policy = require("colorbox.policy.builtin")
local track = require("colorbox.track")

local M = {}

--- The handle of the pending tick, and the generation it belongs to. A chain that
--- was stopped (or replaced by a newer `run`) must not schedule anything again, so
--- every callback compares the generation it was created with against the current
--- one before doing anything.
--- @type uv_timer_t?
local Timer = nil
local Generation = 0

--- @param po colorbox.Options?
--- @return boolean
M.is_fixed_interval_policy = function(po)
  return type(po) == "table"
    and types.greater_than(po.seconds, 0)
    and not types.str_empty(po.implement)
end

--- Stop the running chain, if any.
---
--- A `vim.defer_fn` chain is not tied to an autocmd group, so `setup()` re-running
--- (a `config` function evaluated twice, `:Lazy reload`) would otherwise leave the
--- previous chain ticking next to the new one. It also lets the tests and users stop
--- the player without restarting Neovim.
M.stop = function()
  Generation = Generation + 1
  local timer = Timer
  Timer = nil
  if timer == nil then
    return
  end
  -- `vim.defer_fn` closes its own handle right before calling the callback, so the
  -- handle of a tick that already fired is closed and would raise here.
  if not timer:is_closing() then
    timer:stop()
    timer:close()
  end
end

--- The failures already reported, so a colorscheme that fails on every tick is
--- reported once instead of once per `policy.seconds` seconds.
--- @type table<string, boolean>
local Reported = {}

--- @param implement_policy string
--- @param err any
local function report_failure(implement_policy, err)
  local msg = string.format(
    "failed to run policy %s, error:%s",
    vim.inspect(implement_policy),
    vim.inspect(err)
  )
  if Reported[msg] then
    log.debug(string.format("|fixed_interval| %s", msg))
    return
  end
  Reported[msg] = true
  log.err(string.format("|fixed_interval| %s", msg))
end

M.run = function()
  local confs = configs.get()
  log.ensure(
    M.is_fixed_interval_policy(confs.policy),
    string.format("invalid policy %s for 'interval' timing!", vim.inspect(confs.policy))
  )
  -- `is_fixed_interval_policy` above already rejected a non-positive `seconds`.
  local later = confs.policy.seconds * 1000
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

  -- One chain per session: a second `run` replaces the previous one.
  M.stop()
  local generation = Generation

  --- @type fun()
  local impl

  local function schedule()
    Timer = vim.defer_fn(impl, later)
  end

  impl = function()
    if generation ~= Generation then
      return
    end
    Timer = nil
    -- A colorscheme can fail on its own (`:color x` runs arbitrary Vimscript, e.g.
    -- the stale `ctermul=` of an old theme). That must not kill the player: report
    -- it and keep ticking, the next color of the list may load just fine.
    local ok, err = pcall(function()
      fn()
      track.sync_syntax()
    end)
    if not ok then
      report_failure(implement_policy, err)
    end
    if generation ~= Generation then
      return
    end
    schedule()
  end

  -- The first tick runs synchronously, from `colorbox.setup`. It must not raise
  -- either, or a single broken colorscheme takes the whole `setup()` down.
  impl()
end

return M
