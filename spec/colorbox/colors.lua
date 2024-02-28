local cwd = vim.fn.getcwd()

describe("colors", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local strings = require("colorbox.commons.strings")
  local builtin_policy = require("colorbox.policy.builtin")
  local tables = require("colorbox.commons.tables")
  local colors = require("colorbox.colors")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("[_build_colors]", function()
    it("test", function()
      local actual = colors._build_colors()
      assert_true(tables.list_not_empty(tables.tbl_get(actual, "colors_list")))
      assert_true(tables.tbl_not_empty(tables.tbl_get(actual, "colors_index")))
      for i, color in ipairs(actual.colors_list) do
        assert_eq(actual.colors_index[color], i)
      end
    end)
  end)
end)
