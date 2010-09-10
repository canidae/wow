Commodity = CreateFrame("Frame")

-- slash handler
SLASH_Commodity1 = "/commodity"
function SlashCmdList.Commodity(msg)
	local command, rest = msg:match("^(%S*)%s*(.*)$")
	if command == "draw" then
		if not GuildBankFrame:IsVisible() then
			print("Guild bank window must be open")
			return
		end
		local itemname
		local itemlink
		local itemtexture
		itemname, itemlink, _, _, _, _, _, _, _, itemtexture = GetItemInfo(rest)
		if not itemlink and rest and rest ~= "" then
			print("I'm not familiar with item \"" .. rest .. "\"")
			return
		end
		-- hook functions preventing us from picking up items in guildbank
		for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			index = math.fmod(slot, NUM_SLOTS_PER_GUILDBANK_GROUP)
			if index == 0 then
				index = NUM_SLOTS_PER_GUILDBANK_GROUP
			end
			local column = math.ceil((slot - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
			local button = _G["GuildBankColumn" .. column .. "Button" .. index]
			if not Commodity.forceoverlay then
				-- already in draw mode, don't overwrite stored functions
				Commodity["OnMouseDown" .. slot] = button:GetScript("OnMouseDown")
				Commodity["OnEnter" .. slot] = button:GetScript("OnEnter")
				Commodity["OnClick" .. slot] = button:GetScript("OnClick")
				Commodity["OnDragStart" .. slot] = button:GetScript("OnDragStart")
				Commodity["OnReceiveDrag" .. slot] = button:GetScript("OnReceiveDrag")
				Commodity["UpdateTooltip" .. slot] = button.UpdateTooltip
			end
			button:SetScript("OnMouseDown", function(self, mouse, down)
				Commodity:Draw(slot)
				self:UpdateTooltip(self)
			end)
			button:SetScript("OnEnter", function(self, motion)
				if Commodity.drawlink then
					local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(Commodity.drawlink)
					SetCursor(texture)
				end
				Commodity:Draw(slot)
				self:UpdateTooltip(self)
			end)
			button:SetScript("OnClick", nil)
			button:SetScript("OnDragStart", nil)
			button:SetScript("OnReceiveDrag", nil)
			button.UpdateTooltip = function(self)
				local tabindex = GetCurrentGuildBankTab()
				if tabindex and slot then
					local link
					if IsShiftKeyDown() then
						link = GetGuildBankItemLink(tabindex, slot)
					else
						link = Commodity:GetCommodityLink(tabindex, slot)
					end
					if link then
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:SetHyperlink(link)
					end
				end
			end
		end
		if itemlink and itemlink ~= Commodity.drawlink then
			Commodity.drawlink = itemlink
			print("Drawing " .. Commodity.drawlink)
		end
		Commodity.tabsupdated = {}
		Commodity.forceoverlay = 1
		Commodity:SetGuildBankSlotOverlay()
	elseif command == "done" then
		if Commodity.forceoverlay then
			-- restore function hooks so we can play around with guildbank again
			for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
				index = math.fmod(slot, NUM_SLOTS_PER_GUILDBANK_GROUP)
				if index == 0 then
					index = NUM_SLOTS_PER_GUILDBANK_GROUP
				end
				local column = math.ceil((slot - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
				local button = _G["GuildBankColumn" .. column .. "Button" .. index]
				button:SetScript("OnMouseDown", Commodity["OnMouseDown" .. slot])
				button:SetScript("OnEnter", Commodity["OnEnter" .. slot])
				button:SetScript("OnClick", Commodity["OnClick" .. slot])
				button:SetScript("OnDragStart", Commodity["OnDragStart" .. slot])
				button:SetScript("OnReceiveDrag", Commodity["OnReceiveDrag" .. slot])
				button.UpdateTooltip = Commodity["UpdateTooltip" .. slot]
			end
		end
		Commodity.forceoverlay = nil
		Commodity:SetGuildBankSlotOverlay()
		SetCursor(nil)
		-- broadcast any updated tabs
		if Commodity.tabsupdated then
			for tabindex, one in pairs(Commodity.tabsupdated) do
				Commodity:SetTabLastUpdated(tabindex)
				Commodity:BroadcastTabLastUpdated(tabindex)
			end
		end
	else
		print("Commodity usage:")
		print("/commodity draw [item] - Reserve slots for item by drawing it in guild bank")
		print("/commodity done - Exit draw mode, will also broadcast changes to guild")
	end
end

function Commodity:Draw(slot)
	local tabindex = GetCurrentGuildBankTab()
	if tabindex and slot then
		if IsMouseButtonDown("LeftButton") then
			if IsShiftKeyDown() then
				Commodity:SetCommodityLink(tabindex, slot, nil)
			elseif Commodity.drawlink then
				Commodity:SetCommodityLink(tabindex, slot, Commodity.drawlink)
			end
			Commodity:SetGuildBankSlotOverlay()
		elseif IsMouseButtonDown("RightButton") then
			local drawlink
			if IsShiftKeyDown() then
				drawlink = GetGuildBankItemLink(tabindex, slot)
			else
				drawlink = Commodity:GetCommodityLink(tabindex, slot)
			end
			if drawlink and drawlink ~= Commodity.drawlink then
				local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(drawlink)
				SetCursor(texture)
				Commodity.drawlink = drawlink
			end
		end
	end
end

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
		if not commodity_db.overlayalpha then
			commodity_db.overlayalpha = 0.2
		end
		-- create overlay frames
		for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			index = math.fmod(slot, NUM_SLOTS_PER_GUILDBANK_GROUP)
			if index == 0 then
				index = NUM_SLOTS_PER_GUILDBANK_GROUP
			end
			local column = math.ceil((slot - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
			local button = _G["GuildBankColumn" .. column .. "Button" .. index]
			local overlay = button:CreateTexture("CommodityOverlayTexture" .. slot, "BACKGROUND")
			overlay:SetAllPoints(button)
		end
		-- broadcast queue, for sending data to other clients at a sane speed
		Commodity.broadcastqueue = {}
		Commodity.broadcastdelay = 0
		-- and broadcast our status in case someone got updated data
		for tabindex = 1, 6 do
			Commodity:BroadcastTabLastUpdated(tabindex)
		end
	elseif event == "GUILDBANKBAGSLOTS_CHANGED" then
		if Commodity:ScanGuildBankTab() then
			-- only sort if tab is changed
			Commodity:SortGuildBankTab()
		end
		Commodity:SetGuildBankSlotOverlay()
	elseif event == "CHAT_MSG_ADDON" and arg1 == "Commodity" then --and arg4 ~= GetUnitName("player") then
		-- Commodity message from someone else than me
		--print(arg1, arg2, arg3, arg4)
		local _, _, messagetype, data = string.find(arg2, "^(.)(.*)$")
		if messagetype == "U" then
			-- when a tab was last updated
			local _, _, tabindex, date = string.find(data, "^(%d)(%d+)$")
			date = tonumber(date)
			local ourdate = tonumber(Commodity:GetTabLastUpdated(tabindex))
			if date > ourdate then
				-- this person got more recent data than us, broadcast when our tab was last updated
				Commodity:BroadcastTabLastUpdated(tabindex)
			elseif date < ourdate then
				-- this person got less recent data than us, we should share our data
				Commodity:BroadcastTabCommodities(tabindex)
			end
		elseif messagetype == "B" then
			-- beginning of item list
			local _, _, tabindex, date = string.find(data, "^(%d)(%d+)$")
			if not Commodity.updatetabdata then
				Commodity.updatetabdata = {}
			end
			Commodity.updatetabdata[arg4] = {
				date = date,
				itemids = {}
			}
		elseif messagetype == "E" then
			-- end of item list
			local _, _, tabindex, count = string.find(data, "^(%d)(%d+)$")
			local tabdata = Commodity.updatetabdata[arg4]
			local commodities = {}
			if tabdata then
				local count2 = 0
				for itemid, slots in pairs(tabdata.itemids) do
					local _, itemlink = GetItemInfo(itemid)
					if not itemlink then
						itemlink = "nil"
					end
					local length = strlen(slots)
					for start = 1, length, 2 do
						local slot = strsub(slots, start, start + 1)
						commodities[slot] = itemlink
					end
					count2 = count2 + 1
				end
				if count2 == tonumber(count) then
					for slot, itemlink in pairs(commodities) do
						if itemlink == "nil" then
							itemlink = nil
						end
						Commodity:SetCommodityLink(tabindex, slot, itemlink)
					end
					Commodity:SetTabLastUpdated(tabindex, tabdata.date)
					print(arg4 .. " sent us updated Commodity data for guild bank tab " .. tabindex .. "!")
					Commodity:SetGuildBankSlotOverlay()
				else
					print(arg4 .. " sent Commodity data, but we seem to have missed some of the transmission")
				end
			end
		elseif messagetype == "I" then
			-- item
			local _, _, itemid, slots = string.find(data, "^(%d+):(%d+)$")
			local tabdata = Commodity.updatetabdata[arg4]
			if tabdata then
				tabdata.itemids[itemid] = slots
			end
		end
	end
end

function Commodity:OnUpdate(elapsed)
	Commodity.broadcastdelay = Commodity.broadcastdelay - elapsed
	if Commodity.broadcastdelay <= 0 then
		local message = table.remove(Commodity.broadcastqueue, 1)
		if message then
			SendAddonMessage("Commodity", message, "GUILD")
		else
			-- no more messages in queue
			Commodity:SetScript("OnUpdate", nil)
		end
		Commodity.broadcastdelay = 0.2
	end
end

function Commodity:ScanGuildBankTab()
	local tabindex = GetCurrentGuildBankTab()
	if not tabindex then
		return
	end
	local changed
	if commodity_db.items then
		-- clear cached items in this tab
		commodity_db.items[tabindex] = {}
	end
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local _, newamount = GetGuildBankItemInfo(tabindex, slot)
		local newlink = GetGuildBankItemLink(tabindex, slot)
		if not newamount then
			newamount = 0
		end
		local oldlink, oldamount = Commodity:GetSlotData(tabindex, slot)
		if oldlink ~= newlink or oldamount ~= newamount then
			changed = 1
			Commodity:SetSlotData(tabindex, slot, newlink, newamount)
		end
		if newlink then
			local itemamount = Commodity:GetItemAmount(tabindex, newlink)
			if not itemamount then
				itemamount = 0
			end
			Commodity:SetItemAmount(tabindex, newlink, itemamount + newamount)
		end
	end
	return changed
end

function Commodity:SetGuildBankSlotOverlay()
	local tabindex = GetCurrentGuildBankTab()
	if not tabindex then
		return
	end
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local texture
		if Commodity.forceoverlay or commodity_db.overlayvisible then
			local commoditylink = Commodity:GetCommodityLink(tabindex, slot)
			if commoditylink then
				texture = GetItemIcon(commoditylink)
			end
		end
		local overlay = _G["CommodityOverlayTexture" .. slot]
		if Commodity.forceoverlay then
			overlay:SetDrawLayer("OVERLAY")
			overlay:SetAlpha(0.6)
			if not texture then
				texture = "Interface\\PaperDoll\\UI-Backpack-EmptySlot"
			end
		else
			overlay:SetDrawLayer("BACKGROUND")
			overlay:SetAlpha(commodity_db.overlayalpha)
		end
		overlay:SetTexture(texture)
	end
end

function Commodity:SortGuildBankTab()
	if not commodity_db.sortguildbanktab then
		return
	end
	local tabindex = GetCurrentGuildBankTab()
	if not tabindex then
		return
	end
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local commodity = Commodity:GetCommodityLink(tabindex, slot)
		if commodity then
			-- we want a certain item in this slot
			local moveto
			local movefrom
			local partialmove
			local item, amount = Commodity:GetSlotData(tabindex, slot)
			if item then
				local _, _, _, _, _, _, _, maxstacksize = GetItemInfo(item)
				local _, amount = GetGuildBankItemInfo(tabindex, slot)
				-- there already is an item occupying this slot
				if item == commodity then
					-- correct item in slot, but is the stack filled?
					if amount < maxstacksize then
						-- it's not filled, should do something about that
						for slot2 = slot + 1, MAX_GUILDBANK_SLOTS_PER_TAB do
							local item2, amount2 = Commodity:GetSlotData(tabindex, slot2)
							if item2 == item then
								-- found another stack of same item
								partialmove = math.min(maxstacksize - amount, amount2)
								moveto = slot
								movefrom = slot2
								break
							end
						end
					end
				else
					-- oh dear, wrong item in slot
					for slot2 = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
						local item2, amount2 = Commodity:GetSlotData(tabindex, slot2)
						local freeslot
						local commodity2 = Commodity:GetCommodityLink(tabindex, slot2)
						if not commodity2 or commodity2 == item then
							-- slot not reserved or reserved for same item
							if not item2 or ((item2 ~= item and item2 == commodity) or (item2 == item and amount + amount2 <= maxstacksize)) then
								-- either empty slot or slot with same item and room enough to stack all items here
								-- or the item we're swapping against actually want to be in current slot
								moveto = slot2
								movefrom = slot
								if item2 then
									-- we do this to prevent that the misplaced item is temporarily placed in an empty slot
									-- if it's just going to be moved to a (correct) reserved slot later
									break
								end
							end
						end
					end
				end
			else
				-- no item currently in this slot
				for slot2 = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
					local item2 = Commodity:GetSlotData(tabindex, slot2)
					if item2 and (Commodity:GetCommodityLink(tabindex, slot2) ~= commodity or slot2 > slot) and item2 == commodity then
						-- found an item that match this commodity
						moveto = slot
						movefrom = slot2
						break
					end
				end
			end
			if movefrom then
				ClearCursor()
				if partialmove then
					SplitGuildBankItem(tabindex, movefrom, partialmove)
				else
					PickupGuildBankItem(tabindex, movefrom)
				end
				PickupGuildBankItem(tabindex, moveto)
				return
			end
		end
	end
end

function Commodity:BroadcastTabLastUpdated(tabindex)
	-- used when logging on, tell people when you last saw the given tab updated
	table.insert(Commodity.broadcastqueue, "U" .. tabindex .. Commodity:GetTabLastUpdated(tabindex))
	Commodity:SetScript("OnUpdate", Commodity.OnUpdate)
end

function Commodity:BroadcastTabCommodities(tabindex)
	-- broadcast reserved slots for items in given tab
	local commodities = {}
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local commodity = Commodity:GetCommodityLink(tabindex, slot)
		local itemid
		if commodity then
			_, _, itemid = string.find(commodity, "item:(%d+):")
		end
		if not itemid then
			itemid = "0"
		end
		if not commodities[itemid] then
			commodities[itemid] = {}
		end
		local tmpslot = slot
		if tmpslot < 10 then
			tmpslot = "0" .. tmpslot
		end
		table.insert(commodities[itemid], tmpslot)
	end
	table.insert(Commodity.broadcastqueue, "B" .. tabindex .. Commodity:GetTabLastUpdated(tabindex))
	local count = 0
	for itemid, slots in pairs(commodities) do
		local message = "I" .. itemid .. ":"
		for index, slot in ipairs(slots) do
			message = message .. slot
		end
		table.insert(Commodity.broadcastqueue, message)
		count = count + 1
	end
	table.insert(Commodity.broadcastqueue, "E" .. tabindex .. count)
	Commodity:SetScript("OnUpdate", Commodity.OnUpdate)
end

function Commodity:GetTabData(tabindex)
	if not commodity_db.tabs then
		commodity_db.tabs = {}
	end
	local tabs = commodity_db.tabs
	tabindex = tonumber(tabindex)
	if not tabs[tabindex] then
		tabs[tabindex] = {}
	end
	return tabs[tabindex]
end

function Commodity:SetCommodityLink(tabindex, slot, link)
	local tab = Commodity:GetTabData(tabindex)
	if not tab.commodities then
		tab.commodities = {}
	end
	slot = tonumber(slot)
	tab.commodities[slot] = link
	-- need to know which tabs are updated when broadcasting
	if Commodity.tabsupdated then
		Commodity.tabsupdated[tabindex] = 1
	end
end

function Commodity:GetCommodityLink(tabindex, slot)
	local tab = Commodity:GetTabData(tabindex)
	local commodities = tab.commodities
	if not commodities then
		return
	end
	slot = tonumber(slot)
	return commodities[slot]
end

function Commodity:SetSlotData(tabindex, slot, link, amount)
	local tab = Commodity:GetTabData(tabindex)
	if not tab.slots then
		tab.slots = {}
	end
	slot = tonumber(slot)
	tab.slots[slot] = {
		link = link,
		amount = amount
	}
end

function Commodity:GetSlotData(tabindex, slot)
	local tab = Commodity:GetTabData(tabindex)
	local slots = tab.slots
	if not slots then
		return
	end
	slot = tonumber(slot)
	local slotdata = slots[slot]
	if not slotdata then
		return
	end
	return slotdata.link, slotdata.amount
end

function Commodity:SetItemAmount(tabindex, itemlink, amount)
	local tab = Commodity:GetTabData(tabindex)
	if not tab.items then
		tab.items = {}
	end
	amount = tonumber(amount)
	tab.items[itemlink] = amount
end

function Commodity:GetItemAmount(tabindex, itemlink)
	local tab = Commodity:GetTabData(tabindex)
	local items = tab.items
	if not items then
		return
	end
	return items[itemlink]
end

function Commodity:SetTabLastUpdated(tabindex, timestamp)
	local tab = Commodity:GetTabData(tabindex)
	if not timestamp then
		local _, month, day, year = CalendarGetDate()
		if month < 10 then
			month = "0" .. month
		end
		if day < 10 then
			day = "0" .. day
		end
		local hour, minute = GetGameTime()
		if hour < 10 then
			hour = "0" .. hour
		end
		if minute < 10 then
			minute = "0" .. minute
		end
		timestamp = year .. month .. day .. hour .. minute
	end
	tab.lastupdated = tonumber(timestamp)
end

function Commodity:GetTabLastUpdated(tabindex, itemlink)
	local tab = Commodity:GetTabData(tabindex)
	if tab.lastupdated then
		return tab.lastupdated
	end
	return 0
end

Commodity.eventtimes = {}

Commodity:SetScript("OnEvent", Commodity.OnEvent)
Commodity:RegisterEvent("ADDON_LOADED")
Commodity:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
Commodity:RegisterEvent("CHAT_MSG_ADDON")
