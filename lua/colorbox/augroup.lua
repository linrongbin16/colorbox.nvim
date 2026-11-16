--- The single autocmd group every colorbox autocmd lives in.
---
--- `setup()` can run more than once in a session (`:Lazy reload`, a `config`
--- function that is evaluated twice, a user calling it from a `VimEnter` hook).
--- Creating autocmds outside a group stacks one more handler per call, so a single
--- `:colorscheme` then runs the per-handle setup and `post_hook` that many times.
--- Keeping them in one group and clearing it on every `setup()` makes the call
--- idempotent.
---
--- The name comes from the `augroup` option, whose default and validation live in
--- `colorbox.configs`, so that users who need to keep several configurations apart
--- can give each one its own group.
local configs = require("colorbox.configs")

local M = {}

--- Name of the group the previous `reset` created, so that renaming the option does
--- not leave the old handlers behind. It is either `nil` or the configured name at
--- the time of that call.
--- @type string?
local last_name = nil

--- The configured group name. `colorbox.configs` always leaves this as a non-empty
--- string: the default comes from `Defaults` and `validate` rejects anything else.
--- Callers run after `colorbox.setup` has called `configs.setup`, which is what
--- fills the option in.
--- @return string
M.name = function()
  return configs.get().augroup
end

--- Create the group, dropping everything previously attached to it.
---
--- Only `setup()` should call this: it removes the handlers the earlier run added.
--- When the option named a different group last time, that one is emptied too, or
--- its handlers would keep firing next to the new ones.
--- @return integer
M.reset = function()
  local name = M.name()
  if last_name ~= nil and last_name ~= name then
    vim.api.nvim_create_augroup(last_name, { clear = true })
  end
  last_name = name
  return vim.api.nvim_create_augroup(name, { clear = true })
end

--- The group, creating it if `reset` has not run yet. Never clears.
--- @return integer
M.get = function()
  return vim.api.nvim_create_augroup(M.name(), { clear = false })
end

return M
