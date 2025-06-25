-- entities/ent_csg_terminal/cl_init.lua
-- Client-side drawing logic for Surveillance Terminal

include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    -- Optional: Draw a hologram or label here using 3D2D
end
