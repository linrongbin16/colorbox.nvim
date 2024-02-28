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
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("[util]", function()
    it("sync_syntax", function()
      util.sync_syntax()
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
