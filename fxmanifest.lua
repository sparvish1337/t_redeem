fx_version 'cerulean'
game 'gta5'

description 'Redeem System for QBox'

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
