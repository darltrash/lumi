-- vec2.lua: A simple 3D vector library

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

local vector = { x = 0, y = 0, z = 0 }
vector.__index = vector
vector.__type = "vec3"
vector.name = vector.__type

local function is_vector(a)
    return getmetatable(a) == vector
end

vector.is_vector = is_vector

vector.new = function (x, y, z)
    return setmetatable(
        { x = x, y = y, z = z }, vector
    )
end

vector.copy = function (self)
    return vector.new(self.x, self.y, self.z)
end

vector.rotate = function (self, phi, axis)
	local u = axis:normalize()
	local c = math.cos(phi)
	local s = math.sin(phi)

	return vector.new(
		self:dot(vector.new(
            (c + u.x * u.x * (1 - c)), 
            (u.x * u.y * (1 - c) - u.z * s),
            (u.x * u.z * (1 - c) + u.y * s)
        )),
		self:dot(vector.new(
            (u.y * u.x * (1 - c) + u.z * s),
            (c + u.y * u.y * (1 - c)),
            (u.y * u.z * (1 - c) - u.x * s)
        )),
		self:dot(vector.new(
            (u.z * u.x * (1 - c) - u.y * s),
            (u.z * u.y * (1 - c) + u.x * s),
            (c + u.z * u.z * (1 - c))
        ))
	)
end

vector.from_table = function (t)
    return vector.new(
        tonumber(t.x) or 0,
        tonumber(t.y) or 0,
        tonumber(t.z) or 0
    )
end

vector.from_array = function (array)
    return vector.new(array[1], array[2], array[3])
end

vector.to_array = function (self)
    return {self.x, self.y, self.z}
end

vector.unpack = function (self)
    return self.x, self.y, self.z
end

vector.magnitude2 = function (self)
    return self.x*self.x + self.y*self.y + self.z*self.z
end

vector.magnitude = function (self)
    return math.sqrt(self:magnitude2())
end

vector.normalize = function (self)
    local m = self:magnitude()
    return m ~= 0 and (self / m) or vector(0, 0, 0)
end

vector.dist = function (a, b)
    local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

vector.dot = function (a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

vector.reflect = function (a, b)
    return a - (b * vector.dot(a, b) * 2)
end

vector.cross = function (a, b)
    return vector.new(
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x
	)
end

vector.sign = function (a)
    return vector.new(
        (a.x == 0) and 0 or (a.x > 0) and 1 or -1,
        (a.y == 0) and 0 or (a.y > 0) and 1 or -1,
        (a.z == 0) and 0 or (a.z > 0) and 1 or -1
    )
end

local clamp = function (x, min, max)
    return math.min(math.max(min, x), max)
end
local lerp = function (a, b, t)
    return a * (1-t) + b * t
end
local decay = function (value, target, rate, delta)
    return lerp(target, value, math.exp(-math.exp(rate)*delta))
end

vector.clamp = function (a, min, max)
    local minx, miny, minz = min, min, min
    if is_vector(min) then
        minx, miny, minz = min:unpack()
    end
    
    local maxx, maxy, maxz = max, max, max
    if is_vector(max) then
        maxx, maxy, maxz = max:unpack()
    end
    
    return vector.new(
        clamp(a.x, minx, maxx), 
        clamp(a.y, miny, maxy),
        clamp(a.z, minz, maxz)
    )
end

vector.lerp = function (a, b, t)
    return is_vector(b) and
        vector.new(
            lerp(a.x, b.x, t), 
            lerp(a.y, b.y, t), 
            lerp(a.z, b.z, t)
        )
        or
        vector.new(
            lerp(a.x, b, t),
            lerp(a.y, b, t),
            lerp(a.z, b, t)
        )
end

vector.decay = function (a, b, rate, delay)
    return is_vector(b) and
        vector.new(
            decay(a.x, b.x, rate, delay),
            decay(a.y, b.y, rate, delay),
            decay(a.z, b.z, rate, delay)
        )
        or
        vector.new(
            decay(a.x, b, rate, delay),
            decay(a.y, b, rate, delay),
            decay(a.z, b, rate, delay)
        )
end

vector.round = function(a, b)
    b = b or 1
    return is_vector(b) and 
        vector.new(
            math.floor((a.x / b.x) + .5) * b.x,
            math.floor((a.y / b.y) + .5) * b.y,
            math.floor((a.z / b.z) + .5) * b.z
        )
        or
        vector.new(
            math.floor((a.x / b) + .5) * b,  
            math.floor((a.y / b) + .5) * b,
            math.floor((a.z / b) + .5) * b
        )
end


vector.__call = function (self, ...)
    return self:copy()
end

vector.__add = function (a, b)
    return is_vector(b) and vector.new(a.x+b.x, a.y+b.y, a.z+b.z)
                        or vector.new(a.x+b,   a.y+b  , a.z+b)
end
vector.add = vector.__add

vector.__sub = function (a, b)
    return is_vector(b) and vector.new(a.x-b.x, a.y-b.y, a.z-b.z)
                        or vector.new(a.x-b,   a.y-b  , a.z-b)
end
vector.sub = vector.__sub

vector.__mul = function (a, b)
    return is_vector(b) and vector.new(a.x*b.x, a.y*b.y, a.z*b.z)
                        or vector.new(a.x*b,   a.y*b  , a.z*b)
end
vector.mul = vector.__mul

vector.__div = function (a, b)
    return is_vector(b) and vector.new(a.x/b.x, a.y/b.y, a.z/b.z)
                        or vector.new(a.x/b,   a.y/b  , a.z/b)
end
vector.div = vector.__div

vector.__mod = function (a, b)
    return is_vector(b) and vector.new(a.x%b.x, a.y%b.y, a.z%b.z)
                        or vector.new(a.x%b,   a.y%b  , a.z%b)
end
vector.modulo = vector.__mod

vector.__pow = function (a, b)
    return is_vector(b) and vector.new(a.x^b.x, a.y^b.y, a.z^b.z)
                        or vector.new(a.x^b,   a.y^b  , a.z^b)
end
vector.pow = vector.__pow

vector.__unm = function (a)
    a.x = -a.x
    a.y = -a.y
    a.z = -a.z
    return a
end

vector.__eq = function (a, b)
    return is_vector(b) and (a.x==b.x and a.y==b.y and a.z==b.z)
                        or (a.x==b   and a.y==b   and a.z==b)
end

vector.__lt = function (a, b)
    return is_vector(b) and (a.x>b.x and a.y>b.y and a.z>b.z)
                        or (a.x>b   and a.y>b   and a.z>b)
end

vector.__le = function (a, b)
    return is_vector(b) and (a.x>=b.x and a.y>=b.y and a.z>=b.z)
                        or (a.x>=b   and a.y>=b   and a.z>=b)
end

vector.__tostring = function (a)
    return ("vec3(%s, %s, %s)"):format(a.x, a.y, a.z)
end

vector.zero = vector.new(0, 0, 0)
vector.one  = vector.new(1, 1, 1)

return setmetatable(vector, {
    __call = function (self, ...)
        return vector.new(...)
    end
})