local str = require("colorbox.commons.str")
local tbl = require("colorbox.commons.tbl")
local uv = require("colorbox.commons.uv")
local logging = require("colorbox.commons.logging")

local configs = require("colorbox.configs")
local track = require("colorbox.track")
local db = require("colorbox.db")

local M = {}

--- @param colorname string?
--- @param execute boolean?
M.load = function(colorname, execute)
  local logger = logging.get("colorbox")
  local ColorNameToColorSpecsMap = require("colorbox.db").get_color_name_to_color_specs_map()

  if str.empty(colorname) then
    return
  end
  local spec = ColorNameToColorSpecsMap[colorname]
  if tbl.tbl_empty(spec) then
    return
  end
  local full_pack_path = db.get_full_pack_path(spec)
  local pack_exist = uv.fs_stat(full_pack_path) ~= nil
  logger:debug(
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
  vim.opt.runtimepath:append(autoload_path)
  vim.cmd(string.format([[packadd %s]], spec.git_path))

  local confs = configs.get()
  if type(confs.setup) == "table" and vim.is_callable(confs.setup[spec.handle]) then
    local home_dir = vim.fn["colorbox#base_dir"]()
    local ok, setup_err = pcall(confs.setup[spec.handle], home_dir, spec)
    logger:ensure(
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

  if type(execute) ~= "boolean" then
    execute = true
  end
  if execute then
    vim.cmd(string.format("colorscheme %s", colorname))
    track.save_track(colorname)
  end
end

return M
