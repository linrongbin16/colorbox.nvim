local cwd = vim.fn.getcwd()

describe("colorbox", function()
    local assert_eq = assert.is_equal
    local assert_true = assert.is_true
    local assert_false = assert.is_false

    before_each(function()
        vim.api.nvim_command("cd " .. cwd)
    end)

    local github_actions = os.getenv("GITHUB_ACTIONS") == "true"
    local colorbox = require("colorbox")
    local db = require("colorbox.db")
    colorbox.setup({
        debug = true,
        file_log = true,
    })

    describe("[update]", function()
        it("update", function()
            if not github_actions then
                colorbox.update()
            end
        end)
    end)
    describe("[_primary_color_name_filter]", function()
        it("test", function()
            local ColorNameToColorSpecsMap =
                db.get_color_name_to_color_specs_map()
            local input_color = "tokyonight"
            local input_spec = ColorNameToColorSpecsMap[input_color]
            for _, c in ipairs(input_spec.color_names) do
                local actual =
                    colorbox._primary_color_name_filter(c, input_spec)
                print(
                    string.format(
                        "input color:%s, current color:%s, actual:%s\n",
                        vim.inspect(input_color),
                        vim.inspect(c),
                        vim.inspect(actual)
                    )
                )
                assert_eq(actual, input_color ~= c)
            end
        end)
    end)
    describe("[_should_filter]", function()
        it("test", function()
            local ColorNameToColorSpecsMap =
                db.get_color_name_to_color_specs_map()
            for color, spec in pairs(ColorNameToColorSpecsMap) do
                local actual = colorbox._should_filter(color, spec)
                assert_eq(type(actual), "boolean")
            end
        end)
    end)
    describe("[_force_sync_syntax]", function()
        it("test", function()
            colorbox._force_sync_syntax()
        end)
    end)
    describe("[_save_track/_load_previous_track]", function()
        it("test", function()
            colorbox._save_track("tokyonight")
            local actual = colorbox._load_previous_track() --[[@as colorbox.PreviousTrack]]
            print(
                string.format("load previous track:%s\n", vim.inspect(actual))
            )
            if actual ~= nil then
                assert_eq(type(actual), "table")
                assert_eq(type(actual.color_name), "string")
                assert_true(actual.color_number > 0)
            end
        end)
    end)
    describe(
        "[_get_next_color_name_by_idx/_get_prev_color_name_by_idx]",
        function()
            it("_get_next_color_name_by_idx", function()
                local colornames = colorbox._get_filtered_color_names_list()
                local colorindexes =
                    colorbox._get_filtered_color_name_to_index_map()
                for i, c in ipairs(colornames) do
                    local actual = colorbox._get_next_color_name_by_idx(i)
                    if i == #colornames then
                        assert_eq(colorindexes[actual], 1)
                    else
                        assert_eq(i + 1, colorindexes[actual])
                    end
                end
            end)
            it("_get_prev_color_name_by_idx", function()
                local colornames = colorbox._get_filtered_color_names_list()
                local colorindexes =
                    colorbox._get_filtered_color_name_to_index_map()
                for i, c in ipairs(colornames) do
                    local actual = colorbox._get_prev_color_name_by_idx(i)
                    if i == 1 then
                        assert_eq(colorindexes[actual], #colornames)
                    else
                        assert_eq(i - 1, colorindexes[actual])
                    end
                end
            end)
        end
    )
end)
