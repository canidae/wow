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
		local itemname, itemlink, _, _, _, _, _, _, _, itemtexture = GetItemInfo(rest)
		if not itemlink and rest and rest ~= "" then
			print("I'm not familiar with item \"" .. rest .. "\"")
			return
		end
		-- hook functions preventing us from picking up items in guildbank
		for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			local index = math.fmod(slot, NUM_SLOTS_PER_GUILDBANK_GROUP)
			if index == 0 then
				index = NUM_SLOTS_PER_GUILDBANK_GROUP
			end
			local column = math.ceil((slot - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
			local button = _G["GuildBankColumn" .. column .. "Button" .. index]
			if not Commodity.drawmode then
				-- already in draw mode, don't overwrite stored functions
				Commodity["OnMouseDown" .. slot] = button:GetScript("OnMouseDown")
				Commodity["OnEnter" .. slot] = button:GetScript("OnEnter")
				Commodity["OnClick" .. slot] = button:GetScript("OnClick")
				Commodity["OnDragStart" .. slot] = button:GetScript("OnDragStart")
				Commodity["OnReceiveDrag" .. slot] = button:GetScript("OnReceiveDrag")
				Commodity["UpdateTooltip" .. slot] = button.UpdateTooltip
				-- no point doing this more than once either
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
							local itemid = Commodity:GetCommodityItemId(tabindex, slot)
							if itemid then
								_, link = GetItemInfo(itemid)
							end
						end
						if link then
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
							GameTooltip:SetHyperlink(link)
						end
					end
				end
			end
		end
		if not Commodity.drawmode then
			Commodity.tabsupdated = {}
			Commodity.drawmode = 1
			Commodity:SetGuildBankSlotOverlay()
		end
		if itemlink and itemlink ~= Commodity.drawlink then
			Commodity.drawlink = itemlink
		end
	elseif command == "done" then
		if Commodity.drawmode then
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
			Commodity.drawmode = nil
			Commodity:SetGuildBankSlotOverlay()
			SetCursor(nil)
			-- broadcast any updated tabs
			for tabindex, one in pairs(Commodity.tabsupdated) do
				Commodity:ScanGuildBankTab(tabindex)
				Commodity:SetTabLastUpdated(tabindex)
				Commodity:BroadcastTabCommodities(tabindex)
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
	if not tabindex or not slot then
		return
	end
	if IsMouseButtonDown("LeftButton") then
		if IsShiftKeyDown() then
			Commodity:SetCommodityItemId(tabindex, slot, nil)
		elseif Commodity.drawlink then
			local _, _, itemid = string.find(Commodity.drawlink, "item:(%d+):")
			Commodity:SetCommodityItemId(tabindex, slot, itemid)
		end
		Commodity:SetGuildBankSlotOverlay()
	elseif IsMouseButtonDown("RightButton") then
		local item
		if IsShiftKeyDown() then
			item = GetGuildBankItemLink(tabindex, slot)
		else
			item = Commodity:GetCommodityItemId(tabindex, slot)
		end
		local drawlink, texture
		if item then
			_, drawlink, _, _, _, _, _, _, _, texture = GetItemInfo(item)
		end
		if drawlink and drawlink ~= Commodity.drawlink then
			SetCursor(texture)
			Commodity.drawlink = drawlink
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
			commodity_db.showtooltip = 1
			commodity_db.overlayvisible = 1
		end
		if not commodity_db.overlayalpha then
			commodity_db.overlayalpha = 0.25
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
	elseif event == "CHAT_MSG_ADDON" and arg1 == "Commodity" and arg3 == "GUILD" and (commodity_db.broadcastdebug or arg4 ~= GetUnitName("player")) then
		-- Commodity message from someone else than me
		if commodity_db.broadcastdebug then
			print(arg1, arg2, arg3, arg4)
		end
		local _, _, messagetype, data = string.find(arg2, "^(.)(.*)$")
		if messagetype == "U" then
			-- when a tab was last updated
			local _, _, tabindex, date = string.find(data, "^(%d)(%d+)$")
			date = tonumber(date)
			local ourdate = tonumber(Commodity:GetTabLastUpdated(tabindex))
			if date > ourdate then
				-- this person got more recent data than us, request person to dump tab commodities
				Commodity:BroadcastRequest(tabindex, arg4)
			elseif date < ourdate then
				-- this person got less recent data than us, broadcast when our tab was last updated so person can request data
				Commodity:BroadcastTabLastUpdated(tabindex)
			end
		elseif messagetype == "R" then
			-- person requesting tab data to be dumped
			local _, _, tabindex, player = string.find(data, "^(%d)(.+)$")
			if player == GetUnitName("player") then
				-- they want us to dump our data
				-- check that we're not already dumping data for this tab
				local dump = 1
				for index, message in ipairs(Commodity.broadcastqueue) do
					if string.find(message, "^[BE]" .. tabindex) then
						-- we are dumping this tab, don't queue it again
						dump = nil
						break
					end
				end
				if dump then
					Commodity:BroadcastTabCommodities(tabindex)
				end
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
		elseif messagetype == "I" then
			-- item
			local _, _, itemid, slots = string.find(data, "^(%d+):(%d+)$")
			local tabdata = Commodity.updatetabdata[arg4]
			if tabdata then
				tabdata.itemids[itemid] = slots
			end
		elseif messagetype == "E" then
			-- end of item list
			local _, _, tabindex, count = string.find(data, "^(%d)(%d+)$")
			local tabdata = Commodity.updatetabdata[arg4]
			if tabdata then
				local commodities = {}
				local count2 = 0
				for itemid, slots in pairs(tabdata.itemids) do
					local length = strlen(slots)
					for start = 1, length, 2 do
						local slot = strsub(slots, start, start + 1)
						if itemid == 0 then
							commodities[slot] = nil
						else
							commodities[slot] = itemid
						end
					end
					count2 = count2 + 1
				end
				if count2 == tonumber(count) then
					-- only update if the data is more recent than what we got
					if tonumber(tabdata.date) > Commodity:GetTabLastUpdated(tabindex) then
						for slot, itemid in pairs(commodities) do
							Commodity:SetCommodityItemId(tabindex, slot, itemid)
						end
						Commodity:SetTabLastUpdated(tabindex, tabdata.date)
						print(arg4 .. " sent us updated Commodity data for guild bank tab " .. tabindex .. "!")
						Commodity:SetGuildBankSlotOverlay()
					end
				else
					print(arg4 .. " sent Commodity data, but we seem to have missed some of the transmission")
				end
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
			Commodity.broadcastdelay = 0.2
		else
			-- no more messages in queue
			Commodity:SetScript("OnUpdate", nil)
		end
	end
end

function Commodity:ScanGuildBankTab(tabindex)
	if not tabindex then
		tabindex = GetCurrentGuildBankTab()
		if not tabindex then
			return
		end
	end
	local changed
	-- clear cached items in this tab
	local tab = Commodity:GetTabData(tabindex)
	tab.items = {}
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local _, newamount = GetGuildBankItemInfo(tabindex, slot)
		local newlink = GetGuildBankItemLink(tabindex, slot)
		local newitemid
		if newlink then
			_, _, newitemid = string.find(newlink, "item:(%d+):")
		end
		-- set slot data
		local olditemid, oldamount = Commodity:GetSlotData(tabindex, slot)
		if olditemid ~= newitemid or oldamount ~= newamount then
			changed = 1
			Commodity:SetSlotData(tabindex, slot, newitemid, newamount)
		end
		-- set commodity/item data
		local commodityitemid = Commodity:GetCommodityItemId(tabindex, slot)
		if commodityitemid then
			local _, _, _, _, _, _, _, maxstacksize = GetItemInfo(commodityitemid)
			if maxstacksize then
				local itemamount, commodityamount = Commodity:GetItemData(tabindex, commodityitemid)
				if not commodityamount then
					commodityamount = 0
				end
				commodityamount = commodityamount + maxstacksize
				Commodity:SetItemData(tabindex, commodityitemid, itemamount, commodityamount)
			end
		end
		if newitemid then
			local itemamount, commodityamount = Commodity:GetItemData(tabindex, newitemid)
			if not itemamount then
				itemamount = 0
			end
			itemamount = itemamount + newamount
			Commodity:SetItemData(tabindex, newitemid, itemamount, commodityamount)
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
		if Commodity.drawmode or commodity_db.overlayvisible then
			local itemid = Commodity:GetCommodityItemId(tabindex, slot)
			if itemid then
				_, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemid)
			end
		end
		local overlay = _G["CommodityOverlayTexture" .. slot]
		if Commodity.drawmode then
			overlay:SetDrawLayer("OVERLAY")
			overlay:SetAlpha(0.7)
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
		local commodityitemid = Commodity:GetCommodityItemId(tabindex, slot)
		if commodityitemid then
			-- we want a certain item in this slot
			local moveto, movefrom, partialmove
			local itemid, amount = Commodity:GetSlotData(tabindex, slot)
			if itemid then
				-- there already is an item occupying this slot
				local _, _, _, _, _, _, _, maxstacksize = GetItemInfo(itemid)
				if itemid == commodityitemid then
					-- correct item in slot, but is the stack filled?
					if amount < maxstacksize then
						-- stack is not filled, should do something about that
						for slot2 = slot + 1, MAX_GUILDBANK_SLOTS_PER_TAB do
							local itemid2, amount2 = Commodity:GetSlotData(tabindex, slot2)
							if itemid2 == itemid then
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
						local itemid2, amount2 = Commodity:GetSlotData(tabindex, slot2)
						local commodityitemid2 = Commodity:GetCommodityItemId(tabindex, slot2)
						if not commodityitemid2 or commodityitemid2 == itemid then
							-- slot not reserved or reserved for same item
							if not itemid2 or ((itemid2 ~= itemid and itemid2 == commodityitemid) or (itemid2 == itemid and amount + amount2 <= maxstacksize)) then
								-- either empty slot or slot with same item and room enough to stack all items here
								-- or the item we're swapping against actually want to be in current slot
								moveto = slot2
								movefrom = slot
								if itemid2 then
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
					local itemid2 = Commodity:GetSlotData(tabindex, slot2)
					local commodityitemid2 = Commodity:GetCommodityItemId(tabindex, slot2)
					if itemid2 and (commodityitemid2 ~= commodityitemid or slot2 > slot) and itemid2 == commodityitemid then
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

function Commodity:UpdateTooltip()
	if not commodity_db.showtooltip then
		return
	end
	local itemname, itemlink = GameTooltip:GetItem()
	local itemid
	if itemlink then
		_, _, itemid = string.find(itemlink, "item:(%d+):")
	end
	if not itemid then
		return
	end
	for tabindex, tab in ipairs(commodity_db.tabs) do
		local itemamount, commodityamount = Commodity:GetItemData(tabindex, itemid)
		if commodityamount and commodityamount > 0 then
			if not itemamount then
				itemamount = 0
			end
			local percent = itemamount / commodityamount
			if percent > 1.0 then
				percent = 1.0
			end
			local r, g
			local b = 0.0
			if percent > 0.75 then
				r = 1.0 - (percent - 0.75) * 4
				g = 1.0
			elseif percent > 0.25 then
				r = 1.0
				g = (percent - 0.25) * 2
			else
				r = 1.0
				g = 0.0
			end
			GameTooltip:AddDoubleLine("Guild bank tab " .. tabindex, itemamount .. "/" .. commodityamount, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, r, g, b)
		end
	end
end

function Commodity:BroadcastRequest(tabindex, player)
	-- used when logging on, tell people when you last saw the given tab updated
	table.insert(Commodity.broadcastqueue, "R" .. tabindex .. player)
	Commodity:SetScript("OnUpdate", Commodity.OnUpdate)
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
		local commodityitemid = Commodity:GetCommodityItemId(tabindex, slot)
		if not commodityitemid then
			commodityitemid = "0"
		end
		if not commodities[commodityitemid] then
			commodities[commodityitemid] = {}
		end
		local tmpslot = slot
		if tmpslot < 10 then
			tmpslot = "0" .. tmpslot
		end
		table.insert(commodities[commodityitemid], tmpslot)
	end
	table.insert(Commodity.broadcastqueue, "B" .. tabindex .. Commodity:GetTabLastUpdated(tabindex))
	local count = 0
	for commodityitemid, slots in pairs(commodities) do
		local message = "I" .. commodityitemid .. ":"
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

function Commodity:SetCommodityItemId(tabindex, slot, itemid)
	local tab = Commodity:GetTabData(tabindex)
	if not tab.commodities then
		tab.commodities = {}
	end
	slot = tonumber(slot)
	tab.commodities[slot] = itemid
	-- set that tab is updated when in drawmode (used to figure out which tabs to broadcast)
	if Commodity.drawmode and Commodity.tabsupdated then
		Commodity.tabsupdated[tabindex] = 1
	end
end

function Commodity:GetCommodityItemId(tabindex, slot)
	local tab = Commodity:GetTabData(tabindex)
	local commodities = tab.commodities
	if not commodities then
		return
	end
	slot = tonumber(slot)
	return commodities[slot]
end

function Commodity:SetSlotData(tabindex, slot, itemid, amount)
	local tab = Commodity:GetTabData(tabindex)
	if not tab.slots then
		tab.slots = {}
	end
	slot = tonumber(slot)
	tab.slots[slot] = {
		itemid = itemid,
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
	return slotdata.itemid, slotdata.amount
end

function Commodity:SetItemData(tabindex, itemid, itemamount, commodityamount)
	local tab = Commodity:GetTabData(tabindex)
	if not tab.items then
		tab.items = {}
	end
	itemamount = tonumber(itemamount)
	commodityamount = tonumber(commodityamount)
	tab.items[itemid] = {
		itemamount = itemamount,
		commodityamount = commodityamount
	}
end

function Commodity:GetItemData(tabindex, itemid)
	local tab = Commodity:GetTabData(tabindex)
	local items = tab.items
	if not items then
		return
	end
	local item = items[itemid]
	if not item then
		return
	end
	return item.itemamount, item.commodityamount
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

function Commodity:GetTabLastUpdated(tabindex)
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
