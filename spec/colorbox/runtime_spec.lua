local cwd = vim.uv.cwd()

describe("colorbox.runtime", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local runtime = require("colorbox.runtime")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("[_available_colors]", function()
    it("test", function()
      local actual = runtime._available_colors()
      print(string.format("_build_colors:%s\n", vim.inspect(actual)))
      assert_eq(type(vim.tbl_get(actual, "colors_list")), "table")
      assert_eq(type(vim.tbl_get(actual, "colors_index")), "table")
      for i, color in ipairs(actual.colors_list) do
        assert_eq(actual.colors_index[color], i)
      end
    end)
    it("color_names/color_indexes", function()
      local color_names = runtime.color_names()
      local color_indexes = runtime.color_indexes()
      for i, color in ipairs(color_names) do
        assert_eq(color_indexes[color], i)
      end
    end)
    it("setup", function()
      runtime.setup()
    end)
    it("default filter enables every installed color", function()
      local db = require("colorbox.db")
      runtime.setup()
      local color_names = runtime.color_names()
      local installed = {}
      for _, color in ipairs(db.get_color_names()) do
        if runtime.is_package_available(db.get_specs_by_color_name()[color]) then
          table.insert(installed, color)
        end
      end
      assert_true(#installed > 0)
      assert_eq(#color_names, #installed)
    end)
  end)
end)
