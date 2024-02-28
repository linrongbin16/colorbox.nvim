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
  -- builtin filter
  --- @alias colorbox.BuiltinFilterConfig "primary"
  ---
  -- function-based filter, enabled if function returns true.
  --- @alias colorbox.FunctionFilterConfig fun(color:string, spec:colorbox.ColorSpec):boolean
  ---
  -- list-based all of filter, a color is enabled if all of inside filters returns true.
  --- @alias colorbox.AllFilterConfig (colorbox.BuiltinFilterConfig|colorbox.FunctionFilterConfig)[]
  ---
  --- @alias colorbox.FilterConfig colorbox.BuiltinFilterConfig|colorbox.FunctionFilterConfig|colorbox.AllFilterConfig
  --- @type colorbox.FilterConfig?
  filter = {
    "primary",
    function(color, spec)
      return spec.github_stars >= 800
    end,
  },

  --- @type table<string, function>
  setup = {
    ["projekt0n/github-nvim-theme"] = function()
      require("github-theme").setup()
    end,
  },

  --- @type "dark"|"light"|nil
  background = nil,

  --- @type colorbox.Options
  command = {
    name = "Colorbox",
    desc = "Colorschemes player controller",
  },

  --- @type string
  cache_dir = string.format("%s/colorbox.nvim", vim.fn.stdpath("data")),

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
