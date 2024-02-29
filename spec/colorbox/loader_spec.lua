local cwd = vim.fn.getcwd()

describe("colorbox.loader", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local github_actions = os.getenv("GITHUB_ACTIONS") == "true"
  local runtime = require("colorbox.runtime")
  local loader = require("colorbox.loader")
  require("colorbox").setup({
    debug = true,
    file_log = true,
    background = "dark",
  })

  describe("loader", function()
    it("load", function()
      -- if not github_actions then
      local colors = runtime.colornames()
      for i, c in ipairs(colors) do
        loader.load(c)
      end
      -- end
    end)
  end)
end)
