local users = {}

AddEventHandler('playerConnecting', function(name, reject, deferrals)
	local src = source
	local identifier = nil
	--local discord = nil
	for k,v in ipairs(GetPlayerIdentifiers(src)) do
		--if string.find(v, 'discord') then
		--	discord = v
		--end
		if string.sub(v, 1, string.len('steam:')) == 'steam:' then
			identifier = v
			break
		end
	end
	deferrals.defer()
	deferrals.update('\nChecking status of Steam...')
	if not identifier then
		reject('Steam could not be identified, please restart your FiveM client and Steam then try again.')
		CancelEvent()
		return false
	end
	exports.ghmattimysql:execute('SELECT queue_prio, queue_bypass FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if not result[1] then -- user does not exist, create it.
			print('creating new user')
			exports.ghmattimysql:execute('INSERT INTO users (identifier, admin, queue_prio, queue_bypass, settings, active_minutes, last_active) VALUES (@identifier, @admin, @queue_prio, @queue_bypass, @settings, @active_minutes, @last_active)', {
				['@identifier'] = identifier,
				['@admin'] = 0,
				['@queue_prio'] = 10,
				['@queue_bypass'] = 0,
				['@settings'] = json.encode({
					['settings'] = {
						['voice'] = {
							['stereoAudio'] = true,
							['localClickOn'] = true,
							['localClickOff'] = true,
							['remoteClickOn'] = true,
							['remoteClickOff'] = true,
							['clickVolume'] = 80,
							['radioVolume'] = 80,
							['voiceVolume'] = 80,
							['releaseDelay'] = 200
						},
						['hud'] = {}
					}
				}),
				['@active_minutes'] = 0,
				['@last_active'] = os.date('%m-%d-%Y %H:%M:%S', os.time())
			})
		end
		users[identifier] = {
			source = src,
			prio = result[1] and result[1].queue_prio or 10,
			bypass = result[1] and result[1].queue_bypass or false,
			waiting = false,
			connecting = false
		}
		Purge(identifier)
		Citizen.Wait(1000)
		deferrals.update('\nAuthenticating Steam displayname...')
		if name == nil then
			reject('Empty Steam displaynames are not allowed.')
			CancelEvent()
			return false
		end
		if(string.match(name, "[*%%'=`\"]")) then
			reject('There is an invalid character in your Steam displayname, please remove it and restart your FiveM client to connect. (Invalid character: '..string.match(name, "[*%%'=`\"]")..')')
			CancelEvent()
			return false
		end
		if (string.match(name, 'drop') or string.match(name, 'table') or string.match(name, 'database')) then
			reject('SQL baddie huh...')
			CancelEvent()
			return false
		end
		Citizen.Wait(1000)
		deferrals.update('\nChecking serverstatus...')
		local serverStatus = GetConvar('server_status')
		if serverStatus ~= 'open' then
			if not users[identifier].bypass then
				reject(serverStatus)
				CancelEvent()
				return false
			end
		end
		Purge(identifier)
		TriggerEvent('core:consoleLog', self, 'queue', name .. ' connecting...')
		users[identifier].waiting = true
		local stop = false
		repeat
			if users[identifier].connecting then
				stop = true
			end
			if users[identifier].waiting and GetPlayerPing(users[identifier].source) == 0 then
				Purge(identifier)
				deferrals.done('Something went wrong, please restart your FiveM client.')
				CancelEvent()
				return false
			end
			local msg = ' Error: Please restart your FiveM client'
			local place = 1
			local waiting = 0
			local connecting = 0
			for k,v in pairs(users) do
				if v.waiting then
					waiting = waiting + 1
					if v.prio > users[identifier].prio then
						place = place + 1
					end
				end
				if v.connecting then
					connecting = connecting + 1
				end
				if waiting > 0 and connecting + #GetPlayers() < GetConvarInt('sv_maxclients', 64) then
					if waiting == 0 then return end
					if v.waiting and v.prio > 0 then
						users[k].waiting = false
						users[k].connecting = true
					end
				end
				local block = false
				if identifier == k and v.waiting then
					v.prio = v.prio + 1
					block = true
				end
				if not block then
					if identifier == k and v.connecting then
						block = true
					end
					if not block then
						Purge(identifier)
						users[identifier] = nil
					end
				end
			end
			msg = waiting > 0 and 'Awaiting connection, you are at position ' .. place .. '/'.. waiting .. ' in the queue' .. '.\n' or 'Awaiting connection, you are at position ' .. place .. '/1 in the queue' .. '.\n'
			deferrals.update(msg)
			Citizen.Wait(5000)
		until stop
		deferrals.done()
		return true
	end)
end)

AddEventHandler('playerDropped', function()
	if core.utils.getUserFromId(source).identifier ~= nil then
		Purge(core.utils.getUserFromId(source).identifier)
	else
		TriggerEvent('core:consoleLog', source, 'queue', 'Fatal error, could not locate identifier for source: ' .. source)
	end
end)

function Purge(identifier)
	if users[identifier].connecting then
		users[identifier].connecting = false
	end
	if users[identifier].waiting then
		users[identifier].waiting = false
	end
end