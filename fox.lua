-- Fox: @darltrash's rendering sheganigans
-- inspired by TinyFX and LVFX by Shakesoda

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

assert(
    select(2, love.getVersion()) <= 10,
    "Löve version unsupported :("
)

local _type = type
local type = function (a)
    local meta = getmetatable(a)
    return meta and meta.__type or _type(a)
end

local EMPTY = {}

local View = setmetatable({
    new = function (self, what)
        local out = setmetatable({
            draws = {}
        }, {
            __index = self,
            __type = "View"
        })

        if what then
            out:set(what)
        end

        return out
    end,

    of_type = function (v)
        local meta = getmetatable(v)
        return meta and meta.__type == "View" and v
    end,

    set = function (self, v)
        self:set_canvas(v.canvas)
        self:set_scissor(v.scissor)
        self:set_depth_clear(v.clear)
        self:set_clear(unpack(v.clear))
        self:set_culling(v.culling)
        self:set_depth_test(v.depth_test, v.depth_write)
    end,

    set_canvas = function (self, canvas)
        self.canvas = canvas
    end,

    set_scissor = function (self, x, y, w, h)
        if not x then
            self.scissor = nil
            return
        end

        self.scissor = {x, y, w, h}
    end,

    set_clear = function (self, ...)
        self.clear = {...}
    end,

    set_culling = function (self, face)
        self.culling = face or false
    end,

    set_depth_clear = function (self, clear)
        self.clear = clear or false
    end,

    set_depth_test = function (self, test, write)
        self.depth_test  = test
	    self.depth_write = (write == nil) and true or write
    end,

    get_width = function (self)
        return self.canvas and self.canvas:getWidth()
            or love.graphics.getWidth()
    end,
    
    get_height = function (self)
        return self.canvas and self.canvas:getHeight()
            or love.graphics.getHeight()
    end,
    
    get_dimensions = function (self)
        return self:get_width(), self:get_height()
    end

}, {
    __call = function (self, ...)
        return self:new(...)
    end
})

local Shader = setmetatable({
    new = function (self, vertex, fragment)
        return setmetatable({
            handle = love.graphics.newShader(vertex, fragment)

        }, {
            __index = self,
            __type = "Shader"
        })
    end,

    of_type = function (v)
        local meta = getmetatable(v)
        return meta and meta.__type == "Shader" and v
    end
}, {
    __call = function (self, ...)
        return self:new(...)
    end
})

local updated_uniforms = {}
local Uniform = setmetatable({
    new = function (self, name, int)
        return setmetatable({
            name = assert(name, "Uniform name is required!"),
            int = int or false

        }, {
            __index = self,
            __type = "Uniform"
        })
    end,

    of_type = function (v)
        local meta = getmetatable(v)
        return meta and meta.__type == "Uniform" and v
    end,

    set = function (self, ...)
        self.data = {...}
        table.insert(updated_uniforms, self)
        updated_uniforms[self.name] = #updated_uniforms
    end
}, {
    __call = function (self, ...)
        return self:new(...)
    end
})

local state_def = {
    "mesh"        ,
	"mesh_params" ,
	"fn"          ,
	"fn_params"   ,
	"color"       ,
	"shader"
}

local function state_copy(t)
	local clone = {}
	for _, v in ipairs(state_def) do
		clone[v] = t[v]
	end
	return clone
end

local state = {}
local fox
fox = {
    View = View,
    Shader = Shader,
    Uniform = Uniform,
	
    set_shader = function (shader)
        state.shader = assert(
            Shader.of_type(shader) or (shader == nil), 
            "Expected fox.Shader or nil!"
        )
    end,

    set_color = function (r, g, b, a)
        state.color = (type(r) == "table") and r or {r, g, b, a}
    end,

    set_draw = function (mesh, params)
        if type(mesh) == "function" then
            state.fn = mesh
            state.fn_params = params or nil

            return
        end

        state.mesh = mesh
        state.mesh_params = params or nil
    end,

--    set_uniforms = function (name, ...)
--        local t = type(name)
--
--        if t == "Uniform" then
--            return name:set(...)
--
--        elseif t == "table" then
--            for k, v in pairs(name) do
--                local uniform = { name = k, data = v }
--                table.insert(updated_uniforms, uniform)
--                updated_uniforms[uniform.name] = #updated_uniforms
--            end
--
--            return
--        end
--
--        local uniform = { name = name, data = ... }
--        table.insert(updated_uniforms, uniform)
--        updated_uniforms[uniform.name] = #updated_uniforms
--    end,

    submit = function (view, retain)
        if view then
            assert(View.of_type(view), "Expected fox.View!")

            local add_state = state_copy(state)
            add_state.uniforms = {}
    
            if add_state.shader then
                local found = {}
                for i = #updated_uniforms, 1, -1 do
                    local uniform = updated_uniforms[i]
                    if add_state.shader.handle:hasUniform(uniform.name) then
                        if not found[uniform.name] then
                            found[uniform.name] = true

                            table.insert(add_state.uniforms, {
                                name = uniform.name,
                                data = {unpack(uniform.data)}
                            })
                        end
                    end
                end
            end
            table.insert(view.draws, add_state)
        end

        if not retain then
            state = {
                shader = state.shader
            }
        end
    end,

    touch = function ()
        fox.submit()
    end,

    frame = function (views)
        love.graphics.setColor(1, 1, 1, 1)

        for _, view in ipairs(views) do
            love.graphics.push("all")
            
            if not View.of_type(view) then
                goto continue
            end

            love.graphics.setCanvas(view.canvas) -- nil by default
            love.graphics.setScissor(unpack(view.scissor or EMPTY))

            if view.clear then
                love.graphics.clear(unpack(view.clear))
            end

            if #view.draws == 0 then
                goto continue
            end
            
            for _, draw in ipairs(view.draws) do
                love.graphics.push("all")
                
                if draw.color then
                    love.graphics.setColor(draw.color)
                end

                love.graphics.setShader(draw.shader and draw.shader.handle or nil)
                if view.depth_test then
                    love.graphics.setDepthMode(view.depth_test, view.depth_write)
                end

                if draw.shader then
                    local shader = draw.shader.handle

                    for _, uniform in ipairs(draw.uniforms) do
                        if uniform.int then
                            shader:sendInt(uniform.name, unpack(uniform.data))
                        else
                            shader:send(uniform.name, unpack(uniform.data))
                        end
                    end
                end

                if draw.fn then
                    draw.fn(unpack(draw.fn_params or EMPTY))
                elseif draw.mesh then
                    love.graphics.draw(draw.mesh, unpack(draw.mesh_params or EMPTY))
                end

                love.graphics.pop()
            end
            view.draws = {}
            ::continue::

            love.graphics.pop()
        end

        fox.touch()
        updated_uniforms = {}
    end
}

for _, v in ipairs({
    "arc", "circle", "discard", "draw",
    "drawInstanced", "drawLayer", "ellipse",
    "flushBatch", "line", "points", "polygon",
    "print", "printf", "rectangle", "stencil",
}) do
    local fn = love.graphics[v]
    fox[v] = function (...)
        state.fn = fn
        state.fn_params = {...}
    end
end

return fox