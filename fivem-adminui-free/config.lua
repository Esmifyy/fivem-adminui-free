Config = {}

-- Framework
Config.Framework = {
    AutoDetect = true,

    -- Nur genutzt, wenn AutoDetect = false ist.
    -- Optionen: 'qb' oder 'esx'
    Type = 'qb',

    -- Resource Namen
    QBCoreResource = 'qb-core',
    ESXResource = 'es_extended'
}

Config.Debug = false

Config.AutoLoad = {
    -- QBCore:
    -- Items    = QBCore.Shared.Items
    -- Weapons  = QBCore.Shared.Items mit weapon_
    -- Vehicles = QBCore.Shared.Vehicles, falls vorhanden
    -- Jobs     = QBCore.Shared.Jobs
    --
    -- ESX:
    -- Items teilweise möglich, Jobs/Vehicles je nach Setup später über DB/Bridge.
    Items = true,
    Weapons = true,
    Vehicles = true,
    Jobs = true,
    Gangs = true,

    -- Wenn true, werden Config.Items/Weapons/Vehicles/Jobs zusätzlich an die automatisch geladenen Listen angehängt.
    -- Wenn false, nutzt er automatische Listen und Config nur als Fallback.
    MergeWithConfig = false
}

-- Command Taste
Config.OpenCommand = 'adminui'
Config.OpenKey = 'F7'

-- Permissions
Config.Permissions = {
    -- QBCore Permission, z.B. 'admin', 'god'
    QBCore = 'admin',

    -- ESX Gruppen, die Zugriff haben
    ESX = {
        'admin',
        'superadmin',
        'owner'
    },

    -- Für Testing kannst du das kurz auf true setzen.
    -- Später unbedingt false!
    AllowEveryone = false
}

-- UI Texte
Config.UI = {
    Title = 'Admin UI',
    Subtitle = 'Admin Tool',
    FooterText = 'ENTF zum Schließen',

    Sections = {
        Items = {
            Enabled = true,
            Title = 'Items geben',
            Description = 'Gib einem Spieler ein Item mit Anzahl.'
        },

        Weapons = {
            Enabled = true,
            Title = 'Waffen geben',
            Description = 'Gib einem Spieler eine Waffe mit Munition.'
        },

        Vehicles = {
            Enabled = true,
            Title = 'Auto spawnen',
            Description = 'Spawne ein Fahrzeug direkt bei dir.'
        },

        Jobs = {
            Enabled = true,
            Title = 'Job setzen',
            Description = 'Setze einem Spieler einen Job und Rang.'
        },

        Gangs = {
            Enabled = true,
            Title = 'Gang setzen',
            Description = 'Setze einem Spieler eine Gang und Rang.'
        }
    }
}

-- Design
Config.Theme = {
    PrimaryColor = '#8b5cf6',
    SecondaryColor = '#06b6d4',

    BackgroundDark = 'rgba(8, 10, 18, 0.97)',
    BackgroundWarm = 'rgba(18, 16, 30, 0.97)',

    CardBackground = 'rgba(255, 255, 255, 0.065)',
    CardBorder = 'rgba(255, 255, 255, 0.105)',

    TextColor = '#ffffff',
    MutedTextColor = 'rgba(255, 255, 255, 0.62)',

    OverlayBackground = 'rgba(0, 0, 0, 0.28)',

    BorderRadius = '26px',
    CardRadius = '20px'
}

-- Placeholder
Config.Labels = {
    GiveItemButton = 'Item geben',
    GiveWeaponButton = 'Waffe geben',
    SpawnVehicleButton = 'Auto spawnen',
    SetJobButton = 'Job setzen',
    SetGangButton = 'Gang setzen',
    TestButton = 'NUI Test',

    PlayerIdPlaceholder = 'Spieler-ID oder Name',

    ItemPlaceholder = 'Itemname z.B. bread',
    ItemAmountPlaceholder = 'Anzahl',

    WeaponPlaceholder = 'Waffe z.B. weapon_pistol',
    AmmoPlaceholder = 'Munition',

    VehiclePlaceholder = 'Auto z.B. sultan',

    JobPlaceholder = 'Job z.B. police',
    JobGradePlaceholder = 'Rang z.B. 0',

    GangPlaceholder = 'Gang z.B. lostmc',
    GangGradePlaceholder = 'Rang z.B. 0'
}

Config.Vehicles = {
    { label = 'Sultan', model = 'sultan' },
    { label = 'Blista', model = 'blista' },
    { label = 'Adder', model = 'adder' },
    { label = 'Futo', model = 'futo' },
    { label = 'Comet', model = 'comet2' },
    { label = 'Police', model = 'police' }
}

Config.Weapons = {
    { label = 'Pistole', name = 'weapon_pistol' },
    { label = 'Combat Pistol', name = 'weapon_combatpistol' },
    { label = 'Messer', name = 'weapon_knife' },
    { label = 'Taschenlampe', name = 'weapon_flashlight' },
    { label = 'Schlagstock', name = 'weapon_nightstick' }
}

Config.Items = {
    { label = 'Brot', name = 'bread' },
    { label = 'Wasser', name = 'water' },
    { label = 'Handy', name = 'phone' },
    { label = 'Repairkit', name = 'repairkit' },
    { label = 'Bandage', name = 'bandage' }
}

Config.Jobs = {
    {
        label = 'Unemployed',
        name = 'unemployed',
        grades = {
            { label = 'Arbeitslos', grade = 0 }
        }
    },

    {
        label = 'Police',
        name = 'lspd',
        grades = {
            { label = 'Recruit', grade = 0 },
            { label = 'Officer', grade = 1 },
            { label = 'Sergeant', grade = 2 },
            { label = 'Lieutenant', grade = 3 },
            { label = 'Boss', grade = 4 }
        }
    },

    {
        label = 'Ambulance',
        name = 'lsmd',
        grades = {
            { label = 'Recruit', grade = 0 },
            { label = 'Paramedic', grade = 1 },
            { label = 'Doctor', grade = 2 },
            { label = 'Boss', grade = 3 }
        }
    },

    {
        label = 'Mechanic',
        name = 'mechanic',
        grades = {
            { label = 'Azubi', grade = 0 },
            { label = 'Mechaniker', grade = 1 },
            { label = 'Meister', grade = 2 },
            { label = 'Boss', grade = 3 }
        }
    }
}

Config.Gangs = {
    {
        label = 'Keine Gang',
        name = 'none',
        grades = {
            { label = 'Unaffiliated', grade = 0 }
        }
    },

    {
        label = 'The Lost MC',
        name = 'lostmc',
        grades = {
            { label = 'Recruit', grade = 0 },
            { label = 'Enforcer', grade = 1 },
            { label = 'Shot Caller', grade = 2 },
            { label = 'Boss', grade = 3 }
        }
    }
}


-- Notify Texte
Config.Notify = {
    NoPermission = 'Du hast keine Berechtigung.',
    UiTest = 'Admin UI funktioniert!',

    InvalidPlayer = 'Ungültige Spieler-ID.',
    InvalidItem = 'Ungültiger Itemname.',
    InvalidWeapon = 'Ungültiger Waffenname.',
    InvalidVehicle = 'Ungültiges Fahrzeug.',
    InvalidJob = 'Ungültiger Job.',
    InvalidJobGrade = 'Ungültiger Job-Rang.',
    InvalidGang = 'Ungültige Gang.',
    InvalidGangGrade = 'Ungültiger Gang-Rang.',
    InvalidAmount = 'Ungültige Anzahl.',
    InvalidAmmo = 'Ungültige Munitionsanzahl.',

    ItemGiven = 'Item wurde gegeben.',
    WeaponGiven = 'Waffe wurde gegeben.',
    VehicleSpawned = 'Fahrzeug wurde gespawnt.',
    JobSet = 'Job wurde gesetzt.',
    GangSet = 'Gang wurde gesetzt.'
}