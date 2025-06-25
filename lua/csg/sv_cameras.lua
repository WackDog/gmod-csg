-- sv_cameras.lua
-- Server-side camera registry + feed logic

util.AddNetworkString("CSG_OpenTerminalUI")
util.AddNetworkString("CSG_RequestCameraList")
util.AddNetworkString("CSG_SendCameraList")
util.AddNetworkString("CSG_RequestRenameCamera")
util.AddNetworkString("CSG_ConfirmRenameCamera")
util.AddNetworkString("CSG_LogCameraViewed")
util.AddNetworkString("CSG_PingCamera")

CSG_CameraRegistry = {}

-- Load saved cameras from file
local function LoadCameras()
    if not file.Exists(CSG_Config.DataPath, "DATA") then
        file.CreateDir(CSG_Config.DataPath)
    end

    if file.Exists(CSG_Config.DataPath .. "cameras.json", "DATA") then
        local raw = file.Read(CSG_Config.DataPath .. "cameras.json", "DATA")
        CSG_CameraRegistry = util.JSONToTable(raw) or {}
    else
        CSG_CameraRegistry = {}
    end
end

-- Save current camera registry to file
local function SaveCameras()
    file.Write(CSG_Config.DataPath .. "cameras.json", util.TableToJSON(CSG_CameraRegistry, true))
end

-- Provide camera list to clients
net.Receive("CSG_RequestCameraList", function(_, ply)
    if not CSG_Config.CombineTeams[ply:Team()] then return end

    net.Start("CSG_SendCameraList")
    net.WriteTable(CSG_CameraRegistry)
    net.Send(ply)
end)

-- Allow camera renames
net.Receive("CSG_RequestRenameCamera", function(_, ply)
    local camID = net.ReadUInt(16)
    local newLabel = net.ReadString()

    if not CSG_Config.CombineTeams[ply:Team()] then return end
    if not CSG_CameraRegistry[camID] then return end

    CSG_CameraRegistry[camID].label = newLabel

    SaveCameras()

    -- Optional confirmation
    net.Start("CSG_ConfirmRenameCamera")
    net.WriteUInt(camID, 16)
    net.WriteString(newLabel)
    net.Send(ply)
end)

-- Log cameras being viewed
net.Receive("CSG_LogCameraViewed", function(_, ply)
    local id = net.ReadUInt(16)
    local label = net.ReadString()
    local logLine = string.format("[%s] %s viewed Camera #%d (\"%s\")\n",
        os.date("%Y-%m-%d %H:%M:%S"),
        ply:Nick(),
        id,
        label
    )

    file.CreateDir("csg/logs")
    file.Append("csg/logs/camera_pings.txt", logLine)
end)

-- Ping current camera
net.Receive("CSG_PingCamera", function(_, ply)
    local id = net.ReadUInt(16)
    local label = net.ReadString()

    local logLine = string.format("[%s] %s 🔔 PINGED Camera #%d (\"%s\")\n",
        os.date("%Y-%m-%d %H:%M:%S"),
        ply:Nick(),
        id,
        label
    )

    file.CreateDir("csg/logs")
    file.Append("csg/logs/camera_pings.txt", logLine)

    net.Start("CSG_PingFX")
    net.WriteUInt(id, 16)
    net.WriteString(label)
    net.Broadcast()
end)

-- Initial load
hook.Add("Initialize", "CSG_LoadCameraData", LoadCameras)