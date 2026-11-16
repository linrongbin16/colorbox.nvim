local cwd = vim.uv.cwd()

describe("colorbox.timing", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local timing = require("colorbox.timing")
  local configs = require("colorbox.configs")
  local augroup = require("colorbox.augroup")
  local policy = require("colorbox.policy")

  local opts = {
    debug = true,
    file_log = true,
  }
  require("colorbox").setup(opts)

  --- How many autocmds of `event` belong to colorbox.
  --- @param event string
  --- @return integer
  local function count(event)
    return #vim.api.nvim_get_autocmds({ event = event, group = augroup.name() })
  end

  --- Collect the messages `log.err` receives while `fn` runs.
  --- @param fn fun()
  --- @return string[]
  local function capture_errors(fn)
    local log = require("colorbox.log")
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

  describe("[timing]", function()
    it("startup", function()
      -- The `setup` above already created one, so count what this call adds.
      local before = count("VimEnter")
      timing.startup()
      assert_eq(count("VimEnter"), before + 1)
    end)
    it("filetype", function()
      local events = { "BufEnter", "FocusGained", "WinEnter", "TermEnter" }
      local before = {}
      for _, event in ipairs(events) do
        before[event] = count(event)
      end
      timing.filetype()
      for _, event in ipairs(events) do
        assert_eq(count(event), before[event] + 1, event)
      end
    end)
    it("fixed_interval", function()
      local confs = configs.get()
      local timing_original, policy_original = confs.timing, confs.policy
      confs.timing = "interval"
      confs.policy = { seconds = 1, implement = "shuffle" }
      configs.set(confs)
      --- The interval policy re-schedules itself, so the test only checks that the
      --- first run went through.
      local run = policy.run
      local runs = 0
      policy.run = function()
        runs = runs + 1
      end
      local ok, err = pcall(timing.fixed_interval)
      policy.run = run
      confs.timing, confs.policy = timing_original, policy_original
      configs.set(confs)
      if not ok then
        error(err, 0)
      end
      assert_eq(runs, 1)
    end)
  end)

  --- Run `setup` with `timing` and `policy` on top of the options above, then let
  --- the next test start from them again.
  --- @param extra colorbox.Options
  local function setup_with(extra)
    require("colorbox").setup(vim.tbl_extend("force", opts, extra))
  end

  describe("[setup]", function()
    it("creates the autocmds of the configured timing", function()
      setup_with({ timing = "filetype", policy = { mapping = { lua = "solarized8" } } })
      assert_eq(count("BufEnter"), 1)
      assert_eq(count("VimEnter"), 0)

      setup_with({ timing = "startup", policy = "shuffle" })
      assert_eq(count("VimEnter"), 1)
      assert_eq(count("BufEnter"), 0)
    end)
    it("reports an unsupported timing and policy pair once, then sets up nothing", function()
      local msgs = capture_errors(function()
        setup_with({ timing = "startup", policy = { mapping = { lua = "solarized8" } } })
      end)
      assert_eq(#msgs, 1)
      assert_true(msgs[1]:find("not supported", 1, true) ~= nil)
      -- An autocmd firing the same broken pair on every buffer enter would repeat
      -- the notification forever.
      assert_eq(#capture_errors(timing.setup), 0)
      assert_eq(count("VimEnter"), 0)
      assert_eq(count("BufEnter"), 0)

      setup_with({})
    end)
    it("reports a removed timing with a pointer to its replacement", function()
      local msgs = capture_errors(function()
        setup_with({ timing = "bufferchanged", policy = "shuffle" })
      end)
      assert_eq(#msgs, 1)
      assert_true(msgs[1]:find("'filetype'", 1, true) ~= nil)
      assert_eq(count("BufEnter"), 0)

      setup_with({})
    end)
    it("sets up the configured timing", function()
      setup_with({ timing = "startup", policy = "single" })
      assert_eq(count("VimEnter"), 1)
      setup_with({})
    end)
  end)
end)
