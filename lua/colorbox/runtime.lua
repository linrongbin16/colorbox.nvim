local tbl = require("colorbox.commons.tbl")
local str = require("colorbox.commons.str")
local uv = require("colorbox.commons.uv")
local fileios = require("colorbox.commons.fileio")
local logging = require("colorbox.commons.logging")

local configs = require("colorbox.configs")
local filter = require("colorbox.filter")
local db = require("colorbox.db")

local M = {}

-- filtered color names list
--- @type string[]
local FilteredColorNamesList = {}

-- the reverse of FilteredColorNamesList (index => name)
--- @type table<string, integer>
local FilteredColorNameToIndexMap = {}

--- @return {colors_list:string[],colors_index:table<string,integer>}
M._build_colors = function()
  local colors_list = {}
  local colors_index = {}

  local ColorNameToColorSpecsMap = require("colorbox.db").get_color_name_to_color_specs_map()
  local ColorNamesList = require("colorbox.db").get_color_names_list()
  for _, color_name in pairs(ColorNamesList) do
    local spec = ColorNameToColorSpecsMap[color_name]
    local full_pack_path = db.get_full_pack_path(spec)
    local pack_exist = uv.fs_stat(full_pack_path) ~= nil
    if filter.run(color_name, spec) and pack_exist then
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
  local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]

  local home_dir = vim.fn["colorbox#base_dir"]()
  vim.opt.packpath:append(home_dir)

  local confs = configs.get()
  logger:debug(
    string.format(
      "|setup| confs.previous_colors_cache:%s",
      vim.inspect(confs.previous_colors_cache)
    )
  )
  local cache_content = fileios.readfile(confs.previous_colors_cache, { trim = true })
  logger:debug(string.format("|setup| cache_content:%s", vim.inspect(cache_content)))
  local found_cache = false

  if cache_content then
    local colors_list = str.split(cache_content, ",")
    logger:debug(string.format("|setup| colors_list:%s", vim.inspect(colors_list)))
    if tbl.list_not_empty(colors_list) then
      FilteredColorNamesList = colors_list

      FilteredColorNameToIndexMap = {}
      for i, color_name in ipairs(colors_list) do
        FilteredColorNameToIndexMap[color_name] = i
      end
      found_cache = true

      vim.defer_fn(function()
        local data = M._build_colors()
        fileios.asyncwritefile(
          confs.previous_colors_cache,
          table.concat(data.colors_list, ","),
          function()
            logger:debug("|setup| found cache, update cache - done")
          end
        )
      end, 100)
    end
  end

  if not found_cache then
    local data = M._build_colors()
    logger:debug(string.format("|setup| not found, data:%s", vim.inspect(data)))
    FilteredColorNamesList = data.colors_list
    FilteredColorNameToIndexMap = data.colors_index

    vim.defer_fn(function()
      fileios.asyncwritefile(
        confs.previous_colors_cache,
        table.concat(FilteredColorNamesList, ","),
        function()
          logger:debug("|setup| not found cache, dump cache - done")
        end
      )
    end, 100)
  end

  -- logger:debug("|_init| FilteredColorNamesList:%s", vim.inspect(FilteredColorNamesList))
  -- logger:debug("|_init| FilteredColorNameToIndexMap:%s", vim.inspect(FilteredColorNameToIndexMap))
end

M.colornames = function()
  return FilteredColorNamesList
end

M.colornames_index = function()
  return FilteredColorNameToIndexMap
end

return M
