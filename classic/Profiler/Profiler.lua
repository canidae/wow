function Profiler_OnLoad()
	Profiler_index = 1;
end

function Profiler_Update(value, average_count, name)
	if (not value) then
		return;
	end
	if (not name) then
		name = this:GetName();
		if (not name) then
			-- ?
			return;
		end
	end
	if (not average_count) then
		average_count = 22;
	end
	if (not Profiler_item) then
		Profiler_item = {};
	end
	if (not Profiler_item[name]) then
		if (Profiler_index <= 20) then
			Profiler_item[name] = {
				["Index"] = Profiler_index,
				["Max"] = 1,
				["Updates"] = {}
			};
			getglobal("ProfilerItem" .. Profiler_index .. "Text"):SetText(name);
			getglobal("ProfilerItem" .. Profiler_index):Show();
			Profiler_index = Profiler_index + 1;
		else
			-- no more room
			return;
		end
	end
	local bar = getglobal("ProfilerItem" .. Profiler_item[name]["Index"]);
	table.insert(Profiler_item[name]["Updates"], 1, value);
	if (table.getn(Profiler_item[name]["Updates"]) > average_count) then
		table.remove(Profiler_item[name]["Updates"]);
	end
	local total = 0;
	local count = 0;
	for a = 1, table.getn(Profiler_item[name]["Updates"]) do
		if (a <= average_count) then
			total = total + Profiler_item[name]["Updates"][a];
		end
	end
	if (value > Profiler_item[name]["Max"]) then
		Profiler_item[name]["Max"] = value;
	end
	value = total / average_count;
	bar:SetValue(value);
	value = math.floor(value + 0.5);
	if (value > 6) then
		getglobal(bar:GetName() .. "BarTexture"):SetVertexColor(1.0, 0.0, 0.0, 0.5);
	elseif (value > 3) then
		getglobal(bar:GetName() .. "BarTexture"):SetVertexColor(1.0, 1.0, 0.0, 0.5);
	else
		getglobal(bar:GetName() .. "BarTexture"):SetVertexColor(0.0, 1.0, 0.0, 0.5);
	end
	local barvalue = getglobal(bar:GetName() .. "Value");
	barvalue:SetText(value .. "/" .. Profiler_item[name]["Max"]);
	if (value > 6) then
		barvalue:SetTextColor(1.0, 0.0, 0.0, 1.0);
	elseif (value > 3) then
		barvalue:SetTextColor(1.0, 1.0, 0.0, 1.0);
	else
		barvalue:SetTextColor(0.0, 1.0, 0.0, 1.0);
	end
end
