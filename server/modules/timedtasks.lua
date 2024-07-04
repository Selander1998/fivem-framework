local tasks = {
	{
		hour = 17,
		minute = 00,
		event = 'core:activatePrimetime'
	}
}

Citizen.CreateThread(function()
	for i = 1, 24 do -- Make this the amount we actually need, based on time that server starts. (need restart times to be accurate & needs failsafe on server crash etc)
		table.insert(tasks, {hour = i, minute = 59, event = 'core:retrieveTaxesTask'}) -- Does nothing, just an example for running something once every hour
	end
    while true do
		for k,v in pairs(tasks) do
			if v.hour == tonumber(os.date('%H', os.time())) and v.minute == tonumber(os.date('%M', os.time())) then
				TriggerEvent(v.event)
			end
		end
		Citizen.Wait(60000)
	end
end)