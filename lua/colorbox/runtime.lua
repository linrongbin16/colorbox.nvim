local log = require("colorbox.commons.log")
local filter = require("colorbox.filter")
local db = require("colorbox.db")
local uv = vim.uv or vim.loop

local M = {}

-- filtered color names list
--- @type string[]
local AvailableColorNames = {}

-- the reverse of FilteredColorNamesList (index => name)
--- @type table<string, integer>
local AvailableColorIndexes = {}

--- @return {colors_list:string[],colors_index:table<string,integer>}
M._available_colors = function()
  -- All color name list
  local colors_list = {}
  -- Maps from color name to its index in `colors_list`
  local colors_index = {}

  local specs_by_colorname = db.get_specs_by_colorname()
  local color_names = db.get_color_names()
  for _, color_name in pairs(color_names) do
    local spec = specs_by_colorname[color_name]
    local full_pack_path = db.get_full_pack_path(spec)
    local pack_exist = uv.fs_stat(full_pack_path) ~= nil
    local yes = filter.run(color_name, spec)
    -- logger:debug(
    --   string.format(
    --     "|_build_colors| color_name:%s, choose:%s, pack_exist:%s, full_pack_path:%s",
    --     vim.inspect(color_name),
    --     vim.inspect(choose),
    --     vim.inspect(pack_exist),
    --     vim.inspect(full_pack_path)
    --   )
    -- )
    if yes and pack_exist then
      table.insert(colors_list, color_name)
    end
  end
  for i, color_name in ipairs(colors_list) do
    colors_index[color_name] = i
  end

  return {
    colors_list = colors_list,
    colors_index = colors_index,
  }
end

M.setup = function()
  local available_colors = M._available_colors()
  log.debug(string.format("|setup| available_colors:%s", vim.inspect(available_colors)))
  AvailableColorNames = available_colors.colors_list
  AvailableColorIndexes = available_colors.colors_index

  -- logger:debug("|_init| FilteredColorNamesList:%s", vim.inspect(FilteredColorNamesList))
  -- logger:debug("|_init| FilteredColorNameToIndexMap:%s", vim.inspect(FilteredColorNameToIndexMap))
end

M.color_names = function()
  return AvailableColorNames
end

M.color_indexes = function()
  return AvailableColorIndexes
end

return M
