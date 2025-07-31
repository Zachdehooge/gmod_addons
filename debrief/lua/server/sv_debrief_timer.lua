util.AddNetworkString("DebriefTimer_Start")
util.AddNetworkString("DebriefTimer_Stop")
util.AddNetworkString("DebriefTimer_Exit")

local debriefTimerEnd = 0

local ALLOWED_USERGROUPS = {
	["admin"] = true,
	["superadmin"] = true,
	["moderator"] = true,
	["gamemaster"] = true,
	["seniorgamemaster"] = true,
}

local ALLOWED_JOBS = {
	["Clone Officer"] = true,
	["Clone Company Commander"] = true,
	["Clone Battalion Commander"] = true,
	["Colt"] = true,
	["Havoc"] = true,
	["Hammer"] = true,
	["Blitz"] = true,
	["Naval Officer"] = true,
	["Naval Commander"] = true,
	["RBNO Marine Commander"] = true,
}

local function IsAllowed(ply)
	local teamIndex = ply:Team()
	local jobTeams = team.GetAllTeams()

	local jobName = jobTeams[teamIndex] and jobTeams[teamIndex].Name
	if jobName and ALLOWED_JOBS[jobName] then
		return true
	end

	local usergroup = ply:GetUserGroup()
	if ALLOWED_USERGROUPS[usergroup] then
		return true
	end

	return false
end

function StartDebriefTimer(duration)
	debriefTimerEnd = CurTime() + duration
	net.Start("DebriefTimer_Start")
	net.WriteFloat(debriefTimerEnd)
	net.Broadcast()
end

function StopDebriefTimer()
	net.Start("DebriefTimer_Stop")
	net.Broadcast()
end

-- Example command
concommand.Add("debrief_start", function(ply, cmd, args)
	if not IsValid(ply) or ply:IsAdmin() then
		StartDebriefTimer(tonumber(args[1]) or 900)
	end
end)

concommand.Add("debrief_stop", function(ply, cmd, args)
	if not IsValid(ply) or ply:IsAdmin() then
		StopDebriefTimer()
	end
end)

-- Handle chat commands
hook.Add("PlayerSay", "DebriefTimerChatCommand", function(ply, text)
	local args = string.Explode(" ", text)

	if args[1] == "!debrief" then
		if not IsAllowed(ply) then
			ply:ChatPrint("[Debrief] You don't have permission.")
			return ""
		end

		local duration = tonumber(args[2]) or 900
		StartDebriefTimer(duration)
		PrintMessage(HUD_PRINTTALK, "[Debrief] Timer started for " .. duration .. " seconds.")
		return ""
	end

	if args[1] == "!stopdebrief" then
		if not IsAllowed(ply) then
			ply:ChatPrint("[Debrief] You don't have permission.")
			return ""
		end

		StopDebriefTimer()
		PrintMessage(HUD_PRINTTALK, "[Debrief] Timer stopped.")
		return ""
	end
end)
