fx_version 'cerulean'
game 'gta5'

description 'qbx_seatbelt'
repository 'https://github.com/Qbox-project/qbx_seatbelt'
version '1.0.0'

shared_script '@ox_lib/init.lua'

client_script 'client/main.lua'

server_script 'server/main.lua'

files {
    "locales/*.json"
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'