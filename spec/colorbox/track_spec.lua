local cwd = vim.fn.getcwd()

describe("colorbox.track", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local track = require("colorbox.track")
  local runtime = require("colorbox.runtime")
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
      local ColorNamesList = runtime.colornames()
      for i, color in ipairs(ColorNamesList) do
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
    it("next", function()
      local ColorNamesList = runtime.colornames()
      local n = #ColorNamesList
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
        if actual then
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
      local ColorNamesList = runtime.colornames()
      local n = #ColorNamesList
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
        if actual then
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
