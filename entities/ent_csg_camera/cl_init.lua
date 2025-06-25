-- entities/ent_csg_camera/cl_init.lua
-- Client-side drawing logic for Combine Surveillance Camera

include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    -- Optional: add visual indicator or glow in future
    -- Example: cam.Start3D2D for direction or camera label
end
