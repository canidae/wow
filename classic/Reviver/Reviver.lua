function Reviver_FindDeadPlayer()
	-- find a dead player
	if (not Reviver_spell_id and not Reviver_FindReviveSpell()) then
		-- can't find a reviving spell
		C_Error("Unable to find a spell that revives people");
		return;
	end
	-- target
	if (UnitExists("target") and UnitIsFriend("player", "target") and UnitIsDead("target")) then
		return Reviver_Revive("target");
	elseif (UnitExists("target") and UnitIsFriend("player", "target")) then
		C_Error(UnitName("target") .. " ain't dead, buddy");
		return;
	end
	-- party/raid
	local tmppor = "raid";
	local players = GetNumRaidMembers();
	if (players == 0) then
		tmppor = "party";
		players = GetNumPartyMembers();
	end
	local revivers = {};
	local others = {};
	for a = 1, players do
		local unit = tmppor .. a;
		if (UnitExists(unit) and UnitIsDead(unit) and (not Reviver_last_revived or Reviver_last_revived ~= unit) and (not Reviver_being_revived or not Reviver_being_revived[UnitName(unit)])) then
			if (UnitClass(unit) == C_Priest or UnitClass(unit) == C_Paladin or UnitClass(unit) == C_Shaman) then
				table.insert(revivers, unit);
			else
				table.insert(others, unit);
			end
		end
	end
	local triedtorevive;
	-- first we try classes able to revive other people
	while (table.getn(revivers) > 0) do
		local index = math.random(1, table.getn(revivers));
		local unit = table.remove(revivers, index);
		if (Reviver_Revive(unit)) then
			-- casting
			return;
		end
		triedtorevive = 1;
	end
	-- then the others
	while (table.getn(others) > 0) do
		local index = math.random(1, table.getn(others));
		local unit = table.remove(others, index);
		if (Reviver_Revive(unit)) then
			-- casting
			return;
		end
		triedtorevive = 1;
	end
	if (Reviver_last_revived) then
		-- only 1 left we can revive and we've revived player earlier
		-- try again if this player still is dead
		if (UnitExists(Reviver_last_revived) and UnitIsDead(Reviver_last_revived)) then
			if (Reviver_Revive(Reviver_last_revived)) then
				-- seems like we're reviving someone
				return;
			end
			triedtorevive = 1;
		end
	end
	if (not triedtorevive) then
		-- just give me the manual cast cursor thingy
		CastSpell(Reviver_spell_id, 1);
	end
end

function Reviver_FindReviveSpell()
	-- let's see if we got a spell that can revive people
	if (not Reviver_Revives) then
		return;
	end
	local a = 1;
	local found;
	local spellname, spellrank = GetSpellName(a, 1);
	while (spellname) do
		if (Reviver_Revives[spellname]) then
			found = 1;
			Reviver_spell_id = a;
		end
		if (found and not Reviver_Revives[spellname]) then
			-- we've found all our reviving spells
			-- return here
			local mana, range, casttime, text = C_GetSpellData(a, BOOKTYPE_SPELL);
			Reviver_spell_casttime = casttime;
			return 1;
		end
		a = a + 1;
		spellname, spellrank = GetSpellName(a, 1);
	end
	return;
end

function Reviver_OnEvent()
	if (event == "VARIABLES_LOADED") then
		C_variables_loaded = 1;
		if (Broadcast_Register) then
			Broadcast_Register("Reviver", Reviver_Receive);
		end
	elseif (event == "SPELLCAST_FAILED") then
		-- spellcast failed, used to track down errors detected on client side
		Reviver_spellcast_failed = 1;
	elseif (event == "LEARNED_SPELL_IN_TAB") then
		-- we learned a new spell, which means we'll have to find our reviving spell again
		Reviver_spell_id = nil;
		Reviver_spell_casttime = nil;
	end
end

function Reviver_OnLoad()
	this:RegisterEvent("LEARNED_SPELL_IN_TAB");
	this:RegisterEvent("SPELLCAST_FAILED");
	this:RegisterEvent("VARIABLES_LOADED");

	SLASH_Reviver1 = "/revive";
	SlashCmdList["Reviver"] = function(command)
		Reviver_FindDeadPlayer();
	end
end

function Reviver_OnUpdate(arg1)
	if (not Reviver_being_revived) then
		return;
	end
	for name, data in Reviver_being_revived do
		local percent = (data["Timeleft"] or 1) / (data["Casttime"] or 1);
		if (data["PlayerOrPet"] == "player" and UnitName("player") == name) then
			-- update playerframe
			Reviver_UpdateFrame(PlayerFrameHealthBar, percent);
		elseif (data["PlayerOrPet"] == "pet" and UnitName("pet") == name) then
			-- update petframe
			Reviver_UpdateFrame(PetFrameHealthBar, percent);
		elseif (((data["PlayerOrPet"] == "player" and UnitIsPlayer(unit)) or (data["PlayerOrPet"] == "pet" and not UnitIsPlayer(unit))) and UnitName("target") == name) then
			-- update target frame
			Reviver_UpdateFrame(TargetFrameHealthBar, percent);
		end
		for a = 1, GetNumPartyMembers() do
			if (data["PlayerOrPet"] == "player" and UnitName("party" .. a) == name) then
				-- update partyframe
				Reviver_UpdateFrame(getglobal("PartyMemberFrame" .. a .. "HealthBar"), percent)
			elseif (data["PlayerOrPet"] == "pet" and UnitName("partypet" .. a) == name) then
				-- update partypetframe
				Reviver_UpdateFrame(getglobal("PartyMemberFrame" .. a .. "PetFrameHealthBar"), percent)
			end
		end
		for a = 1, 12 do
			for b = 1, 15 do
				local rpb = getglobal("RaidPullout" .. a .. "Button" .. b);
				if (rpb and rpb.unit and UnitName(rpb.unit) == name) then
					-- update raidpulloutframe
					Reviver_UpdateFrame(getglobal(rpb:GetName() .. "HealthBar"), percent);
				end
			end
		end
		if (Reviver_being_revived[name]["Timeleft"]) then
			Reviver_being_revived[name]["Timeleft"] = data["Timeleft"] - arg1;
			if (Reviver_being_revived[name]["Timeleft"] < 0) then
				Reviver_being_revived[name] = nil;
			end
		end
	end
end

function Reviver_Receive(author, message)
	if (not C_GetUnitID(author, "player")) then
		-- this person isn't in my party/raid, ignore person
		return;
	end
	local start, stop, who, pop, casttime = string.find(message, "^(.+), (.+), (%d+%.?%d*)");
	if (not start) then
		return;
	end
	if (not C_GetUnitID(who, pop)) then
		-- unknown unit
		return;
	end
	-- we handle the "Revive" actions
	casttime = casttime / 1.0;
	if (not Reviver_being_revived) then
		Reviver_being_revived = {};
	end
	Reviver_being_revived[who] = {
		["Casttime"] = casttime,
		["PlayerOrPet"] = pop,
		["Timeleft"] = casttime
	};
end

function Reviver_Revive(unit)
	-- cast our reviving spell on this unit
	-- broadcast if we got the broadcast addon as well
	if (not Reviver_spell_id and not Reviver_FindReviveSpell()) then
		-- can't find a reviving spell
		C_Error("Unable to find a spell that revives people");
		return;
	end
	if (not unit or not UnitExists(unit)) then
		C_Error("Unknown unit");
		return;
	end
	Reviver_spellcast_failed = nil;
	CastSpell(Reviver_spell_id, 1);
	if (SpellIsTargeting()) then
		SpellTargetUnit(unit);
	end
	if (not Reviver_spellcast_failed and not SpellIsTargeting()) then
		-- seems like we're reviving someone
		local pop = "player";
		if (not UnitIsPlayer(unit)) then
			pop = "pet";
		end
		if (Broadcast_Message and Reviver_spell_casttime) then
			-- broadcast who we're reviving
			Broadcast_Message("Reviver", UnitName(unit) .. ", " .. pop .. ", " .. Reviver_spell_casttime);
		end
		-- and just in case we don't have broadcast
		if (not Reviver_being_revived) then
			Reviver_being_revived = {};
		end
		Reviver_being_revived[UnitName(unit)] = {
			["Casttime"] = Reviver_spell_casttime,
			["PlayerOrPet"] = pop,
			["Timeleft"] = Reviver_spell_casttime
		};
		return 1;
	end
	C_Error("Unable to revive " .. UnitName(unit));
end

function Reviver_UpdateFrame(statusbar, percent)
	if (not statusbar) then
		return;
	end
	local min, max = statusbar:GetMinMaxValues();
	statusbar:SetValue(math.floor(max * percent));
	statusbar:SetStatusBarColor(0.0, 0.7, 1.0);
end
