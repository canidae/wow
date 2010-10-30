SmartTargeting = CreateFrame("Frame")

function SmartTargeting:OnEvent(event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "SmartTargeting" then
		SmartTargeting:UnregisterEvent("ADDON_LOADED")
		SmartTargeting:RegisterEvent("UPDATE_BINDINGS")
		SmartTargeting:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	elseif event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_REGEN_ENABLED" then
		local pvpzone = SmartTargeting:GetZoneType() == "pvp"
		local tne = pvpzone and smarttargeting_pve_tnep or smarttargeting_pve_tne
		local tnep = pvpzone and smarttargeting_pve_tne or smarttargeting_pve_tnep
		local ctne, ctnep = SmartTargeting:GetBindings("pve")
		if ctne ~= tne or ctnep ~= tnep then
			SmartTargeting:UnregisterEvent("UPDATE_BINDINGS")
			if not InCombatLockdown() and (not tne or SetBinding(tne, "TARGETNEARESTENEMY")) and (not tnep or SetBinding(tnep, "TARGETNEARESTENEMYPLAYER")) then
				print("|cffc9a61b" .. (tnep or "<unbound>") .. "|r set to |cff00ccffenemy players|r, |cffc9a61b" .. (tne or "<unbound>") .. "|r set to |cff00ccffall enemies|r.")
				SaveBindings(GetCurrentBindingSet())
				SmartTargeting:UnregisterEvent("PLAYER_REGEN_ENABLED")
			else
				print("|cffe5462cFailed updating targeting bindings, retrying when you leave combat.|r")
				SmartTargeting:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
			SmartTargeting:RegisterEvent("UPDATE_BINDINGS")
		end
	end
	if event == "UPDATE_BINDINGS" or (event == "ADDON_LOADED" and arg1 == "SmartTargeting" and not smarttargeting_pve_tne and not smarttargeting_pve_tnep) then
		smarttargeting_pve_tne, smarttargeting_pve_tnep = SmartTargeting:GetBindings(SmartTargeting:GetZoneType())
	end
end

function SmartTargeting:GetZoneType()
	local pvptype = GetZonePVPInfo()
	if pvptype == "arena" or pvptype == "combat" then
		return "pvp"
	end
	local _, instancetype = IsInInstance()
	if instancetype == "pvp" then
		return "pvp"
	end
	return "pve"
end

function SmartTargeting:GetBindings(zonetype)
	if zonetype == "pvp" then
		return GetBindingKey("TARGETNEARESTENEMYPLAYER"), GetBindingKey("TARGETNEARESTENEMY")
	end
	return GetBindingKey("TARGETNEARESTENEMY"), GetBindingKey("TARGETNEARESTENEMYPLAYER")
end

SmartTargeting:SetScript("OnEvent", SmartTargeting.OnEvent)
SmartTargeting:RegisterEvent("ADDON_LOADED")
