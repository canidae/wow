function C_UpdatePlayerData(elapsed,unit)
	-- method that updates various data about the players in the
	-- party/raid. data such as buffs & debuffs
	-- the argument (elapsed) says how many seconds since last update
	-- if two or more addons call this function the same "update" only 1 may go thru
	elapsed = (elapsed or 0);
	if (not this) then
		elapsed = 0;
	end
	if (elapsed ~= 0 and this and C_last_update_player_data_caller and C_last_update_player_data_caller ~= this:GetName()) then
		-- another caller tries to update the time, can't allow that
		return;
	end
	local start = GetTime();
	C_player_data = (C_player_data or {});
	if (this and elapsed ~= 0) then
		C_last_update_player_data_caller = this:GetName();
	end
	
	if (unit) then
		-- Note: elapsed should be 0 if unit is set
		C_SetPlayerData(unit, 0);
		return;
	end

	local players = GetNumRaidMembers();
	local por = "raid";
	if (players == 0) then
		players = GetNumPartyMembers();
		por = "party";
		-- if we're alone or in a party we have to check "player" & "pet"
		C_SetPlayerData("player", elapsed);
		if (UnitExists("pet")) then
			C_SetPlayerData("pet", elapsed);
		end
	end
	if (UnitExists("target")) then
		C_SetPlayerData("target", elapsed);
	end
	if (UnitExists("targettarget")) then
		C_SetPlayerData("targettarget", elapsed);
	end
	if (UnitExists("mouseover")) then
		C_SetPlayerData("mouseover", elapsed);
	end
	for a = 1, players do
		local unit = por .. a;
		if (UnitExists(unit)) then
			C_SetPlayerData(unit, elapsed);
			unit = por .. "pet" .. a;
			if (UnitExists(unit)) then
				C_SetPlayerData(unit, elapsed);
			end
		end
	end
	if (elapsed > 0) then
		C_update_player_data_interval = (GetTime() - start) * 1000 / C_update_player_data_time;
		if (C_update_player_data_interval > 5) then
			-- in case of a "spike"
			C_update_player_data_interval = 5;
		end
	end
	return time;
end
