local cwd = vim.fn.getcwd()

describe("colorbox", function()
    local assert_eq = assert.is_equal
    local assert_true = assert.is_true
    local assert_false = assert.is_false

    before_each(function()
        vim.api.nvim_command("cd " .. cwd)
    end)

    local colorbox = require("colorbox")
    local db = require("colorbox.db")
    local filter = require("colorbox.filter")
    colorbox.setup({
        debug = true,
        file_log = true,
    })

    describe("filter", function()
        it("run", function()
            local ColorNameToColorSpecsMap = db.get_color_name_to_color_specs_map()
            for color, spec in pairs(ColorNameToColorSpecsMap) do
                local actual = filter.run(color, spec)
                assert_eq(type(actual), "boolean")
            end
        end)
    end)
end)
