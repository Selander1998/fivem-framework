core = {}
core.character = {}
core.utils = {}
core.maths = {}
core.blips = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if NetworkIsSessionStarted() then

            TriggerServerEvent('core:loadUser')

            -- Discord rich presence stuff
            --[[
            SetDiscordAppId()
            SetDiscordRichPresenceAsset()
            SetDiscordRichPresenceAssetText()
            SetDiscordRichPresenceAssetSmallText()
            SetDiscordRichPresenceAction()
            SetDiscordRichPresenceAction()
            --]]

            repeat
                Citizen.Wait(500)
                print('Loading exports...')
            until exports and exports['core']

            TriggerEvent('core:exportsLoaded')
            break
        end
    end
end)

-- This export is here as a temporary solution to getting a hold of regularly changing character data values
exports('getCharacterData', function(key)
	return core.character[key]
end)