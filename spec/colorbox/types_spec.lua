local cwd = vim.uv.cwd()

describe("colorbox.types", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false
  local assert_nil = assert.is_nil

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local types = require("colorbox.types")

  describe("[file_io]", function()
    local tmpdir = vim.fs.dirname(vim.fn.tempname())
    local tmpfile = vim.fs.joinpath(tmpdir, "colorbox_types_spec_tmpfile")

    before_each(function()
      vim.fn.mkdir(tmpdir, "p")
      vim.fn.delete(tmpfile)
    end)

    it("read_file on missing file", function()
      local content, err = types.read_file(tmpfile)
      assert_nil(content)
      assert_eq(type(err), "string")
      assert_true(string.len(err) > 0)
    end)

    it("write_file then read_file", function()
      local ok, err = types.write_file(tmpfile, "hello\nworld")
      assert_true(ok)
      assert_nil(err)

      local content, read_err = types.read_file(tmpfile)
      assert_nil(read_err)
      assert_eq(content, "hello\nworld")
    end)

    it("write_file empty content", function()
      assert_true(types.write_file(tmpfile, ""))

      local content, err = types.read_file(tmpfile)
      assert_nil(err)
      assert_eq(content, "")
    end)

    it("write_file on missing directory", function()
      local ok, err = types.write_file(vim.fs.joinpath(tmpdir, "no_such_dir", "tmpfile"), "a")
      assert_false(ok)
      assert_eq(type(err), "string")
      assert_true(string.len(err) > 0)
    end)

    it("write_file overwrites an existing file", function()
      assert_true(types.write_file(tmpfile, "first"))
      assert_true(types.write_file(tmpfile, "second"))
      assert_eq(types.read_file(tmpfile), "second")
    end)

    it("write_file leaves no staging file behind", function()
      assert_true(types.write_file(tmpfile, "hello"))

      local name = vim.fs.basename(tmpfile)
      local names = {}
      for entry, _ in vim.fs.dir(tmpdir) do
        table.insert(names, entry)
      end
      table.sort(names)
      assert.same({ name }, names)
    end)

    it("write_file replaces the destination as a whole", function()
      -- The staging file is renamed over the destination, so the destination is
      -- either the old content or the new one, never a truncated file.
      local payload = '{"color_name":"apprentice","color_number":1}'
      assert_true(types.write_file(tmpfile, "old"))
      assert_eq(types.read_file(tmpfile), "old")

      assert_true(types.write_file(tmpfile, payload))
      assert_eq(types.read_file(tmpfile), payload)
    end)
  end)

  describe("[string]", function()
    it("str_empty", function()
      assert_true(types.str_empty(""))
      assert_true(types.str_empty(nil))
      assert_false(types.str_empty("a"))
    end)
    it("str_startswith", function()
      assert_true(types.str_startswith("colorbox", "color"))
      assert_false(types.str_startswith("colorbox", "box"))
    end)
  end)

  describe("[table]", function()
    it("tbl_empty", function()
      assert_true(types.tbl_empty(nil))
      assert_true(types.tbl_empty({}))
      assert_false(types.tbl_empty({ 1 }))
    end)
  end)

  describe("[number]", function()
    it("clamp", function()
      assert_eq(types.clamp(5, 1, 3), 3)
      assert_eq(types.clamp(-1, 1, 3), 1)
      assert_eq(types.clamp(2, 1, 3), 2)
      -- missing bounds fall back to the int32 range.
      assert_eq(types.clamp(types.INT32_MAX + 1, nil, 3), 3)
      assert_eq(types.clamp(types.INT32_MIN - 1, 1, nil), 1)
      -- non-number arguments are rejected.
      assert.has_error(function()
        types.clamp(nil, 1, 3)
      end)
      assert.has_error(function()
        types.clamp("2", 1, 3)
      end)
      assert.has_error(function()
        types.clamp(2, "1", 3)
      end)
    end)
    it("greater_than", function()
      assert_true(types.greater_than(2, 1))
      assert_false(types.greater_than(1, 2))
      assert_false(types.greater_than(1, 1))
      assert_false(types.greater_than(nil, 1))
      assert_false(types.greater_than(1, nil))
      assert_false(types.greater_than("2", 1))
    end)
    it("mod", function()
      assert_eq(types.mod(5, 3), 2)
      assert_eq(types.mod(-1, 3), 2)
      assert_eq(types.mod(-5, 3), 1)
      assert_eq(types.mod(1, 3), 1)
      assert.has_error(function()
        types.mod(1, 0)
      end)
      assert.has_error(function()
        types.mod(nil, 3)
      end)
      assert.has_error(function()
        types.mod(1, "3")
      end)
    end)
    it("random", function()
      for _ = 1, 16 do
        local n = types.random(1, 10)
        assert_true(n >= 1 and n <= 10)
      end
      for _ = 1, 16 do
        local n = types.random(-5, -1)
        assert_true(n >= -5 and n <= -1)
      end
      -- degenerate range collapses to a single value.
      assert_eq(types.random(7, 7), 7)
      -- non-number or inverted bounds are rejected.
      assert.has_error(function()
        types.random(10, 1)
      end)
      assert.has_error(function()
        types.random(nil, 1)
      end)
      assert.has_error(function()
        types.random(1, nil)
      end)
      assert.has_error(function()
        types.random("1", 10)
      end)
    end)
    it("random is roughly uniform", function()
      local buckets = { 0, 0, 0, 0 }
      for _ = 1, 4000 do
        local n = types.random(1, 4) --[[@as integer]]
        buckets[n] = buckets[n] + 1
      end
      for i = 1, 4 do
        assert_true(buckets[i] > 700, string.format("bucket %d: %d", i, buckets[i]))
      end
    end)
  end)
end)
