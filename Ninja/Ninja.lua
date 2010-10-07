Ninja = CreateFrame("Frame")

function Ninja:Roll(rollId)
	if not rollId then
		return
	end
	-- fetch roll item info
	local itemlink = GetLootRollItemLink(rollId)
	local r = Ninja:GetItemData(itemlink)
	_, _, r.count, _, r.bop, r.need, r.greed, r.dis = GetLootRollItemInfoedit(rollId)
	r.count = tonumber(r.count) or -1
end

function Ninja:GetItemData(link)
	local i = {}
	local _, _, itemid = string.find(link, "item:(%d+):")
	local name, _, rarity, level, equiplevel, itemtype, subtype, stackcount, equiploc, texture, price = GetItemInfo(link)
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

	local stats = GetItemStats(link)
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
end
