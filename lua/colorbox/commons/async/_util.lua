---@diagnostic disable
local M = {}

--- @param ... any
--- @return {[integer]: any, n: integer}
function M.pack_len(...)
  return { n = select('#', ...), ... }
end

--- like unpack() but use the length set by F.pack_len if present
--- @param t? { [integer]: any, n?: integer }
--- @param first? integer
--- @return any...
function M.unpack_len(t, first)
  if t then
    return unpack(t, first or 1, t.n or table.maxn(t))
  end
end

--- @return_cast obj function
function M.is_callable(obj)
  return vim.is_callable(obj)
end

return M
