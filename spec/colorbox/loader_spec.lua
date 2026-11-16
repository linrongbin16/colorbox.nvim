local cwd = vim.uv.cwd()

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
  local db = require("colorbox.db")
  require("colorbox").setup({
    debug = true,
    file_log = true,
    background = "dark",
  })

  local disabled_colorspecs = { ["zenbones-theme/zenbones.nvim"] = true }

  describe("[re-entrancy]", function()
    -- Probing re-entrancy needs a colorscheme that can actually be applied, and
    -- `pack/` is gitignored so CI has none installed. The first one that loads
    -- without error here is used; a colorscheme that this Neovim refuses (an old
    -- `ctermul` in its own `colors/*.vim`, say) is skipped instead of failing the
    -- test, because that is not what these tests are about.
    local loadable_color
    --- @return string?
    local function any_loadable_color()
      if loadable_color ~= nil then
        return loadable_color
      end
      for _, color_name in ipairs(runtime.color_names()) do
        -- `load()` reports a colorscheme it could not apply through its return
        -- value, and never raises.
        if loader.load(color_name) then
          loadable_color = color_name
          return color_name
        end
      end
      return nil
    end

    --- Count how deep `loader.load` re-enters itself.
    --- @param color_name string
    --- @param execute boolean?
    --- @return integer
    local function max_depth_of_load(color_name, execute)
      local depth, max_depth = 0, 0
      local original = loader.load
      loader.load = function(c, e)
        depth = depth + 1
        max_depth = math.max(max_depth, depth)
        local ok, err = pcall(original, c, e)
        depth = depth - 1
        if not ok then
          error(err, 0)
        end
      end
      local ok, err = pcall(loader.load, color_name, execute)
      loader.load = original
      if not ok then
        error(err, 0)
      end
      return max_depth
    end

    --- Let scheduled work from earlier tests finish.
    ---
    --- `loader.load` saves the track asynchronously and that write runs `post_hook`
    --- when it completes. A test that installs its own hook must drain the previous
    --- test's writes first, or their hooks land in the new counter.
    local function drain_scheduled_work()
      vim.wait(1000, function()
        return false
      end)
    end

    it("load does not re-enter itself through the colorscheme events", function()
      local color_name = any_loadable_color()
      if color_name == nil then
        return
      end
      assert_eq(max_depth_of_load(color_name), 1)
      assert_false(loader.loading())
      drain_scheduled_work()
    end)

    it("load runs the per-handle setup and the post hook once", function()
      local color_name = any_loadable_color()
      if color_name == nil then
        return
      end

      drain_scheduled_work()
      local confs = require("colorbox.configs")
      local spec = db.get_specs_by_color_name()[color_name]
      local setup_calls, hooks = 0, {}
      local original_setup, original_post_hook = confs.get().setup, confs.get().post_hook
      confs.get().setup = {
        [spec.handle] = function()
          setup_calls = setup_calls + 1
        end,
      }
      confs.get().post_hook = function(name)
        table.insert(hooks, name)
      end
      local ok, err = pcall(function()
        loader.load(color_name)
        -- Drain the scheduled work instead of stopping at the first hook: the
        -- duplicate this test guards against arrives as a second scheduled write.
        drain_scheduled_work()
      end)
      confs.get().setup = original_setup
      confs.get().post_hook = original_post_hook
      if not ok then
        error(err, 0)
      end

      assert_eq(setup_calls, 1)
      assert_eq(#hooks, 1)
      assert_eq(hooks[1], color_name)
    end)

    it("load resets the guard after a failed setup", function()
      local color_name = any_loadable_color()
      if color_name == nil then
        return
      end

      local confs = require("colorbox.configs")
      local spec = db.get_specs_by_color_name()[color_name]
      local original_setup = confs.get().setup
      confs.get().setup = {
        [spec.handle] = function()
          error("setup failed on purpose")
        end,
      }
      local ok = loader.load(color_name)
      confs.get().setup = original_setup

      assert_false(ok)
      -- A stuck guard would silently skip every load for the rest of the session.
      assert_false(loader.loading())
      assert_eq(max_depth_of_load(color_name), 1)
    end)
  end)

  describe("loader", function()
    it("load", function()
      local specs_by_color_name = db.get_specs_by_color_name()

      if not github_actions then
        local color_names = runtime.color_names()
        local color_indexes = runtime.color_indexes()
        print(
          string.format(
            "color_names:%s, color_indexes:%s",
            vim.inspect(color_names),
            vim.inspect(color_indexes)
          )
        )
        for i, c in ipairs(color_names) do
          local spec = specs_by_color_name[c]
          if not disabled_colorspecs[spec.handle] then
            print(string.format("color:%s, spec:%s", vim.inspect(c), vim.inspect(spec)))
            loader.load(c)
          end
        end
      end
    end)
  end)
end)
