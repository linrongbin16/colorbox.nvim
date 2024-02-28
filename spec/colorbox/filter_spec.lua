local cwd = vim.fn.getcwd()

describe("filter", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local db = require("colorbox.db")
  local filter = require("colorbox.filter")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("filter", function()
    it("run builtin primary", function()
      require("colorbox").setup({
        debug = true,
        file_log = true,
      })
      local ColorNameToColorSpecsMap = db.get_color_name_to_color_specs_map()
      for color, spec in pairs(ColorNameToColorSpecsMap) do
        local actual = filter.run(color, spec)
        assert_eq(type(actual), "boolean")
      end
    end)
    it("run lua function", function()
      local i = 0
      require("colorbox").setup({
        debug = true,
        file_log = true,
        filter = function()
          return i >= 5
        end,
      })
      local ColorNameToColorSpecsMap = db.get_color_name_to_color_specs_map()
      for color, spec in pairs(ColorNameToColorSpecsMap) do
        local actual = filter.run(color, spec)
        assert_eq(type(actual), "boolean")
        assert_eq(actual, i >= 5)
        i = i + 1
      end
    end)
    it("_builtin_filter", function()
      local ColorNameToColorSpecsMap = db.get_color_name_to_color_specs_map()
      for color, spec in pairs(ColorNameToColorSpecsMap) do
        local actual = filter._builtin_filter("primary", color, spec)
        assert_eq(type(actual), "boolean")
      end
    end)
    it("_function_filter", function()
      local ColorNameToColorSpecsMap = db.get_color_name_to_color_specs_map()
      for color, spec in pairs(ColorNameToColorSpecsMap) do
        local actual = filter._function_filter(function(c, s)
          return true
        end, color, spec)
        assert_eq(type(actual), "boolean")
        assert_true(actual)
      end
      for color, spec in pairs(ColorNameToColorSpecsMap) do
        local actual = filter._function_filter(function(c, s)
          return false
        end, color, spec)
        assert_eq(type(actual), "boolean")
        assert_false(actual)
      end
    end)
    it("_all_filter", function()
      local ColorNameToColorSpecsMap = db.get_color_name_to_color_specs_map()
      for color, spec in pairs(ColorNameToColorSpecsMap) do
        local actual = filter._all_filter({
          function(c, s)
            return true
          end,
          function(c, s)
            return true
          end,
        }, color, spec)
        assert_eq(type(actual), "boolean")
        assert_true(actual)
      end
      for color, spec in pairs(ColorNameToColorSpecsMap) do
        local actual = filter._all_filter({
          function(c, s)
            return false
          end,
          function(c, s)
            return false
          end,
        }, color, spec)
        assert_eq(type(actual), "boolean")
        assert_false(actual)
      end
    end)
  end)
end)
