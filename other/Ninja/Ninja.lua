Ninja = CreateFrame("Frame")

SLASH_Ninja1 = "/ninja"
function SlashCmdList.Ninja(msg)
	msg = strtrim(msg or "")
	if msg == "" then
		InterfaceOptionsFrame_OpenToCategory("Ninja")
	elseif msg == "on" then
		ninja_db.enabled = 1
		NinjaEnabledCheckButton:SetChecked(ninja_db.enabled)
		print("Ninja enabled")
	elseif msg == "off" then
		ninja_db.enabled = nil
		NinjaEnabledCheckButton:SetChecked(ninja_db.enabled)
		print("Ninja disabled")
	else
		print("Ninja usage:")
		print("/ninja - open configuration")
		print("/ninja on/off - enable/disable")
	end
end

function Ninja:OnEvent(event, arg1, arg2, ...)
	if event == "ADDON_LOADED" and arg1 == "Ninja" then
		if not ninja_db then
			ninja_db = {}
			ninja_db.enabled = 1
		end
		if not ninja_db.codes then
			ninja_db.codes = {}
		end
		if not ninja_db.rolldelay then
			ninja_db.rolldelay = 10
		end
		if not ninja_db.betweendelay then
			ninja_db.betweendelay = 2
		end

		-- hook functions
		Ninja.ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
		ChatFrame_OnHyperlinkShow = function(...)
			local chatFrame, link, text, button = ...
			local _, _, rollidandtype = string.find(link, "^ninja:(%d+:%d+)$")
			if rollidandtype then
				local _, _, rollid, rolltype = string.find(rollidandtype, "(%d+):(%d+)")
				rollid = tonumber(rollid)
				-- make sure we've not rolled on it already and that we're not already showing it
				local show = 1
				if Ninja.rolled[rollid] then
					print("Too late, already rolled on item")
					show = nil
				else
					for frameid = 1, NUM_GROUP_LOOT_FRAMES do
						local frame = getglobal("GroupLootFrame" .. frameid)
						if frame:IsShown() and tonumber(frame.rollID) == rollid then
							show = nil
							break
						end
					end
				end
				local timeleft = GetLootRollTimeLeft(rollid)
				if show and timeleft and timeleft > 0 then
					GroupLootFrame_OpenNewFrame(rollid, timeleft)
					Ninja.rolled[rollid] = 1
				end
				Ninja.rolls[rollidandtype] = nil
			else
				Ninja.ChatFrame_OnHyperlinkShow(...)
			end
		end

		-- load settings
		Ninja:LoadSettings()

		-- set help text (don't like this, have to keep it up to date manually)
		Ninja:AddHelpLine("r.<key>", "41d5c9", "The item being rolled for")
		Ninja:AddHelpLine("c.<key>", "c843c6", "An item in a matching inventory slot")
		Ninja:AddHelpLine("number", "number", "A numeric value [-1,∞], never <nil>, -1 == unknown value")
		Ninja:AddHelpLine("string", "string", "A string value, never <nil>, no value is \"\"")
		Ninja:AddHelpLine("boolean", "boolean", "A boolean value")
		Ninja:AddHelpLine()
		Ninja:AddHelpLine("Item info:", "bbbbbb")
		Ninja:AddHelpLine("id", "number", "Item ID (-1 if unknown)")
		Ninja:AddHelpLine("rarity", "number", "Item rarity (see also poor, common, etc below. -1 if unknown)")
		Ninja:AddHelpLine("level/equiplevel", "number", "Item level/equip level (-1 if unknown)")
		Ninja:AddHelpLine("stack", "number", "Item max stack size (-1 if unknown)")
		Ninja:AddHelpLine("price", "number", "Item vendor price")
		Ninja:AddHelpLine("name/link", "string", "Item name/link")
		Ninja:AddHelpLine("type/subtype", "string", "Item type (armor, weapon)/subtype (cloth, sword)")
		Ninja:AddHelpLine("equiploc", "string", "Item equip location")
		Ninja:AddHelpLine("texture", "string", "Item texture")
		Ninja:AddHelpLine("poor/common/uncommon/rare/epic/legendary/artifact/heirloom", "boolean", "Quality")
		Ninja:AddHelpLine("isweapon/isarmor", "boolean", "Whether item is weapon/armor")
		Ninja:AddHelpLine("exists", "boolean", "Whether item exists (\"r.exists\" is probably always true)")
		Ninja:AddHelpLine()
		Ninja:AddHelpLine("Attributes:", "bbbbbb")
		Ninja:AddHelpLine("agi/int/spi/sta/str", "number", "Base attributes")
		Ninja:AddHelpLine("armor/health/mana", "number", "Armor/Health/Mana")
		Ninja:AddHelpLine("sdmg/sheal/spen", "number", "Spell damage/healing/penetration")
		Ninja:AddHelpLine("dps/ap/fap", "number", "Damage per second/Attack Power/Feral attack power")
		Ninja:AddHelpLine("crit/exp/haste/hit/mastery/dodge/parry/res", "number", "Ratings")
		Ninja:AddHelpLine("holy/fire/nature/frost/shadow/arcane", "number", "Resistances")
		Ninja:AddHelpLine("meta/prismatic/blue/red/yellow", "number", "Sockets")
		Ninja:AddHelpLine()
		Ninja:AddHelpLine("Only available for roll item (r.<key>):", "bbbbbb")
		Ninja:AddHelpLine("count", "number", "Item count (probably always 1)")
		Ninja:AddHelpLine("bop", "boolean", "Whether item binds on pickup")
		Ninja:AddHelpLine("need/greed/disenchant", "boolean", "Whether you can need/greed/disenchant item")
	elseif event == "START_LOOT_ROLL" then
		Ninja:Roll(arg1)
	elseif event == "CANCEL_LOOT_ROLL" then
		-- hide roll frame
		for frameid = 1, NUM_GROUP_LOOT_FRAMES do
			local frame = getglobal("GroupLootFrame" .. frameid)
			if tonumber(frame.rollID) == tonumber(arg1) then
				frame:Hide()
				break
			end
		end
	elseif (event == "CONFIRM_LOOT_ROLL" or event == "CONFIRM_DISENCHANT_ROLL") and ninja_db.enabled then
		-- we'll need to confirm need/greed/disenchant rolls on bop items
		ConfirmLootRoll(arg1, arg2)
		-- also hide the confirmation window. not sure if "arg1" (roll id) is needed, but it's used in GroupLootFrame_OnEvent() (LootFrame.lua)
		StaticPopup_Hide("CONFIRM_LOOT_ROLL", arg1)
	end
end

function Ninja:AddHelpLine(text, color, description)
	local add = ""
	if text then
		if not color then
			add = add .. "|cffffffff"
		elseif color == "number" then
			add = add .. "|cffffff00"
		elseif color == "string" then
			add = add .. "|cff0055ff"
		elseif color == "boolean" then
			add = add .. "|cff00ff00"
		else
			add = add .. "|cff" .. color
		end
		add = add .. text .. "|r"
		if description then
			add = add .. " - " .. description
		end
	end
	NinjaCodeHelpFrameText:SetText((NinjaCodeHelpFrameText:GetText() or "") .. add .. "\n")
end

function Ninja:OnUpdate(elapsed)
	local empty = 1
	for rollidandtype, time in pairs(Ninja.rolls) do
		local timeleft = time - elapsed
		if timeleft <= 0 then
			-- time's up, roll the dice
			local _, _, rollid, rolltype = string.find(rollidandtype, "(%d+):(%d+)")
			RollOnLoot(rollid, rolltype)
			Ninja.rolled[rollid] = 1
			Ninja.rolls[rollidandtype] = nil
		else
			empty = nil
			Ninja.rolls[rollidandtype] = timeleft
		end
	end
	if empty then
		Ninja:SetScript("OnUpdate", nil)
	end
end

function Ninja:SaveSettings()
	-- called when player clicks "Okay" in addon options frame
	ninja_db.enabled = NinjaEnabledCheckButton:GetChecked()
	ninja_db.rolldelay = NinjaRollWaitTimeSlider:GetValue()
	ninja_db.betweendelay = NinjaDelayBetweenRollSlider:GetValue()

	-- roll code
	ninja_db.codes[0] = NinjaConfigPassCodeFrameCode:GetText()
	ninja_db.codes[1] = NinjaConfigNeedCodeFrameCode:GetText()
	ninja_db.codes[2] = NinjaConfigGreedCodeFrameCode:GetText()
	ninja_db.codes[3] = NinjaConfigDisenchantCodeFrameCode:GetText()
	ninja_db.codes[4] = NinjaConfigManualCodeFrameCode:GetText()

	-- test roll codes
	local r = Ninja:GetItemData()
	r.need = 1
	r.greed = 1
	r.disenchant = 1
	r.count = 1
	r.bop = 1
	local c = Ninja:GetItemData()
	Ninja:Compare(r, c, 1)
end

function Ninja:LoadSettings()
	-- called on addon load and when player clicks "Cancel" in addon options frame
	NinjaEnabledCheckButton:SetChecked(ninja_db.enabled)
	NinjaRollWaitTimeSlider:SetValue(ninja_db.rolldelay)
	NinjaDelayBetweenRollSlider:SetValue(ninja_db.betweendelay)

	-- roll code
	NinjaConfigPassCodeFrameCode:SetText(ninja_db.codes[0] or "")
	NinjaConfigNeedCodeFrameCode:SetText(ninja_db.codes[1] or "")
	NinjaConfigGreedCodeFrameCode:SetText(ninja_db.codes[2] or "")
	NinjaConfigDisenchantCodeFrameCode:SetText(ninja_db.codes[3] or "")
	NinjaConfigManualCodeFrameCode:SetText(ninja_db.codes[4] or "")
end

function Ninja:Roll(rollid)
	if not rollid or not ninja_db.enabled then
		return
	end
	-- fetch roll item info
	local itemlink = GetLootRollItemLink(rollid)
	if not itemlink then
		return
	end
	local r = Ninja:GetItemData(itemlink)
	_, _, r.count, _, r.bop, r.need, r.greed, r.disenchant = GetLootRollItemInfo(rollid)
	r.count = tonumber(r.count) or -1

	local roll, c
	if Ninja.equiplocmap[r.equiploc] then
		-- equipable item, compare with existing item(s)
		for equiploc, slot in pairs(Ninja.equiplocmap[r.equiploc]) do
			c = Ninja:GetItemData(GetInventoryItemLink("player", slot))
			local tmproll = Ninja:Compare(r, c)
			if tmproll then
				if not roll then
					roll = tmproll
				elseif tmproll ~= roll then
					for index, priorityroll in pairs(Ninja.rollorder) do
						if roll == priorityroll then
							break
						elseif tmproll == priorityroll then
							roll = tmproll
							break
						end
					end
				end
			end
		end
	else
		-- item not equipable, compare with "empty" item
		c = Ninja:GetItemData()
		roll = Ninja:Compare(r, c)
	end
	if roll and roll >= 0 and roll <= 3 then
		Ninja:SetScript("OnUpdate", Ninja.OnUpdate)
		local waittime = ninja_db.rolldelay
		-- circumvent bug with rolling on two BoP/disenchant items at the same time
		for rollidandtype, time in pairs(Ninja.rolls) do
			if waittime - ninja_db.betweendelay < time then
				waittime = time + ninja_db.betweendelay
			end
		end
		-- prettyfication for output later
		waittime = math.floor(waittime * 10 + 0.5) / 10
		Ninja.rolls[rollid .. ":" .. roll] = waittime
		local msg
		if roll == 0 then
			msg = "|cffcb0000Passing|r "
		elseif roll == 1 then
			msg = "Rolling |cff12b7c6Need|r on "
		elseif roll == 2 then
			msg = "Rolling |cff939802Greed|r on "
		elseif roll == 3 then
			msg = "|cfff811daDisenchanting|r "
		end
		msg = msg .. itemlink .. " in " .. waittime .. "s" .. " |Hninja:" .. rollid .. ":" .. roll .. "|h|cffff0000[Cancel]|r|h"
		print(msg)
		-- hide roll frame
		for frameid = 1, NUM_GROUP_LOOT_FRAMES do
			local frame = getglobal("GroupLootFrame" .. frameid)
			if frame.rollID == rollid then
				frame:Hide()
				break
			end
		end
	end
	wipe(r)
	wipe(c)
end

function Ninja:Compare(rollitem, currentitem, test)
	for index, roll in pairs(Ninja.rollorder) do
		if (roll ~= 1 or rollitem.need) and (roll ~= 2 or rollitem.greed) and (roll ~= 3 or rollitem.disenchant) then
			local text = strtrim(ninja_db.codes[roll] or "")
			if text ~= "" then
				local lines = {strsplit("\n", text)}
				for index, line in pairs(lines) do
					line = strtrim(line or "")
					if line ~= "" then
						local func, errormessage = loadstring("return function(r, c) return " .. line .. "; end")
						if not func then
							local rolltype
							if roll == 0 then
								rolltype = "Pass"
							elseif roll == 1 then
								rolltype = "Need"
							elseif roll == 2 then
								rolltype = "Greed"
							elseif roll == 3 then
								rolltype = "Disenchant"
							else
								rolltype = "Manual"
							end
							_, _, errormessage = string.find(errormessage, ".*:1:(.*)$")
							print("Invalid code: <" .. rolltype .. "> line " .. index .. ": \"" .. line .. "\" -", strtrim(errormessage))
						elseif func()(rollitem, currentitem) then
							if not test then
								wipe(lines)
								return roll
							end
						end
					end
				end
				if lines then
					wipe(lines)
				end
			end
		end
	end
end

function Ninja:GetItemData(link)
	local itemid, name, itemlink, rarity, level, equiplevel, itemtype, subtype, stackcount, equiploc, texture, price
	if link then
		_, _, itemid = string.find(link, "item:(%d+):")
		name, itemlink, rarity, level, equiplevel, itemtype, subtype, stackcount, equiploc, texture, price = GetItemInfo(link)
	end
	local i = {}
	if itemlink then
		i.exists = 1
	end
	i.link = itemlink or ""
	i.id = tonumber(itemid) or -1
	i.name = name or ""
	i.rarity = tonumber(rarity) or -1
	i.level = tonumber(level) or -1
	i.equiplevel = tonumber(equiplevel) or -1
	i.type = itemtype or ""
	i.subtype = subtype or ""
	i.stack = tonumber(stackcount) or -1
	i.equiploc = equiploc or ""
	i.texture = texture or ""
	i.price = tonumber(price) or 0

	i.poor = i.rarity == 0
	i.common = i.rarity == 1
	i.uncommon = i.rarity == 2
	i.rare = i.rarity == 3
	i.epic = i.rarity == 4
	i.legendary = i.rarity == 5
	i.artifact = i.rarity == 6
	i.heirloom = i.rarity == 7
	i.isweapon = Ninja.equiplocmap[i.equiploc] and Ninja.equiplocmap[i.equiploc][1] >= 16 and Ninja.equiplocmap[i.equiploc][1] <= 18
	i.isarmor = Ninja.equiplocmap[i.equiploc] and not i.weapon

	local stats
	if link then
		stats = GetItemStats(link)
	else
		stats = {}
	end
	i.agi = tonumber(stats[ITEM_MOD_AGILITY_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT]) or 0
	i.ap = tonumber(stats[ITEM_MOD_ATTACK_POWER_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_BLOCK_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_BLOCK_VALUE_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_CRIT_MELEE_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_CRIT_RANGED_RATING_SHORT]) or 0
	i.crit = tonumber(stats[ITEM_MOD_CRIT_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_CRIT_SPELL_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_CRIT_TAKEN_MELEE_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_CRIT_TAKEN_RANGED_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_CRIT_TAKEN_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_CRIT_TAKEN_SPELL_RATING_SHORT]) or 0
	i.dps = tonumber(stats[ITEM_MOD_DAMAGE_PER_SECOND_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_DEFENSE_SKILL_RATING_SHORT]) or 0
	i.dodge = tonumber(stats[ITEM_MOD_DODGE_RATING_SHORT]) or 0
	i.exp = tonumber(stats[ITEM_MOD_EXPERTISE_RATING_SHORT]) or 0
	i.fap = tonumber(stats[ITEM_MOD_FERAL_ATTACK_POWER_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_HASTE_MELEE_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_HASTE_RANGED_RATING_SHORT]) or 0
	i.haste = tonumber(stats[ITEM_MOD_HASTE_RATING_SHORT]) or 0
	--i.= tonumber(stats[ITEM_MOD_HASTE_SPELL_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_HEALTH_REGENERATION_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_HEALTH_REGEN_SHORT]) or 0
	i.health = tonumber(stats[ITEM_MOD_HEALTH_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_HIT_MELEE_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_HIT_RANGED_RATING_SHORT]) or 0
	i.hit = tonumber(stats[ITEM_MOD_HIT_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_HIT_SPELL_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_HIT_TAKEN_MELEE_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_HIT_TAKEN_RANGED_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_HIT_TAKEN_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_HIT_TAKEN_SPELL_RATING_SHORT]) or 0
	i.int = tonumber(stats[ITEM_MOD_INTELLECT_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_MANA_REGENERATION_SHORT]) or 0
	i.mana = tonumber(stats[ITEM_MOD_MANA_SHORT]) or 0
	i.mastery = tonumber(stats[ITEM_MOD_MASTERY_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_MELEE_ATTACK_POWER_SHORT]) or 0
	i.parry = tonumber(stats[ITEM_MOD_PARRY_RATING_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_POWER_REGEN0_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_POWER_REGEN1_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_POWER_REGEN2_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_POWER_REGEN3_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_POWER_REGEN4_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_POWER_REGEN5_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_POWER_REGEN6_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_RANGED_ATTACK_POWER_SHORT]) or 0
	i.res = tonumber(stats[ITEM_MOD_RESILIENCE_RATING_SHORT]) or 0
	i.sdmg = tonumber(stats[ITEM_MOD_SPELL_DAMAGE_DONE_SHORT]) or 0
	i.sheal = tonumber(stats[ITEM_MOD_SPELL_HEALING_DONE_SHORT]) or 0
	i.spen = tonumber(stats[ITEM_MOD_SPELL_PENETRATION_SHORT]) or 0
	--i. = tonumber(stats[ITEM_MOD_SPELL_POWER_SHORT]) or 0
	i.spi = tonumber(stats[ITEM_MOD_SPIRIT_SHORT]) or 0
	i.sta = tonumber(stats[ITEM_MOD_STAMINA_SHORT]) or 0
	i.str = tonumber(stats[ITEM_MOD_STRENGTH_SHORT]) or 0

	i.armor = tonumber(stats[RESISTANCE0_NAME]) or 0
	i.holy = tonumber(stats[RESISTANCE1_NAME]) or 0
	i.fire = tonumber(stats[RESISTANCE2_NAME]) or 0
	i.nature = tonumber(stats[RESISTANCE3_NAME]) or 0
	i.frost = tonumber(stats[RESISTANCE4_NAME]) or 0
	i.shadow = tonumber(stats[RESISTANCE5_NAME]) or 0
	i.arcane = tonumber(stats[RESISTANCE6_NAME]) or 0

	i.blue = tonumber(stats[EMPTY_SOCKET_BLUE]) or 0
	i.meta = tonumber(stats[EMPTY_SOCKET_META]) or 0
	i.prismatic = tonumber(stats[EMPTY_SOCKET_NO_COLOR]) or 0
	i.red = tonumber(stats[EMPTY_SOCKET_RED]) or 0
	i.yellow = tonumber(stats[EMPTY_SOCKET_YELLOW]) or 0

	wipe(stats)
	return i
end

-- couldn't find a more sane mapping for this than to do it manually :(
Ninja.equiplocmap = {
	["INVTYPE_AMMO"] = {0},
	["INVTYPE_HEAD"] = {1},
	["INVTYPE_NECK"] = {2},
	["INVTYPE_SHOULDER"] = {3},
	["INVTYPE_BODY"] = {4},
	["INVTYPE_CHEST"] = {5},
	["INVTYPE_ROBE"] = {5},
	["INVTYPE_WAIST"] = {6},
	["INVTYPE_LEGS"] = {7},
	["INVTYPE_FEET"] = {8},
	["INVTYPE_WRIST"] = {9},
	["INVTYPE_HAND"] = {10},
	["INVTYPE_FINGER"] = {11, 12},
	["INVTYPE_TRINKET"] = {13, 14},
	["INVTYPE_CLOAK"] = {15},
	["INVTYPE_WEAPON"] = {16, 17},
	["INVTYPE_SHIELD"] = {17},
	["INVTYPE_2HWEAPON"] = {16},
	["INVTYPE_WEAPONMAINHAND"] = {16},
	["INVTYPE_WEAPONOFFHAND"] = {17},
	["INVTYPE_HOLDABLE"] = {17},
	["INVTYPE_RANGED"] = {18},
	["INVTYPE_THROWN"] = {18},
	["INVTYPE_RANGEDRIGHT"] = {18},
	["INVTYPE_RELIC"] = {18},
	["INVTYPE_TABARD"] = {19}
}
Ninja.rolls = {}
Ninja.rolled = {}

-- 0: pass
-- 1: need
-- 2: greed
-- 3: disenchant
-- 4: don't roll (special value only used in Ninja)
Ninja.rollorder = {4, 1, 2, 3, 0}

Ninja:SetScript("OnEvent", Ninja.OnEvent)
Ninja:RegisterEvent("ADDON_LOADED")
Ninja:RegisterEvent("START_LOOT_ROLL")
Ninja:RegisterEvent("CANCEL_LOOT_ROLL")
Ninja:RegisterEvent("CONFIRM_LOOT_ROLL")
Ninja:RegisterEvent("CONFIRM_DISENCHANT_ROLL")
