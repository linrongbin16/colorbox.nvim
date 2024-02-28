local cwd = vim.fn.getcwd()

describe("colorbox.colors", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local strings = require("colorbox.commons.strings")
  local tables = require("colorbox.commons.tables")
  local colors = require("colorbox.colors")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("[_build_colors]", function()
    it("test", function()
      local actual = colors._build_colors()
      print(string.format("_build_colors:%s\n", vim.inspect(actual)))
      assert_eq(type(tables.tbl_get(actual, "colors_list")), "table")
      assert_eq(type(tables.tbl_get(actual, "colors_index")), "table")
      for i, color in ipairs(actual.colors_list) do
        assert_eq(actual.colors_index[color], i)
      end
    end)
    it("colornames/colornames_index", function()
      local colornames = colors.colornames()
      local colornames_index = colors.colornames_index()
      for i, color in ipairs(colornames) do
        assert_eq(colornames_index[color], i)
      end
    end)
    it("setup", function()
      colors.setup()
    end)
  end)
end)
