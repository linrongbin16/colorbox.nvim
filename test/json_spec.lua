local cwd = vim.fn.getcwd()

describe("json", function()
    local assert_eq = assert.is_equal
    local assert_true = assert.is_true
    local assert_false = assert.is_false

    before_each(function()
        vim.api.nvim_command("cd " .. cwd)
    end)

    local json = require("colorbox.json")
    describe("[encode/decode]", function()
        it("encode/decode", function()
            local expect = { a = 1, b = 2 }
            local actual1 = json.encode({ a = 1, b = 2 })
            local actual2 = json.decode(actual1)
            assert_true(vim.deep_equal(actual2, expect))
        end)
    end)
end)
