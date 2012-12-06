Autochievement = CreateFrame("Frame")

function Autochievement:OnEvent(event, arg1, ...)
	if event == "ADDON_LOADED" then
		Autochievement:UnregisterEvent("ADDON_LOADED")
		if not Autochievement_DB then
			Autochievement_DB = {}
		end
		if not Autochievement_DB.data then
			Autochievement_DB.data = {}
		end
		if not Autochievement_DB.tracking then
			Autochievement_DB.tracking = {}
		end
		if not Autochievement_DB.config then
			Autochievement:DefaultSettings()
		else
			Autochievement:LoadSettings()
		end
		Autochievement.alreadyAdded = {}
		GameTooltip:HookScript("OnTooltipSetUnit", Autochievement.UnitTooltip)
		GameTooltip:HookScript("OnTooltipSetItem", Autochievement.ItemTooltip)
	else
		Autochievement:UpdateObjectiveTracker()
	end
end

function Autochievement:UnitTooltip()
	if not Autochievement_DB.config.unit then
		return
	end
	local name, unit = GameTooltip:GetUnit()
	if not name then
		return
	end
	wipe(Autochievement.alreadyAdded)
	Autochievement:TooltipAchievement(name)
	if not unit then
		return
	end
	local unitGuid = UnitGUID(unit)
	if unitGuid then
		Autochievement:TooltipAchievement(tonumber(string.sub(unitGuid, 60, 10), 16))
	end
	local unitRace = UnitRace(unit)
	local unitClass = UnitClass(unit)
	Autochievement:TooltipAchievement(unitRace)
	Autochievement:TooltipAchievement(unitClass)
	if unitRace and unitClass then
		Autochievement:TooltipAchievement(unitRace .. " " .. unitClass)
	end
end

function Autochievement:ItemTooltip()
	if not Autochievement_DB.config.item then
		return
	end
	local name, link = GameTooltip:GetItem()
	if not name then
		return
	end
	wipe(Autochievement.alreadyAdded)
	Autochievement:TooltipAchievement(name)
	if not link then
		return
	end
	local _, _, itemId = string.find(link, "[^:]*:(%d+)")
	Autochievement:TooltipAchievement(itemId)
end

function Autochievement:TooltipAchievement(text)
	if not text then
		return
	end
	-- lowercase what we're searching for
	text = string.lower(text)
	-- remove unwanted words
	text = string.gsub(text, "the ", "")
	-- trim string
	text = string.gsub(text, "^%s*(.-)%s*$", "%1")
	if not Autochievement_DB.data[text] then
		return
	end
	for _, id in ipairs(Autochievement_DB.data[text]) do
		local _, name, _, completed = GetAchievementInfo(id)
		if not completed and not Autochievement.alreadyAdded[name] then
			GameTooltip:AddLine(name)
			Autochievement.alreadyAdded[name] = true
		end
	end
end

function Autochievement:UpdateObjectiveTracker()
	-- remove automatically tracked achievements
	for id, _ in pairs(Autochievement_DB.tracking) do
		RemoveTrackedAchievement(id)
	end
	wipe(Autochievement_DB.tracking)

	-- adding zone achievements
	if Autochievement_DB.config.subzone then
		Autochievement:TrackAchievement(GetSubZoneText())
	end
	if Autochievement_DB.config.zone then
		Autochievement:TrackAchievement(GetRealZoneText())
	end
	-- adding holiday achievements
	if Autochievement_DB.config.holiday then
		local _, _, day = CalendarGetDate()
		for i = 1, CalendarGetNumDayEvents(0, day) do
			Autochievement:TrackAchievement(CalendarGetHolidayInfo(0, day, i))
		end
	end
	-- add continent
	if Autochievement_DB.config.continent then
		Autochievement:TrackAchievement(select(GetCurrentMapContinent(), GetMapContinents()))
	end
end

function Autochievement:TrackAchievement(text)
	if not text or GetNumTrackedAchievements() >= WATCHFRAME_MAXACHIEVEMENTS then
		return
	end
	-- lowercase what we're searching for
	text = string.lower(text)
	-- remove unwanted words
	text = string.gsub(text, "the ", "")
	-- trim string
	text = string.gsub(text, "^%s*(.-)%s*$", "%1")
	if not Autochievement_DB.data[text] then
		return
	end
	for _, id in ipairs(Autochievement_DB.data[text]) do
		local _, _, _, completed = GetAchievementInfo(id)
		if not completed then
			AddTrackedAchievement(id)
			Autochievement_DB.tracking[id] = true
			if GetNumTrackedAchievements() >= WATCHFRAME_MAXACHIEVEMENTS then
				return
			end
		end
	end
end

function Autochievement:AddAchievement(group, id)
	if not group or not id or group == "0" or group == 0 or group == "" then
		return
	end
	-- lowercase everything
	group = string.lower(group)
	-- remove unwanted words
	group = string.gsub(group, "the ", "")
	group = string.gsub(group, " quests", "")
	group = string.gsub(group, "heroic: ", "")
	group = string.gsub(group, "collector: ", "")
	group = string.gsub(group, " safari", "")
	group = string.gsub(group, " tamer", "")
	group = string.gsub(group, "taming ", "")
	-- trim string
	group = string.gsub(group, "^%s*(.-)%s*$", "%1")
	-- add to database
	if not Autochievement_DB.data[group] then
		Autochievement_DB.data[group] = {}
	end
	table.insert(Autochievement_DB.data[group], id)
end

function Autochievement:ScanAchievements()
	table.wipe(Autochievement_DB.data)
	local categoryList = GetCategoryList()
	for i, categoryId in ipairs(categoryList) do
		local categoryName, categoryParent, categoryFlags = GetCategoryInfo(categoryId)
		local achievements, completedCount = GetCategoryNumAchievements(categoryId)
		for j = completedCount + 1, achievements do
			local id, name, points, _, _, _, _, description, flags, _, _, isGuildAch = GetAchievementInfo(categoryId, j)
			if bit.band(flags, 0x00000001) == 0 then
				-- this is an achievement (and not statistics)
				-- add category as something to look for
				Autochievement:AddAchievement(categoryName, id)
				-- add achievement name
				Autochievement:AddAchievement(name, id)
				-- add criterias as something we can look up
				for k = 1, GetAchievementNumCriteria(id) do
					local desc, criteriaType, completed, _, _, _, _, assetId = GetAchievementCriteriaInfo(id, k)
					if criteriaType ~= 8 and not completed then
						-- criteria text, may be useful
						Autochievement:AddAchievement(desc, id)
						-- asset ID, may be NPC ID, item ID, etc. very useful
						Autochievement:AddAchievement(assetId, id)
					end
				end
			end
		end
	end
end

function Autochievement:LoadSettings()
	AutochievementEnableContinentAchievementsCheckButton:SetChecked(Autochievement_DB.config.continent)
	AutochievementEnableZoneAchievementsCheckButton:SetChecked(Autochievement_DB.config.zone)
	AutochievementEnableSubZoneAchievementsCheckButton:SetChecked(Autochievement_DB.config.subzone)
	AutochievementEnableHolidayAchievementsCheckButton:SetChecked(Autochievement_DB.config.holiday)
	AutochievementEnableUnitAchievementsCheckButton:SetChecked(Autochievement_DB.config.unit)
	AutochievementEnableItemAchievementsCheckButton:SetChecked(Autochievement_DB.config.item)
end

function Autochievement:SaveSettings()
	if not Autochievement_DB.config then
		Autochievement_DB = {}
	end
	Autochievement_DB.config.continent = AutochievementEnableContinentAchievementsCheckButton:GetChecked()
	Autochievement_DB.config.zone = AutochievementEnableZoneAchievementsCheckButton:GetChecked()
	Autochievement_DB.config.subzone = AutochievementEnableSubZoneAchievementsCheckButton:GetChecked()
	Autochievement_DB.config.holiday = AutochievementEnableHolidayAchievementsCheckButton:GetChecked()
	Autochievement_DB.config.unit = AutochievementEnableUnitAchievementsCheckButton:GetChecked()
	Autochievement_DB.config.item = AutochievementEnableItemAchievementsCheckButton:GetChecked()
	UpdateObjectiveTracker()
end

function Autochievement:DefaultSettings()
	Autochievement_DB.config = {}
	Autochievement_DB.config.continent = false
	Autochievement_DB.config.zone = true
	Autochievement_DB.config.subzone = true
	Autochievement_DB.config.holiday = false
	Autochievement_DB.config.unit = false
	Autochievement_DB.config.item = false
	Autochievement:LoadSettings()
	UpdateObjectiveTracker()
end

Autochievement:SetScript("OnEvent", Autochievement.OnEvent)
Autochievement:RegisterEvent("ADDON_LOADED")
Autochievement:RegisterEvent("PLAYER_ENTERING_WORLD")
Autochievement:RegisterEvent("ZONE_CHANGED_NEW_AREA")
