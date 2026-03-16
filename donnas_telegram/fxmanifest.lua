fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'LaDonna'
description 'Advanced Realistic Telegraph System'
version '3.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/sounds/*.mp3',
    'html/images/*.png'
}

dependencies {
    'rsg-core',
    'ox_target',
    'oxmysql'
}