-- entities/ent_csg_camera/init.lua
-- Server-side logic for Combine Surveillance Camera

AddCSLuaFile()
include("shared.lua")

function ENT:Initialize()
    -- Basic model & physics setup
    self:SetModel("models/props_c17/camera.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetUseType(SIMPLE_USE)

    -- Register this camera after a short delay
    timer.Simple(1, function()
        if not IsValid(self) then return end

        local id = self:EntIndex()
        CSG_CameraRegistry = CSG_CameraRegistry or {}

        CSG_CameraRegistry[id] = {
            ent      = self,
            entIndex = id,
            label    = "Camera #" .. id,
            pos      = self:GetPos(),
            ang      = self:GetAngles()
        }

        if SaveCameras then SaveCameras() end
    end)

    -- Motion detection & auto-ping every second
    timer.Create("CSG_MotionDetect_" .. self:EntIndex(), 1, 0, function()
        if not IsValid(self) then
            timer.Remove("CSG_MotionDetect_" .. self:EntIndex())
            return
        end

        local origin  = self:GetPos()
        local forward = self:GetForward()

        for _, ply in ipairs(player.GetAll()) do
            -- Only detect non-Combine players who are alive
            if ply:Alive() and not CSG_Config.CombineTeams[ply:Team()] then
                local toPlayer = ply:GetPos() - origin
                local dist     = toPlayer:Length()

                if dist < 800 then
                    toPlayer:Normalize()
                    if forward:Dot(toPlayer) > 0.7 then
                        local id    = self:EntIndex()
                        local entry = CSG_CameraRegistry[id]
                        local label = entry and entry.label or ("Camera #" .. id)

                        -- Server-side log
                        file.CreateDir(CSG_Config.DataPath .. "logs")
                        file.Append(
                            CSG_Config.DataPath .. "logs/camera_pings.txt",
                            string.format(
                                "[%s] AUTO-PINGED Camera #%d (\"%s\") due to motion by %s\n",
                                os.date("%Y-%m-%d %H:%M:%S"),
                                id,
                                label,
                                ply:Nick()
                            )
                        )

                        -- Broadcast ping FX to all clients
                        net.Start("CSG_PingCamera")
                        net.WriteUInt(id, 16)
                        net.WriteString(label)
                        net.Broadcast()
                    end
                end
            end
        end
    end)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if not CSG_Config.CombineTeams[activator:Team()] then
        activator:ChatPrint("[CSG] Access denied.")
        return
    end
    activator:ChatPrint("[CSG] This is a surveillance camera. Use a terminal to view feeds.")
end

function ENT:OnRemove()
    -- Cleanup registry entry
    CSG_CameraRegistry = CSG_CameraRegistry or {}
    local id = self:EntIndex()
    if CSG_CameraRegistry[id] then
        CSG_CameraRegistry[id] = nil
        if SaveCameras then SaveCameras() end
    end

    -- Remove motion detection timer
    timer.Remove("CSG_MotionDetect_" .. id)
end

