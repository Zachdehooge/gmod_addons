TOOL.Category = "ForceFP"
TOOL.Name = "#ForceFP Zone"
TOOL.Command = nil
TOOL.ConfigName = ""

if CLIENT then
    language.Add("#tool.forcefptool.name", "ForceFP")
    language.Add("#tool.forcefptool.desc", "Place/Remove ForceFP zones using the toolgun")
    language.Add("#tool.forcefptool.0", "Left click to place zone, right click to remove zone")
    showZones = true
end

TOOL.ClientConVar = {
    width = "200",
    length = "200",
    height = "200",
    showzones = "1"
}


FP_Zones = FP_Zones or {}


if SERVER then
    util.AddNetworkString("FP_ForceState")
    util.AddNetworkString("FP_ZoneUpdate")
end

local function IsInForceFPZone(ply)
    if not IsValid(ply) then return false end
    local pos = ply:GetPos()
    
    -- Debug: print position and zones
    if CLIENT then
        -- Uncomment to debug:
        -- print("[ForceFP] Player pos:", pos, "Zone count:", table.Count(FP_Zones))
    end
    
    for id, zone in pairs(FP_Zones) do
        if zone.min and zone.max then
            if pos:WithinAABox(zone.min, zone.max) then
                if CLIENT then
                    -- print("[ForceFP] Player IS in zone:", id)
                end
                return true
            end
        end
    end
    return false
end


local function ClampSlider(value)
    return math.Clamp(value, 10, 10000)
end

if SERVER then
    util.AddNetworkString("FP_ForceState")
    util.AddNetworkString("FP_ZoneUpdate")
    
    -- File path for saving zones
    local ZONES_FILE = "forcefp_zones.txt"
    
    -- Save zones to file
    local function SaveZones()
        local data = util.TableToJSON(FP_Zones)
        file.Write(ZONES_FILE, data)
        print("[ForceFP] Zones saved to file")
    end
    
    -- Load zones from file
    local function LoadZones()
        if file.Exists(ZONES_FILE, "DATA") then
            local data = file.Read(ZONES_FILE, "DATA")
            FP_Zones = util.JSONToTable(data) or {}
            print("[ForceFP] Loaded " .. table.Count(FP_Zones) .. " zones from file")
            return true
        end
        print("[ForceFP] No saved zones found")
        return false
    end
    
    hook.Add("Initialize", "ForceFP_LoadZones", function()
        LoadZones()
    end)
    
    local function BroadcastZones()
        net.Start("FP_ZoneUpdate")
            net.WriteUInt(table.Count(FP_Zones), 16)
            for id, zone in pairs(FP_Zones) do
                net.WriteString(id)
                net.WriteVector(zone.min)
                net.WriteVector(zone.max)
            end
        net.Broadcast()
    end

    TOOL.BroadcastZones = BroadcastZones
    TOOL.SaveZones = SaveZones
    
    hook.Add("PlayerInitialSpawn", "ForceFP_SendZones", function(ply)
        timer.Simple(1, function()
            if IsValid(ply) then
                net.Start("FP_ZoneUpdate")
                    net.WriteUInt(table.Count(FP_Zones), 16)
                    for id, zone in pairs(FP_Zones) do
                        net.WriteString(id)
                        net.WriteVector(zone.min)
                        net.WriteVector(zone.max)
                    end
                net.Send(ply)
            end
        end)
    end)
end


function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", {Description = "Place/remove ForceFP zones"})
    panel:NumSlider("Width",  "forcefptool_width", 10, 10000, 0)
    panel:NumSlider("Length", "forcefptool_length", 10, 10000, 0)
    panel:NumSlider("Height", "forcefptool_height", 10, 10000, 0)
    panel:CheckBox("Show Active Zones", "forcefptool_showzones")
end


function TOOL:LeftClick(trace)
    if CLIENT then return true end
    if not trace.Hit then return false end

    local ply = self:GetOwner()
    local width  = ClampSlider(self:GetClientNumber("width"))
    local length = ClampSlider(self:GetClientNumber("length"))
    local height = ClampSlider(self:GetClientNumber("height"))

    local min = Vector(trace.HitPos.x - width/2, trace.HitPos.y - length/2, trace.HitPos.z)
    local max = Vector(trace.HitPos.x + width/2, trace.HitPos.y + length/2, trace.HitPos.z + height)

    local zoneID = "zone_" .. os.time() .. "_" .. math.random(1000,9999)

    FP_Zones[zoneID] = {
        min = min,
        max = max,
        width = width,
        length = length,
        height = height,
        creator = ply:Nick()
    }

    if SERVER then 
        self.BroadcastZones()
        self.SaveZones()
    end
    ply:ChatPrint("[ForceFP] Zone placed! ID: " .. zoneID)
    return true
end


function TOOL:RightClick(trace)
    if CLIENT then return true end
    if not trace.Hit then return false end

    local ply = self:GetOwner()
    local removed = 0
    for id, zone in pairs(FP_Zones) do
        if trace.HitPos:WithinAABox(zone.min, zone.max) then
            FP_Zones[id] = nil
            removed = removed + 1
        end
    end
    if removed > 0 and SERVER then
        self.BroadcastZones()
        self.SaveZones()
        ply:ChatPrint("[ForceFP] Removed " .. removed .. " zone(s) under crosshair")
    else
        ply:ChatPrint("[ForceFP] No zones under crosshair")
    end
    return true
end

function TOOL:Reload(trace)
    if CLIENT then return true end
    FP_Zones = {}
    if SERVER then 
        self.BroadcastZones()
        self.SaveZones()
    end
    self:GetOwner():ChatPrint("[ForceFP] All zones removed!")
    return true
end

if CLIENT then

    local wasInZone = false
    local allowInternalCommand = false
    
    local oldRunConsoleCommand = RunConsoleCommand
    
    RunConsoleCommand = function(cmd, ...)
        if allowInternalCommand then
            return oldRunConsoleCommand(cmd, ...)
        end
        
        if (cmd == "thirdperson_toggle" or cmd == "thirdperson_view") then
            local ply = LocalPlayer()
            if IsValid(ply) and not table.IsEmpty(FP_Zones) and not IsInForceFPZone(ply) then
                chat.AddText(Color(255,100,100), "[ForceFP] ", Color(255,255,255), "Third person is only allowed inside base!")
                return
            end
        end
        return oldRunConsoleCommand(cmd, ...)
    end
    
    hook.Add("Think", "ForceFP_ZoneCheck", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        if table.IsEmpty(FP_Zones) then 
            wasInZone = false
            return 
        end

        local inZone = IsInForceFPZone(ply)
        
        if wasInZone and not inZone then
            --print("[ForceFP] Player left zone - forcing first person")
            allowInternalCommand = true
            RunConsoleCommand("thirdperson_view", "0")
            allowInternalCommand = false
            --chat.AddText(Color(255,100,100), "[ForceFP] ", Color(255,255,255), "Forced to first person!")
        end
        
        if not wasInZone and inZone then
            --print("[ForceFP] Player entered zone")
            chat.AddText(Color(100,255,100), "[ForceFP] ", Color(255,255,255), "Third person available!")
        end
        
        wasInZone = inZone
    end)
end

if CLIENT then
    FP_Zones = FP_Zones or {}
    net.Receive("FP_ZoneUpdate", function()
        local count = net.ReadUInt(16)
        FP_Zones = {}
        for i = 1, count do
            local id = net.ReadString()
            local min = net.ReadVector()
            local max = net.ReadVector()
            FP_Zones[id] = {min = min, max = max}
        end
    end)

    cvars.AddChangeCallback("forcefptool_showzones", function(convar, old, new)
        showZones = new == "1"
        if showZones then
            chat.AddText(Color(100,255,100), "[Force FP] ", Color(255,255,255), "Zone visualization enabled")
        else
            chat.AddText(Color(100,255,100), "[Force FP] ", Color(255,255,255), "Zone visualization disabled")
        end
    end)
end

if CLIENT then
    hook.Add("PostDrawTranslucentRenderables", "ForceFP_Preview", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
        if not wep.Tool then return end

        local tool = wep.Tool
        if not tool or tool.Mode ~= "forcefptool" then return end

        local w = ClampSlider(tool:GetClientNumber("width"))
        local l = ClampSlider(tool:GetClientNumber("length"))
        local h = ClampSlider(tool:GetClientNumber("height"))

        local tr = ply:GetEyeTrace()
        if not tr.Hit then return end

        render.SetColorMaterial()
        render.DrawWireframeBox(
            tr.HitPos,
            Angle(0,0,0),
            Vector(-w/2, -l/2, 0),
            Vector( w/2,  l/2, h),
            Color(0,255,0),
            true
        )
    end)
end

if CLIENT then
    hook.Add("PostDrawTranslucentRenderables", "ForceFP_ActiveZones", function()
        if not showZones then return end
        if not FP_Zones then return end

        for _, zone in pairs(FP_Zones) do
            local center = (zone.min + zone.max)/2
            render.SetColorMaterial()
            render.DrawWireframeBox(
                center,
                Angle(0,0,0),
                zone.min - center,
                zone.max - center,
                Color(255,0,0),
                true
            )
        end
    end)
end