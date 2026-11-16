local log = require("colorbox.log")

local M = {}

--- @alias colorbox.Options table<any, any>
--- @type colorbox.Options
local Defaults = {
  -- builtin policy
  --- @alias colorbox.BuiltinPolicyConfig "shuffle"|"in_order"|"reverse_order"|"single"
  ---
  -- by filetype policy: buffer filetype => color name
  --- @alias colorbox.ByFileTypePolicyConfig {mapping:table<string, string>,empty:string?,fallback:string?}
  ---
  -- fixed interval seconds
  --- @alias colorbox.FixedIntervalPolicyConfig {seconds:integer,implement:colorbox.BuiltinPolicyConfig}
  ---
  --- @alias colorbox.PolicyConfig colorbox.BuiltinPolicyConfig|colorbox.ByFileTypePolicyConfig|colorbox.FixedIntervalPolicyConfig
  --- @type colorbox.PolicyConfig
  policy = "shuffle",

  --- @type "startup"|"interval"|"filetype"
  timing = "startup",

  -- (Optional) filters that disable some colors that you don't want.
  --
  -- function-based filter, enabled if function returns true.
  -- (default to nil, which enables all colors)
  --- @alias colorbox.FunctionFilterConfig fun(color:string, spec:colorbox.ColorSpec):boolean
  ---
  -- list-based all of filter, a color is enabled if all of inside filters returns true.
  --- @alias colorbox.AllFilterConfig colorbox.FunctionFilterConfig[]
  ---
  --- @alias colorbox.FilterConfig colorbox.FunctionFilterConfig|colorbox.AllFilterConfig
  --- @type colorbox.FilterConfig?
  filter = nil,

  --- @type table<string, function>
  setup = {},

  --- @type "dark"|"light"|nil
  background = nil,

  --- @type colorbox.Options
  command = {
    name = "Colorbox",
    desc = "Colorschemes player controller",
  },

  -- name of the autocmd group colorbox attaches its autocmds to. `setup()` clears
  -- this group on every call, which is what keeps repeated `setup()` from stacking
  -- one more handler per event.
  --- @type string
  augroup = "Colorbox",

  -- (Optional) hook lua function after colorscheme is been choose.
  --- @type function(color_name: string, color_spec: colorbox.ColorSpec):nil|nil
  post_hook = nil,

  --- @type string
  cache_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "colorbox.nvim"),

  -- enable debug
  debug = false,

  -- print log to console (command line)
  console_log = true,

  -- print log to file.
  file_log = false,
}

--- @type colorbox.Options
local Configs = {}

--- Validate options, warn on invalid values instead of failing silently.
--- @param opts colorbox.Options
local validate = function(opts)
  -- `filter`: nil, a function, or a list of functions, anything else enables every
  -- color.
  local f = opts.filter
  if f ~= nil and type(f) ~= "function" and type(f) ~= "table" then
    log.warn(
      string.format(
        "'filter' option expects a function, a list of functions or nil, got: %s, "
          .. "it will be ignored and all colors will be enabled.",
        vim.inspect(f)
      )
    )
    opts.filter = nil
  end

  -- `augroup`: the name handed to `nvim_create_augroup`, so a value that is not a
  -- non-empty string would make every autocmd creation fail. `nil` means "use the
  -- default", which `Defaults` already fills in.
  local augroup = opts.augroup
  if augroup ~= nil and (type(augroup) ~= "string" or vim.trim(augroup) == "") then
    log.warn(
      string.format(
        "'augroup' option expects a non-empty string, got: %s, it will be ignored "
          .. "and the default group name will be used.",
        vim.inspect(augroup)
      )
    )
    opts.augroup = Defaults.augroup
  end
end

--- Merge user options with the defaults, then apply the logging settings and
--- validate them. Keeping this here means `cfg.debug`/`cfg.console_log`/
--- `cfg.file_log` are always honored, whoever calls `setup`.
--- @param opts colorbox.Options?
--- @return colorbox.Options
M.setup = function(opts)
  Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})
  -- logging first, so warnings emitted by `validate` respect the new options
  log.setup({
    level = Configs.debug and vim.log.levels.DEBUG or vim.log.levels.INFO,
    use_console = Configs.console_log,
    use_file = Configs.file_log,
  })
  validate(Configs)
  return Configs
end

--- @return colorbox.Options
M.get = function()
  return Configs
end

--- @param confs colorbox.Options
--- @return colorbox.Options
M.set = function(confs)
  Configs = confs
  return Configs
end

return M
