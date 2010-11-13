Profit = CreateFrame("Frame")

function Profit:OnEvent(event, arg1, ...)
	local timesincelast = GetTime()
	if Profit.eventtimes[event] then
		timesincelast = timesincelast - Profit.eventtimes[event]
	end
	--print(event, timesincelast)
	Profit.eventtimes[event] = GetTime()
	if event == "ADDON_LOADED" and arg1 == "Profit" then
		self:UnregisterEvent("ADDON_LOADED")
		if not profit_db then
			profit_db = {}
		end
		if not profit_db.items then
			-- item data
			profit_db.items = {}
		end
		if not profit_db.selltime then
			-- how long to put up the item (1 = 8h, 2 = 24h, 3 = 48h, any other value is duration in minutes)
			profit_db.selltime = 2
		end
		if not profit_db.sellbidpercent then
			-- the bid price relative to buyout price
			profit_db.sellbidpercent = 0.95
		end
		if not profit_db.sellundercutpercent then
			-- how much to undercut competitors
			profit_db.sellundercutpercent = 0.001
		end
		if not profit_db.sellprofitpercent then
			-- how much profit we at least want to make, relative to vendor price
			profit_db.sellprofitpercent = 1.80
		end
		-- set sell time in auction frame to our global sell time
		AuctionFrameAuctions.duration = profit_db.selltime
		-- some hooking
		AuctionsStackSizeEntry:HookScript("OnEditFocusLost", Profit.RememberStackSize)
		AuctionsStackSizeMaxButton:HookScript("OnClick", Profit.RememberStackSize)
		hooksecurefunc("DurationDropDown_OnClick", Profit.RememberDuration)
	elseif event == "AUCTION_ITEM_LIST_UPDATE" then
		Profit:SetScript("OnUpdate", Profit.OnUpdate)
	elseif event == "NEW_AUCTION_UPDATE" then
		Profit:AuctionItem()
	end
end

function Profit:RememberStackSize()
	local itemname, _, _, _, _, _, _, maxstacksize, totalcount = GetAuctionSellItemInfo()
	if not itemname then
		return
	end
	if not profit_db.items[itemname] then
		profit_db.items[itemname] = {}
	end
	local stacksize = AuctionsStackSizeEntry:GetNumber()
	if stacksize == maxstacksize or stacksize == totalcount then
		profit_db.items[itemname].stacksize = nil
		print(Profit.msg, "Using max stack size when selling", itemname)
	else
		profit_db.items[itemname].stacksize = stacksize
		print(Profit.msg, "Using stack size of", stacksize, "when selling", itemname)
	end
	AuctionsNumStacksMaxButton:Click()
end

function Profit:RememberDuration()
	local itemname = GetAuctionSellItemInfo()
	local msg
	if not itemname then
		profit_db.selltime = AuctionFrameAuctions.duration
		msg = "Global sell time"
	else
		if not profit_db.items[itemname] then
			profit_db.items[itemname] = {}
		end
		profit_db.items[itemname].selltime = AuctionFrameAuctions.duration
		msg = "Sell time for " .. itemname
	end
	local textduration = UIDropDownMenu_GetText(DurationDropDown)
	if textduration == CUSTOM then
		textduration = AuctionFrameAuctions.duration
	end
	print(Profit.msg, msg, "set to", textduration)
end

function Profit:OnUpdate()
	if not CanSendAuctionQuery() then
		return
	end
	-- no point calling this method before we get the next AUCTION_ITEM_LIST_UPDATE event
	Profit:SetScript("OnUpdate", nil)
	if not Profit.scan then
		-- we didn't scan, don't fetch data from listed auctions
		return
	end
	-- fetch data
	local batch, total = GetNumAuctionItems("list")
	local wasnil = 0
	for index = 1, batch do
		local itemlink = GetAuctionItemLink("list", index)
		if itemlink then
			local _, _, count, _, _, _, minbid, increment, buyout, currentbid, mybid, seller = GetAuctionItemInfo("list", index)
			local itemname, itemlink, itemrarity = GetItemInfo(itemlink)
			if itemrarity > 0 and buyout > 0 then
				local priceperitem = math.ceil(buyout / count)
				if not Profit.items[itemname] then
					Profit.items[itemname] = {
						prices = {}
					}
				end
				if seller == GetUnitName("player") then
					if not Profit.items[itemname].myprice or priceperitem < Profit.items[itemname].myprice then
						Profit.items[itemname].myprice = priceperitem
					end
				else
					table.insert(Profit.items[itemname].prices, priceperitem)
				end
			end
		else
			wasnil = wasnil + 1
		end
	end
	if wasnil > 0 then
		-- TODO: can we improve this? rescanning page won't work (we'll get duplicate data for items we got link to)
		print(Profit.msg, "Missing itemlink for", wasnil, "items on page", Profit.page .. ", skipping items")
	end
	-- update status bar
	Profit.page = Profit.page + 1
	local pages
	if batch > 0 then
		pages = math.ceil(total / 50)
	else
		pages = 0
	end
	ProfitScanStatusBar:SetMinMaxValues(0, pages)
	ProfitScanStatusBar:SetValue(Profit.page)
	ProfitScanStatusBarText:SetText("Page " .. Profit.page .. " of " .. pages)
	-- check whether we're done or have to scan some more
	if batch == 50 then
		-- more pages to be scanned
		QueryAuctionItems(Profit.scan, 0, 0, 0, 0, 0, Profit.page, 0, 0, 0)
		return
	end
	-- last page reached
	for itemname, data in pairs(Profit.items) do
		-- calculate prices
		local totalprice = 0
		local values = 0
		for index, value in ipairs(data.prices) do
			totalprice = totalprice + value
			values = values + 1
		end
		local average = math.ceil(totalprice / values)
		local stddev = 0
		for index, value in ipairs(data.prices) do
			stddev = stddev + math.pow(value - average, 2)
		end
		stddev = math.ceil(math.sqrt(stddev / values))
		-- filter out absurd prices
		local filtered = {}
		local minprice = nil
		totalprice = 0
		values = 0
		for index, value in ipairs(data.prices) do
			if value >= average - stddev and value <= average + stddev then
				table.insert(filtered, value)
				totalprice = totalprice + value
				values = values + 1
			end
			if not minprice or minprice > value then
				minprice = value
			end
		end
		average = math.ceil(totalprice / values)
		stddev = 0
		for index, value in ipairs(filtered) do
			stddev = stddev + math.pow(value - average, 2)
		end
		stddev = math.ceil(math.sqrt(stddev / values))
		-- add data to database
		Profit:SetItemData(itemname, minprice, average, stddev, data.myprice, values)
	end
	-- stop scanning
	ProfitScanButton:Enable()
	Profit.scan = nil
	Profit.page = 0
	-- call AuctionItem if we're auctioning an item
	if Profit.auctioning then
		Profit:AuctionItem()
		Profit.auctioning = nil
	end
end

function Profit:SetItemData(itemname, minprice, average, stddev, myprice, auctions)
	-- add item to database
	local hour, minute = GetGameTime()
	local _, month, day, year = CalendarGetDate()
	if not profit_db.items[itemname] then
		profit_db.items[itemname] = {}
	end
	local item = profit_db.items[itemname]
	-- keep minprice/average/stddev/myprice if we got no new data for these
	item.minprice = minprice or item.minprice
	item.average = average or item.average
	item.stddev = stddev or item.stddev
	item.myprice = myprice or item.myprice
	item.auctions = auctions
	item.year = year
	item.month = month
	item.day = day
	item.hour = hour
	item.minute = minute
end

function Profit:StartScan(itemname)
	if not CanSendAuctionQuery() then
		return
	end
	ProfitScanButton:Disable()
	Profit.scan = itemname
	Profit.page = 0
	if Profit.items then
		wipe(Profit.items)
	else
		Profit.items = {}
	end
	QueryAuctionItems(Profit.scan, 0, 0, 0, 0, 0, Profit.page, 0, 0, 0)
end

function Profit:AuctionItem()
	local itemname, _, count, _, _, _, itemvendorprice, maxstacksize, totalcount = GetAuctionSellItemInfo()
	if not itemname then
		return
	end
	if not itemvendorprice or itemvendorprice < 1 then
		itemvendorprice = 1
	end
	local item = profit_db.items[itemname]
	if not item or Profit:MinutesSinceLastScan(itemname) > 10 then
		-- data is too old, need to rescan
		Profit.auctioning = 1
		if item then
			-- update timestamp (to prevent it from being scanned endlessly if item is not already being sold on ah)
			Profit:SetItemData(itemname, item.minprice, item.average, item.stddev, item.myprice, item.auctions)
		else
			-- item not in db, add it
			Profit:SetItemData(itemname)
		end
		AuctionsCreateAuctionButton:SetText("Scanning...")
		Profit:StartScan(itemname)
		return
	end
	AuctionsCreateAuctionButton:SetText(CREATE_AUCTION)
	local _, itemlink = GetItemInfo(itemname)
	local buyoutprice = Profit:GetBuyoutPricePerItem(itemname)
	if not buyoutprice then
		print(Profit.msg, "Unable to find price for " .. itemlink .. ", possibly never seen the item on the Auction House")
		return
	end
	-- we got what we need of information to sell this item
	local stacksize = math.min(item.stacksize or maxstacksize, totalcount)
	local stacks = math.max(math.floor(totalcount / stacksize), 1)
	buyoutprice = math.floor(buyoutprice)
	local bidprice = math.floor(buyoutprice * profit_db.sellbidpercent)
	local selltime = item.selltime or profit_db.selltime
	local deposit = CalculateAuctionDeposit(selltime, 1, 1)
	-- update fields
	AuctionsStackSizeEntry:SetNumber(stacksize)
	AuctionsNumStacksEntry:SetNumber(stacks)
	AuctionFrameAuctions.priceType = 1 -- should really be PRICE_TYPE_UNIT, but that is apparently local :\
	PriceDropDown:Hide() -- to update the dropdown value
	PriceDropDown:Show() -- ditto ^^
	MoneyInputFrame_SetCopper(StartPrice, bidprice)
	MoneyInputFrame_SetCopper(BuyoutPrice, buyoutprice)
	AuctionFrameAuctions.duration = selltime
	DurationDropDown:Hide() -- to update the dropdown value
	DurationDropDown:Show() -- ditto ^^
	UpdateDeposit()
	AuctionsFrameAuctions_ValidateAuction()
	-- print warning if profit is low
	if bidprice < itemvendorprice * profit_db.sellprofitpercent + deposit then
		print(Profit.msg, "Low profit for", itemlink .. ":|cffff0000", math.floor(bidprice * 100 / (itemvendorprice + deposit) - 100) .. "%/" .. math.floor(buyoutprice * 100 / (itemvendorprice + deposit) - 100) .. "%|r")
	end
end

function Profit:GetBuyoutPricePerItem(itemname)
	local item = profit_db.items[itemname]
	if item then
		if item.average and item.stddev and item.minprice and item.auctions > 0 then
			-- auctions of this item already out, find optimal price
			return math.max(item.minprice, item.average - item.stddev) * (1.0 - profit_db.sellundercutpercent)
		elseif item.myprice then
			-- we seem to be the only one with an auction of this item at the moment
			return item.myprice
		end
	end
end

function Profit:MinutesSinceLastScan(itemname)
	local item = profit_db.items[itemname]
	if not item or not item.year then
		-- just return a really large number for simplicity
		return 3141592654
	end
	local itemscantime = item.year * 525600 + item.day * 1440 + item.hour * 60 + item.minute
	local hour, minute = GetGameTime()
	local _, month, day, year = CalendarGetDate()
	local currenttime = year * 525600 + day * 1440 + hour * 60 + minute
	for index, days in ipairs(Profit.daysinmonth) do
		if index < item.month then
			itemscantime = itemscantime + days * 1440
		end
		if index < month then
			currenttime = currenttime + days * 1440
		end
	end
	return currenttime - itemscantime
end

function Profit:UpdateTooltip()
	local itemname, itemlink = GameTooltip:GetItem()
	if not itemlink then
		return
	end
	local buyoutprice = Profit:GetBuyoutPricePerItem(itemname)
	if buyoutprice then
		local minutes = Profit:MinutesSinceLastScan(itemname)
		local lastscan
		if minutes >= 6000 then
			lastscan = "a long time"
		else
			if minutes >= 60 then
				lastscan = math.floor(minutes / 60) .. "h" .. math.fmod(minutes, 60) .. "m"
			else
				lastscan = minutes .. "m"
			end
		end
		GameTooltip:AddLine("Profit (scanned " .. lastscan .. " ago):")
		local item = profit_db.items[itemname]
		local counttext = getglobal(GetMouseFocus():GetName() .. "Count")
		local count
		if counttext and counttext:IsVisible() then
			count = tonumber(counttext:GetText())
		end
		if not count or count < 1 then
			count = 1
		end
		if profit_db.detailed then
			if item.average then
				SetTooltipMoney(GameTooltip, math.floor(item.average * count), nil, "Average:", nil)
			end
			if item.minprice then
				SetTooltipMoney(GameTooltip, math.floor(item.minprice * count), nil, "Minimum:", nil)
			end
			if item.stddev and item.stddev > 0 then
				SetTooltipMoney(GameTooltip, math.floor(item.stddev * count), nil, "Deviation:", nil)
			end
			if item.myprice then
				SetTooltipMoney(GameTooltip, math.floor(item.myprice * count), nil, "My price:", nil)
			end
			GameTooltip:AddLine("Rivaling auctions: " .. item.auctions)
		end
		SetTooltipMoney(GameTooltip, math.floor(buyoutprice), nil, "1x@AH:", nil)
		if count > 1 then
			SetTooltipMoney(GameTooltip, math.floor(buyoutprice * count), nil, count .. "x@AH:", nil)
		end
	end
end

Profit.eventtimes = {}
Profit.page = 0
Profit.daysinmonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
Profit.msg = "|cff81c30f[Profit]|r"

Profit:SetScript("OnEvent", Profit.OnEvent)

Profit:RegisterEvent("ADDON_LOADED")
Profit:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
Profit:RegisterEvent("NEW_AUCTION_UPDATE")
