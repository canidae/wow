DROPRATE_VERSION = "3.10";

-- the next variables are used to keep track of what
-- we've got from looting the last n corpses/chests/boxes
DROPRATE_LOOT_RADIUS = 0.0010;
DROPRATE_LOOT_HISTORY = 4;
DROPRATE_LOOT_COUNTER = 1;
DROPRATE_LOOTED = {};
DROPRATE_LASTLOOT = {};
DROPRATE_ITEM_COLOR = {
	[0] = {
		r = 0.47,
		g = 0.47,
		b = 0.47
	},
	[1] = {
		r = 0.8,
		g = 0.8,
		b = 0.8
	},
	[2] = {
		r = 0,
		g = 1.0,
		b = 0
	},
	[3] = {
		r = 0,
		g = 0.384,
		b = 1.0
	},
	[4] = {
		r = 0.47,
		g = 0,
		b = 1.0
	},
	[5] = {
		r = 1.0,
		g = 0.47,
		b = 0
	},
	[6] = {
		r = 1.0,
		g = 0,
		b = 0
	}
};

function DropRate_OnLoad()
	this:RegisterEvent("LOOT_OPENED");
	this:RegisterEvent("LOOT_SLOT_CLEARED");
	this:RegisterEvent("LOOT_CLOSED");
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF");
	this:RegisterEvent("SPELLCAST_START");
	this:RegisterEvent("SPELLCAST_STOP");
	this:RegisterEvent("SPELLCAST_FAILED");
	this:RegisterEvent("SPELLCAST_INTERRUPTED");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("CHAT_MSG_LOOT");
	SLASH_DROPRATECMD1 = "/dr";
	SlashCmdList["DROPRATECMD"] = function(msg)
		DropRate_Cmd(msg);
	end

	DropRate_Print("|cffead9acDropRate v" .. DROPRATE_VERSION .. " kickin'. \"/dr\" for usage ;)");
end

function DropRate_IsLooted(x, y, unit, level)
	-- let's see if it's a chance that this unit has been looted before
	-- if so, we don't want to increase the lootcounter for this unit
	-- go thru the most recent lootings to speed up things
	if DROPRATE_TREASURE_TYPE == DROPRATE_MINING then
		-- mining, not looted before
		DROPRATE_TREASURE_TYPE = nil;
		return;
	end
	if DROPRATE_LOOT_IS_SKIN then
		-- just skinned someone, not looted before
		return;
	end
	for a = (DROPRATE_LOOT_COUNTER - 1), 1, -1 do
		local data = DROPRATE_LOOTED[a];
		if data and DropRate_CheckMatch(x, y, unit, level, data["x"], data["y"], data["unit"], data["level"], data["loot"]) == 1 then
			-- no go, seems like this corpse/chest/box has been looted before
			return 1;
		end
	end
	-- no? go thru the older ones aswell, then
	for a = DROPRATE_LOOT_HISTORY, DROPRATE_LOOT_COUNTER, -1 do
		local data = DROPRATE_LOOTED[a];
		if data and DropRate_CheckMatch(x, y, unit, level, data["x"], data["y"], data["unit"], data["level"], data["loot"]) == 1 then
			-- no go, seems like this corpse/chest/box has been looted before
			return 1;
		end
	end
	return;
end

function DropRate_CheckMatch(x1, y1, unit1, level1, x2, y2, unit2, level2, loot)
	-- this function checks if the gives looting data may match
	-- first check that x2 and y2 is set, coz if they're not,
	-- this function is utterly useless :p
	if not x1 or not y1 or not x2 or not y2 or (x1 == 0 and y1 == 0) or (x2 == 0 and y2 == 0) then
		return 0;
	end
	local xdist = math.abs(x1 - x2);
	local ydist = math.abs(y1 - y2);
	local hyp = math.sqrt((xdist * xdist) + (ydist * ydist));
	-- check if we're within the given "loot radius"
	if hyp > DROPRATE_LOOT_RADIUS then
		-- we're outside the loot radius. probably not the same loot
		return 0;
	end
	-- okay, so we're within the loot radius... not good
	-- let's see... if unit1, unit2, level1 and level2 are set
	-- then we can check them up against eachother
	-- if they don't match: good!
	if unit1 and level1 and unit2 and level2 then
		-- all the needed variables are set
		-- let's compare :)
		if unit1 == unit2 and level1 == level2 then
			-- still looks like it's the same loot
			-- but let's check if there's some loot stored aswell
			local a = 1;
			local match = 1;
			while (DROPRATE_LASTLOOT[a] and loot[a]) do
				local last = DROPRATE_LASTLOOT[a];
				local curr = loot[a];
				if last["item"] ~= curr["item"] or last["amount"] ~= curr["amount"] then
					match = 0;
				end
				a = a + 1;
			end
			if match == 1 and not DROPRATE_LASTLOOT[a] and not loot[a] then
				-- everythin match... same loot
				return 1;
			end
		end
	else
		-- some of them are not set
		-- can't match, and must assume it's the same loot :(
		return 1;
	end
	-- unit1 didn't match with unit2 or level1 didn't match with level2
	-- not the same loot :)
	return 0;
end

function DropRate_OnEvent()
	if DROPRATE_TREASURE_LOOT and event ~= "LOOT_OPENED" and event ~= "LOOT_CLOSED" then
		-- argh... you can open a treasure that doesn't open a loot window
		-- what a pain :\
		-- this is not 100% accurate, but better than nothing :(
		DROPRATE_TREASURE_LOOT = nil;
	end
	if event == "VARIABLES_LOADED" then
		DropRate_VariablesLoaded();
	elseif event == "CHAT_MSG_LOOT" then
		if arg1 and string.find(arg1, ".+%s+" .. DROPRATE_RECEIVES .. ".*:%s+.+%.") then
			-- someone in my party received loot
			-- figure out who and that persons position
			-- since we don't know the amount of items that was picked up (unless it was me)
			-- we simply set an area where droprate won't count lootings from units
			-- with same name and level
			local start, stop, who, what = string.find(arg1, "(.+)%s+" .. DROPRATE_RECEIVES .. ".*:%s+(.+)%.");
			for a = 1, GetNumPartyMembers() do
				if UnitName("party" .. a) == who then
					-- this is the one who received loot
					local x, y = GetPlayerMapPosition("party" .. a);
					local data = {};
					-- check that this corpse hasn't been looted before:
					if DropRate_IsLooted(x, y, nil, nil) then
						-- corpse has been looted before, don't insert more data in the array
						return;
					end
					data["x"] = x;
					data["y"] = y;
					-- possible to get the target name and target level of
					-- this party member?
					DROPRATE_LOOTED[DROPRATE_LOOT_COUNTER] = data;
					DROPRATE_LOOT_COUNTER = math.mod(DROPRATE_LOOT_COUNTER, DROPRATE_LOOT_HISTORY);
					DROPRATE_LOOT_COUNTER = DROPRATE_LOOT_COUNTER + 1;
				end
			end
		end
	elseif event == "CHAT_MSG_SPELL_SELF_BUFF" and arg1 and DROPRATE_TREASURE then
		local start, stop;
		start, stop, DROPRATE_TREASURE_TYPE, DROPRATE_TREASURE_LOOT = string.find(arg1, DROPRATE_TREASURE);
		if not DROPRATE_TREASURE_TYPE or (DROPRATE_TREASURE_TYPE ~= DROPRATE_OPENING and DROPRATE_TREASURE_TYPE ~= DROPRATE_HERB_GATHERING and DROPRATE_TREASURE_TYPE ~= DROPRATE_MINING) then
			DROPRATE_TREASURE_LOOT = nil;
		end
	elseif event == "SPELLCAST_START" and arg1 and arg1 == DROPRATE_SKINNING then
		-- we're skinning now! set loot to be skin
		DROPRATE_LOOT_IS_SKIN = 1;
	elseif event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
		-- skinning failed or was interrupted :\
		DROPRATE_LOOT_IS_SKIN = nil;
	elseif event == "LOOT_OPENED" then
		DROPRATE_LOOT_OPEN = 1;
		local name = UnitName("target");
		local level = UnitLevel("target");
		local x, y = GetPlayerMapPosition("player");
		local rarematch = 0;
		local rarefound = 0;
		if DROPRATE_TREASURE_LOOT then
			-- we just opened a treasure, change name to the name of the treasure :)
			name = DROPRATE_TREASURE_LOOT;
			level = nil;
			DROPRATE_TREASURE_LOOT = nil;
		else
			if not name or UnitIsPlayer("target") or IsFishingLoot() or UnitIsFriend("player", "target") or not UnitIsDead("target") then
				return;
			end
		end

		-- store all the loot just to check if this is the same loot as an earlier loot
		for a = 1, GetNumLootItems() do
			local icon, item, amount, rarity = GetLootSlotInfo(a);
			local data = {};
			data["icon"] = icon;
			data["item"] = item;
			data["amount"] = amount;
			data["rarity"] = rarity;
			DROPRATE_LASTLOOT[a] = data;
		end
		-- but we must check that we haven't looted this fellow before
		if DropRate_IsLooted(x, y, name, level) then
			-- we have looted this guy before, abort!
			return;
		end

		local dropped = drdb[name];

		if not dropped then
			dropped = {};
		end

		if not DROPRATE_TREASURE_LOOT then
			for a = 1, GetNumLootItems() do
				local icon, item, amount, rarity = GetLootSlotInfo(a);
				if amount > 0 then
					if rarity > 1 and rarefound == 0 then
						-- it's a rare item, if this rare item is the same
						-- rare item as last time we looted a corpse with a rare item
						-- then don't increase the loot counter
						if DROPRATE_LAST_RARE and DROPRATE_LAST_RARE == item then
							-- yep, same rare item
							rarematch = 1;
						end
						DROPRATE_LAST_RARE = item;
						rarefound = 1;
					end
				end
			end
		end

		-- if the same rare item appear twice in a row, don't count
		if rarematch == 0 then
			-- nopes, this rare item (if any) is not the same as the last rare item
			for a = 1, GetNumLootItems() do
				local icon, item, amount, rarity = GetLootSlotInfo(a);
				if amount > 0 then
					if dropped[item] then
						dropped[item] = dropped[item] + amount;
					else
						dropped[item] = amount;
					end
					-- set the rarity of this item
					-- we do this every time in case someone
					-- got an old database or if an item of some odd
					-- reason should change rarity :p
					-- if it's skin, set rarity to -1
					if DROPRATE_LOOT_IS_SKIN then
						dritems[item] = -1;
					else
						-- you can loot skin without skinning someone first
						-- we don't want to overwrite this "rarity"
						if not dritems[item] or dritems[item] > -1 then
							dritems[item] = rarity;
						end
					end
				else
					-- money :)
					local money = 0;

					if string.find(item, ".*" .. DROPRATE_GOLD .. ".*") then
						-- unit dropped some gold
						local start, stop, tmp = string.find(item, "(%d+)%s" .. DROPRATE_GOLD);
						money = tmp * 10000;
					end
					if string.find(item, ".*" .. DROPRATE_SILVER .. ".*") then
						-- unit dropped some silver
						local start, stop, tmp = string.find(item, "(%d+)%s" .. DROPRATE_SILVER);
						money = money + tmp * 100;
					end
					if string.find(item, ".*" .. DROPRATE_COPPER .. ".*") then
						-- unit dropped some copper
						local start, stop, tmp = string.find(item, "(%d+)%s" .. DROPRATE_COPPER);
						money = money + tmp;
					end
					if money > 0 then
						if dropped["money"] then
							dropped["money"] = dropped["money"] + money;
						else
							-- money dropped, but this unit has never dropped
							-- money before... old database, or the first time this
							-- unit has been looted?
							if dropped["looted"] then
								-- unit has been looted before, assume it's an
								-- old database
								dropped["money"] = money * dropped["looted"];
							else
								-- seems to be the first time this unit is looted
								dropped["money"] = money;
							end
						end
					end
				end
			end
			if GetNumLootItems() > 0 and level and DROPRATE_LOOT_IS_SKIN then
				-- skinloot, increase skinloot counter
				dropped = DropRate_IncreaseLootCounter(dropped, "skinned");
			else
				-- normal loot, increase loot counter
				dropped = DropRate_IncreaseLootCounter(dropped, "looted");
			end
			if level and level > 0 and (not dropped["level"] or dropped["level"] < level) then
				dropped["level"] = level;
			end
			drdb[name] = dropped;
		end
		DROPRATE_LOOT_IS_SKIN = nil;
	elseif event == "LOOT_SLOT_CLEARED" then
		-- simply clear this slot
		DROPRATE_LASTLOOT[arg1] = nil;
		-- and move the items next in the list a step up (if any)
		local a = arg1;
		while (DROPRATE_LASTLOOT[a + 1]) do
			DROPRATE_LASTLOOT[a] = DROPRATE_LASTLOOT[a + 1];
			a = a + 1;
		end
	elseif event == "LOOT_CLOSED" then
		if not DROPRATE_LOOT_OPEN then
			-- loot was never opened, but closed
			-- this means there was no loot, and as you always get loot when
			-- skinning this means it was a normal loot
			-- increase the normal loot counter
			local name = UnitName("target");
			local level = UnitLevel("target");
			if DROPRATE_TREASURE_LOOT then
				-- we just opened a treasure, change name to the name of the treasure :)
				name = DROPRATE_TREASURE_LOOT;
				level = nil;
				DROPRATE_TREASURE_LOOT = nil;
			else
				if not name or UnitIsPlayer("target") or IsFishingLoot() or UnitIsFriend("player", "target") or not UnitIsDead("target") then
					return;
				end
			end

			local dropped = drdb[name];

			if not dropped then
				dropped = {};
			end
			dropped = DropRate_IncreaseLootCounter(dropped, "looted");
			if level and level > 0 and (not dropped["level"] or dropped["level"] < level) then
				dropped["level"] = level;
			end
			drdb[name] = dropped;
		else
			-- there was some loot, and now we closed the window
			-- store the loot location, unit & level (if possible) if we didn't clear out the loot
			local x, y = GetPlayerMapPosition("player");
			local name = UnitName("target");
			local level = UnitLevel("target");
			if DROPRATE_LASTLOOT[1] and not DropRate_IsLooted(x, y, name, level) then
				-- add the data to the list of remembered lootings
				local data = {};
				data["x"] = x;
				data["y"] = y;
				data["unit"] = name;
				data["level"] = level;
				data["loot"] = DROPRATE_LASTLOOT;
				DROPRATE_LOOTED[DROPRATE_LOOT_COUNTER] = data;
				DROPRATE_LOOT_COUNTER = math.mod(DROPRATE_LOOT_COUNTER, DROPRATE_LOOT_HISTORY);
				DROPRATE_LOOT_COUNTER = DROPRATE_LOOT_COUNTER + 1;
			end
		end
		DROPRATE_LOOT_OPEN = nil;
		DROPRATE_LOOT_IS_SKIN = nil;
	end
end

function DropRate_OnShow()
	-- show info in tooltip
	local lbl = getglobal("GameTooltipTextLeft1");
	if lbl and DROPRATE_VAR_LOADED and not MouseIsOver(MinimapCluster) then
		local name = lbl:GetText();
		
		if DropRate_IsFiltered(name) == 1 then
			return;
		end

		local list = DropRate_TooltipHasDropped(name);
		if list["looted"] or list["skinned"] then
			local counter = 0;
			-- match on mobname
			if list["looted"] then
				GameTooltip:AddLine("Looted " .. list["looted"] .. " times", 1.0, 1.0, 0.0);
				if list["skinned"] then
					GameTooltip:AddLine("Skinned " .. list["skinned"] .. " times", 1.0, 1.0, 0.0);
				end
				if list["gray"] then
					local percent = math.floor(1000 * list["gray"] / list["looted"] + 0.5) / 10;
					GameTooltip:AddDoubleLine("Gray drops", percent .. "% (" .. list["gray"] .. ")", DROPRATE_ITEM_COLOR[0]["r"], DROPRATE_ITEM_COLOR[0]["g"], DROPRATE_ITEM_COLOR[0]["b"], 0.9, 0.9, 0.6);
				end
				if list["white"] then
					local percent = math.floor(1000 * list["white"] / list["looted"] + 0.5) / 10;
					GameTooltip:AddDoubleLine("White drops", percent .. "% (" .. list["white"] .. ")", DROPRATE_ITEM_COLOR[1]["r"], DROPRATE_ITEM_COLOR[1]["g"], DROPRATE_ITEM_COLOR[1]["b"], 0.9, 0.9, 0.6);
				end
				if list["green"] then
					local percent = math.floor(1000 * list["green"] / list["looted"] + 0.5) / 10;
					GameTooltip:AddDoubleLine("Green drops", percent .. "% (" .. list["green"] .. ")", DROPRATE_ITEM_COLOR[2]["r"], DROPRATE_ITEM_COLOR[2]["g"], DROPRATE_ITEM_COLOR[2]["b"], 0.9, 0.9, 0.6);
				end
				if list["blue"] then
					local percent = math.floor(1000 * list["blue"] / list["looted"] + 0.5) / 10;
					GameTooltip:AddDoubleLine("Blue drops", percent .. "% (" .. list["blue"] .. ")", DROPRATE_ITEM_COLOR[3]["r"], DROPRATE_ITEM_COLOR[3]["g"], DROPRATE_ITEM_COLOR[3]["b"], 0.9, 0.9, 0.6);
				end
				if list["purple"] then
					local percent = math.floor(1000 * list["purple"] / list["looted"] + 0.5) / 10;
					GameTooltip:AddDoubleLine("Purple drops", percent .. "% (" .. list["purple"] .. ")", DROPRATE_ITEM_COLOR[4]["r"], DROPRATE_ITEM_COLOR[4]["g"], DROPRATE_ITEM_COLOR[4]["b"], 0.9, 0.9, 0.6);
				end
				if list["money"] then
					GameTooltip:AddDoubleLine("Money", list["money"], 0.6, 0.6, 0.9, 0.9, 0.9, 0.6);
				end
			elseif list["skinned"] then
				GameTooltip:AddLine("Skinned " .. list["skinned"] .. " times", 1.0, 1.0, 0.0);
			end
			local addedhasdropped;
			for index, data in list["drops"] do
				if (counter < drmaxtooltiplines) then
					if (not addedhasdropped) then
						GameTooltip:AddLine("Has dropped:", 1.0, 1.0, 0.0);
						addedhasdropped = 1;
					end
					GameTooltip:AddDoubleLine(data["itemname"], data["percent"] .. "% (" .. data["itemamount"] .. "/" .. data["looted"] .. ")", data["color"]["r"], data["color"]["g"], data["color"]["b"], 0.9, 0.9, 0.6);
				end
				counter = counter + 1;
			end
		end
		list = DropRate_TooltipDropsItem(name);
		if table.getn(list) > 0 then
			-- apparently an item, as there are mobs that drop this
			GameTooltip:AddLine("Dropped by:", 1.0, 1.0, 0.0);
			local counter = 0;
			for index, data in list do
				if (counter < drmaxtooltiplines) then
					local mobname = data["mobname"];
					if data["level"] then
						mobname = mobname .. " (lvl " .. data["level"] .. ")";
					end
					GameTooltip:AddDoubleLine(mobname, data["percent"] .. "% (" .. data["itemamount"] .. "/" .. data["looted"] .. ")", 0.6, 0.6, 0.9, 0.9, 0.9, 0.6);
				end
				counter = counter + 1;
			end
		end
		GameTooltip:Show();
	end
end

function DropRate_IncreaseLootCounter(dropped, loottype)
	if dropped[loottype] then
		dropped[loottype] = dropped[loottype] + 1;
	else
		dropped[loottype] = 1;
	end
	return dropped;
end

function DropRate_Print(message)
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(message);
	end
end

function DropRate_ResetTooltip()
	-- this one got so big i made an own function for it
	drtooltip = {};
	drtooltip[-1] = 1; -- stuff from skinning (leather, hide, scale)
	drtooltip[0] = 0; -- gray items
	drtooltip[1] = 1; -- white items
	drtooltip[2] = 1; -- green items
	drtooltip[3] = 1; -- blue items
	drtooltip[4] = 1; -- purple items
	drtooltip[5] = 1; -- money
	drtooltip[6] = 0; -- droprate gray items
	drtooltip[7] = 0; -- droprate white items
	drtooltip[8] = 0; -- droprate green items
	drtooltip[9] = 0; -- droprate blue items
	drtooltip[10] = 0; -- droprate purple items
	drtooltip[11] = 1; -- show item info
	drtooltip[12] = 1; -- show unit info
end

function DropRate_Cmd(msg)
	if msg == "" then
		msg = UnitName("target");
	end
	if not msg then
		DropRate_Print("Display info simply type: /dr <item or name>");
		DropRate_Print(" or if you've targetted an unit simply type: /dr");
		DropRate_Print("Show/hide items/money in tooltip: /dr <show/hide> <gray/white/green/blue/purple/money>");
		DropRate_Print("Show/hide droprate of items in tooltip: /dr <show/hide> rate <gray/white/green/blue/purple>");
		DropRate_Print("Show/hide info of items/units in tooltip: /dr <show/hide> <iteminfo/unitinfo>");
		DropRate_Print("Set minimum droprate for items to appear in tooltip: /dr mindroprate <0-100>");
		DropRate_Print("Set max/min range in level: /dr <maxlevel/minlevel> <level, -1 for no limit>");
		DropRate_Print("Show/hide items dropped by unit with unknown lvl: /dr <show/hide> unknown");
		DropRate_Print("Set max amount of lines in tooltip: /dr maxlines <positive value>");
		DropRate_Print("Set minimum times a unit has been looted before appearing in tooltip: /dr minlooted <positive value>");
		DropRate_Print("Show what's currently filtered: /dr filter");
		DropRate_Print("[Un]filter something: /dr [un]filter <text>");
		return;
	end

	local search = string.lower(msg);
	if string.find(search, ".*%s+.*%[.*%].*%s+.*") then
		-- in case someone shift-clicked an item
		local start, stop, before, after;
		start, stop, before, search, after = string.find(search, "(.*)%s+.*%[(.*)%].*%s+(.*)");
		if before and search then
			search = before .. " " .. search;
			if after then
				search = search .. " " .. after;
			end
		end
	elseif string.find(search, ".*%[.*%]") then
		local start, stop;
		start, stop, search = string.find(search, ".*%[(.*)%]");
	end

	if not search then
		-- search is nil? this shouldn't happen here
		DropRate_Print("An internal error occured. I refuse to carry on your command!");
		return;
	end

	if search == "reset_everything" then
		drdb = {};
		dritems = {};
		drfilter = {};
		DropRate_ResetTooltip();
		DropRate_Print("Database & filter deleted. Info will appear in tooltip. White items & money will appear in the tooltip");
	elseif search == "show leather" then
		drtooltip[-1] = 1;
		DropRate_Print("Leather will now appear in the tooltip");
	elseif search == "hide leather" then
		drtooltip[-1] = 0;
		DropRate_Print("Leather will no longer appear in the tooltip");
	elseif search == "show gray" then
		drtooltip[0] = 1;
		DropRate_Print("Gray items will now appear in the tooltip");
	elseif search == "hide gray" then
		drtooltip[0] = 0;
		DropRate_Print("Gray items will no longer appear in the tooltip");
	elseif search == "show white" then
		drtooltip[1] = 1;
		DropRate_Print("White items will now appear in the tooltip");
	elseif search == "hide white" then
		drtooltip[1] = 0;
		DropRate_Print("White items will no longer appear in the tooltip");
	elseif search == "show green" then
		drtooltip[2] = 1;
		DropRate_Print("Green items will now appear in the tooltip");
	elseif search == "hide green" then
		drtooltip[2] = 0;
		DropRate_Print("Green items will no longer appear in the tooltip");
	elseif search == "show blue" then
		drtooltip[3] = 1;
		DropRate_Print("Blue items will now appear in the tooltip");
	elseif search == "hide blue" then
		drtooltip[3] = 0;
		DropRate_Print("Blue items will no longer appear in the tooltip");
	elseif search == "show purple" then
		drtooltip[4] = 1;
		DropRate_Print("Purple items will now appear in the tooltip");
	elseif search == "hide purple" then
		drtooltip[4] = 0;
		DropRate_Print("Purple items will no longer appear in the tooltip");
	elseif search == "show money" then
		drtooltip[5] = 1;
		DropRate_Print("Money will now appear in the tooltip");
	elseif search == "hide money" then
		drtooltip[5] = 0;
		DropRate_Print("Money will no longer appear in the tooltip");
	elseif search == "show rate gray" then
		drtooltip[6] = 1;
		DropRate_Print("Droprate of gray items will now appear in the tooltip");
	elseif search == "hide rate gray" then
		drtooltip[6] = 0;
		DropRate_Print("Droprate of gray items will no longer appear in the tooltip");
	elseif search == "show rate white" then
		drtooltip[7] = 1;
		DropRate_Print("Droprate of white items will now appear in the tooltip");
	elseif search == "hide rate white" then
		drtooltip[7] = 0;
		DropRate_Print("Droprate of white items will no longer appear in the tooltip");
	elseif search == "show rate green" then
		drtooltip[8] = 1;
		DropRate_Print("Droprate of green items will now appear in the tooltip");
	elseif search == "hide rate green" then
		drtooltip[8] = 0;
		DropRate_Print("Droprate of green items will no longer appear in the tooltip");
	elseif search == "show rate blue" then
		drtooltip[9] = 1;
		DropRate_Print("Droprate of blue items will now appear in the tooltip");
	elseif search == "hide rate blue" then
		drtooltip[9] = 0;
		DropRate_Print("Droprate of blue items will no longer appear in the tooltip");
	elseif search == "show rate purple" then
		drtooltip[10] = 1;
		DropRate_Print("Droprate of purple items will now appear in the tooltip");
	elseif search == "hide rate purple" then
		drtooltip[10] = 0;
		DropRate_Print("Droprate of purple items will no longer appear in the tooltip");
	elseif search == "show iteminfo" then
		drtooltip[11] = 1;
		DropRate_Print("Iteminfo will now appear in the tooltip");
	elseif search == "hide iteminfo" then
		drtooltip[11] = 0;
		DropRate_Print("Iteminfo will no longer appear in the tooltip");
	elseif search == "show unitinfo" then
		drtooltip[12] = 1;
		DropRate_Print("Unitinfo will now appear in the tooltip");
	elseif search == "hide unitinfo" then
		drtooltip[12] = 0;
		DropRate_Print("Unitinfo will no longer appear in the tooltip");
	elseif search == "show unknown" then
		drlevelunknown = 1;
		DropRate_Print("Units with unknown level or items dropped from units with unknown level will now be shown");
	elseif search == "hide unknown" then
		drlevelunknown = 0;
		DropRate_Print("Units with unknown level or items dropped from units with unknown level will no longer be shown");
	elseif string.find(search, "minlevel%s+%-*%d+") then
		local start, stop, neg, range = string.find(search, "minlevel%s+(%-*)(%d+)");
		range = range / 1; -- a funny way to cast string to int :p
		if neg and neg == "-" then
			range = 0 - range;
		end
		if range < -1 then
			range = -1;
		end
		if UnitLevel("player") - 1 < range then
			range = UnitLevel("player") - 1;
		end
		drminlevel = range;
		if drminlevel > -1 and drmaxlevel > -1 then
			DropRate_Print("Items dropped by units with level " .. UnitLevel("player") - drminlevel .. " to " .. UnitLevel("player") + drmaxlevel .. " will appear in the tooltip");
		elseif drminlevel > -1 and drmaxlevel == -1 then
			DropRate_Print("Items dropped by units with level " .. UnitLevel("player") - drminlevel .. " and up will appear in the tooltip");
		elseif drminlevel == -1 and drmaxlevel > -1 then
			DropRate_Print("Items dropped by units with level 1 to " .. UnitLevel("player") + drmaxlevel .. " will appear in the tooltip");
		else
			DropRate_Print("Items dropped by units with level 1 and up will appear in the tooltip");
		end
	elseif string.find(search, "maxlevel%s+%-*%d+") then
		local start, stop, neg, range = string.find(search, "maxlevel%s+(%-*)(%d+)");
		range = range / 1; -- a funny way to cast string to int :p
		if neg and neg == "-" then
			range = 0 - range;
		end
		if range < -1 then
			range = -1;
		end
		drmaxlevel = range;
		if drminlevel > -1 and drmaxlevel > -1 then
			DropRate_Print("Items dropped by units with level " .. UnitLevel("player") - drminlevel .. " to " .. UnitLevel("player") + drmaxlevel .. " will appear in the tooltip");
		elseif drminlevel > -1 and drmaxlevel == -1 then
			DropRate_Print("Items dropped by units with level " .. UnitLevel("player") - drminlevel .. " and up will appear in the tooltip");
		elseif drminlevel == -1 and drmaxlevel > -1 then
			DropRate_Print("Items dropped by units with level 1 to " .. UnitLevel("player") + drmaxlevel .. " will appear in the tooltip");
		else
			DropRate_Print("Items dropped by units with level 1 and up will appear in the tooltip");
		end
	elseif string.find(search, "mindroprate%s+%d+") then
		local start, stop, mindroprate = string.find(search, "mindroprate%s+(%d+)");
		mindroprate = mindroprate / 1; -- a funny way to cast string to int :p
		if mindroprate < 0 then
			mindroprate = 0;
		elseif mindroprate > 100 then
			mindroprate = 100;
		end
		drmindroprate = mindroprate;
		DropRate_Print("Only items with a droprate of " .. mindroprate .. "% or greater will appear in the tooltip");
	elseif string.find(search, "maxlines%s+%d+") then
		local start, stop, maxlines = string.find(search, "maxlines%s+(%d+)");
		maxlines = maxlines / 1; -- a funny way to cast string to int :p
		if maxlines <= 0 then
			maxlines = 1;
		end
		drmaxtooltiplines = maxlines;
		DropRate_Print("Will only show up to " .. maxlines .. " items/mobs in the tooltip");
	elseif string.find(search, "minlooted%s+%d+") then
		local start, stop, minlooted = string.find(search, "minlooted%s+(%d+)");
		minlooted = minlooted / 1; -- a funny way to cast string to int :p
		if minlooted < 1 then
			minlooted = 1;
		end
		drminlooted = minlooted;
		if minlooted == 1 then
			DropRate_Print("Only units looted at least " .. minlooted .. " time will appear in the tooltip");
		else
			DropRate_Print("Only units looted at least " .. minlooted .. " times will appear in the tooltip");
		end
	elseif string.find(search, "^filter%s*$") then
		local words = "";
		for a = 1, table.getn(drfilter) do
			if drfilter[a] then
				words = words .. ", \"" .. drfilter[a] .. "\"";
			end
		end
		if words == "" then
			DropRate_Print("No filters applied");
		else
			words = string.sub(words, 3);
			DropRate_Print("Filtered: " .. words);
		end
	elseif string.find(search, "^filter%s*.+$") then
		local start, stop, word = string.find(search, "^filter%s*(.+)$");
		for a = 1, table.getn(drfilter) do
			if drfilter[a] == word then
				DropRate_Print("\"" .. word .. "\" is already filtered");
				return;
			end
		end
		table.insert(drfilter, word);
		DropRate_Print("\"" .. word .. "\" filtered");
	elseif string.find(search, "^unfilter%s*.+$") then
		local start, stop, word = string.find(search, "^unfilter%s*(.+)$");
		for a = 1, table.getn(drfilter) do
			if drfilter[a] == word then
				table.remove(drfilter, a);
				DropRate_Print("\"" .. word .. "\" is no longer filtered");
				return;
			end
		end
	else
		local list = DropRate_DropsItem(search);
		if table.getn(list) > 0 then
			-- apparently an item, as there are mobs that drop this
			DropRate_Print(search .. " is dropped by:");
			for a = 1, table.getn(list) do
				DropRate_Print(list[a]);
			end
		else
			list = DropRate_HasDropped(search);
			if table.getn(list) > 0 then
				-- not an item, but match on name
				DropRate_Print(search .. " has dropped:");
				for a = 1, table.getn(list) do
					DropRate_Print(list[a]);
				end
			else
				DropRate_Print(search .. " not found in the database");
			end
		end
	end
end

function DropRate_VariablesLoaded()
	if not drdb then
		drdb = {};
		dritems = {};
		drfilter = {};
		DropRate_ResetTooltip();
		drmindroprate = 0;
		drminlevel = -1;
		drmaxlevel = -1;
		drlevelunknown = 1;
		drminlooted = 1;
		drmaxtooltiplines = 10;
	else
		if not dritems then
			dritems = {};
		end
		if not drfilter then
			drfilter = {};
		end
		if not drtooltip then
			DropRate_ResetTooltip();
		end
		if not drmindroprate then
			drmindroprate = 0;
		end
		if not drminlevel then
			drminlevel = -1;
		end
		if not drmaxlevel then
			drmaxlevel = -1;
		end
		if not drlevelunknown then
			drlevelunknown = 1;
		end
		if not drminlooted then
			drminlooted = 1;
		end
		if not drmaxtooltiplines then
			drmaxtooltiplines = 10;
		end
	end
	if SIMPLEPERFORMSELFOTHER then
		DROPRATE_TREASURE = SIMPLEPERFORMSELFOTHER;
		DROPRATE_TREASURE = string.gsub(DROPRATE_TREASURE, "(%%s)", "%(%.%+%)");
		DROPRATE_TREASURE = string.gsub(DROPRATE_TREASURE, "(%%%d$s)", "%(%.%+%)");
	else
		DropRate_Print("Serious error: \"OPEN_LOCK_SELF\" does not exist!");
		DropRate_Print("Droprate from chests/mining/skinning/gathering herbs won't work");
	end
	DROPRATE_VAR_LOADED = 1;
end

function DropRate_LootedOrSkinned(item)
	-- is the given item skin or not?
	if dritems[item] == -1 then
		return "skinned";
	end
	return "looted";
end 

function DropRate_IsFiltered(word)
	for a = 1, table.getn(drfilter) do
		if string.find(string.lower(word), "^.*" .. drfilter[a] .. ".*$") then
			return 1;
		end
	end
	return 0;
end

function DropRate_ShowUnit(unitname)
	local unit = drdb[unitname];
	if not unit["level"] then
		if drlevelunknown == 1 then
			return 1;
		end
		return 0;
	end
	if (drminlevel == -1 or (unit["level"] >= UnitLevel("player") - drminlevel)) and (drmaxlevel == -1 or (unit["level"] <= UnitLevel("player") + drmaxlevel)) then
		return 1;
	end
	return 0;
end

function DropRate_DropsItem(item)
	-- who drops the given item?
	local list = {};
	
	for unitname, unitdata in pairs(drdb) do
		for itemname, itemamount in pairs(unitdata) do
			if string.lower(itemname) == item then
				local rarity = dritems[itemname];
				if not rarity then
					rarity = 1;
				end
				local loottype = DropRate_LootedOrSkinned(itemname);
				if not unitdata[loottype] then
					-- it claims the item is either:
					-- skin, but unit has never been skinned
					-- loot, but unit has never been looted
					-- this may happen with chests or if someone else skin a unit, then the player just loot the skin
					-- swap loottype
					if loottype == "skinned" then
						loottype = "looted";
					else
						loottype = "skinned";
					end
				end
				if unitdata[loottype] then
					local percent = math.floor(1000 * itemamount / unitdata[loottype] + 0.5) / 10;
					if unitdata["level"] then
						table.insert(list, unitname .. " (" .. unitdata["level"] .. "): " .. itemamount .. " (" .. percent .. "%)");
					else
						table.insert(list, unitname .. ": " .. itemamount .. " (" .. percent .. "%)");
					end
				else
					-- this really shouldn't happen
					-- write a gigantic error message to make people complain (so i can figure out the bug) :)
					DropRate_Print("Error: A unit has never been looted nor skinned, yet the database claims it has dropped stuff. Unit: " .. unitname .. ", Item: " .. itemname);
				end
			end
		end
	end
	table.sort(list);

	return list;
end

function DropRate_HasDropped(unit)
	-- what items has this target dropped?
	local list = {};
	local droprate = {};

	for unitname, unitdata in pairs(drdb) do
		if string.lower(unitname) == unit then
			for itemname, itemamount in pairs(unitdata) do
				if itemname == "looted" or itemname == "skinned" or itemname == "money" or itemname == "level" then
					-- "looted", "skinned", "money" & "level" shouldn't appear like this in the list
				else
					local rarity = dritems[itemname];
					if not rarity then
						rarity = 1;
					end
					if droprate[rarity] then
						droprate[rarity] = droprate[rarity] + 1;
					else
						droprate[rarity] = 1;
					end
					local loottype = DropRate_LootedOrSkinned(itemname);
					if not unitdata[loottype] then
						-- it claims the item is either:
						-- skin, but unit has never been skinned
						-- loot, but unit has never been looted
						-- this may happen with chests or if someone else skin a unit, then the player just loot the skin
						-- swap loottype
						if loottype == "skinned" then
							loottype = "looted";
						else
							loottype = "skinned";
						end
					end
					if unitdata[loottype] then
						local percent = math.floor(1000 * itemamount / unitdata[loottype] + 0.5) / 10;
						table.insert(list, itemname .. ": " .. itemamount .. " (" .. percent .. "%)");
					else
						-- this really shouldn't happen
						-- write a gigantic error message to make people complain (so i can figure out the bug) :)
						DropRate_Print("Error: A unit has never been looted nor skinned, yet the database claims it has dropped stuff. Unit: " .. unitname .. ", Item: " .. itemname);
					end
				end
			end
			table.sort(list);
			local money = unitdata["money"];
			if money and looted then
				-- show me the money!
				money = math.floor(money / looted);
				local tmp = "Money: ";
				if money > 10000 then
					tmp = tmp .. math.floor(money / 10000) .. "g ";
					money = money - math.floor(money / 10000) * 10000;
				end
				if money > 100 then
					tmp = tmp .. math.floor(money / 100) .. "s ";
					money = money - math.floor(money / 100) * 100;
				end
				if money > 0 then
					tmp = tmp .. money .. "c";
				end
				table.insert(list, tmp);
			end
		end
	end

	return list;
end

function DropRate_TooltipDropsItem(itemname)
	-- who drops the given item (tooltip speedup hack edition)?
	local list = {};
	local counter = 1;
	if drtooltip[11] == 0 then
		-- user don't want to show iteminfo in the tooltip
		return list;
	end

	for unitname, unitdata in pairs(drdb) do
		if unitdata[itemname] and DropRate_ShowUnit(unitname) == 1 then
			local itemamount = unitdata[itemname];
			local rarity = dritems[itemname];
			if not rarity then
				rarity = 1;
			end
			if drtooltip[rarity] == 1 then
				local loottype = DropRate_LootedOrSkinned(itemname);
				if not unitdata[loottype] then
					-- it claims the item is either:
					-- skin, but unit has never been skinned
					-- loot, but unit has never been looted
					-- this may happen with chests or if someone else skin a unit, then the player just loot the skin
					-- swap loottype
					if loottype == "skinned" then
						loottype = "looted";
					else
						loottype = "skinned";
					end
				end
				if unitdata[loottype] and unitdata[loottype] >= drminlooted then
					local percent = math.floor(1000 * itemamount / unitdata[loottype] + 0.5) / 10;
					if percent >= drmindroprate then
						list[counter] = {
							["mobname"] = unitname,
							["level"] = unitdata["level"],
							["itemamount"] = itemamount,
							["looted"] = unitdata[loottype],
							["percent"] = percent
						};
						counter = counter + 1;
					end
				elseif not unitdata[loottype] then
					-- this really shouldn't happen
					-- write a gigantic error message to make people complain (so i can figure out the bug) :)
					DropRate_Print("Error: A unit has never been looted nor skinned, yet the database claims it has dropped stuff. Unit: " .. unitname .. ", Item: " .. itemname);
				end
			end
		end
	end
	table.sort(list, function(a, b) return a["percent"] > b["percent"] end);

	return list;
end

function DropRate_TooltipHasDropped(unitname)
	-- what items has this target dropped (tooltip speedup hack edition)?
	local droprate = {};
	local list = {};
	local counter = 1;
	local unitdata = drdb[unitname];
	if drtooltip[12] == 0 then
		-- user don't want to show unitinfo in the tooltip
		return list;
	end

	if unitdata then
		list["skinned"] = unitdata["skinned"];
		list["looted"] = unitdata["looted"];
		list["drops"] = {};
		for itemname, itemamount in pairs(unitdata) do
			if itemname ~= "looted" and itemname ~= "skinned" and itemname ~= "money" and itemname ~= "level" then
				local rarity = dritems[itemname];
				if not rarity then
					rarity = 1;
				end
				if droprate[rarity] then
					droprate[rarity] = droprate[rarity] + itemamount;
				else
					droprate[rarity] = itemamount;
				end
				if DropRate_IsFiltered(itemname) == 0 and drtooltip[rarity] == 1 then
					local loottype = DropRate_LootedOrSkinned(itemname);
					if not unitdata[loottype] then
						-- it claims the item is either:
						-- skin, but unit has never been skinned
						-- loot, but unit has never been looted
						-- this may happen with chests or if someone else skin a unit, then the player just loot the skin
						-- swap loottype
						if loottype == "skinned" then
							loottype = "looted";
						else
							loottype = "skinned";
						end
					end
					if unitdata[loottype] then
						local percent = math.floor(1000 * itemamount / unitdata[loottype] + 0.5) / 10;
						if percent >= drmindroprate then
							local color;
							if (rarity < 0 or rarity > 6) then
								color = DROPRATE_ITEM_COLOR[1];
							else
								color = DROPRATE_ITEM_COLOR[rarity];
							end
							list["drops"][counter] = {
								["itemname"] = itemname,
								["itemamount"] = itemamount,
								["looted"] = unitdata[loottype],
								["color"] = color,
								["percent"] = percent
							};
							counter = counter + 1;
						end
					elseif not unitdata[loottype] then
						-- this really shouldn't happen
						-- write a gigantic error message to make people complain (so i can figure out the bug) :)
						DropRate_Print("Error: A unit has never been looted nor skinned, yet the database claims it has dropped stuff. Unit: " .. unitname .. ", Item: " .. itemname);
					end
				end
			end
		end
		table.sort(list["drops"], function(a, b) return a["percent"] > b["percent"] end);
		if drtooltip[6] == 1 and droprate[0] then
			list["gray"] = droprate[0];
		end
		if drtooltip[7] == 1 and droprate[1] then
			list["white"] = droprate[1];
		end
		if drtooltip[8] == 1 and droprate[2] then
			list["green"] = droprate[2];
		end
		if drtooltip[9] == 1 and droprate[3] then
			list["blue"] = droprate[3];
		end
		if drtooltip[10] == 1 and droprate[4] then
			list["purple"] = droprate[4];
		end
		local money = unitdata["money"];
		if money and unitdata["looted"] and drtooltip[5] == 1 then
			-- show me the money!
			money = math.floor(money / unitdata["looted"]);
			local tmp = "";
			if money > 10000 then
				tmp = tmp .. math.floor(money / 10000) .. "g ";
				money = money - math.floor(money / 10000) * 10000;
			end
			if money > 100 then
				tmp = tmp .. math.floor(money / 100) .. "s ";
				money = money - math.floor(money / 100) * 100;
			end
			if money > 0 then
				tmp = tmp .. money .. "c";
			end
			list["money"] = tmp;
		end
	end

	return list;
end
