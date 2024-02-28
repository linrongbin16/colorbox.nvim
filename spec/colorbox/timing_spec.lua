local cwd = vim.fn.getcwd()

describe("colorbox.timing", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local timing = require("colorbox.timing")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("[timing]", function()
    it("startup", function()
      timing.startup()
    end)
    it("filetype", function()
      timing.filetype()
    end)
    it("fixed_interval", function()
      pcall(timing.fixed_interval)
    end)
    it("setup", function()
      timing.setup()
    end)
  end)
end)
