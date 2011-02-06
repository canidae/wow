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
					local _, _, item, stacksize, slots = string.find(line, "^%s*([^,=]+)%s*[,=]?%s*(%d*)%s*=%s*(%d+)")
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

function Commodity:SortGuildBankTab()
	local tab = GetCurrentGuildBankTab()
	if not commodity_player.sortguildbank or not Commodity.tabs[tab] then
		return
	end
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local itemname, amount, priority, itemlevel, stacksize, slots = Commodity:GetItemData(tab, slot)
		local lastslot2
		if slots then
			for slot2 in ipairs(slots) do
				local itemname2, amount2, priority2, itemlevel2, stacksize2, slots2 = Commodity:GetItemData(tab, slot2)
				if slot ~= slot2 and (not itemname2 or (priority > priority2 or (priority == priority2 and (itemlevel > itemlevel2 or (itemlevel == itemlevel2 and itemname <= itemname2))))) then
					local moveamount
					if itemname == itemname2 then
						if slot > slot2 and amount2 < stacksize2 then
							moveamount = math.min(stacksize2 - amount2, amount)
						elseif slot < slot2 and amount > stacksize and amount2 < stacksize2 then
							moveamount = math.min(amount - stacksize, stacksize2 - amount2)
						end
					elseif slot > slot2 and amount <= stacksize then
						moveamount = amount
					end
					if moveamount then
						ClearCursor()
						SplitGuildBankItem(tab, slot, moveamount)
						PickupGuildBankItem(tab, slot2)
						print(moveamount, itemname, "from", slot, "to", slot2, "replacing", itemname2, ":", priority, priority2, "|", itemlevel, itemlevel2, "|", stacksize, stacksize2, "|", amount, amount2)
						return
					end
				end
				lastslot2 = slot2
			end
		end
		if itemname and (not lastslot2 or lastslot2 < slot) then
			-- item that may not belong in this slot, move it to another slot
			local reserved = {}
			for item, itemdata in pairs(Commodity.tabs[tab]) do
				for slot in ipairs(itemdata.slots) do
					reserved[slot] = 1
				end
			end
			for slot2 = MAX_GUILDBANK_SLOTS_PER_TAB, slot, -1 do
				if not reserved[slot] and not GetGuildBankItemInfo(tab, slot2) then
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
