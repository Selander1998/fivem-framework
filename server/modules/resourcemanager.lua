RegisterServerEvent('core:startResource')
AddEventHandler('core:startResource', function(data)
    if not data then return end
    StartResource(data.resource)
end)

RegisterServerEvent('core:onResourceRestart')
AddEventHandler('core:onResourceRestart', function(id)
    local character = core.utils.getCharacterFromId(id)
    if not character or not character.source then return print('Error loading character data') end
    TriggerEvent('core:characterLoaded', character.source, character)
    TriggerClientEvent('core:characterLoaded', character.source, character)
end)