local cwd = vim.uv.cwd()

describe("colorbox.filter", function()
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
    it("run default (no filter)", function()
      local confs = require("colorbox.configs").setup({
        debug = true,
        file_log = true,
      })
      assert_eq(confs.filter, nil)
      local specs_by_color_name = db.get_specs_by_color_name()
      for color, spec in pairs(specs_by_color_name) do
        local actual = filter.run(color, spec)
        assert_eq(type(actual), "boolean")
        assert_true(actual)
      end
    end)
    it("a false filter is treated like any other invalid value", function()
      local confs = require("colorbox.configs").setup({
        debug = true,
        file_log = true,
        filter = false,
      })
      assert_eq(confs.filter, nil)
      local specs_by_color_name = db.get_specs_by_color_name()
      for color, spec in pairs(specs_by_color_name) do
        assert_true(filter.run(color, spec))
      end
    end)
    it("invalid filter is warned and ignored", function()
      local confs = require("colorbox.configs").setup({
        debug = true,
        file_log = true,
        filter = "primary",
      })
      assert_eq(confs.filter, nil)
      local specs_by_color_name = db.get_specs_by_color_name()
      for color, spec in pairs(specs_by_color_name) do
        assert_true(filter.run(color, spec))
      end
    end)
    it("run list filter", function()
      require("colorbox").setup({
        debug = true,
        file_log = true,
        filter = {
          function(color)
            return color ~= "ayu"
          end,
          function(color)
            return color ~= "edge"
          end,
        },
      })
      local specs_by_color_name = db.get_specs_by_color_name()
      for color, spec in pairs(specs_by_color_name) do
        local actual = filter.run(color, spec)
        assert_eq(type(actual), "boolean")
        assert_eq(actual, color ~= "ayu" and color ~= "edge")
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
      local specs_by_color_name = db.get_specs_by_color_name()
      for color, spec in pairs(specs_by_color_name) do
        local actual = filter.run(color, spec)
        assert_eq(type(actual), "boolean")
        assert_eq(actual, i >= 5)
        i = i + 1
      end
    end)
    it("_function_filter", function()
      local specs_by_color_name = db.get_specs_by_color_name()
      for color, spec in pairs(specs_by_color_name) do
        local actual = filter._function_filter(function(c, s)
          return true
        end, color, spec)
        assert_eq(type(actual), "boolean")
        assert_true(actual)
      end
      for color, spec in pairs(specs_by_color_name) do
        local actual = filter._function_filter(function(c, s)
          return false
        end, color, spec)
        assert_eq(type(actual), "boolean")
        assert_false(actual)
      end
    end)
    it("_all_filter", function()
      local specs_by_color_name = db.get_specs_by_color_name()
      for color, spec in pairs(specs_by_color_name) do
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
      for color, spec in pairs(specs_by_color_name) do
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
