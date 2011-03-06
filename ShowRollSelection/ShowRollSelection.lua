SRS = CreateFrame("Frame")

function SRS:OnEvent(event, ...)
	if event == "ADDON_LOADED" and ... == "ShowRollSelection" then
		for id = 1, 4 do
			-- get buttons
			local itemFrame = _G["GroupLootFrame" .. id .. "IconFrame"]
			local rollButton = _G["GroupLootFrame" .. id .. "RollButton"]
			local greedButton = _G["GroupLootFrame" .. id .. "GreedButton"]
			local disenchantButton = _G["GroupLootFrame" .. id .. "DisenchantButton"]
			local passButton = _G["GroupLootFrame" .. id .. "PassButton"]

			-- create labels
			local itemText = itemFrame:CreateFontString("GroupLootFrame" .. id .. "ItemFrameText", "OVERLAY", "NumberFontNormal")
			local rollText = rollButton:CreateFontString("GroupLootFrame" .. id .. "RollButtonText", "OVERLAY", "NumberFontNormal")
			local greedText = greedButton:CreateFontString("GroupLootFrame" .. id .. "GreedButtonText", "OVERLAY", "NumberFontNormal")
			local disenchantText = disenchantButton:CreateFontString("GroupLootFrame" .. id .. "DisenchantButtonText", "OVERLAY", "NumberFontNormal")
			local passText = passButton:CreateFontString("GroupLootFrame" .. id .. "PassButtonText", "OVERLAY", "NumberFontNormal")

			-- place labels
			itemText:SetPoint("TOPLEFT", itemFrame, "TOPLEFT", 2, -2)
			rollText:SetPoint("TOPLEFT", rollButton, "TOPLEFT", -6, 1)
			greedText:SetPoint("TOPLEFT", greedButton, "TOPLEFT", -4, 4)
			disenchantText:SetPoint("TOPLEFT", disenchantButton, "TOPLEFT", -5, 1)
			passText:SetPoint("RIGHT", passButton, "LEFT", 4, -2)
		end
	elseif event == "START_LOOT_ROLL" then
		-- find frame showing item
		local id
		for index = 1, 4 do
			if _G["GroupLootFrame" .. index].rollID == ... then
				id = index
				break
			end
		end
		if id then
			-- set text
			_G["GroupLootFrame" .. id .. "ItemFrameText"]:SetText("".. (math.max(GetNumPartyMembers() + 1, GetNumRaidMembers())))
			_G["GroupLootFrame" .. id .. "RollButtonText"]:SetText("0")
			_G["GroupLootFrame" .. id .. "GreedButtonText"]:SetText("0")
			_G["GroupLootFrame" .. id .. "DisenchantButtonText"]:SetText("0")
			_G["GroupLootFrame" .. id .. "PassButtonText"]:SetText("0")

			-- set roll data
			local itemLink = GetLootRollItemLink(...)
			SRS.items[itemLink] = id
		end
	elseif event == "CHAT_MSG_LOOT" then
		local msg = ...
		local _, _, who, rollType, itemLink = msg:find("(.*) have selected (.*) for: (.*)")
		if itemLink and SRS.items[itemLink] then
			local id = SRS.items[itemLink]
			if who == "You" then
				-- clear data
				SRS.items[itemLink] = nil
				-- reset tooltip text
				_G["GroupLootFrame" .. id .. "RollButton"].tooltipText = NEED
				_G["GroupLootFrame" .. id .. "RollButton"].newbieText = NEED_NEWBIE
				_G["GroupLootFrame" .. id .. "GreedButton"].tooltipText = GREED
				_G["GroupLootFrame" .. id .. "GreedButton"].newbieText = GREED_NEWBIE
				_G["GroupLootFrame" .. id .. "DisenchantButton"].tooltipText = ROLL_DISENCHANT
				_G["GroupLootFrame" .. id .. "DisenchantButton"].newbieText = ROLL_DISENCHANT_NEWBIE
				-- TODO: PASS (it's using OnEnter instead of setting tooltip text)
			else
				-- decrease counter on item frame
				_G["GroupLootFrame" .. id .. "ItemFrameText"]:SetText("" .. (tonumber(_G["GroupLootFrame" .. id .. "ItemFrameText"]:GetText()) - 1))
				-- increase counter & update tooltip text
				if rollType == NEED then
					_G["GroupLootFrame" .. id .. "RollButtonText"]:SetText("" .. (tonumber(_G["GroupLootFrame" .. id .. "RollButtonText"]:GetText()) + 1))
					_G["GroupLootFrame" .. id .. "RollButton"].tooltipText = _G["GroupLootFrame" .. id .. "RollButton"].tooltipText .. "\n" .. who
					_G["GroupLootFrame" .. id .. "RollButton"].newbieText = _G["GroupLootFrame" .. id .. "RollButton"].newbieText .. "\n" .. who
				elseif rollType == GREED then
					_G["GroupLootFrame" .. id .. "GreedButtonText"]:SetText("" .. (tonumber(_G["GroupLootFrame" .. id .. "GreedButtonText"]:GetText()) + 1))
					_G["GroupLootFrame" .. id .. "GreedButton"].tooltipText = _G["GroupLootFrame" .. id .. "GreedButton"].tooltipText .. "\n" .. who
					_G["GroupLootFrame" .. id .. "GreedButton"].newbieText = _G["GroupLootFrame" .. id .. "GreedButton"].newbieText .. "\n" .. who
				elseif rollType == ROLL_DISENCHANT then
					_G["GroupLootFrame" .. id .. "DisenchantButtonText"]:SetText("" .. (tonumber(_G["GroupLootFrame" .. id .. "DisenchantButtonText"]:GetText()) + 1))
					_G["GroupLootFrame" .. id .. "DisenchantButton"].tooltipText = _G["GroupLootFrame" .. id .. "DisenchantButton"].tooltipText .. "\n" .. who
					_G["GroupLootFrame" .. id .. "DisenchantButton"].newbieText = _G["GroupLootFrame" .. id .. "DisenchantButton"].newbieText .. "\n" .. who
				elseif rollType == PASS then
					_G["GroupLootFrame" .. id .. "PassButtonText"]:SetText("" .. (tonumber(_G["GroupLootFrame" .. id .. "PassButtonText"]:GetText()) + 1))
					-- TODO: PASS (it's using OnEnter instead of setting tooltip text)
				end
			end
		end
	end
end

SRS.items = {}

SRS:SetScript("OnEvent", SRS.OnEvent)
SRS:RegisterEvent("ADDON_LOADED")
SRS:RegisterEvent("CHAT_MSG_LOOT")
SRS:RegisterEvent("START_LOOT_ROLL")
