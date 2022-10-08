-- mat4.lua: A simple 4D matrix library

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

--[[
    NOTICE:
        This library might be underperformant and have a severe lack of features
        It essentially exists because I didn't like the way other libraries worked.
        If you feel this isnt enough for your needs, check out CPML from Excessive!

    CPML: https://github.com/excessive/cpml
]]

local matrix = {
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
}
matrix.__index = matrix
matrix.__type = "mat4"

local FLT_EPSILON = 1.19209290e-07

local function isMatrix(a)
    return getmetatable(a) == matrix
end

-- Checks if a value is a matrix
matrix.is_mat4 = isMatrix

-- Creates a new matrix, defaults to identity 
matrix.new = function (...)
    local values = select(1, ...)
    if type(values) ~= "table" then
        values = {...}
    end

    return setmetatable (
        values, matrix
    )
end

matrix.copy = matrix.new

-- Creates a new matrix from perspective
matrix.from_perspective = function (fov, aspect, near, far)
    local t = math.tan(math.rad(fov) / 2)

	return matrix.new {
        [1]  =  1 / (t * aspect),
        [6]  =  1 / t,
        [11] = -(far + near) / (far - near),
        [12] = -1,
        [15] = -(2 * far * near) / (far - near),
        [16] =  0
    }
end

-- Creates matrix from orthographic projection
matrix.from_ortho = function (left, right, top, bottom, near, far)
    return matrix.new {
        [1]  =  2 / (right - left),
        [6]  =  2 / (top - bottom),
        [11] = -2 / (far - near),
        [13] = -((right + left) / (right - left)),
        [14] = -((top + bottom) / (top - bottom)),
        [15] = -((far + near) / (far - near)),
        [16] =  1
    }
end

local vector = function (a)
    local n = tonumber(a)
    if n then
        return n, n, n, n
    end

    return
        a.x or a[1] or 0,
        a.y or a[2] or 0,
        a.z or a[3] or 0,
        a.w or a[4] or 0
end

local normalize = function (x, y, z)
    local l = math.sqrt(x^2 + y^2 + z^2)
    return x/l, y/l, z/l, l
end

local cross = function (ax, ay, az, bx, by, bz)
    return 
        ay * bz - az * by,
        az * bx - ax * bz,
        ax * by - ay * bx
end

-- Creates matrix from scale vector or number
matrix.from_scale = function (scale)
    local x, y, z = vector(scale)

	return matrix.new {
        [1]  = x,
        [6]  = y,
        [11] = z
    }
end

-- Creates a matrix from a translation vector
matrix.from_translation = function (t)
    local x, y, z = vector(t)

    return matrix.new {
        [13] = x,
        [14] = y,
        [15] = z
    }
end

-- Creates a matrix from an angle and an axis
matrix.from_angle_axis = function (angle, axis)
    local x, y, z, l = normalize(vector(axis))

    if l == 0 then
        return matrix.new {}
    end

	local c = math.cos(angle)
	local s = math.sin(angle)

	return matrix.new {
		x*x*(1-c)+c,   y*x*(1-c)+z*s, x*z*(1-c)-y*s, 0,
		x*y*(1-c)-z*s, y*y*(1-c)+c,   y*z*(1-c)+x*s, 0,
		x*z*(1-c)+y*s, y*z*(1-c)-x*s, z*z*(1-c)+c,   0,
		0,             0,             0,             1
	}
end

-- Create matrix from euler angle (vec3)
matrix.from_euler_angle = function (euler)
    local x, y, z = vector(euler)

    return
        matrix.from_angle_axis(x, { x = 1, y = 0, z = 0 }) *
        matrix.from_angle_axis(y, { x = 0, y = 1, z = 0 }) *
        matrix.from_angle_axis(z, { x = 0, y = 0, z = 1 })
end

-- Create matrix from transform (vec3, vec3, vec3)
matrix.from_transform = function (trans, euler, scale)
    return
        matrix.from_scale(scale) *
        matrix.from_translation(trans) *
        matrix.from_euler_angle(euler)
end

-- Create matrix from eye into target
matrix.look_at = function (eye, look_at, up)
    local eye_x, eye_y, eye_z = vector(eye)
    local look_at_x, look_at_y, look_at_z = vector(look_at)
    local up_x, up_y, up_z = vector(up)

    local z_x, z_y, z_z = normalize(
        eye_x - look_at_x,
        eye_y - look_at_y,
        eye_z - look_at_z
    )

    local x_x, x_y, x_z = normalize(cross(
        up_x, up_y, up_z,
         z_x,  z_y,  z_z
    ))

    local y_x, y_y, y_z = cross(
        z_x, z_y, z_z, 
        x_x, x_y, x_z
    )

    local out =  matrix.new {
	    [1] = x_x,
	    [2] = y_x,
	    [3] = z_x,
	    [4] = 0,
	    [5] = x_y,
	    [6] = y_y,
	    [7] = z_y,
	    [8] = 0,
	    [9] =  x_z,
	    [10] = y_z,
	    [11] = z_z,
	    [12] = 0,
    }

    out[13] = -out[  1]*eye_x - out[4+1]*eye_y - out[8+1]*eye_z
    out[14] = -out[  2]*eye_x - out[4+2]*eye_y - out[8+2]*eye_z
    out[15] = -out[  3]*eye_x - out[4+3]*eye_y - out[8+3]*eye_z
    out[16] = -out[  4]*eye_x - out[4+4]*eye_y - out[8+4]*eye_z + 1

    return out
end

-- Converts matrix into columns/vec4s, useful for Löve
matrix.to_columns = function (self)
    return {
		{ self[1],  self[2],  self[3],  self[4]  },
		{ self[5],  self[6],  self[7],  self[8]  },
		{ self[9],  self[10], self[11], self[12] },
		{ self[13], self[14], self[15], self[16] }
	}
end

-- Multiplies a matrix by another matrix
matrix.multiply = function (a, b)
    return matrix.new {
        b[1]  * a[1] + b[2]  * a[5] + b[3]  * a[9]  + b[4]  * a[13],
        b[1]  * a[2] + b[2]  * a[6] + b[3]  * a[10] + b[4]  * a[14],
        b[1]  * a[3] + b[2]  * a[7] + b[3]  * a[11] + b[4]  * a[15],
        b[1]  * a[4] + b[2]  * a[8] + b[3]  * a[12] + b[4]  * a[16],
        b[5]  * a[1] + b[6]  * a[5] + b[7]  * a[9]  + b[8]  * a[13],
        b[5]  * a[2] + b[6]  * a[6] + b[7]  * a[10] + b[8]  * a[14],
        b[5]  * a[3] + b[6]  * a[7] + b[7]  * a[11] + b[8]  * a[15],
        b[5]  * a[4] + b[6]  * a[8] + b[7]  * a[12] + b[8]  * a[16],
        b[9]  * a[1] + b[10] * a[5] + b[11] * a[9]  + b[12] * a[13],
        b[9]  * a[2] + b[10] * a[6] + b[11] * a[10] + b[12] * a[14],
        b[9]  * a[3] + b[10] * a[7] + b[11] * a[11] + b[12] * a[15],
        b[9]  * a[4] + b[10] * a[8] + b[11] * a[12] + b[12] * a[16],
        b[13] * a[1] + b[14] * a[5] + b[15] * a[9]  + b[16] * a[13],
        b[13] * a[2] + b[14] * a[6] + b[15] * a[10] + b[16] * a[14],
        b[13] * a[3] + b[14] * a[7] + b[15] * a[11] + b[16] * a[15],
        b[13] * a[4] + b[14] * a[8] + b[15] * a[12] + b[16] * a[16]
    }
end

-- Multiplies a matrix by a vec4, returns vec4
matrix.multiply_vec4 = function (a, b)
    local x, y, z, w = vector(b)

    return {
        x = x * a[1] + y * a[5] + z * a[9]  + w * a[13],
        y = x * a[2] + y * a[6] + z * a[10] + w * a[14],
        z = x * a[3] + y * a[7] + z * a[11] + w * a[15],
        w = x * a[4] + y * a[8] + z * a[12] + w * a[16]
    }
end

-- General multiplication
matrix.__mul = function (a, b)
    assert(isMatrix(a), "Left-hand value expected to be a mat4!")

    local is_vec = b.x and b.y and b.z and b.w

    if is_vec then
        return a:multiply_vec4(b)
        
    elseif isMatrix(b) then
        return a:multiply(b)

    else
        error("Right-hand value expected to be a mat4 or vec4!")
    end
end

matrix.__tostring = function (self)
    local o = "["
    for i = 1, 16 do
        o = o .. tostring(self[i])..", "
    end
    return o:sub(1, #o-2).."]"
end

matrix.__eq = function (a, b)
    for x = 1, 16 do
        -- 1.5 + 1.5 != 3.0
        if math.abs(a[x] - b[x]) > FLT_EPSILON then
            return false
        end
    end
    return true
end

return setmetatable(matrix, {
    __call = function (self, ...)
        return matrix.new(...)
    end
})
