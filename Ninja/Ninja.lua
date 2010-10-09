Ninja = CreateFrame("Frame")

function Ninja:OnEvent()
	if event == "ADDON_LOADED" then
		if not ninja_db then
			ninja_db = {}
		end
		if not ninja_db.rolls then
			ninja_db.rolls = {}
		end
		if not ninja_db.rollorder then
			-- 0: pass
			-- 1: need
			-- 2: greed
			-- 3: disenchant
			-- 4: don't roll (special value only used in Ninja)
			ninja_db.rollorder = {4, 1, 2, 3, 0}
		end
	end
end

function Ninja:Roll(rollid)
	if not rollid then
		return
	end
	-- fetch roll item info
	local itemlink = GetLootRollItemLink(rollid)
	local r = Ninja:GetItemData(itemlink)
	_, _, r.count, _, r.bop, r.need, r.greed, r.dis = GetLootRollItemInfoedit(rollid)
	r.count = tonumber(r.count) or -1

	local roll, c
	if Ninja.equiplocmap[r.equiploc] then
		-- equipable item, compare with existing item(s)
		for equiploc, slot in pairs(Ninja.equiplocmap[r.equiploc]) do
			c = Ninja:GetItemData(GetInventoryItemLink("player", slot))
		end
	else
		-- item not equipable, compare with "empty" item
		c = Ninja:GetItemData()
	end
	if roll then
		RollOnLoot(rollid, roll)
	end
	wipe(r)
	wipe(c)
end

function Ninja:Compare(rollItem, currentItem)
	for index, roll in pairs(ninja_db.rollorder) do
		local text = ninja_db.rolls[roll]
		if text and strtrim(text) ~= "" then
			local lines = {strsplit(text, "\n")}
			for index, line in pairs(lines) do
				local func = assert(loadstring([[
				return function(r, c)
					return ]] .. line .. [[
				end
				]]))
				if func()(r, c) then
					wipe(lines)
					return roll
				end
			end
		end
		wipe(lines)
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
	i.weapon = Ninja.equiplocmap[i.equiploc] and Ninja.equiplocmap[i.equiploc] >= 16 and Ninja.equiplocmap[i.equiploc] <= 18
	i.armor = Ninja.equiplocmap[i.equiploc] and not i.weapon

	local stats
	if link then
		stats = GetItemStats(link)
	else
		stats = {}
	end
	i.agility = tonumber(stats[ITEM_MOD_AGILITY_SHORT]) or 0
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
	i.defence = tonumber(stats[ITEM_MOD_DEFENSE_SKILL_RATING_SHORT]) or 0
	i.dodge = tonumber(stats[ITEM_MOD_DODGE_RATING_SHORT]) or 0
	i.expertise = tonumber(stats[ITEM_MOD_EXPERTISE_RATING_SHORT]) or 0
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
	i.intellect = tonumber(stats[ITEM_MOD_INTELLECT_SHORT]) or 0
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
	i.resilience = tonumber(stats[ITEM_MOD_RESILIENCE_RATING_SHORT]) or 0
	i.spelldamage = tonumber(stats[ITEM_MOD_SPELL_DAMAGE_DONE_SHORT]) or 0
	i.spellhealing = tonumber(stats[ITEM_MOD_SPELL_HEALING_DONE_SHORT]) or 0
	i.spellpenetration = tonumber(stats[ITEM_MOD_SPELL_PENETRATION_SHORT]) or 0
	i.spellpower = tonumber(stats[ITEM_MOD_SPELL_POWER_SHORT]) or 0
	i.spirit = tonumber(stats[ITEM_MOD_SPIRIT_SHORT]) or 0
	i.stamina = tonumber(stats[ITEM_MOD_STAMINA_SHORT]) or 0
	i.strength = tonumber(stats[ITEM_MOD_STRENGTH_SHORT]) or 0

	wipe(stats)
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

Ninja:SetScript("OnEvent", Ninja.OnEvent)
Ninja:RegisterEvent("ADDON_LOADED")
