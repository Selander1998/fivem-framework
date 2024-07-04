core.maths.round = function(value, decimals)
	return tonumber(string.format('%.' .. (decimals or 0) .. 'f', value))
end

core.maths.groupDigits = function(value)
	local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1'):reverse()) .. right
end

core.maths.commaValue = function(value)
	local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse())..right
end

core.maths.formatMoney = function(value)
	return tostring(math.floor(value)):reverse():gsub('(%d%d%d)', '%1,'):gsub(',(%-?)$', '%1'):reverse()
end