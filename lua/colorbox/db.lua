--- @class colorbox.ColorSpec
--- @field handle string "folke/tokyonight.nvim"
--- @field color_name string "tokyonight"
--- @field plugin_name string "tokyonight"
--- @field url string "https://github.com/folke/tokyonight.nvim"
--- @field install_path string "folke-tokyonight.nvim"
--- @field git_branch string? nil|"neovim"
local ColorSpec = {}

-- plugin pack path: "pack/colorbox/start/folke-tokyonight.nvim"
--- @param spec colorbox.ColorSpec
--- @return string
local function get_pack_path(spec)
  return string.format("pack/colorbox/start/%s", spec.install_path)
end

--- plugin pack full path: "Users/linrongbin16/github/linrongbin16/colorbox.nvim/pack/colorbox/start/folke-tokyonight.nvim"
--- @param spec colorbox.ColorSpec
--- @return string
local function get_full_pack_path(spec)
  local cwd = vim.fn["colorbox#base_dir"]()
  return string.format("%s/pack/colorbox/start/%s", cwd, spec.install_path)
end

--- @return table<string, colorbox.ColorSpec>
local function get_specs_by_handle()
  return require("colorbox.meta.specs")
end

--- @return table<string, colorbox.ColorSpec>
local function get_specs_by_install_path()
  return require("colorbox.meta.specs_by_install_path")
end

--- @return table<string, colorbox.ColorSpec>
local function get_specs_by_color_name()
  return require("colorbox.meta.specs_by_colorname")
end

--- @return string[]
local function get_color_names()
  return require("colorbox.meta.colornames")
end

local M = {
  get_specs_by_handle = get_specs_by_handle,
  get_specs_by_install_path = get_specs_by_install_path,
  get_specs_by_color_name = get_specs_by_color_name,
  get_color_names = get_color_names,
  get_pack_path = get_pack_path,
  get_full_pack_path = get_full_pack_path,
}

return M
