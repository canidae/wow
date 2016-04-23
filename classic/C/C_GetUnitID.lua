function C_GetUnitID(name)
	-- find a unit with this name and return the unit id
	if (not name) then
		return;
	end
	C_player_map = (C_player_map or {});
	local unit = C_player_map[name];
	if (unit and UnitExists(unit)) then
		-- quick lookup
		if (UnitName(unit) == name) then
			-- it's a player
			return unit;
		elseif (unit == "pet" and UnitName("player") .. "-" .. UnitName("pet") == name) then
			-- it's the players pet
			return unit;
		elseif (string.find(unit, "pet") and UnitName(string.gsub(unit, "pet", "")) .. "-" .. UnitName(unit) == name) then
			-- it's someone's pet
			return unit;
		end
	end
	-- "slow" lookup (haven't seen this person before or unitid changed)
	local players = GetNumRaidMembers();
	local por = "raid";
	if (players == 0) then
		if (C_my_name == name) then
			C_player_map[name] = "player";
			return "player";
		end
		if (UnitExists("pet") and UnitName("player") .. "-" .. UnitName("pet") == name) then
			C_player_map[name] = "pet";
			return "pet";
		end
		players = GetNumPartyMembers();
		por = "party";
	end
	for a = 1, players do
		local unit = por .. a;
		local unitpet = por .. "pet" .. a;
		if (UnitExists(unit) and UnitName(unit) == name) then
			C_player_map[name] = unit;
			return unit;
		elseif (UnitExists(unitpet) and UnitName(unit) .. "-" .. UnitName(unitpet) == name) then
			C_player_map[name] = unitpet;
			return unitpet;
		end
	end
	if (UnitName("target") == name) then
		return "target";
	end
	if (UnitName("targettarget") == name) then
		return "targettarget";
	end
	if (UnitName("mouseover") == name) then
		return "mouseover";
	end
end
