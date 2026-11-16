local cwd = vim.uv.cwd()

describe("colorbox.policy.fixed_interval", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local fixed_interval_policy = require("colorbox.policy.fixed_interval")
  local builtin_policy = require("colorbox.policy.builtin")
  local configs = require("colorbox.configs")
  local log = require("colorbox.log")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  local base_timing, base_policy = configs.get().timing, configs.get().policy

  --- The interval used by the tests. The shortest documented one, so a test that
  --- waits for the next tick stays short.
  local Seconds = 1

  local original_implement, original_implement_name
  local original_err

  --- Make `timing = "interval"` drive `implement`, and replace it with `fn`.
  --- @param implement colorbox.BuiltinPolicyConfig
  --- @param fn fun()
  local function install_policy(implement, fn)
    local confs = configs.get()
    confs.timing = "interval"
    confs.policy = { seconds = Seconds, implement = implement }
    configs.set(confs)

    if original_implement_name == nil then
      original_implement_name = implement
      original_implement = builtin_policy[implement]
    end
    builtin_policy[implement] = fn
  end

  --- Collect the messages `log.err` receives, for as long as the returned table
  --- lives (a chain reports from a timer, i.e. after `install_policy` returned).
  --- @return string[] msgs
  --- @return fun() restore
  local function capture_errors()
    local msgs = {}
    original_err = original_err or log.err
    log.err = function(msg)
      table.insert(msgs, msg)
    end
    return msgs, function()
      log.err = original_err
      original_err = nil
    end
  end

  --- @param timeout integer
  --- @param cond fun(): boolean
  --- @return boolean
  local function wait_for(timeout, cond)
    return vim.wait(timeout, cond, 20) == true
  end

  after_each(function()
    -- Never leave a chain ticking into the next test.
    fixed_interval_policy.stop()
    if original_implement_name ~= nil then
      builtin_policy[original_implement_name] = original_implement
      original_implement_name, original_implement = nil, nil
    end
    if original_err ~= nil then
      log.err = original_err
      original_err = nil
    end
    local confs = configs.get()
    confs.timing = base_timing
    confs.policy = base_policy
    configs.set(confs)
  end)

  describe("[fixed_interval_policy]", function()
    it("is_fixed_interval_policy", function()
      local input1 = {
        seconds = 1,
        implement = "shuffle",
      }
      local actual1 = fixed_interval_policy.is_fixed_interval_policy(input1)
      assert_true(actual1)
      local input2 = {
        seconds = "1",
        implement = nil,
      }
      local actual2 = fixed_interval_policy.is_fixed_interval_policy(input2)
      assert_false(actual2)
    end)

    it("run rejects a policy that is not a fixed interval one", function()
      -- The `setup()` above installs the default `startup`/`shuffle` pair, which
      -- `interval` cannot drive.
      local ok, err = pcall(fixed_interval_policy.run)
      print(string.format("run err:%s\n", vim.inspect(err)))
      assert_false(ok)
      assert_true(tostring(err):find("invalid policy", 1, true) ~= nil)
    end)

    it("run does not raise when the first tick fails", function()
      install_policy("shuffle", function()
        error("colorscheme exploded")
      end)
      local msgs, restore = capture_errors()

      -- The first tick runs synchronously from `run`, i.e. from `setup()`: a
      -- colorscheme that raises there must not take the caller down with it.
      local ok, err = pcall(fixed_interval_policy.run)
      fixed_interval_policy.stop()
      restore()

      print(string.format("run ok:%s, err:%s\n", vim.inspect(ok), vim.inspect(err)))
      assert_true(ok)
      assert_eq(#msgs, 1)
      assert_true(msgs[1]:find("failed to run policy", 1, true) ~= nil)
      assert_true(msgs[1]:find("colorscheme exploded", 1, true) ~= nil)
    end)

    it("keeps ticking after a failed tick", function()
      local calls = 0
      install_policy("shuffle", function()
        calls = calls + 1
        if calls == 1 then
          error("colorscheme exploded")
        end
      end)
      local msgs, restore = capture_errors()

      fixed_interval_policy.run()
      -- The chain must schedule the next tick even though the first one raised.
      local ticked = wait_for(Seconds * 1000 * 3, function()
        return calls >= 2
      end)
      fixed_interval_policy.stop()
      restore()

      print(string.format("calls:%d, msgs:%s\n", calls, vim.inspect(msgs)))
      assert_true(ticked)
      assert_eq(calls, 2)
      assert_eq(#msgs, 1)
    end)

    it("reports a repeated failure once", function()
      local calls = 0
      install_policy("shuffle", function()
        calls = calls + 1
        error("colorscheme exploded")
      end)
      local msgs, restore = capture_errors()

      fixed_interval_policy.run()
      local ticked = wait_for(Seconds * 1000 * 3, function()
        return calls >= 3
      end)
      fixed_interval_policy.stop()
      restore()

      print(string.format("calls:%d, msgs:%s\n", calls, vim.inspect(msgs)))
      assert_true(ticked)
      -- Two failures on two ticks, one notification: a broken colorscheme must not
      -- notify on every `policy.seconds`.
      assert_eq(#msgs, 1)
    end)

    it("stop cancels the scheduled tick", function()
      local calls = 0
      install_policy("shuffle", function()
        calls = calls + 1
      end)

      fixed_interval_policy.run()
      assert_eq(calls, 1)
      fixed_interval_policy.stop()

      local ticked = wait_for(Seconds * 1000 * 2, function()
        return calls > 1
      end)
      print(string.format("calls:%d\n", calls))
      assert_false(ticked)
      assert_eq(calls, 1)
    end)

    it("stop is idempotent", function()
      fixed_interval_policy.stop()
      fixed_interval_policy.stop()
      assert_true(true)
    end)

    it("run replaces the previous chain", function()
      local calls = 0
      install_policy("shuffle", function()
        calls = calls + 1
      end)

      fixed_interval_policy.run()
      -- A `setup()` re-run installs a new chain; the previous one must be gone, or
      -- the colorscheme changes twice as often as configured.
      fixed_interval_policy.run()
      assert_eq(calls, 2)

      local ticked = wait_for(Seconds * 1000 * 3, function()
        return calls >= 3
      end)
      fixed_interval_policy.stop()

      print(string.format("calls:%d\n", calls))
      assert_true(ticked)
      -- The two synchronous ticks above, plus one from the surviving chain.
      assert_eq(calls, 3)
    end)
  end)
end)
