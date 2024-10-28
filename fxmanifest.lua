fx_version 'cerulean'
game 'gta5'
lua54 "yes"

description 'Redeem System for QBox'

shared_scripts {
    '@ox_lib/init.lua',
}

server_scripts {
    'server.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client.lua'
}

dependencies {
    'qbx_core',
    'ox_inventory'
}
