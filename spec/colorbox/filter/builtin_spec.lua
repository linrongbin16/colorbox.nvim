local cwd = vim.fn.getcwd()

describe("colorbox.filter.builtin", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local db = require("colorbox.db")
  local builtin_filter = require("colorbox.filter.builtin")
  require("colorbox").setup({
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
    it("_minimal_color_name_len", function()
      local ColorNameToColorSpecsMap = db.get_color_name_to_color_specs_map()
      for _, spec in pairs(ColorNameToColorSpecsMap) do
        local actual = builtin_filter._minimal_color_name_len(spec)
        assert_eq(type(actual), "number")
        assert_true(actual > 0)
      end
    end)
    it("_primary_score", function()
      local ColorNameToColorSpecsMap = db.get_color_name_to_color_specs_map()
      for _, spec in pairs(ColorNameToColorSpecsMap) do
        for i, color in ipairs(spec.color_names) do
          local actual = builtin_filter._primary_score(color, spec)
          assert_eq(type(actual), "number")
          assert_true(actual >= 0)
        end
      end
    end)
  end)
end)
