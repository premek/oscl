return function(astring)
	local pos = 0
	local num_nzero = 0
	local num_zero = 0
	local result = ""
	if astring == nil then
		error("error: string is empty - probably malformated message")
	end
	for c in string.gmatch(astring, ".") do
		pos = pos + 1
		-- and then check if it is correctly padded with '\0's
		if c ~= '\0' and num_zero == 0 then
			num_nzero = (num_nzero + 1) % 4
			result = result .. c
		elseif num_zero > 0 and (num_zero + num_nzero) % 4 == 0 then
			return result, pos
		elseif c == '\0' then
			num_zero = num_zero + 1
			result = result .. c
		else
			return nil
		end
	end
	if num_zero > 0 and (num_zero + num_nzero) % 4 == 0 then
		return result, pos
	end
end

