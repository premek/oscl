-- lua-MessagePack  0.5.1
-- Copyright (c) 2012-2018 Francois Perrad"
-- licensed under the terms of the MIT/X11 license
-- thanks :)

local floor = require'math'.floor
local huge = require'math'.huge
local ldexp = require'math'.ldexp or require'mathx'.ldexp

return function (s)
    if #s < 4 then
	    error "missing bytes"
    end
    local b1, b2, b3, b4 = s:sub(1, 4):byte(1, 4)
    local sign = b1 > 0x7F
    local expo = (b1 % 0x80) * 0x2 + floor(b2 / 0x80)
    local mant = ((b2 % 0x80) * 0x100 + b3) * 0x100 + b4
    if sign then
        sign = -1
    else
        sign = 1
    end
    local n
    if mant == 0 and expo == 0 then
        n = sign * 0.0
    elseif expo == 0xFF then
        if mant == 0 then
            n = sign * huge
        else
            n = 0.0/0.0
        end
    else
        n = sign * ldexp(1.0 + mant / 0x800000, expo - 0x7F)
    end
    return n
end
