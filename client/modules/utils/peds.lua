local usablePeds = {}

core.utils.getClosestNPC = function()
	local playerped = PlayerPedId()
	local playerCoords = GetEntityCoords(playerped)
	local handle, ped = FindFirstPed()
	local success
	local rped = nil
	local distanceFrom
	repeat
	  	local pos = GetEntityCoords(ped)
	  	local distance = #(playerCoords - pos)
	  	if canPedBeUsed(ped) and distance < 5.0 and (distanceFrom == nil or distance < distanceFrom) then
			distanceFrom = distance
			rped = ped
			usablePeds['conf' .. rped] = true
	  	end
	  	success, ped = FindNextPed(handle)
	until not success
	EndFindPed(handle)
	return rped
end

core.utils.getNpcNearCoords = function(x, y, z)
	local handle, ped = FindFirstPed()
	local pedfound = false
	local success
	repeat
	  	local pos = GetEntityCoords(ped)
	  	local distance = #(vector3(x,y,z) - pos)
	  	if distance < 5.0 then
			pedfound = true
	  	end
	  	success, ped = FindNextPed(handle)
	until not success
	EndFindPed(handle)
	return pedfound
end

core.utils.removePedsInArea = function(area)
	local playerped = PlayerPedId()
	local playerCoords = GetEntityCoords(playerped)
	local handle, ped = FindFirstPed()
	local success
	local rped = nil
	local distanceFrom
	repeat
		local pos = GetEntityCoords(ped)
		local distance = #(playerCoords - pos)
		if canPedBeUsed(ped) and distance < area then
			distanceFrom = distance
			DeleteEntity(ped)
		end
		success, ped = FindNextPed(handle)
	until not success
	EndFindPed(handle)
end
  
function canPedBeUsed(ped)
	if ped == nil then
	  	return false
	end
	if usablePeds['conf' .. ped] then
	  	return false
	end
	if ped == PlayerPedId() then
	  	return false
	end
	if not DoesEntityExist(ped) then
	  	return false
	end
	if IsPedAPlayer(ped) then
	  	return false
	end
	if IsPedFatallyInjured(ped) then
	  	return false
	end
	if IsPedFleeing(ped) or IsPedRunning(ped) or IsPedSprinting(ped) then
	  	return false
	end
	if IsPedInCover(ped) or IsPedGoingIntoCover(ped) or IsPedGettingUp(ped) then
	  	return false
	end
	if IsPedInMeleeCombat(ped) then
	  	return false
	end
	if IsPedShooting(ped) then
	  	return false
	end
	if IsPedDucking(ped) then
	  	return false
	end
	if IsPedBeingJacked(ped) then
	  	return false
	end
	if IsPedSwimming(ped) then
	  	return false
	end
	if IsPedSittingInAnyVehicle(ped) or IsPedGettingIntoAVehicle(ped) or IsPedJumpingOutOfVehicle(ped) then
	  	return false
	end
	if IsPedOnAnyBike(ped) or IsPedInAnyBoat(ped) or IsPedInFlyingVehicle(ped) then
	  	return false
	end
	local pedType = GetPedType(ped)
	if pedType == 6 or pedType == 27 or pedType == 29 or pedType == 28 then -- Don´t allow gangpeds, policepeds and whatever
	  	return false
	end
	return true
end