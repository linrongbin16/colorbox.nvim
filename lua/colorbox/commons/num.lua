local M = {}

-- int32 max/min
M.INT32_MAX = 2147483647
M.INT32_MIN = -2147483648

M._RELATIVE_PRECISION = 1e-09
M._ABSOLUTE_PRECISION = 0.0

-- https://docs.python.org/3/library/math.html#math.isclose
--
--- @param a number?
--- @param b number?
--- @param rel_tol number?
--- @param abs_tol number?
--- @return boolean
M.eq = function(a, b, rel_tol, abs_tol)
  if type(a) ~= "number" or type(b) ~= "number" then
    return false
  end
  if a == b then
    return true
  end

  rel_tol = rel_tol or M._RELATIVE_PRECISION
  abs_tol = abs_tol or M._ABSOLUTE_PRECISION

  return math.abs(a - b) <= math.max(rel_tol * math.max(math.abs(a), math.abs(b)), abs_tol)
end

--- @param a number?
--- @param b number?
--- @param rel_tol number?
--- @param abs_tol number?
--- @return boolean
M.ne = function(a, b, rel_tol, abs_tol)
  return not M.eq(a, b, rel_tol, abs_tol)
end

--- @param a number?
--- @param b number?
--- @param rel_tol number?
--- @param abs_tol number?
--- @return boolean
M.gt = function(a, b, rel_tol, abs_tol)
  if type(a) ~= "number" or type(b) ~= "number" then
    return false
  end
  return M.ne(a, b, rel_tol, abs_tol) and a > b
end

--- @param a integer
--- @param b integer
--- @return integer
M.mod = function(a, b)
  return math.floor(math.fmod(a, b))
end

--- @param value number
--- @param left number?   lower bound, by default INT32_MIN
--- @param right number?  upper bound, by default INT32_MAX
--- @return number
M.clamp = function(value, left, right)
  assert(type(value) == "number")
  assert(type(left) == "number" or left == nil)
  assert(type(right) == "number" or right == nil)
  return math.min(math.max(left or M.INT32_MIN, value), right or M.INT32_MAX)
end

-- Drop-in 32-bit random replacement of `math.random`.
--- @param m integer?
--- @param n integer?
--- @return number
M.random = function(m, n)
  local uv = vim.uv or vim.loop
  local rand_result, rand_err = uv.random(4)
  assert(rand_result ~= nil, rand_err)

  local bytes = {
    string.byte(rand_result --[[@as string]], 1, -1),
  }
  local total = 0
  for _, b in ipairs(bytes) do
    total = M.mod(total * 256 + b, M.INT32_MAX)
  end
  if m == nil and n == nil then
    return total / M.INT32_MAX
  elseif m ~= nil and n == nil then
    assert(type(m) == "number")
    assert(m >= 1)
    return M.mod(total, m) + 1
  else
    assert(type(m) == "number")
    assert(type(n) == "number")
    assert(n >= m)
    return M.mod(total, n - m + 1) + m
  end
end

return M
