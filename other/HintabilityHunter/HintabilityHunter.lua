HintabilityHunter = CreateFrame("Frame")

function HintabilityHunter:OnEvent(event, ...)
	if event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		_, _, _, _, HintabilityHunter.improvedMendPetTalent = GetTalentInfo(1, 7)
		_, _, _, _, HintabilityHunter.fervorTalent = GetTalentInfo(1, 9)
	end
end

function HintabilityHunter:OnUpdate(elapsed)
	local targetHealth = math.ceil(UnitHealth("target") * 100 / UnitHealthMax("target"))
	Hintability:SetGlow(HintabilityHunter.killShot, not UnitIsDead("target") and UnitCanAttack("player", "target") and targetHealth <= 20 and Hintability:GetCooldown(HintabilityHunter.killShot) < HintabilityHunter.reactionTime)
	Hintability:SetGlow(HintabilityHunter.fervor, HintabilityHunter.fervorTalent == 1 and UnitPowerType("player") == 2 and UnitPower("player") < 40 and Hintability:GetCooldown(HintabilityHunter.fervor) <= 1.5)

	Hintability:ShowDispel(HintabilityHunter.tranquilizingShot, 1, 1)

	local petDead = UnitIsDead("pet")
	local petHealth = math.ceil(UnitHealth("pet") * 100 / UnitHealthMax("pet"))
	local _, _, _, _, _, _, expires = UnitBuff("pet", HintabilityHunter.buffs[HintabilityHunter.mendPet])
	local remaining = (expires or 0) - GetTime()

	if petHealth > 90 and remaining < HintabilityHunter.reactionTime and HintabilityHunter.improvedMendPetTalent then
		local index = 1
		local _, _, _, _, dispelType, _, expires = UnitDebuff("pet", index)
		while expires do
			if dispelType and expires > 3 then
				break
			end
			index = index + 1
			_, _, _, _, dispelType, _, expires = UnitDebuff("pet", index)
		end
	end
	if not petDead and (petHealth < 90 or dispelType) and remaining < HintabilityHunter.reactionTime then
		if petHealth < 60 or UnitIsPVP("player") or Hintability:InPvpZone() then
			-- only play sound when pet health is really low, we're flagged for PvP or we're in a PvP zone (won't be flagged for PvP in arena)
			PlaySound("igQuestFailed")
		end
		Hintability:SetGlow(HintabilityHunter.mendPet, 1)
	else
		Hintability:SetGlow(HintabilityHunter.mendPet)
	end
end

-- spell id of abilities
HintabilityHunter.mendPet = 136
HintabilityHunter.revivePet = 982
HintabilityHunter.tranquilizingShot = 19801
HintabilityHunter.killShot = 53351
HintabilityHunter.fervor = 82726
-- cache of ability buff names
HintabilityHunter.buffs = {
	[HintabilityHunter.mendPet] = GetSpellInfo(HintabilityHunter.mendPet)
}

-- other variables
HintabilityHunter.reactionTime = 0.2

-- functions & events
HintabilityHunter:SetScript("OnEvent", HintabilityHunter.OnEvent)
HintabilityHunter:SetScript("OnUpdate", HintabilityHunter.OnUpdate)
HintabilityHunter:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
HintabilityHunter:RegisterEvent("PLAYER_TALENT_UPDATE")
