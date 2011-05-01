IBGI = CreateFrame("Frame")

-- localization
IBGI.L = {
	enabled = "Enabled",
	join_as_group = "Join as group",
	requeue_same = "Requeue same battleground",
	enter = "Enter",
	leave = "Leave"
}

function IBGI:OnEvent(event, ...)
	if event == "ADDON_LOADED" and ... == "IBGI" then
		-- events
		IBGI:UnregisterEvent("ADDON_LOADED")

		-- setup config
		if not ibgi_data then
			ibgi_data = {
			}
		end

		-- hooks
		IBGI.Original_MiniMapBattlefieldDropDown_Initialize = MiniMapBattlefieldDropDown_Initialize
		MiniMapBattlefieldDropDown_Initialize = IBGI.MiniMapBattlefieldDropDown_Initialize
		return
	elseif event == "UPDATE_BATTLEFIELD_STATUS" then
		IBGI:Update()
	end
end

function IBGI:Update(hwEvent, force)
	local canJoinBattleground = MAX_BATTLEFIELD_QUEUES
	-- TODO: joinAsGroup
	-- requeue battlegrounds
	for i = 1, MAX_BATTLEFIELD_QUEUES do
		local status, name = GetBattlefieldStatus(i)
		if status == "queued" and (force or GetBattlefieldTimeWaited(i) > GetBattlefieldEstimatedWaitTime(i)) then
			if hwEvent then
				-- hardware event, we can requeue
				local queue
				if ibgi_data[RANDOM_BATTLEGROUND] then
					queue = IBGI:GetBattlegroundIndex(RANDOM_BATTLEGROUND)
					canJoinBattleground = 0
				elseif ibgi_data.requeue_same then
					queue = IBGI:GetBattlegroundIndex(name)
					canJoinBattleground = canJoinBattleground - 1
				else
					-- TODO: find a random battleground
				end
				AcceptBattlefieldPort(i) -- leave queue
				IBGI:JoinBattleground(queue)
			else
				-- flash minimap icon, user should requeue
				BattlegroundShineFadeIn()
			end
		end
	end
	-- queue arena
	-- TODO, and set canJoinBattleground = 0 if we queue
	-- queue rated battleground
	-- TODO, and set canJoinBattleground = 0 if we queue
	-- queue battlegrounds
	while canJoinBattleground > 0 do
		-- TODO
		canJoinBattleground = canJoinBattleground - 1
	end
	-- queue world pvp zones
	-- TODO
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
			IBGI:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
		else
			IBGI:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")
		end
	end
	info.checked = IBGI.enabled
	info.isNotRadio = 1
	UIDropDownMenu_AddButton(info)
	-- join as group
	info = UIDropDownMenu_CreateInfo()
	info.text = IBGI.L.join_as_group
	info.colorCode = "|cff74e817"
	info.func = function() ibgi_data.join_as_group = not ibgi_data.join_as_group end
	info.checked = ibgi_data.join_as_group
	info.isNotRadio = 1
	UIDropDownMenu_AddButton(info)
	-- requeue same battleground
	info = UIDropDownMenu_CreateInfo()
	info.text = IBGI.L.requeue_same
	info.colorCode = "|cff74e817"
	info.func = function() ibgi_data.requeue_same = not ibgi_data.requeue_same end
	info.checked = ibgi_data.requeue_same
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
		local name = GetBattlegroundInfo(i)
		if name == RANDOM_BATTLEGROUND or not ibgi_data[RANDOM_BATTLEGROUND] then
			-- only add "Random Battleground" if that is checked,
			-- otherwise add all battlegrounds
			info = UIDropDownMenu_CreateInfo()
			if name == RANDOM_BATTLEGROUND then
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
