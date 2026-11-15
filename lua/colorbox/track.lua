local types = require("colorbox.types")
local log = require("colorbox.log")

local configs = require("colorbox.configs")
local runtime = require("colorbox.runtime")
local db = require("colorbox.db")

local M = {}

M.sync_syntax = function()
  vim.schedule(function()
    vim.cmd([[syntax sync fromstart]])
  end)
end

--- @alias colorbox.PreviousTrack {color_name:string,color_number:integer}
--- @param color_name string
M.save_track = function(color_name)
  log.debug(string.format("|save_track| color_name:%s", vim.inspect(color_name)))
  if types.str_blank(color_name) then
    return
  end

  vim.schedule(function()
    local confs = configs.get()

    local color_indexes = runtime.color_indexes()
    local color_number = color_indexes[color_name] or 1

    local content = vim.json.encode({
      color_name = color_name,
      color_number = color_number,
    }) --[[@as string]]

    local ok, err = types.write_file_async(confs.previous_track_cache, content, {
      on_complete = function()
        log.debug(
          string.format(
            "|save_track| finished save track for color_name:%s, color_number:%s",
            vim.inspect(color_name),
            vim.inspect(color_number)
          )
        )
        vim.schedule(function()
          if vim.is_callable(confs.post_hook) then
            local specs_by_color_name = db.get_specs_by_color_name()
            local spec = specs_by_color_name[color_name]
            confs.post_hook(color_name, spec)
          end
        end)
      end,
    })
    if not ok then
      log.warn(
        string.format(
          "|save_track| failed to save track for color_name:%s, error:%s",
          vim.inspect(color_name),
          vim.inspect(err)
        )
      )
    end
  end)
end

--- @return colorbox.PreviousTrack?
M.previous_track = function()
  local confs = configs.get()
  local content, err = types.read_file(confs.previous_track_cache)
  if err ~= nil then
    log.debug(
      string.format("|previous_track| failed to read track cache, error:%s", vim.inspect(err))
    )
    return nil
  end
  if types.str_empty(content) then
    return nil
  end
  return vim.json.decode(content --[[@as string]]) --[[@as colorbox.PreviousTrack?]]
end

--- @param idx integer
--- @return string, integer
M.get_next_color_name_by_idx = function(idx)
  assert(type(idx) == "number")
  idx = idx + 1
  local color_names = runtime.color_names()
  local n = #color_names
  if idx > n then
    idx = 1
  end
  idx = types.clamp(idx, 1, n)
  return color_names[idx], idx
end

--- @param idx integer
--- @return string, integer
M.get_prev_color_name_by_idx = function(idx)
  assert(type(idx) == "number")
  idx = idx - 1
  local color_names = runtime.color_names()
  local n = #color_names
  if idx < 1 then
    idx = n
  end
  idx = types.clamp(idx, 1, n)
  return color_names[idx], idx
end

return M
