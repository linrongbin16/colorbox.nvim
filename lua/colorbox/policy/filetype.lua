local types = require("colorbox.types")
local log = require("colorbox.log")
local configs = require("colorbox.configs")
local track = require("colorbox.track")
local loader = require("colorbox.loader")

local M = {}

--- How long the events of one buffer switch have to settle before the load runs.
---
--- `timing.filetype` listens to `BufEnter`, `WinEnter`, `FocusGained` and
--- `TermEnter`, and one real switch fires several of them within a few
--- milliseconds. Waiting lets them collapse into a single load.
local Delay = 20

--- The pending load, and the generation it belongs to. A `vim.defer_fn` callback
--- does not belong to an augroup, so a cancelled one must not run either, even if
--- the timer was already queued.
--- @type uv_timer_t?
local Timer = nil
local Generation = 0

--- Cancel the pending load, if any.
---
--- Safe to call when nothing is pending, and on a handle whose callback is already
--- running: `vim.defer_fn` closes its own handle right before calling it.
M.stop = function()
  Generation = Generation + 1
  local timer = Timer
  Timer = nil
  if timer == nil then
    return
  end
  if not timer:is_closing() then
    timer:stop()
    timer:close()
  end
end

--- @param po colorbox.Options?
--- @return boolean
M.is_filetype_policy = function(po)
  return type(po) == "table"
    and type(po.mapping) == "table"
    and (not types.str_empty(po.empty) or po.empty == nil)
    and (not types.str_empty(po.fallback) or po.fallback == nil)
end

--- The colorscheme the current buffer asks for, or `nil` when the policy has nothing
--- to say about it.
--- @param mapping table<string, string>
--- @param empty string?
--- @param fallback string?
--- @return string?
local function pick_color(mapping, empty, fallback)
  local ft = vim.bo.filetype or ""
  if not types.str_empty(mapping[ft]) then
    return mapping[ft]
  end
  if types.str_empty(ft) and not types.str_empty(empty) then
    return empty
  end
  if not types.str_empty(fallback) then
    return fallback
  end
  return nil
end

M.run = function()
  local policy_config = configs.get().policy
  assert(
    M.is_filetype_policy(policy_config),
    string.format("invalid policy %s for 'filetype' timing!", vim.inspect(policy_config))
  )

  -- Debounce: one buffer switch fires several of the events above, and every one of
  -- them used to schedule its own load.
  M.stop()
  local generation = Generation
  Timer = vim.defer_fn(function()
    if generation ~= Generation then
      return
    end
    Timer = nil
    local confs = configs.get()
    -- The policy can be replaced between the event and this callback.
    if not M.is_filetype_policy(confs.policy) then
      return
    end
    local color_name = pick_color(confs.policy.mapping, confs.policy.empty, confs.policy.fallback)
    if types.str_empty(color_name) then
      return
    end
    -- Already applied: two buffers of the same file type, or a window switch inside
    -- one buffer, would otherwise reload the colorscheme it is already showing.
    if color_name == vim.g.colors_name then
      log.debug(string.format("|filetype| color:%s is already applied", vim.inspect(color_name)))
      return
    end
    loader.load(color_name)
    track.sync_syntax()
  end, Delay)
end

return M
