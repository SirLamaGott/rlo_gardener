fx_version 'cerulean'
games {'gta5'}
lua54 'yes'

author 'SirLamaGott'
description 'Gardener Job'
version '1.1'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua'
}

client_script 'client/cl_main.lua'

dependencies {
    'es_extended',
    'oxmysql',
    'ox_lib'
}