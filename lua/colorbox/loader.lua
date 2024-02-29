local logging = require("colorbox.commons.logging")
local strings = require("colorbox.commons.strings")
local tables = require("colorbox.commons.tables")

local configs = require("colorbox.configs")

local M = {}

--- @param colorname string?
M.load = function(colorname)
  local ColorNameToColorSpecsMap = require("colorbox.db").get_color_name_to_color_specs_map()

  if strings.empty(colorname) then
    return
  end
  local spec = ColorNameToColorSpecsMap[colorname]
  if tables.tbl_empty(spec) then
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

  vim.cmd(string.format("colorscheme %s", colorname))
end

return M
