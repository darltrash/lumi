-- vec2.lua: A simple 2D vector library

--[[
    Copyright (c) 2022 Nelson Lopez
    
    This software is provided 'as-is', without any express or implied warranty. 
    In no event will the authors be held liable for any damages arising from the use of this software.
    
    Permission is granted to anyone to use this software for any purpose, 
    including commercial applications, and to alter it and redistribute it freely, 
    subject to the following restrictions:

    1. The origin of this software must not be misrepresented; 
        you must not claim that you wrote the original software. 
        If you use this software in a product, an acknowledgment 
        in the product documentation would be appreciated but is not required.

    2. Altered source versions must be plainly marked as such, 
        and must not be misrepresented as being the original software.

    3. This notice may not be removed or altered from any source distribution.
]]

local vector = {}
vector.__index = vector
vector.__type = "vec2"

local function isVector(a)
    return getmetatable(a) == vector
end

vector.is_vector = isVector

vector.new = function (x, y)
    return setmetatable(
        { x = x, y = y }, vector
    )
end

vector.copy = function (self)
    return vector.new(self.x, self.y)
end

vector.from_angle = function (theta, magnitude)
    return vector.new(
         math.cos(theta)*magnitude,
        -math.sin(theta)*magnitude
    )
end

vector.to_angle = function (self)
    return -math.atan2(self.y, self.x)
end

vector.rotate = function (self, theta)
    local s = math.sin(theta)
    local c = math.cos(theta)
    
    return vector.new(
         (c * self.x) + (s * self.y),
        -(s * self.x) + (c * self.y)
    )
end

vector.from_table = function (t)
    return vector.new(
        tonumber(t.x) or 0,
        tonumber(t.y) or 0
    )
end

vector.from_array = function (array)
    return vector.new(array[1], array[2])
end

vector.to_array = function (self)
    return {self.x, self.y}
end

vector.unpack = function (self)
    return self.x, self.y
end

vector.get_magnitude = function (self)
    return math.sqrt(self.x^2 + self.y^2)
end

vector.normalize = function (self)
    local m = self:get_magnitude()
    return m == 0 and self or (self / m)
end

vector.dist = function (a, b)
    return math.sqrt((a.x-b.x)^2 + (a.y-b.y)^2)
end

vector.dot = function (a, b)
    return a.x * b.x + a.y * b.y
end

vector.sign = function (a)
    return vector.new(
        (a.x == 0) and 0 or (a.x > 0) and 1 or -1,
        (a.y == 0) and 0 or (a.y > 0) and 1 or -1
    )
end

local clamp = function (x, min, max)
    return x < min and min or (x > max and max or x)
end
local lerp = function (a, b, t)
    return a * (1-t) + b * t
end

vector.clamp = function (a, min, max)
    local minx, miny = min, min
    if isVector(min) then
        minx, miny = min:unpack()
    end
    
    local maxx, maxy = max, max
    if isVector(max) then
        maxx, maxy = max:unpack()
    end
    
    return vector.new(clamp(a.x, minx, maxx), clamp(a.y, miny, maxy))
end

vector.lerp = function (a, b, t)
    return isVector(b) and vector.new(lerp(a.x, b.x, t), lerp(a.y, b.y, t))
                        or vector.new(lerp(a.x, b,   t), lerp(a.y, b,   t))
end

vector.round = function(a, b)
    return isVector(b) and vector.new(math.floor((a.x/b.x) + .5)*b.x, math.floor((a.y/b.y) + .5)*b.y)
                        or vector.new(math.floor((a.x/b) + .5)*b, math.floor((a.y/b) + .5)*b)
end


vector.__call = function (self, ...)
    return self:copy()
end

vector.__add = function (a, b)
    return isVector(b) and vector.new(a.x+b.x, a.y+b.y)
                        or vector.new(a.x+b,   a.y+b)
end

vector.__sub = function (a, b)
    return isVector(b) and vector.new(a.x-b.x, a.y-b.y)
                        or vector.new(a.x-b,   a.y-b)
end

vector.__mul = function (a, b)
    return isVector(b) and vector.new(a.x*b.x, a.y*b.y)
                        or vector.new(a.x*b,   a.y*b)
end

vector.__div = function (a, b)
    return isVector(b) and vector.new(a.x/b.x, a.y/b.y)
                        or vector.new(a.x/b,   a.y/b)
end

vector.__mod = function (a, b)
    return isVector(b) and vector.new(a.x%b.x, a.y%b.y)
                        or vector.new(a.x%b,   a.y%b)
end

vector.__pow = function (a, b)
    return isVector(b) and vector.new(a.x^b.x, a.y^b.y)
                        or vector.new(a.x^b,   a.y^b)
end

vector.__unm = function (a)
    a.x = -a.x
    a.y = -a.y
    return a
end

vector.__eq = function (a, b)
    return isVector(b) and (a.x==b.x and a.y==b.y)
                        or (a.x==b   and a.y==b)
end

vector.__lt = function (a, b)
    return isVector(b) and (a.x>b.x and a.y>b.y)
                        or (a.x>b   and a.y>b)
end

vector.__le = function (a, b)
    return isVector(b) and (a.x>=b.x and a.y>=b.y)
                        or (a.x>=b   and a.y>=b)
end

vector.__tostring = function (a)
    return ("vec2(%s, %s)"):format(a.x, a.y)
end

vector.zero = vector.new(0, 0)
vector.one  = vector.new(1, 1)

return setmetatable(vector, {
    __call = function (self, ...)
        return vector.new(...)
    end
})
