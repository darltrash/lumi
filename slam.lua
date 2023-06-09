-- SLAM: Sirno's Lerfect Allision Mibrary

--[[
    This is free and unencumbered software released into the public domain.

    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.

    In jurisdictions that recognize copyright laws, the author or authors
    of this software dedicate any and all copyright interest in the
    software to the public domain. We make this dedication for the benefit
    of the public at large and to the detriment of our heirs and
    successors. We intend this dedication to be an overt act of
    relinquishment in perpetuity of all present and future rights to this
    software under copyright law.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
    OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.

    For more information, please refer to <http://unlicense.org/>
]]

--[[
    This library was made with the intention to continue the works done at:
        https://github.com/excessive/cpcl

    Please read https://github.com/darltrash/lumi/blob/main/docs/slam.md
    to get a better knowledge of what this can and cannot do
]]

-- TODO?: DECOUPLE FROM LUMI.VEC3
local current_folder = (...):gsub('%.[^%.]+$', '')
local vector = require(current_folder .. "vec3")
local slam = {}

local clamp = function (a, min, max)
    return math.max(min, math.min(max, a))
end

local signed_distance = function (plane, base)
    local d = -vector.dot(plane.normal, plane.position)
    return vector.dot(base, plane.normal) + d
end

local swap = function (a, b)
    return b, a
end

slam.triangle_intersects_point = function (point, v0, v1, v2)
    local u = v1 - v0
    local v = v2 - v0
    local w = point - v0
    
    local vw = vector.cross(v, w)
    local vu = vector.cross(v, u)

    if (vector.dot(vw, vu) < 0) then
        return false
    end

    local uw = vector.cross(u, w)
    local uv = vector.cross(u, v)

    if (vector.dot(uw, uv) < 0) then
        return false
    end

    local d = 1 / vector.magnitude(uv)
    local r = vector.magnitude(vw) * d
    local t = vector.magnitude(uw) * d

    return (r + t) <= 1
end

local get_lowest_root = function (a, b, c, max)
    local determinant = b*b - 4*a*c

    if determinant < 0 then
        return false
    end

    local sqrtd = math.sqrt(determinant)
    local r1 = (-b - sqrtd) / (2*a)
    local r2 = (-b + sqrtd) / (2*a)

    if (r1 > r2) then -- perform swap
        r1, r2 = swap(r1, r2)
    end

    if (r1 > 0 and r1 < max) then
        return r1
    end

    if (r2 > 0 and r2 < max) then
        return r2
    end

    return false
end

local check_triangle = function (packet, p1, p2, p3, id)
    local plane_normal = vector.normalize(vector.cross(p2 - p1, p3 - p1))

--    // only check front facing triangles
--	if (vec3.dot(pn, packet.e_norm_velocity) > 0.0) {
--		//return packet;
--	}

    local t0 = 0
    local embedded_in_plane = false

    local signed_dist_to_plane = vector.dot(packet.e_base_point, plane_normal) - vector.dot(plane_normal, p1)
    local normal_dot_vel = vector.dot(plane_normal, packet.e_velocity)

    if normal_dot_vel == 0 then
        if math.abs(signed_dist_to_plane) >= 1 then
            return packet
        else
            embedded_in_plane = true
            t0 = 0
        end
    else
        local nvi = 1 / normal_dot_vel
        t0 = (-1 - signed_dist_to_plane) * nvi
        local t1 = (1 - signed_dist_to_plane) * nvi

        if (t0 > t1) then
            t0, t1 = swap(t0, t1)
        end

        if (t0 > 1 or t1 < 0) then
            return packet
        end

        t0 = clamp(t0, 0, 1)
    end

    local collision_point = vector(0, 0, 0)
    local found_collision = false
    local t = 1

    if not embedded_in_plane then
        local plane_intersect = packet.e_base_point - plane_normal
        local temp = packet.e_velocity * t0
        plane_intersect = plane_intersect + temp

        if slam.triangle_intersects_point(plane_intersect, p1, p2, p3) then
            found_collision = true
            t = t0
            collision_point = plane_intersect
        end
    end

    if not found_collision then
        local velocity_sq_length = vector.magnitude2(packet.e_velocity)
        local a = velocity_sq_length

        local function check_point(collision_point, p)
            local b = 2 * vector.dot(packet.e_velocity, packet.e_base_point - p)
            local c = vector.magnitude2(p - packet.e_base_point) - 1

            local new_t = get_lowest_root(a, b, c, t)
            if new_t then
                t = new_t
                found_collision = true
                collision_point = p
            end

            return collision_point
        end

        collision_point = check_point(collision_point, p1)

        if not found_collision then
            collision_point = check_point(collision_point, p2)
        end

        if not found_collision then
            collision_point = check_point(collision_point, p3)
        end

        local function check_edge(collision_point, pa, pb)
            local edge = pb - pa
            local base_to_vertex = pa - packet.e_base_point
            local edge_sq_length = vector.magnitude2(edge)
            local edge_dot_velocity = vector.dot(edge, packet.e_velocity)
            local edge_dot_base_to_vertex = vector.dot(edge, base_to_vertex)

            local a = edge_sq_length * -velocity_sq_length + edge_dot_velocity * edge_dot_velocity
            local b = edge_sq_length * (2.0 * vector.dot(packet.e_velocity, base_to_vertex)) - 2.0 * edge_dot_velocity * edge_dot_base_to_vertex
            local c = edge_sq_length * (1.0 - vector.magnitude2(base_to_vertex)) + edge_dot_base_to_vertex * edge_dot_base_to_vertex;

            local new_t = get_lowest_root(a, b, c, t)
            if new_t then
                local f = (edge_dot_velocity * new_t - edge_dot_base_to_vertex) / edge_sq_length
                if (f >= 0 and f <= 1) then
                    t = new_t
                    found_collision = true
                    collision_point = pa + (edge * f)
                end
            end

            return collision_point
        end

        collision_point = check_edge(collision_point, p1, p2) -- p1 -> p2
		collision_point = check_edge(collision_point, p2, p3) -- p2 -> p3
		collision_point = check_edge(collision_point, p3, p1) -- p3 -> p1
    end

    if found_collision then
        local dist_to_coll = t * vector.magnitude(packet.e_velocity)

        if (not packet.found_collision or dist_to_coll < packet.nearest_distance) then
            packet.nearest_distance = dist_to_coll
            packet.intersect_point = collision_point
            packet.intersect_time = t
            packet.found_collision = true
            packet.id = id
        end
    end

    return packet
end

local check_collision = function (packet, triangles, ids)
    local inv_radius = packet.e_inv_radius

    for index, triangle in ipairs(triangles) do
		local v0 = vector.from_array(triangle[1])
		local v1 = vector.from_array(triangle[2])
		local v2 = vector.from_array(triangle[3])

		check_triangle(
			packet,
			v0 * inv_radius,
			v1 * inv_radius,
			v2 * inv_radius,
            ids and ids[index] or 0
		)
	end
end

-- This implements the improvements to Kasper Fauerby's "Improved Collision
-- detection and Response" proposed by Jeff Linahan's "Improving the Numerical
-- Robustness of Sphere Swept Collision Detection"
local VERY_CLOSE_DIST = 0.00125

slam.collide_with_world = function(packet, position, velocity, triangles, ids)
    local first_plane
    local dest = position + velocity
    local speed = 1

    for i=1, 3 do
        packet.e_norm_velocity = vector.normalize(velocity)
        packet.e_velocity = vector.copy(velocity)
        packet.e_base_point = vector.copy(position)
        packet.found_collision = false
        packet.nearest_distance = 1e20

        check_collision(packet, triangles, ids)

        if not packet.found_collision then
            return dest
        end

        local touch_point = position + velocity * packet.intersect_time

        local pn = vector.normalize(touch_point - packet.intersect_point)
        local p = {
            position = packet.intersect_point,
            normal = pn
        }
        local n = vector.normalize(p.normal / packet.e_radius)

        local dist = vector.magnitude(velocity) * packet.intersect_time
        local short_dist = math.max(dist - speed * VERY_CLOSE_DIST, 0)
        local nvel = vector.normalize(velocity)
        position = position + nvel * short_dist

        table.insert(packet.contacts, {
            id = packet.id,
            position = p.position * packet.e_radius,
            normal = n,
            near = packet.intersect_time
        })

        if i == 1 then
            local long_radius = 1 + speed * VERY_CLOSE_DIST
            first_plane = p
            
            dest = dest - (first_plane.normal * (signed_distance(first_plane, dest) - long_radius))
            velocity = dest - position
        elseif i == 2 and first_plane then
            local second_plane = p
            local crease = vector.normalize(vector.cross(first_plane.normal, second_plane.normal))
            local dis = vector.dot(dest - position, crease)
            velocity = crease * dis
            dest = position + velocity
        end
    end

    return position
end

local function get_tris(position, velocity, radius, query, data)
    local scale = math.max(1.5, vector.magnitude(velocity)) * 1.25
	local r3_position = position
	local query_radius = radius * scale
	local min = r3_position - query_radius
	local max = r3_position + query_radius

	return query(min, max, velocity, data)
end

local function sub_update(packet, position, triangles, ids)
    packet.e_velocity = packet.e_velocity * 0.5
    
    local e_position = vector.copy(packet.e_position)
    local e_velocity = vector.copy(packet.e_velocity)

    local final_position = slam.collide_with_world(packet, e_position, e_velocity, triangles, ids)

    packet.r3_position = final_position * packet.e_radius
    packet.r3_velocity = packet.r3_position - position
end

-- query must be function(min, max, velocity)->triangles,id?
-- returns position, velocity, contacts (as planes)
slam.check = function (position, velocity, radius, query, substeps, data)
    substeps = substeps or 1
    velocity = velocity / substeps

    local _q = query
    if type(query)=="table" then
        query = function ()
            return _q
        end
    end

    local tri_cache, id_cache = get_tris(position, velocity, radius, query, data)

    local base = position
    local contacts = {}
    for i=1, substeps do
        local packet = {
            r3_position  = position,
			r3_velocity  = velocity,
			e_radius     = radius,
			e_inv_radius = vector(1, 1, 1) / radius,
			e_position   = position / radius,
			e_velocity   = velocity / radius,
			e_norm_velocity  = vector(0, 0, 0),
			e_base_point     = vector(0, 0, 0),
			found_collision  = false,
			nearest_distance = 0,
			intersect_point  = vector(0, 0, 0),
			intersect_time   = 0,
			id = 0,
			contacts = contacts
        }

        sub_update(packet, packet.r3_position, tri_cache, id_cache)
        position = packet.r3_position
        velocity = packet.r3_velocity
    end

    return position, position - base, contacts
end
slam.__call = slam.check

return setmetatable(slam, slam)