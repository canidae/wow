Commodity = CreateFrame("Frame")

function Commodity:OnEvent()
	local timesincelast = GetTime()
	if Commodity.eventtimes[event] then
		timesincelast = timesincelast - Commodity.eventtimes[event]
	end
	Commodity.eventtimes[event] = GetTime()
	--print(event .. " - " .. timesincelast)
	if event == "ADDON_LOADED" and arg1 == "Commodity" then
		this:UnregisterEvent("ADDON_LOADED")
		if not commodity_db then
			commodity_db = {}
		end
		if not commodity_db.backgroundalpha then
			commodity_db.backgroundalpha = 0.3
		end
		if not commodity_db.tabs then
			commodity_db.tabs = {}
		end
		-- create overlay frames
		for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			index = math.fmod(slot, NUM_SLOTS_PER_GUILDBANK_GROUP)
			if index == 0 then
				index = NUM_SLOTS_PER_GUILDBANK_GROUP
			end
			local column = math.ceil((slot - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
			local button = _G["GuildBankColumn" .. column .. "Button" .. index]
			local background = button:CreateTexture("CommodityOverlayTexture" .. slot, "BACKGROUND")
			background:SetAllPoints(button)
			background:Show()
		end
	elseif event == "GUILDBANKBAGSLOTS_CHANGED" then
		if timesincelast > 0.1 then
			Commodity:ScanGuildBankTab()
			Commodity:SortGuildBankTab()
			Commodity:SetGuildBankSlotBackground()
		end
	end
end

function Commodity:ScanGuildBankTab()
	local tabindex = GetCurrentGuildBankTab()
	if not tabindex or not commodity_db.tabs[tabindex] then
		commodity_db.tabs[tabindex] = {}
	end
	local tab = commodity_db.tabs[tabindex]
	tab.items = {}
	tab.slots = {}
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local _, amount, locked = GetGuildBankItemInfo(tabindex, slot)
		local itemlink = GetGuildBankItemLink(tabindex, slot)
		tab.slots[slot] = itemlink
		if amount and amount > 0 then
			local itemname = GetItemInfo(itemlink)
			if tab.items[itemname] then
				tab.items[itemname].amount = tab.items[itemname].amount + amount
			else
				tab.items[itemname] = {
					amount = amount,
					slots = {}
				}
			end
			table.insert(tab.items[itemname].slots, slot)
		end
	end
end

function Commodity:SetGuildBankSlotBackground()
	local tabindex = GetCurrentGuildBankTab()
	if not tabindex then
		return
	end
	local tab = commodity_db.tabs[tabindex]
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local texture
		if commodity_db.backgroundvisible and tab and tab.commodities then
			local commoditylink = tab.commodities[slot]
			if commoditylink then
				texture = GetItemIcon(commoditylink)
			end
		end
		local background = _G["CommodityOverlayTexture" .. slot]
		background:SetTexture(texture)
		background:SetAlpha(commodity_db.backgroundalpha)
	end
end

function Commodity:SortGuildBankTab()
	if not commodity_db.sortguildbanktab then
		return
	end
	local tabindex = GetCurrentGuildBankTab()
	if not tabindex or not commodity_db.tabs[tabindex] then
		return
	end
	local tab = commodity_db.tabs[tabindex]
	if not tab.commodities then
		tab.commodities = {}
	end
	local locked = {}
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local commodity = tab.commodities[slot]
		if commodity and not locked[slot] then
			-- we want a certain item in this slot (and it's not locked)
			local item = tab.slots[slot]
			if item then
				-- there already is an item occupying this slot
				if item == commodity then
					-- correct item in slot, but is the stack filled?
				else
					-- oh dear, wrong item in slot
				end
			else
				-- no item currently in this slot
				local swapslot
				for slot2 = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
					local swapitem = tab.slots[slot2]
					if not locked[slot2] and swapitem and swapitem == commodity then
						-- found an item that match this commodity, and it's not locked!
						swapslot = slot2
						break
					end
				end
				if swapslot then
					locked[slot] = 1
					locked[swapslot] = 1
					print("Moving item from slot " .. swapslot .. " to " .. slot)
					PickupGuildBankItem(tabindex, swapslot)
					PickupGuildBankItem(tabindex, slot)
				end
			end
		end
	end
end

Commodity.eventtimes = {}

Commodity:SetScript("OnEvent", Commodity.OnEvent)
Commodity:RegisterEvent("ADDON_LOADED")
Commodity:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
