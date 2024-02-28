local M = {}

-- filtered color names list
--- @type string[]
local FilteredColorNamesList = {}

-- the reverse of FilteredColorNamesList (index => name)
--- @type table<string, integer>
local FilteredColorNameToIndexMap = {}

M.setup = function() end

M.colornames = function()
  return FilteredColorNamesList
end

M.colornames_index = function()
  return FilteredColorNameToIndexMap
end

return M
