function C_AKA(target)
	-- find another unit id than "target" or "mouseover"
	if (not target or not UnitExists(target)) then
		return target;
	end
	local players = GetNumRaidMembers();
	local por = "raid";
	if (players == 0) then
		players = GetNumPartyMembers();
		por = "party";
		if (UnitIsUnit(target, "player")) then
			return "player";
		end
		if (UnitExists("pet") and UnitIsUnit(target, "pet")) then
			return "pet";
		end
	end
	for a = 1, players do
		local unit = por .. a;
		if (UnitExists(unit)) then
			if (UnitIsUnit(target, unit)) then
				return unit;
			end
			unit = por .. "pet" .. a;
			if (UnitExists(unit) and UnitIsUnit(target, unit)) then
				return unit;
			end
		end
	end
	return target;
end
