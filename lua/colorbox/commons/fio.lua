local uv = vim.uv or vim.loop

local M = {}

--- @param filename string
--- @return string?
M.readfile = function(filename)
  local f = io.open(filename, "r")
  if f == nil then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return content
end

--- @alias commons.AsyncWriteFileOnComplete fun(bytes:integer?):any
--- @alias commons.AsyncWriteFileOnError fun(step:string?,err:string?):any
--- @param filename string                      file name.
--- @param content string                       file content.
--- @param opts {on_complete:commons.AsyncWriteFileOnComplete,on_error:commons.AsyncWriteFileOnError?}
M.asyncwritefile = function(filename, content, opts)
  assert(type(opts) == "table")
  assert(type(opts.on_complete) == "function")

  if type(opts.on_error) ~= "function" then
    opts.on_error = function(step, err)
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

  uv.fs_open(filename, "w", 438, function(on_open_err, fd)
    if on_open_err then
      opts.on_error("fs_open", on_open_err)
      return
    end
    ---@diagnostic disable-next-line: param-type-mismatch
    uv.fs_write(fd, content, nil, function(on_write_err, bytes)
      if on_write_err then
        opts.on_error("fs_write", on_write_err)
        return
      end
      ---@diagnostic disable-next-line: param-type-mismatch
      uv.fs_close(fd, function(on_close_err)
        if on_close_err then
          opts.on_error("fs_close", on_close_err)
          return
        end
        opts.on_complete(bytes)
      end)
    end)
  end)
end

return M
