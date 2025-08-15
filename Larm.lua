local activeCall = false
local blip = nil
local callLocation = nil

-- Lista på larm
local alarms = {
    {
        name = "Man med kniv på tunnelbanan",
        coords = vector3(279.8, -1204.5, 29.3)
    },
    {
        name = "Man med kniv på torget",
        coords = vector3(-1033.2, -2731.8, 20.2)
    },
    {
        name = "Man med vapen",
        coords = vector3(450.1, -981.2, 30.6)
    },
    {
        name = "Skottlossning",
        coords = vector3(-1100.0, -830.0, 14.0)
    },
    {
        name = "Stulen polisbil, kidnappning av polis",
        coords = vector3(1850.0, 3700.0, 33.0)
    }
}

-- Meny för larm
local menuPool = NativeUI.CreatePool()
local larmMenu = NativeUI.CreateMenu("FiveSWE Larm", "~b~Larmhantering")
menuPool:Add(larmMenu)

local endCallItem = NativeUI.CreateItem("Avsluta larm", "Tar bort markeringen för nuvarande larm")
larmMenu:AddItem(endCallItem)

larmMenu.OnItemSelect = function(sender, item, index)
    if item == endCallItem then
        if activeCall then
            RemoveBlip(blip)
            blip = nil
            activeCall = false
            TriggerEvent("chat:addMessage", {
                color = {255, 0, 0},
                args = {"FiveSWE", "Du har avslutat larmet."}
            })
        else
            TriggerEvent("chat:addMessage", {
                color = {255, 255, 0},
                args = {"FiveSWE", "Inget aktivt larm att avsluta."}
            })
        end
    end
end

-- Funktion: starta nytt larm
local function startRandomAlarm()
    if not exports["FiveSWE"]:IsInService() then return end
    if activeCall then return end -- redan ett aktivt larm

    local alarm = alarms[math.random(#alarms)]
    callLocation = alarm.coords

    -- Meddelande på skärmen
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("~r~Larm: ~w~" .. alarm.name .. "\nTryck ~g~Y~w~ för att ta emot")
    EndTextCommandThefeedPostTicker(false, false)

    Citizen.CreateThread(function()
        local timer = 10000 -- 10 sekunder att acceptera
        while timer > 0 do
            Citizen.Wait(0)
            if IsControlJustPressed(0, 246) then -- Y
                activeCall = true
                blip = AddBlipForCoord(callLocation.x, callLocation.y, callLocation.z)
                SetBlipSprite(blip, 161)
                SetBlipScale(blip, 1.2)
                SetBlipColour(blip, 3)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Larmplats")
                EndTextCommandSetBlipName(blip)

                TriggerEvent("chat:addMessage", {
                    color = {0, 255, 0},
                    args = {"FiveSWE", "Du har tagit emot larmet: " .. alarm.name}
                })
                return
            end
            timer = timer - 0
        end
    end)
end

-- Slumpa larm var 1-3 minuter
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(math.random(60000, 180000))
        startRandomAlarm()
    end
end)

-- Visa larmmeny med Z
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        menuPool:ProcessMenus()

        if IsControlJustPressed(1, 20) then -- Z
            if exports["FiveSWE"]:IsInService() then
                larmMenu:Visible(not larmMenu:Visible())
            end
        end
    end
end)
