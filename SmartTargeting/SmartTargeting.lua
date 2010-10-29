SmartTargeting = CreateFrame("Frame")

function SmartTargeting:OnEvent(event, ...)
	if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_REGEN_ENABLED" then
		local zonetype = SmartTargeting:GetZoneType()
		if zonetype ~= SmartTargeting.zonetype then
			-- went from pve zone to pvp zone or vice versa, swap keybindings
			local tnep = GetBindingKey("TARGETNEARESTENEMYPLAYER")
			local tne = GetBindingKey("TARGETNEARESTENEMY")
			if not InCombatLockdown() and (not tnep or SetBinding(tnep, "TARGETNEARESTENEMY")) and (not tne or SetBinding(tne, "TARGETNEARESTENEMYPLAYER")) then
				print("|cffc9a61b" .. (tne or "<unbound>") .. "|r set to |cff00ccffenemy players|r, |cffc9a61b" .. (tnep or "<unbound>") .. "|r set to |cff00ccffall enemies|r.")
				SaveBindings(GetCurrentBindingSet())
				-- remember that we swapped
				SmartTargeting.zonetype = zonetype
				-- and unregister event which we may have registered if we were unable to swap bindings earlier
				SmartTargeting:UnregisterEvent("PLAYER_REGEN_ENABLED")
			else
				-- updating failed, try again when we leave combat
				print("|cffe5462cFailed updating targeting bindings, retrying when you leave combat.|r")
				SmartTargeting:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		end
	end
end

function SmartTargeting:GetZoneType()
	local pvptype = GetZonePVPInfo()
	if pvptype == "arena" or pvptype == "combat" then
		return "pvp"
	end
	local ininstance, instancetype = IsInInstance()
	if instancetype == "pvp" then
		return "pvp"
	end
	return "pve"
end

SmartTargeting:SetScript("OnEvent", SmartTargeting.OnEvent)
SmartTargeting:RegisterEvent("ZONE_CHANGED_NEW_AREA")
SmartTargeting.zonetype = SmartTargeting:GetZoneType()
