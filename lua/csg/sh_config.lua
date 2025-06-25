-- sh_config.lua
-- Shared configuration for Combine Surveillance Grid

CSG_Config = {}

-- Data storage path
CSG_Config.DataPath = "csg/"

-- Teams that can access terminals and cameras
CSG_Config.CombineTeams = {
    ["MPF"] = true,
    ["OTA"] = true,
    ["Combine"] = true
}

-- Max cameras per player (optional enforcement)
CSG_Config.MaxCamerasPerUnit = 5
