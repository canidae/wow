Commodity = CreateFrame("Frame")

-- slash handler
SLASH_Commodity1 = "/commodity"
function SlashCmdList.Commodity(msg)
	local command, rest = msg:match("^(%S*)%s*(.*)$")
	if command == "draw" then
		if not GuildBankFrame:IsVisible() then
			print("Guild bank window must be open.")
			return
		end
		local itemname, itemlink, itemtexture
		if rest and rest ~= "" then
			itemname, itemlink, _, _, _, _, _, _, _, itemtexture = GetItemInfo(rest)
			if not itemlink then
				local itemid = tonumber(rest)
				if itemid then
					itemname, itemlink, _, _, _, _, _, _, _, itemtexture = GetItemInfo(itemid)
				end
			end
			if not itemlink then
				print("I'm not familiar with item \"" .. rest .. "\".")
				return
			end
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
					Commodity:Draw(slot, 1)
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
							local itemid = Commodity:GetCommodityData(tabindex, slot)
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
			Commodity:DeleteTable(Commodity.tabsupdated)
			Commodity.tabsupdated = {}
			Commodity.drawmode = 1
			Commodity:SetGuildBankSlotOverlay()
			-- show some help for users as well
			print("Right click on drawn item or shift right click on guild bank item to draw that.")
			print("Draw with left mouse button, erase with shift left mouse button.")
			print("Left click again to increase stack size by 1, hold down ctrl to increase by 5.")
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
			-- sort open tab as well
			Commodity:SortGuildBankTab()
			print("Done drawing, broadcasting changes")
		end
	else
		print("Commodity usage:")
		print("/commodity draw [itemid or itemlink] - Reserve slots for item in guild bank")
		print("/commodity done - Exit draw mode, will also broadcast changes to guild")
	end
end

function Commodity:Draw(slot, increasestack)
	local tabindex = GetCurrentGuildBankTab()
	if not tabindex or not slot then
		return
	end
	if IsMouseButtonDown("LeftButton") then
		if IsShiftKeyDown() then
			Commodity:SetCommodityData(tabindex, slot, nil, nil)
		elseif Commodity.drawlink then
			local commodityitemid, stacksize = Commodity:GetCommodityData(tabindex, slot)
			local _, _, itemid = string.find(Commodity.drawlink, "item:(%d+):")
			local _, _, _, _, _, _, _, maxstacksize = GetItemInfo(itemid)
			if commodityitemid == tonumber(itemid) then
				if increasestack then
					if IsControlKeyDown() then
						stacksize = stacksize + 4
					end
					stacksize = math.fmod(stacksize, maxstacksize) + 1
				end
			else
				stacksize = maxstacksize
			end
			Commodity:SetCommodityData(tabindex, slot, itemid, stacksize)
		end
		Commodity:SetGuildBankSlotOverlay()
	elseif IsMouseButtonDown("RightButton") then
		local item
		if IsShiftKeyDown() then
			item = GetGuildBankItemLink(tabindex, slot)
		else
			item = Commodity:GetCommodityData(tabindex, slot)
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
			commodity_db.databaseversion = 1
			print("Hi! You seem to be new to Commodity, or somehow the Commodity database was deleted.")
			print("To get started, look at the top right corner of your guild bank, also write \"/commodity\" in your chat box :)")
		end
		if not commodity_db.guilds then
			commodity_db.guilds = {}
		end
		if not commodity_player then
			commodity_player = {
				showtooltip = 1,
				overlayvisible = 1
			}
		end
		if not commodity_player.overlayalpha then
			commodity_player.overlayalpha = 0.25
		end
		if not commodity_player.overlaydrawalpha then
			commodity_player.overlaydrawalpha = 0.7
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
			local overlaytext = button:CreateFontString("CommodityOverlayText" .. slot, "BACKGROUND", "NumberFontNormal")
			overlay:SetAllPoints(button)
			overlaytext:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
		end
		-- should we show tooltip?
		if commodity_player.showtooltip then
			CommodityTooltipFrame:SetScript("OnShow", Commodity.UpdateTooltip)
		end
		-- broadcast queue, for sending data to other clients at a sane speed
		Commodity.broadcastqueue = {}
		Commodity.broadcastdelay = 0
	elseif event == "GUILDBANKBAGSLOTS_CHANGED" then
		if Commodity:ScanGuildBankTab() then
			-- only sort if tab is changed
			Commodity:SortGuildBankTab()
		end
		Commodity:SetGuildBankSlotOverlay()
	elseif event == "CHAT_MSG_ADDON" and arg1 == "Commodity" and arg3 == "GUILD" and arg4 ~= GetUnitName("player") then
		-- Commodity message from someone else than me
		local _, _, messagetype, data = string.find(arg2, "^(.)(.*)$")
		if messagetype == "U" then
			-- when a tab was last updated
			local _, _, tabindex, timestamp = string.find(data, "^(%d)(%d+)$")
			if tabindex and timestamp then
				timestamp = tonumber(timestamp)
				local ourtimestamp = Commodity:GetTabLastUpdated(tabindex)
				if timestamp > ourtimestamp then
					-- this person got more recent data than us, request person to dump tab commodities
					Commodity:BroadcastRequest(tabindex, arg4)
				elseif timestamp < ourtimestamp then
					-- this person got less recent data than us, broadcast when our tab was last updated so person can request data
					Commodity:BroadcastTabLastUpdated(tabindex)
				end
			end
		elseif messagetype == "R" then
			-- person requesting tab data to be dumped
			local _, _, tabindex, player = string.find(data, "^(%d)(.+)$")
			if tabindex and player == GetUnitName("player") then
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
			local _, _, tabindex, timestamp = string.find(data, "^(%d)(%d+)$")
			if tabindex and timestamp and Commodity:GetTabLastUpdated(tabindex) < tonumber(timestamp) then
				if not Commodity.updatetabdata then
					Commodity.updatetabdata = {}
				end
				Commodity:DeleteTable(Commodity.updatetabdata[arg4])
				Commodity.updatetabdata[arg4] = {
					timestamp = tonumber(timestamp),
					itemids = {}
				}
			end
		elseif messagetype == "I" and Commodity.updatetabdata and Commodity.updatetabdata[arg4] then
			-- item
			if Commodity.updatetabdata then
				local _, _, itemidandstacksize, slots = string.find(data, "^(%d+:%d+):(%d+)$")
				local tabdata = Commodity.updatetabdata[arg4]
				if itemidandstacksize and slots and tabdata then
					tabdata.itemids[itemidandstacksize] = slots
				end
			end
		elseif messagetype == "E" and Commodity.updatetabdata and Commodity.updatetabdata[arg4] then
			-- end of item list
			if Commodity.updatetabdata then
				local _, _, tabindex, count = string.find(data, "^(%d)(%d+)$")
				local tabdata = Commodity.updatetabdata[arg4]
				if tabindex and count and tabdata then
					local count2 = 0
					if tabdata.timestamp > Commodity:GetTabLastUpdated(tabindex) then
						for itemidandstacksize, slots in pairs(tabdata.itemids) do
							local _, _, itemid, stacksize = string.find(itemidandstacksize, "(%d+):(%d+)")
							local length = strlen(slots)
							for start = 1, length, 2 do
								local slot = strsub(slots, start, start + 1)
								Commodity:SetCommodityData(tabindex, slot, itemid, stacksize)
							end
							count2 = count2 + 1
						end
						if count2 == tonumber(count) then
							Commodity:SetTabLastUpdated(tabindex, tabdata.timestamp)
							print(arg4 .. " sent us updated Commodity data for guild bank tab " .. tabindex .. "!")
							Commodity:SetGuildBankSlotOverlay()
						else
							print(arg4 .. " sent Commodity data, but we seem to have missed some of the transmission. Got " .. count2 .. " items, expected " .. count .. ".")
						end
					end
					Commodity:DeleteTable(Commodity.updatetabdata[arg4])
				end
			end
		end
	end
	if event == "ADDON_LOADED" or (event == "PLAYER_GUILD_UPDATE" and timesincelast > 0.01) then
		-- figure out which guild we're in
		-- this is slightly annoying, while "PLAYER_GUILD_UPDATE" should by all means of logic be the only event necessary,
		-- it's not quite that simple in the World of Warcraft.
		-- when you enter the world for the first time with a character, "ADDON_LOADED" is fired, and at this time,
		-- GetGuildName() will return nil.
		-- However, then "PLAYER_GUILD_UPDATE" will be fired like 100 times(!) before going completely silent,
		-- and before this is done spamming, GetGuildInfo() should return our guild name.
		-- Now on the other hand, if we /reload the game then "PLAYER_GUILD_UPDATE" won't be fired at all,
		-- but seemingly GetGuildInfo() returns our guild name when event "ADDON_LOADED" is sent.
		-- In case player decides to join another guild we should look for "PLAYER_GUILD_UPDATE" events.
		-- *sigh*
		local realmname = GetRealmName()
		local guildname = GetGuildInfo("player")
		if realmname and guildname then
			local realmguild = realmname .. " - " .. guildname
			if realmguild ~= Commodity.realmguild then
				local guilds = commodity_db.guilds
				if not guilds[realmguild] then
					guilds[realmguild] = {}
				end
				local guild = guilds[realmguild]
				if not guild.tabs then
					guild.tabs = {}
				end
				Commodity.realmguild = realmguild
				Commodity.tabs = guild.tabs
				-- and broadcast our status in case someone got updated data
				for tabindex = 1, 6 do
					Commodity:BroadcastTabLastUpdated(tabindex)
				end
			end
		else
			Commodity:DeleteTable(Commodity.realmguild)
			Commodity:DeleteTable(Commodity.tabs)
		end
	end
end

function Commodity:OnUpdate(elapsed)
	Commodity.broadcastdelay = Commodity.broadcastdelay - elapsed
	if Commodity.broadcastdelay <= 0 then
		local message = table.remove(Commodity.broadcastqueue, 1)
		if message then
			SendAddonMessage("Commodity", message, "GUILD")
			Commodity.broadcastdelay = 0.3
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
	-- clear cached items in this tab
	local tab = Commodity:GetTabData(tabindex)
	if not tab then
		return
	end
	Commodity:DeleteTable(tab.items)
	tab.items = {}
	local changed
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local _, newamount = GetGuildBankItemInfo(tabindex, slot)
		if newamount == 0 then
			newamount = nil
		end
		local newlink = GetGuildBankItemLink(tabindex, slot)
		local newitemid
		if newlink then
			_, _, newitemid = string.find(newlink, "item:(%d+):")
			newitemid = tonumber(newitemid)
		end
		-- set slot data
		local olditemid, oldamount = Commodity:GetSlotData(tabindex, slot)
		if olditemid ~= newitemid or oldamount ~= newamount then
			changed = 1
			Commodity:SetSlotData(tabindex, slot, newitemid, newamount)
		end
		-- set commodity/item data
		local commodityitemid, stacksize = Commodity:GetCommodityData(tabindex, slot)
		if commodityitemid then
			local _, _, _, _, _, _, _, maxstacksize = GetItemInfo(commodityitemid)
			if not stacksize then
				stacksize = maxstacksize
			end
			if stacksize then
				local itemamount, commodityamount = Commodity:GetItemData(tabindex, commodityitemid)
				if not commodityamount then
					commodityamount = 0
				end
				commodityamount = commodityamount + stacksize
				Commodity:SetItemData(tabindex, commodityitemid, itemamount, commodityamount)
			end
		end
		if newitemid and newamount then
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
		local itemid, stacksize = Commodity:GetCommodityData(tabindex, slot)
		if itemid then
			_, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemid)
		end
		local overlay = _G["CommodityOverlayTexture" .. slot]
		local overlaytext = _G["CommodityOverlayText" .. slot]
		if Commodity.drawmode then
			overlay:SetDrawLayer("OVERLAY")
			overlay:SetAlpha(commodity_player.overlaydrawalpha)
			overlaytext:SetDrawLayer("OVERLAY")
			overlaytext:SetAlpha(1.0)
			if not texture then
				texture = "Interface\\PaperDoll\\UI-Backpack-EmptySlot"
			end
		elseif commodity_player.overlayvisible then
			overlay:SetDrawLayer("BACKGROUND")
			overlay:SetAlpha(commodity_player.overlayalpha)
			if commodity_player.alwaysshowstacksize then
				overlaytext:SetDrawLayer("OVERLAY")
				overlaytext:SetAlpha(1.0)
			else
				overlaytext:SetDrawLayer("BACKGROUND")
				overlaytext:SetAlpha(commodity_player.overlayalpha)
			end
		else
			overlay:SetAlpha(0.0)
			overlaytext:SetAlpha(0.0)
		end
		overlay:SetTexture(texture)
		overlaytext:SetText(stacksize)
	end
end

function Commodity:SortGuildBankTab()
	if not commodity_player.sortguildbanktab then
		return
	end
	local tabindex = GetCurrentGuildBankTab()
	if not tabindex then
		return
	end
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local itemid, amount = Commodity:GetSlotData(tabindex, slot)
		if not amount then
			amount = 0
		end
		local commodityitemid, stacksize = Commodity:GetCommodityData(tabindex, slot)
		if itemid and not stacksize then
			_, _, _, _, _, _, _, stacksize = GetItemInfo(itemid)
		end
		if commodityitemid and (not itemid or commodityitemid ~= itemid or amount ~= stacksize) then
			-- reserved slot, but wrong item here, or too few/many items in stack
			local moveto, movefrom, moveamount
			for slot2 = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
				if slot2 ~= slot then
					local itemid2, amount2 = Commodity:GetSlotData(tabindex, slot2)
					if not amount2 then
						amount2 = 0
					end
					local commodityitemid2, stacksize2 = Commodity:GetCommodityData(tabindex, slot2)
					if itemid2 and not stacksize2 then
						_, _, _, _, _, _, _, stacksize2 = GetItemInfo(itemid2)
					end
					if not itemid then
						-- no item in reserved slot <slot>, move a matching stack of items there
						if itemid2 and itemid2 == commodityitemid then
							-- item in <slot2> match the reservation in <slot>
							if itemid2 ~= commodityitemid2 or slot2 > slot then
								-- this item is in a slot reserved for another item or it is in a later slot
								moveto = slot
								movefrom = slot2
								moveamount = math.min(stacksize, amount2)
								if itemid2 ~= commodityitemid2 then
									-- only break when we're moving a misplaced item
									break
								end
							elseif amount2 > stacksize2 then
								-- there are too many items in this slot!
								moveto = slot
								movefrom = slot2
								moveamount = math.min(stacksize, amount2 - stacksize2)
								break
							end
						end
					elseif itemid and itemid ~= commodityitemid then
						-- misplaced item in <slot>
						if not itemid2 and (not commodityitemid2 or itemid == commodityitemid2) then
							-- empty slot that's either not reserved or our item match the reservation, we can move it here
							moveto = slot2
							movefrom = slot
							moveamount = amount
							if commodityitemid2 then
								-- we want to place the item in the first slot reserved for this item
								-- and if we don't find such a reserved slot, we want to place it in the last non-reserved slot
								-- also, we may have a lower stack size in this reserved slot, hence:
								moveamount = math.min(amount, stacksize2)
								break
							end
						elseif itemid2 and itemid == itemid2 then
							-- same item, stack as much as possible, even if item in slot2 is misplaced (it will be moved later)
							if commodityitemid2 and itemid2 ~= commodityitemid2 then
								-- slot is reserved for something else, might as well fill up the stack
								_, _, _, _, _, _, _, stacksize2 = GetItemInfo(itemid2)
							end
							local tmpmoveamount = math.min(amount, stacksize2 - amount2)
							if tmpmoveamount > 0 then
								moveto = slot2
								movefrom = slot
								moveamount = tmpmoveamount
								break
							end
						elseif commodityitemid2 and itemid == commodityitemid2 then
							-- item in <slot> match reserved slot <slot2> (which, if any, got a misplaced item)
							-- move entire stack, we'll have to make more moves later anyways if <slot2> don't want that many items
							moveto = slot2
							movefrom = slot
							moveamount = amount
							break
						end
					elseif amount ~= stacksize and slot2 > slot then
						-- amount doesn't match stack size
						if amount > stacksize then
							-- too many items in stack
							if (not itemid2 and not commodityitemid2) or (itemid2 and itemid == itemid2 and amount2 < stacksize2) then
								-- free slot or slot with same item and room for more
								moveto = slot2
								movefrom = slot
								if not stacksize2 then
									-- moving to empty slot, non-reserved slot, target stacksize equals source stacksize
									_, _, _, _, _, _, _, stacksize2 = GetItemInfo(itemid)
								end
								moveamount = math.min(amount - stacksize, stacksize2 - amount2)
								if itemid2 then
									-- only break if we're moving items to another stack
									break
								end
							end
						else
							-- too few items in stack
							if itemid2 and itemid == itemid2 then
								-- found a stack of same item in a later slot
								moveto = slot
								movefrom = slot2
								moveamount = math.min(stacksize - amount, amount2)
							end
						end
					end
				end
			end
			if movefrom then
				ClearCursor()
				SplitGuildBankItem(tabindex, movefrom, moveamount)
				PickupGuildBankItem(tabindex, moveto)
				return
			end
		end
	end
end

function Commodity:UpdateTooltip()
	if not commodity_player.showtooltip or not Commodity.tabs then
		return
	end
	local itemname, itemlink = GameTooltip:GetItem()
	local itemid
	if itemlink then
		_, _, itemid = string.find(itemlink, "item:(%d+):")
		itemid = tonumber(itemid)
	end
	if not itemid then
		return
	end
	for tabindex, tab in pairs(Commodity.tabs) do
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
	tabindex = tonumber(tabindex)
	local commodities = {}
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local commodityitemid, stacksize = Commodity:GetCommodityData(tabindex, slot)
		if not commodityitemid then
			commodityitemid = 0
		end
		if not stacksize then
			_, _, _, _, _, _, _, stacksize = GetItemInfo(commodityitemid)
		end
		if not stacksize then
			stacksize = 0
		end
		local itemidandstacksize = commodityitemid .. ":" .. stacksize
		if not commodities[itemidandstacksize] then
			commodities[itemidandstacksize] = {}
		end
		local tmpslot = slot
		if tmpslot < 10 then
			tmpslot = "0" .. tmpslot
		end
		table.insert(commodities[itemidandstacksize], tmpslot)
	end
	table.insert(Commodity.broadcastqueue, "B" .. tabindex .. Commodity:GetTabLastUpdated(tabindex))
	local count = 0
	for itemidandstacksize, slots in pairs(commodities) do
		local message = "I" .. itemidandstacksize .. ":"
		for index, slot in ipairs(slots) do
			message = message .. slot
		end
		table.insert(Commodity.broadcastqueue, message)
		count = count + 1
	end
	table.insert(Commodity.broadcastqueue, "E" .. tabindex .. count)
	Commodity:DeleteTable(commodities)
	Commodity:SetScript("OnUpdate", Commodity.OnUpdate)
end

function Commodity:DeleteTable(table)
	-- unfortunately lua (or wow) still haven't figured out how to clean up tabless properly
	-- so to prevent calling the gc too often, we'll use our own method to delete a table
	if not table then
		return
	end
	if not type(table) ~= "table" then
		-- reached the leaf
		table = nil
		return
	end
	for key, value in pairs(table) do
		Commodity:DeleteTable(value)
		table[key] = nil
	end
	table = nil
end

function Commodity:GetTabData(tabindex)
	if not Commodity.tabs then
		return
	end
	tabindex = tonumber(tabindex)
	if not Commodity.tabs[tabindex] then
		Commodity.tabs[tabindex] = {}
	end
	return Commodity.tabs[tabindex]
end

function Commodity:SetCommodityData(tabindex, slot, itemid, stacksize)
	local tab = Commodity:GetTabData(tabindex)
	if not tab then
		return
	end
	if not tab.commodities then
		tab.commodities = {}
	end
	slot = tonumber(slot)
	itemid = tonumber(itemid)
	stacksize = tonumber(stacksize)
	if itemid == 0 then
		itemid = nil
	end
	if stacksize == 0 then
		stacksize = nil
	end
	if tab.commodities[slot] then
		-- prevent loose tables
		tab.commodities[slot].itemid = itemid
		tab.commodities[slot].stacksize = stacksize
	else
		tab.commodities[slot] = {
			itemid = itemid,
			stacksize = stacksize
		}
	end
	-- set that tab is updated when in drawmode (used to figure out which tabs to broadcast)
	if Commodity.drawmode and Commodity.tabsupdated then
		tabindex = tonumber(tabindex)
		Commodity.tabsupdated[tabindex] = 1
	end
end

function Commodity:GetCommodityData(tabindex, slot)
	local tab = Commodity:GetTabData(tabindex)
	if not tab then
		return
	end
	local commodities = tab.commodities
	if not commodities then
		return
	end
	slot = tonumber(slot)
	local commodity = commodities[slot]
	if not commodity then
		return
	end
	return commodity.itemid, commodity.stacksize
end

function Commodity:SetSlotData(tabindex, slot, itemid, amount)
	local tab = Commodity:GetTabData(tabindex)
	if not tab then
		return
	end
	if not tab.slots then
		tab.slots = {}
	end
	slot = tonumber(slot)
	itemid = tonumber(itemid)
	if itemid == 0 then
		itemid = nil
	end
	amount = tonumber(amount)
	if amount == 0 then
		amount = nil
	end
	if tab.slots[slot] then
		-- prevent loose tables
		tab.slots[slot].itemid = itemid
		tab.slots[slot].amount = amount
	else
		tab.slots[slot] = {
			itemid = itemid,
			amount = amount
		}
	end
end

function Commodity:GetSlotData(tabindex, slot)
	local tab = Commodity:GetTabData(tabindex)
	if not tab then
		return
	end
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
	if not tab then
		return
	end
	if not tab.items then
		tab.items = {}
	end
	itemid = tonumber(itemid)
	if not itemid or itemid == 0 then
		return
	end
	itemamount = tonumber(itemamount)
	if itemamount == 0 then
		itemamount = nil
	end
	commodityamount = tonumber(commodityamount)
	if commodityamount == 0 then
		commodityamount = nil
	end
	if tab.items[itemid] then
		-- prevent loose tables
		tab.items[itemid].itemamount = itemamount
		tab.items[itemid].commodityamount = commodityamount
	else
		tab.items[itemid] = {
			itemamount = itemamount,
			commodityamount = commodityamount
		}
	end
end

function Commodity:GetItemData(tabindex, itemid)
	local tab = Commodity:GetTabData(tabindex)
	if not tab then
		return
	end
	local items = tab.items
	if not items then
		return
	end
	itemid = tonumber(itemid)
	local item = items[itemid]
	if not item then
		return
	end
	return item.itemamount, item.commodityamount
end

function Commodity:SetTabLastUpdated(tabindex, timestamp)
	local tab = Commodity:GetTabData(tabindex)
	if not tab then
		return
	end
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
	if tab and tab.lastupdated then
		return tab.lastupdated
	end
	return 0
end

Commodity.eventtimes = {}

Commodity:SetScript("OnEvent", Commodity.OnEvent)
Commodity:RegisterEvent("ADDON_LOADED")
Commodity:RegisterEvent("PLAYER_GUILD_UPDATE")
Commodity:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
Commodity:RegisterEvent("CHAT_MSG_ADDON")
