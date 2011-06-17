HintabilityHunter = CreateFrame("Frame")

function HintabilityHunter:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		_, _, _, _, HintabilityHunter.improvedMendPetTalent = GetTalentInfo(1, 7)
		_, _, _, _, HintabilityHunter.fervorTalent = GetTalentInfo(1, 9)
	end
end

function HintabilityHunter:OnUpdate(elapsed)
	local targetDead = UnitIsDead("target")
	local hostile = UnitCanAttack("player", "target")
	local targetHealth = math.ceil(UnitHealth("target") * 100 / UnitHealthMax("target"))
	Hintability:SetGlow(HintabilityHunter.killShot, not targetDead and hostile and targetHealth <= 20 and Hintability:GetCooldown(HintabilityHunter.killShot) < HintabilityHunter.reactionTime)
	Hintability:SetGlow(HintabilityHunter.fervor, HintabilityHunter.fervorTalent == 1 and UnitPowerType("player") == 2 and UnitPower("player") < 40 and Hintability:GetCooldown(HintabilityHunter.fervor) < HintabilityHunter.reactionTime)

	local tranq
	if not targetDead and hostile then
		local index = 1
		local _, _, _, _, dispellType, _, expires, _, _, _, buffId = UnitBuff("target", index)
		while expires do
			if dispellType == "Magic" or dispellType == "" then
				-- enrage got dispellType ""
				tranq = 1
				if dispellType == "" or HintabilityHunter.mustDispel[buffId] then
					-- nasty buff we must dispel immediately
					PlaySound("RaidWarning")
					break
				end
			end
			index = index + 1
			_, _, _, _, dispellType, _, expires, _, _, _, buffId = UnitBuff("target", index)
		end
	end
	Hintability:SetGlow(HintabilityHunter.tranquilizingShot, tranq)

	local petDead = UnitIsDead("pet")
	local petHealth = math.ceil(UnitHealth("pet") * 100 / UnitHealthMax("pet"))
	local _, _, _, _, _, _, expires = UnitBuff("pet", HintabilityHunter.buffs[HintabilityHunter.mendPet])
	local remaining = (expires or 0) - GetTime()
	Hintability:SetGlow(HintabilityHunter.revivePet, petDead)

	local index = 1
	local _, _, _, _, dispellType, _, expires = UnitDebuff("pet", index)
	while expires do
		if dispellType and expires > 3 then
			break
		end
		index = index + 1
		_, _, _, _, dispellType, _, expires = UnitDebuff("pet", index)
	end
	Hintability:SetGlow(HintabilityHunter.mendPet, not petDead and ((dispellType and HintabilityHunter.improvedMendPetTalent > 0) or (petHealth < 90 and remaining < HintabilityHunter.reactionTime)))
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
HintabilityHunter.mustDispel = {
	-- druid
	[29166] = 1, -- innervate
	-- hunter
	[90355] = 1, -- ancient hysteria
	-- mage
	[543] = 1, -- mage ward
	[1463] = 1, -- mana shield
	[11426] = 1, -- ice barrier
	[12042] = 1, -- arcane power
	[12472] = 1, -- icy veins
	[80353] = 1, -- time warp
	-- paladin
	[1044] = 1, -- hand of freedom
	[6940] = 1, -- hand of sacrifice
	-- priest
	[10060] = 1, -- power infusion
	[17] = 1, -- power word: shield
	[6346] = 1, -- fear ward
	-- shaman
	[2825] = 1, -- bloodlust
	[32182] = 1, -- heroism
	[79206] = 1, -- spiritwalker's grace
	-- warlock
	[91711] = 1 -- nether ward
}

-- functions & events
HintabilityHunter:SetScript("OnEvent", HintabilityHunter.OnEvent)
HintabilityHunter:SetScript("OnUpdate", HintabilityHunter.OnUpdate)
HintabilityHunter:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
HintabilityHunter:RegisterEvent("PLAYER_ENTERING_WORLD")
