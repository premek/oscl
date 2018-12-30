local decode_float = require 'oscl.decoder.float'

local decode_int = function(bin)
	if bin == nil then
		error("error: string is empty - probably malformated message")
	end
	local result = 0
	for i=1,4 do
		result = result*256 + string.byte(string.sub(bin,i,i))
	end
	if result > 2147483647 then return result - 4294967296 end
	return result
end

local next_string = function(astring)
	-- this is a workaraound because the lua pttern matching is
	-- not as powerful as pcre and I did not want to include another
	-- dependecy to an external re lib
	local pos = 0
	local num_nzero = 0
	local num_zero = 0
	local result = ""
	if astring == nil then
		-- ensure that string is not empty
		error("error: string is empty - probably malformated message")
	end
	-- we match every character with the help of gmatch
	for m in string.gmatch(astring, ".") do
		pos = pos + 1
		-- and then check if it is correctly padded with '\0's
		if m ~= '\0' and num_zero == 0 then
			num_nzero = (num_nzero + 1) % 4
			result = result .. m
		elseif num_zero > 0 and (num_zero + num_nzero) % 4 == 0 then
			return result, pos
		elseif m == '\0' then
			num_zero = num_zero + 1
			result = result .. m
		else
			return nil
		end
	end
	if num_zero > 0 and (num_zero + num_nzero) % 4 == 0 then
		return result, pos
	end
end

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
