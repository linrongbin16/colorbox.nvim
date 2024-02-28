local cwd = vim.fn.getcwd()

describe("colorbox", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local github_actions = os.getenv("GITHUB_ACTIONS") == "true"
  local colorbox = require("colorbox")
  local db = require("colorbox.db")
  describe("setup", function()
    it("setup", function()
      colorbox.setup({
        debug = true,
        file_log = true,
      })
    end)
  end)
end)
