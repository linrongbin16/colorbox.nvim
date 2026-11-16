local types = require("colorbox.types")
local log = require("colorbox.log")

local configs = require("colorbox.configs")
local runtime = require("colorbox.runtime")
local db = require("colorbox.db")

local M = {}

--- @alias colorbox.PreviousTrack {color_name:string,color_number:integer}

-- Track cache.

--- The cache file lives in `cache_dir`, which `colorbox.setup` fills in.
--- @return string
local function cache_file()
  return configs.get().previous_track_cache
end

--- The 1-based index of a color in the current color list.
--- Returns nil when colorbox does not manage that colorscheme, e.g. the user
--- runs `:colorscheme default`.
--- @param color_name string
--- @return integer?
local function managed_index(color_name)
  return runtime.color_indexes()[color_name]
end

--- Build the track record for a managed color, nil for an unmanaged one.
--- @param color_name string
--- @return colorbox.PreviousTrack?
local function to_track(color_name)
  local color_number = managed_index(color_name)
  if color_number == nil then
    return nil
  end
  return { color_name = color_name, color_number = color_number }
end

--- Validate a decoded track against the current color list, and repair its
--- `color_number` when the two disagree. Returns nil for a track that cannot be
--- trusted, so callers fall back to their own default instead of using a color
--- that is not managed by colorbox.
--- @param track colorbox.PreviousTrack?
--- @return colorbox.PreviousTrack?
local function normalize_track(track)
  if type(track) ~= "table" then
    return nil
  end
  local color_name = track.color_name
  if type(color_name) ~= "string" or types.str_blank(color_name) then
    return nil
  end

  local color_number = managed_index(color_name)
  if color_number == nil then
    log.debug(
      string.format(
        "|previous_track| color_name:%s is not managed by colorbox, ignore it",
        vim.inspect(color_name)
      )
    )
    return nil
  end

  if track.color_number ~= color_number then
    log.debug(
      string.format(
        "|previous_track| repairing color_number for color_name:%s, %s => %s",
        vim.inspect(color_name),
        vim.inspect(track.color_number),
        vim.inspect(color_number)
      )
    )
  end

  return { color_name = color_name, color_number = color_number }
end

--- @param color_name string
local function run_post_hook(color_name)
  local post_hook = configs.get().post_hook
  if not vim.is_callable(post_hook) then
    return
  end
  vim.schedule(function()
    post_hook(color_name, db.get_specs_by_color_name()[color_name])
  end)
end

--- @param track colorbox.PreviousTrack
local function write_track(track)
  local content = vim.json.encode(track) --[[@as string]]
  local ok, err = types.write_file_async(cache_file(), content, {
    on_complete = function()
      log.debug(
        string.format(
          "|save_track| finished save track for color_name:%s, color_number:%s",
          vim.inspect(track.color_name),
          vim.inspect(track.color_number)
        )
      )
      run_post_hook(track.color_name)
    end,
  })
  if not ok then
    log.warn(
      string.format(
        "|save_track| failed to save track for color_name:%s, error:%s",
        vim.inspect(track.color_name),
        vim.inspect(err)
      )
    )
  end
end

--- @param color_name string
M.save_track = function(color_name)
  log.debug(string.format("|save_track| color_name:%s", vim.inspect(color_name)))
  if types.str_blank(color_name) then
    return
  end

  vim.schedule(function()
    local track = to_track(color_name)
    if track == nil then
      log.debug(
        string.format(
          "|save_track| color_name:%s is not managed by colorbox, skip it",
          vim.inspect(color_name)
        )
      )
      return
    end
    write_track(track)
  end)
end

--- @return colorbox.PreviousTrack?
M.previous_track = function()
  local filename = cache_file()
  local content, err = types.read_file(filename)
  if err ~= nil then
    log.debug(
      string.format("|previous_track| failed to read track cache, error:%s", vim.inspect(err))
    )
    return nil
  end
  if types.str_empty(content) then
    return nil
  end

  -- A cache file written by an older version, or by a version that was killed while
  -- writing, can hold a truncated record. That is not worth an error: drop the file and
  -- let the caller start from its own default.
  local ok, track = pcall(vim.json.decode, content --[[@as string]])
  if not ok then
    log.warn(
      string.format(
        "|previous_track| failed to decode track cache, remove it, content:%s, error:%s",
        vim.inspect(content),
        vim.inspect(track)
      )
    )
    local _, unlink_err = vim.uv.fs_unlink(filename)
    if unlink_err ~= nil then
      log.debug(
        string.format(
          "|previous_track| failed to remove track cache, error:%s",
          vim.inspect(unlink_err)
        )
      )
    end
    return nil
  end
  return normalize_track(track --[[@as colorbox.PreviousTrack?]])
end

-- Navigation.

--- Step through the current color list. The list wraps around in the direction
--- of travel; a value out of range on the other side is clamped to the bound.
--- @param idx integer
--- @param delta integer 1 to go forward, -1 to go backward
--- @return string?, integer color name and its 1-based index
local function step_color_name(idx, delta)
  local color_names = runtime.color_names()
  local n = #color_names
  if n == 0 then
    return nil, 0
  end

  idx = idx + delta
  if delta > 0 then
    if idx > n then
      idx = 1
    end
  elseif idx < 1 then
    idx = n
  end
  idx = types.clamp(idx, 1, n)
  return color_names[idx], idx
end

--- @param idx integer
--- @return string?, integer
M.get_next_color_name_by_idx = function(idx)
  assert(type(idx) == "number")
  return step_color_name(idx, 1)
end

--- @param idx integer
--- @return string?, integer
M.get_prev_color_name_by_idx = function(idx)
  assert(type(idx) == "number")
  return step_color_name(idx, -1)
end

-- Syntax.

--- Colorschemes that bring their own `syntax` need a resync after being loaded,
--- otherwise highlighting lags behind the theme.
M.sync_syntax = function()
  vim.schedule(function()
    vim.cmd([[syntax sync fromstart]])
  end)
end

return M
