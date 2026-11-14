--- @class colorbox.ColorSpec
--- @field handle string "folke/tokyonight.nvim"
--- @field color_name string "tokyonight"
--- @field plugin_name string "tokyonight"
--- @field url string "https://github.com/folke/tokyonight.nvim"
--- @field install_path string "folke-tokyonight.nvim"
--- @field git_branch string? nil|"neovim"
local ColorSpec = {}

--- The generated dataset, see `collect.py`:
--- `specs` maps a git handle to a color name, `overrides` holds the few fields
--- that cannot be derived from the handle (custom url, plugin name, branch).
--- @class colorbox.SpecOverrides
--- @field url string?
--- @field plugin_name string?
--- @field git_branch string?

--- @class colorbox.Dataset
--- @field specs table<string, string>
--- @field overrides table<string, colorbox.SpecOverrides>
local dataset = require("colorbox.meta.dataset")

--- Split a git handle into owner and repository name.
--- @param handle string
--- @return string, string
local function split_handle(handle)
  local owner, repo = handle:match("^([^/]+)/(.+)$")
  if type(owner) ~= "string" or type(repo) ~= "string" then
    error(string.format("invalid handle in dataset:%s", vim.inspect(handle)))
  end
  return owner, repo
end

--- Expand a dataset entry into a full `colorbox.ColorSpec`.
--- @param handle string
--- @param color_name string
--- @return colorbox.ColorSpec
local function build_spec(handle, color_name)
  local owner, repo = split_handle(handle)
  --- @type colorbox.ColorSpec
  local spec = {
    handle = handle,
    color_name = color_name,
    plugin_name = repo,
    url = string.format("https://github.com/%s", handle),
    install_path = string.format("%s-%s", owner, repo),
    git_branch = nil,
  }
  local overrides = dataset.overrides[handle]
  if overrides ~= nil then
    spec.url = overrides.url or spec.url
    spec.plugin_name = overrides.plugin_name or spec.plugin_name
    spec.git_branch = overrides.git_branch
  end
  return spec
end

--- @type table<string, colorbox.ColorSpec>
local SpecsByHandle = {}
--- @type table<string, colorbox.ColorSpec>
local SpecsByColorName = {}
--- @type string[]
local ColorNames = {}

for handle, color_name in pairs(dataset.specs) do
  assert(
    SpecsByColorName[color_name] == nil,
    string.format("duplicate color name in dataset:%s", vim.inspect(color_name))
  )
  local spec = build_spec(handle, color_name)
  SpecsByHandle[handle] = spec
  SpecsByColorName[color_name] = spec
  table.insert(ColorNames, color_name)
end
table.sort(ColorNames, function(a, b)
  return string.lower(a) < string.lower(b)
end)

for handle in pairs(dataset.overrides) do
  assert(
    dataset.specs[handle] ~= nil,
    string.format("overrides for unknown handle in dataset:%s", vim.inspect(handle))
  )
end

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
  return SpecsByHandle
end

--- @return table<string, colorbox.ColorSpec>
local function get_specs_by_color_name()
  return SpecsByColorName
end

--- @return string[]
local function get_color_names()
  return ColorNames
end

local M = {
  get_specs_by_handle = get_specs_by_handle,
  get_specs_by_color_name = get_specs_by_color_name,
  get_color_names = get_color_names,
  get_pack_path = get_pack_path,
  get_full_pack_path = get_full_pack_path,
}

return M
