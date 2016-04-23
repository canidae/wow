if (GetLocale() ~= "deDE") then
	return;
end

-- classes
C_Druid = "Druide";
C_Hunter = "J\195\164ger";
C_Mage = "Magier";
C_Paladin = "Paladin";
C_Priest = "Priester";
C_Rogue = "Schurke";
C_Shaman = "Schamane";
C_Warlock = "Hexenmeister";
C_Warrior = "Krieger";

-- factions
C_Alliance = "Allianz";
C_Horde = "Horde";

-- spells/buffs/debuffs
C_Amplify_magic = "Magie verst\195\164rken";
C_Banish = "Verbannen";
C_Blessing_of_light = "Segen des Lichts";
C_Blessing_of_protection = "Segen des Schutzes";
C_Chain_heal = "Kettenheilung";
C_Clearcasting = "Freizauber";
C_Crystal_restore = "Cristal de restauration";
C_Dampen_magic = "Magie d\195\164mpfen";
C_Deep_slumber = "Sommeil profond";
C_Divine_favor = "G\195\182ttliche Gunst";
C_Divine_intervention = "G\195\182ttliche Einmischung";
C_Divine_protection = "G\195\182ttlicher Schutz";
C_Divine_shield = "G\195\182ttlicher Schild";
C_First_aid = "Erste Hilfe";
C_Flash_heal = "Blitzheilung";
C_Flash_of_light = "Lichtblitz";
C_Forbearance = "Vorhersehung";
C_Greater_blessing_of_light = "Gro\195\159er Segen des Lichts";
C_Greater_heal = "Gro\195\159e Heilung";
C_Heal = "Heilen";
C_Healing_touch = "Heilende Ber\195\188hrung";
C_Healing_wave = "Welle der Heilung";
C_Holy_light = "Heiliges Licht";
C_Holy_nova = "Heilige Nova";
C_Holy_shock = "Heiliger Schock";
C_Ice_barrier = "Eis-Barriere";
C_Inner_focus = "Innerer Fokus";
C_Lay_on_hands = "Handauflegung";
C_Lesser_heal = "Geringes Heilen";
C_Lesser_healing_wave = "Geringe Welle der Heilung";
C_Lightwell = "Brunnen des Lichts";
C_Mortal_strike = "T\195\182dlicher Sto\195\159";
C_Natures_grace = "Anmut der Natur";
C_Natures_swiftness = "Schnelligkeit der Natur";
C_Phase_shift = "Phasenverschiebung";
C_Power_infusion = "Power Infusion";
C_Power_word_shield = "Machtwort: Schild";
C_Prayer_of_healing = "Gebet der Heilung";
C_Recently_bandaged = "K\195\188rzlich bandagiert";
C_Regrowth = "Nachwachsen";
C_Rejuvenation = "Verj\195\188ngung";
C_Renew = "Erneuerung";
C_Spirit_tap = "Willensentzug";
C_Swiftmend = "Rasche Heilung";
C_Tranquility = "Gelassenheit";
C_Unstable_power = "Instabile Macht";
C_Weakened_soul = "Geschw\195\164chte Seele";


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
	"Erh\195\182ht durch Zauber und Effekte verursachte Heilung um bis zu (%d+%.?%d*)%.",
	"Erh\195\182ht durch Zauber und magische Effekte zugef\195\188gten Schaden und Heilung um bis zu (%d+%.?%d*)%.",
	"%+(%d+%.?%d*) Heilzauber",
	"Heilzauber %+(%d+%.?%d*)"
};

Genesis_set_bonus_active_text = "Set:";
Genesis_set_bonus_inactive_text = "%(%d%) Set:";
