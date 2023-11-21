--- @param l any[]
--- @param f fun(v:any):number
--- @return number
local function min(l, f)
    local result = 2 ^ 31 - 1
    for _, i in ipairs(l) do
        result = math.min(result, f(i))
    end
    return result
end

--- @return integer
local function randint()
    local s1 = vim.loop.getpid()
    local s2, s3 = vim.loop.gettimeofday()
    local s4 = math.random()
    local int32_max = 2 ^ 31 - 1
    local r = math.min(s1, int32_max)
    r = math.min(r + s2, int32_max)
    r = math.min(r + s3, int32_max)
    r = math.min(r + s4, int32_max)
    return math.floor(r)
end

--- @param s string
--- @param t string
--- @return boolean
local function string_endswith(s, t)
    return string.len(s) >= string.len(t) and s:sub(#s - #t + 1) == t
end

--- @param s string
--- @param t string
--- @param start integer?
--- @return integer?
local function string_find(s, t, start)
    -- start = start or 1
    -- local result = vim.fn.stridx(s, t, start - 1)
    -- return result >= 0 and (result + 1) or nil

    start = start or 1
    for i = start, #s do
        local match = true
        for j = 1, #t do
            if i + j - 1 > #s then
                match = false
                break
            end
            local a = string.byte(s, i + j - 1)
            local b = string.byte(t, j)
            if a ~= b then
                match = false
                break
            end
        end
        if match then
            return i
        end
    end
    return nil
end

local M = {
    min = min,
    randint = randint,
    string_endswith = string_endswith,
    string_find = string_find,
}

return M
