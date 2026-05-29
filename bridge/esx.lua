AdminUI_ESX = {}

local ESX = nil

function AdminUI_ESX.Init()
    local resourceName = Config.Framework.ESXResource or 'es_extended'

    if GetResourceState(resourceName) ~= 'started' then
        return false
    end

    ESX = exports[resourceName]:getSharedObject()

    if ESX then
        print('[adminui] ESX Bridge geladen')
        return true
    end

    return false
end

function AdminUI_ESX.HasPermission(src)
    if Config.Permissions.AllowEveryone then
        return true
    end

    if not ESX then
        return false
    end

    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return false
    end

    local group = xPlayer.getGroup()

    for _, allowedGroup in pairs(Config.Permissions.ESX or {}) do
        if group == allowedGroup then
            return true
        end
    end

    return false
end

function AdminUI_ESX.Notify(src, message, notifyType)
    TriggerClientEvent('esx:showNotification', src, message)
end

function AdminUI_ESX.GetPlayer(src)
    if not ESX then return nil end
    return ESX.GetPlayerFromId(src)
end

function AdminUI_ESX.AddItem(src, targetId, itemName, amount)
    local xPlayer = AdminUI_ESX.GetPlayer(targetId)

    if not xPlayer then return false, Config.Notify.InvalidPlayer end

    amount = tonumber(amount)

    if not itemName or itemName == '' then return false, Config.Notify.InvalidItem end
    if not amount or amount <= 0 then return false, Config.Notify.InvalidAmount end

    xPlayer.addInventoryItem(itemName, amount)

    return true, Config.Notify.ItemGiven
end

function AdminUI_ESX.AddWeapon(src, targetId, weaponName, ammo)
    local xPlayer = AdminUI_ESX.GetPlayer(targetId)

    if not xPlayer then return false, Config.Notify.InvalidPlayer end
    if not weaponName or weaponName == '' then return false, Config.Notify.InvalidWeapon end

    ammo = tonumber(ammo) or 0

    if ammo < 0 then return false, Config.Notify.InvalidAmmo end

    xPlayer.addWeapon(string.upper(weaponName), ammo)

    return true, Config.Notify.WeaponGiven
end

function AdminUI_ESX.SetJob(src, targetId, jobName, grade)
    local xPlayer = AdminUI_ESX.GetPlayer(targetId)

    if not xPlayer then return false, Config.Notify.InvalidPlayer end
    if not jobName or jobName == '' then return false, Config.Notify.InvalidJob end

    grade = tonumber(grade)

    if grade == nil or grade < 0 then return false, Config.Notify.InvalidJobGrade end

    xPlayer.setJob(jobName, grade)

    return true, Config.Notify.JobSet
end

function AdminUI_ESX.SetGang(src, targetId, gangName, grade)
    return false, 'Gang setzen ist bei ESX standardmäßig nicht unterstützt.'
end

function AdminUI_ESX.GetItems()
    local items = {}

    if ESX and ESX.Items then
        for itemName, itemData in pairs(ESX.Items) do
            items[#items + 1] = {
                label = itemData.label or itemName,
                name = itemName
            }
        end
    end

    table.sort(items, function(a, b)
        return tostring(a.label):lower() < tostring(b.label):lower()
    end)

    return items
end

function AdminUI_ESX.GetWeapons()
    return Config.Weapons or {}
end

function AdminUI_ESX.GetVehicles()
    return Config.Vehicles or {}
end

function AdminUI_ESX.GetJobs()
    return Config.Jobs or {}
end

function AdminUI_ESX.GetGangs()
    return Config.Gangs or {}
end