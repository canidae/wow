Loyalty = CreateFrame("Frame")

function Loyalty:OnUpdate(elapsed)
	local powermax = UnitPowerMax("player")
	local power = UnitPower("player")
	if not UnitIsDeadOrGhost("player") and (InCombatLockdown() or power < powermax) then
		ReputationWatchStatusBarText:SetText(power .. " / " .. powermax)
		ReputationWatchStatusBarText:Show()
		ReputationWatchStatusBar:SetMinMaxValues(0, powermax)
		ReputationWatchStatusBar:SetValue(power)
		local color = PowerBarColor["FOCUS"]
		ReputationWatchStatusBar:SetStatusBarColor(color.r, color.g, color.b);
		Loyalty.resetrepbar = 1
	elseif Loyalty.resetrepbar then
		HideWatchedReputationBarText()
		ReputationWatchBar_Update()
		Loyalty.resetrepbar = nil
	end
	if UnitExists("pet") and not UnitIsDead("pet") then
		local pethealth = math.ceil(UnitHealth("pet") * 100 / UnitHealthMax("pet"))
		local _, _, _, _, _, duration, expires, _, _, _, _ = UnitBuff("pet", "Mend Pet")
		if not duration and pethealth < 95 and InCombatLockdown() and (UnitIsPVP("player") or pethealth < 75) then
			-- pet is wounded and mend pet is not up, annoy hunter
			PlaySound("igQuestFailed")
		end
	end
end

Loyalty:SetScript("OnUpdate", Loyalty.OnUpdate)
