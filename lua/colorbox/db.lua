local json = require("colorbox.commons.json")
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
--- @field pack_path string "pack/colorbox/start/folke-tokyonight.nvim"
--- @field full_pack_path string "Users/linrongbin16/github/linrongbin16/colorbox.nvim/pack/colorbox/start/folke-tokyonight.nvim"
local ColorSpec = {}

--- @param handle string
--- @return string
local function _make_url(handle)
  return string.format("https://github.com/%s", handle)
end

--- @param handle string
--- @return string
local function _make_git_path(handle)
  local result = str.replace(handle, "/", "-")
  return result
end

--- @param handle string
--- @param github_stars integer
--- @param last_git_commit string
--- @param source string
--- @param git_branch string?
--- @param color_names string[]
--- @return colorbox.ColorSpec
function ColorSpec:new(handle, github_stars, last_git_commit, source, git_branch, color_names)
  local cwd = vim.fn["colorbox#base_dir"]()
  local git_path = _make_git_path(handle)
  local o = {
    handle = handle,
    url = _make_url(handle),
    github_stars = github_stars,
    last_git_commit = last_git_commit,
    source = source,
    git_path = git_path,
    git_branch = git_branch,
    color_names = color_names,
    pack_path = string.format("pack/colorbox/start/%s", git_path),
    full_pack_path = string.format("%s/pack/colorbox/start/%s", cwd, git_path),
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- specs
--- @type colorbox.ColorSpec[]
local ColorSpecs = {}

-- plugin name => spec
--- @type table<string, colorbox.ColorSpec>
local ColorSpecsMap = {}

-- plugin url => spec
local ColorSpecUrlsMap = {}

-- color names
--- @type string[]
local ColorNames = {}

-- color name => spec
--- @type table<string, colorbox.ColorSpec>
local ColorNamesMap = {}

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
    local cwd = vim.fn["colorbox#base_dir"]()
    local file = string.format("%s/autoload/db.json", cwd)
    local fp = io.open(file, "r")
    assert(fp, string.format("failed to read %s", vim.inspect(file)))
    local content = fp:read("*a")
    fp:close()
    local data = json.decode(content) --[[@as table]]
    HandleToColorSpecsMap = {}
    for _, d in pairs(data["_default"]) do
      local handle = d.h -- handle
      local github_stars = d.st -- github stars
      local last_git_commit = d.gc -- last git commit
      local source = d.s -- source
      local git_branch = d.gb -- git branch
      local color_names = d.cn -- color names
      HandleToColorSpecsMap[handle] =
        ColorSpec:new(handle, github_stars, last_git_commit, source, git_branch, color_names)
    end
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
    ColorNamesList = {}
    for _, spec in pairs(HandleToColorSpecsMap) do
      for _, color_name in ipairs(spec.color_names) do
        table.insert(ColorNamesList, color_name)
      end
    end
    table.sort(ColorNamesList, function(a, b)
      return a:lower() < b:lower()
    end)
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
