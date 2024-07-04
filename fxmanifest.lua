fx_version 'cerulean'

game 'gta5'

author 'Selander1998'

dependencies {
	'mapmanager',
	'spawnmanager',
	'sessionmanager',
	'fivem'
}

client_scripts {
	'shared/main.lua',
	'shared/jobs.lua',
	'client/main.lua',
	'client/events.lua',
	'client/modules/*.lua',
	'client/modules/utils/*.lua'
}

server_scripts {
	'shared/main.lua',
	'shared/jobs.lua',
	'server/main.lua',
	'server/events.lua',
	'server/modules/*.lua',
	'server/modules/utils/*.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/css/app.css',
	'html/js/mustache.min.js',
	'html/js/app.js'
}