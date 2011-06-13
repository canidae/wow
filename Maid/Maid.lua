Maid = CreateFrame("Frame")

function Maid:OnEvent(event, arg1, ...)
	if UnitIsDeadOrGhost("player") or (event == "UNIT_FACTION" and arg1 ~= "player") then
		return
	end
	local _, zone = IsInInstance() -- none, pvp, arena, party, raid
	if not zone or zone == "none" then
		zone = GetZonePVPInfo() or "pvp" -- arena, friendly, contested, hostile, sanctuary, combat, and make it "pvp" if nil is returned
	elseif zone == "pvp" then
		zone = "battleground" -- "pvp" is returned when we're in battleground, so change it to "battleground"
	end
	-- pve - sanctuary - friendly - contested - hostile - raid - party - pvp - combat - battleground - arena - <zone>
	if UnitIsPVP("player") and zone ~= "arena" and zone ~= "battleground" and zone ~= "combat" then
		-- force "zone" to "pvp" if we're pvp toggled, but not in a combat zone, battleground or arena
		zone = "pvp"
	end

	if not (Maid:Dress(GetSubZoneText()) or Maid:Dress(GetZoneText()) or Maid:Dress(GetRealZoneText())) then
		while zone and not Maid:Dress(zone) do
			zone = Maid.order[zone]
		end
	end
end

function Maid:Dress(name)
	if name then
		local assigned = UnitGroupRolesAssigned("player")
		local role
		if assigned == "DAMAGER" then
			role = "d"
		elseif assigned == "HEALER" then
			role = "h"
		elseif assigned == "TANK" then
			role = "t"
		end
		name = strsub(name, 1, 16)
		local specname = GetActiveTalentGroup() .. ":" .. strsub(name, 1, 14)
		local specrolename = ""
		local rolename = ""
		if role then
			specrolename = GetActiveTalentGroup() .. ":" .. role .. ":" .. strsub(name, 1, 12)
			rolename = role .. ":" .. strsub(name, 1, 14)
		end
		return (GetEquipmentSetInfoByName(specrolename) and Maid:Equip(specrolename)) or (GetEquipmentSetInfoByName(rolename) and Maid:Equip(rolename)) or (GetEquipmentSetInfoByName(specname) and Maid:Equip(specname)) or (GetEquipmentSetInfoByName(name) and Maid:Equip(name))
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
	return 1
end

Maid.order = {
	["arena"] = "battleground",
	["battleground"] = "combat",
	["combat"] = "pvp",
	["pvp"] = "party",
	["party"] = "raid",
	["raid"] = "hostile",
	["hostile"] = "contested",
	["contested"] = "friendly",
	["friendly"] = "sanctuary",
	["sanctuary"] = "pve"
}
Maid.msg = "|cfff33bd7[Maid]|r"
Maid:SetScript("OnEvent", Maid.OnEvent)
Maid:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Maid:RegisterEvent("PLAYER_ROLES_ASSIGNED")
Maid:RegisterEvent("UNIT_FACTION")
Maid:RegisterEvent("ZONE_CHANGED_NEW_AREA")
