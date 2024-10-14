# rlo_gardener

This script offers a dynamic gardening job experience for the ESX Framework in FiveM. Players can take on various gardening tasks, such as weeding, tree trimming, and lawn mowing. The script includes an experience and level system, as well as a payout system, and customizable task locations.

## Features

- **Multiple Task Types:** Players can choose from tasks like weeding, tree trimming, and lawn mowing.
- **Experience and Reward System:** Players earn experience points and money for each completed task.
- **Customizable Vehicle and Zones:** Vehicle and zone positions can be adjusted in the configuration file.
- **Easy Configuration:** All settings can be customized in the `Config.lua` file.

## Video Demo

Watch the demo of the gardening job script [here](https://youtu.be/LI30zdBjQzI).

## Installation

1. Download this repository and place it in your FiveM server's resources folder.
2. Ensure that ESX and MySQL are installed on your server.
3. Import the `skills_gardening.sql` file into your database to create the required tables.
4. Add the script to your `server.cfg` file:

   ```plaintext
   ensure rlo_gardener
   ```

5. Adjust the configuration in the `config.lua` file to meet your server requirements.

## Configuration

The configuration is handled via the `config.lua` file. Here are some of the key options:

```lua
Config = {}
Config.Debug = false -- Enable/disable debug mode
Config.DrawDistance = 50 -- Zone render distance

Config.ExperiencePerPoint = 10 -- Experience points per completed task
Config.MoneyPerPoint = 50 -- Payout per garden point

Config.Vehicle = 'mower' -- Vehicle model name
Config.VehicleSpawn = vector4(-42.0131, -412.1090, 40.3985, 69.7127) -- Vehicle spawn location
```

### Zones

You can customize the locations of various zones under `Config.Zones`, such as job management and vehicle deletion:

```lua
Config.Zones = {
    ManageJob = {
        Position = vector3(-45.5763, -415.8636, 39.4970),
        Size  = {x = 1.0, y = 1.0, z = 1.0},
        Color = {r = 8, g = 163, b = 0},
        Type  = 41, Rotate = true
    },
    VehicleDelete = {
        Position = vector3(-41.7814, -411.9491, 38.6962),
        Size  = {x = 3.0, y = 3.0, z = 1.0},
        Color = {r = 8, g = 163, b = 0},
        Type  = 25, Rotate = false
    }
}
```

### Task Locations

You can also configure the locations for garden and tree maintenance tasks:

```lua
Config.JobPickups = {
    vector3(-154.0146, -440.3530, 33.7225),
    -- Additional coordinates here...
}

Config.JobTrees = {
    vector3(-154.0582, -463.6331, 32.9408),
    -- Additional coordinates here...
}
```

## SQL Setup

The `skills_gardening.sql` file creates the required database tables. Here’s an example of the table structure:

```sql
CREATE TABLE `skills_gardening` (
	`identifier` VARCHAR(46) NOT NULL COLLATE 'latin1_swedish_ci',
	`experience` INT(11) NOT NULL DEFAULT '0',
	PRIMARY KEY (`identifier`) USING BTREE
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;
```

## Dependencies

- **[ESX](https://github.com/esx-framework/esx_core):** ESX framework for FiveM.
- **[oxmysql](https://github.com/overextended/oxmysql):** Asynchronous library for database communication with MySQL.
- **[ox_lib](https://github.com/overextended/ox_lib):** Library for shared functions and utilities.
