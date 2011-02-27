SmartTargeting = CreateFrame("Frame")

function SmartTargeting:OnEvent(event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "SmartTargeting" then
		SmartTargeting:UnregisterEvent("ADDON_LOADED")
		SmartTargeting:RegisterEvent("PLAYER_ENTERING_WORLD")
		SmartTargeting:RegisterEvent("UPDATE_WORLD_STATES")
		SmartTargeting:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		KeyBindingFrameOkayButton:HookScript("OnClick", SmartTargeting.UpdateKeyBindings)
		return
	elseif GetCurrentBindingSet() ~= 1 and GetCurrentBindingSet() ~= 2 then
		return
	elseif not smarttargeting_pve_tne and not smarttargeting_pve_tnep then
		SmartTargeting:UpdateKeyBindings()
	end
	local pvpzone = SmartTargeting:InPvpZone()
	local tne = (pvpzone and smarttargeting_pve_tnep) or (not pvpzone and smarttargeting_pve_tne)
	local tnep = (pvpzone and smarttargeting_pve_tne) or (not pvpzone and smarttargeting_pve_tnep)
	local ctne, ctnep = SmartTargeting:GetBindings()
	if (tne and ctne ~= tne) or (tnep and ctnep ~= tnep) then
		if not InCombatLockdown() and (not tne or SetBinding(tne, "TARGETNEARESTENEMY")) and (not tnep or SetBinding(tnep, "TARGETNEARESTENEMYPLAYER")) then
			if not smarttargeting_quiet then
				print("|cffc9a61b" .. (tnep or "<unbound>") .. "|r set to |cff00ccffenemy players|r, |cffc9a61b" .. (tne or "<unbound>") .. "|r set to |cff00ccffall enemies|r.")
			end
			SaveBindings(GetCurrentBindingSet())
			SmartTargeting:UnregisterEvent("PLAYER_REGEN_ENABLED")
		else
			SmartTargeting:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end
end

function SmartTargeting:UpdateKeyBindings()
	smarttargeting_pve_tne, smarttargeting_pve_tnep = SmartTargeting:GetBindings(SmartTargeting:InPvpZone())
	if not smarttargeting_quiet then
		print("|cff23e523Key bindings for targeting nearest enemy/enemy player saved.|r")
	end
end

function SmartTargeting:InPvpZone()
	local pvptype = GetZonePVPInfo()
	if pvptype == "arena" or pvptype == "combat" then
		return 1
	end
	local _, instancetype = IsInInstance()
	if instancetype == "pvp" then
		return 1
	end
end

function SmartTargeting:GetBindings(pvpzone)
	if pvpzone then
		return GetBindingKey("TARGETNEARESTENEMYPLAYER"), GetBindingKey("TARGETNEARESTENEMY")
	end
	return GetBindingKey("TARGETNEARESTENEMY"), GetBindingKey("TARGETNEARESTENEMYPLAYER")
end

SmartTargeting:SetScript("OnEvent", SmartTargeting.OnEvent)
SmartTargeting:RegisterEvent("ADDON_LOADED")
