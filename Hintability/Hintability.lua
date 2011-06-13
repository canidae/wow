Hintability = CreateFrame("Frame")
HintabilityTooltip = CreateFrame("GameTooltip", "HintabilityTooltip", nil, "GameTooltipTemplate")
HintabilityTooltip:SetOwner(UIParent, "ANCHOR_NONE")

function Hintability:OnEvent(event, ...)
	--print(GetTime(), event, ...)
	if event == "ACTIONBAR_SLOT_CHANGED" then
		Hintability:DetectAbility(...)
	elseif event == "PLAYER_ENTERING_WORLD" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		for i = 1, NUM_ACTIONBAR_PAGES * NUM_ACTIONBAR_BUTTONS do
			Hintability:DetectAbility(i)
		end
	end
end

function Hintability:DetectAbility(slot)
	local text, actionId = GetActionInfo(slot)
	local cache = (text or "") .. (actionId or "")
	if Hintability.cache[slot] == cache then
		-- no change
		return
	end
	Hintability.cache[slot] = cache

	local spellId
	local button = Hintability:GetButton(slot)
	if button and button:IsVisible() then
		HintabilityTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		HintabilityTooltip:SetAction(slot)
		_, _, spellId = HintabilityTooltip:GetSpell()
		HintabilityTooltip:Hide()
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

function Hintability:SetGlow(spellId, on)
	if Hintability.spells[spellId] then
		for slot, one in pairs(Hintability.spells[spellId]) do
			local button = Hintability:GetButton(slot)
			if button and button:IsVisible() then
				if on and not Hintability.glowing[slot] then
					ActionButton_ShowOverlayGlow(button)
				elseif not on and Hintability.glowing[slot] then
					ActionButton_HideOverlayGlow(button)
				end
				Hintability.glowing[slot] = on
			end
		end
	end
end

function Hintability:GetButton(slot)
	if not slot then
		return
	end
	local buttonId = math.fmod(slot - 1, 12) + 1
	if (slot >= 1 and slot <= 24) or slot >= 73 then
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

Hintability.spells = {}
Hintability.slots = {}
Hintability.cache = {}
Hintability.glowing = {}

Hintability:SetScript("OnEvent", Hintability.OnEvent)
Hintability:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
Hintability:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Hintability:RegisterEvent("PLAYER_ENTERING_WORLD")
