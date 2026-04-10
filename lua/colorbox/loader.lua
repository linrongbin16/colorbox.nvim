local str = require("colorbox.commons.str")
local tbl = require("colorbox.commons.tbl")
local log = require("colorbox.commons.log")

local uv = vim.uv or vim.loop
local configs = require("colorbox.configs")
local track = require("colorbox.track")
local db = require("colorbox.db")

local M = {}

--- @param color_name string?
--- @param execute boolean?
M.load = function(color_name, execute)
  -- by default 'execute' is true
  if type(execute) ~= "boolean" then
    execute = true
  end

  local specs_by_color_name = require("colorbox.db").get_specs_by_color_name()

  if str.empty(color_name) then
    return
  end
  local spec = specs_by_color_name[color_name]
  if tbl.tbl_empty(spec) then
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

  local autoload_path = string.format("%s/autoload", full_pack_path)
  vim.opt.runtimepath:append(full_pack_path)
  log.debug(
    string.format("|load| autoload_path:%s, spec:%s", vim.inspect(autoload_path), vim.inspect(spec))
  )
  vim.cmd(string.format([[packadd %s]], spec.install_path))

  local confs = configs.get()
  if type(confs.setup) == "table" and vim.is_callable(confs.setup[spec.handle]) then
    local home_dir = vim.fn["colorbox#base_dir"]()
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
    vim.cmd(string.format("color %s", color_name))
    track.save_track(color_name)
  end
end

return M
