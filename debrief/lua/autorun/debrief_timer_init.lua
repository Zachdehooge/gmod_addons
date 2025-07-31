if SERVER then
    AddCSLuaFile("client/cl_debrief_timer.lua")
    include("server/sv_debrief_timer.lua")
else
    include("client/cl_debrief_timer.lua")
end
