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

--- @param a integer
--- @param b integer
--- @return integer
local function math_mod(a, b)
    return math.floor(math.fmod(a, b))
end

--- @param maximal integer?
--- @return integer
local function randint(maximal)
    local int32_max = 2 ^ 31 - 1
    maximal = maximal or int32_max
    local s1 = vim.loop.getpid()
    local s2, s3 = vim.loop.gettimeofday()
    local s4 = math.random()
    local r = math_mod(s1, maximal)
    r = math_mod(r * 3 + s2, maximal)
    r = math_mod(r * 7 + s3, maximal)
    r = math_mod(r * 11 + s4, maximal)
    return r
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
    math_mod = math_mod,
    randint = randint,
    string_endswith = string_endswith,
    string_find = string_find,
}

return M
