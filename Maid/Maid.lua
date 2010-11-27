Maid = CreateFrame("Frame")

function Maid:OnEvent(event, arg1, ...)
	if UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then
		return
	end
	if event == "ZONE_CHANGED_NEW_AREA" or event == "ACTIVE_TALENT_GROUP_CHANGED" or (event == "UNIT_FACTION" and arg1 == "player") or event == "PLAYER_REGEN_ENABLED" then
		local _, zone = IsInInstance() -- none, pvp, arena, party, raid
		if not zone or zone == "none" then
			zone = GetZonePVPInfo() or "pvp" -- arena, friendly, contested, hostile, sanctuary, combat, and make it "pvp" if nil is returned
		elseif zone == "pvp" then
			zone = "battleground" -- "pvp" is returned when we're in battleground, so change it to "battleground"
		end

		-- pve - pvp - sanctuary - friendly - contested - hostile - raid - party - combat - battleground - arena - <zone>
		if not (Maid:Dress(GetSubZoneText()) or Maid:Dress(GetZoneText()) or Maid:Dress(GetRealZoneText())) then
			while zone do
				if (UnitIsPVP("player") or zone ~= "pvp") and Maid:Dress(zone) then -- skip set "pvp" when we're not enabled for pvp
					break
				end
				zone = Maid.order[zone]
			end
		end
	end
end

function Maid:Dress(name)
	if  name then
		name = strsub(name, 1, 16)
		local specname = GetActiveTalentGroup() .. ":" .. strsub(name, 1, 14)
		return (GetEquipmentSetInfoByName(specname) and (Maid:Equip(specname) or 1)) or (GetEquipmentSetInfoByName(name) and (Maid:Equip(name) or 1))
	end
end

function Maid:Equip(set)
	if set ~= Maid.currentset then
		if not InCombatLockdown() then
			print(Maid.msg, "Putting on set |cffd2cb0b" .. set .. "|r")
			if not UseEquipmentSet(set) then
				print(Maid.msg, "|cffff0000Failed putting on set|r |cffd2cb0b" .. set .. "|r")
			else
				Maid.currentset = set
			end
			Maid:UnregisterEvent("PLAYER_REGEN_ENABLED")
		else
			print(Maid.msg, "Will put on set |cffd2cb0b" .. set .. "|r once you leave combat")
			Maid:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end
end

Maid.order = {
	["arena"] = "battleground",
	["battleground"] = "combat",
	["combat"] = "party",
	["party"] = "raid",
	["raid"] = "sanctuary",
	["sanctuary"] = "hostile",
	["hostile"] = "contested",
	["contested"] = "friendly",
	["friendly"] = "pvp",
	["pvp"] = "pve",
}
Maid.msg = "|cfff33bd7[Maid]|r"
Maid:SetScript("OnEvent", Maid.OnEvent)
Maid:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Maid:RegisterEvent("UNIT_FACTION")
Maid:RegisterEvent("ZONE_CHANGED_NEW_AREA")
