local cwd = vim.fn.getcwd()

describe("colorbox.util", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local db = require("colorbox.db")
  local util = require("colorbox.util")
  local colors = require("colorbox.colors")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("[sync_syntax]", function()
    it("test", function()
      util.sync_syntax()
    end)
  end)
  describe("[track]", function()
    it("save_track", function()
      local ColorNamesList = colors.colornames()
      for i, color in ipairs(ColorNamesList) do
        util.save_track(color)
      end
    end)
    it("previous_track", function()
      local track = util.previous_track()
      if track then
        assert_eq(type(track), "table")
        assert_true(string.len(track.color_name) > 0)
        assert_true(track.color_number > 0)
      end
    end)
    it("next", function()
      local ColorNamesList = colors.colornames()
      local n = #ColorNamesList
      for i = 1, 2 * n do
        local actual, actual_idx = util.get_next_color_name_by_idx(i)
        print(
          string.format(
            "get_next_color_name_by_idx(%s): %s, %s\n",
            vim.inspect(i),
            vim.inspect(actual),
            vim.inspect(actual_idx)
          )
        )
        assert_true(string.len(actual) > 0)
        if i < n then
          assert_eq(actual_idx, i + 1)
        else
          assert_eq(actual_idx, 1)
        end
      end
    end)
    it("prev", function()
      local ColorNamesList = colors.colornames()
      local n = #ColorNamesList
      for i = 0, 2 * n do
        local actual, actual_idx = util.get_prev_color_name_by_idx(i)
        print(
          string.format(
            "get_next_color_name_by_idx(%s): %s, %s\n",
            vim.inspect(i),
            vim.inspect(actual),
            vim.inspect(actual_idx)
          )
        )
        assert_true(string.len(actual) > 0)
        if i > 1 and i <= n then
          assert_eq(actual_idx, i - 1)
        else
          assert_eq(actual_idx, n)
        end
      end
    end)
  end)
end)
