local log = require("colorbox.commons.log")
local str = require("colorbox.commons.str")

local configs = require("colorbox.configs")
local timing = require("colorbox.timing")
local track = require("colorbox.track")
local runtime = require("colorbox.runtime")
local controller = require("colorbox.controller")
local loader = require("colorbox.loader")

local uv = vim.uv or vim.loop

--- @param opts colorbox.Options?
local function setup(opts)
  local confs = configs.setup(opts)
  log.setup({
    name = "colorbox",
    level = confs.debug and vim.log.levels.DEBUG or vim.log.levels.INFO,
    use_console = confs.console_log,
    use_file = confs.file_log,
    file_name = "colorbox.log",
  })

  -- cache
  if not uv.fs_stat(confs.cache_dir) then
    vim.fn.mkdir(confs.cache_dir, "p")
  end
  assert(
    vim.fn.filereadable(confs.cache_dir) <= 0,
    string.format("%s (cache_dir option) already exist but not a directory!", confs.cache_dir)
  )
  confs.previous_track_cache = string.format("%s/previous_track_cache", confs.cache_dir)
  confs = configs.set(confs)

  runtime.setup()

  vim.api.nvim_create_user_command(confs.command.name, function(command_opts)
    -- logger.debug(
    --     "|colorbox.setup| command opts:%s",
    --     vim.inspect(command_opts)
    -- )
    local args = vim.trim(command_opts.args)
    local args_splits = vim.split(args, " ", { plain = true, trimempty = true })
    -- logger.debug(
    --     "|colorbox.setup| command args:%s, splits:%s",
    --     vim.inspect(args),
    --     vim.inspect(args_splits)
    -- )
    if #args_splits == 0 then
      log.warn("missing parameter.")
      return
    end
    if vim.is_callable(controller[args_splits[1]]) then
      local fn = controller[args_splits[1]]
      local sub_args = args:sub(string.len(args_splits[1]) + 1)
      fn(sub_args)
    else
      log.warn(string.format("unknown parameter %s.", args_splits[1]))
    end
  end, {
    nargs = "*",
    range = false,
    bang = true,
    desc = confs.command.desc,
    complete = function(ArgLead, CmdLine, CursorPos)
      local complete_args = {}
      for k, v in pairs(controller) do
        if not str.startswith(k, "_") and vim.is_callable(v) then
          table.insert(complete_args, k)
        end
      end
      table.sort(complete_args)
      return complete_args
    end,
  })

  vim.api.nvim_create_autocmd("ColorSchemePre", {
    callback = function(event)
      log.debug(string.format("ColorSchemePre event:%s", vim.inspect(event)))
      loader.load(vim.tbl_get(event, "match"), false)
    end,
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function(event)
      log.debug(string.format("ColorScheme event:%s", vim.inspect(event)))
      vim.schedule(function()
        track.save_track(vim.g.colors_name)
      end)
    end,
  })

  timing.setup()
end

local M = {
  setup = setup,
  update = controller.update,
}

return M
