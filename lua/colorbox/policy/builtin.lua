local logging = require("colorbox.commons.logging")
local numbers = require("colorbox.commons.numbers")

local colors = require("colorbox.colors")
local util = require("colorbox.util")

local M = {}

M.shuffle = function()
  local ColorNamesList = colors.colornames()
  if #ColorNamesList > 0 then
    local i = numbers.random(#ColorNamesList) --[[@as integer]]
    local color = util.get_next_color_name_by_idx(i)
    logging.get("colorbox"):debug(
      "|_policy_shuffle| color:%s, ColorNamesList:%s (%d), i:%d",
      vim.inspect(color),
      vim.inspect(ColorNamesList),
      vim.inspect(#ColorNamesList),
      vim.inspect(i)
    )
    vim.cmd(string.format([[color %s]], color))
  end
end

M.in_order = function()
  local ColorNamesList = colors.colornames()
  if #ColorNamesList > 0 then
    local previous_track = util.previous_track() --[[@as colorbox.PreviousTrack]]
    local i = previous_track ~= nil and previous_track.color_number or 0
    local color = util.get_next_color_name_by_idx(i)
    vim.cmd(string.format([[color %s]], color))
  end
end

M.reverse_order = function()
  local ColorNamesList = colors.colornames()
  if #ColorNamesList > 0 then
    local previous_track = util.previous_track() --[[@as colorbox.PreviousTrack]]
    local i = previous_track ~= nil and previous_track.color_number or (#ColorNamesList + 1)
    local color = util.get_prev_color_name_by_idx(i)
    vim.cmd(string.format([[color %s]], color))
  end
end

M.single = function()
  local ColorNamesList = colors.colornames()
  if #ColorNamesList > 0 then
    local previous_track = util.previous_track() --[[@as colorbox.PreviousTrack]]
    local color = previous_track ~= nil and previous_track.color_name
      or util.get_next_color_name_by_idx(0)
    if color ~= vim.g.colors_name then
      vim.cmd(string.format([[color %s]], color))
    end
  end
end

return M
