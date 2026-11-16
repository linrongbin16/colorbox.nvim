local cwd = vim.uv.cwd()

describe("colorbox.configs", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local configs = require("colorbox.configs")
  local log = require("colorbox.log")

  describe("[setup]", function()
    it("applies logging options", function()
      configs.setup({
        debug = true,
        console_log = false,
        file_log = true,
      })
      local log_configs = log.get()
      assert_eq(log_configs.level, vim.log.levels.DEBUG)
      assert_eq(log_configs.use_console, false)
      assert_eq(log_configs.use_file, true)

      configs.setup({
        debug = false,
        console_log = true,
        file_log = false,
      })
      log_configs = log.get()
      assert_eq(log_configs.level, vim.log.levels.INFO)
      assert_eq(log_configs.use_console, true)
      assert_eq(log_configs.use_file, false)
    end)
    it("defaults to nil filter, i.e. all colors enabled", function()
      local confs = configs.setup()
      assert_eq(confs.filter, nil)
    end)
    it("normalizes the legacy false filter to nil", function()
      local confs = configs.setup({ filter = false })
      assert_eq(confs.filter, nil)
    end)
    it("ignores an invalid filter", function()
      local confs = configs.setup({ filter = "primary" })
      assert_eq(confs.filter, nil)
    end)
    it("keeps function and list filters", function()
      local f = function()
        return true
      end
      assert_eq(configs.setup({ filter = f }).filter, f)

      local list = { f }
      local confs = configs.setup({ filter = list })
      assert_eq(type(confs.filter), "table")
      assert_eq(#confs.filter, 1)
      assert_true(confs.filter[1] == f)
    end)
  end)
end)
