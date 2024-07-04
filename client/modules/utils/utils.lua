core.utils.getCurrentStreet = function()
	local coords = GetEntityCoords(PlayerPedId(), true)
	local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, coords.x, coords.y, coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
	return {
		street1 = GetStreetNameFromHashKey(s1),
		street2 = GetStreetNameFromHashKey(s2),
		zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
	}
end

core.utils.draw3dText = function(x, y, z, text)
	local xType = type(x)
	local pos = (xType == 'table' and x or xType == 'vector3' and x or vector3(x, y, z))
	local onScreen, _x, _y = World3dToScreen2d(pos.x, pos.y, pos.z)
	local px, py, pz = table.unpack(GetGameplayCamCoords())
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry('STRING')
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x, _y)
	local factor = (string.len(text)) / 370
	DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

core.utils.drawLoadingPrompt = function(text)
	SetLoadingPromptTextEntry('STRING')
	AddTextComponentSubstringPlayerName(text)
	ShowLoadingPrompt(3)
end

core.utils.loadAnimDict = function(dict)
	if not HasAnimDictLoaded(dict) then
	  	RequestAnimDict(dict)
	  	local start = GetGameTimer()
	  	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
			if GetGameTimer() - start > 10000 then
			    return Citizen.Trace('Failed to load animation dictionary: ' .. dict)
			end
	  	end
	end
end

core.utils.loadAnimSet = function(set)
	if not HasAnimSetLoaded(set) then
		RequestAnimSet(set)
	  	local start = GetGameTimer()
	  	while not HasAnimSetLoaded(set) do
			Citizen.Wait(1)
			if GetGameTimer() - start > 10000 then
			    return Citizen.Trace('Failed to load animation set: ' .. dict)
			end
	  	end
	end
end

core.utils.loadPtfxAsset = function(asset)
	if not HasNamedPtfxAssetLoaded(asset) then
		RequestNamedPtfxAsset(asset)
		local start = GetGameTimer()
		while not HasNamedPtfxAssetLoaded(asset) do
			Citizen.Wait(1)
			if GetGameTimer() - start > 10000 then
				return Citizen.Trace('Failed to load pftx asset: ' .. asset)
			end
		end
	end
end

core.utils.loadScaleformMovie = function(scaleform)
	if not HasScaleformMovieLoaded(scaleform) then
		RequestScaleformMovie(scaleform)
		local start = GetGameTimer()
		while not HasScaleformMovieLoaded(scaleform) do
			Citizen.Wait(1)
			if GetGameTimer() - start > 10000 then
				return Citizen.Trace('Failed to load scaleform movie: ' .. scaleform)
			end
		end
	end
end

core.utils.loadModel = function(model)
	if not IsModelValid(model) then
		local model = model or 'UNKNOWN'
		local type = 'UNKNOWN'
		if IsModelAPed(model) then
		  type = 'PED'
		elseif IsModelAVehicle(model) then
		  type = 'VEHICLE'
		end
		return Citizen.Trace('Tried to load invalid model: ' .. model .. ' with type ' .. type)
	end
	local start = GetGameTimer()
	while not HasModelLoaded(model) do
		Citizen.Wait(1)
		RequestModel(model)
		if GetGameTimer() - start > 10000 then
	    	return Citizen.Trace('Failed to load model: ' .. model)
		end
	end
end

core.utils.releaseModel = function(model)
	if not IsModelValid(model) then
		local model = model or 'UNKNOWN'
		local type = 'UNKNOWN'
		if IsModelAPed(model) then
		  type = 'PED'
		elseif IsModelAVehicle(model) then
		  type = 'VEHICLE'
		end
		return Citizen.Trace('Tried to release invalid model: ' .. model .. ' with type ' .. type)
	end
	SetModelAsNoLongerNeeded(model)
end

core.utils.teleport = function(x, y, z, h)
	local xType = type(x)
	local pos = (xType == 'table' and x or xType == 'vector3' and x or vector3(x, y, z))
	local heading = (xType == 'table' and y or xType == 'vector3' and y or h and h or GetEntityHeading(PlayerPedId()))
	DoScreenFadeOut(400)
	while IsScreenFadingOut() do
		Citizen.Wait(0)
	end
	SetEntityCoordsNoOffset(PlayerPedId(), pos.x, pos.y, pos.z)
	SetEntityHeading(PlayerPedId(), heading)
	SetGameplayCamRelativeHeading(0.0)
	if not HasCollisionLoadedAroundEntity(PlayerPedId()) then
		FreezeEntityPosition(PlayerPedId(), true)
		while not HasCollisionLoadedAroundEntity(PlayerPedId()) do 
			Citizen.Wait(0)
		end
		FreezeEntityPosition(PlayerPedId(), false)
	end
	Citizen.Wait(400)
	DoScreenFadeIn(400)
end

core.utils.generateUniqueId = function(template)
	local template = template or 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	math.randomseed(GetCloudTimeAsInt())
	return string.gsub(template, '[xy]', function(c)
	  	local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
	  	return string.format('%x', v)
	end)
end