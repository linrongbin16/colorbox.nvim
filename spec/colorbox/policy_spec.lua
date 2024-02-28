local cwd = vim.fn.getcwd()

describe("policy", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local strings = require("colorbox.commons.strings")
  local policy = require("colorbox.policy")
  local configs = require("colorbox.configs")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  describe("[builtin_policy]", function()
    it("builtin shuffle", function()
      local confs = configs.get()
      confs.timing = "startup"
      confs.policy = "shuffle"
      configs.set(confs)
      local ok, err = pcall(policy.run)
      assert_true(ok)
    end)
    it("builtin in_order", function()
      local confs = configs.get()
      confs.timing = "startup"
      confs.policy = "in_order"
      configs.set(confs)
      local ok, err = pcall(policy.run)
      assert_true(ok)
    end)
    it("builtin reverse_order", function()
      local confs = configs.get()
      confs.timing = "startup"
      confs.policy = "reverse_order"
      configs.set(confs)
      local ok, err = pcall(policy.run)
      assert_true(ok)
    end)
    it("builtin single", function()
      local confs = configs.get()
      confs.timing = "startup"
      confs.policy = "single"
      configs.set(confs)
      local ok, err = pcall(policy.run)
      assert_true(ok)
    end)
    it("fixed interval", function()
      local confs = configs.get()
      confs.timing = "interval"
      confs.policy = { seconds = 1, implement = "shuffle" }
      configs.set(confs)
      local ok, err = pcall(policy.run)
      assert_true(ok)
    end)
    it("filetype", function()
      local confs = configs.get()
      confs.timing = "filetype"
      confs.policy = { mapping = { lua = "solarized8" } }
      configs.set(confs)
      local ok, err = pcall(policy.run)
      assert_true(ok)
    end)
  end)
end)
