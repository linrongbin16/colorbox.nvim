local cwd = vim.uv.cwd()

describe("colorbox.track", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local types = require("colorbox.types")
  local track = require("colorbox.track")
  local runtime = require("colorbox.runtime")

  --- @param filename string
  --- @param content string
  local function write_file(filename, content)
    local fp = assert(io.open(filename, "w"))
    fp:write(content)
    fp:close()
  end

  --- @param filename string
  --- @return string
  local function read_file(filename)
    local fp = io.open(filename, "r")
    if fp == nil then
      return ""
    end
    local content = fp:read("*a")
    fp:close()
    return content
  end
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("[sync_syntax]", function()
    it("test", function()
      track.sync_syntax()
    end)
  end)
  describe("[track]", function()
    it("save_track", function()
      local color_names = runtime.color_names()
      for i, color in ipairs(color_names) do
        track.save_track(color)
      end
    end)
    it("previous_track", function()
      local tck = track.previous_track()
      if tck then
        assert_eq(type(tck), "table")
        assert_true(string.len(tck.color_name) > 0)
        assert_true(tck.color_number > 0)
      end
    end)
    it("save_track skips a colorscheme colorbox does not manage", function()
      local confs = require("colorbox.configs").get()
      local cache_file = confs.previous_track_cache
      -- flush the writes queued by the previous case, they run `vim.schedule`ed
      vim.wait(300, function()
        return false
      end)
      write_file(cache_file, "")

      track.save_track("default")
      vim.wait(200, function()
        return false
      end)
      assert_eq(read_file(cache_file), "")

      local color_names = runtime.color_names()
      if #color_names > 0 then
        track.save_track(color_names[1])
        vim.wait(200, function()
          return read_file(cache_file) ~= ""
        end)
        local tck = track.previous_track()
        assert_eq(tck.color_name, color_names[1])
        assert_eq(tck.color_number, 1)
      end
    end)
    it("previous_track ignores a color colorbox does not manage", function()
      local cache_file = require("colorbox.configs").get().previous_track_cache
      write_file(cache_file, '{"color_name":"default","color_number":1}')
      assert_eq(track.previous_track(), nil)

      write_file(cache_file, '{"color_name":"","color_number":1}')
      assert_eq(track.previous_track(), nil)

      write_file(cache_file, '{"color_number":1}')
      assert_eq(track.previous_track(), nil)

      write_file(cache_file, "[]")
      assert_eq(track.previous_track(), nil)
    end)
    it("previous_track repairs a stale color_number", function()
      local cache_file = require("colorbox.configs").get().previous_track_cache
      local color_names = runtime.color_names()
      if #color_names == 0 then
        return
      end
      local color_name = color_names[1]
      write_file(cache_file, '{"color_name":"' .. color_name .. '","color_number":999}')
      local tck = track.previous_track()
      assert_eq(tck.color_name, color_name)
      assert_eq(tck.color_number, 1)
    end)
    it("next", function()
      local color_names = runtime.color_names()
      local n = #color_names
      for i = 1, 2 * n do
        local actual, actual_idx = track.get_next_color_name_by_idx(i)
        print(
          string.format(
            "get_next_color_name_by_idx(%s): %s, %s\n",
            vim.inspect(i),
            vim.inspect(actual),
            vim.inspect(actual_idx)
          )
        )
        if not types.str_empty(actual) then
          assert_true(string.len(actual) > 0)
          if i < n then
            assert_eq(actual_idx, i + 1)
          else
            assert_eq(actual_idx, 1)
          end
        end
      end
    end)
    it("prev", function()
      local color_names = runtime.color_names()
      local n = #color_names
      for i = 0, 2 * n do
        local actual, actual_idx = track.get_prev_color_name_by_idx(i)
        print(
          string.format(
            "get_next_color_name_by_idx(%s): %s, %s\n",
            vim.inspect(i),
            vim.inspect(actual),
            vim.inspect(actual_idx)
          )
        )
        if not types.str_empty(actual) then
          assert_true(string.len(actual) > 0)
          if i > 1 and i <= n then
            assert_eq(actual_idx, i - 1)
          else
            assert_eq(actual_idx, n)
          end
        end
      end
    end)
  end)
end)
