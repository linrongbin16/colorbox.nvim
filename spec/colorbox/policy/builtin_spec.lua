local cwd = vim.fn.getcwd()

describe("policy.builtin", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local builtin_policy = require("colorbox.policy.builtin")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("[builtin_policy]", function()
    it("shuffle", function()
      builtin_policy.shuffle()
    end)
    it("in_order", function()
      builtin_policy.in_order()
    end)
    it("reverse_order", function()
      builtin_policy.reverse_order()
    end)
    it("single", function()
      builtin_policy.single()
    end)
  end)
end)
