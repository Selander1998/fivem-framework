local stoppedResources = {}

AddEventHandler('onResourceStop', function(resource)
    if not resource then return end
	stoppedResources[#stoppedResources + 1] = resource
end)

AddEventHandler('onResourceStart', function(resource)
    if not resource then return end
    for k,v in pairs(stoppedResources) do
        if v == resource then
            TriggerServerEvent('core:onResourceRestart', core.character.source)
            stoppedResources[k] = nil
            break
        end
    end
end)

RegisterCommand('resourcehandler', function()
    for k,v in pairs (stoppedResources) do
        TriggerEvent('menu:sendMenu', {
            {
                id = i,
                header = '[' .. v .. ']' ,
                txt = 'Start resource',
                params = {
                    event = 'core:startResource',
                    serverevent = true,
                    args = {
                        resource = v
                    }
                }
            }
        })
    end
end)