local blips = {}

AddEventHandler('core:exportsLoaded', function()
	local default = { -- Fill out with whatever you need, tattoo parlors added as examples
		['tattooparlor_1'] = { label = 'Tattoo Parlor', color = 49, sprite = 75, x = 1322.60, y = -1651.90 },
		['tattooparlor_2'] = { label = 'Tattoo Parlor', color = 49, sprite = 75, x = -1153.60, y = -1425.60 },
		['tattooparlor_3'] = { label = 'Tattoo Parlor', color = 49, sprite = 75, x = 322.10, y = 180.400 },
		['tattooparlor_4'] = { label = 'Tattoo Parlor', color = 49, sprite = 75, x = -3170.00, y = 1075.00 },
		['tattooparlor_5'] = { label = 'Tattoo Parlor', color = 49, sprite = 75, x = 1864.60, y = 3747.70 },
		['tattooparlor_6'] = { label = 'Tattoo Parlor', color = 49, sprite = 75, x = -293.70, y = 6200.00 },
	}
	for k,v in pairs(default) do
		core.blips.createBlip(k, v)
	end
end)

core.blips.createBlip = function(id, data)
	if blips[id] then TriggerEvent('core:consoleLog', self, 'blips', 'blip ' .. id .. ' was attemped to be overridden') return end
	if not data.sprite then TriggerEvent('core:consoleLog', self, 'blips', 'warning: sprite for blip ' .. id .. ' is missing') return end
	if not data.color then TriggerEvent('core:consoleLog', self, 'blips', 'color for blip ' .. id .. ' is missing') return end
	local blip = AddBlipForCoord(data.x, data.y, 0.0)
	SetBlipSprite(blip, data.sprite)
	SetBlipColour(blip, data.color)
	SetBlipAsShortRange(blip, data.short or true)
	if data.display then SetBlipDisplay(blip, data.display) end
	if data.playername then SetBlipNameToPlayerName(blip, data.playername) end
	if data.showcone then SetBlipShowCone(blip, data.showcone) end
    if data.secondarycolor then SetBlipSecondaryColour(blip, data.secondarycolor) end
    if data.friend then ShowFriendIndicatorOnBlip(blip, data.friend) end
    if data.mission then SetBlipAsMissionCreatorBlip(blip, data.mission) end
    if data.route then SetBlipRoute(blip, data.route) end
	if data.friendly then SetBlipAsFriendly(blip, data.friendly) end
    if data.routecolor then SetBlipRouteColour(blip, data.routecolor) end
	SetBlipScale(blip, data.scale or 0.7)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(data.label)
    EndTextCommandSetBlipName(blip)
	blips[id] = {
		blip = blip,
		data = data
	}
end

core.blips.hideBlip = function(id)
	if not blips[id] then TriggerEvent('core:consoleLog', self, 'blips', 'blip ' .. id .. ' could not be hidden due to not existing') return end
	SetBlipAlpha(blips[id].blip, 0)
end

core.blips.showBlip = function(id)
	if not blips[id] then TriggerEvent('core:consoleLog', self, 'blips', 'blip ' .. id .. ' could not be shown due to not existing') return end
	SetBlipAlpha(blips[id].blip, 255)
end

core.blips.doesBlipExist = function(id)
	if not blips[id] then return false end
	return true
end

core.blips.removeBlip = function(id)
	if not blips[id] or not DoesBlipExist(blips[id].blip) then TriggerEvent('core:consoleLog', self, 'blips', 'blip ' .. id .. ' could not be removed due to not existing') return end
	RemoveBlip(blips[id].blip)
	blips[id] = nil
end