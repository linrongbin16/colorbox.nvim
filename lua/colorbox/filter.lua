local logging = require("colorbox.commons.logging")

local configs = require("colorbox.configs")
local builtin_filters = require("colorbox.filter.builtin")

local M = {}

--- @param f colorbox.BuiltinFilterConfig
--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
M._builtin_filter = function(f, color_name, spec)
  if f == "primary" then
    return builtin_filters.primary(color_name, spec)
  end
  return false
end

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
      logging.get("colorbox"):err("failed to invoke function filter, please check your config!")
    end
  end
  return false
end

--- @param f colorbox.AllFilterConfig
--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
M._all_filter = function(f, color_name, spec)
  if type(f) == "table" then
    for _, f1 in ipairs(f) do
      if type(f1) == "string" then
        local result = M._builtin_filter(f1, color_name, spec)
        if not result then
          return result
        end
      elseif type(f1) == "function" then
        local result = M._function_filter(f1, color_name, spec)
        if not result then
          return result
        end
      end
    end
  end
  return true
end

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
M.run = function(color_name, spec)
  local confs = configs.get()
  if type(confs.filter) == "string" then
    return M._builtin_filter(confs.filter, color_name, spec)
  elseif type(confs.filter) == "function" then
    return M._function_filter(confs.filter, color_name, spec)
  elseif type(confs.filter) == "table" then
    return M._all_filter(confs.filter, color_name, spec)
  end
  return false
end

return M
