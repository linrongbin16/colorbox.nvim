local cwd = vim.uv.cwd()

describe("colorbox.setup", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local augroup = require("colorbox.augroup")
  local runtime = require("colorbox.runtime")
  local loader = require("colorbox.loader")

  local opts = {
    debug = true,
    file_log = true,
    background = "dark",
  }

  -- `setup()` itself runs at the top of most specs; this file calls it on purpose.
  require("colorbox").setup(opts)

  --- How many autocmds of `event` belong to colorbox.
  --- @param event string
  --- @return integer
  local function count(event)
    return #vim.api.nvim_get_autocmds({ event = event, group = augroup.name() })
  end

  --- Let scheduled work from earlier tests finish.
  local function drain_scheduled_work()
    vim.wait(1000, function()
      return false
    end)
  end

  describe("[idempotency]", function()
    it("repeated setup keeps one autocmd per event", function()
      require("colorbox").setup(opts)
      local scheme, scheme_pre, vim_enter =
        count("ColorScheme"), count("ColorSchemePre"), count("VimEnter")
      assert_eq(scheme, 1)

      require("colorbox").setup(opts)
      require("colorbox").setup(opts)
      assert_eq(count("ColorScheme"), scheme)
      assert_eq(count("ColorSchemePre"), scheme_pre)
      assert_eq(count("VimEnter"), vim_enter)
    end)

    it("repeated setup runs the post hook once per colorscheme", function()
      local color_name
      for _, c in ipairs(runtime.color_names()) do
        if pcall(loader.load, c) then
          color_name = c
          break
        end
      end
      if color_name == nil then
        -- `pack/` is gitignored, so CI has no colorscheme to apply.
        return
      end

      -- Two more setups on top of the one this file runs, so a stacked handler
      -- would call the hook twice. The hook is installed after them because
      -- `setup()` rebuilds the configuration from the defaults.
      require("colorbox").setup(opts)
      require("colorbox").setup(opts)
      drain_scheduled_work()

      local confs = require("colorbox.configs")
      local original_post_hook = confs.get().post_hook
      local hooks = {}
      confs.get().post_hook = function(name)
        table.insert(hooks, name)
      end

      local ok, err = pcall(function()
        vim.cmd("colorscheme " .. color_name)
        drain_scheduled_work()
      end)
      confs.get().post_hook = original_post_hook
      if not ok then
        error(err, 0)
      end

      assert_eq(#hooks, 1)
      assert_eq(hooks[1], color_name)
    end)

    it("setup honors a custom augroup name", function()
      require("colorbox").setup(vim.tbl_extend("force", opts, { augroup = "ColorboxCustom" }))
      assert_eq(#vim.api.nvim_get_autocmds({ event = "ColorScheme", group = "ColorboxCustom" }), 1)
      -- Renaming the option empties the group the previous setup used, or its
      -- handlers would keep firing next to the new ones.
      assert_eq(#vim.api.nvim_get_autocmds({ event = "ColorScheme", group = "Colorbox" }), 0)

      require("colorbox").setup(opts)
      assert_eq(#vim.api.nvim_get_autocmds({ event = "ColorScheme", group = "Colorbox" }), 1)
      assert_eq(#vim.api.nvim_get_autocmds({ event = "ColorScheme", group = "ColorboxCustom" }), 0)
    end)

    it("setup keeps the user command working", function()
      require("colorbox").setup(opts)
      require("colorbox").setup(opts)
      assert_eq(vim.fn.exists(":Colorbox"), 2)
      -- Recreating the command replaces its callback rather than stacking one.
      assert_true(vim.api.nvim_get_commands({ builtin = false }).Colorbox ~= nil)
    end)
  end)
end)
