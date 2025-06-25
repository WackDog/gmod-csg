-- /init.lua
-- Server-side logic for Combine Surveillance Camera

AddCSLuaFile()
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/camera.mdl") -- Default Combine-style camera
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    self:SetUseType(SIMPLE_USE)

    -- Register this camera after a short delay to ensure it's valid
    timer.Simple(1, function()
        if not IsValid(self) then return end

        local id = self:EntIndex()
        CSG_CameraRegistry = CSG_CameraRegistry or {}

        CSG_CameraRegistry[id] = {
            ent = self,
            entIndex = id,
            label = "Camera #" .. id,
            pos = self:GetPos(),
            ang = self:GetAngles()
        }

        -- Save metadata (excluding entity itself)
        if SaveCameras then SaveCameras() end
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
    for id, data in pairs(CSG_CameraRegistry or {}) do
        if data.entIndex == self:EntIndex() then
            CSG_CameraRegistry[id] = nil
            break
        end
    end

    SaveCameras()
end
