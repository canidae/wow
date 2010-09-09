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
				Commodity:Draw(slot, itemlink)
				self:UpdateTooltip(self)
			end)
			button:SetScript("OnEnter", function(self, motion)
				Commodity:Draw(slot, itemlink)
				self:UpdateTooltip(self)
			end)
			button:SetScript("OnClick", nil)
			button:SetScript("OnDragStart", nil)
			button:SetScript("OnReceiveDrag", nil)
			button.UpdateTooltip = function(self)
				local tabindex = GetCurrentGuildBankTab()
				if tabindex then
					local tab = commodity_db.tabs[tabindex]
					if tab.commodities then
						local commoditylink = tab.commodities[slot]
						if commoditylink then
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
							GameTooltip:SetHyperlink(commoditylink);
						end
					end
				end
			end
		end
		Commodity.forceoverlay = 1
		Commodity:SetGuildBankSlotOverlay()
		if itemlink then
			print("Reserve slots for " .. itemlink .. " with left mouse button, remove slot reservation with right mouse button")
		else
			print("Item not given, both left and right mouse button will remove slot reservation")
		end
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
	else
		print("Commodity usage:")
		print("/commodity draw [item] - Reserve guild bank slots to given item")
		print("/commodity done - Exit draw mode")
	end
end

function Commodity:Draw(slot, itemlink)
	local tabindex = GetCurrentGuildBankTab()
	if tabindex then
		local tab = commodity_db.tabs[tabindex]
		if not tab.commodities then
			tab.commodities = {}
		end
		local commoditylink
		local draw
		if IsMouseButtonDown("LeftButton") then
			commoditylink = itemlink
			draw = 1
		elseif IsMouseButtonDown("RightButton") then
			commoditylink = nil
			draw = 1
		end
		if draw and tab.commodities[slot] ~= commoditylink then
			tab.commodities[slot] = commoditylink
			Commodity:SetGuildBankSlotOverlay()
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
			commodity_db.overlayalpha = 0.3
		end
		if not commodity_db.sortguildbanktabdelay then
			commodity_db.sortguildbanktabdelay = 0.3
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
			local overlay = button:CreateTexture("CommodityOverlayTexture" .. slot, "BACKGROUND")
			overlay:SetAllPoints(button)
		end
	elseif event == "GUILDBANKBAGSLOTS_CHANGED" then
		Commodity.sortguildbanktabdelay = commodity_db.sortguildbanktabdelay
		Commodity:SetScript("OnUpdate", Commodity.OnUpdate)
	end
end

function Commodity:OnUpdate(elapsed)
	Commodity.sortguildbanktabdelay = Commodity.sortguildbanktabdelay - elapsed
	if Commodity.sortguildbanktabdelay <= 0 then
		Commodity:SetScript("OnUpdate", nil)
		Commodity:ScanGuildBankTab()
		Commodity:SortGuildBankTab()
		Commodity:SetGuildBankSlotOverlay()
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

function Commodity:SetGuildBankSlotOverlay()
	local tabindex = GetCurrentGuildBankTab()
	if not tabindex then
		return
	end
	local tab = commodity_db.tabs[tabindex]
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local texture
		if (Commodity.forceoverlay or commodity_db.overlayvisible) and tab and tab.commodities then
			local commoditylink = tab.commodities[slot]
			if commoditylink then
				texture = GetItemIcon(commoditylink)
			end
		end
		local overlay = _G["CommodityOverlayTexture" .. slot]
		if Commodity.forceoverlay then
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
	if not tabindex or not commodity_db.tabs[tabindex] then
		return
	end
	local tab = commodity_db.tabs[tabindex]
	if not tab.commodities then
		tab.commodities = {}
	end
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local commodity = tab.commodities[slot]
		if commodity then
			-- we want a certain item in this slot (and it's not locked)
			local moveto
			local movefrom
			local partialmove
			local item = tab.slots[slot]
			if item then
				local _, _, _, _, _, _, _, maxstacksize = GetItemInfo(item)
				local _, stacksize = GetGuildBankItemInfo(tabindex, slot)
				-- there already is an item occupying this slot
				if item == commodity then
					-- correct item in slot, but is the stack filled?
					if stacksize < maxstacksize then
						-- it's not filled, should do something about that
						for slot2 = slot + 1, MAX_GUILDBANK_SLOTS_PER_TAB do
							local swapitem = tab.slots[slot2]
							if swapitem and swapitem == item then
								-- found another stack of same item
								local _, stacksize2 = GetGuildBankItemInfo(tabindex, slot2)
								partialmove = math.min(maxstacksize - stacksize, stacksize2)
								moveto = slot
								movefrom = slot2
								break
							end
						end
					end
				else
					-- oh dear, wrong item in slot
					for slot2 = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
						local swapitem = tab.slots[slot2]
						if not tab.commodities[slot2] or tab.commodities[slot2] == item then
							-- slot not reserved or reserved for same item
							local _, stacksize2 = GetGuildBankItemInfo(tabindex, slot2)
							if not swapitem or ((swapitem ~= item and swapitem == commodity) or (swapitem == item and stacksize + stacksize2 <= maxstacksize)) then
								-- either empty slot or slot with same item and room enough to stack all items here
								-- or the item we're swapping against actually want to be in current slot
								moveto = slot2
								movefrom = slot
								break
							end
						end
					end
				end
			else
				-- no item currently in this slot
				for slot2 = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
					local swapitem = tab.slots[slot2]
					if swapitem and (tab.commodities[slot2] ~= commodity or slot2 > slot) and swapitem == commodity then
						-- found an item that match this commodity
						moveto = slot
						movefrom = slot2
						break
					end
				end
			end
			if movefrom then
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

Commodity.eventtimes = {}

Commodity:SetScript("OnEvent", Commodity.OnEvent)
Commodity:RegisterEvent("ADDON_LOADED")
Commodity:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
