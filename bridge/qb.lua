AdminUI_QB = {}

local QBCore = nil

function AdminUI_QB.Init()
    local resourceName = Config.Framework.QBCoreResource or 'qb-core'

    if GetResourceState(resourceName) ~= 'started' then
        return false
    end

    QBCore = exports[resourceName]:GetCoreObject()

    if QBCore then
        print('[adminui] QBCore Bridge geladen')
        return true
    end

    return false
end

function AdminUI_QB.HasPermission(src)
    if Config.Permissions.AllowEveryone then
        return true
    end

    if not QBCore then
        return false
    end

    local permission = Config.Permissions.QBCore or 'admin'
    return QBCore.Functions.HasPermission(src, permission)
end

function AdminUI_QB.Notify(src, message, notifyType)
    TriggerClientEvent('QBCore:Notify', src, message, notifyType or 'primary')
end

function AdminUI_QB.GetPlayer(src)
    if not QBCore then return nil end
    return QBCore.Functions.GetPlayer(src)
end

function AdminUI_QB.AddItem(src, targetId, itemName, amount)
    local Player = AdminUI_QB.GetPlayer(targetId)

    if not Player then return false, Config.Notify.InvalidPlayer end

    amount = tonumber(amount)

    if not itemName or itemName == '' then return false, Config.Notify.InvalidItem end
    if not amount or amount <= 0 then return false, Config.Notify.InvalidAmount end

    local success = Player.Functions.AddItem(itemName, amount)

    if success == false then
        return false, 'Item konnte nicht gegeben werden.'
    end

    if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[itemName] then
        TriggerClientEvent('inventory:client:ItemBox', targetId, QBCore.Shared.Items[itemName], 'add', amount)
    end

    return true, Config.Notify.ItemGiven
end

function AdminUI_QB.AddWeapon(src, targetId, weaponName, ammo)
    local Player = AdminUI_QB.GetPlayer(targetId)

    if not Player then return false, Config.Notify.InvalidPlayer end
    if not weaponName or weaponName == '' then return false, Config.Notify.InvalidWeapon end

    ammo = tonumber(ammo) or 0

    if ammo < 0 then return false, Config.Notify.InvalidAmmo end

    local weaponItem = string.lower(weaponName)

    local success = Player.Functions.AddItem(weaponItem, 1, false, {
        ammo = ammo
    })

    if success == false then
        return false, 'Waffe konnte nicht gegeben werden.'
    end

    if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[weaponItem] then
        TriggerClientEvent('inventory:client:ItemBox', targetId, QBCore.Shared.Items[weaponItem], 'add', 1)
    end

    return true, Config.Notify.WeaponGiven
end

function AdminUI_QB.SetJob(src, targetId, jobName, grade)
    local Player = AdminUI_QB.GetPlayer(targetId)

    if not Player then return false, Config.Notify.InvalidPlayer end
    if not jobName or jobName == '' then return false, Config.Notify.InvalidJob end

    grade = tonumber(grade)

    if grade == nil or grade < 0 then return false, Config.Notify.InvalidJobGrade end

    if QBCore.Shared and QBCore.Shared.Jobs then
        local job = QBCore.Shared.Jobs[jobName]

        if not job then return false, Config.Notify.InvalidJob end

        if job.grades and not job.grades[tostring(grade)] and not job.grades[grade] then
            return false, Config.Notify.InvalidJobGrade
        end
    end

    Player.Functions.SetJob(jobName, grade)

    return true, Config.Notify.JobSet
end

function AdminUI_QB.SetGang(src, targetId, gangName, grade)
    local Player = AdminUI_QB.GetPlayer(targetId)

    if not Player then return false, Config.Notify.InvalidPlayer end
    if not gangName or gangName == '' then return false, Config.Notify.InvalidGang end

    grade = tonumber(grade)

    if grade == nil or grade < 0 then return false, Config.Notify.InvalidGangGrade end

    if QBCore.Shared and QBCore.Shared.Gangs then
        local gang = QBCore.Shared.Gangs[gangName]

        if not gang then return false, Config.Notify.InvalidGang end

        if gang.grades and not gang.grades[tostring(grade)] and not gang.grades[grade] then
            return false, Config.Notify.InvalidGangGrade
        end
    end

    Player.Functions.SetGang(gangName, grade)

    return true, Config.Notify.GangSet
end

function AdminUI_QB.GetItems()
    local items = {}

    if not QBCore or not QBCore.Shared or not QBCore.Shared.Items then
        return items
    end

    for itemName, itemData in pairs(QBCore.Shared.Items) do
        items[#items + 1] = {
            label = itemData.label or itemName,
            name = itemName
        }
    end

    table.sort(items, function(a, b)
        return tostring(a.label):lower() < tostring(b.label):lower()
    end)

    return items
end

function AdminUI_QB.GetWeapons()
    local weapons = {}
    local exists = {}

    if QBCore and QBCore.Shared and QBCore.Shared.Weapons then
        for weaponName, weaponData in pairs(QBCore.Shared.Weapons) do
            local name = string.lower(weaponName)

            if not exists[name] then
                exists[name] = true

                weapons[#weapons + 1] = {
                    label = weaponData.label or weaponData.name or name,
                    name = name
                }
            end
        end
    end

    if QBCore and QBCore.Shared and QBCore.Shared.Items then
        for itemName, itemData in pairs(QBCore.Shared.Items) do
            local lowerName = string.lower(itemName)

            if string.find(lowerName, 'weapon_') and not exists[lowerName] then
                exists[lowerName] = true

                weapons[#weapons + 1] = {
                    label = itemData.label or itemName,
                    name = itemName
                }
            end
        end
    end

    table.sort(weapons, function(a, b)
        return tostring(a.label):lower() < tostring(b.label):lower()
    end)

    return weapons
end

function AdminUI_QB.GetVehicles()
    local vehicles = {}

    if not QBCore or not QBCore.Shared or not QBCore.Shared.Vehicles then
        return vehicles
    end

    for model, vehicleData in pairs(QBCore.Shared.Vehicles) do
        vehicles[#vehicles + 1] = {
            label = vehicleData.name or vehicleData.label or vehicleData.brand and (vehicleData.brand .. ' ' .. model) or model,
            model = model
        }
    end

    table.sort(vehicles, function(a, b)
        return tostring(a.label):lower() < tostring(b.label):lower()
    end)

    return vehicles
end

function AdminUI_QB.GetJobs()
    local jobs = {}

    if not QBCore or not QBCore.Shared or not QBCore.Shared.Jobs then
        return jobs
    end

    for jobName, jobData in pairs(QBCore.Shared.Jobs) do
        local grades = {}

        if jobData.grades then
            for gradeKey, gradeData in pairs(jobData.grades) do
                grades[#grades + 1] = {
                    label = gradeData.name or gradeData.label or tostring(gradeKey),
                    grade = tonumber(gradeKey) or 0
                }
            end
        end

        table.sort(grades, function(a, b)
            return tonumber(a.grade) < tonumber(b.grade)
        end)

        jobs[#jobs + 1] = {
            label = jobData.label or jobName,
            name = jobName,
            grades = grades
        }
    end

    table.sort(jobs, function(a, b)
        return tostring(a.label):lower() < tostring(b.label):lower()
    end)

    return jobs
end

function AdminUI_QB.GetGangs()
    local gangs = {}

    if not QBCore or not QBCore.Shared or not QBCore.Shared.Gangs then
        return gangs
    end

    for gangName, gangData in pairs(QBCore.Shared.Gangs) do
        local grades = {}

        if gangData.grades then
            for gradeKey, gradeData in pairs(gangData.grades) do
                grades[#grades + 1] = {
                    label = gradeData.name or gradeData.label or tostring(gradeKey),
                    grade = tonumber(gradeKey) or 0
                }
            end
        end

        table.sort(grades, function(a, b)
            return tonumber(a.grade) < tonumber(b.grade)
        end)

        gangs[#gangs + 1] = {
            label = gangData.label or gangName,
            name = gangName,
            grades = grades
        }
    end

    table.sort(gangs, function(a, b)
        return tostring(a.label):lower() < tostring(b.label):lower()
    end)

    return gangs
end