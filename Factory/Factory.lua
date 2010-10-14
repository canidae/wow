Factory = CreateFrame("Frame")

function Factory:OnEvent(event, arg1, ...)
	local timesincelast = GetTime()
	if Factory.eventtimes[event] then
		timesincelast = timesincelast - Factory.eventtimes[event]
	end
	Factory.eventtimes[event] = GetTime()
	if event == "ADDON_LOADED" and arg1 == "Factory" then
		self:UnregisterEvent("ADDON_LOADED")
		if not factory_items or not factory_items.version or factory_items.version ~= 1 then
			factory_items = {}
			factory_items.version = 1
		end
		if not factory_products or not factory_products.version or factory_products.version ~= 1 then
			factory_products = {}
			factory_products.version = 1
		end
		if not factory_resources or not factory_resources.version or factory_resources.version ~= 1 then
			factory_resources = {}
			factory_resources.version = 1
		end
		if not factory_resources.luggage then
			factory_resources.luggage = {}
		end
		if not factory_resources.bank then
			factory_resources.bank = {}
		end
		if not factory_resources.guildbank then
			factory_resources.guildbank = {}
		end
		if not factory_workbench then
			factory_workbench = {}
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		Factory.playername = GetUnitName("player")
	elseif event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE" then
		Factory:ScanProfession()
		Factory:ScanLuggage()
		Factory:UpdateFactoryFrame()
	elseif event == "BANKFRAME_CLOSED" then
		if timesincelast > 0.1 then
			-- event is called twice when closing bank frame
			-- according to the documentation the items in the bank should be visible for the first event
			Factory:ScanBank()
			Factory:UpdateFactoryFrame()
		end
	elseif event == "GUILDBANKBAGSLOTS_CHANGED" or event == "GUILDBANKFRAME_CLOSED" then
		if timesincelast > 0.1 then
			-- same reasons as BANKFRAME_CLOSED
			Factory:ScanGuildBankTab()
			Factory:UpdateFactoryFrame()
		end
	elseif event == "BAG_UPDATE" and (FactoryFrame:IsVisible() or FactoryReagentFrame:IsVisible()) then
		Factory:ScanLuggage()
		Factory:UpdateFactoryFrame()
	end
end

function Factory:UpdateFactoryFrame()
	local steps = {}
	local reagents = {}
	local frametext = "|cffd96109" .. "Workbench:" .. "|r" .. "\n"
	for productname, count in pairs(factory_workbench) do
		Factory:GetStepsAndReagents(productname, count, steps, reagents)
		frametext = frametext .. count .. "x" .. factory_items[productname].link .. Factory:CheckReagentsKnown(productname) .. "\n"
	end
	frametext = frametext .. "\n" .. "|cff2c4df8" .. "Required steps:" .. "|r" .. "\n"
	for stepname, stepcount in pairs(steps) do
		if stepcount < 0 then
			local banktext = "(|cff00ff00" .. Factory:BankItemCount(stepname) .. "|r/|cff0088ff" .. Factory:GuildBankItemCount(stepname) .. "|r)"
			frametext = frametext .. (0 - stepcount) .. "x" .. factory_items[stepname].link .. banktext .. Factory:CheckReagentsKnown(stepname) .. "\n"
		end
	end
	frametext = frametext .. "\n" .. "|cff25de36" .. "Missing reagents:" .. "|r" .. "\n"
	local reagentframetext = ""
	for reagentname, reagentcount in pairs(reagents) do
		if reagentcount < 0 then
			local banktext = "(|cff00ff00" .. Factory:BankItemCount(reagentname) .. "|r/|cff0088ff" .. Factory:GuildBankItemCount(reagentname) .. "|r)"
			local tmptext = (0 - reagentcount) .. "x" .. factory_items[reagentname].link .. banktext .. "\n"
			frametext = frametext .. tmptext
			reagentframetext = reagentframetext .. tmptext
		end
	end
	FactoryFrameInfoText:SetText(frametext)
	FactoryReagentFrameInfoText:SetText(reagentframetext)
end

function Factory:CheckReagentsKnown(productname)
	for professionname, product in pairs(factory_items[productname].professions) do
		if product.reagents then
			return ""
		end
	end
	return Factory.levels.error .. " (reagents not known)" .. "|r"
end

function Factory:GetStepsAndReagents(productname, amount, steps, reagents)
	for professionname, product in pairs(factory_items[productname].professions) do
		for reagentname, reagentcount in pairs(product.reagents) do
			-- multiply how many <productname> we should produce by <count> reagents
			local count = amount * reagentcount
			-- is reagent producable and can we produce it?
			local stepprofessionname
			if factory_products[reagentname] then
				for tmpprofessionname, difficulty in pairs(factory_products[reagentname]) do
					if GetSpellInfo(tmpprofessionname) then
						stepprofessionname = tmpprofessionname
					end
				end
			end
			if stepprofessionname then
				-- yes, we can produce it
				local reagent = factory_items[reagentname].professions[stepprofessionname]
				if not steps[reagentname] then
					steps[reagentname] = Factory:LuggageItemCount(reagentname)
				end
				if steps[reagentname] > count then
					-- don't need to produce any of these, got enough
					steps[reagentname] = steps[reagentname] - count
					count = 0
				elseif steps[reagentname] > 0 then
					-- need to produce some or all of these
					count = count - steps[reagentname]
					steps[reagentname] = 0
				end
				steps[reagentname] = steps[reagentname] - count
				-- divide by amount the step produce
				count = math.ceil(count / math.floor((reagent.min_produced + reagent.max_produced) / 2))
				-- recursively add reagents to make this part
				Factory:GetStepsAndReagents(reagentname, count, steps, reagents)
			else
				-- no, we'll need to get this item in some other way
				if not reagents[reagentname] then
					reagents[reagentname] = Factory:LuggageItemCount(reagentname)
				end
				reagents[reagentname] = reagents[reagentname] - count
			end
		end
	end
end

function Factory:EasierThan(newdifficulty, olddifficulty)
	if not olddifficulty then
		return true
	elseif newdifficulty == "trivial" then
		return true
	elseif newdifficulty == "easy" and olddifficulty ~= "trivial" then
		return true
	elseif newdifficulty == "medium" and olddifficulty == "optimal" then
		return true
	end
	return false
end

function Factory:StartProduction()
	Factory:ScanLuggage()
	local professionopen, _, _ = GetTradeSkillLine()
	if not professionopen or professionopen == "UNKNOWN" then
		Factory:Print("You need to open a trade skill window in order to produce items", Factory.levels.error)
		return
	end
	-- produce items
	local steps = {}
	local reagents = {}
	for productname, count in pairs(factory_workbench) do
		Factory:GetStepsAndReagents(productname, count, steps, reagents)
		-- add target product to steps
		if steps[productname] then
			steps[productname] = steps[productname] - count
		else
			steps[productname] = 0 - count
		end
	end
	-- filter out stuff we can't make in the currently open tradeskill window and stuff we're missing reagents for
	local produce = {}
	local switchprofession
	for stepname, count in pairs(steps) do
		if not switchprofession then
			local canmake = math.min(Factory:CanProduceCount(stepname, professionopen), 0 - count)
			if canmake > 0 then
				if not factory_items[stepname].professions[professionopen] then
					for professionname, product in pairs(factory_items[stepname].professions) do
						if not switchprofession then
							switchprofession = professionname
						else
							switchprofession = switchprofession .. " or " .. professionname
						end
					end
				else
					produce[stepname] = canmake
				end
			end
		end
	end
	-- find the easiest tradeskill
	local productname
	local count
	for stepname, stepcount in pairs(produce) do
		if not productname or Factory:EasierThan(factory_products[stepname], factory_products[productname]) then
			productname = stepname
			count = stepcount
		end
	end
	-- do we have a product to produce?
	if not productname then
		if switchprofession then
			Factory:Print("Must change tradeskill window to " .. switchprofession .. " in order to continue the production", Factory.levels.notice)
		else
			Factory:Print("Nothing else can be done at this time", Factory.levels.notice)
		end
		return
	end
	-- then produce the item
	local item = factory_items[productname]
	local product = item.professions[professionopen]
	local stepcount = math.ceil(count / math.floor((product.min_produced + product.max_produced) / 2))
	local extra = ""
	if stepcount ~= count then
		extra = " (" .. stepcount .. " executions)"
	end
	Factory:Print("Producing " .. count .. " of " .. (0 - steps[productname]) .. " " .. item.link .. extra)
	for index = 1, GetNumTradeSkills() do
		local tmpproductname, difficulty, _, _, _ = GetTradeSkillInfo(index)
		if tmpproductname and difficulty ~= "header" then
			local productitemlink = GetTradeSkillItemLink(index)
			local _, tmp2productname, _ = strsplit("[]", productitemlink)
			if productname == tmp2productname then
				if factory_workbench[productname] then
					-- producing the final item
					if count < factory_workbench[productname] then
						-- not producing all of them, remove just as many as we're producing
						Factory:Print(count .. " of the " .. factory_workbench[productname] .. " " .. item.link .. " has been removed from the workbench", Factory.levels.notice)
						factory_workbench[productname] = factory_workbench[productname] - count
					else
						-- producing all of them, remove from workbench
						Factory:Print(item.link .. " has been removed from the workbench", Factory.levels.notice)
						factory_workbench[productname] = nil
					end
				end
				DoTradeSkill(index, stepcount)
				return
			end
		end
	end
	Factory:Print("Unable to find " .. productname .. " in the tradeskill window, maybe it's in a collapsed category? Or perhaps you've filtered out some tradeskills?", Factory.levels.error)
end

function Factory:CanProduceCount(productname)
	if not factory_items[productname] then
		return 0
	end
	local count
	for professionname, product in pairs(factory_items[productname].professions) do
		if GetSpellInfo(professionname) then
			for reagentname, reagentcount in pairs(product.reagents) do
				local tmp_count = math.floor(Factory:LuggageItemCount(reagentname) / reagentcount)
				if not count or tmp_count < count then
					count = tmp_count
				end
			end
			if not count then
				return 0
			end
			return count * math.floor((product.min_produced + product.max_produced) / 2)
		end
	end
	return 0
end

function Factory:Print(msg, level)
	if not msg then
		return
	end
	if not level then
		level = Factory.levels.info
	end
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(level .. "[Factory] " .. "|r" .. msg)
	end
end

function Factory:LuggageItemCount(itemname)
	if not factory_resources.luggage[itemname] then
		return 0
	end
	return factory_resources.luggage[itemname]
end

function Factory:BankItemCount(itemname)
	if not factory_resources.bank[itemname] then
		return 0
	end
	return factory_resources.bank[itemname]
end

function Factory:GuildBankItemCount(itemname)
	local count = 0
	for tab, item in pairs(factory_resources.guildbank) do
		if item[itemname] then
			count = count + item[itemname]
		end
	end
	return count
end

function Factory:ScanBag(bag, container)
	for slot = 1, GetContainerNumSlots(bag) do
		local _, amount, locked, _, _ = GetContainerItemInfo(bag, slot)
		if amount and amount > 0 and not locked then
			local itemlink = GetContainerItemLink(bag, slot)
			local _, itemname, _ = strsplit("[]", itemlink)
			if container[itemname] then
				container[itemname] = container[itemname] + amount
			else
				container[itemname] = amount
			end
		end
	end
end

function Factory:ScanLuggage()
	factory_resources.luggage = {}
	for bag = 0, NUM_BAG_SLOTS do
		Factory:ScanBag(bag, factory_resources.luggage)
	end
end

function Factory:ScanBank()
	factory_resources.bank = {}
	Factory:ScanBag(BANK_CONTAINER, factory_resources.bank)
	for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
		Factory:ScanBag(bag, factory_resources.bank)
	end
end

function Factory:ScanGuildBankTab()
	local tab = GetCurrentGuildBankTab()
	factory_resources.guildbank[tab] = {}
	local guildbanktab = factory_resources.guildbank[tab]
	for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local _, amount, locked = GetGuildBankItemInfo(tab, slot)
		if amount and amount > 0 and not locked then
			local itemlink = GetGuildBankItemLink(tab, slot)
			if itemlink then
				local _, itemname, _ = strsplit("[]", itemlink)
				if guildbanktab[itemname] then
					guildbanktab[itemname] = guildbanktab[itemname] + amount
				else
					guildbanktab[itemname] = amount
				end
			end
		end
	end
end

function Factory:ScanProfession()
	local professionname, level, maxlevel = GetTradeSkillLine()
	for index = 1, GetNumTradeSkills() do
		local tmpproductname, difficulty, _, _, _ = GetTradeSkillInfo(index)
		if tmpproductname and difficulty ~= "header" then
			local productitemlink = GetTradeSkillItemLink(index)
			if productitemlink then
				local min_produced, max_produced = GetTradeSkillNumMade(index)
				local _, productname, _ = strsplit("[]", productitemlink)
				-- add product to global database
				if not factory_items[productname] then
					factory_items[productname] = {
						link = productitemlink
					}
				end
				local item = factory_items[productname]
				if not item.professions then
					item.professions = {
					}
				end
				item.professions[professionname] = {
					min_produced = min_produced,
					max_produced = max_produced
				}
				item = item.professions[professionname]
				-- add product to player database
				if not factory_products[productname] then
					factory_products[productname] = {}
				end
				factory_products[productname][professionname] = difficulty
				-- fetch reagents
				for rindex = 1, GetTradeSkillNumReagents(index) do
					local reagentitemlink = GetTradeSkillReagentItemLink(index, rindex)
					if reagentitemlink then
						local _, _, count, _ = GetTradeSkillReagentInfo(index, rindex)
						local _, reagentname, _ = strsplit("[]", reagentitemlink)
						-- add reagent to global database
						if not factory_items[reagentname] then
							factory_items[reagentname] = {}
						end
						factory_items[reagentname].link = reagentitemlink
						-- add reagents to product in global database
						if not item.reagents then
							item.reagents = {}
						end
						item.reagents[reagentname] = count
					end
				end
			end
		end
	end
end

Factory.eventtimes = {}

Factory.levels = {
	info = "|cff2711fd",
	notice = "|cfffdb211",
	warning = "|cffd43200",
	error = "|cffff0000"
}

Factory:SetScript("OnEvent", Factory.OnEvent)

Factory:RegisterEvent("ADDON_LOADED")
Factory:RegisterEvent("PLAYER_ENTERING_WORLD")
Factory:RegisterEvent("TRADE_SKILL_SHOW")
Factory:RegisterEvent("TRADE_SKILL_UPDATE")
Factory:RegisterEvent("BANKFRAME_CLOSED")
Factory:RegisterEvent("GUILDBANKFRAME_CLOSED")
Factory:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
Factory:RegisterEvent("BAG_UPDATE")
