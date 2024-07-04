function loadUser(user)
	local self = {}
	self.source = user.source
	self.identifier = user.identifier
	self.admin = user.admin
	self.queue = user.queue
	self.settings = user.settings
	self.playtime = user.playtime

	self.updateSettings = function(settings)
		self.settings = settings
		TriggerClientEvent('core:setCharacterData', self.source, 'settings', settings)
		exports.ghmattimysql:execute('UPDATE users SET settings = @settings WHERE identifier = @identifier', {
			['@identifier'] = self.identifier,
			['@settings'] = json.encode(settings)
		})
	end
	
	return self
end