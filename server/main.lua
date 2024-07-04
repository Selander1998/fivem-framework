core = {}
core.callbacks = {}
core.users = {}
core.characters = {}
core.utils = {}
core.maths = {}

RegisterServerEvent('core:loadUser')
AddEventHandler('core:loadUser', function()
	local src = source
	local identifier = nil

	for k,v in ipairs(GetPlayerIdentifiers(src)) do
		if string.sub(v, 1, string.len('steam:')) == 'steam:' then
			identifier = v
			break
		end
	end

	if not identifier then DropPlayer(src, 'Could not find SteamID, restart your Fivem and Steam clients.') return end

	exports.ghmattimysql:execute('SELECT admin, queue_prio, queue_bypass, active_minutes, settings FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		local queryData = {
			source = src,
			identifier = identifier,
			admin = result[1].admin or false,
			queue = {
				priority = result[1].queue_prio,
				bypass = result[1].queue_bypass or false
			},
			settings = json.decode(result[1].settings),
			playtime = result[1].active_minutes or 0
		}
		local user = loadUser(queryData)

		if not user then DropPlayer(src, 'Your user could not be loaded correctly.') end

		core.users[src] = user
		TriggerClientEvent('core:setCharacterData', src, 'user', user)
		TriggerClientEvent('core:addChatSuggestions', src, user.admin and true or false)

	end)
end)

RegisterServerEvent('core:loadCharacter')
AddEventHandler('core:loadCharacter', function(cid)
	local src = source
	local user = core.utils.getUserFromId(src)
	if not user.identifier then DropPlayer(src, 'Your user could not be loaded correctly.') return end
	local income = {
		startingTime = user.playtime,
		sessionTime = GetGameTimer(),
		totalIncome = 0
	}
	exports.ghmattimysql:execute('SELECT job, job_grade, money, bank, firstname, lastname, sex, phone_number, status, dateofbirth, lastdigits, licenses FROM characters WHERE cid = @cid', {
		['@cid'] = cid
	}, function(result)
		local queryData = {
			job = result[1].job,
			grade = result[1].job_grade,
			money = result[1].money,
			bank = result[1].bank,
			name = {
				firstname = result[1].firstname,
				lastname = result[1].lastname
			},
			gender = result[1].sex,
			phoneNumber = result[1].phone_number,
			status = json.decode(result[1].status),
			dob = result[1].dateofbirth,
			lastdigits = result[1].lastdigits,
			licenses = json.decode(result[1].licenses)
		}
		if core.jobs[queryData.job] and core.jobs[queryData.job].grades[queryData.grade] then
			local jobData = {
				name = queryData.job,
				label = core.jobs[queryData.job].label,
				grade = core.jobs[queryData.job].grades[queryData.grade].grade,
				grade_label = core.jobs[queryData.job].grades[queryData.grade].label,
				grade_salary = core.jobs[queryData.job].grades[queryData.grade].salary
			}
			local character = loadCharacter(src, cid, jobData, queryData, core.jobs[queryData.job].duty, income)

			if not character then DropPlayer(src, 'Your character could not be loaded correctly') end

			core.characters[character.source] = character
			character.user = user
			character.trunk = false
			character.dead = false
			character.nui = false
			character.primetime = primetime
			character.handcuffed = false
			character.property = {}
			
			TriggerEvent('core:characterLoaded', character.source, character)
			TriggerClientEvent('core:characterLoaded', character.source, character)

		else
			DropPlayer(character.source, 'Your characters job is invalid.')
		end
	end)
end)

RegisterServerEvent('core:unloadCharacter')
AddEventHandler('core:unloadCharacter', function()
	TriggerEvent('core:characterUnloaded')
	TriggerClientEvent('core:characterUnloaded', source)
	TriggerEvent('playerDropped', 'characterswitch')
end)

AddEventHandler('playerDropped', function(reason)
	local src = source
	local reason = string.lower(reason) or 'unknown'
	local coords = GetEntityCoords(GetPlayerPed(src)) or vector3(-263.29086303711, -967.51324462891, 31.224555969238)
	if string.match(reason, 'game crashed') then
		TriggerEvent('core:discordLog', src, 'error', 'Crashed with reason: ' .. reason, 16711680)
		exports.ghmattimysql:execute('INSERT INTO crashdata (error, coords) VALUES (@error, @coords)', {
			['@error'] = string.sub(reason, 14, -1),
			['@coords'] = json.encode({x = coords[1], y = coords[2], z = coords[3]})
		})
	end
	local character = core.utils.getCharacterFromId(src)
	if character then
		local time = math.floor(GetGameTimer() - character.income.sessionTime / 1000 / 60)
		local income = character.income.totalIncome
		local dollarsPerMinute = income / time or 0
		local suspiciusDollarAmount = 0
		if dollarsPerMinute > suspiciusDollarAmount then
			TriggerEvent('core:discordLog', character.source, 'admin', GetPlayerName(character.source) .. ' earned ' .. income .. '$ in ' .. time .. ' minutes of playing', 16711680)
		end
		exports.ghmattimysql:execute('UPDATE characters SET money = @money, bank = @bank, status = @status, licenses = @licenses, dropreason = @dropreason, dropcoords = @dropcoords WHERE cid = @cid', {
			['@cid'] = character.cid,
			['@money'] = character.money,
			['@bank'] = character.bank,
			['@status'] = json.encode(character.status),
			['@licenses'] = json.encode(character.licenses),
			['@dropreason'] = reason,
			['@dropcoords'] = json.encode({x = coords[1], y = coords[2], z = coords[3]})
		})
		if reason ~= 'characterswitch' then
			local user = core.utils.getUserFromId(src)
			if user then
				exports.ghmattimysql:execute('UPDATE users SET admin = @admin, queue_prio = @queue_prio, queue_bypass = @queue_bypass, settings = @settings, active_minutes = @active_minutes, last_active = @last_active WHERE identifier = @identifier', {
					['@identifier'] = user.identifier,
					['@admin'] = user.admin,
					['@queue_prio'] = user.queue.priority,
					['@queue_bypass'] = user.queue.bypass,
					['@settings'] = json.encode(user.settings),
					['@active_minutes'] = character.income.startingTime + time,
					['@last_active'] = os.date('%m-%d-%Y %H:%M:%S', os.time())
				})
			end
			core.users[user.source] = nil
		end
		Wait(1000) -- To allow other resources to use character on playerDropped event, without this the other resources will lose traction of target
		core.characters[character.source] = nil
	end
end)