-- classes
C_Druid = "Druid";
C_Hunter = "Hunter";
C_Mage = "Mage";
C_Paladin = "Paladin";
C_Priest = "Priest";
C_Rogue = "Rogue";
C_Shaman = "Shaman";
C_Warlock = "Warlock";
C_Warrior = "Warrior";

-- factions
C_Alliance = "Alliance";
C_Horde = "Horde";

-- spells/buffs/debuffs
C_Amplify_magic = "Amplify Magic";
C_Banish = "Banish";
C_Blessing_of_light = "Blessing of Light";
C_Blessing_of_protection = "Blessing of Protection";
C_Chain_heal = "Chain Heal";
C_Clearcasting = "Clearcasting";
C_Crystal_restore = "Crystal Restore";
C_Dampen_magic = "Dampen Magic";
C_Deep_slumber = "Deep Slumber";
C_Divine_favor = "Divine Favor";
C_Divine_intervention = "Divine Intervention";
C_Divine_protection = "Divine Protection";
C_Divine_shield = "Divine Shield";
C_First_aid = "First Aid";
C_Flash_heal = "Flash Heal";
C_Flash_of_light = "Flash of Light";
C_Forbearance = "Forbearance";
C_Greater_blessing_of_light = "Greater Blessing of Light";
C_Greater_heal = "Greater Heal";
C_Heal = "Heal";
C_Healing_touch = "Healing Touch";
C_Healing_wave = "Healing Wave";
C_Holy_light = "Holy Light";
C_Holy_nova = "Holy Nova";
C_Holy_shock = "Holy Shock";
C_Ice_barrier = "Ice Barrier";
C_Inner_focus = "Inner Focus";
C_Lay_on_hands = "Lay on Hands";
C_Lesser_heal = "Lesser Heal";
C_Lesser_healing_wave = "Lesser Healing Wave";
C_Lightwell = "Lightwell";
C_Mortal_strike = "Mortal Strike";
C_Natures_grace = "Nature's Grace";
C_Natures_swiftness = "Nature's Swiftness";
C_Phase_shift = "Phase Shift";
C_Power_infusion = "Power Infusion";
C_Power_word_shield = "Power Word: Shield";
C_Prayer_of_healing = "Prayer of Healing";
C_Recently_bandaged = "Recently bandaged";
C_Regrowth = "Regrowth";
C_Rejuvenation = "Rejuvenation";
C_Renew = "Renew";
C_Spirit_tap = "Spirit Tap";
C_Swiftmend = "Swiftmend";
C_Tranquility = "Tranquility";
C_Unstable_power = "Unstable Power";
C_Weakened_soul = "Weakened Soul";


Genesis_blessing_of_light_text = {C_Holy_light, C_Flash_of_light};

Genesis_buff_affect_healing_text = {
	[C_Amplify_magic] = {"DamageUp", "HealUp"},
	[C_Dampen_magic] = {"DamageDown", "HealDown"}
};

Genesis_debuff_affect_healing_text = {
};

Genesis_my_buff_affect_healing_text = {
	[C_Unstable_power] = {"DamageUp", "HealUp"}
};

Genesis_heal_spells_text = {
	[C_Blessing_of_protection] = {"Duration", "Delay"},
	[C_Chain_heal] = {"HealMin", "HealMax", "EffectLoss", "Targets"},
	[C_Divine_protection] = {"Duration"},
	[C_Divine_shield] = {"Duration", "AttackSpeedLoss"},
	[C_Flash_heal] = {"HealMin", "HealMax"},
	[C_Flash_of_light] = {"HealMin", "HealMax"},
	[C_Greater_heal] = {"HealMin", "HealMax"},
	[C_Heal] = {"HealMin", "HealMax"},
	[C_Healing_touch] = {"HealMin", "HealMax"},
	[C_Healing_wave] = {"HealMin", "HealMax"},
	[C_Holy_light] = {"HealMin", "HealMax"},
	[C_Holy_nova] = {"DamageMin", "DamageMax", "DamageRange", "HealRange", "HealMin", "HealMax"},
	[C_Holy_shock] = {"DamageMin", "DamageMax", "HealMin", "HealMax"},
	[C_Lesser_heal] = {"HealMin", "HealMax"},
	[C_Lesser_healing_wave] = {"HealMin", "HealMax"},
	[C_Power_word_shield] = {"Absorb", "Duration", "Delay"},
	[C_Prayer_of_healing] = {"HealMin", "HealMax"},
	[C_Regrowth] = {"HealMin", "HealMax", "HealingOverTime", "Duration"},
	[C_Rejuvenation] = {"HealingOverTime", "Duration"},
	[C_Renew] = {"HealingOverTime", "Duration"},
	[C_Swiftmend] = {"RejuvenationTime", "RegrowthTime"},
	[C_Tranquility] = {"Heal", "Interval", "ChannelTime"}
};

Genesis_hot_text = {"Heal", "Interval"};

Genesis_item_heal_bonus_text = {
        "Increases healing done by spells and effects by up to (%d+%.?%d*)%.",
        "Increases damage and healing done by magical spells and effects by up to (%d+%.?%d*)%.",
	"%+(%d+%.?%d*) Healing Spells",
	"Healing Spells %+(%d+%.?%d*)"
};

Genesis_set_bonus_active_text = "Set:";
Genesis_set_bonus_inactive_text = "%(%d%) Set:";
