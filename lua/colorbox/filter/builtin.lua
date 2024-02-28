local numbers = require("colorbox.commons.numbers")
local strings = require("colorbox.commons.strings")
local logging = require("colorbox.commons.logging")

local M = {}

--- @param spec colorbox.ColorSpec
--- @return integer
M._minimal_color_name_len = function(spec)
  local n = numbers.INT32_MAX
  for _, c in ipairs(spec.color_names) do
    if string.len(c) < n then
      n = string.len(c)
    end
  end
  return n
end

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return integer
M._primary_score = function(color_name, spec)
  -- local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]

  -- unique
  local unique = #spec.color_names <= 1

  -- shortest
  local current_name_len = string.len(color_name)
  local minimal_name_len = M._minimal_color_name_len(spec)
  local shortest = current_name_len == minimal_name_len

  -- match
  local handle_splits = strings.split(spec.handle, "/")
  local handle1 = handle_splits[1]:gsub("%-", "_")
  local handle2 = handle_splits[2]:gsub("%-", "_")
  local normalized_color = color_name:gsub("%-", "_")
  local matched = strings.startswith(handle1, normalized_color, { ignorecase = true })
    or strings.startswith(handle2, normalized_color, { ignorecase = true })
    or strings.endswith(handle1, normalized_color, { ignorecase = true })
    or strings.endswith(handle2, normalized_color, { ignorecase = true })
  -- logger:debug(
  --     "|_primary_score| unique:%s, shortest:%s (current:%s, minimal:%s), matched:%s",
  --     vim.inspect(unique),
  --     vim.inspect(shortest),
  --     vim.inspect(current_name_len),
  --     vim.inspect(minimal_name_len),
  --     vim.inspect(matched)
  -- )
  local n = 0
  if unique then
    n = n + 3
  end
  if matched then
    n = n + 2
  end
  if shortest then
    n = n + 1
  end
  return n
end

--- @param color_name string
--- @param spec colorbox.ColorSpec
--- @return boolean
M.primary = function(color_name, spec)
  local color_score = M._primary_score(color_name, spec)
  for _, other_color in ipairs(spec.color_names) do
    local other_score = M._primary_score(other_color, spec)
    if color_score < other_score then
      return false
    end
  end
  return true
end

return M
