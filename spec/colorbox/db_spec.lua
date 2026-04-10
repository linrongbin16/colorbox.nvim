local cwd = vim.fn.getcwd()

describe("colorbox.db", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local db = require("colorbox.db")
  describe("[get_xxx]", function()
    it("get_specs_by_handle", function()
      local specs_by_handle = db.get_specs_by_handle()
      assert_eq(type(specs_by_handle), "table")
    end)
    it("get_specs_by_colorname", function()
      local specs_by_colorname = db.get_specs_by_colorname()
      assert_eq(type(specs_by_colorname), "table")
    end)
    it("get_color_names", function()
      local colornames = db.get_color_names()
      assert_eq(type(colornames), "table")
    end)
  end)
end)
