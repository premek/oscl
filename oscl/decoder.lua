local decode_float = require 'oscl.decoder.float'
local decode_int = require 'oscl.decoder.int'
local next_string = require 'oscl.decoder.string'

local collect_decoding_from_message = function(t, data, message)
	if t == 'i' then
		table.insert(message, decode_int(data))
		return string.sub(data, 5)
	elseif t == 'f' then
		table.insert(message, decode_float(data))
		return string.sub(data, 5)
	elseif t == 'T' then
		table.insert(message, true)
		return data
	elseif t == 'F' then
		table.insert(message, false)
		return data
	elseif t == 'I' then
		table.insert(message, math.huge)
		return data
	elseif t == 's' then
		local match, last = next_string(data)
		table.insert(message, match)
		return string.sub(data, last)
--	elseif t == 'b' then
--		local length = decode_int(data)
--		table.insert(message, string.sub(data, 4, length))
--		return string.sub(data, 4 + length + 1)
    else
        error("Type not supported: " .. t)
	end
end

local get_addr_from_data = function(data)
	local addr_raw_string,last = next_string(data)
	local result = ""
	if addr_raw_string == nil then
		-- if we could not find an addr something went wrong
		error("error: could not extract address from OSC message")
	end
	-- delete possible trailing zeros
	for t in string.gmatch(addr_raw_string, "[^%z]") do
		result = result .. t
	end
	return result, string.sub(data, last)
end

local get_types_from_data = function(data)
	local typestring, last = next_string(data)
	local result = {}
	if typestring == nil then
		return {}
	end
	-- split typestring into an iterable table
	for t in string.gmatch(typestring, "[^,%z]") do
		table.insert(result, t)
	end
	return result, string.sub(data, last)
end

local decode_message = function(data, server)
	local message = {}
	local addr, tmp_data = get_addr_from_data(data)
	if not server:doesHandle(addr) then return end

	local types
	types, tmp_data = get_types_from_data(tmp_data)
	-- ensure that we at least found something
	if addr == nil or types == nil then
		return nil
	end
	message.addr = addr
	for _,t in ipairs(types) do
		tmp_data = collect_decoding_from_message(t, tmp_data, message)
	end
	return server:handle(message)
end

return function (data, server)
	if #data == 0 then
		return nil
	end
	if string.match(data, "^#bundle") then
		error("bundle not yet implemented")
        --return decode_bundle(data)
	else
		return decode_message(data, server)
	end
end
