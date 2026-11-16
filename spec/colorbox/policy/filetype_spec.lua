local cwd = vim.uv.cwd()

describe("colorbox.policy.filetype", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local filetype_policy = require("colorbox.policy.filetype")
  local loader = require("colorbox.loader")
  local configs = require("colorbox.configs")
  local log = require("colorbox.log")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  local base_policy = configs.get().policy
  local base_filetype = vim.bo.filetype
  local base_colors_name = vim.g.colors_name

  local original_load = loader.load
  local original_sync = require("colorbox.track").sync_syntax
  local loads = {}

  --- Configure the policy, keep the colorscheme `colors_name` as applied, and stop
  --- every load dead in its tracks so no real colorscheme is touched.
  --- @param policy colorbox.FiletypePolicyConfig
  --- @param colors_name string?
  local function install_policy(policy, colors_name)
    local confs = configs.get()
    confs.policy = policy
    configs.set(confs)
    vim.g.colors_name = colors_name
    loads = {}
    loader.load = function(color_name)
      table.insert(loads, color_name)
      return true
    end
    require("colorbox.track").sync_syntax = function() end
  end

  after_each(function()
    -- Nothing may stay queued into the next test.
    filetype_policy.stop()
    loader.load = original_load
    require("colorbox.track").sync_syntax = original_sync
    vim.bo.filetype = base_filetype
    vim.g.colors_name = base_colors_name
    local confs = configs.get()
    confs.policy = base_policy
    configs.set(confs)
  end)

  --- Wait for the debounce window to close.
  local function settle()
    vim.wait(200, function()
      return false
    end, 20)
  end

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

    it("run rejects a policy that is not a file type one", function()
      local ok = pcall(filetype_policy.run)
      assert_false(ok)
    end)

    it("collapses the events of one buffer switch into one load", function()
      install_policy({ mapping = { lua = "gruvbox" } }, "default")
      vim.bo.filetype = "lua"

      -- One buffer switch fires `BufEnter`, `WinEnter` and sometimes more; each of
      -- them used to schedule its own load.
      filetype_policy.run()
      filetype_policy.run()
      filetype_policy.run()
      assert_eq(#loads, 0)

      settle()
      assert_eq(#loads, 1)
      assert_eq(loads[1], "gruvbox")
    end)

    it("does not reload the colorscheme that is already applied", function()
      install_policy({ mapping = { lua = "gruvbox" } }, "gruvbox")
      vim.bo.filetype = "lua"

      filetype_policy.run()
      settle()

      assert_eq(#loads, 0)
    end)

    it("falls back to `empty`, then to `fallback`", function()
      install_policy({ mapping = { lua = "gruvbox" }, fallback = "tokyonight" }, "default")
      vim.bo.filetype = "python"
      filetype_policy.run()
      settle()
      assert_eq(#loads, 1)
      assert_eq(loads[1], "tokyonight")

      install_policy(
        { mapping = { lua = "gruvbox" }, empty = "default", fallback = "tokyonight" },
        "tokyonight"
      )
      vim.bo.filetype = ""
      filetype_policy.run()
      settle()
      assert_eq(#loads, 1)
      assert_eq(loads[1], "default")
    end)

    it("does nothing when the policy has nothing to say", function()
      install_policy({ mapping = { lua = "gruvbox" } }, "default")
      vim.bo.filetype = "python"

      filetype_policy.run()
      settle()

      assert_eq(#loads, 0)
    end)

    it("stop cancels the pending load", function()
      install_policy({ mapping = { lua = "gruvbox" } }, "default")
      vim.bo.filetype = "lua"

      filetype_policy.run()
      filetype_policy.stop()
      settle()

      assert_eq(#loads, 0)
    end)

    it("stop is idempotent", function()
      filetype_policy.stop()
      filetype_policy.stop()
      assert_true(true)
    end)
  end)
end)
