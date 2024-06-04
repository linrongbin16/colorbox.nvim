local num = require("colorbox.commons.num")
local logging = require("colorbox.commons.logging")

local runtime = require("colorbox.runtime")
local track = require("colorbox.track")
local loader = require("colorbox.loader")

local M = {}

M.shuffle = function()
  local ColorNamesList = runtime.colornames()
  if #ColorNamesList > 0 then
    local i = num.random(#ColorNamesList) --[[@as integer]]
    local color = track.get_next_color_name_by_idx(i)
    logging.get("colorbox"):debug(
      string.format(
        "|_policy_shuffle| color:%s, ColorNamesList:%s (%d), i:%d",
        vim.inspect(color),
        vim.inspect(ColorNamesList),
        vim.inspect(#ColorNamesList),
        vim.inspect(i)
      )
    )

    loader.load(color)
  end
end

M.in_order = function()
  local ColorNamesList = runtime.colornames()
  if #ColorNamesList > 0 then
    local logger = logging.get("colorbox")
    local previous_track = track.previous_track() --[[@as colorbox.PreviousTrack]]
    local i = previous_track ~= nil and previous_track.color_number or 0
    local color = track.get_next_color_name_by_idx(i)
    logger:debug(
      string.format(
        "|in_order| color:%s, i:%d, ColorNamesList(%d):%s",
        vim.inspect(color),
        vim.inspect(i),
        vim.inspect(#ColorNamesList),
        vim.inspect(ColorNamesList)
      )
    )

    loader.load(color)
  end
end

M.reverse_order = function()
  local ColorNamesList = runtime.colornames()
  if #ColorNamesList > 0 then
    local previous_track = track.previous_track() --[[@as colorbox.PreviousTrack]]
    local i = previous_track ~= nil and previous_track.color_number or (#ColorNamesList + 1)
    local color = track.get_prev_color_name_by_idx(i)

    loader.load(color)
  end
end

M.single = function()
  local ColorNamesList = runtime.colornames()
  if #ColorNamesList > 0 then
    local previous_track = track.previous_track() --[[@as colorbox.PreviousTrack]]
    local color = previous_track ~= nil and previous_track.color_name
      or track.get_next_color_name_by_idx(0)
    if color ~= vim.g.colors_name then
      loader.load(color)
    end
  end
end

return M
