hook.Add("PlayerSay", "HelmetToggleCommand", function(ply, text)
	if string.lower(text) ~= "/helmet" then
		return
	end

	local model = ply:GetModel()
	local hasHelmet = false
	local helmetGroupID = nil
	local maxSubmodels = 0

	util.PrecacheModel(model)
	local ent = ents.Create("prop_physics")
	if not IsValid(ent) then
		ply:ChatPrint("Something went wrong.")
		return ""
	end
	ent:SetModel(model)
	ent:Spawn()

	for _, bg in ipairs(ent:GetBodyGroups()) do
		if string.lower(bg.name) == "helmet" then
			hasHelmet = true
			helmetGroupID = bg.id
			maxSubmodels = #bg.submodels
			break
		end
	end

	ent:Remove()

	if hasHelmet and helmetGroupID ~= nil then
		local current = ply:GetBodygroup(helmetGroupID)
		local new = (current == 0) and 1 or 0
		ply:SetBodygroup(helmetGroupID, new)

		if new == 1 then
			ply:ChatPrint("You removed your helmet.")
		else
			ply:ChatPrint("You put your helmet back on.")
		end
	else
		ply:ChatPrint("Your job doesn't support removing a helmet.")
	end

	return ""
end)
