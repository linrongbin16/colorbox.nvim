local num = require("colorbox.commons.num")
local str = require("colorbox.commons.str")
local log = require("colorbox.commons.log")
local async = require("colorbox.commons.async")

local loader = require("colorbox.loader")

local runtime = require("colorbox.runtime")
local db = require("colorbox.db")

local M = {}

M.update = function()
  log.setup({
    name = "colorbox-update",
    level = vim.log.levels.DEBUG,
  })

  local home_dir = vim.fn["colorbox#base_dir"]()
  local packstart = string.format("%s/pack/colorbox/start", home_dir)
  log.debug(
    string.format(
      "|colorbox.init| home_dir:%s, packstart:%s",
      vim.inspect(home_dir),
      vim.inspect(packstart)
    )
  )
  vim.opt.packpath:append(home_dir)

  local specs_by_handle = db.get_specs_by_handle()

  local prepared_count = 0
  for _, _ in pairs(specs_by_handle) do
    prepared_count = prepared_count + 1
  end
  log.info(string.format("started %s jobs", vim.inspect(prepared_count)))

  async.run(function()
    local finished_count = 0

    for handle, spec in pairs(specs_by_handle) do
      local pack_path = db.get_pack_path(spec)
      local full_pack_path = db.get_full_pack_path(spec)
      local param = nil
      if
        vim.fn.isdirectory(full_pack_path) > 0
        and vim.fn.isdirectory(full_pack_path .. "/.git") > 0
      then
        param = {
          cmd = { "git", "pull" },
          opts = {
            cwd = full_pack_path,
            text = true,
          },
        }
        -- logger:debug(
        --   string.format(
        --     "|_update| git pull param:%s, spec:%s",
        --     vim.inspect(param),
        --     vim.inspect(spec)
        --   )
        -- )
      else
        param = {
          cmd = str.not_empty(spec.git_branch) and {
            "git",
            "clone",
            "--branch",
            spec.git_branch,
            "--depth=1",
            spec.url,
            pack_path,
          } or {
            "git",
            "clone",
            "--depth=1",
            spec.url,
            pack_path,
          },
          opts = {
            cwd = home_dir,
            text = true,
          },
        }
        -- logger:debug(
        --   string.format(
        --     "|_update| git clone param:%s, spec:%s",
        --     vim.inspect(param),
        --     vim.inspect(spec)
        --   )
        -- )
      end

      async.wrap(1, function(cb)
        vim.system(
          param.cmd,
          param.opts,
          --- @param completed vim.SystemCompleted
          function(completed)
            if type(completed) == "table" then
              if str.not_blank(completed.stdout) then
                log.info(string.format("%s: %s", handle, str.trim(completed.stdout)))
              end
              if str.not_blank(completed.stderr) then
                log.info(string.format("%s: %s", handle, str.trim(completed.stderr)))
              end
            end
            cb(completed)
          end
        )
      end)()

      async.await(1, vim.schedule)
      finished_count = finished_count + 1
    end

    log.info(string.format("finished %s jobs", vim.inspect(finished_count)))
  end)
end

--- @param args string?
--- @return colorbox.Options?
M._parse_args = function(args)
  local opts = nil
  log.debug(string.format("|_parse_args| args:%s", vim.inspect(args)))
  if str.not_blank(args) then
    local args_splits = str.split(vim.trim(args --[[@as string]]), " ", { trimempty = true })
    for _, arg_split in ipairs(args_splits) do
      local item_splits = str.split(vim.trim(arg_split), "=", { trimempty = true })
      if str.not_blank(item_splits[1]) then
        if opts == nil then
          opts = {}
        end
        opts[vim.trim(item_splits[1])] = vim.trim(item_splits[2] or "")
      end
    end
  end
  return opts
end

M.shuffle = function()
  local colornames = runtime.colornames()
  if #colornames > 0 then
    local random_index = num.random(1, #colornames)
    local color = colornames[random_index]

    log.debug(
      string.format(
        "|shuffle| color:%s, random_index:%d, ColorNamesList(%d):%s",
        vim.inspect(color),
        random_index,
        #colornames,
        vim.inspect(colornames)
      )
    )
    loader.load(color)
  end
end

--- @param args string?
M.info = function(args)
  local opts = M._parse_args(args)
  opts = opts or { scale = 0.7 }
  opts.scale = type(opts.scale) == "string" and (tonumber(opts.scale) or 0.7) or 0.7
  opts.scale = num.clamp(opts.scale, 0, 1)
  log.debug(string.format("|_info| opts:%s", vim.inspect(opts)))

  local total_width = vim.o.columns
  local total_height = vim.o.lines
  local width = math.floor(total_width * opts.scale)
  local height = math.floor(total_height * opts.scale)

  local function get_shift(totalsize, modalsize, offset)
    local base = math.floor((totalsize - modalsize) * 0.5)
    local shift = offset > -1 and math.ceil((totalsize - modalsize) * offset) or offset
    return num.clamp(base + shift, 0, totalsize - modalsize)
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
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
  vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = bufnr })
  vim.keymap.set({ "n" }, "q", ":\\<C-U>quit<CR>", { silent = true, buffer = bufnr })
  local winnr = vim.api.nvim_open_win(bufnr, true, win_config)

  local color_indexes = runtime.color_indexes()
  local specs_by_handle = db.get_specs_by_handle()
  local color_specs_list = {}
  for handle, spec in pairs(specs_by_handle) do
    table.insert(color_specs_list, spec)
  end
  table.sort(color_specs_list, function(a, b)
    return a.color_name > b.color_name
  end)
  local total_colors = #color_specs_list

  vim.api.nvim_buf_set_lines(bufnr, 0, 0, true, {
    string.format("# ColorSchemes List, total: %d", total_colors),
  })
  local lineno = 1
  for i, spec in ipairs(color_specs_list) do
    vim.api.nvim_buf_set_lines(bufnr, lineno, lineno, true, {
      string.format("- %s (%s)", spec.handle, spec.colorname),
    })
    lineno = lineno + 1
  end
  vim.schedule(function()
    vim.cmd(string.format([[call setpos('.', [%d, 1, 1])]], bufnr))
  end)
end

return M
