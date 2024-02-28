local jsons = require("colorbox.commons.jsons")
local numbers = require("colorbox.commons.numbers")
local fileios = require("colorbox.commons.fileios")
local strings = require("colorbox.commons.strings")

local configs = require("colorbox.configs")
local colors = require("colorbox.colors")

local M = {}

M.sync_syntax = function()
  vim.schedule(function()
    vim.cmd([[syntax sync fromstart]])
  end)
end

--- @alias colorbox.PreviousTrack {color_name:string,color_number:integer}
--- @param color_name string
M.save_track = function(color_name)
  if strings.blank(color_name) then
    return
  end

  vim.schedule(function()
    local confs = configs.get()

    local ColorNamesIndex = colors.colornames_index()
    local color_number = ColorNamesIndex[color_name] or 1

    local content = jsons.encode({
      color_name = color_name,
      color_number = color_number,
    }) --[[@as string]]

    fileios.asyncwritefile(confs.previous_track_cache, content, function() end)
  end)
end

--- @return colorbox.PreviousTrack?
M.previous_track = function()
  local confs = configs.get()
  local content = fileios.readfile(confs.previous_track_cache)
  if strings.empty(content) then
    return nil
  end
  return jsons.decode(content) --[[@as colorbox.PreviousTrack?]]
end

--- @param idx integer
--- @return string
M.get_next_color_name_by_idx = function(idx)
  assert(type(idx) == "number")
  idx = idx + 1
  local ColorNamesList = colors.colornames()
  local n = #ColorNamesList
  if idx > n then
    idx = 1
  end
  return ColorNamesList[numbers.bound(idx, 1, n)]
end

--- @param idx integer
--- @return string
M.get_prev_color_name_by_idx = function(idx)
  assert(type(idx) == "number")
  idx = idx - 1
  local ColorNamesList = colors.colornames()
  local n = #ColorNamesList
  if idx < 1 then
    idx = n
  end
  return ColorNamesList[numbers.bound(idx, 1, n)]
end

return M
