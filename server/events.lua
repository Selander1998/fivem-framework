primetime = false

Citizen.CreateThread(function()
    local developmentServer = GetConvar('is_devserver')
	local version = 'Unknown server type, be sure to set is_devserver variable in your server configuration file.'
	if developmentServer ~= nil then
    	if developmentServer then
			version = 'Development Server.'
			StopResource('example-resource')
    	else
			version = 'Production Server.'
    	    StopResource('devtools')
    	end
	end
	if tonumber(os.date('%H', os.time())) > 17 then
        primetime = true
    end
    Citizen.Wait(2000)
    print('Framework initialized\nRunning as ' .. version)
	exports.ghmattimysql:execute('SELECT * FROM job_grades', function(result)
		for k,v in pairs(result) do
			if core.jobs[v.job_name] then
				core.jobs[v.job_name].grades[v.grade] = {
					grade = v.grade,
					label = v.label,
					salary = v.salary
				}
			end
		end
	end)
end)

RegisterServerEvent('core:activatePrimetime')
AddEventHandler('core:activatePrimetime', function()
    primetime = true
    TriggerClientEvent('core:setCharacterData', -1, 'primetime', primetime)
end)

RegisterServerEvent('tools:setPrimetime')
AddEventHandler('tools:setPrimetime', function()
    if primetime then
        TriggerClientEvent('core:setCharacterData', source, 'primetime', primetime)
    end
end)

RegisterServerEvent('core:switchDutyState')
AddEventHandler('core:switchDutyState', function(job)
	if core.jobs[job].duty then
		local character = core.utils.getCharacterFromId(source)
		local radioFrequencies = {
			['ambulance'] = 2.00,
			['police'] = 1.00
		}
		character.onDuty = not character.onDuty
		if radioFrequencies[job] then
			TriggerClientEvent(character.onDuty and 'radio:addPlayerToRadio' or 'radio:removePlayerFromRadio', character.source, radioFrequencies[job])
		end
		TriggerClientEvent('core:notify', character.source, character.onDuty and 'inform' or 'error', character.onDuty and 'You are not on duty' or 'You are now off duty')
		TriggerEvent('core:dutyChanged', character.source, character.onDuty)
		TriggerClientEvent('core:dutyChanged', character.source, character.onDuty)
	end
end)

RegisterServerEvent('core:addMoney')
AddEventHandler('core:addMoney', function(amount, account)
	local src = source
	local character = core.utils.getCharacterFromId(src)
	if account == 'bank' then
		character.addBank(amount)
		TriggerClientEvent('core:notify', character.source, 'inform', amount .. '$ was added to your bank account', 7500)
	else
		character.addMoney(amount)
	end
	incomeTable[character.identifier].totalIncome = incomeTable[character.identifier].totalIncome + amount
end)

RegisterServerEvent('core:removeMoney')
AddEventHandler('core:removeMoney', function(amount, account, event, params)
	local src = source
	local character = core.utils.getCharacterFromId(src)
	if account == 'bank' then
		if character.bank < amount then TriggerClientEvent('core:notify', character.source, 'error', 'Insufficent funds in bankaccount') return end
		character.removeBank(price)
		TriggerClientEvent('core:notify', character.source, 'inform', 'A transaction of ' .. amount .. '$ was drawn from your bank account', 7500)
		if event ~= 'none' then
			TriggerClientEvent(event, character.source, params)
		end
	else
		if character.money < amount then TriggerClientEvent('core:notify', character.source, 'error', 'You dont have enough cash on you') return end
		character.removeMoney(amount)
		TriggerClientEvent(event, character.source, params)
	end
end)

RegisterServerEvent('core:playerCompanySplit')
AddEventHandler('core:playerCompanySplit', function(amount, playerSplit, societySplit)
	local character = core.utils.getCharacterFromId(source)
	if playerSplit <= 0 then TriggerEvent('banking:updateCompany', core.maths.round(amount), character.job.label, 'add') return end
	local societyMoney = core.maths.round(amount / 100 * societySplit)
	character.addMoney(core.maths.round(amount / 100 * playerSplit))
	TriggerEvent('banking:updateCompany', societyMoney, character.job.label, 'add')
	TriggerClientEvent('core:notify', character.source, 'inform', 'Your company got ' .. societyMoney .. '$', 7500)
end)

RegisterServerEvent('core:updateSettingsTable')
AddEventHandler('core:updateSettingsTable', function(settings)
    core.utils.getUserFromId(source).updateSettings(settings)
end)

RegisterServerEvent('core:discordLog')
AddEventHandler('core:discordLog', function(src, log, message, color)
	if GetConvar('is_devserver') then return end
	if not log then log = 'admin' end
	local channels = { -- Create separate webhooks & channels for logs
		['admin'] = 'disccord_webhook_url',
		['error'] = 'disccord_webhook_url',
		['anticheat'] = 'disccord_webhook_url',
		['police'] = 'disccord_webhook_url'
	}
	local id = src or source
	local discord = core.utils.getDiscordId(id) or 'Could not find Discord ID'
    local embeds = {
        {
            ['type'] = 'rich',
            ['title'] = GetPlayerName(id) .. ', ' .. discord or 'Name missing, sadge',
            ['description'] = message or 'Message missing',
            ['color'] = color or 10092339, -- This needs color Decimal, use https://convertingcolors.com/hex-color-FF0000.html?search=#FF0000 to convert ||| RED: 16711680, ORANGE: 16744960, GREEN: 10092339
            ['footer'] = {
                ['text'] = 'Admin log: ' .. os.date()
            }
        }
    }
	PerformHttpRequest(channels[log], function(err, text, headers) end, 'POST', json.encode({
		embeds = embeds, 
		avatar_url = 'avatar_url'
	}), {['Content-Type'] = 'application/json'})
end)