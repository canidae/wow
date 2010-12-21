Commodity = CreateFrame("Frame")

function Commodity:OnEvent(event, arg1, ...)
	--print(GetTime(), event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "Commodity" then
		self:UnregisterEvent("ADDON_LOADED")
		if not commodity_player then
			commodity_player = {}
		end
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
	local tab = GetCurrentGuildBankTab()
	if not commodity_player.sortguildbank or not Commodity.tabs[tab] then
		return
	end
	-- sort: Commodity.tabs, type, subtype, itemlevel, name
	local items = {}
	local availableslots = MAX_GUILDBANK_SLOTS_PER_TAB
	local groups = {
		commodity = {},
		type = {},
		subtype = {},
		name = {}
	}
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local _, amount = GetGuildBankItemInfo(tab, slot)
		local itemlink = GetGuildBankItemLink(tab, slot)
		if amount and amount > 0 and itemlink then
			local itemname, _, _, itemlevel, _, itemtype, itemsubtype, itemstackcount = GetItemInfo(itemlink)
			local priority = math.min(Commodity.tabs[tab][itemname] or 666, Commodity.tabs[tab][itemtype] or 666, Commodity.tabs[tab][itemsubtype] or 666)
			if priority == 666 then
				availableslots = availableslots - 1
			else
				groups.commodity[priority] = (groups.commodity[priority] or 0) + 1
				groups.type[itemtype] = (groups.type[itemtype] or 0) + 1
				groups.subtype[itemsubtype] = (groups.subtype[itemsubtype] or 0) + 1
				groups.name[itemname] = (groups.name[itemname] or 0) + 1
			end
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
	-- grouping
	local namegroups = 0
	local namegrouprows = 0
	for key, value in pairs(groups.name) do
		namegroups = namegroups + 1
		namegrouprows = namegrouprows + math.ceil(value / 7)
	end
	local subtypegroups = 0
	local subtypegrouprows = 0
	for key, value in pairs(groups.subtype) do
		subtypegroups = subtypegroups + 1
		subtypegrouprows = subtypegrouprows + math.ceil(value / 7)
	end
	local commoditygroups = 0
	local commoditygrouprows = 0
	for key, value in pairs(groups.commodity) do
		commoditygroups = commoditygroups + 1
		commoditygrouprows = commoditygrouprows + math.ceil(value / 7)
	end
	local typegroups = 0
	local typegrouprows = 0
	for key, value in pairs(groups.type) do
		typegroups = typegroups + 1
		typegrouprows = typegrouprows + math.ceil(value / 7)
	end
	local availablerows = math.floor(availableslots / 7)
	local groupmethod
	local bestrowcount = 0
	if namegrouprows < availablerows and namegrouprows > bestrowcount then
		groupmethod = "name"
		bestrowcount = namegrouprows
	end
	if subtypegrouprows < availablerows and subtypegrouprows > bestrowcount then
		groupmethod = "subtype"
		bestrowcount = subtypegrouprows
	end
	if commoditygrouprows < availablerows and commoditygrouprows > bestrowcount then
		groupmethod = "commodity"
		bestrowcount = commoditygrouprows
	end
	if typegrouprows < availablerows and typegrouprows > bestrowcount then
		groupmethod = "type"
		bestrowcount = typegrouprows
	end
	--print("Sort: " .. groupmethod .. ", " .. bestrowcount .. "/" .. availablerows)
	--print(availableslots, availablerows, namegroups, namegrouprows, subtypegroups, subtypegrouprows, typegroups, typegrouprows, commoditygroups, commoditygrouprows)
	-- end grouping
	local slot = 1
	local slotinc = 1
	local lastitem
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
		-- grouping
		if item.priority ~= 666 then
			while groupmethod == "name" and lastitem and lastitem.name ~= item.name and slot % 7 ~= 1 do
				slot = slot + slotinc
			end
			while groupmethod == "subtype" and lastitem and lastitem.subtype ~= item.subtype and slot % 7 ~= 1 do
				slot = slot + slotinc
			end
			while groupmethod == "commodity" and lastitem and lastitem.commodity ~= item.commodity and slot % 7 ~= 1 do
				slot = slot + slotinc
			end
			while groupmethod == "type" and lastitem and lastitem.type ~= item.type and slot % 7 ~= 1 do
				slot = slot + slotinc
			end
			lastitem = item
		end
		-- end grouping
		itemlink = GetGuildBankItemLink(tab, slot)
		itemname, _, _, _, _, _, _, itemstackcount = GetItemInfo(itemlink or -1)
		_, itemamount = GetGuildBankItemInfo(tab, slot)
		while itemname and itemname == item.name and itemamount == itemstackcount and item.slot ~= slot do
			slot = slot + slotinc
			itemlink = GetGuildBankItemLink(tab, slot)
			itemname, _, _, _, _, _, _, itemstackcount = GetItemInfo(itemlink or -1)
			_, itemamount = GetGuildBankItemInfo(tab, slot)
		end
		if item.slot ~= slot then
			local _, moveamount = GetGuildBankItemInfo(tab, item.slot)
			if item.name ~= itemname or itemamount ~= itemamount then
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
