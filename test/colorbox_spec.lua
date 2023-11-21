local cwd = vim.fn.getcwd()

describe("colorbox", function()
    local assert_eq = assert.is_equal
    local assert_true = assert.is_true
    local assert_false = assert.is_false

    before_each(function()
        vim.api.nvim_command("cd " .. cwd)
    end)

    local colorbox = require("colorbox")
    describe("[setup]", function()
        it("setup", function()
            assert_true(true)
        end)
    end)
end)
