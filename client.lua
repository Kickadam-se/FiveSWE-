local inService = false
local menuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu("FiveSWE", "~b~Polis Meny")
menuPool:Add(mainMenu)

-- Skapa undermeny för bilar
local carMenu = NativeUI.CreateMenu("Polisbilar", "~b~Välj fordon")
menuPool:Add(carMenu)

-- Variabler för extra knappar
local weaponsItem, carsItem, endServiceItem = nil, nil, nil

-- Export för larm-scriptet
exports("IsInService", function()
    return inService
end)

-- Ge polisvapen
local function givePoliceLoadout()
    local playerPed = PlayerPedId()
    RemoveAllPedWeapons(playerPed, true)
    GiveWeaponToPed(playerPed, `WEAPON_COMBATPISTOL`, 200, false, true)
    GiveWeaponToPed(playerPed, `WEAPON_STUNGUN`, 1, false, true)
    GiveWeaponToPed(playerPed, `WEAPON_CARBINERIFLE`, 250, false, true)
    GiveWeaponToPed(playerPed, `WEAPON_NIGHTSTICK`, 1, false, true)
    GiveWeaponToPed(playerPed, `WEAPON_FLASHLIGHT`, 1, false, true)
    TriggerEvent("chat:addMessage", {
        color = {0, 255, 0},
        args = {"FiveSWE", "Du har fått polisens utrustning."}
    })
end

-- Spawna polisbil
local function spawnPoliceCar(model)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end

    local vehicle = CreateVehicle(model, pos.x, pos.y, pos.z, GetEntityHeading(playerPed), true, false)
    SetVehicleNumberPlateText(vehicle, "FIVESWE")
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    SetEntityAsNoLongerNeeded(vehicle)
    SetModelAsNoLongerNeeded(model)
end

-- Starta tjänst
local function startService()
    inService = true
    SetMaxWantedLevel(0)
    ClearPlayerWantedLevel(PlayerId())

    TriggerEvent("chat:addMessage", {
        color = {0, 255, 0},
        args = {"FiveSWE", "Du har gått i tjänst"}
    })

    -- Lägg till extra knappar
    weaponsItem = NativeUI.CreateItem("Vapen", "Få polisens vapen")
    mainMenu:AddItem(weaponsItem)

    carsItem = NativeUI.CreateItem("Bilar", "Välj en polisbil")
    mainMenu:AddItem(carsItem)

    endServiceItem = NativeUI.CreateItem("Gå ur tjänst", "Avsluta ditt pass som polis")
    mainMenu:AddItem(endServiceItem)
end

-- Avsluta tjänst
local function endService()
    inService = false
    SetMaxWantedLevel(5) -- återställer normal polisjakt
    TriggerEvent("chat:addMessage", {
        color = {255, 0, 0},
        args = {"FiveSWE", "Du har gått ur tjänst"}
    })

    -- Ta bort extra knappar
    mainMenu:Clear()
    AddMainMenu(mainMenu)
end

-- Huvudmeny
function AddMainMenu(menu)
    local serviceItem = NativeUI.CreateItem("Gå i tjänst", "Starta ditt pass som polis")
    menu:AddItem(serviceItem)

    menu.OnItemSelect = function(sender, item, index)
        if item == serviceItem then
            if not inService then
                startService()
            else
                TriggerEvent("chat:addMessage", {
                    color = {255, 255, 0},
                    args = {"FiveSWE", "Du är redan i tjänst"}
                })
            end
        elseif item == weaponsItem then
            givePoliceLoadout()
        elseif item == carsItem then
            carMenu:Visible(true)
        elseif item == endServiceItem then
            endService()
        end
    end
end

-- Bilmeny
function AddCarMenu(menu)
    local car1 = NativeUI.CreateItem("Polisbil 1", "Standard polisbil")
    local car2 = NativeUI.CreateItem("Polisbil 2", "Annat polisfordon")
    menu:AddItem(car1)
    menu:AddItem(car2)

    menu.OnItemSelect = function(sender, item, index)
        if item == car1 then
            spawnPoliceCar(`police`)
        elseif item == car2 then
            spawnPoliceCar(`police2`)
        end
    end
end

AddMainMenu(mainMenu)
AddCarMenu(carMenu)

-- Visa meny på F10
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        menuPool:ProcessMenus()
        if IsControlJustPressed(1, 57) then -- F10
            mainMenu:Visible(not mainMenu:Visible())
        end
    end
end)
