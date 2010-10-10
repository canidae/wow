Ninja = CreateFrame("Frame")

SLASH_Ninja1 = "/ninja"
function SlashCmdList.Ninja(msg)
	msg = strtrim(msg or "")
	if msg == "" then
		InterfaceOptionsFrame_OpenToCategory("Ninja")
	elseif msg == "on" then
		ninja_db.enabled = 1
	elseif msg == "off" then
		ninja_db.enabled = nil
	end
end

function Ninja:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "Ninja" then
		if not ninja_db then
			ninja_db = {}
		end
		if not ninja_db.codes then
			ninja_db.codes = {}
		end
		if not ninja_db.rollorder then
			-- 0: pass
			-- 1: need
			-- 2: greed
			-- 3: disenchant
			-- 4: don't roll (special value only used in Ninja)
			ninja_db.rollorder = {4, 1, 2, 3, 0}
		end
		if not ninja_db.rollwaittime then
			ninja_db.rollwaittime = 15
		end

		-- hook functions
		Ninja.ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
		ChatFrame_OnHyperlinkShow = function(...)
			local chatFrame, link, text, button = ...
			local _, _, rollidandtype = string.find(link, "^ninja:(%d+:%d+)$")
			if rollidandtype then
				local _, _, rollid, rolltype = string.find(rollidandtype, "(%d+):(%d+)")
				-- make sure we're not already showing it
				local isshown
				for frameid = 1, NUM_GROUP_LOOT_FRAMES do
					local frame = getglobal("GroupLootFrame" .. frameid)
					if frame:IsShown() and tonumber(frame.rollID) == tonumber(rollid) then
						isshown = 1
						break
					end
				end
				if not isshown then
					GroupLootFrame_OpenNewFrame(rollid, GetLootRollTimeLeft(rollid))
				end
				Ninja.rolls[rollidandtype] = nil
			else
				Ninja.ChatFrame_OnHyperlinkShow(...)
			end
		end

		-- load settings
		Ninja:LoadSettings()
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
	elseif event == "CONFIRM_LOOT_ROLL" or event == "CONFIRM_DISENCHANT_ROLL" then
		-- we'll need to confirm need/greed/disenchant rolls on bop items
		ConfirmLootRoll(arg1, arg2)
	end
end

function Ninja:OnUpdate(elapsed)
	local empty = 1
	for rollidandtype, time in pairs(Ninja.rolls) do
		local timeleft = time - elapsed
		if timeleft <= 0 then
			-- time's up, roll the dice
			local _, _, rollid, rolltype = string.find(rollidandtype, "(%d+):(%d+)")
			RollOnLoot(rollid, rolltype)
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
	ninja_db.rollwaittime = NinjaRollWaitTimeSlider:GetValue()

	-- roll code
	ninja_db.codes[0] = NinjaConfigPassCodeFrameCode:GetText()
	ninja_db.codes[1] = NinjaConfigNeedCodeFrameCode:GetText()
	ninja_db.codes[2] = NinjaConfigGreedCodeFrameCode:GetText()
	ninja_db.codes[3] = NinjaConfigDisenchantCodeFrameCode:GetText()
	ninja_db.codes[4] = NinjaConfigNoneCodeFrameCode:GetText()
end

function Ninja:LoadSettings()
	-- called on addon load and when player clicks "Cancel" in addon options frame
	NinjaEnabledCheckButton:SetChecked(ninja_db.enabled)
	NinjaRollWaitTimeSlider:SetValue(ninja_db.rollwaittime)

	-- roll code
	NinjaConfigPassCodeFrameCode:SetText(ninja_db.codes[0])
	NinjaConfigNeedCodeFrameCode:SetText(ninja_db.codes[1])
	NinjaConfigGreedCodeFrameCode:SetText(ninja_db.codes[2])
	NinjaConfigDisenchantCodeFrameCode:SetText(ninja_db.codes[3])
	NinjaConfigNoneCodeFrameCode:SetText(ninja_db.codes[4])
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
					for index, priorityroll in pairs(ninja_db.rollorder) do
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
		Ninja.rolls[rollid .. ":" .. roll] = ninja_db.rollwaittime
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
		msg = msg .. itemlink .. " in " .. ninja_db.rollwaittime .. "s" .. " |Hninja:" .. rollid .. ":" .. roll .. "|h|cffff0000[Cancel]|r|h"
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

function Ninja:Compare(rollitem, currentitem)
	for index, roll in pairs(ninja_db.rollorder) do
		if (roll ~= 1 or rollitem.need) and (roll ~= 2 or rollitem.greed) and (roll ~= 3 or rollitem.disenchant) then
			local text = strtrim(ninja_db.codes[roll] or "")
			if text ~= "" then
				local lines = {strsplit("\n", text)}
				for index, line in pairs(lines) do
					line = strtrim(line or "")
					if line ~= "" then
						local func = assert(loadstring([[
						return function(r, c)
							return ]] .. line .. [[
						end
						]]))
						if func()(rollitem, currentitem) then
							wipe(lines)
							return roll
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
	i.price = tonumber(price) or -1

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
	i.arp = tonumber(stats[ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT]) or 0
	i.ap = tonumber(stats[ITEM_MOD_ATTACK_POWER_SHORT]) or 0
	i.br = tonumber(stats[ITEM_MOD_BLOCK_RATING_SHORT]) or 0
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
	i.def = tonumber(stats[ITEM_MOD_DEFENSE_SKILL_RATING_SHORT]) or 0
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
	i.spow = tonumber(stats[ITEM_MOD_SPELL_POWER_SHORT]) or 0
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

Ninja:SetScript("OnEvent", Ninja.OnEvent)
Ninja:RegisterEvent("ADDON_LOADED")
Ninja:RegisterEvent("START_LOOT_ROLL")
Ninja:RegisterEvent("CANCEL_LOOT_ROLL")
Ninja:RegisterEvent("CONFIRM_LOOT_ROLL")
Ninja:RegisterEvent("CONFIRM_DISENCHANT_ROLL")
