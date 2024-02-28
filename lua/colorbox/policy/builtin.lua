local logging = require("colorbox.commons.logging")
local LogLevels = require("colorbox.commons.logging").LogLevels
local jsons = require("colorbox.commons.jsons")
local uv = require("colorbox.commons.uv")
local numbers = require("colorbox.commons.numbers")
local fileios = require("colorbox.commons.fileios")
local strings = require("colorbox.commons.strings")
local apis = require("colorbox.commons.apis")
local async = require("colorbox.commons.async")

local configs = require("colorbox.configs")

local M = {}

M.shuffle = function()
  if #FilteredColorNamesList > 0 then
    local i = numbers.random(#FilteredColorNamesList) --[[@as integer]]
    local color = _get_next_color_name_by_idx(i)
    logging.get("colorbox"):debug(
      "|_policy_shuffle| color:%s, FilteredColorNamesList:%s (%d), i:%d",
      vim.inspect(color),
      vim.inspect(FilteredColorNamesList),
      vim.inspect(#FilteredColorNamesList),
      vim.inspect(i)
    )
    vim.cmd(string.format([[color %s]], color))
  end
end

local function _policy_in_order()
  if #FilteredColorNamesList > 0 then
    local previous_track = _load_previous_track() --[[@as colorbox.PreviousTrack]]
    local i = previous_track ~= nil and previous_track.color_number or 0
    local color = _get_next_color_name_by_idx(i)
    vim.cmd(string.format([[color %s]], color))
  end
end

local function _policy_reverse_order()
  if #FilteredColorNamesList > 0 then
    local previous_track = _load_previous_track() --[[@as colorbox.PreviousTrack]]
    local i = previous_track ~= nil and previous_track.color_number or (#FilteredColorNamesList + 1)
    local color = _get_prev_color_name_by_idx(i)
    vim.cmd(string.format([[color %s]], color))
  end
end

local function _policy_single()
  if #FilteredColorNamesList > 0 then
    local previous_track = _load_previous_track() --[[@as colorbox.PreviousTrack]]
    local color = previous_track ~= nil and previous_track.color_name
      or _get_next_color_name_by_idx(0)
    if color ~= vim.g.colors_name then
      vim.cmd(string.format([[color %s]], color))
    end
  end
end

return M
