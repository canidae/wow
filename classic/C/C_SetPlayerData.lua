function C_SetPlayerData(unit, elapsed)
	-- little method that help C_UpdatePlayerData
	local name = UnitName(unit);
	if (string.find(unit, "pet")) then
		-- pet
		if (unit == "pet") then
			name = UnitName("player") .. "-" .. name;
		else
			name = UnitName(string.gsub(unit, "pet", "")) .. "-" .. name;
		end
	end
	if (not C_player_data[name]) then
		C_player_data[name] = {
			["Buff"] = {},
			["Debuff"] = {}
		};
	end
	C_buff_texture_map = (C_buff_texture_map or {});
	C_debuff_texture_map = (C_debuff_texture_map or {});
	C_player_data[name]["CurrentTick"] = (C_player_data[name]["CurrentTick"] or 0) + 1;
	C_player_data[name]["UpdateTime"] = GetTime();
	for slot = 1, 16 do
		local bufftexture, buffamount = UnitBuff(unit, slot);
		local debufftexture, debuffamount = UnitDebuff(unit, slot);
		if (not bufftexture and not debufftexture) then
			-- no more buffs nor debuffs
			return;
		end
		if (bufftexture) then
			if (not C_player_data[name]["Buff"][bufftexture]) then
				-- new buff
				local buffname, bufftype, bufftext = C_GetBuffData(unit, slot);
				if (buffname) then
					C_buff_texture_map[buffname] = bufftexture;
					C_player_data[name]["Buff"][bufftexture] = {
						["Count"] = buffamount,
						["Name"] = buffname,
						["Text"] = string.gsub((bufftext or ""), ",", "."),
						["Tick"] = C_player_data[name]["CurrentTick"],
						["Time"] = elapsed,
						["Type"] = bufftype
					};
				end
			elseif (C_player_data[name]["Buff"][bufftexture]["Tick"] == C_player_data[name]["CurrentTick"] - 1 and buffamount == C_player_data[name]["Buff"][bufftexture]["Count"]) then
				-- known buff, update tick & time
				C_player_data[name]["Buff"][bufftexture]["Tick"] = C_player_data[name]["CurrentTick"];
				C_player_data[name]["Buff"][bufftexture]["Time"] = C_player_data[name]["Buff"][bufftexture]["Time"] + elapsed;
			else
				-- known buff, but it was gone and has been reapplied
				-- update name, text & type as well
				local buffname, bufftype, bufftext = C_GetBuffData(unit, slot);
				C_player_data[name]["Buff"][bufftexture]["Count"] = buffamount;
				C_player_data[name]["Buff"][bufftexture]["Name"] = buffname;
				C_player_data[name]["Buff"][bufftexture]["Text"] = string.gsub((bufftext or ""), ",", ".");
				C_player_data[name]["Buff"][bufftexture]["Tick"] = C_player_data[name]["CurrentTick"];
				C_player_data[name]["Buff"][bufftexture]["Time"] = elapsed;
				C_player_data[name]["Buff"][bufftexture]["Type"] = bufftype;
			end
		end
		if (debufftexture) then
			if (not C_player_data[name]["Debuff"][debufftexture]) then
				-- new debuff
				local debuffname, debufftype, debufftext = C_GetDebuffData(unit, slot);
				if (debuffname) then
					C_debuff_texture_map[debuffname] = debufftexture;
					C_player_data[name]["Debuff"][debufftexture] = {
						["Count"] = debuffamount,
						["Name"] = debuffname,
						["Text"] = string.gsub((debufftext or ""), ",", "."),
						["Tick"] = C_player_data[name]["CurrentTick"],
						["Time"] = elapsed,
						["Type"] = debufftype
					};
				end
			elseif (C_player_data[name]["Debuff"][debufftexture]["Tick"] == C_player_data[name]["CurrentTick"] - 1 and debuffamount == C_player_data[name]["Debuff"][debufftexture]["Count"]) then
				-- known debuff, update tick & time
				C_player_data[name]["Debuff"][debufftexture]["Tick"] = C_player_data[name]["CurrentTick"];
				C_player_data[name]["Debuff"][debufftexture]["Time"] = C_player_data[name]["Debuff"][debufftexture]["Time"] + elapsed;
			else
				-- known debuff, but it was gone and has been reapplied
				-- update name, text & type as well
				local debuffname, debufftype, debufftext = C_GetDebuffData(unit, slot);
				C_player_data[name]["Debuff"][debufftexture]["Count"] = debuffamount;
				C_player_data[name]["Debuff"][debufftexture]["Name"] = debuffname;
				C_player_data[name]["Debuff"][debufftexture]["Text"] = string.gsub((debufftext or ""), ",", ".");
				C_player_data[name]["Debuff"][debufftexture]["Tick"] = C_player_data[name]["CurrentTick"];
				C_player_data[name]["Debuff"][debufftexture]["Time"] = elapsed;
				C_player_data[name]["Debuff"][debufftexture]["Type"] = debufftype;
			end
		end
	end
end
