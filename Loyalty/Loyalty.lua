Loyalty = CreateFrame("Frame")
Loyalty.mendPet = "Mend Pet"

function Loyalty:OnUpdate()
	if UnitExists("pet") then
		local petHealth = UnitHealth("pet")
		local petHealthMax = UnitHealthMax("pet")
		local _, _, _, _, _, duration, expires, _, _, _, _ = UnitBuff("pet", Loyalty.mendPet)
		local now = GetTime()
		local odd = (now * 2 - math.floor(now * 2) < 0.5)
		local inRange = (IsSpellInRange(Loyalty.mendPet, "pet") == 1)
		local value = 0
		LoyaltyFrame:Show();
		LoyaltyHealthBar:SetMinMaxValues(0, petHealthMax)
		LoyaltyHealthBarText:SetText(UnitName("pet"))
		if not duration and petHealth / petHealthMax < 0.95 then
			-- pet is wounded and mend pet is not up, flash pet health bar
			if odd then
				if not inRange then
					-- pet is not in range, flash red
					LoyaltyHealthBarTexture:SetVertexColor(1.0, 0.0, 0.0, 1.0)
				else
					-- pet is in range, flash yellow
					LoyaltyHealthBarTexture:SetVertexColor(1.0, 1.0, 0.0, 1.0)
					if InCombatLockdown() then --and UnitIsPVP("player") then
						-- play sound alerting us to heal
						PlaySound("igQuestFailed")
					end
				end
				LoyaltyHealthBar:SetValue(petHealthMax)
			end
		elseif not inRange then
			-- not wounded, but neither in range, flash white
			if odd then
				LoyaltyHealthBarTexture:SetVertexColor(1.0, 1.0, 1.0, 1.0)
				LoyaltyHealthBar:SetValue(petHealthMax)
			end
		end
		if not odd then
			LoyaltyHealthBarTexture:SetVertexColor(0.0, 1.0, 0.0, 1.0)
			LoyaltyHealthBar:SetValue(petHealth)
		end
		if duration and expires then
			-- mend pet is up, show remaining duration on mend pet bar
			LoyaltyMendPetBar:SetMinMaxValues(0, duration)
			LoyaltyMendPetBarTexture:SetVertexColor(0.0, 1.0, 1.0, 1.0)
			value = expires - now
		end
		LoyaltyMendPetBar:SetValue(value)
		local start, duration, _ = GetSpellCooldown("Bestial Wrath")
		if start and start > 0 then
			LoyaltyBestialWrathBar:SetMinMaxValues(0, duration)
			LoyaltyBestialWrathBarText:SetTextColor(1.0, 0.0, 0.0, 1.0)
			value = (start + duration) - now
		else
			LoyaltyBestialWrathBarText:SetTextColor(0.0, 1.0, 0.0, 1.0)
			value = 0
		end
		LoyaltyBestialWrathBar:SetValue(value)
		start, duration, _ = GetSpellCooldown("Intimidation")
		if start and start > 0 then
			LoyaltyIntimidationBar:SetMinMaxValues(0, duration)
			LoyaltyIntimidationBarText:SetTextColor(1.0, 0.0, 0.0, 1.0)
			value = (start + duration) - now
		else
			LoyaltyIntimidationBarText:SetTextColor(0.0, 1.0, 0.0, 1.0)
			value = 0
		end
		LoyaltyIntimidationBar:SetValue(value)
		start, duration, _ = GetSpellCooldown("Master's Call")
		if start and start > 0 then
			LoyaltyMastersCallBar:SetMinMaxValues(0, duration)
			LoyaltyMastersCallBarText:SetTextColor(1.0, 0.0, 0.0, 1.0)
			value = (start + duration) - now
		else
			LoyaltyMastersCallBarText:SetTextColor(0.0, 1.0, 0.0, 1.0)
			value = 0
		end
		LoyaltyMastersCallBar:SetValue(value)
	else
		LoyaltyFrame:Hide();
	end
end

Loyalty:SetScript("OnUpdate", Loyalty.OnUpdate)
