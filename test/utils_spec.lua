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
                "de",
            }, function(v)
                return string.len(v)
            end)
            assert_eq(actual, 1)
        end)
    end)
    describe("[randint]", function()
        it("randint", function()
            local last_value = nil
            for i = 1, 100 do
                local actual = utils.randint()
                assert_true(actual ~= last_value)
                last_value = actual
            end
        end)
    end)
    describe("[string_endswith]", function()
        it("endswith", function()
            assert_true(utils.string_endswith("asdf", "df"))
            assert_true(utils.string_endswith("hello world", " world"))
            assert_true(
                utils.string_endswith(
                    "folke/tokyonight.nvim",
                    "/tokyonight.nvim"
                )
            )
            assert_false(
                utils.string_endswith(
                    "folke/tokyonight.nvim",
                    "/tokyonight%.nvim"
                )
            )
        end)
    end)
end)
