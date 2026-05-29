fx_version 'cerulean'
game 'gta5'

author 'Esmify'
description 'Admin UI QBCore & ESX Admin Tool'
version '1.0.0'

lua54 'yes'

ui_page 'html/index.html'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'bridge/qb.lua',
    'bridge/esx.lua',
    'server.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}