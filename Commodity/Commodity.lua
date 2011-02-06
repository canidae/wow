Commodity = CreateFrame("Frame")

function Commodity:OnEvent(event, arg1, ...)
	--print(GetTime(), event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "Commodity" then
		self:UnregisterEvent("ADDON_LOADED")
		if not commodity_player then
			commodity_player = {}
		end
	elseif event == "GUILDBANK_TEXT_CHANGED" then
		-- someone changed guild tab info, wipe data (will be read again the next time we visit the guild bank)
		local tab = tonumber(arg1)
		if Commodity.tabs[tab] then
			wipe(Commodity.tabs[tab])
			Commodity.tabs[tab] = nil
		end
	elseif event == "GUILDBANK_UPDATE_TEXT" then
		-- parse guild bank tab info
		local tab = tonumber(arg1)
		local text = GetGuildBankText(tab) or ""
		local _, endpos = string.find(text, "%[Commodity%]")
		if endpos then
			if not Commodity.tabs[tab] then
				Commodity.tabs[tab] = {}
			end
			for line in string.gmatch(string.sub(text, endpos + 1), "[^\n]+") do
				line = strtrim(line)
				if line ~= "" then
					if line == "[/Commodity]" then
						break
					end
					local _, _, item, stacksize, slots = string.find(line, "^%s*(.+)%s*[,=]%s*(%d*)%s*=%s*(%d+)")
					if not slots then
						print("Unable to parse line: " .. line)
					else
						Commodity.tabs[tab][item] = {
							slots = {},
							stacksize = tonumber(stacksize)
						}
						local length = strlen(slots)
						for start = 1, length, 2 do
							local slot = tonumber(strsub(slots, start, start + 1))
							table.insert(Commodity.tabs[tab][item].slots, slot)
						end

					end
				end
			end
			-- and sort guild bank
			if GetCurrentGuildBankTab() == tab then
				Commodity:SortGuildBankTab()
			end
		end
	elseif event == "GUILDBANKBAGSLOTS_CHANGED" then
		local tab = GetCurrentGuildBankTab()
		if not Commodity.tabs[tab] then
			-- missing data for this tab, query
			QueryGuildBankText(tab)
		else
			-- only update when the tab is actually changed
			local tabfingerprint = Commodity.tabfingerprint
			Commodity:UpdateTabFingerprint()
			if tabfingerprint ~= Commodity.tabfingerprint then
				Commodity:SortGuildBankTab()
			end
		end
	end
end

function Commodity:GetItemData(tab, slot)
	if not tab or not slot then
		return
	end
	local _, amount = GetGuildBankItemInfo(tab, slot)
	local itemlink = GetGuildBankItemLink(tab, slot)
	if not amount or amount <= 0 or not itemlink then
		return
	end
	local itemname, _, _, itemlevel, _, itemtype, itemsubtype, stacksize = GetItemInfo(itemlink)
	local itemdata = Commodity.tabs[tab][itemname]
	local priority = 4
	if not itemdata then
		itemdata = Commodity.tabs[tab][itemtype]
		priority = 3
		if not itemdata then
			itemdata = Commodity.tabs[tab][itemsubtype]
			priority = 2
			if not itemdata then
				priority = 1
			end
		end
	end
	local slots
	if itemdata then
		if itemdata.stacksize and itemdata.stacksize < stacksize then
			stacksize = itemdata.stacksize
		end
		slots = itemdata.slots
	end
	return itemname, amount, priority, itemlevel, stacksize, slots
end

function Commodity:SortGuildBankTab()
	local tab = GetCurrentGuildBankTab()
	if not commodity_player.sortguildbank or not Commodity.tabs[tab] then
		return
	end
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local itemname, amount, priority, itemlevel, stacksize, slots = Commodity:GetItemData(tab, slot)
		if slots then
			for slot2 in ipairs(slots) do
				local itemname2, amount2, priority2, itemlevel2, stacksize2, slots2 = Commodity:GetItemData(tab, slot2)
				if slot ~= slot2 and (not itemname2 or (priority > priority2 or (priority == priority2 and (itemlevel > itemlevel2 or (itemlevel == itemlevel2 and itemname <= itemname2))))) then
					if slot2 > slot and amount > stacksize then
					elseif slot2 < slot then
					end
					if not itemname2 or itemname == itemname2 then
						ClearCursor()
						if amount > stacksize2 then
							SplitGuildBankItem(tab, slot, amount - stacksize2)
						else
							SplitGuildBankItem(tab, slot, math.min(stacksize - amount, amount2))
						end
						PickupGuildBankItem(tab, slot2)
						print(itemname, "from", slot, "to", slot2, "replacing", itemname2, ":", priority, priority2, "|", itemlevel, itemlevel2, "|", stacksize, stacksize2, "|", amount, amount2)
						return
					end
				end
			end
		elseif itemname then
			-- item that may not belong in this slot, move it to another slot
		end
	end
	-- sort: type, subtype, itemlevel, name
	--[[
	local items = {}
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local _, amount = GetGuildBankItemInfo(tab, slot)
		local itemlink = GetGuildBankItemLink(tab, slot)
		if amount and amount > 0 and itemlink then
			local itemname, _, _, itemlevel, _, itemtype, itemsubtype, itemstackcount = GetItemInfo(itemlink)
			local priority = math.min(Commodity.tabs[tab][itemname] or 666, Commodity.tabs[tab][itemtype] or 666, Commodity.tabs[tab][itemsubtype] or 666)
			local item = {
				type = itemtype,
				subtype = itemsubtype,
				level = itemlevel,
				name = itemname,
				priority = priority,
				slot = slot
			}
			local addlast = 1
			for index, item2 in ipairs(items) do
				-- you're pretty clever if you understand the next line =)
				if item.priority < item2.priority or (item.priority == item2.priority and (item.type < item2.type or (item.type == item2.type and (item.subtype < item2.subtype or (item.subtype == item2.subtype and (item.level > item2.level or (item.level == item2.level and (item.name < item2.name or (priority == 666 and item.name == item2.name))))))))) then
					table.insert(items, index, item)
					addlast = nil
					break
				end
			end
			if addlast then
				table.insert(items, item)
			end
		end
	end
	local slot = 1
	local slotinc = 1
	for index, item in ipairs(items) do
		if slotinc == 1 and item.priority == 666 then
			-- reverse sorting, these items shouldn't be in this bank tab, place them in bottom right corner
			slotinc = -1
			slot = MAX_GUILDBANK_SLOTS_PER_TAB
		elseif items[index - 1] and items[index - 1].name ~= item.name then
			slot = slot + slotinc
		end
		local itemlink = GetGuildBankItemLink(tab, slot)
		local itemname, _, _, _, _, _, _, itemstackcount = GetItemInfo(itemlink or -1)
		local _, itemamount = GetGuildBankItemInfo(tab, slot)
		while item.slot ~= slot and itemname and itemname == item.name and itemamount == itemstackcount do
			slot = slot + slotinc
			itemlink = GetGuildBankItemLink(tab, slot)
			itemname, _, _, _, _, _, _, itemstackcount = GetItemInfo(itemlink or -1)
			_, itemamount = GetGuildBankItemInfo(tab, slot)
		end
		if item.slot ~= slot then
			local _, moveamount = GetGuildBankItemInfo(tab, item.slot)
			if item.name == itemname then
				moveamount = math.min(moveamount, itemstackcount - itemamount)
			end
			ClearCursor()
			SplitGuildBankItem(tab, item.slot, moveamount)
			PickupGuildBankItem(tab, slot)
			break
		end
	end
	wipe(items)
	--]]
end

function Commodity:UpdateTabFingerprint()
	local tab = GetCurrentGuildBankTab()
	Commodity.tabfingerprint = ""
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local _, amount = GetGuildBankItemInfo(tab, slot)
		local itemlink = GetGuildBankItemLink(tab, slot)
		Commodity.tabfingerprint = Commodity.tabfingerprint .. (amount or "0") .. (itemlink or "nil")
	end
end

Commodity.tabs = {}
Commodity.tabfingerprint = ""

Commodity:SetScript("OnEvent", Commodity.OnEvent)
Commodity:RegisterEvent("ADDON_LOADED")
Commodity:RegisterEvent("GUILDBANK_TEXT_CHANGED")
Commodity:RegisterEvent("GUILDBANK_UPDATE_TEXT")
Commodity:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
