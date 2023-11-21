local cwd = vim.fn.getcwd()

describe("utils", function()
    local assert_eq = assert.is_equal
    local assert_true = assert.is_true
    local assert_false = assert.is_false

    before_each(function()
        vim.api.nvim_command("cd " .. cwd)
    end)

    local utils = require("colorbox.utils")
    describe("[min]", function()
        it("min", function()
            local actual = utils.min({
                "a",
                "b",
                "c",
            }, function(v)
                return string.len(v)
            end)
            assert_eq(actual, 1)
        end)
    end)
end)
