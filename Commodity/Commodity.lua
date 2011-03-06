Commodity = CreateFrame("Frame")

-- slash handler
SLASH_Commodity1 = "/commodity"
function SlashCmdList.Commodity(msg)
	local command, rest = msg:match("^%s*(%S+)%s*(.*)%s*$")
	if command == "reserve" and rest then
		local stackSize, item = rest:match("^%s*(%d*)%s*(.+)%s*$")
		if item then
			local itemName = GetItemInfo(item)
			if itemName then
				item = itemName
			end
			if stackSize and stackSize ~= "" then
				stackSize = tonumber(stackSize)
				print("Reserving slots for", item, "in stacks of", stackSize)
			else
				stackSize = 0
				print("Reserving slots for", item)
			end
			for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
				local index = math.fmod(slot, NUM_SLOTS_PER_GUILDBANK_GROUP)
				if index == 0 then
					index = NUM_SLOTS_PER_GUILDBANK_GROUP
				end
				local column = math.ceil((slot - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
				local button = _G["GuildBankColumn" .. column .. "Button" .. index]
				if not Commodity.reserveItem then
					-- store original functions when we're reserving slots
					Commodity["OnClick" .. slot] = button:GetScript("OnClick")
					Commodity["OnDragStart" .. slot] = button:GetScript("OnDragStart")
					Commodity["OnEnter" .. slot] = button:GetScript("OnEnter")
					Commodity["OnMouseDown" .. slot] = button:GetScript("OnMouseDown")
					Commodity["OnReceiveDrag" .. slot] = button:GetScript("OnReceiveDrag")
					-- set up new functions
					button:SetScript("OnMouseDown", function(...)
						if not IsShiftKeyDown() then
							-- in case we're linking item
							Commodity:Reserve(slot)
						end
					end)
					button:SetScript("OnEnter", function(...)
						Commodity:Reserve(slot)
						-- also call old OnEnter to show tooltip
						Commodity["OnEnter" .. slot](...)
					end)
					button:SetScript("OnClick", function(...)
						-- we may still want to link, so if shift is down, call original function
						if IsShiftKeyDown() then
							Commodity["OnClick" .. slot](...)
						end
					end)
					button:SetScript("OnDragStart", nil)
					button:SetScript("OnReceiveDrag", nil)
				end
			end
			Commodity.reserveItem = item
			Commodity.reserveStackSize = stackSize
		end
	elseif command == "done" and Commodity.reserveItem then
		print("Done reserving slots")
		for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			local index = math.fmod(slot, NUM_SLOTS_PER_GUILDBANK_GROUP)
			if index == 0 then
				index = NUM_SLOTS_PER_GUILDBANK_GROUP
			end
			local column = math.ceil((slot - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
			local button = _G["GuildBankColumn" .. column .. "Button" .. index]
			button:SetScript("OnClick", Commodity["OnClick" .. slot])
			button:SetScript("OnDragStart", Commodity["OnDragStart" .. slot])
			button:SetScript("OnEnter", Commodity["OnEnter" .. slot])
			button:SetScript("OnMouseDown", Commodity["OnMouseDown" .. slot])
			button:SetScript("OnReceiveDrag", Commodity["OnReceiveDrag" .. slot])
		end
		Commodity.reserveItem = nil
		Commodity.reserveStackSize = nil

		-- update guild bank tab text
		for tab, tabdata in pairs(Commodity.tabs) do
			local text = ""
			local tabtext = GetGuildBankText(tab) or ""
			local pos = tabtext:find("%[Commodity%]\n")
			if pos and pos > 1 then
				text = tabtext:sub(1, pos - 1)
			elseif not pos then
				text = text .. tabtext .. "\n"
			end
			text = text .. "[Commodity]\n"
			for item, itemdata in pairs(tabdata.items) do
				text = text .. item
				if itemdata.stackSize then
					text = text .. "," .. itemdata.stackSize
				end
				text = text .. "="
				for slot, _ in pairs(itemdata.slots) do
					if slot < 10 then
						text = text .. "0"
					end
					text = text .. slot
				end
				text = text .. "\n"
			end
			text = text .. "[/Commodity]"
			_, pos = tabtext:find("%[/Commodity%]")
			if pos then
				text = text .. tabtext:sub(pos + 1)
			end
			SetGuildBankText(tab, text)
		end
	else
		print("Commodity usage:")
		print("/commodity reserve [stack size] <item name>")
		print("/commodity done")
	end
end

function Commodity:Reserve(slot)
	local tab = GetCurrentGuildBankTab()
	if not tab or not slot then
		return
	end
	if IsMouseButtonDown("LeftButton") then
		Commodity:SetItemData(tab, slot, Commodity.reserveItem, Commodity.reserveStackSize)
		Commodity:SetGuildBankSlotOverlay(tab, slot)
	elseif IsMouseButtonDown("RightButton") then
		Commodity:SetItemData(tab, slot, Commodity.reserveItem, nil)
		Commodity:SetGuildBankSlotOverlay(tab, slot)
	end
end

function Commodity:OnEvent(event, arg1, ...)
	--print(GetTime(), event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "Commodity" then
		self:UnregisterEvent("ADDON_LOADED")
		if not commodity_player then
			commodity_player = {}
		end
		hooksecurefunc(GameTooltip, "SetGuildBankItem", Commodity.UpdateTooltip)
		for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			index = math.fmod(slot, NUM_SLOTS_PER_GUILDBANK_GROUP)
			if index == 0 then
				index = NUM_SLOTS_PER_GUILDBANK_GROUP
			end
			local column = math.ceil((slot - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
			local button = _G["GuildBankColumn" .. column .. "Button" .. index]
			local overlaytext = button:CreateFontString("CommodityOverlayText" .. slot, "OVERLAY", "NumberFontNormal")
			overlaytext:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
		end
	elseif event == "GUILDBANK_UPDATE_TEXT" then
		-- parse guild bank tab info
		local tab = tonumber(arg1)
		local text = GetGuildBankText(tab) or ""
		local _, pos = text:find("%[Commodity%]")
		if Commodity.tabs[tab] then
			wipe(Commodity.tabs[tab])
		end
		if pos then
			for line in text:sub(pos + 1):gmatch("[^\n]+") do
				line = strtrim(line)
				if line ~= "" then
					if line == "[/Commodity]" then
						break
					end
					local _, _, item, stackSize, slots = line:find("^%s*([^,=]+)%s*[,=]?%s*(%d*)%s*=%s*(%d+)")
					if not slots then
						print("Unable to parse line: " .. line)
					else
						local length = strlen(slots)
						for start = 1, length, 2 do
							local slot = tonumber(strsub(slots, start, start + 1))
							if not stackSize or strtrim(stackSize) == "" then
								stackSize = 0
							end
							Commodity:SetItemData(tab, slot, item, stackSize)
						end

					end
				end
			end
			-- and sort guild bank
			if GetCurrentGuildBankTab() == tab then
				Commodity:SortGuildBankTab()
			end
		end
		for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			Commodity:SetGuildBankSlotOverlay(tab, slot)
		end
	elseif event == "GUILDBANKBAGSLOTS_CHANGED" then
		local tab = GetCurrentGuildBankTab()
		if not Commodity.tabs[tab] then
			-- missing data for this tab, query
			QueryGuildBankText(tab)
		else
			-- only update when the tab is actually changed
			local tabFingerprint = Commodity.tabFingerprint
			Commodity:UpdateTabFingerprint()
			if tabFingerprint ~= Commodity.tabFingerprint then
				Commodity:SortGuildBankTab()
			end
		end
	end
end

function Commodity:SortGuildBankTab()
	local tab = GetCurrentGuildBankTab()
	if not commodity_player.sortGuildBank or not Commodity.tabs[tab] then
		return
	end
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local itemName, amount, priority, itemLevel, stackSize, slots = Commodity:GetItemData(tab, slot)
		local lastslot2
		if slots then
			for slot2, _ in pairs(slots) do
				local itemName2, amount2, priority2, itemLevel2, stackSize2, slots2 = Commodity:GetItemData(tab, slot2)
				if slot ~= slot2 and (not itemName2 or (priority > priority2 or (priority == priority2 and (itemLevel > itemLevel2 or (itemLevel == itemLevel2 and itemName <= itemName2))))) then
					local moveAmount
					if itemName == itemName2 then
						if slot > slot2 and amount2 < stackSize2 then
							moveAmount = math.min(stackSize2 - amount2, amount)
						elseif slot < slot2 and amount > stackSize and amount2 < stackSize2 then
							moveAmount = math.min(amount - stackSize, stackSize2 - amount2)
						end
					elseif slot > slot2 and amount <= stackSize then
						moveAmount = amount
					end
					if moveAmount then
						ClearCursor()
						SplitGuildBankItem(tab, slot, moveAmount)
						PickupGuildBankItem(tab, slot2)
						return
					end
				end
				lastslot2 = slot2
			end
		end
		if itemName and (not lastslot2 or lastslot2 < slot) then
			-- item that may not belong in this slot, move it to another slot
			local reserved = {}
			for item, itemData in pairs(Commodity.tabs[tab].items) do
				for slot, _ in pairs(itemData.slots) do
					reserved[slot] = 1
				end
			end
			for slot2 = MAX_GUILDBANK_SLOTS_PER_TAB, slot, -1 do
				if not reserved[slot2] and not GetGuildBankItemInfo(tab, slot2) then
					-- free slot, move item here
					ClearCursor()
					PickupGuildBankItem(tab, slot)
					PickupGuildBankItem(tab, slot2)
					wipe(reserved)
					return
				end
			end
			wipe(reserved)
		end
	end
end

function Commodity:GetItemData(tab, slot)
	if not tab or not slot then
		return
	end
	local _, amount = GetGuildBankItemInfo(tab, slot)
	local itemLink = GetGuildBankItemLink(tab, slot)
	if not amount or amount <= 0 or not itemLink then
		return
	end
	local itemName, _, _, itemLevel, _, itemType, itemSubType, stackSize = GetItemInfo(itemLink)
	local itemData = Commodity.tabs[tab].items[itemName]
	local priority = 4
	if not itemData then
		itemData = Commodity.tabs[tab].items[itemType]
		priority = 3
		if not itemData then
			itemData = Commodity.tabs[tab].items[itemSubType]
			priority = 2
			if not itemData then
				priority = 1
			end
		end
	end
	local slots
	if itemData then
		if itemData.stackSize and itemData.stackSize < stackSize then
			stackSize = itemData.stackSize
		end
		slots = itemData.slots
	end
	return itemName, amount, priority, itemLevel, stackSize, slots
end

function Commodity:SetItemData(tab, slot, item, stackSize)
	if not tab or not slot or not item then
		return
	end
	if not Commodity.tabs[tab] or not Commodity.tabs[tab].slots or not Commodity.tabs[tab].items then
		Commodity.tabs[tab] = {
			slots = {},
			items = {}
		}
	end
	local tabdata = Commodity.tabs[tab]
	if not tabdata.slots[slot] then
		tabdata.slots[slot] = {
			items = {}
		}
	end
	if not tabdata.items[item] then
		tabdata.items[item] = {
			slots = {}
		}
	end
	tabdata.slots[slot].items[item] = stackSize
	tabdata.items[item].slots[slot] = stackSize
end

function Commodity:UpdateTabFingerprint()
	local tab = GetCurrentGuildBankTab()
	Commodity.tabFingerprint = ""
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local _, amount = GetGuildBankItemInfo(tab, slot)
		local itemLink = GetGuildBankItemLink(tab, slot)
		Commodity.tabFingerprint = Commodity.tabFingerprint .. (amount or "0") .. (itemLink or "nil")
	end
end

function Commodity:SetGuildBankSlotOverlay(tab, slot)
	local overlaytext = _G["CommodityOverlayText" .. slot]
	local reservations = 0
	if Commodity.tabs[tab] and Commodity.tabs[tab].slots[slot] and Commodity.tabs[tab].slots[slot].items then
		for item, stackSize in pairs(Commodity.tabs[tab].slots[slot].items) do
			reservations = reservations + 1
		end
	end
	if reservations == 0 then
		overlaytext:SetText("")
	else
		overlaytext:SetText(reservations)
	end
end

function Commodity:UpdateTooltip(tab, slot)
	if Commodity.tabs[tab] and Commodity.tabs[tab].slots[slot] then
		local headerAdded
		for item, stackSize in pairs(Commodity.tabs[tab].slots[slot].items) do
			if not headerAdded then
				headerAdded = 1
				GameTooltip:AddLine("Commodity reservations:")
			end
			if stackSize == 0 then
				-- 0 denotes no limit on stack size, don't show stack size for item
				stackSize = nil
			end
			GameTooltip:AddDoubleLine(item, stackSize, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0)
		end
		if headerAdded then
			GameTooltip:Show()
		end
	end
end

Commodity.tabs = {}
Commodity.tabFingerprint = ""

Commodity:SetScript("OnEvent", Commodity.OnEvent)
Commodity:RegisterEvent("ADDON_LOADED")
Commodity:RegisterEvent("GUILDBANK_UPDATE_TEXT")
Commodity:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
