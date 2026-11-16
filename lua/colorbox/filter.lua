local log = require("colorbox.log")

local configs = require("colorbox.configs")

local M = {}

--- @param f colorbox.FunctionFilterConfig
--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
M._function_filter = function(f, color_name, spec)
  if vim.is_callable(f) then
    local ok, result = pcall(f, color_name, spec)
    if ok and type(result) == "boolean" then
      return result
    else
      log.err("failed to invoke function filter, please check your config!")
    end
  end
  return false
end

--- @param f colorbox.AllFilterConfig
--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
M._all_filter = function(f, color_name, spec)
  for _, f1 in ipairs(f) do
    if not M._function_filter(f1, color_name, spec) then
      return false
    end
  end
  return true
end

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
M.run = function(color_name, spec)
  -- invalid values are warned once in `configs.validate` and normalized to nil.
  local f = configs.get().filter
  if type(f) == "function" then
    return M._function_filter(f, color_name, spec)
  elseif type(f) == "table" then
    return M._all_filter(f, color_name, spec)
  end
  return true
end

return M
