local logging = require("colorbox.commons.logging")
local LogLevels = require("colorbox.commons.logging").LogLevels
local strings = require("colorbox.commons.strings")

local configs = require("colorbox.configs")
local timing = require("colorbox.timing")
local util = require("colorbox.util")
local runtime = require("colorbox.runtime")
local controller = require("colorbox.controller")

--- @param opts colorbox.Options?
local function setup(opts)
  local confs = configs.setup(opts)

  if not logging.has("colorbox") then
    logging.setup({
      name = "colorbox",
      level = confs.debug and LogLevels.DEBUG or LogLevels.INFO,
      console_log = confs.console_log,
      file_log = confs.file_log,
      file_log_name = "colorbox.log",
    })
  end

  -- cache
  assert(
    vim.fn.filereadable(confs.cache_dir) <= 0,
    string.format("%s (cache_dir option) already exist but not a directory!", confs.cache_dir)
  )
  vim.fn.mkdir(confs.cache_dir, "p")
  confs.previous_track_cache = string.format("%s/previous_track_cache", confs.cache_dir)
  confs.previous_colors_cache = string.format("%s/previous_colors_cache", confs.cache_dir)
  confs = configs.set(confs)

  runtime.setup()

  vim.api.nvim_create_user_command(confs.command.name, function(command_opts)
    local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]

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
      logger:warn("missing parameter.")
      return
    end
    if vim.is_callable(controller[args_splits[1]]) then
      local fn = controller[args_splits[1]]
      local sub_args = args:sub(string.len(args_splits[1]) + 1)
      fn(sub_args)
    else
      logger:warn("unknown parameter %s.", args_splits[1])
    end
  end, {
    nargs = "*",
    range = false,
    bang = true,
    desc = confs.command.desc,
    complete = function(ArgLead, CmdLine, CursorPos)
      local complete_args = {}
      for k, v in pairs(controller) do
        if not strings.startswith(k, "_") and vim.is_callable(v) then
          table.insert(complete_args, k)
        end
      end
      table.sort(complete_args)
      return complete_args
    end,
  })

  vim.api.nvim_create_autocmd("ColorSchemePre", {
    callback = function(event)
      local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]
      -- logger:debug("|colorbox.setup| ColorSchemePre event:%s", vim.inspect(event))
      local ColorNameToColorSpecsMap = require("colorbox.db").get_color_name_to_color_specs_map()
      if type(event) ~= "table" or ColorNameToColorSpecsMap[event.match] == nil then
        return
      end
      local spec = ColorNameToColorSpecsMap[event.match]
      local autoload = string.format("%s/autoload", spec.full_pack_path)
      vim.opt.runtimepath:append(autoload)
      vim.cmd(string.format([[packadd %s]], spec.git_path))
      if type(confs.setup) == "table" and type(confs.setup[spec.handle]) == "function" then
        local home_dir = vim.fn["colorbox#base_dir"]()
        local ok, setup_err = pcall(confs.setup[spec.handle], home_dir, spec)
        if not ok then
          logger:err(
            "failed to setup colorscheme:%s, error:%s",
            vim.inspect(spec.handle),
            vim.inspect(setup_err)
          )
        end
      end
      if confs.background == "dark" or confs.background == "light" then
        vim.opt.background = confs.background
      end
    end,
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      vim.schedule(function()
        util.save_track(vim.g.colors_name)
      end)
    end,
  })

  timing.setup()
end

local M = {
  setup = setup,
}

return M
