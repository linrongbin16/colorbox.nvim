local cwd = vim.fn.getcwd()

describe("colorbox.policy.builtin", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local str = require("colorbox.commons.str")
  local builtin_policy = require("colorbox.policy.builtin")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("[builtin_policy]", function()
    it("test", function()
      for k, fn in pairs(builtin_policy) do
        if not str.startswith(k, "_") and vim.is_callable(fn) then
          pcall(fn)
        end
      end
    end)
  end)
end)
