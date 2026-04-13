local log = require("colorbox.commons.log")

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
  if type(f) == "table" then
    for _, f1 in ipairs(f) do
      if type(f1) == "function" then
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
  if type(confs.filter) == "function" then
    return M._function_filter(confs.filter, color_name, spec)
  elseif type(confs.filter) == "table" then
    return M._all_filter(confs.filter, color_name, spec)
  end
  return true
end

return M
