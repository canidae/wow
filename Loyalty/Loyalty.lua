Loyalty = CreateFrame("Frame")
LoyaltyTooltip = CreateFrame("GameTooltip", "LoyaltyTooltip", nil, "GameTooltipTemplate")
LoyaltyTooltip:SetOwner(UIParent, "ANCHOR_NONE")

function Loyalty:OnUpdate(elapsed)
	if not CombatText_AddMessage then
		return
	end
	local focus = UnitPower("player")
	if focus ~= Loyalty.lastFocus then
		Loyalty.lastFocus = focus
		-- keep an eye on focus
		local powermax = UnitPowerMax("player")
		local power = UnitPower("player")
		if not UnitIsDeadOrGhost("player") and (InCombatLockdown() or power < powermax) then
			ReputationWatchStatusBarText:SetText(power .. " / " .. powermax)
			ReputationWatchStatusBarText:Show()
			ReputationWatchStatusBar:SetMinMaxValues(0, powermax)
			ReputationWatchStatusBar:SetValue(power)
			if power < 30 or power > powermax - 30 then
				ReputationWatchStatusBar:SetStatusBarColor(0.9, 0.8, 0);
			else
				ReputationWatchStatusBar:SetStatusBarColor(0.2, 0.6, 0);
			end
			Loyalty.resetrepbar = 1
		elseif Loyalty.resetrepbar then
			HideWatchedReputationBarText()
			ReputationWatchBar_Update()
			Loyalty.resetrepbar = nil
		end
	end
	-- keep an eye on cooldowns
	for spellId, status in pairs(Loyalty.cooldowns) do
		local start, duration, enabled = GetSpellCooldown(spellId)
		local remaining = start + duration - GetTime()
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
	--print(GetTime(), event, ...)
	if event == "ACTIONBAR_SLOT_CHANGED" then
		local slot = ...
		local text, spellId = GetActionInfo(slot)
		if Loyalty.actionButtons[slot] ~= (text or "") .. (spellId or "") then
			Loyalty:DetectAbilities()
		end
	elseif ((event == "UNIT_AURA" and ... == "target") or (event == "UNIT_TARGET" and ... == "player")) and Loyalty.spells[19801] then
		-- keep an eye on enemy
		if not UnitExists("target") or UnitIsDead("target") then -- or UnitCanAttack("player", "target") then
			Loyalty:SetGlow(19801, 1)
		else
			local i = 1
			local buff, _, _, count, buffType, duration, expiration, _, _, _, buffId = UnitBuff("target", i)
			local hideGlow = 1
			while buff do
				if buffType == "Magic" or buffType == "" then
					-- "Enrage" seems to have blank buff type?
					hideGlow = nil
					break
				end
				i = i + 1
				buff, _, _, count, buffType, duration, expiration, _, _, _, buffId = UnitBuff("target", i)
			end
			Loyalty:SetGlow(19801, hideGlow)
		end
	elseif event == "UNIT_AURA" and ... == "player" then
		if UnitAura("player", "Fire!") then
			Loyalty:SetGlow(19434)
		elseif UnitAura("player", "Killing Streak") then
			Loyalty:SetGlow(94007)
		end
	elseif event == "UNIT_HEALTH" and ... == "pet" then
		-- keep an eye on pet
		if not UnitIsDead("pet") then
			local pethealth = math.ceil(UnitHealth("pet") * 100 / UnitHealthMax("pet"))
			local _, _, _, _, _, duration, expires, _, _, _, _ = UnitBuff("pet", "Mend Pet")
			if not duration and pethealth < 80 and (InCombatLockdown() or pethealth < 50) then
				-- pet is wounded and mend pet is not up, annoy hunter
				PlaySound("igQuestFailed")
			end
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
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

function Loyalty:SetGlow(spellId, off)
	if Loyalty.spells[spellId] then
		local button = _G["ActionButton" .. Loyalty.spells[spellId]]
		if button and button:IsVisible() then
			if off then
				ActionButton_HideOverlayGlow(button)
			else
				ActionButton_ShowOverlayGlow(button)
			end
		end
	end
end

function Loyalty:DetectAbilities()
	wipe(Loyalty.spells)
	for i = 1, NUM_ACTIONBAR_PAGES * NUM_ACTIONBAR_BUTTONS do
		local button = _G["ActionButton" .. i]
		if button and button:IsVisible() then
			LoyaltyTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			LoyaltyTooltip:SetAction(i)
			local spellName, _, spellId = LoyaltyTooltip:GetSpell()
			LoyaltyTooltip:Hide()
			if spellId then
				Loyalty.spells[spellId] = i
			end
			local text, spellId = GetActionInfo(i)
			Loyalty.actionButtons[i] = (text or "") .. (spellId or "")
		end
	end
end

Loyalty.cooldowns = {}
Loyalty.spells = {}
Loyalty.lastFocus = 110
Loyalty.actionButtons = {}

Loyalty.ignoreCooldowns = {
	[82179] = 1
}

Loyalty:SetScript("OnUpdate", Loyalty.OnUpdate)
Loyalty:SetScript("OnEvent", Loyalty.OnEvent)
Loyalty:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
Loyalty:RegisterEvent("UNIT_AURA")
Loyalty:RegisterEvent("UNIT_HEALTH")
Loyalty:RegisterEvent("UNIT_TARGET")
Loyalty:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
