local str = require("colorbox.commons.str")
local num = require("colorbox.commons.num")
local json = require("colorbox.commons.json")
local fileio = require("colorbox.commons.fileio")

local configs = require("colorbox.configs")
local runtime = require("colorbox.runtime")

local M = {}

M.sync_syntax = function()
  vim.schedule(function()
    vim.cmd([[syntax sync fromstart]])
  end)
end

--- @alias colorbox.PreviousTrack {color_name:string,color_number:integer}
--- @param color_name string
M.save_track = function(color_name)
  if str.blank(color_name) then
    return
  end

  vim.schedule(function()
    local confs = configs.get()

    local ColorNamesIndex = runtime.colornames_index()
    local color_number = ColorNamesIndex[color_name] or 1

    local content = json.encode({
      color_name = color_name,
      color_number = color_number,
    }) --[[@as string]]

    fileio.asyncwritefile(confs.previous_track_cache, content, function() end)
  end)
end

--- @return colorbox.PreviousTrack?
M.previous_track = function()
  local confs = configs.get()
  local content = fileio.readfile(confs.previous_track_cache)
  if str.empty(content) then
    return nil
  end
  return json.decode(content) --[[@as colorbox.PreviousTrack?]]
end

--- @param idx integer
--- @return string, integer
M.get_next_color_name_by_idx = function(idx)
  assert(type(idx) == "number")
  idx = idx + 1
  local ColorNamesList = runtime.colornames()
  local n = #ColorNamesList
  if idx > n then
    idx = 1
  end
  idx = num.bound(idx, 1, n)
  return ColorNamesList[idx], idx
end

--- @param idx integer
--- @return string, integer
M.get_prev_color_name_by_idx = function(idx)
  assert(type(idx) == "number")
  idx = idx - 1
  local ColorNamesList = runtime.colornames()
  local n = #ColorNamesList
  if idx < 1 then
    idx = n
  end
  idx = num.bound(idx, 1, n)
  return ColorNamesList[idx], idx
end

return M
