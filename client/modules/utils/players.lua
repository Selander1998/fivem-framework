core.utils.getPlayers = function()
	local players = {}
	for _,player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)
		if DoesEntityExist(ped) then
			table.insert(players, player)
		end
	end
	return players
end

core.utils.getClosestPlayer = function(coords)
	local players = core.utils.getPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local usePlayerPed = false
	local playerPed = PlayerPedId()
	local playerId = PlayerId()
	if coords == nil then
		usePlayerPed = true
		coords = GetEntityCoords(playerPed)
	end
	for i = 1, #players, 1 do
		if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
			local distance = #(GetEntityCoords(GetPlayerPed(players[i])) - vector3(coords.x, coords.y, coords.z))
			if closestDistance == -1 or closestDistance > distance then
				closestPlayer = players[i]
				closestDistance = distance
			end
		end
	end
	return closestPlayer, closestDistance
end

core.utils.getPlayersInArea = function(coords, area)
	local player = core.utils.getPlayers()
	local playersInArea = {}
	for i=1, #players, 1 do
		local distance = #(GetEntityCoords(GetPlayerPed(players[i])) - vector3(coords.x, coords.y, coords.z))
		if distance <= area then
			table.insert(playersInArea, players[i])
		end
	end
	return playersInArea
end

--core.utils.jobAllowed(job, bool)
--	if not core.character.onDuty and bool then
--		return false
--	end
--	if core.character.job.name ~= job then
--		return false
--	end
--	return true
--end

core.utils.sendEventToPassengers = function(vehicle, event, params)
	for i = - 1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
		local ped = GetPedInVehicleSeat(vehicle, i)
		if ped ~= PlayerPedId() and ped ~= 0 then
			TriggerServerEvent(event, GetPlayerServerId(v), params)
		end
	end
end