function VT_MatchTargets(unit)
	-- check if the target of the given unit is known
	if (not unit) then
		return;
	end
	VT_checked[unit] = nil;
	if (not UnitExists(unit) or not UnitExists(unit .. "target")) then
		return;
	end
	if (VT_data["show_dead"] == 0 and UnitIsDeadOrGhost(unit .. "target")) then
		-- don't wanna show dead targets
		return;
	end
	if (VT_data["show_friendly"] == 0 and UnitIsFriend("player", unit .. "target")) then
		-- don't wanna show friendly targets
		return;
	end
	for tank, value in VT_tanks do
		if (UnitIsUnit(unit, tank) or UnitIsUnit(unit .. "target", tank .. "target")) then
			-- the tank/unit already exists in the list
			VT_tanks[tank] = value + 1;
			return;
		end
	end
	-- apparently this is a new target, set "unit" as a "tank"
	VT_tanks[unit] = 1;
end

function VT_OnEvent()
	if (event == "VARIABLES_LOADED") then
		VT_data = (VT_data or {});
		VT_data["frame_amount"] = (VT_data["frame_amount"] or 5);
		VT_data["reverse_sort"] = (VT_data["reverse_sort"] or 0);
		VT_data["show_dead"] = (VT_data["show_dead"] or 0);
		VT_data["show_friendly"] = (VT_data["show_friendly"] or 0);
		VT_data["sort_algorithm"] = (VT_data["sort_algorithm"] or 0);
		VT_data["update_interval"] = (VT_data["update_interval"] or 0.5);
	end
end

function VT_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	VT_tanks = {};
	VT_checked = {};

	SLASH_VT1 = "/vt";
	SlashCmdList["VT"] = function(msg)
		if (VT_GUI:IsVisible()) then
			VT_GUI:Hide();
		else
			VT_GUI:Show();
		end
	end
end

function VT_OnUpdate(elapsed)
	VT_update_time = (VT_update_time or 0) + elapsed;
	if (VT_update_time >= VT_data["update_interval"]) then
		VT_update_time = 0;
		VT_Scan();
	end
end

function VT_Scan()
	local players = GetNumRaidMembers();
	local por = "raid";
	-- zero the tanks
	for tank, value in VT_tanks do
		VT_tanks[tank] = nil;
	end
	if (players == 0) then
		players = GetNumPartyMembers();
		if (players == 0) then
			-- we're not in a party/raid, nothing interesting to scan
			for a = 1, 10 do
				getglobal("VT_Target" .. a):Hide();
			end
			return;
		end
		por = "party";
		-- we'll have to check "player" when in a party
		VT_MatchTargets("player");
	end
	for a = 1, players do
		local unit = por .. a;
		VT_MatchTargets(unit);
	end
	VT_UpdateFrames();
end

function VT_ShowTooltip()
	-- show the user a simple tooltip for his or hers amusement :)
	local title, description;
	local length = 0;
	for element, data in VT_GUI_help do
		if (string.find(this:GetName(), element) and string.len(element) > length) then
			title = data["Title"];
			description = data["Description"];
			length = string.len(element);
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

function VT_UpdateFrames()
	for a = 1, VT_data["frame_amount"] do
		local maxminvalue;
		local maxmintank;
		for tank, value in VT_tanks do
			if (VT_data["sort_algorithm"] == 2) then
				value = UnitHealth(tank .. "target");
			end
			if (not VT_checked[tank]) then
				if (not maxminvalue or ((VT_data["reverse_sort"] == 0 and value > maxminvalue) or (VT_data["reverse_sort"] == 1 and value < maxminvalue))) then
					maxminvalue = value;
					maxmintank = tank;
				end
			end
		end
		if (maxmintank) then
			-- this is the "tank" we want to show the target for on this frame
			VT_checked[maxmintank] = 1;
			getglobal("VT_Target" .. a .. "Bar"):SetMinMaxValues(0, UnitHealthMax(maxmintank .. "target"));
			getglobal("VT_Target" .. a .. "Bar"):SetValue(UnitHealth(maxmintank .. "target"));
			getglobal("VT_Target" .. a .. "BarText"):SetText(UnitName(maxmintank .. "target"));
			getglobal("VT_Target" .. a .. "Text"):SetText("TB: " .. VT_tanks[maxmintank] .. " | HP: " .. math.floor(100 * UnitHealth(maxmintank .. "target") / UnitHealthMax(maxmintank .. "target") + 0.5) .. "%");
			getglobal("VT_Target" .. a).target = maxmintank .. "target";
			getglobal("VT_Target" .. a):Show();
		else
			-- less than VT_data["frame_amount"] targets known, hide the frame
			getglobal("VT_Target" .. a):Hide();
		end
	end
	-- hide the rest of the frames as well
	for a = VT_data["frame_amount"] + 1, 10 do
		getglobal("VT_Target" .. a):Hide();
	end
end

function VT_UpdateSetting()
	if (not this or not this.variable) then
		return;
	end
	local variable = this.variable;
	local start, stop, pre = string.find(variable, "^([%w%s:_%-]+)");
	if (not pre) then
		return;
	end
	local value;
	if (string.find(this:GetName(), "^VT_GUI.*Slider$")) then
		-- a slider
		value = math.floor(this:GetValue() * 100 + 0.5) / 100;
		if (this:GetName() == "VT_GUIFrameAmountSlider") then
			getglobal(this:GetName() .. "High"):SetText(value);
		elseif (this:GetName() == "VT_GUISortAlgorithmSlider") then
			getglobal(this:GetName() .. "High"):SetText(VT_GUI_sort_algorithms[value]);
		elseif (this:GetName() == "VT_GUIUpdateIntervalSlider") then
			getglobal(this:GetName() .. "High"):SetText(value .. " s");
		end
	elseif (string.find(this:GetName(), "^VT_GUI.*CheckButton$")) then
		-- a checkbutton
		if (this:GetChecked()) then
			value = 1;
		else
			value = 0;
		end
	else
		return;
	end
	-- this one is kinda cool, but at the same time quite a hack =)
	local args = {};
	for index in string.gfind(variable, "%[\"?([^%[%]\"]+)\"?%]") do
		if (string.find(index, "VT_") and getglobal(index)) then
			-- we want to index the value of this variable, not the text itself
			index = getglobal(index);
		end
		table.insert(args, index);
	end
	if (table.getn(args) == 0) then
		--
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
