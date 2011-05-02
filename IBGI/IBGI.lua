IBGI = CreateFrame("Frame")

-- localization
IBGI.L = {
	enabled = "Enabled",
	join_as_group = "Join as group",
	requeue_same = "Requeue same BG",
	enter = "Enter",
	leave = "Leave"
}

function IBGI:OnEvent(event, ...)
	if event == "ADDON_LOADED" and ... == "IBGI" then
		-- events
		IBGI:UnregisterEvent("ADDON_LOADED")

		-- setup config
		if not ibgi_data then
			ibgi_data = {}
		end
		IBGI.updateTime = 0.0

		-- hooks
		IBGI.Original_MiniMapBattlefieldDropDown_Initialize = MiniMapBattlefieldDropDown_Initialize
		MiniMapBattlefieldDropDown_Initialize = IBGI.MiniMapBattlefieldDropDown_Initialize
		-- don't hide battleground icon
		MiniMapBattlefieldFrame:HookScript("OnHide", function() MiniMapBattlefieldFrame:Show() end)
		-- left clicking battleground icon does magic stuff
		MiniMapBattlefieldFrame:HookScript("OnClick", function(self, button)
			if button == "LeftButton" then
				IBGI.enabled = 1
				IBGI:RegisterEvent("PLAYER_ENTERING_WORLD")
				if not IBGI:InPvpZone() then
					IBGI:SetScript("OnUpdate", IBGI.OnUpdate)
					IBGI:Update(1, IsShiftKeyDown())
				end
			end
		end)

		-- show battleground icon
		MiniMapBattlefieldFrame:Show()
		return
	elseif event == "PLAYER_ENTERING_WORLD" then
		if IBGI:InPvpZone() then
			-- in battleground, stop calling IBGI:Update()
			IBGI:SetScript("OnUpdate", nil)
		else
			-- not in battleground, call IBGI:Update()
			IBGI:SetScript("OnUpdate", IBGI.OnUpdate)
		end
	end
end

function IBGI:OnUpdate(elapsed)
	IBGI.updateTime = IBGI.updateTime + elapsed
	if IBGI.updateTime >= 5.0 then
		IBGI:Update()
		IBGI.updateTime = 0.0
	end
end

function IBGI:Update(hwEvent, force)
	local canJoinBattleground = MAX_BATTLEFIELD_QUEUES
	local teamSize = math.max(GetRealNumPartyMembers() + 1, GetRealNumRaidMembers())
	local already_queued = {}
	local isLeader = IsRealPartyLeader() or IsRealRaidLeader()
	local joinAsGroup
	if hwEvent and teamSize > 1 then
		if isLeader then
			joinAsGroup = ibgi_data.join_as_group
		elseif ibgi_data.join_as_group then
			-- "join as group" checked and we're not leader, don't queue battlegrounds
			canJoinBattleground = 0
		end
	end
	-- requeue battlegrounds (and see what we're already queued to)
	if isLeader or teamSize <= 1 then
		for i = 1, MAX_BATTLEFIELD_QUEUES do
			local status, name, _, _, _, size = GetBattlefieldStatus(i)
			if status and status ~= "none" then
				if size == 0 and name then
					already_queued[name] = 1
					if name == RANDOM_BATTLEGROUND then
						canJoinBattleground = 0
					else
						canJoinBattleground = canJoinBattleground - 1
					end
				elseif size > 0 then
					already_queued[size] = 1
				end
			end
			if status == "queued" and (force or GetBattlefieldTimeWaited(i) > GetBattlefieldEstimatedWaitTime(i)) then
				if hwEvent then
					-- hardware event, we can requeue
					local queue
					if ibgi_data[RANDOM_BATTLEGROUND] then
						queue = IBGI:GetBattlegroundIndex(RANDOM_BATTLEGROUND)
					elseif ibgi_data.requeue_same then
						queue = IBGI:GetBattlegroundIndex(name)
					end
					AcceptBattlefieldPort(i) -- leave queue
					if queue then
						IBGI:JoinBattleground(queue, joinAsGroup)
					else
						-- we didn't requeue for this battleground
						already_queued[name] = nil
					end
				else
					-- flash minimap icon, user should requeue
					BattlegroundShineFadeIn()
				end
			end
		end
	end
	-- check if we're queued up for world pvp zone already
	for i = 1, MAX_WORLD_PVP_QUEUES do
		local status, name= GetWorldPVPQueueStatus(i)
		if status ~= "none" then
			already_queued[name] = 1
		end
	end
	-- queue arena
	if isLeader and teamSize > 1 then
		for i = 1, MAX_ARENA_TEAMS do
			local name, size = GetArenaTeam(i)
			if name and size == teamSize and not already_queued[size] and ((size == 2 and ibgi_data.arena_2v2) or (size == 3 and ibgi_data.arena_3v3) or (size == 5 and ibgi_data.arena_5v5)) then
				local valid = 1
				for j = 1, teamSize - 1 do
					local found
					for k = 1, size * 2 do
						if UnitName("party" .. j) == GetArenaTeamRosterInfo(i, k) then
							found = 1
							break
						end
					end
					if not found or not UnitIsConnected("party" .. j) then
						valid = false
						break
					end
				end
				if valid then
					canJoinBattleground = 0
					JoinArena()
					break
				end
			end
		end
	end
	-- queue rated battleground
	local _, size = GetRatedBattleGroundInfo()
	if isLeader and size == teamSize and not already_queued[size] and ibgi_data.rated_battleground then
		canJoinBattleground = 0
		JoinRatedBattlefield()
	end
	-- queue battlegrounds
	while canJoinBattleground > 0 and (isLeader or teamSize <= 1) do
		if ibgi_data[RANDOM_BATTLEGROUND] then
			IBGI:JoinBattleground(IBGI:GetBattlegroundIndex(RANDOM_BATTLEGROUND), joinAsGroup)
			canJoinBattleground = 0
		else
			local canJoin = {}
			local count = 0
			for i = 1, GetNumBattlegroundTypes() do
				local name = GetBattlegroundInfo(i)
				if name ~= RANDOM_BATTLEGROUND and ibgi_data[name] then
					canJoin[name] = i
					count = count + 1
				end
			end
			if count <= 0 then
				-- can't join [any more] battlegrounds
				break
			end
			local random = math.random(count)
			for name, index in pairs(canJoin) do
				random = random - 1
				if random == 0 then
					IBGI:JoinBattleground(index, joinAsGroup)
					break
				end
			end
			canJoinBattleground = canJoinBattleground - 1
		end
	end
	-- queue world pvp zones
	for i = 1, GetNumWorldPVPAreas() do
		local pvpId, name, isActive, canQueue, _, canEnter = GetWorldPVPAreaInfo(i)
		if canEnter and not already_queued[name] and (isActive or canQueue) and ibgi_data[name] then
			BattlefieldMgrQueueRequest(pvpId)
		end
	end
end

function IBGI:InPvpZone()
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or GetZonePVPInfo() == "arena" then
		return 1
	end
end

function IBGI:JoinBattleground(index, asGroup)
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
			info.text = IBGI.L.enter .. " |r" .. name
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
			IBGI:RegisterEvent("PLAYER_ENTERING_WORLD")
			if not IBGI:InPvpZone() then
				IBGI:SetScript("OnUpdate", IBGI.OnUpdate)
				IBGI:Update(1)
			end
		else
			IBGI:UnregisterEvent("PLAYER_ENTERING_WORLD")
			IBGI:SetScript("OnUpdate", nil)
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
	info.text = ARENA .. " " .. ARENA_2V2
	info.colorCode = "|cffc3ed01"
	info.func = function() ibgi_data.arena_2v2 = not ibgi_data.arena_2v2 end
	info.checked = ibgi_data.arena_2v2
	UIDropDownMenu_AddButton(info)
	-- 3v3
	info = UIDropDownMenu_CreateInfo()
	info.text = ARENA .. " " .. ARENA_3V3
	info.colorCode = "|cffc3ed01"
	info.func = function() ibgi_data.arena_3v3 = not ibgi_data.arena_3v3 end
	info.checked = ibgi_data.arena_3v3
	UIDropDownMenu_AddButton(info)
	-- 5v5
	info = UIDropDownMenu_CreateInfo()
	info.text = ARENA .. " " .. ARENA_5V5
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
