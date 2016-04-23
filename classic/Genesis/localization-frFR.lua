if (GetLocale() ~= "frFR") then
	return;
end

-- classes
C_Druid = "Druide";
C_Hunter = "Chasseur";
C_Mage = "Mage";
C_Paladin = "Paladin";
C_Priest = "Pr\195\170tre";
C_Rogue = "Voleur";
C_Shaman = "Chaman";
C_Warlock = "D\195\169moniste";
C_Warrior = "Guerrier";

-- factions
C_Alliance = "Alliance";
C_Horde = "Horde";

-- spells/buffs/debuffs
C_Amplify_magic = "Amplification de la magie";
C_Banish = "Bannir";
C_Blessing_of_light = "B\195\169n\195\169diction de lumi\195\168re";
C_Blessing_of_protection = "B\195\169n\195\169diction de protection";
C_Chain_heal = "Salve de gu\195\169rison";
C_Clearcasting = "Id\195\169es claires";
C_Crystal_restore = "Cristal de restauration";
C_Dampen_magic = "Att\195\169nuer la magie";
C_Deep_slumber = "Sommeil profond";
C_Divine_favor = "Faveur divine";
C_Divine_intervention = "Intervention divine";
C_Divine_protection = "Protection divine";
C_Divine_shield = "Bouclier divin";
C_First_aid = "Premiers soins";
C_Flash_heal = "Soins rapides";
C_Flash_of_light = "Eclair lumineux";
C_Forbearance = "Longanimit\195\169";
C_Greater_blessing_of_light = "B\195\169n\195\169diction de lumi\195\168re sup\195\169rieure";
C_Greater_heal = "Soins sup\195\169rieurs";
C_Heal = "Soins";
C_Healing_touch = "Toucher gu\195\169risseur";
C_Healing_wave = "Vague de soins";
C_Holy_light = "Lumi\195\168re sacr\195\169e";
C_Holy_nova = "Nova sacr\195\169e";
C_Holy_shock = "Horion sacr\195\169";
C_Ice_barrier = "Barri\195\168re de glace";
C_Inner_focus = "Concentration am\195\169lior\195\169e";
C_Lay_on_hands = "Imposition des mains";
C_Lesser_heal = "Soins inf\195\169rieurs";
C_Lesser_healing_wave = "Vague de soins mineurs";
C_Lightwell = "Puits de lumi\195\168re";
C_Mortal_strike = "Frappe mortelle";
C_Natures_grace = "Gr\195\162ce de la nature";
C_Natures_swiftness = "Rapidit\195\169 de la nature";
C_Phase_shift = "Changement de phase";
C_Power_infusion = "Infusion de puissance";
C_Power_word_shield = "Mot de pouvoir : Bouclier";
C_Prayer_of_healing = "Pri\195\168re de soins";
C_Recently_bandaged = "Un bandage a \195\169t\195\169 appliqu\195\169 r\195\169cemment";
C_Regrowth = "R\195\169tablissement";
C_Rejuvenation = "R\195\169cup\195\169ration";
C_Renew = "R\195\169novation";
C_Swiftmend = "Prompte gu\195\169rison";
C_Spirit_tap = "Connexion Spirituelle";
C_Tranquility = "Tranquillit\195\169";
C_Unstable_power = "Puissance instable";
C_Weakened_soul = "Ame affaiblie";


Genesis_blessing_of_light_text = {C_Holy_light, C_Flash_of_light};

Genesis_buff_affect_healing_text = {
	[C_Amplify_magic] = {"DamageUp", "HealUp"},
	[C_Dampen_magic] = {"DamageDown", "HealDown"}
};

Genesis_my_buff_affect_healing_text = {
	[C_Unstable_power] = {"DamageUp", "HealUp"}
};

Genesis_debuff_affect_healing_text = {
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
	"Augmente les soins prodigu\195\169s par les sorts et effets de (%d+%.?%d*)",
	"Augmente les d\195\169g\195\162ts et les soins produits par les sorts et effets magiques de (%d+%.?%d*)",
	"%+(%d+%.?%d*) aux sorts de soins",
	"Sorts de soins %+(%d+%.?%d*)",
	"Sorts de soin %+(%d+%.?%d*)",
	"Augmente les soins de %+(%d+%.?%d*)",
	"%+(%d+%.?%d*) aux d\195\169g\195\162ts des sorts et aux soins"
};

Genesis_set_bonus_active_text = "Set:";
Genesis_set_bonus_inactive_text = "%(%d%) Set:";
