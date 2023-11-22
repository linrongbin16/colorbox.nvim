local cwd = vim.fn.getcwd()

describe("logger", function()
    local assert_eq = assert.is_equal
    local assert_true = assert.is_true
    local assert_false = assert.is_false

    before_each(function()
        vim.api.nvim_command("cd " .. cwd)
    end)

    local logger = require("colorbox.logger")
    local LogLevels = require("colorbox.logger").LogLevels
    local LogLevelNames = require("colorbox.logger").LogLevelNames
    logger.setup({
        level = LogLevels.DEBUG,
        console_log = true,
        file_log = true,
        file_log_name = "colorbox_test.log",
        file_log_dir = ".",
    })
    describe("[logger]", function()
        it("debug", function()
            logger.debug("debug without parameters")
            logger.debug("debug with 1 parameters: %s", "a")
            logger.debug("debug with 2 parameters: %s, %d", "a", 1)
            logger.debug("debug with 3 parameters: %s, %d, %f", "a", 1, 3.12)
            assert_true(true)
        end)
        it("info", function()
            logger.info("info without parameters")
            logger.info("info with 1 parameters: %s", "a")
            logger.info("info with 2 parameters: %s, %d", "a", 1)
            logger.info("info with 3 parameters: %s, %d, %f", "a", 1, 3.12)
            assert_true(true)
        end)
        it("warn", function()
            logger.warn("warn without parameters")
            logger.warn("warn with 1 parameters: %s", "a")
            logger.warn("warn with 2 parameters: %s, %d", "a", 1)
            logger.warn("warn with 3 parameters: %s, %d, %f", "a", 1, 3.12)
            assert_true(true)
        end)
        it("err", function()
            logger.err("err without parameters")
            logger.err("err with 1 parameters: %s", "a")
            logger.err("err with 2 parameters: %s, %d", "a", 1)
            logger.err("err with 3 parameters: %s, %d, %f", "a", 1, 3.12)
            assert_true(true)
        end)
        it("ensure", function()
            logger.ensure(true, "ensure without parameters")
            logger.ensure(true, "ensure with 1 parameters: %s", "a")
            logger.ensure(true, "ensure with 2 parameters: %s, %d", "a", 1)
            logger.ensure(
                true,
                "ensure with 3 parameters: %s, %d, %f",
                "a",
                1,
                3.12
            )
            assert_true(true)
            local ok1, err1 =
                pcall(logger.ensure, false, "ensure without parameters")
            print(vim.inspect(err1) .. "\n")
            assert_false(ok1)
            local ok2, err2 =
                pcall(logger.ensure, false, "ensure with 1 parameters: %s", "a")
            print(vim.inspect(err2) .. "\n")
            assert_false(ok2)
            local ok3, err3 = pcall(
                logger.ensure,
                false,
                "ensure with 2 parameters: %s, %d",
                "a",
                1
            )
            print(vim.inspect(err3) .. "\n")
            assert_false(ok3)
            local ok4, err4 = pcall(
                logger.ensure,
                false,
                "ensure with 3 parameters: %s, %d, %f",
                "a",
                1,
                3.12
            )
            print(vim.inspect(err4) .. "\n")
            assert_false(ok4)
        end)
        it("throw", function()
            local ok1, msg1 = pcall(logger.throw, "throw without params")
            assert_false(ok1)
            assert_eq(type(msg1), "string")
            local ok2, msg2 =
                pcall(logger.throw, "throw with 1 params: %s", "a")
            assert_false(ok2)
            assert_eq(type(msg2), "string")
            local ok3, msg3 =
                pcall(logger.throw, "throw with 2 params: %s, %d", "a", 2)
            assert_false(ok3)
            assert_eq(type(msg3), "string")
        end)
    end)
    describe("[LogLevels]", function()
        it("check levels", function()
            for k, v in pairs(LogLevels) do
                assert_eq(type(k), "string")
                assert_eq(type(v), "number")
            end
        end)
        it("check level names", function()
            for v, k in pairs(LogLevelNames) do
                assert_eq(type(k), "string")
                assert_eq(type(v), "number")
            end
        end)
    end)
    describe("[echo]", function()
        it("info", function()
            logger.echo(LogLevels.INFO, "echo without parameters")
            logger.echo(LogLevels.INFO, "echo with 1 parameters: %s", "a")
            logger.echo(
                LogLevels.INFO,
                "echo with 2 parameters: %s, %d",
                "a",
                1
            )
            logger.echo(
                LogLevels.INFO,
                "echo with 3 parameters: %s, %d, %f",
                "a",
                1,
                3.12
            )
            assert_true(true)
        end)
        it("debug", function()
            logger.echo(LogLevels.DEBUG, "echo without parameters")
            logger.echo(LogLevels.DEBUG, "echo with 1 parameters: %s", "a")
            logger.echo(
                LogLevels.DEBUG,
                "echo with 2 parameters: %s, %d",
                "a",
                1
            )
            logger.echo(
                LogLevels.DEBUG,
                "echo with 3 parameters: %s, %d, %f",
                "a",
                1,
                3.12
            )
            assert_true(true)
        end)
        it("warn", function()
            logger.echo(LogLevels.WARN, "echo without parameters")
            logger.echo(LogLevels.WARN, "echo with 1 parameters: %s", "a")
            logger.echo(
                LogLevels.WARN,
                "echo with 2 parameters: %s, %d",
                "a",
                1
            )
            logger.echo(
                LogLevels.WARN,
                "echo with 3 parameters: %s, %d, %f",
                "a",
                1,
                3.12
            )
            assert_true(true)
        end)
        it("err", function()
            logger.echo(LogLevels.ERROR, "echo without parameters")
            logger.echo(LogLevels.ERROR, "echo with 1 parameters: %s", "a")
            logger.echo(
                LogLevels.ERROR,
                "echo with 2 parameters: %s, %d",
                "a",
                1
            )
            logger.echo(
                LogLevels.ERROR,
                "echo with 3 parameters: %s, %d, %f",
                "a",
                1,
                3.12
            )
            assert_true(true)
        end)
    end)
end)
