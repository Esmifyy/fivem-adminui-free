local CurrentFramework = nil
local Bridge = nil

local function DebugPrint(message)
    if Config.Debug then
        print(('[adminui] %s'):format(message))
    end
end

CreateThread(function()
    Wait(500)

    if Config.Framework.AutoDetect then
        if AdminUI_QB.Init() then
            CurrentFramework = 'qb'
            Bridge = AdminUI_QB
            return
        end

        if AdminUI_ESX.Init() then
            CurrentFramework = 'esx'
            Bridge = AdminUI_ESX
            return
        end

        print('[adminui] FEHLER: Kein Framework erkannt. Prüfe qb-core oder es_extended.')
        return
    end

    if Config.Framework.Type == 'qb' then
        if AdminUI_QB.Init() then
            CurrentFramework = 'qb'
            Bridge = AdminUI_QB
        else
            print('[adminui] FEHLER: QBCore konnte nicht geladen werden.')
        end
    elseif Config.Framework.Type == 'esx' then
        if AdminUI_ESX.Init() then
            CurrentFramework = 'esx'
            Bridge = AdminUI_ESX
        else
            print('[adminui] FEHLER: ESX konnte nicht geladen werden.')
        end
    else
        print('[adminui] FEHLER: Config.Framework.Type ist ungültig.')
    end
end)

local function HasPermission(src)
    if not Bridge then return false end
    return Bridge.HasPermission(src)
end

local function Notify(src, message, notifyType)
    if Bridge then
        Bridge.Notify(src, message, notifyType)
    else
        TriggerClientEvent('chat:addMessage', src, {
            args = { 'AdminUI', message }
        })
    end
end

local function MergeLists(autoList, configList, key)
    local result = {}
    local exists = {}

    for _, entry in pairs(autoList or {}) do
        local value = entry[key]

        if value and not exists[value] then
            exists[value] = true
            result[#result + 1] = entry
        end
    end

    if Config.AutoLoad and Config.AutoLoad.MergeWithConfig then
        for _, entry in pairs(configList or {}) do
            local value = entry[key]

            if value and not exists[value] then
                exists[value] = true
                result[#result + 1] = entry
            end
        end
    end

    return result
end

local function GetOnlinePlayers()
    local players = {}

    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)
        local name = GetPlayerName(id) or ('Spieler ' .. id)

        players[#players + 1] = {
            id = id,
            name = name,
            label = '[' .. id .. '] ' .. name
        }
    end

    table.sort(players, function(a, b)
        return a.id < b.id
    end)

    return players
end

local function GetUILoadout()
    local items = Config.Items or {}
    local weapons = Config.Weapons or {}
    local vehicles = Config.Vehicles or {}
    local jobs = Config.Jobs or {}
    local gangs = Config.Gangs or {}

    if Bridge and Config.AutoLoad then
        if Config.AutoLoad.Items and Bridge.GetItems then
            local autoItems = Bridge.GetItems()

            if #autoItems > 0 then
                items = MergeLists(autoItems, Config.Items, 'name')
            end
        end

        if Config.AutoLoad.Weapons and Bridge.GetWeapons then
            local autoWeapons = Bridge.GetWeapons()

            if #autoWeapons > 0 then
                weapons = MergeLists(autoWeapons, Config.Weapons, 'name')
            end
        end

        if Config.AutoLoad.Vehicles and Bridge.GetVehicles then
            local autoVehicles = Bridge.GetVehicles()

            if #autoVehicles > 0 then
                vehicles = MergeLists(autoVehicles, Config.Vehicles, 'model')
            end
        end

        if Config.AutoLoad.Jobs and Bridge.GetJobs then
            local autoJobs = Bridge.GetJobs()

            if #autoJobs > 0 then
                jobs = MergeLists(autoJobs, Config.Jobs, 'name')
            end
        end

        if Config.AutoLoad.Gangs and Bridge.GetGangs then
            local autoGangs = Bridge.GetGangs()

            if #autoGangs > 0 then
                gangs = MergeLists(autoGangs, Config.Gangs, 'name')
            end
        end
    end

    return {
        players = GetOnlinePlayers(),
        items = items,
        weapons = weapons,
        vehicles = vehicles,
        jobs = jobs,
        gangs = gangs
    }
end

RegisterNetEvent('adminui:server:requestOpen', function()
    local src = source

    if not HasPermission(src) then
        Notify(src, Config.Notify.NoPermission, 'error')
        return
    end

    local loadout = GetUILoadout()

    DebugPrint(('Loaded Players: %s'):format(#loadout.players))
    DebugPrint(('Loaded Items: %s'):format(#loadout.items))
    DebugPrint(('Loaded Weapons: %s'):format(#loadout.weapons))
    DebugPrint(('Loaded Vehicles: %s'):format(#loadout.vehicles))
    DebugPrint(('Loaded Jobs: %s'):format(#loadout.jobs))
    DebugPrint(('Loaded Gangs: %s'):format(#loadout.gangs))

    TriggerClientEvent('adminui:client:openAllowed', src, {
        framework = CurrentFramework or 'unknown',
        players = loadout.players,
        items = loadout.items,
        weapons = loadout.weapons,
        vehicles = loadout.vehicles,
        jobs = loadout.jobs,
        gangs = loadout.gangs
    })
end)

RegisterNetEvent('adminui:server:giveItem', function(data)
    local src = source

    if not HasPermission(src) then
        Notify(src, Config.Notify.NoPermission, 'error')
        return
    end

    if not Bridge then
        Notify(src, 'Framework Bridge nicht geladen.', 'error')
        return
    end

    local targetId = tonumber(data.playerId)
    local itemName = tostring(data.itemName or '')
    local amount = tonumber(data.amount)

    if not targetId then
        Notify(src, Config.Notify.InvalidPlayer, 'error')
        return
    end

    local success, message = Bridge.AddItem(src, targetId, itemName, amount)
    Notify(src, message, success and 'success' or 'error')
end)

RegisterNetEvent('adminui:server:giveWeapon', function(data)
    local src = source

    if not HasPermission(src) then
        Notify(src, Config.Notify.NoPermission, 'error')
        return
    end

    if not Bridge then
        Notify(src, 'Framework Bridge nicht geladen.', 'error')
        return
    end

    local targetId = tonumber(data.playerId)
    local weaponName = tostring(data.weaponName or '')
    local ammo = tonumber(data.ammo)

    if not targetId then
        Notify(src, Config.Notify.InvalidPlayer, 'error')
        return
    end

    local success, message = Bridge.AddWeapon(src, targetId, weaponName, ammo)
    Notify(src, message, success and 'success' or 'error')
end)

RegisterNetEvent('adminui:server:setJob', function(data)
    local src = source

    if not HasPermission(src) then
        Notify(src, Config.Notify.NoPermission, 'error')
        return
    end

    if not Bridge then
        Notify(src, 'Framework Bridge nicht geladen.', 'error')
        return
    end

    local targetId = tonumber(data.playerId)
    local jobName = tostring(data.jobName or '')
    local grade = tonumber(data.grade)

    if not targetId then
        Notify(src, Config.Notify.InvalidPlayer, 'error')
        return
    end

    local success, message = Bridge.SetJob(src, targetId, jobName, grade)
    Notify(src, message, success and 'success' or 'error')
end)

RegisterNetEvent('adminui:server:setGang', function(data)
    local src = source

    if not HasPermission(src) then
        Notify(src, Config.Notify.NoPermission, 'error')
        return
    end

    if not Bridge then
        Notify(src, 'Framework Bridge nicht geladen.', 'error')
        return
    end

    local targetId = tonumber(data.playerId)
    local gangName = tostring(data.gangName or '')
    local grade = tonumber(data.grade)

    if not targetId then
        Notify(src, Config.Notify.InvalidPlayer, 'error')
        return
    end

    local success, message = Bridge.SetGang(src, targetId, gangName, grade)
    Notify(src, message, success and 'success' or 'error')
end)

RegisterNetEvent('adminui:server:notify', function(message, notifyType)
    local src = source

    if not HasPermission(src) then
        return
    end

    Notify(src, message, notifyType or 'primary')
end)

print('[adminui] Server.lua geladen')