if SERVER then
    AddCSLuaFile("forcefp/sh_config.lua")
    AddCSLuaFile("forcefp/cl_fp_camera.lua")

    include("forcefp/sh_config.lua")
    include("forcefp/sv_fp_control.lua")
else
    include("forcefp/sh_config.lua")
    include("forcefp/cl_fp_camera.lua")
end