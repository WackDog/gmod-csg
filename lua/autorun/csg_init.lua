-- csg_init.lua
-- Loads CSG server and client modules

if SERVER then
   -- Send entity files to clients
   AddCSLuaFile("entities/ent_csg_camera/shared.lua")
   AddCSLuaFile("entities/ent_csg_camera/cl_init.lua")
   AddCSLuaFile("entities/ent_csg_terminal/shared.lua")
   AddCSLuaFile("entities/ent_csg_terminal/cl_init.lua")

   -- Load server-side modules
   include("csg/sh_config.lua")
   include("csg/sv_cameras.lua")
else
   -- Clients get config and UI
   include("csg/sh_config.lua")
   include("csg/cl_viewer.lua")
end
