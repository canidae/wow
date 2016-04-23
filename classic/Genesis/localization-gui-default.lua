-- bindings
BINDING_HEADER_GENESIS = "Genesis";
BINDING_NAME_GENESIS_CUSTOM_1 = "Custom 1";
BINDING_NAME_GENESIS_CUSTOM_2 = "Custom 2";

-- title
Genesis_GUI_title = "Genesis 0.52";

-- tab titles
Genesis_GUI_tab_title = {"Classes", "Mouse/Keys", "Priorities", "Raid", "Settings"};

-- custom classes
Genesis_GUI_new = "New";
Genesis_GUI_delete = "Delete";
Genesis_GUI_percent = "Percent";
Genesis_GUI_rank = "Rank";
Genesis_GUI_new_class = "Name of new class";
Genesis_GUI_okay = "Okay";
Genesis_GUI_cancel = "Cancel";

-- keys thingy
Genesis_GUI_keys = {"Off", "None", "Alt", "Control", "Shift", "Alt + Control", "Alt + Shift", "Control + Shift"};
Genesis_GUI_heal_enough = "Heal enough";
Genesis_GUI_heal_self = "Heal self";
Genesis_GUI_heal_max = "Heal max";
Genesis_GUI_heal_targettarget = "Heal targettarget";

-- mousehealing
Genesis_GUI_left_button = "Left Button";
Genesis_GUI_right_button = "Right Button";
Genesis_GUI_middle_button = "Middle Button";
Genesis_GUI_custom_1 = "Custom 1";
Genesis_GUI_custom_2 = "Custom 2";

-- priorities
Genesis_GUI_player_priority = "Player priority";
Genesis_GUI_party_priority = "Party priority";
Genesis_GUI_raid_priority = "Raid priority";
Genesis_GUI_pet_priority = "Pet priority";
Genesis_GUI_bop_priority = "BoP pri. decrease";
Genesis_GUI_pws_priority = "PWS pri. decrease";
Genesis_GUI_rb_priority = "RB priority increase";
Genesis_GUI_ws_priority = "WS priority increase";
Genesis_GUI_druid_priority = "Druid priority";
Genesis_GUI_hunter_priority = "Hunter priority";
Genesis_GUI_mage_priority = "Mage priority";
Genesis_GUI_paladin_priority = "Paladin priority";
Genesis_GUI_priest_priority = "Priest priority";
Genesis_GUI_rogue_priority = "Rogue priority";
Genesis_GUI_shaman_priority = "Shaman priority";
Genesis_GUI_warlock_priority = "Warlock priority";
Genesis_GUI_warrior_priority = "Warrior priority";

-- raid
Genesis_GUI_check_all = "Check all";
Genesis_GUI_uncheck_all = "Uncheck all";
Genesis_GUI_invert_checked = "Invert checked";
Genesis_GUI_unchecked_priority = "Unchecked priority";

-- settings
Genesis_GUI_hook_useaction = "Hook UseAction";
Genesis_GUI_hook_shields = "Hook shields";
Genesis_GUI_useaction_wounded = "UseAction heal most wounded";
Genesis_GUI_show_all = "Show all healing";
Genesis_GUI_show_me = "Show only healing me";
Genesis_GUI_shapeshifted_druids = "Treat shapeshifted druids as rogues/warriors";
Genesis_GUI_safe_cancel = "Safe cancel";
Genesis_GUI_scale_spells = "Scale spells";
Genesis_GUI_hot_cancel = "HOT heal threshold";
Genesis_GUI_hot_value = "HOT value";
Genesis_GUI_hot_value_battle = "HOT value combat";
Genesis_GUI_max_overheal = "Max overheal";
Genesis_GUI_min_heal_threshold = "Min heal threshold";
Genesis_GUI_heal_power = "Heal power";
Genesis_GUI_update_time = "Max update time";
Genesis_GUI_heal_strategy = "Heal strategy";
Genesis_GUI_heal_strategies = {"Least HP", "Least % life", "Most HP missing"};

-- tooltip help
Genesis_GUI_help = {
	["Tab1"] = {
		["Title"] = "Classes",
		["Description"] = "Create your own classes of healing spells."
	},
	["Tab2"] = {
		["Title"] = "Mouse/Keys",
		["Description"] = "Associate a healing spell to a mousebutton, so you can simply click on a player frame to heal that person.\nConfigure how the addon will react when you press certain buttons (alt/ctrl/shift) while healing."
	},
	["Tab3"] = {
		["Title"] = "Priorities",
		["Description"] = "Change the way the addon prioritize the players."
	},
	["Tab4"] = {
		["Title"] = "Raid",
		["Description"] = "Here you can chose which players to heal when you're in a raid and are healing using the \"heal most wounded\" feature."
	},
	["Tab5"] = {
		["Title"] = "Settings",
		["Description"] = "More advanced settings how the addon should behave."
	},
	["Genesis_GUIClass"] = {
		["Title"] = "Classes",
		["Description"] = "Drag a healing spell from your spellbook here to add it to this class."
	},
	["ClassDropDownMenu"] = {
		["Title"] = "Select class",
		["Description"] = "Select a class in this list to configure it."
	},
	["NewClassButton"] = {
		["Title"] = "New class",
		["Description"] = "Click here to create a new class."
	},
	["DeleteClassButton"] = {
		["Title"] = "Delete class",
		["Description"] = "Click here to delete the currently selected class."
	},
	["Genesis_GUIClass%dRankSlider"] = {
		["Title"] = "Rank",
		["Description"] = "Select the highest rank you want to use of this spell."
	},
	["Genesis_GUIClass%dPercentSlider"] = {
		["Title"] = "Percent",
		["Description"] = "Select the highest percent a player may have for this spell to be used. If there's another spell in this class with a lower max percent value then that spell will be used if a player got less percent life left than that value."
	},
	["Genesis_GUIHealSelfModifier"] = {
		["Title"] = "Heal self modifier",
		["Description"] = "When you hold down the given key here and click on a healing spell then you will heal yourself. This setting can not be the same setting as \"Heal targettarget modifier\". This setting have no impact on \"mouse healing\"."
	},
	["Genesis_GUIHealEnoughModifier"] = {
		["Title"] = "Heal enough modifier",
		["Description"] = "If you hold down this key and use \"mouse healing\" and click on someone, then you will heal that person enough to restore the players missing hitpoints. This setting can not be the same setting as \"Heal max modifier\". Only \"mouse healing\" is affected by this setting."
	},
	["Genesis_GUIHealMaxModifier"] = {
		["Title"] = "Heal max modifier",
		["Description"] = "When this key is pressed and you use \"mouse healing\" on someone then Genesis will \"tank heal\" that player. This setting can not be the same setting as \"Heal enough modifier\". Only \"mouse healing\" is affected by this setting."
	},
	["Genesis_GUIHealTargettargetModifier"] = {
		["Title"] = "Heal targettarget modifier",
		["Description"] = "Hold down this button to heal the target your current target got. This setting can not be the same setting as \"Heal self modifier\". This setting have no impact on \"mouse healing\"."
	},
	["Genesis_GUILeftButtonDrop"] = {
		["Title"] = "Left button",
		["Description"] = "Select a class or a spell to associate with your left button."
	},
	["Genesis_GUILeftButtonRank"] = {
		["Title"] = "Spell rank",
		["Description"] = "Select the highest rank you want to use of this spell."
	},
	["Genesis_GUIRightButtonDrop"] = {
		["Title"] = "Right button",
		["Description"] = "Select a class or a spell to associate with your right button."
	},
	["Genesis_GUIRightButtonRank"] = {
		["Title"] = "Spell rank",
		["Description"] = "Select the highest rank you want to use of this spell."
	},
	["Genesis_GUIMiddleButtonDrop"] = {
		["Title"] = "Middle button",
		["Description"] = "Select a class or a spell to associate with your middle button."
	},
	["Genesis_GUIMiddleButtonRank"] = {
		["Title"] = "Spell rank",
		["Description"] = "Select the highest rank you want to use of this spell."
	},
	["Genesis_GUIButton4Drop"] = {
		["Title"] = "Button 4",
		["Description"] = "Select a class or a spell to associate with your button 4."
	},
	["Genesis_GUIButton4Rank"] = {
		["Title"] = "Spell rank",
		["Description"] = "Select the highest rank you want to use of this spell."
	},
	["Genesis_GUIButton5Drop"] = {
		["Title"] = "Button 5",
		["Description"] = "Select a class or a spell to associate with your button 5."
	},
	["Genesis_GUIButton5Rank"] = {
		["Title"] = "Spell rank",
		["Description"] = "Select the highest rank you want to use of this spell."
	},
	["Genesis_GUICustomButton1Drop"] = {
		["Title"] = "Custom button 1",
		["Description"] = "Select a class or a spell to associate with your custom button 1."
	},
	["Genesis_GUICustomButton1Rank"] = {
		["Title"] = "Spell rank",
		["Description"] = "Select the highest rank you want to use of this spell."
	},
	["Genesis_GUICustomButton2Drop"] = {
		["Title"] = "Custom button 2",
		["Description"] = "Select a class or a spell to associate with your custom button 2."
	},
	["Genesis_GUICustomButton2Rank"] = {
		["Title"] = "Spell rank",
		["Description"] = "Select the highest rank you want to use of this spell."
	},
	["PlayerPriority"] = {
		["Title"] = "Player priority",
		["Description"] = "Set your priority."
	},
	["PartyPriority"] = {
		["Title"] = "Party priority",
		["Description"] = "Set party members priority."
	},
	["RaidPriority"] = {
		["Title"] = "Raid priority",
		["Description"] = "Set raid members priority.",
	},
	["PetPriority"] = {
		["Title"] = "Pet priority",
		["Description"] = "Set pets priority.",
	},
	["BOPPriority"] = {
		["Title"] = "Blessing of Protection priority decrease",
		["Description"] = "Set how much a players priority will decrease when the player got buff \"Blessing of Protection\"."
	},
	["PWSPriority"] = {
		["Title"] = "Power Word: Shield priority decrease",
		["Description"] = "Set how much a players priority will decrease when the player got buff \"Power Word: Shield\". This value should always be higher than or equal to the Weakened Soul priority increase value."
	},
	["RBPriority"] = {
		["Title"] = "Recently Bandaged priority increase",
		["Description"] = "Set how much a players priority will increase when the player got debuff \"Recently Bandaged\"."
	},
	["WSPriority"] = {
		["Title"] = "Weakened Soul priority increase",
		["Description"] = "Set how much a players priority will increase when the player got debuff \"Weakened Soul\". This value should always be less than or equal to the Power Word: Shield priority decrease value."
	},
	["DruidPriority"] = {
		["Title"] = "Druid priority",
		["Description"] = "Set druids priority."
	},
	["HunterPriority"] = {
		["Title"] = "Hunter priority",
		["Description"] = "Set hunters priority."
	},
	["MagePriority"] = {
		["Title"] = "Mage priority",
		["Description"] = "Set mages priority."
	},
	["PaladinPriority"] = {
		["Title"] = "Paladin priority",
		["Description"] = "Set paladins priority."
	},
	["PriestPriority"] = {
		["Title"] = "Priest priority",
		["Description"] = "Set priests priority."
	},
	["RoguePriority"] = {
		["Title"] = "Rogue priority",
		["Description"] = "Set rogues priority."
	},
	["ShamanPriority"] = {
		["Title"] = "Shaman priority",
		["Description"] = "Set shamans priority."
	},
	["WarlockPriority"] = {
		["Title"] = "Warlock priority",
		["Description"] = "Set warlocks priority."
	},
	["WarriorPriority"] = {
		["Title"] = "Warrior priority",
		["Description"] = "Set warriors priority."
	},
	["RaidGroup%dLabel"] = {
		["Title"] = "Check/Uncheck group",
		["Description"] = "Click here if you wish to check/uncheck all the players in this group."
	},
	["RaidGroup%dSlot%dCheckButton"] = {
		["Title"] = "Check/Uncheck player",
		["Description"] = "Click here if you wish to check/uncheck this players."
	},
	["RaidCheckAllButton"] = {
		["Title"] = "Check all",
		["Description"] = "Click here if you wish to check all the players."
	},
	["RaidUncheckAllButton"] = {
		["Title"] = "Uncheck all",
		["Description"] = "Click here if you wish to uncheck all the players."
	},
	["RaidInvertCheckedButton"] = {
		["Title"] = "Invert checked",
		["Description"] = "Click here if you wish to invert the checked/unchecked players."
	},
	["RaidUncheckedPrioritySlider"] = {
		["Title"] = "Unchecked priority",
		["Description"] = "Set what priority unchecked players should have. If you set this to 0% then you won't heal the unchecked players at all."
	},
	["NinjaUseAction"] = {
		["Title"] = "Hook UseAction",
		["Description"] = "When this box is checked Genesis will detect whenever you click on a healing spell on your actionbar. This basicly means that Genesis will be able to cancel your spell if you're about to overheal (it will currently NOT cancel your spellcasting if you select target after you've selected spell). It's recommended you keep this box checked."
	},
	["HookShields"] = {
		["Title"] = "Hook shields",
		["Description"] = "If this box is checked Genesis will hook \"Power Word: Shield\" and \"Blessing of Protection\". This means that you can use these spells as a \"healing\" spell and make Genesis cast the spell on the most wounded player. Uncheck the box if you don't want these shields to be used as a healing spell."
	},
	["UseActionHealMostWounded"] = {
		["Title"] = "UseAction heal most wounded",
		["Description"] = "When this box and the \"Hook UseAction\" box is checked you'll heal the player in your party/raid who Genesis consider to be the most wounded (priorities affect this). This feature won't work unless \"Hook UseAction\" is checked."
	},
	["Autocancel"] = {
		["Title"] = "Autocancel healing",
		["Description"] = "Check this box if you want your healing spells used through Genesis to be automatically cancelled if you're about to overheal. It's recommended you keep this box checked."
	},
	["ShowHealingAll"] = {
		["Title"] = "Show all healing",
		["Description"] = "Show the healing everyone using Genesis do. Generally recommended if you're a healer."
	},
	["ShowHealingMe"] = {
		["Title"] = "Show only healing me",
		["Description"] = "Show only the healing i receive. Can be useful for non-healers who wish to know whether they got a heal coming their way or not and that way can decide whether to use a potion/bandage or not."
	},
	["TreatShapeshifted"] = {
		["Title"] = "Treat shapeshifted druids as rogues/warriors",
		["Description"] = "Check this box to give druids the same priority as rogues when they're in cat form and the same priority as warriors when they're in bear form."
	},
	["HealStrategy"] = {
		["Title"] = "Heal strategy",
		["Description"] = "This slider determines which strategy Genesis should use to heal people. There are 3 settings:\nLeast HP: Heal the player with least hitpoints left (default).\nLeast % life: Heal the player with least percent life left.\nMost HP missing: Heal the player with most hitpoints needed to be restored."
	},
	["SafeCancel"] = {
		["Title"] = "Safe cancel",
		["Description"] = "When this box is checked spells won't be cancelled by clicking on a healing spell/macro unless you will overheal more than the max overheal value."
	},
	["ScaleSpells"] = {
		["Title"] = "Scale Spells",
		["Description"] = "If this box is checked Genesis will scale down when you're not \"target healing\" to save mana. It's highly recommended that you keep this feature on, but there are some places where you might not want to scale down spells (Vaelastrasz in BWL is a good example)."
	},
	["HOTMinCancelThreshold"] = {
		["Title"] = "HOT heal threshold",
		["Description"] = "When a players life drops below the given percent Genesis won't concider how much HOT the player will receive. If you set this value to 100% Genesis will ignore any HOT on players. When a player drops below this value Genesis will also allow you to put a new hot on the player even if the player got the hot already."
	},
	["HOTMultiply"] = {
		["Title"] = "HOT value",
		["Description"] = "This value determine how much healing Genesis believe a HOT will do out of combat. Since buffs only say how much the HOT will heal without heal bonus (eg. \"Rejuvenation\" buff will show 189 per tick, but it can heal for 300 per tick) you can set this value higher than 100%. If you and the healers you usually heal with got a lot of +healing gear then it could be an idea to increase this value."
	},
	["HOTMultiplyBattle"] = {
		["Title"] = "HOT value combat",
		["Description"] = "Same as \"HOT value\" except this is in combat."
	},
	["MaxOverheal"] = {
		["Title"] = "Max overheal",
		["Description"] = "How much overhealing you'll allow before the heal frame go red. The heal frame will be green as long as you won't overheal, yellow if you're about to overheal but you got global cooldown and red if you're about to overheal and don't have global cooldown."
	},
	["MinHealThreshold"] = {
		["Title"] = "Min heal threshold",
		["Description"] = "Genesis won't heal anyone with more percent life left than what's given here. Recommended to keep a bit below 100% as it's pointless to heal someone who's almost as full health."
	},
	["HealPower"] = {
		["Title"] = "Heal power",
		["Description"] = "This is a damn fancy, but a risky feature. When this value is set to 100% you'll heal someone to 100% life (as long as you got a powerful enough spell & rank), but when the value is set to eg. 50% you'll only heal 50% of the life the player is missing. This feature is impressingly useful in raids where there are several healers. Your mana will last a lot longer if you decrease this value, but too low values can be very fatal."
	},
	["UpdatePlayerDataTime"] = {
		["Title"] = "Max update time",
		["Description"] = "Genesis regularly check every players buffs & debuffs so it's capable of determining how long they've had these buffs. This is needed to know how much healing they'll receive from HOT. The value you specify here is how many milliseconds of a second you'll allow Genesis to use to collect this data. Increase the value for a more accurate reading, decrease it for less FPS loss. This has been tested a lot in 40 man raids, and despite all the data it has to look through the methods are so optimized that the FPS drop is not even noticable."
	}
};
