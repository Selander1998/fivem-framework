RegisterNetEvent('core:addChatSuggestions')
AddEventHandler('core:addChatSuggestions', function(privileged)
	local commands = { -- Add whatever you need, example usage below
		['givecash'] = {
			admin = false,
			help = 'Give cash to closest person'
		},
		['adminmenu'] = { -- This does nothing btw, just an example
			admin = true,
			help = 'Open admin menu'
		},
  	}
	for command, data in pairs(commands) do
		if data.admin and privileged then
			TriggerEvent('chat:addSuggestion', '/' .. command, data.help)
		else
			TriggerEvent('chat:addSuggestion', '/' .. command, data.help)
		end
	end
end)