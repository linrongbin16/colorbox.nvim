local str = require("colorbox.commons.str")
local tbl = require("colorbox.commons.tbl")
local uv = require("colorbox.commons.uv")
local logging = require("colorbox.commons.logging")

local configs = require("colorbox.configs")

local M = {}

--- @param colorname string?
--- @param run_command boolean?
M.load = function(colorname, run_command)
  local ColorNameToColorSpecsMap = require("colorbox.db").get_color_name_to_color_specs_map()

  if str.empty(colorname) then
    return
  end
  local spec = ColorNameToColorSpecsMap[colorname]
  if tbl.tbl_empty(spec) then
    return
  end
  local pack_exist = uv.fs_stat(spec.full_pack_path) ~= nil
  if not pack_exist then
    return
  end

  local autoload_path = string.format("%s/autoload", spec.full_pack_path)
  vim.opt.runtimepath:append(autoload_path)
  vim.cmd(string.format([[packadd %s]], spec.git_path))

  local confs = configs.get()
  local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]
  if type(confs.setup) == "table" and vim.is_callable(confs.setup[spec.handle]) then
    local home_dir = vim.fn["colorbox#base_dir"]()
    local ok, setup_err = pcall(confs.setup[spec.handle], home_dir, spec)
    logger:ensure(
      ok,
      "failed to setup colorscheme:%s, error:%s",
      vim.inspect(spec.handle),
      vim.inspect(setup_err)
    )
  end
  if confs.background == "dark" or confs.background == "light" then
    vim.opt.background = confs.background
  end

  run_command = type(run_command) == "boolean" and run_command or true
  if run_command then
    vim.cmd(string.format("colorscheme %s", colorname))
  end
end

return M
