Loyalty = CreateFrame("Frame")
Loyalty.aspects = {
	"Aspect of the Hawk",
	"Aspect of the Fox",
	"Aspect of the Pack",
	"Aspect of the Cheetah",
	"Aspect of the Wild"
}
Loyalty.abilities = {
	["Black Arrow"] = "playercooldown",
	["Explosive Shot"] = "playercooldown",
	["Serpent Sting"] = "targetdebuff",
	["Scatter Shot"] = "playercooldown",
	["Mend Pet"] = "petbuff",
	["Wyvern Sting"] = "playercooldown",
	["Disengage"] = "playercooldown",
	["Deterrence"] = "playercooldown",
	["Flare"] = "playercooldown",
	["Bestial Wrath"] = "playercooldown",
	["Intimidation"] = "playercooldown",
	["Master's Call"] = "playercooldown",
	["Medallion of the Horde"] = "playercooldown",
	["Kill Command"] = "playercooldown",
	["Concussive Shot"] = "playercooldown",
	["Arcane Torrent"] = "playercooldown",
	["Feign Death"] = "playercooldown"
}
Loyalty.mend = "Mend Pet"

function Loyalty:OnUpdate(elapsed)
	local playerhealth = math.ceil(UnitHealth("player") * 100 / UnitHealthMax("player"))
	local r, g, b
	if playerhealth > 80 then
		r = 0.0
		g = 1.0
		b = 0.0
	elseif playerhealth > 20 then
		r = 1.0
		g = 1.0
		b = 0.0
	else
		r = 1.0
		g = 0.0
		b = 0.0
	end
	LoyaltyPlayerHealthTexture:SetTexture(r, g, b)
	LoyaltyPlayerHealthText:SetText(playerhealth)
	local playerpowermax = UnitPowerMax("player")
	local playerpower = UnitPower("player")
	if playerpower < 20 then
		-- red, most likely no damage abilities can be used
		r = 1.0
		g = 0.0
		b = 0.0
	elseif playerpower < 45 or playerpower > 90 then
		-- yellow, some damage abilites can be used, or we're about to cap focus
		r = 1.0
		g = 1.0
		b = 0.0
	else
		-- green, all abilities can be used
		r = 0.0
		g = 1.0
		b = 0.0
	end
	LoyaltyPlayerPowerBar:SetMinMaxValues(0, playerpowermax)
	LoyaltyPlayerPowerBar:SetValue(playerpower)
	LoyaltyPlayerPowerBarText:SetText(playerpower)
	LoyaltyPlayerPowerBarTexture:SetVertexColor(r, g, b)

	local status

	if UnitExists("pet") then
		local pethealth = math.ceil(UnitHealth("pet") * 100 / UnitHealthMax("pet"))
		local r, g, b
		if pethealth > 80 then
			r = 0.0
			g = 1.0
			b = 0.0
		elseif pethealth > 20 then
			r = 1.0
			g = 1.0
			b = 0.0
		else
			r = 1.0
			g = 0.0
			b = 0.0
		end
		LoyaltyPetHealthTexture:SetTexture(r, g, b, 1)
		LoyaltyPetHealthText:SetText(pethealth)

		if IsSpellInRange(Loyalty.mend, "pet") ~= 1 then
			status = UnitName("pet") .. " is too far away!"
		end

		local _, _, _, _, _, duration, expires, _, _, _, _ = UnitBuff("pet", Loyalty.mend)
		if UnitIsDead("pet") then
			status = "You let " .. UnitName("pet") .. " die! Bastard!"
		elseif not duration and pethealth < 95 and InCombatLockdown() and (UnitIsPVP("player") or pethealth < 75) then
			-- pet is wounded and mend pet is not up, annoy hunter
			if not status then
				status = "Heal " .. UnitName("pet") .. "!"
			end
			PlaySound("igQuestFailed")
		end
		--[[
		local value = 0
		if duration and expires then
			-- mend pet is up, show remaining duration on mend pet bar
			LoyaltyMendPetBar:SetMinMaxValues(0, duration)
			LoyaltyMendPetBarTexture:SetVertexColor(0.0, 1.0, 1.0, 1.0)
			value = expires - now
		end
		LoyaltyMendPetBar:SetValue(value)

		start, duration, _ = GetSpellCooldown("Master's Call")
		if start and start > 0 then
			LoyaltyMastersCallBar:SetMinMaxValues(0, duration)
			LoyaltyMastersCallBarText:SetTextColor(1.0, 0.0, 0.0, 1.0)
			value = (start + duration) - now
		else
			LoyaltyMastersCallBarText:SetTextColor(0.0, 1.0, 0.0, 1.0)
			value = 0
		end
		--]]
	else
		LoyaltyPetHealthTexture:SetTexture(0, 0, 0, 0)
		LoyaltyPetHealthText:SetText("")
		if not status and not IsMounted() then
			status = "Where's your companion?"
		end
	end

	if not status then
		local aspectactive
		for index, aspect in pairs(Loyalty.aspects) do
			if UnitBuff("player", aspect) then
				aspectactive = 1
				break
			end
		end
		if not aspectactive then
			status = "No aspect?"
		end
	end

	LoyaltyFrameStatus:SetText(status or "")
end

Loyalty:SetScript("OnUpdate", Loyalty.OnUpdate)
