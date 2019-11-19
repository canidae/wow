function C_UnitHasDebuff(unit, debuff)
	-- figure out if this player has this debuff
	local debufftexture = C_debuff_texture_map[debuff];
	if (not debufftexture) then
		return;
	end
	local name = UnitName(unit);
	if (string.find(unit, "pet")) then
		-- pet
		if (unit == "pet") then
			name = UnitName("player") .. "-" .. name;
		else
			name = UnitName(string.gsub(unit, "pet", "")) .. "-" .. name;
		end
	end
	if (not C_player_data[name] or not C_player_data[name]["Debuff"][debufftexture]) then
		return;
	end
	if (C_player_data[name]["Debuff"][debufftexture]["Tick"] == C_player_data[name]["CurrentTick"] and C_player_data[name]["Debuff"][debufftexture]["Name"] == debuff) then
		return C_player_data[name]["Debuff"][debufftexture];
	end
end
