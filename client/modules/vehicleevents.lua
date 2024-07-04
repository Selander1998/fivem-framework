local isInVehicle = nil

Citizen.CreateThread(function()
	while true do
		local inside = IsPedInAnyVehicle(PlayerPedId(), false)
		if not isInVehicle and inside then
			isInVehicle = true
			TriggerEvent('core:onVehicleEnter', GetVehiclePedIsIn(PlayerPedId()))
		elseif isInVehicle and not inside then
			isInVehicle = nil
			TriggerEvent('core:onVehicleExit')
		end
		Citizen.Wait(200)
	end
end)