Commodity = CreateFrame("Frame")

function Commodity:OnEvent(event, arg1, ...)
	--print(GetTime(), event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "Commodity" then
		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "GUILDBANK_TEXT_CHANGED" then
		-- someone changed guild tab info, wipe data (will be read again the net time we visit the guild bank)
		local tab = tonumber(arg1)
		if Commodity.tabs[tab] then
			wipe(Commodity.tabs[tab])
			Commodity.tabs[tab] = nil
		end
	elseif event == "GUILDBANK_UPDATE_TEXT" then
		-- parse guild bank tab info
		local tab = tonumber(arg1)
		local text = GetGuildBankText(tab) or ""
		local startpos, endpos = string.find(text, "%[Commodity%]")
		if endpos then
			if not Commodity.tabs[tab] then
				Commodity.tabs[tab] = {}
			end
			local index = 1
			for thing in string.gmatch(string.sub(text, endpos + 1), "[^\n]+") do
				thing = strtrim(thing)
				if thing ~= "" then
					if thing == "[/Commodity]" then
						break
					end
					Commodity.tabs[tab][thing] = index
					index = index + 1
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
			local tabhash = Commodity.tabhash
			Commodity:UpdateTabHash()
			if tabhash ~= Commodity.tabhash then
				Commodity:SortGuildBankTab()
			end
		end
	end
end

function Commodity:SortGuildBankTab()
	-- sort: Commodity.tabs, type, subtype, itemlevel, name
	local tab = GetCurrentGuildBankTab()
	local items = {}
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local _, amount = GetGuildBankItemInfo(tab, slot)
		local itemlink = GetGuildBankItemLink(tab, slot)
		if amount and amount > 0 and itemlink then
			local itemname, _, _, itemlevel, _, itemtype, itemsubtype, itemstackcount = GetItemInfo(itemlink)
			local item = {
				type = itemtype,
				subtype = itemsubtype,
				level = itemlevel,
				name = itemname,
				priority = math.min(Commodity.tabs[tab][itemname] or 666, Commodity.tabs[tab][itemtype] or 666, Commodity.tabs[tab][itemsubtype] or 666),
				slot = slot
			}
			local addlast = 1
			for index, item2 in ipairs(items) do
				-- you're pretty clever if you understand the next line =)
				if item.priority < item2.priority or (item.priority == item2.priority and (item.type < item2.type or (item.type == item2.type and (item.subtype < item2.subtype or (item.subtype == item2.subtype and (item.level > item2.level or (item.level == item2.level and item.name < item2.name))))))) then
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
		local itemlink = GetGuildBankItemLink(tab, slot)
		local itemname, _, _, _, _, _, _, itemstackcount = GetItemInfo(itemlink or -1)
		local _, itemamount = GetGuildBankItemInfo(tab, slot)
		if index > 1 and items[index - 1].name ~= item.name and items[index - 1].name == itemname then
			slot = slot + slotinc
		end
		if slotinc == 1 and item.priority == 666 then
			slotinc = -1
			slot = MAX_GUILDBANK_SLOTS_PER_TAB
		end
		itemlink = GetGuildBankItemLink(tab, slot)
		itemname, _, _, _, _, _, _, itemstackcount = GetItemInfo(itemlink or -1)
		_, itemamount = GetGuildBankItemInfo(tab, slot)
		while itemname and itemname == item.name and itemamount == itemstackcount do
			slot = slot + slotinc
			itemlink = GetGuildBankItemLink(tab, slot)
			itemname, _, _, _, _, _, _, itemstackcount = GetItemInfo(itemlink or -1)
			_, itemamount = GetGuildBankItemInfo(tab, slot)
		end
		if (slotinc == 1 and item.slot > slot) or (slotinc == -1 and item.slot < slot) then
			local _, moveamount = GetGuildBankItemInfo(tab, item.slot)
			if item.name == itemname then
				moveamount = math.min(moveamount, itemstackcount - itemamount)
			end
			Commodity:UpdateTabHash()
			ClearCursor()
			SplitGuildBankItem(tab, item.slot, moveamount)
			PickupGuildBankItem(tab, slot)
			break
		end
	end
	wipe(items)
end

function Commodity:UpdateTabHash()
	local tab = GetCurrentGuildBankTab()
	Commodity.tabhash = ""
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local _, amount = GetGuildBankItemInfo(tab, slot)
		local itemlink = GetGuildBankItemLink(tab, slot)
		Commodity.tabhash = Commodity.tabhash .. (amount or "0") .. (itemlink or "nil")
	end
end

Commodity.tabs = {}
Commodity.tabhash = ""

Commodity:SetScript("OnEvent", Commodity.OnEvent)
Commodity:RegisterEvent("ADDON_LOADED")
Commodity:RegisterEvent("GUILDBANK_TEXT_CHANGED")
Commodity:RegisterEvent("GUILDBANK_UPDATE_TEXT")
Commodity:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
