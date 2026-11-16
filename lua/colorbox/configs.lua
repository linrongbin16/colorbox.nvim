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

--- @param opts colorbox.Options?
--- @return colorbox.Options
M.setup = function(opts)
  Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})
  return Configs
end

--- Validate options, warn on invalid values instead of failing silently.
--- @param opts colorbox.Options
M.validate = function(opts)
  local f = opts.filter
  -- `false` is the legacy way to say "enable all colors", treat it as nil.
  if f == false then
    opts.filter = nil
    return
  end
  if f == nil or type(f) == "function" or type(f) == "table" then
    return
  end
  log.warn(
    string.format(
      "'filter' option expects a function, a list of functions or nil, got: %s, "
        .. "it will be ignored and all colors will be enabled.",
      vim.inspect(f)
    )
  )
  opts.filter = nil
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
