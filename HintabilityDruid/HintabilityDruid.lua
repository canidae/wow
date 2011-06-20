HintabilityDruid = CreateFrame("Frame")

function HintabilityDruid:OnEvent(event, ...)
	if event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		_, _, _, _, HintabilityDruid.kotjTalent = GetTalentInfo(2, 8) -- king of the jungle
	end
end

function HintabilityDruid:OnUpdate(elapsed)
	local targetDead = UnitIsDead("target")
	local hostile = UnitCanAttack("player", "target")
	Hintability:SetGlow(HintabilityDruid.tigersFury, HintabilityDruid.kotjTalent > 0 and UnitPowerType("player") == 3 and UnitPower("player") + 20 * HintabilityDruid.kotjTalent < UnitPowerMax("player") and Hintability:GetCooldown(HintabilityDruid.tigersFury) < HintabilityDruid.reactionTime)

	local soothe
	if not targetDead and hostile then
		local index = 1
		local _, _, _, _, dispellType, _, expires, _, _, _, buffId = UnitBuff("target", index)
		while expires do
			if dispellType == "" then
				-- enrage got dispellType ""
				soothe = 1
				PlaySound("RaidWarning")
				local buffFrame = _G["TargetFrameBuff" .. index .. "Stealable"]
				buffFrame:Show()
			end
			index = index + 1
			_, _, _, _, dispellType, _, expires, _, _, _, buffId = UnitBuff("target", index)
		end
	end
	Hintability:SetGlow(HintabilityDruid.soothe, soothe)
end

-- spell id of abilities
HintabilityDruid.soothe = 2908
HintabilityDruid.tigersFury = 5217

-- other variables
HintabilityDruid.reactionTime = 0.2

HintabilityDruid:SetScript("OnEvent", HintabilityDruid.OnEvent)
HintabilityDruid:SetScript("OnUpdate", HintabilityDruid.OnUpdate)
HintabilityDruid:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
HintabilityDruid:RegisterEvent("PLAYER_TALENT_UPDATE")
