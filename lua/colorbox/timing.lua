local configs = require("colorbox.configs")
local policy = require("colorbox.policy")
local augroup = require("colorbox.augroup")

local M = {}

M.startup = function()
  vim.api.nvim_create_autocmd({ "VimEnter" }, {
    group = augroup.get(),
    callback = policy.run,
  })
end

M.filetype = function()
  vim.api.nvim_create_autocmd({
    "BufEnter",
    "FocusGained",
    "WinEnter",
    "TermEnter",
  }, {
    group = augroup.get(),
    callback = policy.run,
  })
end

M.fixed_interval = function()
  policy.run()
end

M.setup = function()
  local confs = configs.get()

  -- A `timing`/`policy` pair that cannot work together is reported here, while
  -- Neovim starts, rather than skipped silently or reported from an autocmd that
  -- would then keep firing.
  local ok, msg = policy.validate(confs)
  if not ok then
    policy.report(msg --[[@as string]])
    return
  end

  if confs.timing == "startup" then
    M.startup()
  elseif confs.timing == "interval" then
    M.fixed_interval()
  else
    -- `validate` above only lets the documented timings through.
    M.filetype()
  end
end

return M
