fx_version 'cerulean'
game 'gta5'

author 'FiveSWE'
description 'Polis meny + larm system för FiveM'
version '1.0.0'

-- Alla klient-scripts (laddas i ordning)
client_scripts {
    'NativeUI.lua', -- Måste laddas först för menyer
    'client.lua',   -- Din huvudmeny och service-hantering
    'Larm.lua'      -- Larm-systemet
}

-- Inga serverscripts här om du inte behöver
-- server_scripts {
-- }

lua54 'yes'
