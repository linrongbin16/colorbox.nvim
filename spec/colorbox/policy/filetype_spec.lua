local cwd = vim.fn.getcwd()

describe("colorbox.policy.filetype", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local filetype_policy = require("colorbox.policy.filetype")
  local configs = require("colorbox.configs")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("[filetype_policy]", function()
    it("is_filetype_policy", function()
      local input1 = {
        mapping = {
          lua = "solarized",
        },
        empty = "default",
        fallback = "tokyonight",
      }
      local actual1 = filetype_policy.is_filetype_policy(input1)
      assert_true(actual1)
      local input2 = {
        mapping = {
          lua = "solarized",
        },
      }
      local actual2 = filetype_policy.is_filetype_policy(input2)
      assert_true(actual2)
      local input3 = {
        empty = "default",
        fallback = "tokyonight",
      }
      local actual3 = filetype_policy.is_filetype_policy(input3)
      assert_false(actual3)
    end)
    it("run", function()
      local ok1, err1 = pcall(filetype_policy.run)
      assert_false(ok1)
      print(string.format("run err1:%s\n", vim.inspect(err1)))

      local confs = configs.get()
      confs.policy = {
        mapping = {
          lua = "solarized",
        },
        empty = "default",
        fallback = "tokyonight",
      }
      configs.set(confs)

      local ok2, err2 = pcall(filetype_policy.run)
      assert_true(ok2)
      print(string.format("run err2:%s\n", vim.inspect(err2)))
    end)
  end)
end)
