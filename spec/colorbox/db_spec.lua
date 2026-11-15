local cwd = vim.uv.cwd()

describe("colorbox.db", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local db = require("colorbox.db")
  describe("[get_xxx]", function()
    it("get_specs_by_handle", function()
      local specs_by_handle = db.get_specs_by_handle()
      assert_eq(type(specs_by_handle), "table")
    end)
    it("get_specs_by_color_name", function()
      local specs_by_color_name = db.get_specs_by_color_name()
      assert_eq(type(specs_by_color_name), "table")
    end)
    it("get_color_names", function()
      local color_names = db.get_color_names()
      assert_eq(type(color_names), "table")
    end)
  end)
  describe("[dataset]", function()
    it("expands every entry into a full color spec", function()
      local specs_by_handle = db.get_specs_by_handle()
      local specs_by_color_name = db.get_specs_by_color_name()
      local color_names = db.get_color_names()
      local count = 0
      for handle, spec in pairs(specs_by_handle) do
        count = count + 1
        assert_eq(spec.handle, handle)
        assert_eq(type(spec.color_name), "string")
        assert_eq(type(spec.plugin_name), "string")
        assert_eq(type(spec.url), "string")
        assert_eq(spec.install_path, string.gsub(handle, "/", "-"))
        assert_true(specs_by_color_name[spec.color_name] == spec)
      end
      assert_eq(count, #color_names)
    end)
    it("sorts color names case insensitively", function()
      local color_names = db.get_color_names()
      for i = 2, #color_names do
        local prev = string.lower(color_names[i - 1])
        local curr = string.lower(color_names[i])
        assert_true(prev <= curr)
      end
    end)
    it("applies overrides", function()
      local specs_by_handle = db.get_specs_by_handle()
      local solarized8 = specs_by_handle["lifepillar/vim-solarized8"]
      assert_eq(solarized8.url, "https://codeberg.org/lifepillar/vim-solarized8")
      assert_eq(solarized8.git_branch, "neovim")
      local dracula = specs_by_handle["dracula/vim"]
      assert_eq(dracula.plugin_name, "dracula")
      assert_eq(dracula.url, "https://github.com/dracula/vim")
      assert_eq(dracula.git_branch, nil)
    end)
  end)
end)
