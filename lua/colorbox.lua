local logging = require("colorbox.commons.logging")
local LogLevels = require("colorbox.commons.logging").LogLevels
local jsons = require("colorbox.commons.jsons")
local uv = require("colorbox.commons.uv")
local numbers = require("colorbox.commons.numbers")
local fileios = require("colorbox.commons.fileios")
local strings = require("colorbox.commons.strings")
local apis = require("colorbox.commons.apis")
local async = require("colorbox.commons.async")

local configs = require("colorbox.configs")
local filter = require("colorbox.filter")

-- filtered color names list
--- @type string[]
local FilteredColorNamesList = {}

-- filtered color name to index map, the reverse of FilteredColorNamesList (index => name)
--- @type table<string, integer>
local FilteredColorNameToIndexMap = {}

local function _init()
  local home_dir = vim.fn["colorbox#base_dir"]()
  -- local pack_dir = "pack/colorbox/start"
  -- local full_pack_dir = string.format("%s/%s", home_dir, pack_dir)
  -- logger.debug(
  --     "|colorbox.init| home_dir:%s, pack_dir:%s, full_pack_dir:%s",
  --     vim.inspect(home_dir),
  --     vim.inspect(pack_dir),
  --     vim.inspect(full_pack_dir)
  -- )
  vim.opt.packpath:append(home_dir)
  -- vim.opt.packpath:append(cwd .. "/pack")
  -- vim.opt.packpath:append(cwd .. "/pack/colorbox")
  -- vim.opt.packpath:append(cwd .. "/pack/colorbox/opt")
  -- vim.cmd([[packadd catppuccin-nvim]])

  local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]
  local ColorNameToColorSpecsMap = require("colorbox.db").get_color_name_to_color_specs_map()
  local ColorNamesList = require("colorbox.db").get_color_names_list()
  for _, color_name in pairs(ColorNamesList) do
    local spec = ColorNameToColorSpecsMap[color_name]
    local pack_exist = uv.fs_stat(spec.full_pack_path) ~= nil
    if filter.run(color_name, spec) and pack_exist then
      table.insert(FilteredColorNamesList, color_name)
    end
  end
  for i, color_name in ipairs(FilteredColorNamesList) do
    FilteredColorNameToIndexMap[color_name] = i
  end
  -- logger:debug("|_init| FilteredColorNamesList:%s", vim.inspect(FilteredColorNamesList))
  -- logger:debug("|_init| FilteredColorNameToIndexMap:%s", vim.inspect(FilteredColorNameToIndexMap))
end

local function _force_sync_syntax()
  vim.cmd([[syntax sync fromstart]])
end

--- @alias colorbox.PreviousTrack {color_name:string,color_number:integer}
--- @param color_name string
local function _save_track(color_name)
  if strings.blank(color_name) then
    return
  end
  local color_number = FilteredColorNameToIndexMap[color_name] or 1
  vim.schedule(function()
    local confs = configs.get()
    local content = jsons.encode({
      color_name = color_name,
      color_number = color_number,
    }) --[[@as string]]
    fileios.writefile(confs.previous_track_cache, content)
  end)
end

--- @return colorbox.PreviousTrack?
local function _load_previous_track()
  local confs = configs.get()
  local content = fileios.readfile(confs.previous_track_cache)
  if content == nil then
    return nil
  end
  return jsons.decode(content) --[[@as colorbox.PreviousTrack?]]
end

--- @param idx integer
--- @return string
local function _get_next_color_name_by_idx(idx)
  assert(type(idx) == "number")
  idx = idx + 1
  if idx > #FilteredColorNamesList then
    idx = 1
  end
  return FilteredColorNamesList[numbers.bound(idx, 1, #FilteredColorNamesList)]
end

--- @param idx integer
--- @return string
local function _get_prev_color_name_by_idx(idx)
  assert(type(idx) == "number")
  idx = idx - 1
  if idx < 1 then
    idx = #FilteredColorNamesList
  end
  return FilteredColorNamesList[numbers.bound(idx, 1, #FilteredColorNamesList)]
end

local function _policy_shuffle()
  if #FilteredColorNamesList > 0 then
    local i = numbers.random(#FilteredColorNamesList) --[[@as integer]]
    local color = _get_next_color_name_by_idx(i)
    logging.get("colorbox"):debug(
      "|_policy_shuffle| color:%s, FilteredColorNamesList:%s (%d), i:%d",
      vim.inspect(color),
      vim.inspect(FilteredColorNamesList),
      vim.inspect(#FilteredColorNamesList),
      vim.inspect(i)
    )
    vim.cmd(string.format([[color %s]], color))
  end
end

local function _policy_in_order()
  if #FilteredColorNamesList > 0 then
    local previous_track = _load_previous_track() --[[@as colorbox.PreviousTrack]]
    local i = previous_track ~= nil and previous_track.color_number or 0
    local color = _get_next_color_name_by_idx(i)
    vim.cmd(string.format([[color %s]], color))
  end
end

local function _policy_reverse_order()
  if #FilteredColorNamesList > 0 then
    local previous_track = _load_previous_track() --[[@as colorbox.PreviousTrack]]
    local i = previous_track ~= nil and previous_track.color_number or (#FilteredColorNamesList + 1)
    local color = _get_prev_color_name_by_idx(i)
    vim.cmd(string.format([[color %s]], color))
  end
end

local function _policy_single()
  if #FilteredColorNamesList > 0 then
    local previous_track = _load_previous_track() --[[@as colorbox.PreviousTrack]]
    local color = previous_track ~= nil and previous_track.color_name
      or _get_next_color_name_by_idx(0)
    if color ~= vim.g.colors_name then
      vim.cmd(string.format([[color %s]], color))
    end
  end
end

--- @param po colorbox.Options?
--- @return boolean
local function _is_fixed_interval_policy(po)
  return type(po) == "table"
    and type(po.seconds) == "number"
    and po.seconds >= 0
    and type(po.implement) == "string"
    and string.len(po.implement) > 0
end

local function _policy_fixed_interval()
  local confs = configs.get()
  local later = confs.policy.seconds > 0 and (confs.policy.seconds * 1000) or numbers.INT32_MAX

  local function impl()
    if confs.policy.implement == "shuffle" then
      _policy_shuffle()
      _force_sync_syntax()
    elseif confs.policy.implement == "in_order" then
      _policy_in_order()
      _force_sync_syntax()
    elseif confs.policy.implement == "reverse_order" then
      _policy_reverse_order()
      _force_sync_syntax()
    elseif confs.policy.implement == "single" then
      _policy_single()
      _force_sync_syntax()
    end
    vim.defer_fn(impl, later)
  end
  impl()
end

--- @param po colorbox.Options?
--- @return boolean
local function _is_by_filetype_policy(po)
  return type(po) == "table"
    and type(po.mapping) == "table"
    and ((type(po.empty) == "string" and string.len(po.empty) > 0) or po.empty == nil)
    and ((type(po.fallback) == "string" and string.len(po.fallback) > 0) or po.fallback == nil)
end

local function _policy_by_filetype()
  vim.defer_fn(function()
    local confs = configs.get()
    local ft = vim.bo.filetype or ""

    if confs.policy.mapping[ft] then
      local ok, err =
        pcall(vim.cmd --[[@as function]], string.format([[color %s]], confs.policy.mapping[ft]))
      assert(ok, err)
    elseif strings.empty(ft) and strings.not_empty(confs.policy.empty) then
      local ok, err =
        pcall(vim.cmd --[[@as function]], string.format([[color %s]], confs.policy.empty))
      assert(ok, err)
    elseif strings.not_empty(confs.policy.fallback) then
      local ok, err =
        pcall(vim.cmd --[[@as function]], string.format([[color %s]], confs.policy.fallback))
      assert(ok, err)
    end
    _force_sync_syntax()
  end, 10)
end

local function _policy()
  local confs = configs.get()
  if confs.policy == "shuffle" then
    _policy_shuffle()
  elseif confs.policy == "in_order" then
    _policy_in_order()
  elseif confs.policy == "reverse_order" then
    _policy_reverse_order()
  elseif confs.policy == "single" then
    _policy_single()
  elseif confs.timing == "interval" and _is_fixed_interval_policy(confs.policy) then
    _policy_fixed_interval()
  elseif
    confs.timing == "bufferchanged"
    or confs.timing == "filetype" and _is_by_filetype_policy(confs.policy)
  then
    _policy_by_filetype()
  end
end

local function _timing_startup()
  vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = _policy,
  })
end

local function _timing_filetype()
  vim.api.nvim_create_autocmd({
    "BufEnter",
    "BufReadPost",
    "FileReadPost",
    "FocusGained",
    "WinEnter",
    "WinNew",
    "TermEnter",
    "TermOpen",
  }, {
    callback = _policy,
  })
end

local function _timing()
  local confs = configs.get()
  if confs.timing == "startup" then
    _timing_startup()
  elseif confs.timing == "interval" then
    assert(
      _is_fixed_interval_policy(confs.policy),
      string.format("invalid policy %s for 'interval' timing!", vim.inspect(confs.policy))
    )
    _policy_fixed_interval()
  elseif confs.timing == "bufferchanged" or confs.timing == "filetype" then
    assert(
      _is_by_filetype_policy(confs.policy),
      string.format("invalid policy %s for 'filetype' timing!", vim.inspect(confs.policy))
    )
    _timing_filetype()
  else
    error(string.format("invalid timing %s!", vim.inspect(confs.timing)))
  end
end

local function update()
  if logging.get("colorbox-update") == nil then
    logging.setup({
      name = "colorbox-update",
      level = LogLevels.DEBUG,
      console_log = true,
      file_log = true,
      file_log_name = "colorbox_update.log",
      file_log_mode = "w",
    })
  end
  local logger = logging.get("colorbox-update") --[[@as commons.logging.Logger]]

  local home_dir = vim.fn["colorbox#base_dir"]()
  -- local packstart = string.format("%s/pack/colorbox/start", home_dir)
  -- logger.debug(
  --     "|colorbox.init| home_dir:%s, pack:%s",
  --     vim.inspect(home_dir),
  --     vim.inspect(packstart)
  -- )
  vim.opt.packpath:append(home_dir)

  local HandleToColorSpecsMap = require("colorbox.db").get_handle_to_color_specs_map()

  local prepared_count = 0
  for _, _ in pairs(HandleToColorSpecsMap) do
    prepared_count = prepared_count + 1
  end
  logger:info("started %s jobs", vim.inspect(prepared_count))

  local async_spawn_run = async.wrap(function(acmd, aopts, cb)
    require("colorbox.commons.spawn").run(acmd, aopts, function(completed_obj)
      cb(completed_obj)
    end)
  end, 3)

  local finished_count = 0
  async.run(function()
    for handle, spec in pairs(HandleToColorSpecsMap) do
      local function _on_output(line)
        if strings.not_blank(line) then
          logger:info("%s: %s", handle, line)
        end
      end
      local param = nil
      if
        vim.fn.isdirectory(spec.full_pack_path) > 0
        and vim.fn.isdirectory(spec.full_pack_path .. "/.git") > 0
      then
        param = {
          cmd = { "git", "pull" },
          opts = {
            cwd = spec.full_pack_path,
            on_stdout = _on_output,
            on_stderr = _on_output,
          },
        }
      else
        param = {
          cmd = strings.not_empty(spec.git_branch) and {
            "git",
            "clone",
            "--branch",
            spec.git_branch,
            "--depth=1",
            spec.url,
            spec.pack_path,
          } or {
            "git",
            "clone",
            "--depth=1",
            spec.url,
            spec.pack_path,
          },
          opts = {
            cwd = home_dir,
            on_stdout = _on_output,
            on_stderr = _on_output,
          },
        }
      end
      async_spawn_run(param.cmd, param.opts)
      async.scheduler()
      finished_count = finished_count + 1
    end
  end, function()
    logger:info("finished %s jobs", vim.inspect(finished_count))
  end)
end

local function _clean()
  local home_dir = vim.fn["colorbox#base_dir"]()
  local full_pack_dir = string.format("%s/pack", home_dir)
  local shorten_pack_dir = vim.fn.fnamemodify(full_pack_dir, ":~")
  ---@diagnostic disable-next-line: discard-returns, param-type-mismatch
  local opened_dir, opendir_err = uv.fs_opendir(full_pack_dir)
  if not opened_dir then
    -- logger.debug(
    --     "directory %s not found, error: %s",
    --     vim.inspect(shorten_pack_dir),
    --     vim.inspect(opendir_err)
    -- )
    return
  end
  local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]
  if vim.fn.executable("rm") > 0 then
    local jobid = vim.fn.jobstart({ "rm", "-rf", full_pack_dir }, {
      detach = false,
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(chanid, data, name)
        -- logger.debug(
        --     "clean job(%s) data:%s",
        --     vim.inspect(name),
        --     vim.inspect(data)
        -- )
      end,
      on_stderr = function(chanid, data, name)
        -- logger.debug(
        --     "clean job(%s) data:%s",
        --     vim.inspect(name),
        --     vim.inspect(data)
        -- )
      end,
      on_exit = function(jid, exitcode, name)
        -- logger.debug(
        --     "clean job(%s) done:%s",
        --     vim.inspect(name),
        --     vim.inspect(exitcode)
        -- )
      end,
    })
    vim.fn.jobwait({ jobid })
    logger:info("cleaned directory: %s", shorten_pack_dir)
  else
    logger:warn("no 'rm' command found, skip cleaning...")
  end
end

--- @param args string?
--- @return colorbox.Options?
local function _parse_args(args)
  local opts = nil
  logging.get("colorbox"):debug("|_parse_args| args:%s", vim.inspect(args))
  if strings.not_blank(args) then
    local args_splits = strings.split(vim.trim(args --[[@as string]]), " ", { trimempty = true })
    for _, arg_split in ipairs(args_splits) do
      local item_splits = strings.split(vim.trim(arg_split), "=", { trimempty = true })
      if strings.not_blank(item_splits[1]) then
        if opts == nil then
          opts = {}
        end
        opts[vim.trim(item_splits[1])] = vim.trim(item_splits[2])
      end
    end
  end
  return opts
end

local function _update()
  update()
end

local function _reinstall()
  _clean()
  update()
end

--- @param args string
local function _info(args)
  local opts = _parse_args(args)
  opts = opts or { scale = 0.7 }
  opts.scale = type(opts.scale) == "string" and (tonumber(opts.scale) or 0.7) or 0.7
  opts.scale = numbers.bound(opts.scale, 0, 1)
  logging.get("colorbox"):debug("|_info| opts:%s", vim.inspect(opts))

  local total_width = vim.o.columns
  local total_height = vim.o.lines
  local width = math.floor(total_width * opts.scale)
  local height = math.floor(total_height * opts.scale)

  local function get_shift(totalsize, modalsize, offset)
    local base = math.floor((totalsize - modalsize) * 0.5)
    local shift = offset > -1 and math.ceil((totalsize - modalsize) * offset) or offset
    return numbers.bound(base + shift, 0, totalsize - modalsize)
  end

  local row = get_shift(total_height, height, 0)
  local col = get_shift(total_width, width, 0)

  local win_config = {
    anchor = "NW",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    zindex = 51,
  }

  local bufnr = vim.api.nvim_create_buf(false, true)
  apis.set_buf_option(bufnr, "bufhidden", "wipe")
  apis.set_buf_option(bufnr, "buflisted", false)
  apis.set_buf_option(bufnr, "filetype", "markdown")
  vim.keymap.set({ "n" }, "q", ":\\<C-U>quit<CR>", { silent = true, buffer = bufnr })
  local winnr = vim.api.nvim_open_win(bufnr, true, win_config)

  local HandleToColorSpecsMap = require("colorbox.db").get_handle_to_color_specs_map()
  local color_specs_list = {}
  for handle, spec in pairs(HandleToColorSpecsMap) do
    table.insert(color_specs_list, spec)
  end
  table.sort(color_specs_list, function(a, b)
    return a.github_stars > b.github_stars
  end)
  local total_plugins = 0
  local total_colors = 0
  local enabled_plugins = 0
  local enabled_colors = 0
  for i, spec in ipairs(color_specs_list) do
    total_plugins = total_plugins + 1
    local plugin_enabled = false
    for j, color in ipairs(spec.color_names) do
      total_colors = total_colors + 1
      local color_enabled = FilteredColorNameToIndexMap[color] ~= nil
      if color_enabled then
        enabled_colors = enabled_colors + 1
        plugin_enabled = true
      end
    end
    if plugin_enabled then
      enabled_plugins = enabled_plugins + 1
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, 0, true, {
    string.format(
      "# ColorSchemes List, total: %d(colors)/%d(plugins), enabled: %d(colors)/%d(plugins)",
      total_colors,
      total_plugins,
      enabled_colors,
      enabled_plugins
    ),
  })
  local lineno = 1
  for i, spec in ipairs(color_specs_list) do
    vim.api.nvim_buf_set_lines(bufnr, lineno, lineno, true, {
      string.format(
        "- %s (stars: %s, last update at: %s)",
        vim.inspect(spec.handle),
        vim.inspect(spec.github_stars),
        vim.inspect(spec.last_git_commit)
      ),
    })
    lineno = lineno + 1
    local colornames = vim.deepcopy(spec.color_names)
    table.sort(colornames, function(a, b)
      local a_enabled = FilteredColorNameToIndexMap[a] ~= nil
      return a_enabled
    end)

    for _, color in ipairs(colornames) do
      local enabled = FilteredColorNameToIndexMap[color] ~= nil
      local content = enabled and string.format("  - %s (**enabled**)", color)
        or string.format("  - %s (disabled)", color)
      vim.api.nvim_buf_set_lines(bufnr, lineno, lineno, true, { content })
      lineno = lineno + 1
    end
  end
  vim.schedule(function()
    vim.cmd(string.format([[call setpos('.', [%d, 1, 1])]], bufnr))
  end)
end

local CONTROLLERS_MAP = {
  update = _update,
  reinstall = _reinstall,
  info = _info,
}

--- @param opts colorbox.Options?
local function setup(opts)
  local confs = configs.setup(opts)

  logging.setup({
    name = "colorbox",
    level = confs.debug and LogLevels.DEBUG or LogLevels.INFO,
    console_log = confs.console_log,
    file_log = confs.file_log,
    file_log_name = "colorbox.log",
  })

  -- cache
  assert(
    vim.fn.filereadable(confs.cache_dir) <= 0,
    string.format("%s (cache_dir option) already exist but not a directory!", confs.cache_dir)
  )
  vim.fn.mkdir(confs.cache_dir, "p")
  confs.previous_track_cache = string.format("%s/previous_track_cache", confs.cache_dir)

  _init()

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
    if type(CONTROLLERS_MAP[args_splits[1]]) == "function" then
      local fn = CONTROLLERS_MAP[args_splits[1]]
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
      return { "update", "reinstall", "info" }
    end,
  })

  vim.api.nvim_create_autocmd("ColorSchemePre", {
    callback = function(event)
      local logger = logging.get("colorbox") --[[@as commons.logging.Logger]]
      logger:debug("|colorbox.setup| ColorSchemePre event:%s", vim.inspect(event))
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
    callback = function(event)
      -- logger.debug(
      --     "|colorbox.setup| ColorScheme event:%s",
      --     vim.inspect(event)
      -- )
      vim.schedule(function()
        _save_track(vim.g.colors_name)
      end)
    end,
  })

  _timing()
end

local function _get_filtered_color_names_list()
  return FilteredColorNamesList
end

local function _get_filtered_color_name_to_index_map()
  return FilteredColorNameToIndexMap
end

local M = {
  setup = setup,
  update = update,

  -- misc
  _force_sync_syntax = _force_sync_syntax,
  _save_track = _save_track,
  _load_previous_track = _load_previous_track,
  _get_next_color_name_by_idx = _get_next_color_name_by_idx,
  _get_prev_color_name_by_idx = _get_prev_color_name_by_idx,
  _get_filtered_color_names_list = _get_filtered_color_names_list,
  _get_filtered_color_name_to_index_map = _get_filtered_color_name_to_index_map,

  -- policy
  _policy_shuffle = _policy_shuffle,
  _policy_in_order = _policy_in_order,
  _policy_reverse_order = _policy_reverse_order,
  _policy_single = _policy_single,
  _policy = _policy,

  -- command
  _parse_args = _parse_args,
}

return M
