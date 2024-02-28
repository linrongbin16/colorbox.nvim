local configs = require("colorbox.configs")
local policy = require("colorbox.policy")

local M = {}

M.startup = function()
  vim.api.nvim_create_autocmd({ "VimEnter" }, {
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
    callback = policy.run,
  })
end

M.fixed_interval = function()
  policy.run()
end

M.setup = function()
  local confs = configs.get()
  if confs.timing == "startup" then
    M.startup()
  elseif confs.timing == "interval" then
    M.fixed_interval()
  elseif confs.timing == "bufferchanged" or confs.timing == "filetype" then
    M.filetype()
  else
    error(string.format("invalid timing: %s!", vim.inspect(confs.timing)))
  end
end

return M
