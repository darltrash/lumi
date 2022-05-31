-- Rose: An extremely abridged and simple ECS implementation

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

local rose = function (entities, systems, process, ...)
    local processed = {}
    process = process or "process"

    for _, system in ipairs(systems) do
        local fn = system[process]

        if fn and system.filter then
            for _, entity in ipairs(entities) do
                if system:filter(entity, ...) then
                    fn(system, entity, ...)
                    
                    table.insert(processed, entity)
                end
            end
        end
    end

    return processed
end

if ... then
    return rose
end

-- Usage:
local movement = {
    filter = function (self, ent)
        return ent.id and
               ent.pos_x and ent.pos_y and
               ent.vel_x and ent.vel_y
    end,

    process = function(self, ent)
        local nx = ent.pos_x + ent.vel_x
        local ny = ent.pos_y + ent.vel_y

        print(string.format(
            "id = [%s], pos = [%s, %s]. next pos = [%s, %s]",
            ent.id, ent.pos_x, ent.pos_y, nx, ny
        ))

        ent.pos_x = nx
        ent.pos_y = ny
    end
}

local speaks = {
    filter = function(self, ent)
        return ent.id
           and ent.pos_x and ent.pos_y 
           and ent.greetings
    end,

    process = function (self, ent)
        print(string.format(
            "[ID %s at %s, %s]: %s", 
            ent.id, ent.pos_x, ent.pos_y, ent.greetings
        ))
    end
}

local entities = {
    { 
        id = 0,
        pos_x = 10, pos_y = 10, 
        vel_x = 5, vel_y = 5 
    },
    
    { 
        id = 1,
        pos_x = 25, pos_y = 25, 
        vel_x = -5, vel_y = -5,
        greetings = "Howdy!"
    },

    {
        id = 2,
        pos_x = 50, pos_y = 50,
        greetings = "Helllllooo!"
    }
}

rose(entities, { movement, speaks })