local x7FFFFFFF = 2147483647
local x100000000 = 4294967296

return function(bin)
	if bin == nil then
		error("error: string is empty - probably malformated message")
	end
	local result = 0
	for i=1,4 do
		result = result * 256 + string.byte(string.sub(bin, i, i))
	end
	if result > x7FFFFFFF then return result - x100000000 end
	return result
end

