local num = require("colorbox.commons.num")
local log = require("colorbox.commons.log")

local runtime = require("colorbox.runtime")
local track = require("colorbox.track")
local loader = require("colorbox.loader")

local M = {}

M.shuffle = function()
  local color_names = runtime.color_names()
  if #color_names > 0 then
    local i = num.random(#color_names) --[[@as integer]]
    local color = track.get_next_color_name_by_idx(i)
    log.debug(
      string.format(
        "|_policy_shuffle| color:%s, ColorNamesList:%s (%d), i:%d",
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
        "|in_order| color:%s, i:%d, ColorNamesList(%d):%s",
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
