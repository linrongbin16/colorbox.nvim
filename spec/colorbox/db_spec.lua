local cwd = vim.fn.getcwd()

describe("colorbox.db", function()
    local assert_eq = assert.is_equal
    local assert_true = assert.is_true
    local assert_false = assert.is_false

    before_each(function()
        vim.api.nvim_command("cd " .. cwd)
    end)

    local db = require("colorbox.db")
    describe("[get_xxxapi]", function()
        it("get_handle_to_color_specs_map", function()
            local HandleToColorSpecsMap = db.get_handle_to_color_specs_map()
            assert_eq(type(HandleToColorSpecsMap), "table")
        end)
        it("get_git_path_to_color_specs_map", function()
            local GitPathToColorSpecsMap = db.get_git_path_to_color_specs_map()
            assert_eq(type(GitPathToColorSpecsMap), "table")
        end)
        it("get_git_path_to_color_specs_map", function()
            local ColorNameToColorSpecsMap =
                db.get_color_name_to_color_specs_map()
            assert_eq(type(ColorNameToColorSpecsMap), "table")
        end)
        it("get_color_names_list", function()
            local ColorNamesList = db.get_color_names_list()
            assert_eq(type(ColorNamesList), "table")
        end)
    end)
end)
