local types = require("colorbox.types")
local log = require("colorbox.log")

local uv = vim.uv
local configs = require("colorbox.configs")
local track = require("colorbox.track")
local db = require("colorbox.db")

local M = {}

-- Re-entrancy guard.
--
-- `vim.cmd("color ...")` fires `ColorSchemePre`, and the handler in `colorbox.lua`
-- calls `M.load()` again. That nested call has nothing left to do: the outer call
-- already ran `packadd` and the per-handle setup, and it is the outer call that
-- saves the track. Letting the nested one through means every `load()` runs the
-- setup twice and writes the cache twice.
local Loading = false

--- Whether `M.load` is currently running. When it is, the colorscheme being applied
--- was requested by colorbox itself, so the events it fires are not user actions.
--- @return boolean
M.loading = function()
  return Loading
end

--- @param color_name string?
--- @param execute boolean?
local function load(color_name, execute)
  -- by default 'execute' is true
  if type(execute) ~= "boolean" then
    execute = true
  end

  local specs_by_color_name = db.get_specs_by_color_name()

  if types.str_empty(color_name) then
    return
  end
  local spec = specs_by_color_name[color_name]
  if types.tbl_empty(spec) then
    return
  end
  local full_pack_path = db.get_full_pack_path(spec)
  local pack_exist = uv.fs_stat(full_pack_path) ~= nil
  log.debug(
    string.format(
      "|load| full_pack_path:%s, pack_exist:%s",
      vim.inspect(full_pack_path),
      vim.inspect(pack_exist)
    )
  )
  if not pack_exist then
    return
  end

  local home_dir = vim.fn["colorbox#base_dir"]()
  local autoload_path = vim.fs.joinpath(full_pack_path, "autoload")
  vim.opt.runtimepath:append(full_pack_path)
  vim.opt.packpath:append(home_dir)
  log.debug(
    string.format("|load| autoload_path:%s, spec:%s", vim.inspect(autoload_path), vim.inspect(spec))
  )
  vim.cmd(string.format([[packadd %s]], spec.install_path))

  local confs = configs.get()
  if type(confs.setup) == "table" and vim.is_callable(confs.setup[spec.handle]) then
    local ok, setup_err = pcall(confs.setup[spec.handle], home_dir, spec)
    log.ensure(
      ok,
      string.format(
        "failed to setup colorscheme:%s, error:%s",
        vim.inspect(spec.handle),
        vim.inspect(setup_err)
      )
    )
  end
  if confs.background == "dark" or confs.background == "light" then
    vim.opt.background = confs.background
  end

  if execute then
    log.debug(string.format("|load| execute color:%s", vim.inspect(color_name)))
    vim.cmd(string.format("color %s", color_name))
    track.save_track(color_name)
  end
end

--- Load a colorscheme and, unless `execute` is false, apply it.
---
--- Re-entrant calls are ignored: while a load is running, the colorscheme events it
--- fires are its own side effects, not user actions. The track is saved by the
--- top-level call only, so `post_hook` runs once per `load()`.
--- @param color_name string?
--- @param execute boolean?
M.load = function(color_name, execute)
  if Loading then
    log.debug(string.format("|load| skip re-entrant load for color:%s", vim.inspect(color_name)))
    return
  end

  Loading = true
  -- load() raises on a failed per-handle setup; reset the guard before the error
  -- escapes, otherwise the next load would be skipped for the rest of the session.
  local ok, err = pcall(load, color_name, execute)
  Loading = false
  if not ok then
    error(err, 0)
  end
end

return M
