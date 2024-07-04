core.utils.getUserFromId = function(src)
	return core.users[src]
end

core.utils.getUserFromIdentifier = function(identifier)
	for k,v in pairs(core.users) do
		if v.identifier == identifier then
			return v
		end
	end
end

core.utils.getCharacterFromId = function(src)
	return core.characters[src]
end

core.utils.getCharacterFromCid = function(cid)
	for k,v in pairs(core.characters) do
		if v.cid == cid then
			return v
		end
	end
end

core.utils.getCharacters = function()
	local sources = {}
	for k,v in pairs(core.characters) do
		table.insert(sources, k)
	end
	return sources
end

core.utils.getDiscordId = function(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, 'discord') then
            return id
        end
    end
end