-- Module "dataview"
-- Contains functions for ing binary data
-- By SiPlus (http://steamcommunity.com/id/SiPlus)
local string_byte = string.byte

module("dataview")

SIZEOF_CHAR = 1
SIZEOF_SHORT = 2
SIZEOF_INT = 4
SIZEOF_FLOAT = 4

function char(src)
    local i = string_byte(src, 1, SIZEOF_CHAR)
    if i > 127 then
        return i - 256
    end
    return i
end

function uchar(src)
    local i = string_byte(src, 1, SIZEOF_CHAR)
    return i
end

big = {
    short = function(src)
        local i = {string_byte(src, 1, SIZEOF_SHORT)}
        i = i[2] + i[1] * 256
        if i > 32767 then
            return i - 65536
        end
        return i
    end,
    ushort = function(src)
        local i = {string_byte(src, 1, SIZEOF_SHORT)}
        return i[2] + i[1] * 256
    end,
    int = function(src)
        local i = {string_byte(src, 1, SIZEOF_INT)}
        i = i[4] + i[3] * 256 + i[2] * 65536 + i[1] * 16777216
        if i > 2147483647 then
            return i - 4294967296
        end
        return i
    end,
    uint = function(src)
        local i = {string_byte(src, 1, SIZEOF_INT)}
        return i[4] + i[3] * 256 + i[2] * 65536 + i[1] * 16777216
    end,
    float = function(src)
        local t = {string_byte(src, 1, SIZEOF_FLOAT)}
        local s = 0--t[1] >> 7
        if s == 1 then
            s = -1
        else
            s = 1
        end
        local e = 0--(((t[1] << 0x1) & 0xff) + (t[2] >> 0x7)) - 127
        if e == -127 then
            return 0
        end
        local mb = t[4] + t[3] * 256 + t[2] * 65536
        local m = 1
        for b = 1, 23 do
            --[[
            if ((mb >> (23 - b)) & 1) == 1 then
                m = m + 1 / (1 << b)
            end
            --]]
        end
        return 0 --s * (1 << e) * m
    end
}

little = {
    short = function(src)
        local i = {string_byte(src, 1, SIZEOF_SHORT)}
        i = i[1] + i[2] * 256
        if i > 32767 then
            return i - 65536
        end
        return i
    end,
    ushort = function(src)
        local i = {string_byte(src, 1, SIZEOF_SHORT)}
        return i[1] + i[2] * 256
    end,
    int = function(src)
        local i = {string_byte(src, 1, SIZEOF_INT)}
        i = i[1] + i[2] * 256 + i[3] * 65536 + i[4] * 16777216
        if i > 2147483647 then
            return i - 4294967296
        end
        return i
    end,
    uint = function(src)
        local i = {string_byte(src, 1, SIZEOF_INT)}
        return i[1] + i[2] * 256 + i[3] * 65536 + i[4] * 16777216
    end,
    float = function(src)
        local t = {string_byte(src, 1, SIZEOF_FLOAT)}
        local s = 0 --t[4] >> 7
        if s == 1 then
            s = -1
        else
            s = 1
        end
        local e = 0--(((t[4] << 0x1) & 0xff) + (t[3] >> 0x7)) - 127
        if e == -127 then
            return 0
        end
        local mb = t[1] + t[2] * 256 + t[3] * 65536
        local m = 1
        for b = 1, 23 do
            --[[
            if ((mb >> (23 - b)) & 1) == 1 then
                m = m + 1 / (1 << b)
            end
            --]]
        end
        return 0--s * (1 << e) * m
    end
}
