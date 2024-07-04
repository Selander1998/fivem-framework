core.serverCallbacks = {}

core.callbacks.register = function(name, cb)
	core.serverCallbacks[name] = cb
end

core.callbacks.trigger = function(name, requestId, source, cb, ...)
	if core.serverCallbacks[name] ~= nil then
		core.serverCallbacks[name](source, cb, ...)
	else
		TriggerEvent('core:consoleLog', source, 'callbacks', 'Failed triggering callback: ' .. name)
	end
end

RegisterServerEvent('core:triggerServerCallback')
AddEventHandler('core:triggerServerCallback', function(name, requestId, ...)
	local src = source
	core.callbacks.trigger(name, requestID, src, function(...)
		TriggerClientEvent('core:serverCallback', src, requestId, ...)
	end, ...)
end)