util.AddNetworkString("FP_ForceState")

local function SendFPState(ply, wep)
    local allowThirdPerson =
        IsValid(wep) and FP_THIRDPERSON_WHITELIST[wep:GetClass()] or false

    net.Start("FP_ForceState")
        net.WriteBool(allowThirdPerson)
    net.Send(ply)
end

hook.Add("PlayerSwitchWeapon", "FP_ForceWeaponSwitch", function(ply, old, new)
    SendFPState(ply, new)
end)

hook.Add("PlayerSpawn", "FP_ForceSpawn", function(ply)
    timer.Simple(0, function()
        if IsValid(ply) then
            SendFPState(ply, ply:GetActiveWeapon())
        end
    end)
end)
