-- Mimi: A very simple INI-like setup language

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

local backend = {
	read = function (file)
		local f = assert(io.open(file, "rb"))
		local o = f:read("*all")
		f:close()

		return o
	end,

	write = function(file, str)
		local f = assert(io.open(file, "w+"))
		f:write(str)
		f:close()

		return true
	end
}

if love then
	backend.read = love.filesystem.read
	backend.write = love.filesystem.write
end

local function decode(txt, out)
	out = out or {}
	local current = out
	local line_number = 0

	for line in txt:gmatch("[^\r\n]*") do
		line = line:gsub("#.*", ""):match("^%s*(.*)%s*$")
		line_number = line_number + 1

		if line == "" then
			goto continue
		end
	
		local header = line:match("^%[(.*)%]$")
		if header then
			current = out
			for name in header:gmatch("([%w_]+)%.?") do 
				current[name] = current[name] or {}
				current = current[name] 
			end
	
			goto continue
		end
		
		local name, value = line:match("^([%w_]+)%s*:%s*(.*)$")
		if not name then
			name, value = line:match("^\"(.*)\"%s*:%s*(.*)$")
		end

		if name then
			value = value:match("^%s*(.*)%s*$")

			if value == "yes" or value == "no" then
				current[name] = value == "yes"
			else
				current[name] =
					tonumber(value)
					or value:match("^\"(.*)\"$")
					or value
			end

			goto continue
			
		else
			return nil, ("Invalid line #"..line_number.."!")

		end

		::continue::
	end

	return out
end

local function encode(input, name)
	local out = name and ("["..name.."]\n") or ""

	local check_later = {}
	for key, value in pairs(input) do
		local t = type(value)
		key = tostring(key)
		if key:gsub("%w_*", "")~="" then
			key = '"' .. key .. '"'
		end

		if t == "string" then
			out = out .. ("%s: \"%s\"\n"):format(key, value)
			
		elseif t == "number" then
			out = out .. ("%s: %s\n"):format(key, value)

		elseif t == "boolean" then
			out = out .. ("%s: %s\n"):format(key, value and "yes" or "no")

		elseif t == "table" then
			local n = (name and (name .. ".") or "") .. key
			check_later[n] = value
		else
			return nil, ("Unsupported type: " .. t .. "!")
		end
	end

	for key, value in pairs(check_later) do
		out = out .. encode(value, key)
	end

	return out
end

local function load(file, template)
	return decode(backend.read(file), template)
end

local function write(file, data)
	return backend.write(file, encode(data))
end

return {
	backend = backend, 

	decode = decode,
	encode = encode,

	load = load,
	write = write
}
