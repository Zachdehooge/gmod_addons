local allowThirdPerson = false

net.Receive("FP_ForceState", function()
    allowThirdPerson = net.ReadBool()
end)

-- HARD OVERRIDE CAMERA
hook.Add("CalcView", "FP_ForceView", function(ply, pos, ang, fov)
    if not IsValid(ply) or not ply:Alive() then return end

    if allowThirdPerson then
        return
    end

    return {
        origin = pos,
        angles = ang,
        fov = fov,
        drawviewer = false
    }
end)

hook.Add("ShouldDrawLocalPlayer", "FP_ForceDraw", function()
    if allowThirdPerson then return end
    return false
end)
