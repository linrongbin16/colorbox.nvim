local cwd = vim.uv.cwd()

describe("colorbox.policy", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false
  local assert_truthy = assert.is_truthy

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local policy = require("colorbox.policy")
  local configs = require("colorbox.configs")
  local log = require("colorbox.log")
  local builtin_policy = require("colorbox.policy.builtin")
  local fixed_interval_policy = require("colorbox.policy.fixed_interval")
  local filetype_policy = require("colorbox.policy.filetype")

  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  --- One policy of each kind, keyed by `colorbox.PolicyKind`.
  --- @type table<string, colorbox.PolicyConfig>
  local policies = {
    builtin = "shuffle",
    fixed_interval = { seconds = 1, implement = "shuffle" },
    filetype = { mapping = { lua = "solarized8" } },
  }

  --- The policy kind each timing drives, i.e. the supported combinations.
  --- @type table<string, colorbox.PolicyKind>
  local accepted = {
    startup = "builtin",
    interval = "fixed_interval",
    filetype = "filetype",
  }

  --- Restore a `timing`/`policy` pair for the tests that replace it.
  local function restore_confs(timing, po)
    local confs = configs.get()
    confs.timing = timing
    confs.policy = po
    configs.set(confs)
  end

  describe("[kind]", function()
    it("recognizes every builtin policy", function()
      for _, name in ipairs(builtin_policy.names()) do
        assert_true(builtin_policy.is_builtin_policy(name))
        assert_eq(policy.kind(name), "builtin")
      end
    end)
    it("recognizes the policy tables", function()
      assert_eq(policy.kind(policies.fixed_interval), "fixed_interval")
      assert_eq(policy.kind(policies.filetype), "filetype")
    end)
    it("returns nil for a value that is not a policy", function()
      assert_eq(policy.kind(nil), nil)
      assert_eq(policy.kind(42), nil)
      assert_eq(policy.kind("no_such_policy"), nil)
      assert_eq(policy.kind({}), nil)
      assert_eq(policy.kind({ seconds = 0, implement = "shuffle" }), nil)
      assert_eq(policy.kind({ mapping = "not-a-table" }), nil)
    end)
  end)

  describe("[validate]", function()
    it("accepts the three documented pairs", function()
      for timing, kind in pairs(accepted) do
        local ok, msg = policy.validate({ timing = timing, policy = policies[kind] })
        assert(ok, string.format("timing=%s kind=%s: %s", timing, kind, tostring(msg)))
      end
    end)
    it("accepts every builtin policy with the startup timing", function()
      for _, name in ipairs(builtin_policy.names()) do
        local ok, msg = policy.validate({ timing = "startup", policy = name })
        assert(ok, string.format("policy=%s: %s", name, tostring(msg)))
      end
    end)
    it("rejects the six other pairs, naming both options", function()
      for timing, expects in pairs(accepted) do
        for kind, po in pairs(policies) do
          if kind ~= expects then
            local ok, msg = policy.validate({ timing = timing, policy = po })
            assert_false(ok)
            assert_truthy(msg)
            -- The message must point at both options, the old one blamed the wrong
            -- timing and left the user guessing which of the two was wrong.
            assert_truthy(msg:find("'policy'", 1, true))
            assert_truthy(msg:find("'timing'", 1, true))
            assert_truthy(msg:find(vim.inspect(timing), 1, true))
            assert_truthy(msg:find("not supported", 1, true))
          end
        end
      end
    end)
    it("rejects an unknown timing", function()
      local ok, msg = policy.validate({ timing = "always", policy = "shuffle" })
      assert_false(ok)
      assert_truthy(msg)
      assert_truthy(msg:find("startup, interval, filetype", 1, true))
    end)
    it("explains that the bufferchanged timing was renamed", function()
      local ok, msg = policy.validate({ timing = "bufferchanged", policy = "shuffle" })
      assert_false(ok)
      assert_truthy(msg)
      assert_truthy(msg:find("'filetype'", 1, true))
    end)
    it("rejects a policy that is none of the three kinds", function()
      -- `nil` cannot live in a list literal without truncating it, so it is its
      -- own case below.
      for _, po in ipairs({ 42, "no_such_policy", {}, { mapping = "not-a-table" } }) do
        local ok, msg = policy.validate({ timing = "startup", policy = po })
        assert_false(ok)
        assert_truthy(msg)
        assert_truthy(msg:find("invalid 'policy'", 1, true))
      end
      local ok, msg = policy.validate({ timing = "startup" })
      assert_false(ok)
      assert_truthy(msg)
      assert_truthy(msg:find("invalid 'policy'", 1, true))
    end)
    it("defaults to the current configuration", function()
      restore_confs("startup", "single")
      local ok = policy.validate()
      assert_true(ok)
      restore_confs("startup", policies.filetype)
      ok = policy.validate()
      assert_false(ok)
      restore_confs("startup", "shuffle")
    end)
  end)

  describe("[run]", function()
    --- Replace every policy entry point with a counter, so a test can tell which
    --- one `run` dispatched without loading a colorscheme.
    --- @return table<string, integer> calls
    --- @return fun() restore
    local function stub_policies()
      local calls = { builtin = 0, fixed_interval = 0, filetype = 0 }
      local builtin_originals = {}
      for _, name in ipairs(builtin_policy.names()) do
        builtin_originals[name] = builtin_policy[name]
        builtin_policy[name] = function()
          calls.builtin = calls.builtin + 1
        end
      end
      local fixed_interval_run = fixed_interval_policy.run
      fixed_interval_policy.run = function()
        calls.fixed_interval = calls.fixed_interval + 1
      end
      local filetype_run = filetype_policy.run
      filetype_policy.run = function()
        calls.filetype = calls.filetype + 1
      end
      local function restore()
        for _, name in ipairs(builtin_policy.names()) do
          builtin_policy[name] = builtin_originals[name]
        end
        fixed_interval_policy.run = fixed_interval_run
        filetype_policy.run = filetype_run
      end
      return calls, restore
    end

    --- Collect the messages `log.err` receives while `fn` runs.
    --- @param fn fun()
    --- @return string[]
    local function capture_errors(fn)
      local msgs = {}
      local err = log.err
      log.err = function(msg)
        table.insert(msgs, msg)
      end
      local ok, e = pcall(fn)
      log.err = err
      if not ok then
        error(e, 0)
      end
      return msgs
    end

    it("dispatches the policy that matches the timing", function()
      local timing, po = configs.get().timing, configs.get().policy
      for want, kind in pairs(accepted) do
        restore_confs(want, policies[kind])
        local calls, restore = stub_policies()
        local ok, err = pcall(policy.run)
        restore()
        if not ok then
          error(err, 0)
        end
        for other, n in pairs(calls) do
          assert_eq(n, other == kind and 1 or 0, string.format("timing=%s ran %s", want, other))
        end
      end
      restore_confs(timing, po)
    end)
    it("runs nothing and reports an unsupported pair", function()
      local timing, po = configs.get().timing, configs.get().policy
      restore_confs("startup", policies.filetype)
      local calls, restore = stub_policies()
      local msgs = capture_errors(policy.run)
      restore()
      assert_eq(calls.builtin + calls.fixed_interval + calls.filetype, 0)
      assert_eq(#msgs, 1)
      assert_truthy(msgs[1]:find("not supported", 1, true))
      restore_confs(timing, po)
    end)
    it("reports an invalid pair once per pair", function()
      local timing, po = configs.get().timing, configs.get().policy
      restore_confs("interval", "single")
      local first = capture_errors(policy.run)
      assert_eq(#first, 1)
      -- An autocmd calls `run` on every buffer enter, the same complaint must not
      -- be repeated forever.
      assert_eq(#capture_errors(policy.run), 0)
      -- A different invalid pair is a different complaint, it still gets through.
      restore_confs("interval", "in_order")
      assert_eq(#capture_errors(policy.run), 1)
      restore_confs(timing, po)
    end)
  end)
end)
