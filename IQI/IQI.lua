IQI = CreateFrame("Frame")

-- localization (only english so far)
IQI.L = {
	enabled = "Enabled",
	join_as_group = "Join as group",
	requeue_same = "Requeue same instance",
	enter = "Enter",
	pvp = "Queue for PvP",
	dungeon = "Queue for dungeon",
	raid = "Queue for raid"
}

function IQI:OnEvent(event, ...)
	if event == "ADDON_LOADED" and ... == "IQI" then
		-- events
		IQI:UnregisterEvent("ADDON_LOADED")

		-- setup config
		if not iqi_data then
			iqi_data = {
				settings = {
					join_as_group = 1,
					requeue_same = 1
				},
				pvp = {},
				dungeon = {},
				raid = {}
			}
		end
		IQI.updateTime = 0.0

		-- populate LFDDungeonList & LFRRaidList
		LFGDungeonList_Setup()
		--LFDQueueFrame_Update() -- TODO: necessary? remove

		-- replace update-function for QueueStatusMinimapButtonDropDown
		UIDropDownMenu_Initialize(QueueStatusMinimapButtonDropDown, IQI.QueueStatusDropDown_Update, "MENU")

		-- left clicking queue button does magic stuff
		QueueStatusMinimapButton:HookScript("OnClick", function(self, button)
			if button == "LeftButton" and IQI.enabled then
				IQI:Update(1, IsShiftKeyDown())
			end
		end)

		-- need to hook OnShow for QueueStatusFrame so we don't show it if it's empty
		QueueStatusFrame:HookScript("OnShow", function()
			if not QueueStatusMinimapButton.Eye:GetScript("OnUpdate") then
				-- when OnUpdate got a function, we're animating the eye, meaning we're in a queue
				QueueStatusFrame:Hide()
			end
		end)

		-- we don't want to hide queue icon
		QueueStatusMinimapButton:HookScript("OnHide", function()
			QueueStatusMinimapButton:Show()
		end)
		QueueStatusMinimapButton:Show()
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- TODO: try again to find another way to update than using OnUpdate?
		if IQI:InPvpZone() then
			-- in battleground, stop calling IQI:OnUpdate()
			IQI:SetScript("OnUpdate", nil)
		else
			-- not in battleground, call IQI:OnUpdate()
			IQI:SetScript("OnUpdate", IQI.OnUpdate)
		end
		QueueStatusMinimapButton:Show()
	end
end

function IQI:OnUpdate(elapsed)
	IQI.updateTime = IQI.updateTime + elapsed
	if IQI.updateTime >= 1.5 then
		IQI:Update()
		IQI.updateTime = 0.0
	end
end

function IQI:Update(hwEvent, force)
	if IQI:InPvpZone() then
		-- this method shouldn't be called in pvp zones, but we keep this check just in case
		return
	end
	local canQueueBattleground = MAX_BATTLEFIELD_QUEUES
	local teamSize = math.max(GetRealNumPartyMembers() + 1, GetRealNumRaidMembers())
	local already_queued = {}
	local isLeader = IsRealPartyLeader() or IsRealRaidLeader()
	local joinAsGroup
	if teamSize > 1 then
		if isLeader then
			joinAsGroup = iqi_data.settings.join_as_group
		elseif iqi_data.settings.join_as_group then
			-- "join as group" checked and we're not leader, don't queue battlegrounds
			canQueueBattleground = 0
		end
	end
	-- requeue battlegrounds (and see what we're already queued to)
	for i = 1, MAX_BATTLEFIELD_QUEUES do
		local status, name, _, _, _, size, registeredMatch = GetBattlefieldStatus(i)
		if status and status ~= "none" then
			if arena then
				already_queued.registeredMatch = 1
			elseif size == 0 and name then
				already_queued[name] = 1
				if name == RANDOM_BATTLEGROUND or status == "confirm" then
					canQueueBattleground = 0
				else
					canQueueBattleground = canQueueBattleground - 1
				end
			elseif size > 0 then
				already_queued[size] = 1
			end
		end
		if (isLeader or teamSize <= 1) and status == "queued" and (force or GetBattlefieldTimeWaited(i) > GetBattlefieldEstimatedWaitTime(i)) then
			if hwEvent then
				-- hardware event, we can requeue
				local queue
				if iqi_data.pvp[RANDOM_BATTLEGROUND] then
					queue = IQI:GetBattlegroundIndex(RANDOM_BATTLEGROUND)
				elseif iqi_data.settings.requeue_same then
					queue = IQI:GetBattlegroundIndex(name)
				end
				AcceptBattlefieldPort(i) -- leave queue
				if queue then
					IQI:JoinBattleground(queue, joinAsGroup)
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
	-- check if we're queued up for world pvp zone already
	for i = 1, MAX_WORLD_PVP_QUEUES do
		local status, name= GetWorldPVPQueueStatus(i)
		if status ~= "none" then
			already_queued[name] = 1
		end
	end
	-- queue arena
	if not already_queued.registeredMatch and isLeader and teamSize > 1 then
		for i = 1, MAX_ARENA_TEAMS do
			local name, size = GetArenaTeam(i)
			if name and size == teamSize and ((size == 2 and iqi_data.pvp.arena_2v2) or (size == 3 and iqi_data.pvp.arena_3v3) or (size == 5 and iqi_data.pvp.arena_5v5)) then
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
					canQueueBattleground = 0
					JoinArena()
					break
				end
			end
		end
	end
	-- queue rated battleground
	local _, size = GetRatedBattleGroundInfo()
	if isLeader and size == teamSize and not already_queued.registeredMatch and iqi_data.pvp.rated_battleground and UnitLevel("player") >= SHOW_CONQUEST_LEVEL then
		canQueueBattleground = 0
		JoinRatedBattlefield()
	end
	-- queue battlegrounds
	while canQueueBattleground > 0 and (isLeader or teamSize <= 1) do
		if iqi_data.pvp[RANDOM_BATTLEGROUND] then
			IQI:JoinBattleground(IQI:GetBattlegroundIndex(RANDOM_BATTLEGROUND), joinAsGroup)
			canQueueBattleground = 0
		else
			local canJoin = {}
			local count = 0
			for i = 1, GetNumBattlegroundTypes() do
				local name, canEnter = GetBattlegroundInfo(i)
				if not already_queued[name] and name ~= RANDOM_BATTLEGROUND and iqi_data.pvp[name] and canEnter then
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
					IQI:JoinBattleground(index, joinAsGroup)
					break
				end
			end
			canQueueBattleground = canQueueBattleground - 1
		end
	end
	-- queue world pvp zones
	for i = 1, GetNumWorldPVPAreas() do
		local pvpId, name, isActive, canQueue, _, canEnter = GetWorldPVPAreaInfo(i)
		if canEnter and not already_queued[name] and (isActive or canQueue) and iqi_data.pvp[name] then
			BattlefieldMgrQueueRequest(pvpId)
		end
	end
end

function IQI:RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

function IQI:InPvpZone()
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or GetZonePVPInfo() == "arena" then
		return 1
	end
end

function IQI:JoinBattleground(index, asGroup)
	local battlegrounds = GetNumBattlegroundTypes()
	if not index or index < 1 or index > battlegrounds then
		return
	end
	RequestBattlegroundInstanceInfo(index)
	JoinBattlefield(index, asGroup)
end

function IQI:GetBattlegroundIndex(battleground)
	for i = 1, GetNumBattlegroundTypes() do
		local name = GetBattlegroundInfo(i)
		if battleground == name then
			return i
		end
	end
end

function IQI:QueueStatusMinimapButton(arg1, arg2)
	if not arg1 then
		return
	end
	iqi_data[arg1][arg2] = not iqi_data[arg1][arg2]
	ToggleDropDownMenu(1, nil, QueueStatusMinimapButtonDropDown, "QueueStatusMinimapButton", 0, 0)
end

function IQI:QueueStatusDropDown_Update()
	-- TODO: don't show settings if we left click, don't show enter/leave if we right-click?

	-- enter
	local spacer
	for i = 1, NUM_LE_LFG_CATEGORYS do
		local status = GetLFGMode(i)
		if status == "proposal" then
			local name = GetLFGDungeonInfo(i)
			spacer = 1
			info = UIDropDownMenu_CreateInfo()
			info.text = IQI.L.enter .. "|r " .. name
			info.colorCode = "|cff00ff00"
			info.func = function() AcceptProposal() end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info)
		end
	end
	for i = 1, GetMaxBattlefieldID() do
		local status, name = GetBattlefieldStatus(i)
		if status == "confirm" then
			spacer = 1
			info = UIDropDownMenu_CreateInfo()
			info.text = IQI.L.enter .. "|r " .. name
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
			info.text = IQI.L.enter .. "|r " .. name
			info.colorCode = "|cff00ff00"
			info.func = function() BattlefieldMgrEntryInviteResponse(queueId, 1) end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info)
		end
	end
	if C_PetBattles.GetPVPMatchmakingInfo() then
		local status = C_PetBattles.GetPVPMatchmakingInfo()
		if status == "proposal" then
			spacer = 1
			info = UIDropDownMenu_CreateInfo()
			info.text = IQI.L.enter .. "|r Pet battle"
			info.colorCode = "|cff00ff00"
			info.func = function() C_PetBattles.AcceptQueuedPVPMatch() end
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

	-- enable IQI
	info = UIDropDownMenu_CreateInfo()
	info.text = IQI.L.enabled
	info.colorCode = "|cff74e817"
	info.func = function()
		IQI.enabled = not IQI.enabled
		if IQI.enabled then
			IQI:RegisterEvent("PLAYER_ENTERING_WORLD")
			if not IQI:InPvpZone() then
				IQI:SetScript("OnUpdate", IQI.OnUpdate)
				IQI:Update(1)
			end
		else
			IQI:UnregisterEvent("PLAYER_ENTERING_WORLD")
			IQI:SetScript("OnUpdate", nil)
		end
	end
	info.checked = IQI.enabled
	info.isNotRadio = 1
	UIDropDownMenu_AddButton(info)
	-- join as group
	info = UIDropDownMenu_CreateInfo()
	info.text = IQI.L.join_as_group
	info.colorCode = "|cff74e817"
	info.func = IQI.QueueStatusMinimapButton
	info.arg1 = "settings"
	info.arg2 = "join_as_group"
	info.checked = iqi_data.settings.join_as_group
	info.isNotRadio = 1
	UIDropDownMenu_AddButton(info)
	-- requeue same battleground
	info = UIDropDownMenu_CreateInfo()
	info.text = IQI.L.requeue_same
	info.colorCode = "|cff74e817"
	info.func = IQI.QueueStatusMinimapButton
	info.arg1 = "settings"
	info.arg2 = "requeue_same"
	info.checked = iqi_data.settings.requeue_same
	info.isNotRadio = 1
	UIDropDownMenu_AddButton(info)

	-- dungeon
	info = UIDropDownMenu_CreateInfo()
	info.text = IQI.L.dungeon
	info.colorCode = "|cff74e817"
	info.func = IQI.QueueStatusMinimapButton
	info.arg1 = "settings"
	info.arg2 = "dungeon"
	info.checked = iqi_data.settings.dungeon
	info.isNotRadio = 1
	UIDropDownMenu_AddButton(info)
	if iqi_data.settings.dungeon then
		-- list random dungeons
		for i = 1, GetNumRandomDungeons() do
			local id, name = GetLFGRandomDungeonInfo(i)
			if LFG_IsRandomDungeonDisplayable(id) and IsLFGDungeonJoinable(id) then
				info = UIDropDownMenu_CreateInfo()
				info.text = "- |cff557ff9" .. name
				info.func = function()
					for j = 1, GetNumRandomDungeons() do
						local randomId = GetLFGRandomDungeonInfo(j)
						if randomId ~= id then
							iqi_data.dungeon[randomId] = false
						end
					end
					for j = 1, LFDGetNumDungeons() do
						local dungeonId = LFDDungeonList[j]
						local dungeonName, _, _, dungeonMinLevel = GetLFGDungeonInfo(dungeonId)
						if not dungeonMinLevel then
							iqi_data.settings[dungeonName] = false
						end
					end
					IQI:QueueStatusMinimapButton("dungeon", id)
				end
				info.checked = iqi_data.dungeon[id]
				UIDropDownMenu_AddButton(info)
			end
		end
		-- list specific dungeons
		local showFollowingDungeons
		for i = 1, LFDGetNumDungeons() do
			local id = LFDDungeonList[i]
			local name, _, _, minLevel, maxLevel, recLevel = GetLFGDungeonInfo(id)
			local colors = GetQuestDifficultyColor(recLevel or 1)
			local color = IQI:RGBToHex(colors.r, colors.g, colors.b)
			info = UIDropDownMenu_CreateInfo()
			if minLevel and maxLevel and minLevel ~= maxLevel then
				info.arg1 = "dungeon"
				info.arg2 = id
				info.func = IQI.QueueStatusMinimapButton
				info.checked = iqi_data.dungeon[id]
				info.text = "  - " .. color .. name .. " (" .. minLevel .. "-" .. maxLevel .. ")"
				if showFollowingDungeons then
					UIDropDownMenu_AddButton(info)
				end
			elseif minLevel then
				info.arg1 = "dungeon"
				info.arg2 = id
				info.func = IQI.QueueStatusMinimapButton
				info.checked = iqi_data.dungeon[id]
				info.text = "  - " .. color .. name .. " (" .. minLevel .. ")"
				if showFollowingDungeons then
					UIDropDownMenu_AddButton(info)
				end
			else
				-- this is a "header" (i.e. "Cataclysm Heroic" or "Cataclysm Normal")
				-- it is listed before any of the specific dungeons
				-- if it is checked, we'll list the following dungeons (showFollowingDungeons = iqi_data.dungeon[name])
				info.func = function() 
					for j = 1, GetNumRandomDungeons() do
						local randomId = GetLFGRandomDungeonInfo(j)
						iqi_data.dungeon[randomId] = false
					end
					IQI:QueueStatusMinimapButton("settings", name)
				end
				info.checked = iqi_data.settings[name]
				info.text = "- |cff557ff9" .. name
				info.isNotRadio = 1
				UIDropDownMenu_AddButton(info)
				showFollowingDungeons = iqi_data.settings[name]
			end
		end
	end

	-- raid
	-- TODO
	-- tip: /run local a, b = GetFullRaidList(); for c, d in ipairs(a) do local e, f = GetLFGDungeonInfo(d); print(e, f); for g, h in ipairs(b) do print(g, h) end end
	info = UIDropDownMenu_CreateInfo()
	info.text = IQI.L.raid
	info.colorCode = "|cff74e817"
	info.func = IQI.QueueStatusMinimapButton
	info.arg1 = "settings"
	info.arg2 = "raid"
	info.checked = iqi_data.settings.raid
	info.isNotRadio = 1
	UIDropDownMenu_AddButton(info)
	if iqi_data.settings.raid then
		-- list specific raids
		local showFollowingRaids
		for i = 1, LFRGetNumDungeons() do
			local id = LFRRaidList[i]
			local name, _, _, minLevel, maxLevel, recLevel = GetLFGDungeonInfo(id)
			local colors = GetQuestDifficultyColor(recLevel or 1)
			local color = IQI:RGBToHex(colors.r, colors.g, colors.b)
			info = UIDropDownMenu_CreateInfo()
			if minLevel and maxLevel and minLevel ~= maxLevel then
				info.arg1 = "raid"
				info.arg2 = id
				info.func = IQI.QueueStatusMinimapButton
				info.checked = iqi_data.raid[id]
				info.text = "  - " .. color .. name .. " (" .. minLevel .. "-" .. maxLevel .. ")"
				if showFollowingRaids then
					UIDropDownMenu_AddButton(info)
				end
			elseif minLevel then
				info.arg1 = "raid"
				info.arg2 = id
				info.func = IQI.QueueStatusMinimapButton
				info.checked = iqi_data.raid[id]
				info.text = "  - " .. color .. name .. " (" .. minLevel .. ")"
				if showFollowingRaids then
					UIDropDownMenu_AddButton(info)
				end
			else
				-- this is a "header" (i.e. "Cataclysm Raid (10)" or "Cataclysm Raid (25)")
				-- it is listed before any of the specific raids
				-- if it is checked, we'll list the following raids (showFollowingRaids = iqi_data.raid[name])
				info.func = function() 
					for j = 1, GetNumRandomDungeons() do
						local randomId = GetLFGRandomDungeonInfo(j)
						iqi_data.raid[randomId] = false
					end
					IQI:QueueStatusMinimapButton("settings", name)
				end
				info.checked = iqi_data.settings[name]
				info.text = "- |cff557ff9" .. name
				info.isNotRadio = 1
				UIDropDownMenu_AddButton(info)
				showFollowingRaids = iqi_data.settings[name]
			end
		end
	end

	-- pvp
	info = UIDropDownMenu_CreateInfo()
	info.text = IQI.L.pvp
	info.colorCode = "|cff74e817"
	info.func = IQI.QueueStatusMinimapButton
	info.arg1 = "settings"
	info.arg2 = "pvp"
	info.checked = iqi_data.settings.pvp
	info.isNotRadio = 1
	UIDropDownMenu_AddButton(info)
	if iqi_data.settings.pvp then
		-- 2v2
		local colorCode
		if IsInArenaTeam() then
			colorCode = "|cffc3ed01"
		else
			colorCode = "|cffa0a0a0"
		end
		info = UIDropDownMenu_CreateInfo()
		info.text = "- " .. colorCode .. ARENA .. " " .. ARENA_2V2
		info.func = IQI.QueueStatusMinimapButton
		info.arg1 = "pvp"
		info.arg2 = "arena_2v2"
		info.checked = iqi_data.pvp.arena_2v2
		UIDropDownMenu_AddButton(info)
		-- 3v3
		info = UIDropDownMenu_CreateInfo()
		info.text = "- " .. colorCode .. ARENA .. " " .. ARENA_3V3
		info.func = IQI.QueueStatusMinimapButton
		info.arg1 = "pvp"
		info.arg2 = "arena_3v3"
		info.checked = iqi_data.pvp.arena_3v3
		UIDropDownMenu_AddButton(info)
		-- 5v5
		info = UIDropDownMenu_CreateInfo()
		info.text = "- " .. colorCode .. ARENA .. " " .. ARENA_5V5
		info.func = IQI.QueueStatusMinimapButton
		info.arg1 = "pvp"
		info.arg2 = "arena_5v5"
		info.checked = iqi_data.pvp.arena_5v5
		UIDropDownMenu_AddButton(info)
		-- rated battleground
		info = UIDropDownMenu_CreateInfo()
		if UnitLevel("player") >= SHOW_CONQUEST_LEVEL then
			info.text = "- |cfff39208" .. PVP_RATED_BATTLEGROUND
		else
			info.text = "- |cffa0a0a0" .. PVP_RATED_BATTLEGROUND
		end
		info.func = IQI.QueueStatusMinimapButton
		info.arg1 = "pvp"
		info.arg2 = "rated_battleground"
		info.checked = iqi_data.pvp.rated_battleground
		UIDropDownMenu_AddButton(info)
		-- pvp zones (wintergrasp, tol barad)
		for i = 1, GetNumWorldPVPAreas() do
			local _, name, _, _, _, canEnter = GetWorldPVPAreaInfo(i)
			info = UIDropDownMenu_CreateInfo()
			if canEnter then
				info.text = "- |cffd91dc5" .. name
			else
				info.text = "- |cffa0a0a0" .. name
			end
			info.func = IQI.QueueStatusMinimapButton
			info.arg1 = "pvp"
			info.arg2 = name
			info.checked = iqi_data.pvp[name]
			UIDropDownMenu_AddButton(info)
		end
		-- random battlegrounds
		for i = 1, GetNumBattlegroundTypes() do
			local name, canEnter = GetBattlegroundInfo(i)
			if name and (name == RANDOM_BATTLEGROUND or not iqi_data.pvp[RANDOM_BATTLEGROUND]) then
				-- only add "Random Battleground" if that is checked,
				-- otherwise add all battlegrounds
				info = UIDropDownMenu_CreateInfo()
				if name == RANDOM_BATTLEGROUND then
					info.text = "- |cff557ff9" .. name
				elseif canEnter then
					info.text = "  - |cff03c4c6" .. name
				else
					info.text = "  - |cffa0a0a0" .. name
				end
				info.func = IQI.QueueStatusMinimapButton
				info.arg1 = "pvp"
				info.arg2 = name
				info.checked = iqi_data.pvp[name]
				UIDropDownMenu_AddButton(info)
			end
		end
	end

	-- leave
	spacer = nil
	if CanHearthAndResurrectFromArea() then
		-- we're in a world pvp zone, presumably fighting
		-- spacer
		info = UIDropDownMenu_CreateInfo()
		info.isTitle = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info)
		spacer = 1
		info = UIDropDownMenu_CreateInfo()
		info.text = format(LEAVE_ZONE, GetRealZoneText())
		info.colorCode = "|cffff2424"
		info.func = wrapFunc(HearthAndResurrectFromArea)
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info)
	end
	for i = 1, GetMaxBattlefieldID() do
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
			info.text = IQI.L.leave .. "|r " .. name
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
			info.text = IQI.L.leave .. "|r " .. name
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

IQI:SetScript("OnEvent", IQI.OnEvent)
IQI:RegisterEvent("ADDON_LOADED")
