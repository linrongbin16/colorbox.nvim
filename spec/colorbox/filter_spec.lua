local cwd = vim.fn.getcwd()

describe("colorbox", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local colorbox = require("colorbox")
  local db = require("colorbox.db")
  local filter = require("colorbox.filter")
  local builtin_filter = require("colorbox.filter.builtin")
  colorbox.setup({
    debug = true,
    file_log = true,
  })

  describe("[builtin_filter]", function()
    it("primary", function()
      local ColorNameToColorSpecsMap = db.get_color_name_to_color_specs_map()
      local input_color = "tokyonight"
      local input_spec = ColorNameToColorSpecsMap[input_color]
      for _, c in ipairs(input_spec.color_names) do
        local actual = builtin_filter.primary(c, input_spec)
        print(
          string.format(
            "input color:%s, current color:%s, actual:%s\n",
            vim.inspect(input_color),
            vim.inspect(c),
            vim.inspect(actual)
          )
        )
        assert_eq(actual, input_color == c)
      end
    end)
  end)
  describe("filter", function()
    it("run", function()
      local ColorNameToColorSpecsMap = db.get_color_name_to_color_specs_map()
      for color, spec in pairs(ColorNameToColorSpecsMap) do
        local actual = filter.run(color, spec)
        assert_eq(type(actual), "boolean")
      end
    end)
    it("_builtin_filter", function()
      local ColorNameToColorSpecsMap = db.get_color_name_to_color_specs_map()
      for color, spec in pairs(ColorNameToColorSpecsMap) do
        local actual = filter.builtin("primary", color, spec)
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
