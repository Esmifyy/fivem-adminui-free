# AdminUI Free

A clean and lightweight FiveM admin interface for QBCore and basic ESX setups.

AdminUI Free gives server staff a simple NUI panel for common admin actions without typing every command manually. It is designed to be easy to configure, beginner-friendly, and useful for test servers, development servers, and smaller roleplay communities.

## Features

- Modern NUI admin panel
- Open with command or keybind
- Give items to players
- Give weapons with ammo
- Spawn vehicles
- Set player jobs
- Set player gangs on QBCore
- Searchable player, item, weapon and vehicle fields
- Auto-loads QBCore shared data:
  - Items
  - Weapons
  - Vehicles
  - Jobs
  - Gangs

- Basic ESX support
- Configurable colors and UI text
- Drag and resize the panel
- Permission protected
- Optional debug output

## Supported Frameworks

### QBCore

QBCore is the main supported framework.

AdminUI Free can automatically read data from:

```lua
QBCore.Shared.Items
QBCore.Shared.Weapons
QBCore.Shared.Vehicles
QBCore.Shared.Jobs
QBCore.Shared.Gangs
```

### ESX

ESX support is basic.

Items, jobs, weapons and vehicles may depend on your ESX version and inventory system. Some ESX servers may need small bridge adjustments, especially when using custom inventories or job/gang systems.

## Installation

1. Download the resource.
2. Place the folder inside your server resources folder.

Example:

```txt
resources/[admin]/adminui
```

3. Add the resource to your `server.cfg`:

```cfg
ensure adminui
```

4. Restart your server.

## Permissions

By default, AdminUI Free is permission protected.

Make sure your admin group has the correct ACE permission:

```cfg
add_ace group.admin command allow
add_ace group.admin admin allow
```

Then add your identifier to the admin group:

```cfg
add_principal identifier.license:YOUR_LICENSE_HERE group.admin
```

Example:

```cfg
add_principal identifier.license:123456789abcdef group.admin
```

Do not use `AllowEveryone = true` on a public server.

## Command

Default command:

```txt
/adminui
```

You can change this in `config.lua`:

```lua
Config.OpenCommand = 'adminui'
```

## Keybind

Default keybind:

```lua
Config.OpenKey = 'F7'
```

Players can change keybinds in their FiveM keybind settings after the command has been registered.

## Configuration

Most options can be changed in `config.lua`.

### Framework

```lua
Config.Framework = {
    AutoDetect = true,
    Type = 'qb',

    QBCoreResource = 'qb-core',
    ESXResource = 'es_extended'
}
```

### Permissions

```lua
Config.Permissions = {
    QBCore = 'admin',

    ESX = {
        'admin',
        'superadmin',
        'owner'
    },

    AllowEveryone = false
}
```

### Debug

```lua
Config.Debug = false
```

Set this to `true` only while testing.

When enabled, the resource prints loaded data counts to the server console.

## Auto Loading

AdminUI Free can automatically load shared QBCore data:

```lua
Config.AutoLoad = {
    Items = true,
    Weapons = true,
    Vehicles = true,
    Jobs = true,
    Gangs = true,

    MergeWithConfig = true
}
```

If `MergeWithConfig` is enabled, your manual config entries will be added to the automatically loaded lists.

This is useful for custom vehicles, custom items, or resources that do not register their data inside QBCore shared files.

## Custom Vehicles

Some addon vehicles are not automatically detectable by FiveM.

If your vehicles are not inside `QBCore.Shared.Vehicles`, add them manually in `config.lua`:

```lua
Config.Vehicles = {
    { label = 'BMW M5', model = 'bmwm5' },
    { label = 'Audi RS6', model = 'rs6' }
}
```

## Important Notes

- Vehicles can only be auto-loaded if they exist in your framework vehicle list.
- ESX support can vary depending on your inventory and job setup.
- Gang support is mainly built for QBCore.
- Always keep `AllowEveryone = false` on live servers.
- Test the resource on a development server before using it on a public server.

## Known Limitations

- Addon vehicles outside shared vehicle lists must be added manually.
- Some custom inventories may require bridge changes.
- ESX gang systems are not standardized and may require custom support.
- Discord logging is not included in the free version.

## Credits

Created by Esma.

Free to use and modify for your own FiveM server.
