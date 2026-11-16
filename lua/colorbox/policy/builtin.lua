local log = require("colorbox.log")

local runtime = require("colorbox.runtime")
local track = require("colorbox.track")
local loader = require("colorbox.loader")

local uv = vim.uv

local M = {}

--- The builtin policy names, in the order they are documented in the README.
--- @type colorbox.BuiltinPolicyConfig[]
local Names = { "shuffle", "in_order", "reverse_order", "single" }

--- @return colorbox.BuiltinPolicyConfig[]
M.names = function()
  return Names
end

--- A builtin policy is configured by its name, everything else is a policy table.
--- @param po any
--- @return boolean
M.is_builtin_policy = function(po)
  if type(po) ~= "string" then
    return false
  end
  for _, name in ipairs(Names) do
    if po == name then
      return true
    end
  end
  return false
end

M.shuffle = function()
  local color_names = runtime.color_names()
  if #color_names > 0 then
    local ts = uv.clock_gettime("realtime") --[[@as {sec:integer,nsec:integer} ]]
    local i = math.floor(math.fmod(ts.nsec, #color_names)) + 1 --[[@as integer]]
    local color = track.get_next_color_name_by_idx(i)
    log.debug(
      string.format(
        "|_policy_shuffle| color:%s, color_names:%s (%d), i:%d",
        vim.inspect(color),
        vim.inspect(color_names),
        vim.inspect(#color_names),
        vim.inspect(i)
      )
    )

    loader.load(color)
  end
end

M.in_order = function()
  local color_names = runtime.color_names()
  if #color_names > 0 then
    local previous_track = track.previous_track() --[[@as colorbox.PreviousTrack]]
    local i = previous_track ~= nil and previous_track.color_number or 0
    local color = track.get_next_color_name_by_idx(i)
    log.debug(
      string.format(
        "|in_order| color:%s, i:%d, color_names(%d):%s",
        vim.inspect(color),
        vim.inspect(i),
        vim.inspect(#color_names),
        vim.inspect(color_names)
      )
    )

    loader.load(color)
  end
end

M.reverse_order = function()
  local color_names = runtime.color_names()
  if #color_names > 0 then
    local previous_track = track.previous_track() --[[@as colorbox.PreviousTrack]]
    local i = previous_track ~= nil and previous_track.color_number or (#color_names + 1)
    local color = track.get_prev_color_name_by_idx(i)

    loader.load(color)
  end
end

M.single = function()
  local color_names = runtime.color_names()
  if #color_names > 0 then
    local previous_track = track.previous_track() --[[@as colorbox.PreviousTrack]]
    local color = previous_track ~= nil and previous_track.color_name
      or track.get_next_color_name_by_idx(0)
    if color ~= vim.g.colors_name then
      loader.load(color)
    end
  end
end

return M
