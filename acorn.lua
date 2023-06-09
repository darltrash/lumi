-- Acorn: A simple OOP library.
-- NOTE: THIS DOES NOT SUPPORT INHERITANCE.

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

return {
    class = function(tab)
        local t = type(tab)
        assert(t, ("Expected 'table', got '%s'!"):format(t))

        tab.__index = tab
        tab.__type = tab.__type or "Instance"
        local new = tab.new

        tab.new = function(...)
            local out = setmetatable({ __instance = true }, tab)
            if new then
                new(out, ...)
            end
            return out
        end

        return setmetatable(tab, {
            __type = "Class",
            __call = function(_, ...)
                return tab.new(...)
            end
        })
    end,

    type = function(v, ignore_vanilla)
        local meta = getmetatable(v)
        return meta and meta.__type or
            (not ignore_vanilla) and type(v) or nil
    end
}
