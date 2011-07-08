Hintability = CreateFrame("Frame")
HintabilityTooltip = CreateFrame("GameTooltip", "HintabilityTooltip", nil, "GameTooltipTemplate")
HintabilityTooltip:SetOwner(UIParent, "ANCHOR_NONE")

function Hintability:OnEvent(event, ...)
	if event == "ACTIONBAR_SLOT_CHANGED" then
		Hintability:DetectAbility(...)
	else
		for i = 1, NUM_ACTIONBAR_PAGES * NUM_ACTIONBAR_BUTTONS do
			Hintability:DetectAbility(i)
		end
	end
end

function Hintability:DetectAbility(slot)
	local cache = GetActionTexture(slot) or ""
	if Hintability.cache[slot] == cache then
		-- no change
		return
	end

	local spellId
	local button = Hintability:GetButton(slot)
	if button then
		if button:IsVisible() then
			HintabilityTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			HintabilityTooltip:SetAction(slot)
			_, _, spellId = HintabilityTooltip:GetSpell()
			HintabilityTooltip:Hide()
		end
		-- only set cache when we got a button
		-- if we don't have a button, it means we either can't show tooltip or tooltip will show for a slot on another page
		Hintability.cache[slot] = cache
	end
	local oldSpellId = Hintability.slots[slot]
	if oldSpellId then
		if not Hintability.spells[oldSpellId] then
			Hintability.spells[oldSpellId] = {}
		end
		Hintability.spells[oldSpellId][slot] = nil
	end
	if spellId then
		if not Hintability.spells[spellId] then
			Hintability.spells[spellId] = {}
		end
		Hintability.spells[spellId][slot] = 1
	end
	Hintability.slots[slot] = spellId
end

function Hintability:ShowDispel(spellId, magic, enrage)
	local glowAbility
	if not UnitIsDead("target") and UnitCanAttack("player", "target") then
		local index = 1
		local _, _, _, _, dispelType, _, expires, _, _, _, buffId = UnitBuff("target", index)
		while expires do
			if (magic and dispelType == "Magic") or (enrage and dispelType == "") then
				-- enrage got dispelType ""
				glowAbility = 1
				local buffFrame = _G["TargetFrameBuff" .. index .. "Stealable"]
				buffFrame:Show()
			end
			index = index + 1
			_, _, _, _, dispelType, _, expires, _, _, _, buffId = UnitBuff("target", index)
		end
	end
	Hintability:SetGlow(spellId, glowAbility)
end

function Hintability:SetGlow(spellId, on)
	if spellId and Hintability.spells[spellId] then
		for slot, one in pairs(Hintability.spells[spellId]) do
			local button = Hintability:GetButton(slot)
			if button and button:IsVisible() then
				if on then
					ActionButton_ShowOverlayGlow(button)
				else
					ActionButton_HideOverlayGlow(button)
				end
			end
		end
	end
end

function Hintability:GetButton(slot)
	if not slot then
		return
	end
	local buttonId = math.fmod(slot - 1, 12) + 1
	if math.floor((slot - 1) / 12) + 1 == GetActionBarPage() or slot >= 73 then
		return _G["ActionButton" .. buttonId]
	elseif slot >= 25 and slot <= 36 then
		return _G["MultiBarRightButton" .. buttonId]
	elseif slot >= 37 and slot <= 48 then
		return _G["MultiBarLeftButton" .. buttonId]
	elseif slot >= 40 and slot <= 60 then
		return _G["MultiBarBottomRightButton" .. buttonId]
	elseif slot >= 61 and slot <= 72 then
		return _G["MultiBarBottomLeftButton" .. buttonId]
	end
end

function Hintability:GetCooldown(spellId)
	local start, duration = GetSpellCooldown(spellId)
	return start + duration - GetTime()
end

function Hintability:InPvpZone()
	local pvptype = GetZonePVPInfo()
	if pvptype == "arena" or pvptype == "combat" then
		return 1
	end
	local _, instancetype = IsInInstance()
	if instancetype == "pvp" then
		return 1
	end
end

Hintability.spells = {}
Hintability.slots = {}
Hintability.cache = {}

Hintability:SetScript("OnEvent", Hintability.OnEvent)
Hintability:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
Hintability:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
Hintability:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Hintability:RegisterEvent("PLAYER_ENTERING_WORLD")
