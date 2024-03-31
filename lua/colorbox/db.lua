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

-- handle => spec
--- @type table<string, colorbox.ColorSpec>
local HandleToColorSpecsMap = nil

-- git path => spec
--- @type table<string, colorbox.ColorSpec>
local GitPathToColorSpecsMap = nil

-- color name => spec
--- @type table<string, colorbox.ColorSpec>
local ColorNameToColorSpecsMap = nil

-- color names list
--- @type string[]
local ColorNamesList = nil

do
  if type(HandleToColorSpecsMap) ~= "table" then
    HandleToColorSpecsMap = require("colorbox.meta.specs")
  end
  if type(ColorNameToColorSpecsMap) ~= "table" then
    ColorNameToColorSpecsMap = {}
    for _, spec in pairs(HandleToColorSpecsMap) do
      for _, color_name in ipairs(spec.color_names) do
        ColorNameToColorSpecsMap[color_name] = spec
      end
    end
  end
  if type(GitPathToColorSpecsMap) ~= "table" then
    GitPathToColorSpecsMap = {}
    for _, spec in pairs(HandleToColorSpecsMap) do
      GitPathToColorSpecsMap[spec.git_path] = spec
    end
  end
  if type(ColorNamesList) ~= "table" then
    ColorNamesList = require('colorbox.meta.colornames')
  end
end

--- @return table<string, colorbox.ColorSpec>
local function get_handle_to_color_specs_map()
  return HandleToColorSpecsMap
end

--- @return table<string, colorbox.ColorSpec>
local function get_git_path_to_color_specs_map()
  return GitPathToColorSpecsMap
end

--- @return table<string, colorbox.ColorSpec>
local function get_color_name_to_color_specs_map()
  return ColorNameToColorSpecsMap
end

--- @return string[]
local function get_color_names_list()
  return ColorNamesList
end

local M = {
  get_handle_to_color_specs_map = get_handle_to_color_specs_map,
  get_git_path_to_color_specs_map = get_git_path_to_color_specs_map,
  get_color_name_to_color_specs_map = get_color_name_to_color_specs_map,
  get_color_names_list = get_color_names_list,
}

return M
