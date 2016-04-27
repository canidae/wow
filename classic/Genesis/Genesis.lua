for index, value in Genesis_blessing_of_light_text do
	Genesis_blessing_of_light_search = (Genesis_blessing_of_light_search or "[^%d]+") .. "(%d+%.?%d*)[^%d]+";
end
Genesis_bonus_divide = 3.5;
Genesis_bonus_instant_divide = 15;
Genesis_buff_affect_healing_search = {};
for buff, data in Genesis_buff_affect_healing_text do
	for index, value in data do
		Genesis_buff_affect_healing_search[buff] = (Genesis_buff_affect_healing_search[buff] or "[^%d]+") .. "(%d+%.?%d*)[^%d]+";
	end
end
Genesis_buff_unable_to_heal = {
	[C_Divine_intervention] = 1,
	[C_Phase_shift] = 1
};
Genesis_class_hp_per_level = {
	[C_Druid] = 60,
	[C_Hunter] = 65,
	[C_Mage] = 50,
	[C_Paladin] = 70,
	[C_Priest] = 50,
	[C_Rogue] = 65,
	[C_Shaman] = 70,
	[C_Warlock] = 65,
	[C_Warrior] = 90
};
Genesis_critical_bonus = 1.5;
Genesis_debuff_affect_healing_search = {};
for debuff, data in Genesis_debuff_affect_healing_text do
	for index, value in data do
		Genesis_debuff_affect_healing_search[debuff] = (Genesis_debuff_affect_healing_search[debuff] or "[^%d]+") .. "(%d+%.?%d*)[^%d]+";
	end
end
Genesis_debuff_unable_to_heal = {
	[C_Banish] = 1,
	[C_Deep_slumber] = 1
};
Genesis_dont_scale = {
	[C_Holy_nova] = 1,
	[C_Power_word_shield] = 1,
	[C_Prayer_of_healing] = 1,
	[C_Tranquility] = 1
};
Genesis_error_moving = {
	[SPELL_FAILED_MOVING] = 1
}
Genesis_error_unable = {
	[SPELL_FAILED_CASTER_DEAD] = 1,
	[SPELL_FAILED_CONFUSED] = 1,
	[SPELL_FAILED_FLEEING] = 1,
	[SPELL_FAILED_NOT_IN_CONTROL] = 1,
	[SPELL_FAILED_NOT_MOUNTED] = 1,
	[SPELL_FAILED_NOT_STANDING] = 1,
	[SPELL_FAILED_PACIFIED] = 1,
	[SPELL_FAILED_POSSESSED] = 1,
	[SPELL_FAILED_SILENCED] = 1,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = 1,
	[SPELL_FAILED_STUNNED] = 1,
	[SPELL_FAILED_TARGETS_DEAD] = 1
}
Genesis_heal_spells_search = {};
for spell, data in Genesis_heal_spells_text do
	for index, value in data do
		Genesis_heal_spells_search[spell] = (Genesis_heal_spells_search[spell] or "[^%d]+") .. "(%d+%.?%d*)[^%d]+";
	end
end
Genesis_hot_duration = {
	[C_Crystal_restore] = 15,
	[C_First_aid] = 8,
	[C_Greater_heal] = 15,
	[C_Lightwell] = 10,
	[C_Regrowth] = 21,
	[C_Rejuvenation] = 12,
	[C_Renew] = 15
};
for index, value in Genesis_hot_text do
	Genesis_hot_search = (Genesis_hot_search or "[^%d]+") .. " (%d+%.?%d*)[^%d]+";
end
Genesis_my_buff_affect_healing_search = {};
for buff, data in Genesis_my_buff_affect_healing_text do
	for index, value in data do
		Genesis_my_buff_affect_healing_search[buff] = (Genesis_my_buff_affect_healing_search[buff] or "[^%d]+") .. "(%d+%.?%d*)[^%d]+";
	end
end
Genesis_spell_level = {
	[C_Blessing_of_protection] = {0, 14, 28},
	[C_Power_word_shield] = {-4, 2, 8, 14, 20, 26, 32, 38, 44, 50},
	[C_Regrowth] = {2, 8, 14, 20, 26, 32, 38, 44, 50},
	[C_Rejuvenation] = {-6, 0, 6, 12, 18, 24, 30, 36, 42, 48, 50},
	[C_Renew] = {-2, 4, 10, 16, 22, 28, 34, 40, 46, 50}
};
Genesis_low_level_spell_bonus_penalty = {
	[C_Heal] = {0.0375*16+0.25},
	[C_Healing_touch] = {0.0375*1+0.25, 0.0375*8+0.25, 0.0375*14+0.25},
	[C_Healing_wave] = {0.0375*1+0.25, 0.0375*6+0.25, 0.0375*12+0.25, 0.0375*18+0.25},
	[C_Holy_light] = {0.0375*1+0.25, 0.0375*6+0.25, 0.0375*14+0.25},
	[C_Lesser_heal] = {0.0375*1+0.25, 0.0375*4+0.25, 0.0375*10+0.25},
	[C_Regrowth] = {0.0375*12+0.25, 0.0375*18+0.25},
	[C_Rejuvenation] = {0.0375*4+0.25, 0.0375*10+0.25, 0.0375*16+0.25},
	[C_Renew] = {0.0375*8+0.25, 0.0375*14+0.25}
};
Genesis_supported_classes = {
	[C_Druid] = 1,
	[C_Paladin] = 1,
	[C_Priest] = 1,
	[C_Shaman] = 1
};

function Genesis_ActionHeal(spell, rank)
	if (Genesis_casting_spell) then
		if (Genesis_data["safe_cancel"] == 0 or Genesis_GetOverheal() > Genesis_data["max_overheal"]) then
			SpellStopCasting();
		end
		return 1;
	end
	if (Genesis_IsHealModifierKeyDown("heal_self_modifier") or Genesis_IsHealModifierKeyDown("heal_targettarget_modifier") or (UnitExists("target") and UnitIsFriend("player", "target"))) then
		-- seems like we want to heal this person
		local unit = C_AKA("target");
		if (Genesis_IsHealModifierKeyDown("heal_self_modifier")) then
			unit = "player";
		elseif (Genesis_IsHealModifierKeyDown("heal_targettarget_modifier") and UnitExists("target")) then
			-- heal "targettarget"
			if (not UnitExists("targettarget") or not Genesis_CanHeal("targettarget")) then
				-- unable to heal targettarget, make sure we don't heal "target"
				return 1;
			end
			unit = C_AKA("targettarget");
		end
		if (not rank) then
			-- we were given a class instead of a spell
			Genesis_HealUsingClass(unit, spell);
		else
			Genesis_Heal(unit, spell, rank);
		end
		return 1;
	elseif (Genesis_data["useaction_heal_most_wounded"] == 1 and (not UnitExists("target") or not UnitIsFriend("player", "target"))) then
		-- hostile target or no target & healing spell: heal most wounded
		Genesis_HealMostWounded(spell, rank);
		-- we should never call the original UseAction if we've hooked this spell
		return 1;
	end
	return;
end

function Genesis_CanHeal(unit)
	-- see if we can heal this unit
	if (not UnitExists(unit) or UnitIsDeadOrGhost(unit) or not UnitIsFriend("player", unit) or not UnitIsVisible(unit)) then
		return;
	end
	for buff, one in Genesis_buff_unable_to_heal do
		if (C_UnitGotBuff(unit, buff)) then
			return;
		end
	end
	for debuff, one in Genesis_debuff_unable_to_heal do
		if (C_UnitGotDebuff(unit, debuff)) then
			return;
		end
	end
	return 1;
end

function Genesis_ClassDropDownMenuButton_OnClick()
	local class = this:GetText();
	Genesis_ClassDropDownMenuUpdate(class);
end

function Genesis_ClassDropDownMenuInitialize()
	if (not Genesis_spells) then
		Genesis_UpdateSpells();
	end
	local info;
	if (not Genesis_data["classes"]) then
		Genesis_data["classes"] = {};
	end
	local classes = 0;
	for class, data in Genesis_data["classes"] do
		classes = classes + 1;
	end
	if (classes == 0) then
		Genesis_data["classes"]["default"] = {};
	end
	local show;
	for class, data in Genesis_data["classes"] do
		info = {
			["text"] = class,
			["func"] = Genesis_ClassDropDownMenuButton_OnClick
		};
		UIDropDownMenu_AddButton(info);
		if (not show) then
			show = class;
		end
	end
	Genesis_ClassDropDownMenuUpdate(Genesis_current_class or show);
end

function Genesis_ClassDropDownMenuUpdate(class)
	Genesis_current_class = class;
	local counter = 1;
	UIDropDownMenu_SetSelectedName(Genesis_GUIClassDropDownMenu, class);
	counter = 1;
	local sorted = {};
	for spell, data in Genesis_data["classes"][class] do
		if (Genesis_spells and Genesis_spells[spell]) then
			sorted[counter] = data["Percent"];
			counter = counter + 1;
		end
	end
	table.sort(sorted, function(a, b) return a > b; end);
	local taken = {};
	for spell, data in Genesis_data["classes"][class] do
		if (Genesis_spells and Genesis_spells[spell]) then
			local slot = 1;
			for a = 1, counter do
				if (data["Percent"] == sorted[a] and not taken[a]) then
					slot = a;
					taken[a] = 1;
					a = counter;
				end
			end
			getglobal("Genesis_GUIClass" .. slot):Hide();
			getglobal("Genesis_GUIClass" .. slot .. "SpellTexture"):SetTexture(Genesis_spells[spell]["Texture"]);
			getglobal("Genesis_GUIClass" .. slot .. "SpellText"):SetText(spell);
			getglobal("Genesis_GUIClass" .. slot):Show();
			getglobal("Genesis_GUIClass" .. slot .. "RankSlider"):SetMinMaxValues(0, table.getn(Genesis_spells[spell]));
			getglobal("Genesis_GUIClass" .. slot .. "RankSlider"):SetValue(data["Rank"]);
			getglobal("Genesis_GUIClass" .. slot .. "PercentSlider"):SetValue(data["Percent"]);
		end
	end
	for counter = counter, 7 do
		getglobal("Genesis_GUIClass" .. counter):Hide();
	end
end

function Genesis_Command(msg)
	if (not msg or msg == "") then
		-- show/hide gui
		if (Genesis_GUI:IsShown()) then
			Genesis_GUI:Hide();
		else
			Genesis_GUI:Show();
		end
		return;
	end
	msg = string.lower(msg);
	if (string.find(msg, "^save")) then
		-- save our settings
		local start, stop, profile = string.find(msg, "^save (.+)$");
		if (not profile) then
			C_Print("You'll have to specify the name of the profile you want to save your settings to.");
			return;
		end
		Genesis_Save(profile);
		C_Print("Settings saved as profile \"" .. profile .. "\".");
	elseif (string.find(msg, "^load")) then
		-- load our settings
		local start, stop, profile = string.find(msg, "^load (.+)$");
		if (not profile) then
			C_Print("You'll have to specify which profile to load settings from.");
			return;
		end
		if (not Genesis_profiles[profile]) then
			C_Print("Couldn't find profile \"" .. profile .. "\"", "|cffff0000");
			return;
		end
		Genesis_Load(profile);
		C_Print("Profile \"" .. profile .. "\" loaded.");
	elseif (string.find(msg, "^delete")) then
		-- delete a saved profile
		local start, stop, profile = string.find(msg, "^delete (.+)$");
		if (not profile) then
			C_Print("You'll have to specify which profile to delete.");
			return;
		end
		if (not Genesis_profiles[profile]) then
			C_Print("Couldn't find profile \"" .. profile .. "\"", "|cffff0000");
			return;
		end
		Genesis_profiles[profile] = nil;
		C_Print("Profile \"" .. profile .. "\" deleted.");
	elseif (msg == "list") then
		-- list our profiles
		C_Print("Saved profiles:");
		local found;
		for profile, data in Genesis_profiles do
			C_Print(profile);
			found = 1;
		end
		if (not found) then
			C_Print("No saved profiles");
		end
	elseif (msg == "help") then
		-- show help
		C_Print("Usage:");
		C_Print("/genesis save <profile>|cffffffff - save current settings to <profile>");
		C_Print("/genesis load <profile>|cffffffff - load settings from <profile>");
		C_Print("/genesis list|cffffffff - list all saved profiles");
		C_Print("/genesis delete <profile>|cffffffff - delete <profile>");
	else
		-- possibly healing using a class
		Genesis_ActionHeal(msg, nil);
	end
end

function Genesis_DropSpell()
	if (not Genesis_pickup_spellid or not Genesis_pickup_spellbook or not Genesis_current_class or not CursorHasSpell()) then
		return;
	end
	local spell, rank = GetSpellName(Genesis_pickup_spellid, Genesis_pickup_spellbook);
	if (not Genesis_spells) then
		Genesis_UpdateSpells();
	end
	if (not Genesis_player_heal_spells[spell] or Genesis_data["classes"][Genesis_current_class][spell]) then
		return;
	end
	start, stop, rank = string.find((rank or ""), "(%d+)");
	rank = (rank or 1) / 1.0;
	for counter = 1, 7 do
		if (not getglobal("Genesis_GUIClass" .. counter):IsShown()) then
			Genesis_data["classes"][Genesis_current_class][spell] = {
				["Rank"] = rank,
				["Percent"] = (Genesis_pickup_percent or 0.5)
			};
			getglobal("Genesis_GUIClass" .. counter .. "SpellTexture"):SetTexture(GetSpellTexture(Genesis_pickup_spellid, Genesis_pickup_spellbook));
			getglobal("Genesis_GUIClass" .. counter .. "SpellText"):SetText(spell);
			getglobal("Genesis_GUIClass" .. counter):Show();
			getglobal("Genesis_GUIClass" .. counter .. "RankSlider"):SetMinMaxValues(0, table.getn(Genesis_spells[spell]));
			getglobal("Genesis_GUIClass" .. counter .. "RankSlider"):SetValue(0);
			PickupSpell(Genesis_pickup_spellid, Genesis_pickup_spellbook);
			return 1;
		end
	end
end

function Genesis_GetActionSpell(slot)
	C_TooltipTextLeft1:SetText();
	C_TooltipTextRight1:SetText();
	C_Tooltip:SetAction(slot);
	local start, stop, name, rank;
	name = C_TooltipTextLeft1:GetText();
	rank = C_TooltipTextRight1:GetText();
	start, stop, rank = string.find((rank or ""), "(%d+)");
	rank = (rank or 1) / 1.0;
	return (name or ""), rank;
end

function Genesis_GetHealBonus(unit, spell, rank)
	-- check how much extra healing we'll get thanks to buffs on our target
	local healbonus = 0;
	Genesis_generic_table = (Genesis_generic_table or {});
	Genesis_generic_table2 = (Genesis_generic_table2 or {});
	Genesis_generic_table2[spell] = 0;
	Genesis_generic_table2["HealUp"] = 0;
	Genesis_generic_table2["HealDown"] = 0;
	if (spell == C_Flash_of_light or spell == C_Holy_light) then
		local data = C_UnitGotBuff(unit, C_Blessing_of_light);
		data = (data or C_UnitGotBuff(unit, C_Greater_blessing_of_light));
		if (data and data["Text"]) then
			local start, stop;
			start, stop, Genesis_generic_table[1], Genesis_generic_table[2] = string.find(data["Text"], Genesis_blessing_of_light_search);
			if (start) then
				for index, value in Genesis_blessing_of_light_text do
					Genesis_generic_table2[value] = (Genesis_generic_table2[value] or 0) + Genesis_generic_table[index] * (Genesis_bonus_divide / Genesis_spells[spell][rank]["CastTime"]);
				end
			end
		end
	end
	for buff, search in Genesis_buff_affect_healing_search do
		local data = C_UnitGotBuff(unit, buff);
		if (data and data["Text"]) then
			local start, stop;
			start, stop, Genesis_generic_table[1], Genesis_generic_table[2] = string.find(data["Text"], search);
			if (start) then
				for index, value in Genesis_buff_affect_healing_text[buff] do
					Genesis_generic_table2[value] = (Genesis_generic_table2[value] or 0) + (Genesis_generic_table[index] or 0);
				end
			end
		end
	end
	for debuff, search in Genesis_debuff_affect_healing_search do
		local data = C_UnitGotDebuff(unit, debuff);
		if (data and data["Text"]) then
			local start, stop;
			start, stop, Genesis_generic_table[1], Genesis_generic_table[2] = string.find(data["Text"], search);
			if (start) then
				for index, value in Genesis_debuff_affect_healing_text[debuff] do
					Genesis_generic_table2[value] = (Genesis_generic_table2[value] or 0) + (Genesis_generic_table[index] or 0);
				end
			end
		end
	end
	for buff, search in Genesis_my_buff_affect_healing_search do
		local data = C_UnitGotBuff("player", buff);
		if (data and data["Text"]) then
			local start, stop;
			start, stop, Genesis_generic_table[1], Genesis_generic_table[2] = string.find(data["Text"], search);
			if (start) then
				for index, value in Genesis_my_buff_affect_healing_text[buff] do
					Genesis_generic_table2[value] = (Genesis_generic_table2[value] or 0) + (Genesis_generic_table[index] or 0);
				end
			end
		end
	end
	healbonus = healbonus + (Genesis_generic_table2[spell] or 0);
	healbonus = healbonus + (Genesis_generic_table2["HealUp"] or 0);
	healbonus = healbonus - (Genesis_generic_table2["HealDown"] or 0);
	-- and the bonus from the equipment
	if (not Genesis_item_heal_bonus) then
		Genesis_UpdateItemHealBonus();
	end
	healbonus = healbonus + Genesis_item_heal_bonus;
	-- if we're a priest & got "spiritual guidance"
	if (C_my_class == C_Priest) then
		local crap1, crap2, crap3, crap4, crank, mrank = GetTalentInfo(2, 14);
		local base, cur = UnitStat("player", 5);
		healbonus = healbonus + crank * 0.05 * cur;
	end
	if (Genesis_low_level_spell_bonus_penalty[spell] and Genesis_low_level_spell_bonus_penalty[spell][rank]) then
		-- low level spell, gets a bonus penalty
		healbonus = healbonus * Genesis_low_level_spell_bonus_penalty[spell][rank];
	end
	return healbonus;
end

function Genesis_GetHealingOverTime(unit)
	-- check how much hot this player will receive
	local hot = 0;
	Genesis_generic_table = (Genesis_generic_table or {});
	Genesis_generic_table2 = (Genesis_generic_table2 or {});
	for buff, duration in Genesis_hot_duration do
		local data = C_UnitGotBuff(unit, buff);
		if (data and data["Text"]) then
			local start, stop;
			start, stop, Genesis_generic_table[1], Genesis_generic_table[2] = string.find(data["Text"], Genesis_hot_search);
			if (start) then
				Genesis_generic_table2["Heal"] = nil;
				Genesis_generic_table2["Interval"] = nil;
				for index, value in Genesis_hot_text do
					Genesis_generic_table2[value] = (Genesis_generic_table2[value] or 0) + Genesis_generic_table[index];
				end
				if (Genesis_generic_table2["Heal"] and Genesis_generic_table2["Interval"]) then
					local timeleft = duration - data["Time"];
					if (timeleft > 0) then
						hot = hot + (timeleft * Genesis_generic_table2["Heal"] / Genesis_generic_table2["Interval"]);
					end
				end
			end
		end
	end
	local hot_multiply = Genesis_data["hot_multiply"];
	if (C_player_in_battle) then
		hot_multiply = Genesis_data["hot_multiply_battle"];
	end
	hot = hot * hot_multiply;
	return hot;
end

function Genesis_GetHealValue(unit)
	-- figure out how much healing this unit should get
	local hpmissing = UnitHealthMax(unit) - UnitHealth(unit);
	if (UnitHealthMax(unit) == 100) then
		-- looks like we don't know this players hp
		hpmissing = hpmissing * UnitLevel(unit) * Genesis_class_hp_per_level[UnitClass(unit)] / 100;
	end
	local hot = Genesis_GetHealingOverTime(unit);
	local other = Genesis_GetOtherHealing(unit);
	return hpmissing - other - hot;
end

function Genesis_GetOtherHealing(unit, maxtimeleft)
	-- fetch how much other healers are healing this unit
	local healing = 0;
	local name = UnitName(unit);
	if (string.find(unit, "pet")) then
		-- pet
		if (unit == "pet") then
			name = UnitName("player") .. "-" .. name;
		else
			name = UnitName(string.gsub(unit, "pet", "")) .. "-" .. name;
		end
	end
	maxtimeleft = (maxtimeleft or 666);
	local hot_multiply = Genesis_data["hot_multiply"];
	if (C_player_in_battle) then
		hot_multiply = Genesis_data["hot_multiply_battle"];
	end
	if (Genesis_healing[name]) then
		for healer, data in Genesis_healing[name] do
			if (healer ~= C_my_name and Genesis_healing[name][healer]["Status"] == "Active" and Genesis_healing[name][healer]["TimeLeft"] < maxtimeleft) then
				healing = healing + Genesis_healing[name][healer]["Heal"];
				healing = healing + Genesis_healing[name][healer]["HealingOverTime"] * hot_multiply;
			end
		end
	end
	return healing;
end

function Genesis_GetOverheal()
	-- return how much overhealing we're about to do
	local giah = Genesis_i_am_healing;
	if (not giah or not Genesis_healing[giah] or not Genesis_healing[giah][C_my_name]) then
		return 0;
	end
	local unit = C_GetUnitID(giah);
	if (not unit) then
		-- uhm, this is weird
		return 0;
	end
	local uhm = UnitHealthMax(unit);
	local uh = UnitHealth(unit);
	if (uhm == 100) then
		-- probably percent instead of hp
		uhm = uhm * UnitLevel(unit) * Genesis_class_hp_per_level[UnitClass(unit)] / 100;
		uh = uh * UnitLevel(unit) * Genesis_class_hp_per_level[UnitClass(unit)] / 100;
	end
	-- and how much hot the player will receive from hots and other healers when tankhealing
	if (not Genesis_healing[giah][C_my_name]["TankHealing"]) then
		if (uh / uhm > Genesis_data["hot_heal_threshold"]) then
			uh = uh + Genesis_GetHealingOverTime(unit);
		end
		uh = uh + Genesis_GetOtherHealing(unit, Genesis_healing[giah][C_my_name]["TimeLeft"]);
	end
	-- then see how much i heal
	local hot_multiply = Genesis_data["hot_multiply"];
	if (C_player_in_combat) then
		hot_multiply = Genesis_data["hot_multiply_battle"];
	end
	local heal = Genesis_healing[giah][C_my_name]["Heal"] + Genesis_healing[giah][C_my_name]["HealingOverTime"] * hot_multiply;
	if (heal == 0) then
		return 0;
	end
	local overheal = uh + heal - uhm;
	if (overheal < 0) then
		overheal = 0;
	end
	local overhealpercent = overheal / heal;
	if (overhealpercent > 1) then
		-- due to hots & others healing it's possible to get more than 100% overhealing :o
		overhealpercent = 1;
	end
	return overhealpercent, overheal;
end

function Genesis_GetPriority(unit)
	-- get what priority this unit got
	local priority = 1;
	if (not Genesis_RaidUnitIsChecked(unit)) then
		-- we're in a raid and this unit is not checked for healing
		-- set priority to the "unchecked priority"
		priority = priority * Genesis_data["unchecked_priority"];
		-- we still want to apply the other priorities
	end
	if (UnitIsUnit("player", unit)) then
		-- me!
		priority = priority * Genesis_data["player_priority"];
	elseif (UnitInParty(unit) and not string.find(unit, "pet")) then
		-- someone in my party
		priority = priority * Genesis_data["party_priority"];
	elseif (UnitInRaid(unit)) then
		-- someone in my raid
		priority = priority * Genesis_data["raid_priority"];
	else
		-- a pet(?)
		priority = priority * Genesis_data["pet_priority"];
	end
	if (not UnitIsUnit("player", unit)) then
		if (Genesis_data["shapeshifted_druids"] == 1 and UnitClass(unit) == C_Druid) then
			if (UnitPowerType(unit) == 0) then
				-- caster form
				priority = priority * Genesis_data["class_priority"][C_Druid];
			elseif (UnitPowerType(unit) == 1) then
				-- bear form
				priority = priority * Genesis_data["class_priority"][C_Warrior];
			else
				-- hopefully cat form
				priority = priority * Genesis_data["class_priority"][C_Rogue];
			end
		else
			priority = priority * Genesis_data["class_priority"][UnitClass(unit)];
		end
	end
	if (priority <= 0) then
		return 0;
	end
	for buff, prioritychange in Genesis_data["buff_affect_priority"] do
		if (C_UnitGotBuff(unit, buff)) then
			priority = priority - prioritychange;
		end
	end
	for debuff, prioritychange in Genesis_data["debuff_affect_priority"] do
		if (C_UnitGotDebuff(unit, debuff)) then
			priority = priority + prioritychange;
		end
	end
	return priority;
end

function Genesis_GetSpellHealing(unit, spell, rank)
	-- figure out how much this spell will heal
	if (not Genesis_spells) then
		Genesis_UpdateSpells();
	end
	local healbonus = Genesis_GetHealBonus(unit, spell, rank);
	if (spell == C_Regrowth) then
		-- regrowth got the healbonus splitted 50/50 on the direct heal & hot
		healbonus = healbonus / 2;
	end
	if (spell == C_Swiftmend) then
		-- swiftmend is quite unique
		-- if a player got rejuvenation, it eats that one up
		local data = C_UnitGotBuff(unit, C_Rejuvenation);
		if (data) then
			local start, stop;
			Genesis_generic_table = (Genesis_generic_table or {});
			Genesis_generic_table2 = (Genesis_generic_table2 or {});
			start, stop, Genesis_generic_table[1], Genesis_generic_table[2] = string.find(data["Text"], Genesis_hot_search);
			for index, value in Genesis_hot_text do
				Genesis_generic_table2 = (Genesis_generic_table2 or {});
				Genesis_generic_table2[value] = Genesis_generic_table[index] / 1.0;
			end
			local heal = Genesis_generic_table2["Heal"] * 5 + healbonus * 12 / Genesis_bonus_instant_divide;
			return heal, heal, heal, 0;
		end
		data = C_UnitGotBuff(unit, C_Regrowth);
		-- if no reju then it eats regrowth if it's on the player
		if (data) then
			local start, stop;
			Genesis_generic_table = (Genesis_generic_table or {});
			Genesis_generic_table2 = (Genesis_generic_table2 or {});
			start, stop, Genesis_generic_table[1], Genesis_generic_table[2] = string.find(data["Text"], Genesis_hot_search);
			for index, value in Genesis_hot_text do
				Genesis_generic_table2 = (Genesis_generic_table2 or {});
				Genesis_generic_table2[value] = Genesis_generic_table[index] / 1.0;
			end
			local heal = Genesis_generic_table2["Heal"] * 6 + healbonus * 15 / Genesis_bonus_instant_divide;
			return heal, heal, heal, 0;
		end
	end
	local heal = (Genesis_spells[spell][rank]["Heal"] or 0);
	local healmin = (Genesis_spells[spell][rank]["HealMin"] or 0);
	local healmax = (Genesis_spells[spell][rank]["HealMax"] or 0);
	local hot = (Genesis_spells[spell][rank]["HealingOverTime"] or 0);
	local realcasttime = (Genesis_spells[spell][rank]["RealCastTime"] or 0);
	if (realcasttime > Genesis_bonus_divide) then
		realcasttime = Genesis_bonus_divide;
	end
	local bonus = healbonus * realcasttime / Genesis_bonus_divide;
	if (C_player_in_battle) then
		heal = heal + healmin;
	else
		heal = heal + healmax;
	end
	heal = heal + bonus;
	healmin = healmin + bonus;
	healmax = healmax + bonus;
	local hot_multiply = Genesis_data["hot_multiply"];
	if (C_player_in_combat) then
		hot_multiply = Genesis_data["hot_multiply_battle"];
	end
	hot = hot * hot_multiply;
	if (hot > 0) then
		local duration = (Genesis_hot_duration[spell] or 0);
		if (duration > Genesis_bonus_instant_divide) then
			duration = Genesis_bonus_instant_divide;
		end
		hot = hot + healbonus * Genesis_hot_duration[spell] / Genesis_bonus_instant_divide;
	end
	heal = heal + hot;
	if (C_my_class == C_Paladin and (spell == C_Flash_of_light or spell == C_Holy_light) and C_UnitGotBuff("player", C_Divine_favor)) then
		-- 100% crit chance
		heal = heal * Genesis_critical_bonus;
		healmin = healmin * Genesis_critical_bonus;
		healmax = healmax * Genesis_critical_bonus;
	end
	if (C_UnitGotBuff("player", C_Power_infusion)) then
		heal = heal * 1.2;
		healmin = healmin * 1.2;
		healmax = healmax * 1.2;
		hot = hot * 1.2;
	end
	if (C_UnitGotDebuff(unit, C_Mortal_strike)) then
		-- target got mortal strike debuff, ouch
		heal = heal * 0.5;
		healmin = healmin * 0.5;
		healmax = healmax * 0.5;
		hot = hot * 0.5;
	end
	return heal, healmin, healmax, hot;
end

function Genesis_Heal(unit, spell, rank, healvalue)
	-- heal the specified unit with the given spell & rank (scale down if necessary)
	if (not unit or not spell or not rank or not UnitExists(unit)) then
		return;
	end
	if (Genesis_casting_spell) then
		if (Genesis_data["safe_cancel"] == 0 or Genesis_GetOverheal() > Genesis_data["max_overheal"]) then
			SpellStopCasting();
		end
		return 1;
	end
	if (not Genesis_spells) then
		Genesis_UpdateSpells();
	end
	if (not Genesis_spells[spell]) then
		return;
	end
	if (rank == 0) then
		rank = table.getn(Genesis_spells[spell]);
	end
	if (not Genesis_spells[spell][rank]) then
		return;
	end
	if (GetSpellCooldown(Genesis_spells[spell][rank]["ID"], BOOKTYPE_SPELL) > 0) then
		-- cooldown
		return;
	end
	C_UpdatePlayerData();
	if (not Genesis_CanHeal(unit)) then
		return;
	end
	if (spell == C_Power_word_shield and C_UnitGotDebuff(unit, C_Weakened_soul)) then
		-- casting shield on someone with weakened soul, can't allow that
		return;
	end
	if ((spell == C_Divine_shield or spell == C_Divine_protection or spell == C_Blessing_of_protection) and C_UnitGotDebuff(unit, C_Forbearance)) then
		-- casting paladin shield on someone who got forbearance
		return;
	end
	if (((spell ~= C_Greater_heal and ((spell ~= C_Regrowth and spell ~= C_Power_word_shield) or healvalue) and C_UnitGotBuff(unit, spell)) or (spell == C_Power_word_shield and C_UnitGotBuff(unit, C_Ice_barrier))) and (UnitHealth(unit) / UnitHealthMax(unit) > Genesis_data["hot_heal_threshold"] or spell == C_Renew or spell == C_Rejuvenation)) then
		-- casting rejuvenation/renew on someone who already got it, return
		-- will also return if we're not target healing and trying to cast regrowth on someone who got the regrowth buff
		-- like regrowth, you may cast a new shield on someone who already got the shield if you're target healing
		-- if we're trying to shield a mage with ice barrier then also return here
		return;
	end
	if (spell == C_Swiftmend and not (C_UnitGotBuff(unit, C_Regrowth) or C_UnitGotBuff(unit, C_Rejuvenation))) then
		-- trying to cast swiftmend on someone who don't have regrowth/rejuvenation, return
		return;
	end
	if ((C_my_class == C_Druid and C_UnitGotBuff("player", C_Clearcasting)) or (C_my_class == C_Priest and C_UnitGotBuff("player", C_Inner_focus))) then
		-- clearcasting/inner focus, use highest rank
		rank = table.getn(Genesis_spells[spell]);
	else
		while (rank > 0 and Genesis_spells[spell][rank]["Mana"] > UnitMana("player")) do
			-- not enough mana, scale down
			rank = rank - 1;
		end
	end
	while (Genesis_spell_level[spell] and rank > 0 and UnitLevel(unit) < Genesis_spell_level[spell][rank]) do
		-- unit is too low level, scale down
		rank = rank - 1;
	end
	if (rank == 0) then
		-- not enough mana
		return;
	end
	if (healvalue and not C_UnitGotBuff("player", C_Clearcasting)) then
		-- scale down so we use the "correct" rank
		rank = Genesis_ScaleSpell(unit, spell, rank, healvalue);
	end
	Genesis_error_message = nil;
	Genesis_check_for_client_error = nil;
	if (UnitExists("target") and (spell == C_Holy_shock or UnitIsFriend("player", "target")) and not UnitIsUnit(unit, "target")) then
		Genesis_target_last_target = 1;
		if (unit == "targettarget") then
			TargetUnit(unit);
		else
			ClearTarget();
		end
	end
	local checkname, checkrank = GetSpellName(Genesis_spells[spell][rank]["ID"], BOOKTYPE_SPELL);
	local start, stop, checkrank = string.find((checkrank or ""), "(%d+)");
	checkrank = (checkrank or 1) / 1.0;
	if (checkname ~= spell or checkrank ~= rank) then
		Genesis_UpdateSpells();
	end
	CastSpell(Genesis_spells[spell][rank]["ID"], BOOKTYPE_SPELL);
	if (SpellCanTargetUnit(unit)) then
		-- target our unit
		SpellTargetUnit(unit);
	end
	if (Genesis_error_message) then
		-- ok, so we got an error, figure out what we should do about it
		if (Genesis_error_moving[Genesis_error_message]) then
			-- we're moving, only instant casts allowed
			Genesis_only_instant_spells = 1;
		elseif (Genesis_error_unable[Genesis_error_message]) then
			-- unable to heal, don't try any other spells
			return 1;
		end
	end
	if (Genesis_check_for_client_error) then
		-- client detected an error (are we sitting?)
		if (Genesis_target_last_target) then
			TargetLastTarget();
			Genesis_target_last_target = nil;
		end
		return;
	end
	if (SpellIsTargeting()) then
		-- hmm, we really shouldn't be targeting anymore. another error?
		SpellStopTargeting();
		if (Genesis_target_last_target) then
			TargetLastTarget();
			Genesis_target_last_target = nil;
		end
		return;
	end
	if (Genesis_target_last_target) then
		TargetLastTarget();
		Genesis_target_last_target = nil;
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
	local casttime = Genesis_spells[spell][rank]["CastTime"];
	if ((C_my_class == C_Druid or C_my_class == C_Shaman) and C_UnitGotBuff("player", C_Natures_swiftness)) then
		casttime = 0;
	elseif (C_my_class == C_Druid and C_UnitGotBuff("player", C_Natures_grace) and casttime > 0) then
		casttime = casttime - 0.5;
	end
	local heal, healmin, healmax, hot = Genesis_GetSpellHealing(unit, spell, rank);

	Genesis_healing[name] = (Genesis_healing[name] or {});
	if (Genesis_healing[name][C_my_name] and Genesis_healing[name][C_my_name]["Bar"]) then
		local bar = getglobal("Genesis_GUIHealBars" .. Genesis_healing[name][C_my_name]["Bar"]);
		bar:SetMinMaxValues(666, 1337);
		bar:Hide();
	end

	Genesis_healing[name][C_my_name] = {
		["CastTime"] = casttime,
		["Heal"] = (healmin + healmax) / 2,
		["HealingOverTime"] = hot,
		["Rank"] = rank,
		["Spell"] = spell,
		["Status"] = "Active",
		["TankHealing"] = (not healvalue),
		["TimeLeft"] = casttime
	};
	Genesis_i_am_healing = name;

	Genesis_GUIHealCurrentSpellText:SetText(spell .. " " .. rank .. " - " .. math.floor((healmin + healmax) / 2) .. " / " .. math.floor(hot));
	Genesis_GUIHealCurrentSpell:SetMinMaxValues(0, casttime);
	Genesis_GUIHealCurrentTarget:SetMinMaxValues(0, UnitHealthMax(unit));
	Genesis_GUIHealCurrentAfter:SetMinMaxValues(0, UnitHealthMax(unit));
	Genesis_GUIHealCurrentOverheal:SetMinMaxValues(0, 1);
	Genesis_GUIHealCurrent:SetAlpha(1.0);
	Genesis_GUIHealCurrent:Show();
	Genesis_UpdateHealCurrent();

	if (SendAddonMessage) then
		SendAddonMessage("Genesis", "Update, " .. name .. ", " .. spell .. ", " .. (healmin + healmax) / 2 .. ", " .. hot .. ", " .. casttime .. ", " .. casttime, "RAID");
	end
	if (Broadcast_Message) then
		Broadcast_Message("Genesis", "Update, " .. name .. ", " .. spell .. ", " .. (healmin + healmax) / 2 .. ", " .. hot .. ", " .. casttime .. ", " .. casttime);
	end
	return 1;
end

function Genesis_HealMostWounded(spell, rank)
	-- heal the most wounded
	if (Genesis_casting_spell) then
		if (Genesis_data["safe_cancel"] == 0 or Genesis_GetOverheal() > Genesis_data["max_overheal"]) then
			SpellStopCasting();
		end
		return 1;
	end
	if (not Genesis_spells) then
		Genesis_UpdateSpells();
	end
	if (not ((rank and Genesis_spells[spell]) or (not rank and Genesis_data["classes"][spell]))) then
		-- unable to find spell or class
		return;
	end
	if (rank and GetSpellCooldown(Genesis_spells[spell][rank]["ID"], BOOKTYPE_SPELL) ~= 0) then
		-- cooldown on the spell
		return;
	elseif (not rank) then
		local allcooldown = 1;
		for spell, data in Genesis_data["classes"][spell] do
			if (GetSpellCooldown(Genesis_spells[spell][1]["ID"], BOOKTYPE_SPELL) == 0) then
				allcooldown = nil;
			end
		end
		if (allcooldown) then
			-- cooldown on all the spells in the class
			return;
		end
	end
	Genesis_most_wounded_id = 1;
	Genesis_most_wounded = (Genesis_most_wounded or {});
	C_UpdatePlayerData();
	
	local players = GetNumRaidMembers();
	local por = "raid";
	if (players == 0) then
		players = GetNumPartyMembers();
		por = "party";
		Genesis_SetMostWoundedData("player");
		Genesis_SetMostWoundedData("pet");
	end
	for a = 1, players do
		Genesis_SetMostWoundedData(por .. a);
		Genesis_SetMostWoundedData(por .. "pet" .. a);
	end

	-- erase old entries
	for id = Genesis_most_wounded_id, table.getn(Genesis_most_wounded) do
		Genesis_most_wounded[id] = nil;
	end

	-- sort the list
	table.sort(Genesis_most_wounded, Genesis_SortMostWoundedAlgorithm);

	-- and try to heal people in the right order
	for id = 1, table.getn(Genesis_most_wounded) do
		if (not Genesis_target_last_target and UnitExists("target") and UnitIsFriend("player", "target")) then
			Genesis_target_last_target = 1;
			ClearTarget();
		end
		local unit = Genesis_most_wounded[id]["Unit"];
		if (not rank) then
			-- we were given a class instead of a spell
			if (Genesis_HealUsingClass(unit, spell, Genesis_most_wounded[id]["Heal"])) then
				if (Genesis_target_last_target) then
					TargetLastTarget();
					Genesis_target_last_target = nil;
				end
				return 1;
			end
		elseif ((not Genesis_only_instant_spells or Genesis_spells[spell][rank]["CastTime"] == 0) and Genesis_Heal(unit, spell, rank, Genesis_most_wounded[id]["Heal"])) then
			-- we seem to be healing (at least client didn't detect errors)
			if (Genesis_target_last_target) then
				TargetLastTarget();
				Genesis_target_last_target = nil;
			end
			Genesis_only_instant_spells = nil;
			return 1;
		end
	end
	if (Genesis_target_last_target) then
		TargetLastTarget();
		Genesis_target_last_target = nil;
	end
	Genesis_only_instant_spells = nil;
	return;
end

function Genesis_HealUsingClass(unit, class, healvalue)
	-- this function should call Genesis_Heal trying the proper spell first,
	-- then move on to another spell if the first fail.
	if (not unit or not class or not Genesis_data["classes"][class]) then
		return;
	end
	local percent = UnitHealth(unit) / UnitHealthMax(unit);
	if (healvalue and percent > Genesis_data["min_heal_threshold"]) then
		-- not target healing, and unit got more hp than min heal threshold
		return;
	end
	local spell = 1;
	local spellstried = {};
	local lastpercent;
	while (spell) do
		spell = nil;
		lastpercent = nil;
		for curspell, data in Genesis_data["classes"][class] do
			if (not spellstried[curspell] and (not spell or (lastpercent < percent and data["Percent"] > lastpercent) or (lastpercent > percent and data["Percent"] >= percent and data["Percent"] < lastpercent))) then
				-- ^^ world record
				-- it "simply" figures out which spell to use
				if (not spell or (lastpercent and data["Percent"] ~= lastpercent)) then
					spell = curspell;
				elseif (lastpercent and data["Percent"] == lastpercent) then
					-- this spell got same percent as last
					-- we want to use the spell that:
					-- 1. heals enough on highest rank
					-- 2. got shortest casttime
					-- 3. cost least mana
					local rank = Genesis_data["classes"][class][spell]["Rank"];
					if (not rank) then
						rank = table.getn(Genesis_spells[spell]);
					end
					local currank = Genesis_data["classes"][class][curspell]["Rank"];
					if (not currank) then
						currank = table.getn(Genesis_spells[curspell]);
					end
					local curspellheal = Genesis_GetSpellHealing(unit, curspell, currank);
					local spellheal = Genesis_GetSpellHealing(unit, spell, rank);
					if (healvalue and curspellheal >= healvalue) then
						-- this spell heals enough at least. check casttime
						if (Genesis_spells[curspell][currank]["CastTime"] < Genesis_spells[spell][rank]["CastTime"]) then
							-- yep, shorter casttime
							spell = curspell;
						elseif (Genesis_spells[curspell][currank]["CastTime"] == Genesis_spells[spell][rank]["CastTime"]) then
							-- same casttime, check mana cost
							if (Genesis_spells[curspell][currank]["Mana"] < Genesis_spells[spell][rank]["Mana"]) then
								-- cost less mana
								spell = curspell;
							end
						end
					elseif (curspellheal > spellheal) then
						-- doesn't heal enough, but heals more than previous
						spell = curspell;
					end
				end
				lastpercent = data["Percent"];
			end
		end
		if (spell) then
			if (healvalue and Genesis_data["classes"][class][spell]["Percent"] <= percent) then
				-- the spell with the highest percent is lower than the players hp%
				return;
			end
			local rank = Genesis_data["classes"][class][spell]["Rank"];
			if (not rank) then
				rank = table.getn(Genesis_spells[spell]);
			end
			if ((not Genesis_only_instant_spells or Genesis_spells[spell][rank]["CastTime"] == 0) and Genesis_Heal(unit, spell, rank, healvalue)) then
				-- seem to be healing
				Genesis_only_instant_spells = nil;
				return 1;
			end
			spellstried[spell] = 1;
		end
	end
	Genesis_only_instant_spells = nil;
	return;
end

function Genesis_IsHealModifierKeyDown(modifier)
	if (not modifier or not Genesis_data[modifier]) then
		return;
	end
	if (Genesis_data[modifier] == 1) then
		return;
	elseif (Genesis_data[modifier] == 2) then
		return 1;
	elseif (Genesis_data[modifier] == 3 and IsAltKeyDown()) then
		return 1;
	elseif (Genesis_data[modifier] == 4 and IsControlKeyDown()) then
		return 1;
	elseif (Genesis_data[modifier] == 5 and IsShiftKeyDown()) then
		return 1;
	elseif (Genesis_data[modifier] == 6 and IsAltKeyDown() and IsControlKeyDown()) then
		return 1;
	elseif (Genesis_data[modifier] == 7 and IsAltKeyDown() and IsShiftKeyDown()) then
		return 1;
	elseif (Genesis_data[modifier] == 8 and IsControlKeyDown() and IsShiftKeyDown()) then
		return 1;
	end
end

function Genesis_KeyClick(button)
	if (not button) then
		return;
	end
	local unit;
	if (string.find(GetMouseFocus():GetName(), "Player")) then
		unit = "player";
	elseif (string.find(GetMouseFocus():GetName(), "Target")) then
		unit = C_AKA("target");
	elseif (string.find(GetMouseFocus():GetName(), "Party")) then
		unit = C_AKA("party" .. GetMouseFocus():GetID());
	elseif (string.find(GetMouseFocus():GetName(), "Raid")) then
		unit = (GetMouseFocus().unit or GetMouseFocus():GetParent().unit);
	elseif (UnitExists("mouseover")) then
		unit = C_AKA("mouseover");
	end
	if (not unit) then
		-- hmm, let's make it work like some people want it to work
		local spell = Genesis_data["mouse"][button]["SpellOrClass"];
		local rank;
		if (Genesis_spells[spell]) then
			rank = Genesis_data["mouse"][button]["Rank"];
		end
		Genesis_ActionHeal(spell, rank)
	else
		Genesis_MouseHeal(unit, button);
	end
end

function Genesis_Load(profile)
	-- load settings from profile
	-- since we don't have to copy the values this one is not as ugly as Genesis_Save()
	-- we have to copy the classes though, as they're global
	local classes = {};
	for class, data in Genesis_data["classes"] do
		classes[class] = {};
		for spell, settings in data do
			classes[class][spell] = {};
			for key, value in settings do
				classes[class][spell][key] = value;
			end
		end
	end
	Genesis_data = Genesis_profiles[profile];
	Genesis_data["classes"] = classes;
	-- let's cheat a bit to update the sliders & such in case the gui is showing
	if (Genesis_GUI:IsVisible()) then
		Genesis_GUI:Hide();
		Genesis_GUI:Show();
		if (Genesis_GUIRaid:IsVisible()) then
			Genesis_SetRaidChecked();
		end
	end
end

function Genesis_MouseDropDownMenuButton_OnClick(arg1)
	local start, stop, button = string.find(arg1:GetName(), "^Genesis_GUI(.+)DropDownMenu$");
	button = string.lower(button);
	local id = this:GetID();
	local spellOrClass = this:GetText();
	local slider = getglobal(string.gsub(arg1:GetName(), "DropDownMenu$", "") .. "RankSlider");
	if (not Genesis_data["mouse"]) then
		Genesis_data["mouse"] = {};
	end
	if (spellOrClass == "none") then
		if (not Genesis_data["mouse"][button]) then
			Genesis_data["mouse"][button] = {};
		end
		Genesis_data["mouse"][button]["SpellOrClass"] = nil;
		slider:Hide();
	else
		Genesis_data["mouse"][button] = {
			["SpellOrClass"] = spellOrClass,
			["Rank"] = 1
		};
		if (Genesis_spells[spellOrClass]) then
			slider.variable = "Genesis_data[\"mouse\"][" .. button .. "][\"Rank\"]";
			slider:SetMinMaxValues(1, table.getn(Genesis_spells[spellOrClass]));
			slider:SetValue(table.getn(Genesis_spells[spellOrClass]));
			slider:Show();
		else
			slider:Hide();
		end
	end
	UIDropDownMenu_SetSelectedID(arg1, id);
end

function Genesis_MouseDropDownMenuInitialize()
	if (not Genesis_spells) then
		Genesis_UpdateSpells();
	end
	local dropdownmenu = getglobal(this:GetParent():GetName());
	local info;
	info = {
		["text"] = "none",
		["func"] = Genesis_MouseDropDownMenuButton_OnClick,
		["arg1"] = dropdownmenu
	};
	UIDropDownMenu_AddButton(info);
	if (not Genesis_data["classes"]) then
		Genesis_data["classes"] = {};
	end
	local classes = 0;
	for class, data in Genesis_data["classes"] do
		classes = classes + 1;
	end
	if (classes == 0) then
		Genesis_data["classes"]["default"] = {};
	end
	for class, data in Genesis_data["classes"] do
		info = {
			["text"] = class,
			["func"] = Genesis_MouseDropDownMenuButton_OnClick,
			["arg1"] = dropdownmenu
		};
		UIDropDownMenu_AddButton(info);
	end
	for spell, data in Genesis_spells do
		if (Genesis_player_heal_spells[spell]) then
			info = {
				["text"] = spell,
				["func"] = Genesis_MouseDropDownMenuButton_OnClick,
				["arg1"] = dropdownmenu
			};
			UIDropDownMenu_AddButton(info);
		end
	end
	local me = getglobal(string.gsub(this:GetName(), "Button$", ""));
	local start, stop, button = string.find(dropdownmenu:GetName(), "^Genesis_GUI(.+)$");
	button = string.gsub(button, "DropDownMenu$", "");
	local slider = getglobal("Genesis_GUI" .. button .. "RankSlider");
	button = string.lower(button);
	if (Genesis_data["mouse"][button] and Genesis_data["mouse"][button]["SpellOrClass"]) then
		UIDropDownMenu_SetSelectedName(me, Genesis_data["mouse"][button]["SpellOrClass"])
		if (Genesis_spells[Genesis_data["mouse"][button]["SpellOrClass"]]) then
			slider.variable = "Genesis_data[\"mouse\"][" .. button .. "][\"Rank\"]";
			slider:SetMinMaxValues(1, table.getn(Genesis_spells[Genesis_data["mouse"][button]["SpellOrClass"]]));
			slider:SetValue(Genesis_data["mouse"][button]["Rank"]);
			slider:Show();
		else
			slider:Hide();
		end
	else
		UIDropDownMenu_SetSelectedID(me, 1)
		slider:Hide();
	end
end

function Genesis_MouseHeal(unit, button)
	if (not Genesis_IsHealModifierKeyDown("heal_enough_modifier") and not Genesis_IsHealModifierKeyDown("heal_max_modifier")) then
		-- we haven't ordered a heal
		return;
	end
	button = string.lower(button);
	if (not button or not unit or not Genesis_data["mouse"][button]) then
		return;
	end
	local spell = Genesis_data["mouse"][button]["SpellOrClass"];
	if (not Genesis_spells) then
		Genesis_UpdateSpells();
	end
	local healvalue;
	if (not Genesis_IsHealModifierKeyDown("heal_max_modifier")) then
		-- not tankhealing, set healvalue
		healvalue = Genesis_GetHealValue(unit);
		if (healvalue < UnitHealthMax(unit) * (1.0 - Genesis_data["min_heal_threshold"])) then
			return 1;
		end
	end
	if (Genesis_spells[spell]) then
		-- a simple spell
		local rank = Genesis_data["mouse"][button]["Rank"];
		Genesis_Heal(unit, spell, rank, healvalue);
	else
		-- a class
		Genesis_HealUsingClass(unit, spell, healvalue);
	end
	return 1;
end

function Genesis_OnEvent()
	if (event == "CHAT_MSG_ADDON" and arg1 and arg2 and arg3 and arg4 and arg1 == "Genesis") then
		-- received a message from someone else
		Genesis_Receive(arg2, arg4);
	elseif (event == "LEARNED_SPELL_IN_TAB") then
		Genesis_UpdateSpells();
	elseif (event == "PLAYER_ENTERING_WORLD") then
		-- we zoned somewhere, clearly we left battle
		C_player_in_combat = nil;
		-- and clearly we're not casting a spell
		Genesis_casting_spell = nil;
	elseif (event == "PLAYER_LOGIN") then
		-- register with broadcast
		if (Broadcast_Register) then
			Broadcast_Register("Genesis", Genesis_Receive);
		end

		if (not Genesis_supported_classes[C_my_class]) then
			-- we're not a healer, let's mess with the "OnUpdate" method
			Genesis_OnUpdate = function(elapsed)
				Genesis_UpdateHealing(elapsed);
			end
			-- and then return, don't need to register/hook anymore
			return;
		end
		-- only register these events when they're actually useful
		this:RegisterEvent("CHAT_MSG_ADDON");
		this:RegisterEvent("LEARNED_SPELL_IN_TAB");
		this:RegisterEvent("PLAYER_ENTERING_WORLD");
		this:RegisterEvent("PLAYER_LEAVING_WORLD");
		this:RegisterEvent("PLAYER_REGEN_DISABLED");
		this:RegisterEvent("PLAYER_REGEN_ENABLED");
		this:RegisterEvent("RAID_ROSTER_UPDATE");
		this:RegisterEvent("SPELLCAST_DELAYED");
		this:RegisterEvent("SPELLCAST_FAILED");
		this:RegisterEvent("SPELLCAST_INTERRUPTED");
		this:RegisterEvent("SPELLCAST_START");
		this:RegisterEvent("SPELLCAST_STOP");
		this:RegisterEvent("UI_ERROR_MESSAGE");
		this:RegisterEvent("UNIT_INVENTORY_CHANGED");

		-- ninja "UseAction"
		Genesis_original_UseAction = UseAction;
		UseAction = Genesis_UseAction;

		-- ninja some "OnClick"
		Genesis_original_PlayerFrame_OnClick = PlayerFrame_OnClick;
		PlayerFrame_OnClick = Genesis_PlayerFrame_OnClick;
		Genesis_original_TargetFrame_OnClick = TargetFrame_OnClick;
		TargetFrame_OnClick = Genesis_TargetFrame_OnClick;
		Genesis_original_PartyMemberFrame_OnClick = PartyMemberFrame_OnClick;
		PartyMemberFrame_OnClick = Genesis_PartyMemberFrame_OnClick;
		Genesis_original_RaidPulloutButton_OnClick = RaidPulloutButton_OnClick;
		RaidPulloutButton_OnClick = Genesis_RaidPulloutButton_OnClick;

		-- and PickupSpell
		Genesis_original_PickupSpell = PickupSpell;
		PickupSpell = Genesis_PickupSpell;

		-- and TargetFrame_Update to make it stfu when deselecting since we're healing someone else than our (friendly) target
		Genesis_original_TargetFrame_Update = TargetFrame_Update;
		TargetFrame_Update = Genesis_TargetFrame_Update;
	elseif (event == "PLAYER_REGEN_DISABLED") then
		-- regen disabled, means we're in combat
		C_player_in_combat = 1;
	elseif (event == "PLAYER_REGEN_ENABLED") then
		-- regen enabled, means we left combat
		C_player_in_combat = nil;
	elseif (event == "RAID_ROSTER_UPDATE") then
		Genesis_SetRaidChecked();
	elseif (event == "SPELLCAST_DELAYED" and Genesis_i_am_healing and arg1) then
		-- our current spellcasting got delayed somehow
		local giah = Genesis_i_am_healing;
		if (not Genesis_healing[giah] or not Genesis_healing[giah][C_my_name] or Genesis_healing[giah][C_my_name]["Complete"]) then
			return;
		end
		Genesis_healing[giah][C_my_name]["TimeLeft"] = Genesis_healing[giah][C_my_name]["TimeLeft"] + arg1 / 1000;
		if (SendAddonMessage) then
			SendAddonMessage("Genesis", "Update, " .. giah .. ", " .. Genesis_healing[giah][C_my_name]["Spell"] .. ", " .. Genesis_healing[giah][C_my_name]["Heal"] .. ", " .. Genesis_healing[giah][C_my_name]["HealingOverTime"] .. ", " .. Genesis_healing[giah][C_my_name]["CastTime"] .. ", " .. Genesis_healing[giah][C_my_name]["TimeLeft"], "RAID");
		end
		if (Broadcast_Message) then
			Broadcast_Message("Genesis", "Update, " .. giah .. ", " .. Genesis_healing[giah][C_my_name]["Spell"] .. ", " .. Genesis_healing[giah][C_my_name]["Heal"] .. ", " .. Genesis_healing[giah][C_my_name]["HealingOverTime"] .. ", " .. Genesis_healing[giah][C_my_name]["CastTime"] .. ", " .. Genesis_healing[giah][C_my_name]["TimeLeft"]);
		end
	elseif (event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_STOP") then
		-- our spellcasting failed, was interrupted or stopped
		local wascasting = Genesis_casting_spell;
		Genesis_casting_spell = nil;
		Genesis_check_for_client_error = 1;
		local giah = Genesis_i_am_healing;
		if (not giah or not Genesis_healing[giah] or not Genesis_healing[giah][C_my_name]) then
			return;
		end
		if (event == "SPELLCAST_FAILED") then
			Genesis_healing[giah][C_my_name]["Status"] = "Failed";
		elseif (event == "SPELLCAST_INTERRUPTED") then
			Genesis_healing[giah][C_my_name]["Status"] = "Interrupted";
		elseif (not wascasting) then
			-- we got a "stop" signal before the "start" signal?
			-- don't do anything, return
			return;
		else
			Genesis_healing[giah][C_my_name]["Status"] = "Stop";
		end
		-- an attempt to improve "heal most wounded"; "ban" the last healed player for a short duration
		-- could use the "UNIT_HEALTH" event to monitor this, but that event fires ALL the time. waste of cpu
		-- 300ms ban should be more than 'nuff, if the players hp is so critically low then there's most likely
		-- 10 other healers trying to heal that player anyways.
		Genesis_soft_lock_player = C_GetUnitID(giah);
		Genesis_soft_lock_time = 0.3;

		Genesis_healing[giah][C_my_name]["Complete"] = 1;
		Genesis_healing[giah][C_my_name]["TimeLeft"] = -1;
		if (SendAddonMessage) then
			SendAddonMessage("Genesis", Genesis_healing[giah][C_my_name]["Status"] .. ", " .. giah .. ", " .. Genesis_healing[giah][C_my_name]["Spell"] .. ", " .. Genesis_healing[giah][C_my_name]["Heal"] .. ", " .. Genesis_healing[giah][C_my_name]["HealingOverTime"] .. ", " .. Genesis_healing[giah][C_my_name]["CastTime"] .. ", " .. Genesis_healing[giah][C_my_name]["TimeLeft"], "RAID");
		end
		if (Broadcast_Message) then
			Broadcast_Message("Genesis", Genesis_healing[giah][C_my_name]["Status"] .. ", " .. giah .. ", " .. Genesis_healing[giah][C_my_name]["Spell"] .. ", " .. Genesis_healing[giah][C_my_name]["Heal"] .. ", " .. Genesis_healing[giah][C_my_name]["HealingOverTime"] .. ", " .. Genesis_healing[giah][C_my_name]["CastTime"] .. ", " .. Genesis_healing[giah][C_my_name]["TimeLeft"]);
		end
	elseif (event == "SPELLCAST_START" and arg2) then
		-- we just started casting a spell
		Genesis_casting_spell = 1;
		local giah = Genesis_i_am_healing;
		if (not giah or not Genesis_healing[giah] or not Genesis_healing[giah][C_my_name] or Genesis_healing[giah][C_my_name]["Complete"]) then
			return;
		end
		arg2 = arg2 / 1000;
		if (arg2 == Genesis_healing[giah][C_my_name]["CastTime"]) then
			-- casttime is correct, no need to tell everyone
			return;
		end
		Genesis_healing[giah][C_my_name]["TimeLeft"] = Genesis_healing[giah][C_my_name]["TimeLeft"] + arg2 - Genesis_healing[giah][C_my_name]["CastTime"];
		Genesis_healing[giah][C_my_name]["CastTime"] = arg2;
		if (SendAddonMessage) then
			SendAddonMessage("Genesis", "Update, " .. giah .. ", " .. Genesis_healing[giah][C_my_name]["Spell"] .. ", " .. Genesis_healing[giah][C_my_name]["Heal"] .. ", " .. Genesis_healing[giah][C_my_name]["HealingOverTime"] .. ", " .. Genesis_healing[giah][C_my_name]["CastTime"] .. ", " .. Genesis_healing[giah][C_my_name]["TimeLeft"], "RAID");
		end
		if (Broadcast_Message) then
			Broadcast_Message("Genesis", "Update, " .. giah .. ", " .. Genesis_healing[giah][C_my_name]["Spell"] .. ", " .. Genesis_healing[giah][C_my_name]["Heal"] .. ", " .. Genesis_healing[giah][C_my_name]["HealingOverTime"] .. ", " .. Genesis_healing[giah][C_my_name]["CastTime"] .. ", " .. Genesis_healing[giah][C_my_name]["TimeLeft"]);
		end
	elseif (event == "UI_ERROR_MESSAGE") then
		Genesis_error_message = arg1;
	elseif (event == "UNIT_INVENTORY_CHANGED" and arg1 and arg1 == "player") then
		-- it's possible the player changed equipment
		-- recalculate +healing
		Genesis_UpdateItemHealBonus();
	elseif (event == "VARIABLES_LOADED") then
		Genesis_SetupSettings();
	end
end

function Genesis_OnLoad()
	Genesis_healing = {};
	Genesis_item_heal_bonus_cache = {};
	Genesis_raid_cache = {};

	C_my_class = UnitClass("player");
	C_my_name = UnitName("player");

	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("VARIABLES_LOADED");

	SLASH_Genesis1 = "/genesis";
	SlashCmdList["Genesis"] = function(msg)
		Genesis_Command(msg)
	end
end

function Genesis_OnUpdate(elapsed)
	Genesis_UpdateHealCurrent(elapsed);
	Genesis_UpdateHealing(elapsed);
	Genesis_update_player_data_time = (Genesis_update_player_data_time or 0) + elapsed;
	if (Genesis_update_player_data_time > (C_update_player_data_interval or 0)) then
		C_UpdatePlayerData(Genesis_update_player_data_time);
		Genesis_update_player_data_time = 0;
	end
	if (Genesis_soft_lock_player and Genesis_soft_lock_time) then
		Genesis_soft_lock_time = Genesis_soft_lock_time - elapsed;
		if (Genesis_soft_lock_time < 0) then
			Genesis_soft_lock_time = nil;
			Genesis_soft_lock_player = nil;
		end
	end

end

function Genesis_PartyMemberFrame_OnClick(partyFrame)
	partyFrame = (partyFrame or this);
	local unit = "party" .. partyFrame:GetID();
	if (not Genesis_MouseHeal(unit, arg1)) then
		Genesis_original_PartyMemberFrame_OnClick(partyFrame, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
	end
end

function Genesis_PickupClassSpell()
	local parent = string.gsub(this:GetName(), "Spell$", "");
	local spell = getglobal(parent .. "SpellText"):GetText();
	local rank = getglobal(parent .. "RankSlider"):GetValue();
	if (not Genesis_spells) then
		Genesis_UpdateSpells();
	end
	if (not Genesis_spells[spell][rank] or not Genesis_spells[spell][rank]["ID"]) then
		rank = table.getn(Genesis_spells[spell]);
	end
	local id = Genesis_spells[spell][rank]["ID"];
	Genesis_pickup_percent = getglobal(parent .. "PercentSlider"):GetValue();
	Genesis_data["classes"][Genesis_current_class][spell] = nil;
	PickupSpell(id, BOOKTYPE_SPELL);
	Genesis_ClassDropDownMenuUpdate(Genesis_current_class);
end

function Genesis_PickupSpell(spellid, spellbook)
	if (Genesis_pickup_spellid == spellid and Genesis_pickup_spellbook == spellbook) then
		Genesis_pickup_spellid = nil;
		Genesis_pickup_spellbook = nil;
	else
		Genesis_pickup_spellid = spellid;
		Genesis_pickup_spellbook = spellbook;
	end
	return Genesis_original_PickupSpell(spellid, spellbook);
end

function Genesis_PlayerFrame_OnClick()
	if (not Genesis_MouseHeal("player", arg1)) then
		Genesis_original_PlayerFrame_OnClick(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
	end
end

function Genesis_RaidPulloutButton_OnClick()
	local unit = (this.unit or this:GetParent().unit);
	if (not Genesis_MouseHeal(unit, arg1)) then
		Genesis_original_RaidPulloutButton_OnClick(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
	end
end

function Genesis_RaidUnitIsChecked(unit)
	-- return 1 if we're in a raid and the given unit is checked for healing
	if (GetNumRaidMembers() <= 0) then
		-- we're not in a raid, raid setting doesn't matter
		return 1;
	end
	if (not string.find(unit, "raid")) then
		-- this is not a raid unit
		return 1;
	end
	if (string.find(unit, "pet")) then
		-- pets are not affected by this feature
		return 1;
	end
	local slot = Genesis_raid_cache[UnitName(unit)];
	if (not slot) then
		-- uhh, okay?
		return 1;
	end
	local start, stop, index = string.find(unit, "[^%d]*(%d+)[^%d]*");
	if (not index) then
		-- woot?
		return 1;
	end
	index = index / 1;
	local name, rank, group = GetRaidRosterInfo(index);
	if (not group) then
		-- weird
		return 1;
	end
	if (name ~= UnitName(unit)) then
		-- hmm, this shouldn't happen
		C_Print("Error: out of sync, \"" .. name .. "\" found, \"" .. UnitName(unit) .. "\" expected");
		return 1;
	end
	if (Genesis_data["raid"][group][slot] == 1) then
		-- we're supposed to heal this player
		return 1;
	end
	-- if we get this far it means we're not supposed to heal this unit
end

function Genesis_Receive(author, message)
	-- Broadcast will call this method every time someone tries to tell me something
	if (author == C_my_name or not C_GetUnitID(author)) then
		-- either me or this player ain't in my party/raid
		return;
	end
	local start, stop, what, who, spell, heal, hot, casttime, timeleft = string.find(message, "^(.+), (.+), (.+), (%d+%.?%d*), (%d+%.?%d*), (%d+%.?%d*), (%d+%.?%d*)");
	if (not start) then
		-- don't understand this player :\
		return;
	end
	if (not C_GetUnitID(who)) then
		-- no clue who this person is
		return;
	end
	Genesis_healing[who] = (Genesis_healing[who] or {});
	if (what == "Update") then
		-- general update:
		-- + someone started healing
		-- + someone updated their casting time
		-- + someone got delayed
		-- we just update the data
		heal = heal / 1.0;
		hot = hot / 1.0;
		casttime = casttime / 1.0;
		timeleft = timeleft / 1.0;
		if (Genesis_healing[who][author] and Genesis_healing[who][author]["Bar"]) then
			local bar = getglobal("Genesis_GUIHealBars" .. Genesis_healing[who][author]["Bar"]);
			bar:SetMinMaxValues(666, 1337);
			bar:Hide();
		end
		Genesis_healing[who][author] = {
			["CastTime"] = casttime,
			["Heal"] = heal,
			["HealingOverTime"] = hot,
			["Name"] = name,
			["Spell"] = spell,
			["Status"] = "Active",
			["TimeLeft"] = timeleft
		};
	else
		if (Genesis_healing[who][author] and Genesis_healing[who][author]["Status"] == "Active") then
			Genesis_healing[who][author]["Status"] = what;
			Genesis_healing[who][author]["TimeLeft"] = -1;
		end
	end
end

function Genesis_Save(profile)
	-- save current settings to a profile
	-- a bit "idiot code" here to simplify stuff
	Genesis_profiles[profile] = {};
	for key, value in Genesis_data do
		if (type(value) == "table") then
			Genesis_profiles[profile][key] = {};
			for key2, value2 in value do
				if (type(value2) == "table") then
					Genesis_profiles[profile][key][key2] = {};
					for key3, value3 in value2 do
						if (type(value3) == "table") then
							-- add more levels later if needed...
							-- ugly hack, but it works :\
						else
							Genesis_profiles[profile][key][key2][key3] = value3;
						end
					end
				else
					Genesis_profiles[profile][key][key2] = value2;
				end
			end
		else
			Genesis_profiles[profile][key] = value;
		end
	end
end

function Genesis_ScaleSpell(unit, spell, rank, heal)
	-- scale down a spell to restore ~100%
	if (Genesis_data["scale_spells"] == 0 or not unit or not spell or not rank or Genesis_dont_scale[spell]) then
		return rank;
	end
	heal = heal * Genesis_data["heal_power"];
	while (rank > 1 and heal < Genesis_GetSpellHealing(unit, spell, rank - 1)) do
		rank = rank - 1;
	end
	return rank;
end

function Genesis_SetMostWoundedData(unit)
	-- a helping hand to Genesis_HealMostWounded
	if ((Genesis_soft_lock_player and Genesis_soft_lock_player == unit) or not Genesis_CanHeal(unit)) then
		return;
	end
	local healvalue = Genesis_GetHealValue(unit);
	if (healvalue < UnitHealthMax(unit) * (1.0 - Genesis_data["min_heal_threshold"])) then
		return;
	end

	local priority = Genesis_GetPriority(unit);
	if (priority <= 0 or healvalue <= 0) then
		return;
	end
	-- note to self:
	-- "healvalue" is more or less: UnitHealthMax(unit) - UnitHealth(unit)
	local priorityvalue;
	if (Genesis_data["heal_strategy"] == 2) then
		-- heal least percent life left
		priorityvalue = priority * (healvalue / UnitHealthMax(unit));
	elseif (Genesis_data["heal_strategy"] == 3) then
		-- heal most hitpoints missing
		priorityvalue = priority * healvalue;
	else
		-- heal least hitpoints left (default)
		local divideby = (UnitHealthMax(unit) - healvalue);
		if (divideby < 1) then
			divideby = 1;
		end
		priorityvalue = priority * (666 / divideby);
	end
	Genesis_most_wounded[Genesis_most_wounded_id] = (Genesis_most_wounded[Genesis_most_wounded_id] or {});
	Genesis_most_wounded[Genesis_most_wounded_id]["Heal"] = healvalue;
	Genesis_most_wounded[Genesis_most_wounded_id]["PriorityValue"] = priorityvalue;
	Genesis_most_wounded[Genesis_most_wounded_id]["Unit"] = unit;
	Genesis_most_wounded_id = Genesis_most_wounded_id + 1;
end

function Genesis_SetRaidChecked()
	-- set which groups/units should be checked in the gui
	Genesis_generic_table = (Genesis_generic_table or {});
	for group = 1, 8 do
		Genesis_generic_table[group] = 1;
	end
	for raidindex = 1, GetNumRaidMembers() do
		local name, rank, group, level, class, filename = GetRaidRosterInfo(raidindex);
		local slot = Genesis_generic_table[group];
		Genesis_raid_cache[name] = slot;
		Genesis_generic_table[group] = Genesis_generic_table[group] + 1;
		if (Genesis_GUIRaid:IsVisible()) then
			getglobal("Genesis_GUIRaidGroup" .. group .. "Slot" .. slot .. "CheckButton"):SetChecked(Genesis_data["raid"][group][slot]);
			getglobal("Genesis_GUIRaidGroup" .. group .. "Slot" .. slot .. "Name"):SetText(name);
			getglobal("Genesis_GUIRaidGroup" .. group .. "Slot" .. slot .. "Name"):SetTextColor(RAID_CLASS_COLORS[filename].r, RAID_CLASS_COLORS[filename].g, RAID_CLASS_COLORS[filename].b);
		end
	end
	-- empty the remaining slots
	if (Genesis_GUIRaid:IsVisible()) then
		for group = 1, 8 do
			for slot = Genesis_generic_table[group], 5 do
				getglobal("Genesis_GUIRaidGroup" .. group .. "Slot" .. slot .. "CheckButton"):SetChecked(Genesis_data["raid"][group][slot]);
				getglobal("Genesis_GUIRaidGroup" .. group .. "Slot" .. slot .. "Name"):SetText(EMPTY);
				getglobal("Genesis_GUIRaidGroup" .. group .. "Slot" .. slot .. "Name"):SetTextColor(0.3, 0.3, 0.3);
			end
		end
	end
end

function Genesis_SetupSettings()
	-- setup some user defined settings
	C_update_player_data_time = (C_update_player_data_time or 2.5);

	Genesis_data = (Genesis_data or {});
	Genesis_profiles = (Genesis_profiles or {});

	if (not Genesis_data["version"]) then
		-- new version, fix settings that has changed
		Genesis_data["heal_enough_modifier"] = nil;
		Genesis_data["heal_max_modifier"] = nil;
		Genesis_data["heal_self_modifier"] = nil;
		Genesis_data["heal_targettarget_modifier"] = nil;
		C_Print("Due to changes in Genesis your key modifiers has been reset. Go to the \"Mouse/Keys\" tab in the GUI to set the modifiers to whatever you desire.", "|cffff0000");
	end

	Genesis_data["autocancel"] = (Genesis_data["autocancel"] or 1);
	if (not Genesis_data["buff_affect_priority"]) then
		Genesis_data["buff_affect_priority"] = {
			[C_Blessing_of_protection] = 0.2,
			[C_Power_word_shield] = 0.4
		};
	end
	Genesis_data["autocancel_time"] = (Genesis_data["autocancel_time"] or 0.25);
	if (not Genesis_data["class_priority"]) then
		Genesis_data["class_priority"] = {
			[C_Druid] = 1.0,
			[C_Hunter] = 1.0,
			[C_Mage] = 1.0,
			[C_Paladin] = 1.0,
			[C_Priest] = 1.0,
			[C_Rogue] = 1.0,
			[C_Shaman] = 1.0,
			[C_Warlock] = 1.0,
			[C_Warrior] = 1.0
		};
	end
	Genesis_data["classes"] = (Genesis_data["classes"] or {});
	if (not Genesis_data["debuff_affect_priority"]) then
		Genesis_data["debuff_affect_priority"] = {
			[C_Recently_bandaged] = 0.2,
			[C_Weakened_soul] = 0.2
		};
	end
	Genesis_data["heal_enough_modifier"] = (Genesis_data["heal_enough_modifier"] or 4);
	Genesis_data["heal_max_modifier"] = (Genesis_data["heal_max_modifier"] or 5);
	Genesis_data["heal_power"] = (Genesis_data["heal_power"] or 1.0);
	Genesis_data["heal_self_modifier"] = (Genesis_data["heal_self_modifier"] or 3);
	Genesis_data["heal_strategy"] = (Genesis_data["heal_strategy"] or 1);
	Genesis_data["heal_targettarget_modifier"] = (Genesis_data["heal_targettarget_modifier"] or 1);
	Genesis_data["hook_shields"] = (Genesis_data["hook_shields"] or 1);
	Genesis_data["hook_useaction"] = (Genesis_data["hook_useaction"] or 1);
	Genesis_data["hot_heal_threshold"] = (Genesis_data["hot_heal_threshold"] or 0.4);
	Genesis_data["hot_multiply"] = (Genesis_data["hot_multiply"] or 1.0);
	Genesis_data["hot_multiply_battle"] = (Genesis_data["hot_multiply_battle"] or 0.5);
	Genesis_data["max_overheal"] = (Genesis_data["max_overheal"] or 0.2);
	Genesis_data["min_heal_threshold"] = (Genesis_data["min_heal_threshold"] or 0.95);
	Genesis_data["mouse"] = (Genesis_data["mouse"] or {});
	Genesis_data["party_priority"] = (Genesis_data["party_priority"] or 0.8);
	Genesis_data["pet_priority"] = (Genesis_data["pet_priority"] or 0.2);
	Genesis_data["player_priority"] = (Genesis_data["player_priority"] or 1.0);
	Genesis_data["raid"] = (Genesis_data["raid"] or {});
	for group = 1, 8 do
		Genesis_data["raid"][group] = (Genesis_data["raid"][group] or {});
		for slot = 1, 5 do
			Genesis_data["raid"][group][slot] = (Genesis_data["raid"][group][slot] or 1);
		end
	end
	Genesis_data["raid_priority"] = (Genesis_data["raid_priority"] or 0.6);
	Genesis_data["safe_cancel"] = (Genesis_data["safe_cancel"] or 1);
	if (C_my_class == C_Druid or C_my_class == C_Paladin or C_my_class == C_Priest or C_my_class == C_Shaman) then
		Genesis_data["show_healing_all"] = (Genesis_data["show_healing_all"] or 1);
		Genesis_data["show_healing_me"] = (Genesis_data["show_healing_me"] or 0);
	else
		Genesis_data["show_healing_all"] = (Genesis_data["show_healing_all"] or 0);
		Genesis_data["show_healing_me"] = (Genesis_data["show_healing_me"] or 1);
	end
	Genesis_data["scale_spells"] = (Genesis_data["scale_spells"] or 1);
	Genesis_data["shapeshifted_druids"] = (Genesis_data["shapeshifted_druids"] or 0);
	Genesis_data["unchecked_priority"] = (Genesis_data["unchecked_priority"] or 0.3);
	Genesis_data["useaction_heal_most_wounded"] = (Genesis_data["useaction_heal_most_wounded"] or 1);
	Genesis_data["version"] = Genesis_GUI_title;
end

function Genesis_ShowTooltip()
	-- show the user a simple tooltip for his or hers amusement :)
	local title, description;
	if (this:GetName() == "Genesis_GUIPaladinPriestPrioritySlider") then
		if (UnitFactionGroup("player") == C_Alliance) then
			title = Genesis_GUI_help["PaladinPriority"]["Title"];
			description = Genesis_GUI_help["PaladinPriority"]["Description"];
		else
			title = Genesis_GUI_help["PriestPriority"]["Title"];
			description = Genesis_GUI_help["PriestPriority"]["Description"];
		end
	elseif (this:GetName() == "Genesis_GUIPriestRoguePrioritySlider") then
		if (UnitFactionGroup("player") == C_Alliance) then
			title = Genesis_GUI_help["PriestPriority"]["Title"];
			description = Genesis_GUI_help["PriestPriority"]["Description"];
		else
			title = Genesis_GUI_help["RoguePriority"]["Title"];
			description = Genesis_GUI_help["RoguePriority"]["Description"];
		end
	elseif (this:GetName() == "Genesis_GUIRogueShamanPrioritySlider") then
		if (UnitFactionGroup("player") == C_Alliance) then
			title = Genesis_GUI_help["RoguePriority"]["Title"];
			description = Genesis_GUI_help["RoguePriority"]["Description"];
		else
			title = Genesis_GUI_help["ShamanPriority"]["Title"];
			description = Genesis_GUI_help["ShamanPriority"]["Description"];
		end
	else
		local length = 0;
		for element, data in Genesis_GUI_help do
			if (string.find(this:GetName(), element) and string.len(element) > length) then
				title = data["Title"];
				description = data["Description"];
				length = string.len(element);
			end
		end
	end
	if (title and description) then
		GameTooltip_SetDefaultAnchor(GameTooltip, this);
		GameTooltip:SetText(title, 0.9, 0.9, 0.9, 1.0, 1);
		GameTooltip:AddLine(description, nil, nil, nil, 1);
		GameTooltip:Show();
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, this);
		GameTooltip:SetText("Missing", 0.9, 0.9, 0.9, 1.0, 1);
		GameTooltip:AddLine(this:GetName());
		GameTooltip:Show();
	end
end

function Genesis_SortMostWoundedAlgorithm(a, b)
	-- sort algorithm for the list
	return (a["PriorityValue"] > b["PriorityValue"]);
end

function Genesis_TargetFrame_OnClick()
	if (not Genesis_MouseHeal(C_AKA("target"), arg1)) then
		Genesis_original_TargetFrame_OnClick(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
	end
end

function Genesis_TargetFrame_Update()
	if (not Genesis_target_last_target) then
		Genesis_original_TargetFrame_Update();
	end
end

function Genesis_UpdateHealCurrent(elapsed)
	local giah = Genesis_i_am_healing;
	if (not giah or not Genesis_healing[giah] or not Genesis_healing[giah][C_my_name]) then
		return;
	end
	local unit = C_GetUnitID(giah);
	elapsed = (elapsed or 0);
	local timeleft = Genesis_healing[giah][C_my_name]["TimeLeft"] - elapsed;
	if (not unit) then
		-- we're healing target, but changed to another target
		-- we don't know how much hp the target currently got
		-- getting blueballed, so color everything likewise
		Genesis_GUIHealCurrentSpell:SetValue(Genesis_healing[giah][C_my_name]["CastTime"] - timeleft);
		Genesis_GUIHealCurrentSpellBarTexture:SetVertexColor(0.0, 0.0, 1.0, 0.5);
		Genesis_GUIHealCurrentTargetBarTexture:SetVertexColor(0.0, 0.0, 1.0, 0.5);
		Genesis_GUIHealCurrentAfterBarTexture:SetVertexColor(0.0, 0.0, 1.0, 0.5);
		Genesis_GUIHealCurrentOverhealBarTexture:SetVertexColor(0.0, 0.0, 1.0, 0.5);
	elseif (unit) then
		Genesis_GUIHealCurrentTargetText:SetText(giah .. " (" .. math.floor(UnitHealth(unit) / UnitHealthMax(unit) * 1000) / 10 .. "%)");
		local afterhp = UnitHealth(unit) + Genesis_healing[giah][C_my_name]["Heal"] + Genesis_healing[giah][C_my_name]["HealingOverTime"];
		if (UnitHealthMax(unit) == 100) then
			-- apparently healing some unit we don't know the real health of (outside raid?). convert the hp restored to percent for this class
			afterhp = UnitHealth(unit) + (Genesis_healing[giah][C_my_name]["Heal"] + Genesis_healing[giah][C_my_name]["HealingOverTime"]) / (UnitLevel(unit) * Genesis_class_hp_per_level[UnitClass(unit)] / 100);
		end
		if (afterhp > UnitHealthMax(unit)) then
			afterhp = UnitHealthMax(unit);
		end
		Genesis_GUIHealCurrentSpell:SetMinMaxValues(0, Genesis_healing[giah][C_my_name]["CastTime"]);
		Genesis_GUIHealCurrentTarget:SetMinMaxValues(0, UnitHealthMax(unit));
		Genesis_GUIHealCurrentAfter:SetMinMaxValues(0, UnitHealthMax(unit));
		Genesis_GUIHealCurrentSpell:SetValue(Genesis_healing[giah][C_my_name]["CastTime"] - timeleft);
		Genesis_GUIHealCurrentTarget:SetValue(UnitHealth(unit));
		if (not Genesis_healing[giah][C_my_name]["Complete"]) then
			-- we don't want to update these bars when the spell is finished (heal would be applied "twice")
			Genesis_GUIHealCurrentAfterText:SetText("After heal (" .. math.floor(afterhp / UnitHealthMax(unit) * 1000) / 10 .. "%)");
			Genesis_GUIHealCurrentAfter:SetValue(afterhp);
			local overhealpercent, overheal = Genesis_GetOverheal();
			Genesis_GUIHealCurrentOverhealText:SetText("Overheal " .. overheal .. " (" .. math.floor(overhealpercent * 1000) / 10 .. "%)");
			Genesis_GUIHealCurrentOverheal:SetValue(overhealpercent);
			if (overhealpercent > Genesis_data["max_overheal"]) then
				-- overhealing
				if (GetSpellCooldown(Genesis_spells[Genesis_healing[giah][C_my_name]["Spell"]][Genesis_healing[giah][C_my_name]["Rank"]]["ID"], BOOKTYPE_SPELL) ~= 0) then
					-- still cooldown, show yellow color
					Genesis_GUIHealCurrentSpellBarTexture:SetVertexColor(1.0, 0.7, 0.0, 0.5);
					Genesis_GUIHealCurrentTargetBarTexture:SetVertexColor(1.0, 0.7, 0.0, 0.5);
					Genesis_GUIHealCurrentAfterBarTexture:SetVertexColor(1.0, 0.7, 0.0, 0.5);
					Genesis_GUIHealCurrentOverhealBarTexture:SetVertexColor(1.0, 0.7, 0.0, 0.5);
				else
					-- no cooldown, show red color
					Genesis_GUIHealCurrentSpellBarTexture:SetVertexColor(1.0, 0.0, 0.0, 0.5);
					Genesis_GUIHealCurrentTargetBarTexture:SetVertexColor(1.0, 0.0, 0.0, 0.5);
					Genesis_GUIHealCurrentAfterBarTexture:SetVertexColor(1.0, 0.0, 0.0, 0.5);
					Genesis_GUIHealCurrentOverhealBarTexture:SetVertexColor(1.0, 0.0, 0.0, 0.5);
				end
			else
				Genesis_GUIHealCurrentSpellBarTexture:SetVertexColor(0.0, 1.0, 0.0, 0.5);
				Genesis_GUIHealCurrentTargetBarTexture:SetVertexColor(0.0, 1.0, 0.0, 0.5);
				Genesis_GUIHealCurrentAfterBarTexture:SetVertexColor(0.0, 1.0, 0.0, 0.5);
				Genesis_GUIHealCurrentOverhealBarTexture:SetVertexColor(0.0, 1.0, 0.0, 0.5);
			end
			if (Genesis_healing[giah][C_my_name]["CastTime"] == 0) then
				Genesis_healing[giah][C_my_name]["Complete"] = 1;
			end
		end
	end
	if (not Genesis_GUI:IsVisible()) then
		if (timeleft <= -4) then
			Genesis_GUIHealCurrent:Hide();
		elseif (timeleft <= -3) then
			Genesis_GUIHealCurrent:SetAlpha(4 + timeleft);
		end
	end
end

function Genesis_UpdateHealing(elapsed)
	-- update the data about everyone's healing
	for who, data in Genesis_healing do
		for author, moredata in Genesis_healing[who] do
			Genesis_healing[who][author]["TimeLeft"] = moredata["TimeLeft"] - elapsed;
			local bar;
			if (Genesis_healing[who][author]["Bar"]) then
				bar = getglobal("Genesis_GUIHealBars" .. moredata["Bar"]);
			end
			if (Genesis_healing[who][author]["TimeLeft"] < -4) then
				if (Genesis_i_am_healing == who) then
					Genesis_i_am_healing = nil;
				end
				Genesis_healing[who][author] = nil;
			end
			if ((GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) and (Genesis_data["show_healing_all"] == 1 or (Genesis_data["show_healing_me"] == 1 and who == C_my_name) or not Genesis_healing[who][author])) then
				if (Genesis_healing[who][author] and bar) then
					bar:SetMinMaxValues(0, moredata["CastTime"]);
					bar:SetValue(moredata["CastTime"] - Genesis_healing[who][author]["TimeLeft"]);
					if (moredata["Status"] == "Failed" or moredata["Status"] == "Interrupted") then
						getglobal(bar:GetName() .. "BarTexture"):SetVertexColor(1.0, 0.0, 0.0, 0.5);
					elseif (moredata["Status"] == "Stop") then
						getglobal(bar:GetName() .. "BarTexture"):SetVertexColor(0.0, 1.0, 0.0, 0.5);
					end
					if (Genesis_healing[who][author]["TimeLeft"] <= -3 and not Genesis_GUI:IsVisible()) then
						bar:SetAlpha(4 + Genesis_healing[who][author]["TimeLeft"]);
					end
				elseif (Genesis_healing[who][author] and Genesis_healing[who][author]["CastTime"] > 0) then
					for a = 1, 15 do
						bar = getglobal("Genesis_GUIHealBars" .. a);
						if (bar:GetMinMaxValues() == 666 or (bar.author and bar.author == author)) then
							if (bar.who and bar.author and not (bar.who == who and bar.author == author) and Genesis_healing[bar.who]) then
								-- to prevent another healing to fade out or new healing
								Genesis_healing[bar.who][bar.author] = nil;
							end
							Genesis_healing[who][author]["Bar"] = a;
							bar:SetMinMaxValues(0, moredata["CastTime"]);
							bar:SetValue(moredata["CastTime"] - Genesis_healing[who][author]["TimeLeft"]);
							getglobal(bar:GetName() .. "Text"):SetText(author .. "(" .. math.floor(moredata["Heal"]) .. ") -> " .. who);
							getglobal(bar:GetName() .. "BarTexture"):SetVertexColor(1.0, 0.7, 0.0, 0.5);
							bar.author = author;
							bar.who = who;
							bar:SetAlpha(1.0);
							bar:Show();
							a = 15;
						end
					end
				elseif (bar) then
					bar:SetMinMaxValues(666, 1337);
					bar:SetValue(666);
					getglobal(bar:GetName() .. "Text"):SetText("Genesis heal bar");
					bar.author = nil;
					bar.who = nil;
					if (not Genesis_GUI:IsVisible()) then
						bar:Hide();
					end
				end
			end
		end
	end
end

function Genesis_UpdateItemHealBonus()
	-- update the heal bonus we get from our equipment
	Genesis_item_heal_bonus = 0;
	local set_bonus_applied = {};
	for slot = 1, 19 do
		local item = GetInventoryItemLink("player", slot);
		if (item and Genesis_item_heal_bonus_cache[item] and (slot == 16 or slot == 17)) then
			local a, b, c, d, e, f = GetWeaponEnchantInfo();
			if (slot == 16 and ((a and not Genesis_main_hand_enchant) or (not a and Genesis_main_hand_enchant))) then
				-- main hand lost/got enchant, rescan
				Genesis_item_heal_bonus_cache[item] = nil;
				Genesis_main_hand_enchant = a;
			end
			if (slot == 17 and ((d and not Genesis_off_hand_enchant) or (not d and Genesis_off_hand_enchant))) then
				-- off hand lost/got enchant, rescan
				Genesis_item_heal_bonus_cache[item] = nil;
				Genesis_off_hand_enchant = d;
			end
		end
		if (item and Genesis_item_heal_bonus_cache[item]) then
			-- cache to speed it up a bit
			Genesis_item_heal_bonus = Genesis_item_heal_bonus + Genesis_item_heal_bonus_cache[item];
		elseif (item) then
			C_ClearTooltip();
			if (C_Tooltip:SetInventoryItem("player", slot)) then
				for line = 1, C_Tooltip:NumLines() do
					local itemtext = getglobal("C_TooltipTextLeft" .. line):GetText();
					if (itemtext and itemtext ~= "" and not set_bonus_applied[itemtext] and not string.find(itemtext, Genesis_set_bonus_inactive_text)) then
						for index, healtext in Genesis_item_heal_bonus_text do
							local start, stop, bonus = string.find(itemtext, healtext);
							Genesis_item_heal_bonus = Genesis_item_heal_bonus + (bonus or 0);
							Genesis_item_heal_bonus_cache[item] = (Genesis_item_heal_bonus_cache[item] or 0) + (bonus or 0);
						end
						if (string.find(itemtext, Genesis_set_bonus_active_text)) then
							set_bonus_applied[itemtext] = 1;
						end
					end
				end
			end
		end
	end
end

function Genesis_UpdateSetting()
	if (not this or not this.variable) then
		return;
	end
	local variable = this.variable;
	local start, stop, pre = string.find(variable, "^([%w%s:_%-]+)");
	if (not pre) then
		return;
	end
	local value;
	if (string.find(this:GetName(), "^Genesis_GUI.*Slider$")) then
		-- a slider
		value = math.floor(this:GetValue() * 100 + 0.5) / 100;
		if (this:GetName() == "Genesis_GUIAutocancelTimeSlider") then
			getglobal(this:GetName() .. "High"):SetText(value * 1000 .. " ms");
		elseif (this:GetName() == "Genesis_GUIUpdatePlayerDataTimeSlider") then
			value = value / 10;
			getglobal(this:GetName() .. "High"):SetText(value .. " ms");
		elseif (this:GetName() == "Genesis_GUIHealStrategySlider") then
			getglobal(this:GetName() .. "High"):SetText(Genesis_GUI_heal_strategies[value]);
		elseif (string.find(this:GetName(), "Genesis_GUIHeal.+ModifierSlider")) then
			getglobal(this:GetName() .. "High"):SetText(Genesis_GUI_keys[value]);
		elseif (string.find(this:GetName(), "RankSlider")) then
			if (value == 0) then
				getglobal(this:GetName() .. "High"):SetText(Genesis_GUI_max);
			else
				getglobal(this:GetName() .. "High"):SetText(value);
			end
		else
			getglobal(this:GetName() .. "High"):SetText(value * 100 .. "%");
		end
	elseif (string.find(this:GetName(), "^Genesis_GUI.*CheckButton$")) then
		-- a checkbutton
		if (this:GetChecked()) then
			value = 1;
			if (this:GetName() == "Genesis_GUIShowHealingAllCheckButton") then
				Genesis_data["show_healing_me"] = 0;
				Genesis_GUIShowHealingMeCheckButton:SetChecked(0);
			elseif (this:GetName() == "Genesis_GUIShowHealingMeCheckButton") then
				Genesis_data["show_healing_all"] = 0;
				Genesis_GUIShowHealingAllCheckButton:SetChecked(0);
			end
		else
			value = 0;
		end
	else
		return;
	end
	-- this one is kinda cool, but at the same time quite a hack =)
	local args = {};
	for index in string.gfind(variable, "%[\"?([^%[%]\"]+)\"?%]") do
		if ((string.find(index, "Genesis_") or string.find(index, "C_")) and getglobal(index)) then
			-- we want to index the value of this variable, not the text itself
			index = getglobal(index);
		end
		table.insert(args, index);
	end
	if (table.getn(args) == 0) then
		if (pre == "C_update_player_data_time") then
			C_update_player_data_time = value;
		end
	elseif (table.getn(args) == 1) then
		getglobal(pre)[args[1]] = value;
	elseif (table.getn(args) == 2) then
		getglobal(pre)[args[1]][args[2]] = value;
	elseif (table.getn(args) == 3) then
		getglobal(pre)[args[1]][args[2]][args[3]] = value;
	elseif (table.getn(args) == 4) then
		getglobal(pre)[args[1]][args[2]][args[3]][args[4]] = value;
	elseif (table.getn(args) == 5) then
		getglobal(pre)[args[1]][args[2]][args[3]][args[4]][args[5]] = value;
	end
end

function Genesis_UpdateSpells()
	-- update the data about our healing spells
	Genesis_party_heal_spells = {
		[C_Chain_heal] = 0,
		[C_Holy_nova] = 0,
		[C_Prayer_of_healing] = 0,
		[C_Tranquility] = 0
	};
	Genesis_player_heal_spells = {
		[C_Blessing_of_protection] = 0,
		[C_Flash_heal] = 0,
		[C_Flash_of_light] = 0,
		[C_Greater_heal] = 0,
		[C_Heal] = 0,
		[C_Healing_touch] = 0,
		[C_Healing_wave] = 0,
		[C_Holy_light] = 0,
		[C_Holy_shock] = 0,
		[C_Lesser_heal] = 0,
		[C_Lesser_healing_wave] = 0,
		[C_Power_word_shield] = 0,
		[C_Regrowth] = 0,
		[C_Rejuvenation] = 0,
		[C_Renew] = 0,
		[C_Swiftmend] = 0
	};
	Genesis_spells = {};
	local spellid = 1;
	local spellname = GetSpellName(spellid, BOOKTYPE_SPELL);
	while (spellname) do
		if (Genesis_heal_spells_text[spellname]) then
			local start, stop;
			if (not Genesis_spells[spellname]) then
				Genesis_spells[spellname] = {};
				rank = 1;
			else
				rank = table.getn(Genesis_spells[spellname]) + 1;
			end
			if (Genesis_party_heal_spells[spellname]) then
				Genesis_party_heal_spell = spellname;
			end
			Genesis_spells[spellname][rank] = (Genesis_spells[spellname][rank] or {});
			Genesis_spells[spellname][rank]["ID"] = spellid;
			local mana, range, casttime, text = C_GetSpellData(spellid, BOOKTYPE_SPELL);
			Genesis_spells[spellname][rank]["Mana"] = mana;
			Genesis_spells[spellname][rank]["CastTime"] = casttime;
			local realcasttime = casttime;
			if (C_my_class == C_Druid and spellname == C_Healing_touch) then
				local crap1, crap2, crap3, crap4, crank, mrank = GetTalentInfo(3, 3);
				realcasttime = realcasttime + crank * 0.1;
			elseif (C_my_class == C_Priest and (spellname == C_Heal or spellname == C_Greater_heal)) then
				local crap1, crap2, crap3, crap4, crank, mrank = GetTalentInfo(2, 5);
				realcasttime = realcasttime + crank * 0.1;
			elseif (C_my_class == C_Shaman and spellname == C_Healing_wave) then
				local crap1, crap2, crap3, crap4, crank, mrank = GetTalentInfo(3, 1);
				realcasttime = realcasttime + crank * 0.1;
			end
			Genesis_spells[spellname][rank]["RealCastTime"] = realcasttime;
			Genesis_spells[spellname][rank]["Range"] = range;
			Genesis_spells[spellname]["Texture"] = GetSpellTexture(spellid, BOOKTYPE_SPELL);
			-- ok, we have a slight trouble here:
			-- if a spell got cooldown, it'll add a number to the description "cooldown remaining: x sec"
			-- which means we'll have to search for an extra number
			local a = {};
			start, stop, cooldown, a[1], a[2], a[3], a[4], a[5], a[6] = string.find(text, Genesis_heal_spells_search[spellname] .. "(%d+%.?%d*)[^%d]+");
			if (not start) then
				-- apparently no cooldown in the description
				start, stop, a[1], a[2], a[3], a[4], a[5], a[6] = string.find(text, Genesis_heal_spells_search[spellname]);
			end
			if (start) then
				for index, value in Genesis_heal_spells_text[spellname] do
					Genesis_spells[spellname][rank][value] = a[index] / 1.0;
				end
			end
			if (Genesis_player_heal_spells[spellname]) then
				Genesis_player_heal_spells[spellname] = 1;
			end
		end
		spellid = spellid + 1;
		spellname = GetSpellName(spellid, BOOKTYPE_SPELL);
	end
	-- clean up a bit
	Genesis_party_heal_spells = nil;
	for spell, value in Genesis_player_heal_spells do
		if (value == 0) then
			-- player don't have spell, remove it
			Genesis_player_heal_spells[spell] = nil;
		end
	end
end

function Genesis_UseAction(slot, checkCursor, onSelf)
	-- our own "UseAction" method
	if (Genesis_data["hook_useaction"] == 0 or CursorHasItem() or CursorHasMoney() or CursorHasSpell() or not Genesis_data) then
		-- placing something on the action bar?
		return Genesis_original_UseAction(slot, checkCursor, onSelf);
	end
	if (GetActionText(slot)) then
		-- this slot does not seem to be a spell, no hooking
		return Genesis_original_UseAction(slot, checkCursor, onSelf);
	end
	local spell, rank = Genesis_GetActionSpell(slot);
	if (not Genesis_spells) then
		Genesis_UpdateSpells();
	end
	if (Genesis_data["hook_shields"] == 0 and (spell == C_Power_word_shield or spell == C_Blessing_of_protection)) then
		-- popular demand to not hook the priest shield... oh well, suckers :p
		return Genesis_original_UseAction(slot, checkCursor, onSelf);
	end
	-- let's see if it's a healing spell in this slot
	if (not Genesis_player_heal_spells[spell]) then
		-- it isn't, just run the original UseAction
		return Genesis_original_UseAction(slot, checkCursor, onSelf);
	end
	-- in case we're using the special "holy shock"
	if (spell == C_Holy_shock and UnitExists("target") and not UnitIsFriend("player", "target")) then
		return Genesis_original_UseAction(slot, checkCursor, onSelf);
	end
	-- okay, so apparently we did click on a healing spell. time for magic
	if (not Genesis_ActionHeal(spell, rank)) then
		return Genesis_original_UseAction(slot, checkCursor, onSelf);
	end
end
