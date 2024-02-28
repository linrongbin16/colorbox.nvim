local cwd = vim.fn.getcwd()

describe("colorbox.policy", function()
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
      print(string.format("builtin shuffle err:%s\n", vim.inspect(err)))
    end)
    it("builtin in_order", function()
      local confs = configs.get()
      confs.timing = "startup"
      confs.policy = "in_order"
      configs.set(confs)
      local ok, err = pcall(policy.run)
      print(string.format("builtin in_order err:%s\n", vim.inspect(err)))
    end)
    it("builtin reverse_order", function()
      local confs = configs.get()
      confs.timing = "startup"
      confs.policy = "reverse_order"
      configs.set(confs)
      local ok, err = pcall(policy.run)
      print(string.format("builtin reverse_order err:%s\n", vim.inspect(err)))
    end)
    it("builtin single", function()
      local confs = configs.get()
      confs.timing = "startup"
      confs.policy = "single"
      configs.set(confs)
      local ok, err = pcall(policy.run)
      print(string.format("builtin single err:%s\n", vim.inspect(err)))
    end)
    it("fixed interval", function()
      local confs = configs.get()
      confs.timing = "interval"
      confs.policy = { seconds = 1, implement = "shuffle" }
      configs.set(confs)
      local ok, err = pcall(policy.run)
      print(string.format("builtin fixed interval err:%s\n", vim.inspect(err)))
    end)
    it("filetype", function()
      local confs = configs.get()
      confs.timing = "filetype"
      confs.policy = { mapping = { lua = "solarized8" } }
      configs.set(confs)
      local ok, err = pcall(policy.run)
      print(string.format("builtin filetype err:%s\n", vim.inspect(err)))
    end)
  end)
end)
