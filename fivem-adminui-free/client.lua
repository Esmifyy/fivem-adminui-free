local uiOpen = false

RegisterCommand(Config.OpenCommand, function()
    if uiOpen then
        return
    end

    TriggerServerEvent('adminui:server:requestOpen')
end)

RegisterKeyMapping(Config.OpenCommand, 'Admin UI öffnen', 'keyboard', Config.OpenKey)

RegisterNetEvent('adminui:client:openAllowed', function(data)
    OpenAdminUI(data)
end)

function OpenAdminUI(data)
    uiOpen = true

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'open',
        framework = data.framework or 'unknown',
        ui = Config.UI,
        theme = Config.Theme,
        labels = Config.Labels,
        vehicles = data.vehicles or Config.Vehicles,
        weapons = data.weapons or Config.Weapons,
        items = data.items or Config.Items,
        jobs = data.jobs or Config.Jobs,
        gangs = data.gangs or Config.Gangs,
        players = data.players or {}
    })
end

function CloseAdminUI()
    uiOpen = false

    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'close'
    })
end

RegisterNUICallback('close', function(data, cb)
    CloseAdminUI()
    cb('ok')
end)

RegisterNUICallback('giveItem', function(data, cb)
    TriggerServerEvent('adminui:server:giveItem', {
        playerId = data.playerId,
        itemName = data.itemName,
        amount = data.amount
    })

    cb('ok')
end)

RegisterNUICallback('giveWeapon', function(data, cb)
    TriggerServerEvent('adminui:server:giveWeapon', {
        playerId = data.playerId,
        weaponName = data.weaponName,
        ammo = data.ammo
    })

    cb('ok')
end)

RegisterNUICallback('setJob', function(data, cb)
    TriggerServerEvent('adminui:server:setJob', {
        playerId = data.playerId,
        jobName = data.jobName,
        grade = data.grade
    })

    cb('ok')
end)

RegisterNUICallback('setGang', function(data, cb)
    TriggerServerEvent('adminui:server:setGang', {
        playerId = data.playerId,
        gangName = data.gangName,
        grade = data.grade
    })

    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    local vehicleModel = tostring(data.vehicleName or '')

    if vehicleModel == '' then
        TriggerServerEvent('adminui:server:notify', Config.Notify.InvalidVehicle, 'error')
        cb('ok')
        return
    end

    SpawnAdminVehicle(vehicleModel)

    cb('ok')
end)

function SpawnAdminVehicle(model)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    local hash = GetHashKey(model)

    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        TriggerServerEvent('adminui:server:notify', Config.Notify.InvalidVehicle, 'error')
        return
    end

    RequestModel(hash)

    local timeout = 0

    while not HasModelLoaded(hash) do
        Wait(50)
        timeout = timeout + 1

        if timeout >= 100 then
            TriggerServerEvent('adminui:server:notify', 'Fahrzeugmodell konnte nicht geladen werden.', 'error')
            return
        end
    end

    local spawnCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, 0.0)
    local vehicle = CreateVehicle(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, false)

    SetVehicleOnGroundProperly(vehicle)
    SetPedIntoVehicle(ped, vehicle, -1)
    SetEntityAsMissionEntity(vehicle, true, true)

    SetModelAsNoLongerNeeded(hash)

    TriggerServerEvent('adminui:server:notify', Config.Notify.VehicleSpawned, 'success')
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    SetNuiFocus(false, false)
end)