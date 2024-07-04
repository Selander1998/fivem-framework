function loadCharacter(source, cid, job, query, duty, income)
	local self = {}
	self.source = source
	self.cid = cid
	self.money = query.money
	self.bank = query.bank
	self.name = query.name
	self.gender = gender
	self.phoneNumber = query.phoneNumber
	self.status = query.status
	self.dob = query.dob
	self.lastDigits = query.lastDigits
	self.licenses = query.licenses
	self.job = job
	self.onDuty = duty
	self.income = income

	self.setMoney = function(newAmount)
		self.money = core.maths.round(newAmount)
	end
	self.addMoney = function(money)
		money = core.maths.round(money)
		if money >= 0 then
			self.money = self.money + money
			TriggerClientEvent('core:cashUpdate', self.source, self.money, money, false)
		end
	end
	self.removeMoney = function(money)
		money = core.maths.round(money)
		if money >= 0 then
			self.money = self.money - money
			TriggerClientEvent('core:cashUpdate', self.source, self.money, money, true)
		end
	end

	self.setBank = function(newAmount)
		self.bank = core.maths.round(newAmount)
	end
	self.addBank = function(amount)
		round = core.maths.round(amount)
		if round >= 0 then
			self.bank = self.bank + round
		end
	end
	self.removeBank = function(amount)
		round = core.maths.round(amount)
		if round >= 0 then
			self.bank = self.bank - round
		end
	end

	self.getFullName = function()
		return self.name.firstname .. ' ' .. self.name.lastname
	end

	self.setJob = function(job, grade)
		if core.jobs[job] and core.jobs[job].grades[grade] then
			local oldJob = self.job
			self.duty = true
			self.job.name = core.jobs[job].name
			self.job.label = core.jobs[job].label
			self.job.grade = core.jobs[job].grades[grade]
			self.job.grade_label = core.jobs[job].grades[grade].label
			self.job.grade_salary = core.jobs[job].grades[grade].salary
			TriggerEvent('core:updateJob', self.source, self.job, oldJob)
			TriggerClientEvent('core:updateJob', self.source, self.job, oldJob)
			exports.ghmattimysql:execute('UPDATE characters SET job = @job, job_grade = @job_grade WHERE cid = @cid', {
				['@job'] = job,
				['@job_grade'] = grade,
				['@cid'] = self.cid
			})
		else
			TriggerEvent('core:consoleLog', self.source, 'jobs', 'Failed to set job ' .. job .. ' with grade ' .. grade .. ' for id (' .. self.source .. ') due to job not found')
		end
	end
	
	return self
end