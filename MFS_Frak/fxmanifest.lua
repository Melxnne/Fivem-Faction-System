fx_version 'adamant'

game 'gta5'

description 'MFS Fraksystem for IloveCrimelife'
author 'Melonne'

version '1.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
    'config.lua',
	"server.lua"
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
    'config.lua',
	"client.lua"
}









