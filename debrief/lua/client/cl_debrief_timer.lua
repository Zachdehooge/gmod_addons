local debriefTimerEnd = 0
local isDebriefActive = false
local isDebriefHidden = false
local debriefPostEndTime = 0

net.Receive("DebriefTimer_Start", function()
	debriefTimerEnd = net.ReadFloat()
	isDebriefActive = true
	isDebriefHidden = false
	debriefPostEndTime = 0
end)

net.Receive("DebriefTimer_Stop", function()
	isDebriefActive = false
end)

net.Receive("DebriefTimer_Exit", function()
	isDebriefHidden = true
end)

hook.Add("HUDPaint", "DrawDebriefTimer", function()
	if isDebriefHidden then
		return
	end

	local currentTime = CurTime()
	local timeLeft = math.max(0, debriefTimerEnd - currentTime)

	if isDebriefActive and timeLeft <= 0 then
		if debriefPostEndTime == 0 then
			debriefPostEndTime = currentTime + 20
		end

		if currentTime >= debriefPostEndTime then
			isDebriefActive = false
			return
		end
	elseif not isDebriefActive then
		return
	end

	local minutes = math.floor(timeLeft / 60)
	local seconds = math.floor(timeLeft % 60)

	local timeText = string.format("Debrief Starts In: %02d:%02d", minutes, seconds)

	surface.SetFont("DermaLarge")
	local textW, textH = surface.GetTextSize(timeText)
	draw.SimpleText(
		timeText,
		"DermaLarge",
		ScrW() / 2,
		90,
		Color(255, 100, 100, 255),
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_TOP
	)
end)
