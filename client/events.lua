RegisterNetEvent('core:characterLoaded')
AddEventHandler('core:characterLoaded', function(character)
	core.character = character
end)

RegisterNetEvent('core:characterUnloaded')
AddEventHandler('core:characterUnloaded', function()
	core.character = {}
	TriggerEvent('core:onVehicleExit')
end)

RegisterNetEvent('core:setCharacterData')
AddEventHandler('core:setCharacterData', function(key, val)
	core.character[key] = val
end)

RegisterNetEvent('core:updateJob')
AddEventHandler('core:updateJob', function(newJob, oldJob)
	core.character.job = newJob
end)

RegisterNetEvent('core:cashUpdate')
AddEventHandler('core:cashUpdate', function(total, amount, remove)
	core.character.money = total
    SendNUIMessage({
        action = 'update',
        cash = total,
        amount = amount,
        minus = remove
    })
end)

RegisterNetEvent('core:notify')
AddEventHandler('core:notify', function(variation, text, length, style)
	SendNUIMessage({
		type = variation or 'inform',
		text = text or 'error',
		length = length or 5000,
		style = style
	})
end)