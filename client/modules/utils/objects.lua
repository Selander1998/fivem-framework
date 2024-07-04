core.utils.spawnObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))
	Citizen.CreateThread(function()
		core.utils.loadModel(model)
		local obj = CreateObject(model, coords.x, coords.y, coords.z, true, false, true)
		if cb ~= nil then
			cb(obj)
		end
	end)
end

core.utils.setGlobalObject = function(object)
	NetworkRegisterEntityAsNetworked(object)
	local netid = ObjToNet(object)
	SetNetworkIdExistsOnAllMachines(netid, true)
	NetworkSetNetworkIdDynamic(netid, true)
	SetNetworkIdCanMigrate(netid, false) 
	for i = 1, 255 do
	  	SetNetworkIdSyncToPlayer(netid, i, true)
	end
end