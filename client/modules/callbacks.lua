core.callbacks = {}
core.currentRequestId = 0
core.serverCallbacks = {}

core.callbacks.trigger = function(name, cb, ...)
	core.serverCallbacks[core.currentRequestId] = cb
	TriggerServerEvent('core:triggerServerCallback', name, core.currentRequestId, ...)
	if core.currentRequestId < 65535 then
		core.currentRequestId = core.currentRequestId + 1
	else
		core.currentRequestId = 0
	end
end

RegisterNetEvent('core:serverCallback')
AddEventHandler('core:serverCallback', function(requestId, ...)
	core.serverCallbacks[requestId](...)
	core.serverCallbacks[requestId] = nil
end)