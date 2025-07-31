-- Configurable roll range (in units)
local ROLL_RADIUS = 500

hook.Add("PlayerSay", "LocalRollCommand", function(ply, text)
	if string.lower(text) == "/roll" then
		local roll = math.random(1, 100)
		local msg = ply:Nick() .. " rolls a " .. roll

		-- Loop through all players and only show to nearby ones
		for _, other in ipairs(player.GetAll()) do
			if other:GetPos():Distance(ply:GetPos()) <= ROLL_RADIUS then
				other:ChatPrint(msg)
			end
		end

		-- Block from global chat
		return ""
	end
end)
