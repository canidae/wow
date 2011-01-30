Loyalty = CreateFrame("Frame")

function Loyalty:OnUpdate(elapsed)
	if not CombatText_AddMessage then
		return
	end
	-- keep an eye on focus
	local focus = UnitPower("player")
	if focus >= 80 and Loyalty.lastFocus < 80 then
		CombatText_AddMessage("High focus: " .. focus, COMBAT_TEXT_SCROLL_FUNCTION, PowerBarColor["FOCUS"].r, PowerBarColor["FOCUS"].g, PowerBarColor["FOCUS"].b, nil, nil)
	end
	Loyalty.lastFocus = focus
	-- keep an eye on pet
	if UnitExists("pet") and not UnitIsDead("pet") then
		local pethealth = math.ceil(UnitHealth("pet") * 100 / UnitHealthMax("pet"))
		local _, _, _, _, _, duration, expires, _, _, _, _ = UnitBuff("pet", "Mend Pet")
		if not duration and pethealth < 80 and (InCombatLockdown() or pethealth < 50) then
			-- pet is wounded and mend pet is not up, annoy hunter
			PlaySound("igQuestFailed")
		end
	end
	-- keep an eye on enemy
	local time = GetTime()
	if UnitExists("target") and not UnitIsDead("target") then -- and UnitCanAttack("player", "target") then
		if UnitName("target") ~= Loyalty.target.name then
			wipe(Loyalty.target)
			Loyalty.target.name = UnitName("target")
			Loyalty.target.buffs = {}
			Loyalty.target.dispellCount = 0
		end
		local i = 1
		local magicBuffs = 0
		local enrages = 0
		local buff, _, _, count, buffType, duration, expiration, _, _, _, buffId = UnitBuff("target", i)
		while buff do
			if buffType == "Magic" or buffType == "" then
				-- "Enrage" seems to have blank buff type?
				if not count or count == 0 then
					-- it appears like count is set to 0 for buffs that doesn't stack
					count = 1
				end
				if buffType == "" then
					enrages = enrages + count
				else
					magicBuffs = magicBuffs + count
				end
				if not Loyalty.target.buffs[buffId] or Loyalty.target.buffs[buffId] ~= count then
					Loyalty.target.dispellCount = 0
				end
				Loyalty.target.buffs[buffId] = count
			end
			i = i + 1
			buff, _, _, count, buffType, duration, expiration, _, _, _, buffId = UnitBuff("target", i)
		end
		local dispellCount = math.max(magicBuffs, enrages)
		if Loyalty.target.dispellCount ~= dispellCount then
			Loyalty.target.dispellCount = dispellCount
			if dispellCount > 0 then
				CombatText_AddMessage("Tranquilize (" .. enrages .. "/" .. magicBuffs .. ")", COMBAT_TEXT_SCROLL_FUNCTION, 0.91, 0.93, 0.0, nil, nil)
			end
		end
	end
	-- keep an eye on cooldowns
	for spellId, status in pairs(Loyalty.cooldowns) do
		local start, duration, enabled = GetSpellCooldown(spellId)
		local remaining = start + duration - time
		if status == 1 then
			if remaining < 3 then
				Loyalty.cooldowns[spellId] = nil
			else
				Loyalty.cooldowns[spellId] = 2
			end
		else
			if remaining <= 0.5 then
				local spell = GetSpellInfo(spellId)
				local crit
				if duration > 20 then
					crit = "crit"
				end
				CombatText_AddMessage(spell, COMBAT_TEXT_SCROLL_FUNCTION, 0.12, 0.73, 0.95, crit, nil)
				Loyalty.cooldowns[spellId] = nil
			end
		end
	end
end

function Loyalty:OnEvent(event, ...)
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, spell, _, _, spellId = ...
		if unit == "player" or unit == "pet" then
			local ignore
			if spellId ~= 90361 and unit == "pet" then
				-- spell 90361 is spirit mend, we may want to keep that at automatic cast
				_, ignore = GetSpellAutocast(spell, SPELLBOOK_PET)
			end
			if not ignore and not Loyalty.ignoreCooldowns[spellId] then
				Loyalty.cooldowns[spellId] = 1
			end
			--print(unit, spell, spellId)
		end
	end
end

Loyalty.cooldowns = {}
Loyalty.target = {}
Loyalty.lastFocus = 110

Loyalty.ignoreCooldowns = {
	[82179] = 1
}

Loyalty:SetScript("OnUpdate", Loyalty.OnUpdate)
Loyalty:SetScript("OnEvent", Loyalty.OnEvent)
Loyalty:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
