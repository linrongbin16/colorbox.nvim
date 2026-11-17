local uv = vim.uv

local string_len = string.len
local string_gsub = string.gsub
local string_byte = string.byte

local M = {}

-- File I/O.

-- Monotonic counter that keeps the staging files of this instance apart.
local tmp_seq = 0

--- @param filename string
--- @return string? content
--- @return string? err
M.read_file = function(filename)
  local ok, content = pcall(vim.fn.readblob, filename)
  if not ok then
    return nil, tostring(content)
  end
  return content --[[@as string]]
end

--- A unique sibling name of `filename`, used as the staging file for the atomic replace.
--- The pid keeps two Neovim instances from staging into the very same file, the counter
--- keeps two writes of the very same instance apart.
--- @param filename string
--- @return string
local function tmp_file(filename)
  tmp_seq = tmp_seq + 1
  return string.format("%s.tmp.%d.%d", filename, uv.os_getpid(), tmp_seq)
end

--- Write `content` into `filename`, replacing it as a whole.
---
--- The content goes into a private staging file that is then renamed over the
--- destination. The rename is atomic, so a reader only ever observes a whole file:
--- never a truncated one, never a mix of two writes. Opening the destination with "w"
--- and writing into it directly cannot give that guarantee, because opening truncates
--- a file, and a reader that arrives in between sees the truncation.
--- @param filename string  file name.
--- @param content string   file content.
--- @return boolean ok
--- @return string? err     error message when `ok` is false.
M.write_file = function(filename, content)
  local tmpname = tmp_file(filename)

  --- Report the destination the caller asked for, not the staging file name.
  --- @param msg string
  --- @return string
  local function report(msg)
    return (msg:gsub(vim.pesc(tmpname), function()
      return filename
    end))
  end

  -- A string is written as the exact bytes it holds, NUL bytes included; the `b` flag
  -- only matters for a line list, where it drops the newline after the last line.
  local ok, err = pcall(vim.fn.writefile, content, tmpname, "b")
  if ok and err ~= 0 then
    ok, err = false, string.format("writefile returned %s", vim.inspect(err))
  end
  if ok then
    local _, rename_err = uv.fs_rename(tmpname, filename)
    if rename_err == nil then
      return true
    end
    ok, err = false, rename_err
  end

  uv.fs_unlink(tmpname)
  return false, report(tostring(err))
end

-- Number.

-- int32 max/min
M.INT32_MAX = 2147483647
M.INT32_MIN = -2147483648

--- @param a number?
--- @param b number?
--- @return boolean
M.greater_than = function(a, b)
  if type(a) ~= "number" or type(b) ~= "number" then
    return false
  end
  return a > b
end

--- Integer modulo. The result always has the same sign as `b`, i.e. it is non-negative for a
--- positive `b`, same as the Lua `%` operator on integers: `mod(-1, 3) == 2`.
--- @param a number
--- @param b number
--- @return number remainder
M.mod = function(a, b)
  assert(type(a) == "number", "a must be a number")
  assert(type(b) == "number", "b must be a number")
  assert(b ~= 0, "b must not be zero")
  return a % b
end

--- Clamp `value` into the `[left, right]` range, missing bounds default to the int32 range.
--- @param value number
--- @param left number?   lower bound, by default INT32_MIN
--- @param right number?  upper bound, by default INT32_MAX
--- @return number clamped value
M.clamp = function(value, left, right)
  assert(type(value) == "number", "value must be a number")
  assert(left == nil or type(left) == "number", "left must be a number")
  assert(right == nil or type(right) == "number", "right must be a number")
  left = left or M.INT32_MIN
  right = right or M.INT32_MAX
  return math.min(math.max(value, left), right)
end

-- Drop-in replacement of `math.random(m, n)`, backed by the system CSPRNG.
--- @param m integer lower bound
--- @param n integer upper bound
--- @return integer value  integer in [m, n]
M.random = function(m, n)
  assert(type(m) == "number", "m must be a number")
  assert(type(n) == "number", "n must be a number")
  local lo, hi = math.floor(m), math.floor(n)
  assert(hi >= lo, "upper bound must be >= lower bound")

  -- `uv.random` only produces bytes, assemble them big-endian into a 32-bit unsigned integer.
  local result = uv.random(4) --[[@as string]]
  local b1, b2, b3, b4 = string_byte(result, 1, 4)
  local value = ((b1 * 256 + b2) * 256 + b3) * 256 + b4
  return lo + value % (hi - lo + 1)
end

-- String.

--- @param s any
--- @return boolean
M.str_empty = function(s)
  return type(s) ~= "string" or string_len(s) == 0
end

--- @param s any
--- @return boolean
M.str_blank = function(s)
  return type(s) ~= "string" or string_len(vim.trim(s)) == 0
end

--- @param s string
--- @param t string?  by default is whitespace
--- @return string
M.str_ltrim = function(s, t)
  assert(type(s) == "string")
  assert(type(t) == "string" or t == nil)

  t = t or "%s+"
  ---@diagnostic disable-next-line: redundant-return-value
  return string_gsub(s, "^" .. t, "")
end

--- @param s string
--- @param t string?  by default is whitespace
--- @return string
M.str_rtrim = function(s, t)
  assert(type(s) == "string")
  assert(type(t) == "string" or t == nil)

  t = t or "%s+"
  ---@diagnostic disable-next-line: redundant-return-value
  return string_gsub(s, t .. "$", "")
end

--- @param s string
--- @param t string
--- @param opts {ignorecase:boolean?}?
--- @return boolean
M.str_startswith = function(s, t, opts)
  assert(type(s) == "string")
  assert(type(t) == "string")

  opts = opts or { ignorecase = false }
  opts.ignorecase = type(opts.ignorecase) == "boolean" and opts.ignorecase or false

  if opts.ignorecase then
    return string_len(s) >= string_len(t) and s:sub(1, #t):lower() == t:lower()
  else
    return string_len(s) >= string_len(t) and s:sub(1, #t) == t
  end
end

-- Table.

--- @param t any?
--- @return boolean
M.tbl_empty = function(t)
  return type(t) ~= "table" or vim.tbl_isempty(t)
end

return M
