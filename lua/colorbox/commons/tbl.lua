local M = {}

--- @param t any?
--- @return boolean
M.tbl_empty = function(t)
  return type(t) ~= "table" or next(t) == nil
end

return M
