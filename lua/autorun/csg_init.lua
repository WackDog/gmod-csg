-- csg_init.lua
-- Loads CSG server and client modules

if SERVER then
    include("csg/sh_config.lua")
    include("csg/sv_cameras.lua")
    AddCSLuaFile("csg/sh_config.lua")
    AddCSLuaFile("csg/cl_viewer.lua")
else
    include("csg/sh_config.lua")
    include("csg/cl_viewer.lua")
end
