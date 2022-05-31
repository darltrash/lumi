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

return function (entities, systems, process, ...)
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