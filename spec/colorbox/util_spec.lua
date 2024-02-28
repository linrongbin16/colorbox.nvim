local cwd = vim.fn.getcwd()

describe("util", function()
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

  describe("[util]", function()
    it("sync_syntax", function()
      util.sync_syntax()
    end)
    it("save_track", function()
      local ColorNamesList = colors.colornames()
      for i, color in ipairs(ColorNamesList) do
        util.save_track(color)
      end
    end)
    it("previous_track", function()
      local track = util.save_track(color)
      if track then
        assert_eq(type(track), "table")
        assert_true(string.len(track.color_name) > 0)
        assert_true(track.color_number > 0)
      end
    end)
  end)
end)
