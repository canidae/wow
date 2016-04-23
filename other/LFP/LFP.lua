LFP = CreateFrame("Frame")

LFP_ROSTER_MAX_COLUMNS = 7
LFP_ROSTER_COLUMNS = {
	pvp = { "level", "class", "name", "resilience", "power", "bgrating", "arenarating" },
}

LFP_ROSTER_COLUMN_DATA = {
	level = { width = 32, text = LEVEL_ABBR, stringJustify = "CENTER" },
	class = { width = 32, text = CLASS_ABBR, hasIcon = true },
	name = { width = 81, text = NAME, stringJustify = "LEFT" },
	resilience = { width = 90, text = STAT_RESILIENCE, stringJustify = "RIGHT" },
	power = { width = 90, text = STAT_PVP_POWER, stringJustify = "RIGHT" },
	bgrating = { width = 80, text = BG_RATING_ABBR, stringJustify = "RIGHT" },
	arenarating = { width = 80, text = ARENA_RATING, stringJustify = "RIGHT" },
}


function LFP:OnEvent(event, arg1, ...)
	if event == "ADDON_LOADED" then
		LFP:UnregisterEvent("ADDON_LOADED")
		if not LFP_DB then
			LFP_DB = {}
		end
		if not LFP_DB.players then
			LFP_DB.players = {}
		end
		LFP_UpdateRoster()
	end
end

function LFP_OnRosterLoad(self)
	--LFPFrame_RegisterPanel(self)
	LFPRosterContainer.update = LFP_UpdateRoster
	HybridScrollFrame_CreateButtons(LFPRosterContainer, "LFPRosterButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
	LFPRosterContainerScrollBar.doNotHide = true
	--self:RegisterEvent("PLAYER_ENTERING_WORLD")
	--SetLFPRosterSelection(0)
	--UIDropDownMenu_SetSelectedValue(LFPRosterViewDropdown, currentLFPView)
	-- right-click dropdown
	LFPRosterMemberDropDown.displayMode = "MENU"
	LFP_SetRosterView("pvp")
end

function LFP_SetRosterView(view)
	if not view or not LFP_ROSTER_COLUMNS[view] then
		view = "pvp"
	end

	local numColumns = #LFP_ROSTER_COLUMNS[view]
	local stringsInfo = { }
	local stringOffset = 0
	local haveIcon

	-- set up columns
	for columnIndex = 1, LFP_ROSTER_MAX_COLUMNS do
		local columnButton = _G["LFPRosterColumnButton" .. columnIndex]
		local columnType = LFP_ROSTER_COLUMNS[view][columnIndex]
		if columnType then
			local columnData = LFP_ROSTER_COLUMN_DATA[columnType]
			columnButton:SetText(columnData.text)
			WhoFrameColumn_SetWidth(columnButton, columnData.width)
			columnButton:Show()
			-- by default the sort type should be the same as the column type
			if columnData.sortType then
				columnButton.sortType = columnData.sortType
			else    
				columnButton.sortType = columnType
			end
			if columnData.hasIcon then
				haveIcon = true
			else    
				-- store string data for processing
				columnData["stringOffset"] = stringOffset
				table.insert(stringsInfo, columnData)
			end
			stringOffset = stringOffset + columnData.width - 2
		else
			columnButton:Hide()
		end
	end

        -- process the button strings
        local buttons = LFPRosterContainer.buttons;
        local button, fontString;
        for buttonIndex = 1, #buttons do
                button = buttons[buttonIndex];
                for stringIndex = 1, 6 do
                        fontString = button["string" .. stringIndex];
                        local stringData = stringsInfo[stringIndex];
                        if stringData then
                                -- want strings a little inside the columns, 6 pixels from the left and 8 from the right
                                fontString:SetPoint("LEFT", stringData.stringOffset + 6, 0);
                                fontString:SetWidth(stringData.width - 14);
                                fontString:SetJustifyH(stringData.stringJustify);
                                fontString:Show();
                        else    
                                fontString:Hide();
                        end
                end
                
                if haveIcon then
                        button.icon:Show();
                else    
                        button.icon:Hide();
                end
        end
end

function LFP_UpdateRoster()
	if not LFP_DB then
		return
	end
	local scrollFrame = LFPRosterContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index, class
	local numPlayers = #LFP_DB.players
	--local totalMembers, onlineMembers, onlineAndMobileMembers = GetNumLFPMembers()
	--local selectedLFPMember = GetLFPRosterSelection()

	for i = 1, numButtons do
		button = buttons[i]
		index = offset + 1
		if index <= numPlayers then
			local playerData = LFP_DB.players[index]
			-- TODO:
			-- playerData.online
			-- playerData.classFileName
			button.playerIndex = index
			button.online = playerData.online

			LFPRosterButton_SetStringText(button.string1, playerData.level, playerData.online)
			--button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[playerData.classFileName])) -- TODO
			LFPRosterButton_SetStringText(button.string2, playerData.name, playerData.online, classFileName)
			LFPRosterButton_SetStringText(button.string3, playerData.bgrating, playerData.online)
			LFPRosterButton_SetStringText(button.string4, playerData.arenarating, playerData.online)
			LFPRosterButton_SetStringText(button.string5, playerData.resilience, playerData.online)
			LFPRosterButton_SetStringText(button.string6, playerData.power, playerData.online)
			button:Show()
			-- TODO: what is this? needed?
			--[[
			if mod(index, 2) == 0 then
				button.stripe:SetTexCoord(0.36230469, 0.38183594, 0.95898438, 0.99804688)
			else    
				button.stripe:SetTexCoord(0.51660156, 0.53613281, 0.88281250, 0.92187500)
			end
			if selectedGuildMember == index then
				button:LockHighlight()
			else    
				button:UnlockHighlight()
			end
			]]
		else
			button:Hide()
		end
	end
	HybridScrollFrame_Update(scrollFrame, numPlayers * 22, numButtons * 22)
end

function LFP:SortRosterByColumn(column)
	-- TODO
end

function LFPRosterButton_SetStringText(buttonString, text, online, class)
	if not text then
		text = "?"
	end
	buttonString:SetText(text)
	if online then
		if class then
			local classColor = RAID_CLASS_COLORS[class]
			buttonString:SetTextColor(classColor.r, classColor.g, classColor.b)
		else    
			buttonString:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
	else    
		buttonString:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	end
end

LFP:SetScript("OnEvent", LFP.OnEvent)
LFP:RegisterEvent("ADDON_LOADED")
