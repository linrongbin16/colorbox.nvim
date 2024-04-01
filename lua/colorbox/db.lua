local str = require("colorbox.commons.str")

--- @class colorbox.ColorSpec
--- @field handle string "folke/tokyonight.nvim"
--- @field url string "https://github.com/folke/tokyonight.nvim"
--- @field github_stars integer 4300
--- @field last_git_commit string "2023-10-25T18:20:36"
--- @field priority integer 100/0
--- @field source string "https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme"
--- @field git_path string "folke-tokyonight.nvim"
--- @field git_branch string? nil|"neovim"
--- @field color_names string[] ["tokyonight","tokyonight-day","tokyonight-moon","tokyonight-night","tokyonight-storm"]
local ColorSpec = {}

-- plugin pack path: "pack/colorbox/start/folke-tokyonight.nvim"
--- @param spec colorbox.ColorSpec
--- @return string
local function get_pack_path(spec)
  return string.format("pack/colorbox/start/%s", spec.git_path)
end

--- plugin pack full path: "Users/linrongbin16/github/linrongbin16/colorbox.nvim/pack/colorbox/start/folke-tokyonight.nvim"
--- @param spec colorbox.ColorSpec
--- @return string
local function get_full_pack_path(spec)
  local cwd = vim.fn["colorbox#base_dir"]()
  return string.format("%s/pack/colorbox/start/%s", cwd, spec.git_path)
end

--- @return table<string, colorbox.ColorSpec>
local function get_handle_to_color_specs_map()
  return require("colorbox.meta.specs")
end

--- @return table<string, colorbox.ColorSpec>
local function get_git_path_to_color_specs_map()
  return require("colorbox.meta.specs_by_gitpath")
end

--- @return table<string, colorbox.ColorSpec>
local function get_color_name_to_color_specs_map()
  return require("colorbox.meta.specs_by_colorname")
end

--- @return string[]
local function get_color_names_list()
  return require("colorbox.meta.colornames")
end

local M = {
  get_handle_to_color_specs_map = get_handle_to_color_specs_map,
  get_git_path_to_color_specs_map = get_git_path_to_color_specs_map,
  get_color_name_to_color_specs_map = get_color_name_to_color_specs_map,
  get_color_names_list = get_color_names_list,
  get_pack_path = get_pack_path,
  get_full_pack_path = get_full_pack_path,
}

return M
