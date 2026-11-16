local cwd = vim.uv.cwd()

describe("colorbox.policy.builtin", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local types = require("colorbox.types")
  local builtin_policy = require("colorbox.policy.builtin")
  local loader = require("colorbox.loader")
  local runtime = require("colorbox.runtime")
  require("colorbox").setup({
    debug = true,
    file_log = true,
  })

  --- @param filename string
  --- @param content string
  local function write_file(filename, content)
    local fp = assert(io.open(filename, "w"))
    fp:write(content)
    fp:close()
  end

  --- Record the color names passed to `loader.load`, without loading them.
  --- @param fn function
  --- @return string[]
  local function record_loads(fn)
    local loads = {}
    local original = loader.load
    loader.load = function(color_name)
      table.insert(loads, color_name)
    end
    local ok, err = pcall(fn)
    loader.load = original
    if not ok then
      error(err)
    end
    return loads
  end

  describe("[builtin_policy]", function()
    it("test", function()
      for k, fn in pairs(builtin_policy) do
        if not types.str_startswith(k, "_") and vim.is_callable(fn) then
          pcall(fn)
        end
      end
    end)
    it("single ignores a track of a colorscheme it does not manage", function()
      local color_names = runtime.color_names()
      if #color_names == 0 then
        return
      end
      local cache_file = require("colorbox.configs").get().previous_track_cache
      write_file(cache_file, '{"color_name":"default","color_number":1}')

      vim.g.colors_name = "default"
      local loads = record_loads(builtin_policy.single)
      assert_eq(#loads, 1)
      assert_eq(loads[1], color_names[1])
    end)
    it("in_order ignores a track of a colorscheme it does not manage", function()
      local color_names = runtime.color_names()
      if #color_names == 0 then
        return
      end
      local cache_file = require("colorbox.configs").get().previous_track_cache
      write_file(cache_file, '{"color_name":"default","color_number":1}')

      local loads = record_loads(builtin_policy.in_order)
      assert_eq(#loads, 1)
      -- color_number 1 would have resumed at the second color
      assert_eq(loads[1], color_names[1])
    end)
  end)
end)
