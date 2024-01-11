fx_version 'cerulean'
game 'gta5'

description 'qbx_seatbelt'
repository 'https://github.com/Qbox-project/qbx_seatbelt'
version '1.0.0'

shared_script '@ox_lib/init.lua'

client_script 'client/main.lua'

server_script 'server/main.lua'

files {
    'locales/*.json',
    'data/seatbelt_sounds.dat54.rel',
    'audiodirectory/seatbelt_sounds.awc'
}

data_file 'AUDIO_WAVEPACK' 'audiodirectory'
data_file 'AUDIO_SOUNDDATA' 'data/seatbelt_sounds.dat'

lua54 'yes'
use_experimental_fxv2_oal 'yes'