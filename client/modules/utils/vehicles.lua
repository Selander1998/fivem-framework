core.utils.spawnVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
	Citizen.CreateThread(function()
		core.utils.loadModel(model)
		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
		local id = NetworkGetNetworkIdFromEntity(vehicle)
		SetNetworkIdCanMigrate(id, true)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		core.utils.releaseModel(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			Citizen.Wait(0)
		end
		SetVehRadioStation(vehicle, 'OFF')
		if cb ~= nil then
			cb(vehicle)
		end
	end)
end

core.utils.spawnLocalVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
	Citizen.CreateThread(function()
		core.utils.loadModel(model)
		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		core.utils.releaseModel(model)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			Citizen.Wait(0)
		end
		SetVehRadioStation(vehicle, 'OFF')
		if cb ~= nil then
			cb(vehicle)
		end
	end)
end

core.utils.getAllVehicles = function()
	local vehicles = {}
	for vehicle in enumerateVehicles() do
		table.insert(vehicles, vehicle)
	end
	return vehicles
end

core.utils.getClosestVehicle = function(coords)
	local coords = coords or GetEntityCoords(PlayerPedId())
	local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 100.0, 0.0)
	return getVehicleInDirection(coords, offset)
end

function getVehicleInDirection(from, to)
    local offset = 0
    local vehicle
    for i = 0, 100 do
        local rayHandle = CastRayPointToPoint(from.x, from.y, from.z, to.x, to.y, to.z + offset, 10, PlayerPedId(), 0)   
        _, _, _, _, vehicle = GetRaycastResult(rayHandle)
        offset = offset - 1
        if vehicle ~= 0 then 
            break 
        end
    end
	local distance = #(vector3(from.x, from.y, from.z) - GetEntityCoords(vehicle))
    if distance > 25.0 then 
        vehicle = nil
    end
    return {
		entity = vehicle ~= nil and vehicle or 0,
		distance = core.maths.round(distance, 1) or nil,
		plate = GetVehicleNumberPlateText(vehicle)
	}
end

core.utils.isVehicleAnchorable = function(vehicle)
	local vehicleModel = GetEntityModel(vehicle)
    if vehicleModel ~= nil and vehicleModel ~= 0 then
        if IsThisModelABoat(vehicleModel) or IsThisModelAJetski(vehicleModel) or IsThisModelAnAmphibiousCar(vehicleModel) or IsThisModelAnAmphibiousQuadbike(vehicleModel) then
			return true
		end
	end
end

core.utils.getVehicleProperties = function(vehicle)
	local color1, color2 = GetVehicleColours(vehicle)
	local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
	local extras = {}
	for id = 0, 12 do
		if DoesExtraExist(vehicle, id) then
			local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
			extras[tostring(id)] = state
		end
	end
	return {
		model             = GetEntityModel(vehicle),
		plate             = GetVehicleNumberPlateText(vehicle),
		plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),
		bodyHealth        = core.maths.round(GetVehicleBodyHealth(vehicle), 1),
		engineHealth      = core.maths.round(GetVehicleEngineHealth(vehicle), 1),
		dirtLevel         = core.maths.round(GetVehicleDirtLevel(vehicle), 1),
		color1            = color1,
		color2            = color2,
		pearlescentColor  = pearlescentColor,
		wheelColor        = wheelColor,
		wheels            = GetVehicleWheelType(vehicle),
		windowTint        = GetVehicleWindowTint(vehicle),
		neonEnabled       = {
			IsVehicleNeonLightEnabled(vehicle, 0),
			IsVehicleNeonLightEnabled(vehicle, 1),
			IsVehicleNeonLightEnabled(vehicle, 2),
			IsVehicleNeonLightEnabled(vehicle, 3)
		},
		extras            = extras,
		neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
		tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),
		modSpoilers       = GetVehicleMod(vehicle, 0),
		modFrontBumper    = GetVehicleMod(vehicle, 1),
		modRearBumper     = GetVehicleMod(vehicle, 2),
		modSideSkirt      = GetVehicleMod(vehicle, 3),
		modExhaust        = GetVehicleMod(vehicle, 4),
		modFrame          = GetVehicleMod(vehicle, 5),
		modGrille         = GetVehicleMod(vehicle, 6),
		modHood           = GetVehicleMod(vehicle, 7),
		modFender         = GetVehicleMod(vehicle, 8),
		modRightFender    = GetVehicleMod(vehicle, 9),
		modRoof           = GetVehicleMod(vehicle, 10),
		modEngine         = GetVehicleMod(vehicle, 11),
		modBrakes         = GetVehicleMod(vehicle, 12),
		modTransmission   = GetVehicleMod(vehicle, 13),
		modHorns          = GetVehicleMod(vehicle, 14),
		modSuspension     = GetVehicleMod(vehicle, 15),
		modArmor          = GetVehicleMod(vehicle, 16),
		modTurbo          = IsToggleModOn(vehicle, 18),
		modSmokeEnabled   = IsToggleModOn(vehicle, 20),
		modXenon          = IsToggleModOn(vehicle, 22),
		modFrontWheels    = GetVehicleMod(vehicle, 23),
		modBackWheels     = GetVehicleMod(vehicle, 24),
		modPlateHolder    = GetVehicleMod(vehicle, 25),
		modVanityPlate    = GetVehicleMod(vehicle, 26),
		modTrimA          = GetVehicleMod(vehicle, 27),
		modOrnaments      = GetVehicleMod(vehicle, 28),
		modDashboard      = GetVehicleMod(vehicle, 29),
		modDial           = GetVehicleMod(vehicle, 30),
		modDoorSpeaker    = GetVehicleMod(vehicle, 31),
		modSeats          = GetVehicleMod(vehicle, 32),
		modSteeringWheel  = GetVehicleMod(vehicle, 33),
		modShifterLeavers = GetVehicleMod(vehicle, 34),
		modAPlate         = GetVehicleMod(vehicle, 35),
		modSpeakers       = GetVehicleMod(vehicle, 36),
		modTrunk          = GetVehicleMod(vehicle, 37),
		modHydrolic       = GetVehicleMod(vehicle, 38),
		modEngineBlock    = GetVehicleMod(vehicle, 39),
		modAirFilter      = GetVehicleMod(vehicle, 40),
		modStruts         = GetVehicleMod(vehicle, 41),
		modArchCover      = GetVehicleMod(vehicle, 42),
		modAerials        = GetVehicleMod(vehicle, 43),
		modTrimB          = GetVehicleMod(vehicle, 44),
		modTank           = GetVehicleMod(vehicle, 45),
		modWindows        = GetVehicleMod(vehicle, 46),
		modLivery         = GetVehicleLivery(vehicle)
	}
end

core.utils.setVehicleProperties = function(vehicle, props)
	SetVehicleModKit(vehicle, 0)
	if props.plate ~= nil then
		SetVehicleNumberPlateText(vehicle, props.plate)
	end
	if props.plateIndex ~= nil then
		SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
	end
	if props.bodyHealth ~= nil then
		SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0 or 1000.0)
	end
	if props.engineHealth ~= nil then
		SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0 or 1000.0)
	end
	if props.dirtLevel ~= nil then
		SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
	end
	if props.color1 ~= nil then
		local color1, color2 = GetVehicleColours(vehicle)
		SetVehicleColours(vehicle, props.color1, color2)
	end
	if props.color2 ~= nil then
		local color1, color2 = GetVehicleColours(vehicle)
		SetVehicleColours(vehicle, color1, props.color2)
	end
	if props.pearlescentColor ~= nil then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
	end
	if props.wheelColor ~= nil then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, pearlescentColor, props.wheelColor)
	end
	if props.wheels ~= nil then
		SetVehicleWheelType(vehicle, props.wheels)
	end
	if props.windowTint ~= nil then
		SetVehicleWindowTint(vehicle, props.windowTint)
	end
	if props.neonEnabled ~= nil then
		SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
		SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
		SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
		SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
	end
	if props.extras ~= nil then
		for id,enabled in pairs(props.extras) do
			if enabled then
				SetVehicleExtra(vehicle, tonumber(id), 0)
			else
				SetVehicleExtra(vehicle, tonumber(id), 1)
			end
		end
	end
	if props.neonColor ~= nil then
		SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
	end
	if props.modSmokeEnabled ~= nil then
		ToggleVehicleMod(vehicle, 20, true)
	end
	if props.tyreSmokeColor ~= nil then
		SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
	end
	if props.modSpoilers ~= nil then
		SetVehicleMod(vehicle, 0, props.modSpoilers, false)
	end
	if props.modFrontBumper ~= nil then
		SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
	end
	if props.modRearBumper ~= nil then
		SetVehicleMod(vehicle, 2, props.modRearBumper, false)
	end
	if props.modSideSkirt ~= nil then
		SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
	end
	if props.modExhaust ~= nil then
		SetVehicleMod(vehicle, 4, props.modExhaust, false)
	end
	if props.modFrame ~= nil then
		SetVehicleMod(vehicle, 5, props.modFrame, false)
	end
	if props.modGrille ~= nil then
		SetVehicleMod(vehicle, 6, props.modGrille, false)
	end
	if props.modHood ~= nil then
		SetVehicleMod(vehicle, 7, props.modHood, false)
	end
	if props.modFender ~= nil then
		SetVehicleMod(vehicle, 8, props.modFender, false)
	end
	if props.modRightFender ~= nil then
		SetVehicleMod(vehicle, 9, props.modRightFender, false)
	end
	if props.modRoof ~= nil then
		SetVehicleMod(vehicle, 10, props.modRoof, false)
	end
	if props.modEngine ~= nil then
		SetVehicleMod(vehicle, 11, props.modEngine, false)
	end
	if props.modBrakes ~= nil then
		SetVehicleMod(vehicle, 12, props.modBrakes, false)
	end
	if props.modTransmission ~= nil then
		SetVehicleMod(vehicle, 13, props.modTransmission, false)
	end
	if props.modHorns ~= nil then
		SetVehicleMod(vehicle, 14, props.modHorns, false)
	end
	if props.modSuspension ~= nil then
		SetVehicleMod(vehicle, 15, props.modSuspension, false)
	end
	if props.modArmor ~= nil then
		SetVehicleMod(vehicle, 16, props.modArmor, false)
	end
	if props.modTurbo ~= nil then
		ToggleVehicleMod(vehicle,  18, props.modTurbo)
	end
	if props.modXenon ~= nil then
		ToggleVehicleMod(vehicle,  22, props.modXenon)
	end
	if props.modFrontWheels ~= nil then
		SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
	end
	if props.modBackWheels ~= nil then
		SetVehicleMod(vehicle, 24, props.modBackWheels, false)
	end
	if props.modPlateHolder ~= nil then
		SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
	end
	if props.modVanityPlate ~= nil then
		SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
	end
	if props.modTrimA ~= nil then
		SetVehicleMod(vehicle, 27, props.modTrimA, false)
	end
	if props.modOrnaments ~= nil then
		SetVehicleMod(vehicle, 28, props.modOrnaments, false)
	end
	if props.modDashboard ~= nil then
		SetVehicleMod(vehicle, 29, props.modDashboard, false)
	end
	if props.modDial ~= nil then
		SetVehicleMod(vehicle, 30, props.modDial, false)
	end
	if props.modDoorSpeaker ~= nil then
		SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
	end
	if props.modSeats ~= nil then
		SetVehicleMod(vehicle, 32, props.modSeats, false)
	end
	if props.modSteeringWheel ~= nil then
		SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
	end
	if props.modShifterLeavers ~= nil then
		SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
	end
	if props.modAPlate ~= nil then
		SetVehicleMod(vehicle, 35, props.modAPlate, false)
	end
	if props.modSpeakers ~= nil then
		SetVehicleMod(vehicle, 36, props.modSpeakers, false)
	end
	if props.modTrunk ~= nil then
		SetVehicleMod(vehicle, 37, props.modTrunk, false)
	end
	if props.modHydrolic ~= nil then
		SetVehicleMod(vehicle, 38, props.modHydrolic, false)
	end
	if props.modEngineBlock ~= nil then
		SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
	end
	if props.modAirFilter ~= nil then
		SetVehicleMod(vehicle, 40, props.modAirFilter, false)
	end
	if props.modStruts ~= nil then
		SetVehicleMod(vehicle, 41, props.modStruts, false)
	end
	if props.modArchCover ~= nil then
		SetVehicleMod(vehicle, 42, props.modArchCover, false)
	end
	if props.modAerials ~= nil then
		SetVehicleMod(vehicle, 43, props.modAerials, false)
	end
	if props.modTrimB ~= nil then
		SetVehicleMod(vehicle, 44, props.modTrimB, false)
	end
	if props.modTank ~= nil then
		SetVehicleMod(vehicle, 45, props.modTank, false)
	end
	if props.modWindows ~= nil then
		SetVehicleMod(vehicle, 46, props.modWindows, false)
	end
	if props.modLivery ~= nil then
		SetVehicleMod(vehicle, 48, props.modLivery, false)
		SetVehicleLivery(vehicle, props.modLivery)
	end
	if props.windows then
		for windowId = 1, 13, 1 do
			if props.windows[windowId] == false then
				SmashVehicleWindow(vehicle, windowId)
			end
		end
	end
	if props.tyres then
        for tyreId = 1, 7, 1 do
            if props.tyres[tyreId] ~= false then
                SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
            end
        end
    end
	if props.doors then
        for doorId = 0, 5, 1 do
            if props.doors[doorId] ~= false then
                SetVehicleDoorBroken(vehicle, doorId - 1, true)
            end
        end
    end
	local fuelLevel = exports['vehiclehud']:getFuelLevel(vehicle)
	exports['vehiclehud']:setFuelLevel(vehicle, fuelLevel)
end

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

local function enumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end
		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
		local next = true
		repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
		until not next
		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function enumerateVehicles()
	return enumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

core.utils.getVehicleColorName = function(vehicle)
	local vehicleColors = { -- Sorry about these being in Swedish, might translate sometime
		[0] = 'Svart Metallic',
		[1] = 'Grafitsvart Metallic',
		[2] = 'Stålsvart Metallic',
		[3] = 'Mörk Silver Metallic',
		[4] = 'Silver Metallic',
		[5] = 'Blåsilver Metallic',
		[6] = 'Stålgrå Metallic',
		[7] = 'Skuggad Silver Metallic',
		[8] = 'Silversten Metallic',
		[9] = 'Midnattssilver Metallic',
		[10] = 'Gråsvart Metallic',
		[11] = 'Gråvart Blank Metallic',
		[12] = 'Mattsvart',
		[13] = 'Mattgrå',
		[14] = 'Ljus Mattgrå',
		[15] = 'Svartplast',
		[16] = 'Svart Polyester',
		[17] = 'Mörk Silver',
		[18] = 'Silverplast',
		[19] = 'Djupgrå',
		[20] = 'Silverskuggad Grå',
		[21] = 'Sliten Svart',
		[22] = 'Sliten Grafit',
		[23] = 'Sliten Silvergrå',
		[24] = 'Sliten Silver',
		[25] = 'Sliten Blåsilver',
		[26] = 'Sliten Skuggad Silver',
		[27] = 'Röd Metallic',
		[28] = 'Sportröd Metallic',
		[29] = 'Sportbilsröd Metallic',
		[30] = 'Eldsröd Metallic',
		[31] = 'Finröd Metallic',
		[32] = 'Garnröd Metallic',
		[33] = 'Ökenröd Metallic',
		[34] = 'Vinröd Metallic',
		[35] = 'Candy Metallic',
		[36] = 'Orange Soluppgång Metallic',
		[37] = 'Klassisk Guld Metallic',
		[38] = 'Orange Metallic',
		[39] = 'Mattröd',
		[40] = 'Mörk Mattröd',
		[41] = 'Mattorange',
		[42] = 'Mattgul',
		[43] = 'Plaströd',
		[44] = 'Ljus Plaströd',
		[45] = 'Djupröd Plast',
		[46] = 'Sliten Röd',
		[47] = 'Sliten Gyllenröd',
		[48] = 'Sliten Mörkröd',
		[49] = 'Mörkgrön Metallic',
		[50] = 'Rallygrön Metallic',
		[51] = 'Havsgrön Metallic',
		[52] = 'Olivgrön Metallic',
		[53] = 'Grön Metallic',
		[54] = 'Bensingrön Metallic',
		[55] = 'Matt Limegrön',
		[56] = 'Mörkgrön',
		[57] = 'Grön',
		[58] = 'Sliten Mörkgrön',
		[59] = 'Sliten Grön',
		[60] = 'Pistagegrön',
		[61] = 'Midnattsblå Metallic',
		[62] = 'Mörkblå Metallic',
		[63] = 'Himmelsblå Metallic',
		[64] = 'Blå Metallic',
		[65] = 'Marinblå Metallic',
		[66] = 'Hamnblå Metallic',
		[67] = 'Diamantblå Metallic',
		[68] = 'Surfblå Metallic',
		[69] = 'Sjömansblå Metallic',
		[70] = 'Ljusblå Metallic',
		[71] = 'Lilablå Metallic',
		[72] = 'Spinnakerblå Metallic',
		[73] = 'Ultrablå Metallic',
		[74] = 'Ljusblå Metallic',
		[75] = 'Mörkblå',
		[76] = 'Midnattsblå',
		[77] = 'Blå',
		[78] = 'Turkos',
		[79] = 'Blixtblå',
		[80] = 'Raggarblå',
		[81] = 'Ljusblå',
		[82] = 'Mattmörkblå',
		[83] = 'Mattblå',
		[84] = 'Matt Midnattsblå',
		[85] = 'Sliten Mörkblå',
		[86] = 'Sliten Blå',
		[87] = 'Sliten Ljusblå',
		[88] = 'Taxigul Metallic',
		[89] = 'Rallygul Metallic',
		[90] = 'Brons Metallic',
		[91] = 'Pippigul Metallic',
		[92] = 'Lime Metallic',
		[93] = 'Champange Metallic',
		[94] = 'Beige Metallic',
		[95] = 'Elfenbens Metallic',
		[96] = 'Kakaobrun Metallic',
		[97] = 'Gyllenbrun Metallic',
		[98] = 'Ljusbrun Metallic',
		[99] = 'Stråbeige Metallic',
		[100] = 'Mossgrön Metallic',
		[101] = 'Brun Metallic',
		[102] = 'Ljusbrun Metallic',
		[103] = 'Mörkbrun Metallic',
		[104] = 'Orange Metallic',
		[105] = 'Sandbrun Metallic',
		[106] = 'Brun Metallic',
		[107] = 'Vit Metallic',
		[108] = 'Brun',
		[109] = 'Mörkbrun',
		[110] = 'Ljusbrun',
		[111] = 'Vit Metallic',
		[112] = 'Frostvit Metallic',
		[113] = 'Honungsbeige',
		[114] = 'Brun',
		[115] = 'Mörkbrun',
		[116] = 'Beige',
		[117] = 'Borstat Stål',
		[118] = 'Borstat Mörkt Stål',
		[119] = 'Borstat Aluminium',
		[120] = 'Krom',
		[121] = 'White',
		[122] = 'Off-White',
		[123] = 'Orange',
		[124] = 'Ljus Orange',
		[125] = 'Grön Metallic',
		[126] = 'Taxigul',
		[127] = 'Polisblå',
		[128] = 'Mattgrön',
		[129] = 'Mattbrun',
		[130] = 'Sliten Orange',
		[131] = 'Mattvit',
		[132] = 'Sliten Vit',
		[133] = 'Sliten Olivgrön',
		[134] = 'Snövit',
		[135] = 'Rosa',
		[136] = 'Laxrosa',
		[137] = 'Rosa Metallic',
		[138] = 'Orange',
		[139] = 'Grön',
		[140] = 'Blå',
		[141] = 'Mörkblå Metallic',
		[142] = 'Mörklila Metallic',
		[143] = 'Mörkröd Metallic',
		[144] = 'Armégrön',
		[145] = 'Lila Metallic',
		[146] = 'Mörkblå Metallic',
		[147] = 'Svart',
		[148] = 'Matt lila',
		[149] = 'Matt mörklila',
		[150] = 'Lavaröd Metallic',
		[151] = 'Matt Skogsgrön',
		[152] = 'Matt Olivegrön',
		[153] = 'Matt Brun',
		[154] = 'Matt Ljusbrun',
		[155] = 'Matt Armégrön',
		[156] = 'Unknown',
		[157] = 'Blue',
		[158] = 'Ren Guld',
		[159] = 'Bortstat Guld',
		[160] = 'MP100'
	}
	local f, s = GetVehicleColours(vehicle)
	return {
		primary = vehicleColors[f] or 'Okänd',
		secondary = vehicleColors[s] or 'Okänd'
	}
end

core.utils.isVehicleRearEngined = function(vehicle, name)
	local rearEngineVehicles = {
		'ninef',
		'adder',
		'vagner',
		't20',
		'infernus',
		'zentorno',
		'reaper',
		'comet2',
		'comet3',
		'jester',
		'jester2',
		'cheetah',
		'cheetah2',
		'prototipo',
		'turismor',
		'pfister811',
		'ardent',
		'nero',
		'nero2',
		'tempesta',
		'vacca',
		'bullet',
		'osiris',
		'entityxf',
		'turismo2',
		'fmj',
		're7b',
		'tyrus',
		'italigtb',
		'penetrator',
		'monroe',
		'ninef2',
		'stingergt',
		'surfer',
		'surfer2',
	}
	return rearEngineVehicles[GetDisplayNameFromVehicleModel(GetHashKey(vehicle))] and true or false
end

core.utils.getVehicleSeat = function(vehicle, ped)
    if GetPedInVehicleSeat(vehicle, -1) == ped then -- Driverseat
        return 2
    elseif GetPedInVehicleSeat(vehicle, 0) == ped then -- Passengerseat
        return 1
    elseif GetPedInVehicleSeat(vehicle, 1) == ped then
        return 4
    elseif GetPedInVehicleSeat(vehicle, 2) == ped then
        return 3
    end
end