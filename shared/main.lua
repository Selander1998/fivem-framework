exports('getModule', function(module)
	return core[module] or TriggerEvent('core:consoleLog', self, module, 'Failed fetching module')
end)

RegisterNetEvent('core:consoleLog')
AddEventHandler('core:consoleLog', function(self, module, message)
	print('[' .. tostring(module) .. ']' or '[Module not declared or missing]', tostring(message) or 'Message not declared or missing')
end)