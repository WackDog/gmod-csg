-- entities/ent_csg_terminal/init.lua
-- Server-side logic for Combine Surveillance Terminal

AddCSLuaFile()
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combineinterface001.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if not CSG_Config.CombineTeams[activator:Team()] then
        activator:ChatPrint("[CSG] Access denied.")
        return
    end

    net.Start("CSG_OpenTerminalUI")
    net.Send(activator)
end
