-- entities/ent_csg_camera/cl_init.lua
-- Client-side drawing logic for Combine Surveillance Camera

include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end
