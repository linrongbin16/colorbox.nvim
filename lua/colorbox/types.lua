local uv = vim.uv

local string_len = string.len
local string_gsub = string.gsub
local string_byte = string.byte

local M = {}

-- File I/O.

-- 0o666, the default permission of a newly created file.
local FILE_MODE = 438

--- @param filename string
--- @return string? content
--- @return string? err
M.read_file = function(filename)
  local fd, open_err = uv.fs_open(filename, "r", FILE_MODE)
  if open_err ~= nil or fd == nil then
    return nil, open_err or "failed to open file"
  end

  local stat, stat_err = uv.fs_fstat(fd)
  if stat_err ~= nil or stat == nil then
    uv.fs_close(fd)
    return nil, stat_err or "failed to stat file"
  end

  local content, read_err = uv.fs_read(fd, stat.size, 0)
  local _, close_err = uv.fs_close(fd)

  if read_err ~= nil then
    return nil, read_err
  end
  if close_err ~= nil then
    return nil, close_err
  end
  return content --[[@as string]]
end

--- @alias colorbox.AsyncWriteFileOnComplete fun(bytes:integer?):any
--- @alias colorbox.AsyncWriteFileOnError fun(step:string?,err:string?):any
--- @param filename string                              file name.
--- @param content string                               file content.
--- @param opts {on_complete:colorbox.AsyncWriteFileOnComplete,on_error:colorbox.AsyncWriteFileOnError?}
--- @return boolean ok    false when the file cannot be opened, i.e. the async write never starts.
--- @return string? err   error message when `ok` is false.
M.write_file_async = function(filename, content, opts)
  assert(type(opts) == "table")
  assert(type(opts.on_complete) == "function")

  local on_error = opts.on_error
  if type(on_error) ~= "function" then
    on_error = function(step, err)
      error(
        string.format(
          "failed to write file(%s), filename:%s, error:%s",
          vim.inspect(step),
          vim.inspect(filename),
          vim.inspect(err)
        )
      )
    end
  end

  local fd, open_err = uv.fs_open(filename, "w", FILE_MODE)
  if open_err ~= nil or fd == nil then
    return false, open_err or "failed to open file"
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  uv.fs_write(fd, content, nil, function(on_write_err, bytes)
    if on_write_err then
      on_error("fs_write", on_write_err)
      return
    end
    ---@diagnostic disable-next-line: param-type-mismatch
    uv.fs_close(fd, function(on_close_err)
      if on_close_err then
        on_error("fs_close", on_close_err)
        return
      end
      opts.on_complete(bytes)
    end)
  end)

  return true
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
M.str_not_empty = function(s)
  return type(s) == "string" and string_len(s) > 0
end

--- @param s any
--- @return boolean
M.str_blank = function(s)
  return type(s) ~= "string" or string_len(vim.trim(s)) == 0
end

--- @param s any
--- @return boolean
M.str_not_blank = function(s)
  return type(s) == "string" and string_len(vim.trim(s)) > 0
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
--- @param t string?  by default is whitespace
--- @return string
M.str_trim = function(s, t)
  assert(type(s) == "string")
  assert(type(t) == "string" or t == nil)
  return M.str_rtrim(M.str_ltrim(s, t), t)
end

--- @param s string
--- @param sep string
--- @param opts {plain:boolean?,trimempty:boolean?}?  by default opts={plain=true,trimempty=false}
--- @return string[]
M.str_split = function(s, sep, opts)
  assert(type(s) == "string")
  assert(type(sep) == "string")
  opts = opts or {
    plain = true,
    trimempty = false,
  }
  opts.plain = type(opts.plain) == "boolean" and opts.plain or true
  opts.trimempty = type(opts.trimempty) == "boolean" and opts.trimempty or false
  return vim.split(s, sep, opts)
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
  return type(t) ~= "table" or next(t) == nil
end

return M
