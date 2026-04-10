local log = require("colorbox.commons.log")

local configs = require("colorbox.configs")

local M = {}

--- @param f colorbox.FunctionFilterConfig
--- @param colorname string
--- @param spec colorbox.ColorSpec
--- @return boolean
M._function_filter = function(f, colorname, spec)
  if vim.is_callable(f) then
    local ok, result = pcall(f, colorname, spec)
    if ok and type(result) == "boolean" then
      return result
    else
      log.err("failed to invoke function filter, please check your config!")
    end
  end
  return false
end

--- @param f colorbox.AllFilterConfig
--- @param colorname string
--- @param spec colorbox.ColorSpec
--- @return boolean
M._all_filter = function(f, colorname, spec)
  if type(f) == "table" then
    for _, f1 in ipairs(f) do
      if type(f1) == "function" then
        local result = M._function_filter(f1, colorname, spec)
        if not result then
          return result
        end
      end
    end
  end
  return true
end

--- @param colorname string
--- @param spec colorbox.ColorSpec
--- @return boolean
M.run = function(colorname, spec)
  local confs = configs.get()
  if type(confs.filter) == "function" then
    return M._function_filter(confs.filter, colorname, spec)
  elseif type(confs.filter) == "table" then
    return M._all_filter(confs.filter, colorname, spec)
  end
  return true
end

return M
