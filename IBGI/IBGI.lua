IBGI = CreateFrame("Frame")

-- localization
IBGI.L = {
	enabled = "Enabled",
	leave = "Leave",
	enter = "Enter"
}

function IBGI:OnEvent(event, ...)
	if event == "ADDON_LOADED" and ... == "IBGI" then
		-- events
		IBGI:UnregisterEvent("ADDON_LOADED")

		-- setup config
		if not ibgi_data then
			ibgi_data = {
				update_interval = 5000
			}
		end

		-- hooks
		IBGI.Original_MiniMapBattlefieldDropDown_Initialize = MiniMapBattlefieldDropDown_Initialize
		MiniMapBattlefieldDropDown_Initialize = IBGI.MiniMapBattlefieldDropDown_Initialize
		return
	end
end

function IBGI:OnUpdate(elapsed)
	IBGI.updateTime = IBGI.updateTime + elapsed
	if IBGI.updateTime >= ibgi_data.update_interval then
		for i = 1, MAX_BATTLEFIELD_QUEUES do
			local status, name = GetBattlefieldStatus(i)
			if status == "queued" and GetBattlefieldTimeWaited(i) > GetBattlefieldEstimatedWaitTime(i) then
				BattlegroundShineFadeIn()
			end
		end

		IBGI.updateTime = IBGI.updateTime - ibgi_data.update_interval
	end
end

function IBGI:JoinBattleground(index)
	local battlegrounds = GetNumBattlegroundTypes()
	if not index or index < 1 or index > battlegrounds then
		return
	end
	RequestBattlegroundInstanceInfo(index)
	JoinBattlefield(index, asGroup)
end

function IBGI:GetBattlegroundIndex(battleground)
	for i = 1, GetNumBattlegroundTypes() do
		local name = GetBattlegroundInfo(i)
		if battleground == name then
			return i
		end
	end
end

function IBGI:MiniMapBattlefieldDropDown_Initialize()
	-- enter
	local spacer
	for i = 1, MAX_BATTLEFIELD_QUEUES do
		local status, name = GetBattlefieldStatus(i)
		if status == "confirm" then
			spacer = 1
			info = UIDropDownMenu_CreateInfo()
			info.text = IBGI.L.enter .. " |r" .. name
			info.colorCode = "|cff00ff00"
			info.func = function() AcceptBattlefieldPort(i, 1) end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info)
		end
	end
	for i = 1, MAX_WORLD_PVP_QUEUES do
		local status, name, queueId = GetWorldPVPQueueStatus(i)
		if status == "confirm" then
			spacer = 1
			info = UIDropDownMenu_CreateInfo()
			info.text = IBGI.L.leave .. " |r" .. name
			info.colorCode = "|cff00ff00"
			info.func = function() BattlefieldMgrEntryInviteResponse(queueId, 1) end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info)
		end
	end
	-- spacer
	if spacer then
		local info = UIDropDownMenu_CreateInfo()
		info.isTitle = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info)
	end

	-- enable IBGI
	info = UIDropDownMenu_CreateInfo()
	info.text = IBGI.L.enabled
	info.colorCode = "|cff74e817"
	info.func = function()
		IBGI.enabled = not IBGI.enabled
		if IBGI.enabled then
			IBGI.updateTime = ibgi_data.update_interval
			IBGI:SetScript("OnUpdate", IBGI.OnUpdate)
		else
			IBGI:SetScript("OnUpdate", nil)
		end
	end
	info.checked = IBGI.enabled
	info.isNotRadio = 1
	UIDropDownMenu_AddButton(info)

	-- 2v2
	info = UIDropDownMenu_CreateInfo()
	info.text = ARENA_2V2
	info.colorCode = "|cffc3ed01"
	info.func = function() ibgi_data.arena_2v2 = not ibgi_data.arena_2v2 end
	info.checked = ibgi_data.arena_2v2
	UIDropDownMenu_AddButton(info)
	-- 3v3
	info = UIDropDownMenu_CreateInfo()
	info.text = ARENA_3V3
	info.colorCode = "|cffc3ed01"
	info.func = function() ibgi_data.arena_3v3 = not ibgi_data.arena_3v3 end
	info.checked = ibgi_data.arena_3v3
	UIDropDownMenu_AddButton(info)
	-- 5v5
	info = UIDropDownMenu_CreateInfo()
	info.text = ARENA_5V5
	info.colorCode = "|cffc3ed01"
	info.func = function() ibgi_data.arena_5v5 = not ibgi_data.arena_5v5 end
	info.checked = ibgi_data.arena_5v5
	UIDropDownMenu_AddButton(info)
	-- rated battleground
	info = UIDropDownMenu_CreateInfo()
	info.text = PVP_RATED_BATTLEGROUND
	info.colorCode = "|cfff39208"
	info.func = function() ibgi_data.rated_battleground = not ibgi_data.rated_battleground end
	info.checked = ibgi_data.rated_battleground
	UIDropDownMenu_AddButton(info)
	-- pvp zones (wintergrasp, tol barad)
	for i = 1, GetNumWorldPVPAreas() do
		local _, name = GetWorldPVPAreaInfo(i)
		info = UIDropDownMenu_CreateInfo()
		info.text = name
		info.colorCode = "|cffd91dc5"
		info.func = function() ibgi_data[name] = not ibgi_data[name] end
		info.checked = ibgi_data[name]
		UIDropDownMenu_AddButton(info)
	end
	-- random battlegrounds
	for i = 1, GetNumBattlegroundTypes() do
		if i == 1 or not ibgi_data[GetBattlegroundInfo(1)] then
			-- only add "Random Battleground" if that is checked,
			-- otherwise add all battlegrounds
			local name = GetBattlegroundInfo(i)
			info = UIDropDownMenu_CreateInfo()
			if i == 1 then
				info.text = name
				info.colorCode = "|cff557ff9"
			else
				info.text = "- |cff03c4c6" .. name
			end
			info.func = function() ibgi_data[name] = not ibgi_data[name] end
			info.checked = ibgi_data[name]
			UIDropDownMenu_AddButton(info)
		end
	end

	-- leave
	spacer = nil
	for i = 1, MAX_BATTLEFIELD_QUEUES do
		local status, name = GetBattlefieldStatus(i)
		if status ~= "none" then
			if not spacer then
				info = UIDropDownMenu_CreateInfo()
				info.isTitle = 1
				info.notCheckable = 1
				UIDropDownMenu_AddButton(info)
				spacer = 1
			end
			info = UIDropDownMenu_CreateInfo()
			info.text = IBGI.L.leave .. " |r" .. name
			info.colorCode = "|cffff2424"
			info.func = function() AcceptBattlefieldPort(i) end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info)
		end
	end
	for i = 1, MAX_WORLD_PVP_QUEUES do
		local status, name, queueId = GetWorldPVPQueueStatus(i)
		if status ~= "none" then
			if not spacer then
				info = UIDropDownMenu_CreateInfo()
				info.isTitle = 1
				info.notCheckable = 1
				UIDropDownMenu_AddButton(info)
				spacer = 1
			end
			info = UIDropDownMenu_CreateInfo()
			info.text = IBGI.L.leave .. " |r" .. name
			info.colorCode = "|cffff2424"
			if status == "queued" then
				info.func = function() BattlefieldMgrExitRequest(queueId) end
			else
				info.func = function() BattlefieldMgrEntryInviteResponse(queueId) end
			end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info)
		end
	end
end

IBGI:SetScript("OnEvent", IBGI.OnEvent)
IBGI:RegisterEvent("ADDON_LOADED")
