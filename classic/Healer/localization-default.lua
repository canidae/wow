-- some variables for the gui
-- div stuff
HEALERGUI_ALL = "Party/Raid";
HEALERGUI_SELF = "Self";
HEALERGUI_AUTO = "Auto";
HEALERGUI_OK = "Okay";
HEALERGUI_CANCEL = "Cancel";
HEALERGUI_YES = "Yes";
HEALERGUI_NO = "No";
HEALERGUI_NONE = "None";
HEALERGUI_CLOSE = "Close";
HEALERGUI_CLASSES = "Class";
HEALERGUI_UNIT_CLASSES = "Unit class";
HEALERGUI_SPELLS = "Spells";
HEALERGUI_BUFFS = "Buffs";
HEALERGUI_DEBUFF = "Debuff";
HEALERGUI_PERCENT = "Percent";
HEALERGUI_PRIORITY = "Priority";
-- tabs
HEALERGUI_HEAL = "Heal";
HEALERGUI_BUFF = "Buff";
HEALERGUI_DEBUFF = "Debuff";
HEALERGUI_MISC = "Misc";
-- heal tab
HEALERGUI_NEW_HEALCLASS = "Enter a name for the new healclass";
HEALERGUI_CREATE_HEALCLASS = "Create a new healclass";
HEALERGUI_DELETE_HEALCLASS = "Delete selected healclass";
HEALERGUI_MAX_OVERHEAL = "Max overheal";
HEALERGUI_HEAL_RAID = "Heal raid";
HEALERGUI_COOPERATIVE_HEALING = "Cooperative healing";
HEALERGUI_SHOW_HEALBARS = "Show healbars";
HEALERGUI_SHOW_ONLY_ME = "Only healers healing me";
HEALERGUI_PLAYER_PRIORITY = "Player priority";
HEALERGUI_PARTY_PRIORITY = "Party priority";
HEALERGUI_RAID_PRIORITY = "Raid priority";
HEALERGUI_PARTYPET_PRIORITY = "Partypet priority";
HEALERGUI_RAIDPET_PRIORITY = "Raidpet priority";
HEALERGUI_MOUSEKEY_1 = "Healclass mousekey 1";
HEALERGUI_MOUSEKEY_2 = "Healclass mousekey 2";
HEALERGUI_MOUSEKEY_3 = "Healclass mousebutton 4";
HEALERGUI_MOUSEKEY_4 = "Healclass mousebutton 5";
-- buff tab
HEALERGUI_NEW_BUFFCLASS = "Enter a name for the new buffclass";
HEALERGUI_CREATE_BUFFCLASS = "Create a new buffclass";
HEALERGUI_DELETE_BUFFCLASS = "Delete selected buffclass";
HEALERGUI_BUFF_RAID = "Buff raid";
HEALERGUI_BUFF_PETS = "Buff pets";
HEALERGUI_AUTOBUFF_RAID = "Autobuff raid";
HEALERGUI_CAST_BUFF_IN_BATTLE = "Allow autobuffing in battle";
HEALERGUI_CAST_SELFBUFF_IN_BATTLE = "Allow autobuffing selfbuffs in battle";
HEALERGUI_AUTOBUFF_TARGET = "Autobuff friendly target";
-- debuff tab
HEALERGUI_SAVE_DEBUFF = "Save selected debuff";
HEALERGUI_DEBUFF_RAID = "Debuff raid";
HEALERGUI_DEBUFF_PETS = "Debuff pets";
HEALERGUI_AUTODEBUFF = "Autodebuff";
HEALERGUI_AUTODEBUFF_RAID = "Autodebuff raid";
HEALERGUI_USE_BEST_DEBUFF = "Always use best debuff available";
-- macro howto (in debuff tab)
HEALERGUI_MACRO_HOWTO = "How to create a macro";
HEALERGUI_MACRO_HOWTO1 = "1. Press <Enter> to get up the input for messages and write \"/macro\".";
HEALERGUI_MACRO_HOWTO2 = "2. Click on \"New\" in the lower right corner.";
HEALERGUI_MACRO_HOWTO3 = "3. Write a name for your macro (examples: \"instant\", \"debuff\").";
HEALERGUI_MACRO_HOWTO4 = "4. Chose an icon for your macro, I suggest you use a familiar icon.";
HEALERGUI_MACRO_HOWTO5 = "5. Below \"Enter Macro Commands\" you'll have to write one of these:";
HEALERGUI_MACRO_HOWTO50= "   /script Healer_AutoCast(); -- Casts anything marked Auto.";
HEALERGUI_MACRO_HOWTO51= "   /script Healer_Heal(\"<name of healclass>\");";
HEALERGUI_MACRO_HOWTO52= "   /script Healer_Buff(\"<name of buffclass>\");";
HEALERGUI_MACRO_HOWTO53= "   /script Healer_Debuff();";
HEALERGUI_MACRO_HOWTO54= "   /script Healer_Revive();";
HEALERGUI_MACRO_HOWTO55= " - \"<name of healclass>\" could for example be \"standard\".";
HEALERGUI_MACRO_HOWTO56= " - \"<name of buffclass>\" could for example be \"motw\".";
HEALERGUI_MACRO_HOWTO6 = "6. Click on \"Complete\" and drag your macro down to your actionbar.";
HEALERGUI_MACRO_HOWTO7 = " ";
-- misc tab
HEALERGUI_ANNOUNCE_OOM = "Announce \"Out of mana\"";
HEALERGUI_ANNOUNCE_NOT_READY = "Announce \"Spell not ready\"";
HEALERGUI_ANNOUNCE_OUT_OF_REACH = "Announce \"Out of reach\"";
HEALERGUI_ANNOUNCE_NOBODY_NEEDS = "Announce \"Nobody needs\"";
HEALERGUI_ANNOUNCE_ACTION = "Announce spellcasting";
HEALERGUI_ANNOUNCE_GOT_BUFF = "Announce \"Already got buff\"";
HEALERGUI_ANNOUNCE_OVERHEALING = "Announce autocancel";
HEALERGUI_ANNOUNCE_AUTOCASTING = "Announce autocasting";
HEALERGUI_SHOW_DOTBARS = "Show DOT bars";
HEALERGUI_AVOID_SPIRIT_TAP = "Avoid Spirit Tap (priest only)";
HEALERGUI_SHOW_WHO_CLICK_MINIMAP = "Show who clicked on minimap";
HEALERGUI_STATUS_BAR = "Show status bars"
HEALERGUI_STATUS_BAR_BUFFS = "Buffs"
HEALERGUI_STATUS_BAR_DEBUFFS = "Debuffs"
HEALERGUI_STATUS_BAR_OVERHEAL = "Overheal"

-- nuker
NUKERGUI_ABILITY = "Ability";
NUKERGUI_CHECK_DEBUFF = "Check for debuff";
NUKERGUI_DELAY = "Delay";
NUKERGUI_CREATE_NUKECLASS = "New";
NUKERGUI_DELETE_NUKECLASS = "Delete";
NUKERGUI_NEW_NUKECLASS = "Enter a name for the new nukeclass";

-- tooltip
HEALERGUI_HELP = {
	["Tab1"] = {
		["Title"] = "Healing",
		["Description"] = "In this tab you can set up your healclasses and decide what priorities each group of players/pets should have."
	},
	["Tab2"] = {
		["Title"] = "Buffing",
		["Description"] = "Here you can set up your buffclasses and set whether the addon should debuff pets and raidmembers."
	},
	["Tab3"] = {
		["Title"] = "Debuffing",
		["Description"] = "In the debuff tab you can turn on/off autodebuffing and set different parameters for whom to debuff."
	},
	["Tab4"] = {
		["Title"] = "Miscellaneous",
		["Description"] = "Different settings (such as announcement) can be set here."
	},
	["AutoHealclass"] = {
		["Title"] = "Auto healing",
		["Description"] = "If you click on one of these checkboxes the addon will automatically heal using the healclass next to the checkbox when you walk around. Note that only healing spells with instant casting time will be used. It's also strongly recommended that you only use this feature when you're grinding solo."
	},
	["HealclassEntry"] = {
		["Title"] = "Healclasses",
		["Description"] = "These are your healclasses. Click on one of them to change the settings for that healclass."
	},
	["HealspellEntry"] = {
		["Title"] = "Healing spells",
		["Description"] = "Here are the healing spells the addon has detected that you got. When you've selected a healclass you can select which of the healing spells the addon should use in the given healclass."
	},
	["HealPercentSlider"] = {
		["Title"] = "Heal percent",
		["Description"] = "The value you set here will affect what spell the addon will chose to use when you're using this healclass. If you set this value to 75% for a spell then the addon will not use that spell unless the person we're about to heal got less or equal to 75% hp left."
	},
	["MaxOverheal"] = {
		["Title"] = "Max overheal",
		["Description"] = "Set this value to how much overhealing you will allow before you want the addon to automatically cancel the spell. If you set this value to 100% then no spells will be canceled."
	},
	["HealRaid"] = {
		["Title"] = "Heal raid",
		["Description"] = "Check this box if you want to heal all the people in your raid. If you check this box then any healing announcements will appear in the raid chat instead of the party chat."
	},
	["CooperativeHealing"] = {
		["Title"] = "Cooperative healing",
		["Description"] = "When this box is checked the addon will coordinate the healing you do with other healers who's using the same addon. For this feature to work the other healers have to be in the same channel and in your party/raid."
	},
	["ShowHealbars"] = {
		["Title"] = "Show healbars",
		["Description"] = "If you check this box then up to 7 more bars will appear next to your own bar. These bars shows the other healers heals/revives."
	},
	["ShowOnlyMe"] = {
		["Title"] = "Show only healbars for healers healing me",
		["Description"] = "Check this box if you only want to see the healbars that are aimed at you or your pet." 
	},
	["HealPrioritySlider"] = {
		["Title"] = "Priority",
		["Description"] = "Set the priority of each group of players. If you set the value to 0% then that group of players won't be healed at all. Too low values will cause the addon not to heal that group of players before their health goes very low. Suggested values is in the range 50-100% and you should not go lower than this unless you want to turn off healing for that group of players or if you know exactly what you're doing."
	},
	["Autobuffclass"] = {
		["Title"] = "Auto buffing",
		["Description"] = "If you click on one of these checkboxes the addon will automatically buff using the buffclass next to the checkbox when you walk around."
	},
	["BuffclassEntry"] = {
		["Title"] = "Buffclasses",
		["Description"] = "These are your buffclasses. Click on one of them to change the settings for that buffclass."
	},
	["BuffUnitEntry"] = {
		["Title"] = "Unitclasses",
		["Description"] = "Here are the unitclasses listed. Simply select a class here to change the settings for this unitclass in this buffclass."
	},
	["BuffspellEntry"] = {
		["Title"] = "Buff spells",
		["Description"] = "Here are all the buffs the addon has detected that you got. When you've selected a buffclass and a unitclass you can select which buffs the addon should cast on the given unitclass in the given buffclass."
	},
	["BuffPrioritySlider"] = {
		["Title"] = "Buff priority",
		["Description"] = "The value you set here decides in what order the addon will cast buffs. If you set one buff with priority 1, and another buff in the same buffclass with priority 2, then the buff with priority 2 will be casted first."
	},
	["HealerGUIButton"] = {
		["Title"] = "Close window",
		["Description"] = "Closes this window."
	},
	["CreateHealclass"] = {
		["Title"] = "Create healclass",
		["Description"] = "Click on this button to create a new healclass."
	},
	["DeleteHealclass"] = {
		["Title"] = "Delete healclass",
		["Description"] = "Deletes the selected healclass. There will not be any confirmation nor will it be possible to restore the healclass."
	},
	["CreateBuffclass"] = {
		["Title"] = "Create buffclass",
		["Description"] = "Click on this button to create a new buffclass."
	},
	["DeleteBuffclass"] = {
		["Title"] = "Delete buffclass",
		["Description"] = "Deletes the selected buffclass. There will not be any confirmation nor will it be possible to restore the buffclass."
	},
	["BuffRaid"] = {
		["Title"] = "Buff raid",
		["Description"] = "Check off this box if you want to buff the entire raid and not only your party. If you check this box then any buff announcements will appear in raid chat instead of party chat."
	},
	["BuffPets"] = {
		["Title"] = "Buff pets",
		["Description"] = "Check off this box if you want to buff pets."
	},
	["AutobuffRaid"] = {
		["Title"] = "Autobuff raid",
		["Description"] = "Check off this box if you want to automatically buff raid and not only your party. In order for this to work you must've selected a buffclass to be automatically used."
	},
	["CastBuffInBattle"] = {
		["Title"] = "Cast buffs in battle",
		["Description"] = "Check this box if you want to allow automatically casting buffs when you're in battle"
	},
	["CastSelfbuffInBattle"] = {
		["Title"] = "Cast selfbuffs in battle",
		["Description"] = "Check this box if you want to allow automatically casting buffs that can only be used on you when you're in battle."
	},
	["AutobuffTarget"] = {
		["Title"] = "Autobuff friendly target",
		["Description"] = "When this box is checked the addon will buff friendly targets"
	},
	["SaveDebuffButton"] = {
		["Title"] = "Save selected debuff";
		["Description"] = "Click this button when you're done setting up a debuff."
	},
	["DebuffUnitEntry"] = {
		["Title"] = "Unitclasses",
		["Description"] = "After you've selected a debuff to modify then select a unitclass which you want to cure for this debuff."
	},
	["DebuffPrioritySlider"] = {
		["Title"] = "Debuff priority";
		["Description"] = "The value you set here decides in what order the addon will debuff the different unitclasses. If you set the priority of one unitclass to 1 and the priority of another unitclass to 2 then the unitclass with priority 2 will be debuffed first."
	},
	["DebuffRaid"] = {
		["Title"] = "Debuff raid",
		["Description"] = "Check off this box if you want to debuff the entire raid and not only your party. If you check this box then any debuff announcements will appear in raid chat instead of party chat."
	},
	["DebuffPets"] = {
		["Title"] = "Debuff pets",
		["Description"] = "Check off this box if you want to debuff pets."
	},
	["AutodebuffCheckButton"] = {
		["Title"] = "Autodebuff",
		["Description"] = "Check off this box if you want to automatically debuff while moving."
	},
	["AutodebuffRaid"] = {
		["Title"] = "Autodebuff raid",
		["Description"] = "Check off this box if you want to automatically debuff the entire raid and not only your party. Autodebuffing must be turned on for this setting to have any effect."
	},
	["AnnounceAutocasting"] = {
		["Title"] = "Announce autocasting",
		["Description"] = "Check this box if you want autocasting to be announced like normal casting."
	},
	["AllCheckButton"] = {
		["Title"] = "Announce to party/raid",
		["Description"] = "Check this box if you want this announcement in the party/raid channel."
	},
	["SelfCheckButton"] = {
		["Title"] = "Announce to self",
		["Description"] = "Check this box if you want this announcement only visible to yourself."
	},
	["ShowDOTbarsCheckButton"] = {
		["Title"] = "Show DOT bars",
		["Description"] = "Show bars for your DOT spells (or DOT spells you can cast) on nearby enemies"
	},
	["AvoidSpiritTap"] = {
		["Title"] = "Spirit Tap",
		["Description"] = "Avoid healing/buffing/debuffing when the player got \"Spirit Tap\" (priest only)"
	},
	["ShowWhoClickMinimap"] = {
		["Title"] = "Show who clicked on minimap",
		["Description"] = "When this checkbox is marked you'll get a note in your chatlog saying who clicked on the minimap"
	},
	["Mousekey"] = {
		["Title"] = "Mousekeys",
		["Description"] = "You can map a key (for example one of the buttons on your mouse), mousebutton 4 and mousebutton 5 to the different healclasses you've made. By doing this you can simply click on the player frame (top left corner), the party frame (those below the party frame when you're in a group), the raid pullout frames (those you can drag out to your main frame from the raid overview) or on a character in the main frame (not your own character). Do note that if you hold the shift key down the addon will enter the \"tank healing\" mode and use the highest rank of the healing spell with lowest \"percent\" value in that healclass. If not the addon will pick a healing spell that's barely strong enough to restore your target's hp."
	},
	["NukerGUIButton"] = {
		["Title"] = "Close window",
		["Description"] = "Closes this window."
	},
	["CreateNukeclass"] = {
		["Title"] = "Create nukeclass",
		["Description"] = "Click on this button to create a new nukeclass."
	},
	["DeleteNukeclass"] = {
		["Title"] = "Delete nukeclass",
		["Description"] = "Deletes the active nukeclass. There will not be any confirmation nor will it be possible to restore the nukeclass."
	},
	["DelaySlider"] = {
		["Title"] = "Delay Slider",
		["Description"] = "If this slider has been set then this ability will be used whenever the time runs out, even if the \"Check debuff\" box has been marked and the target got a debuff with the same name as the ability."
	},
	["DebuffCheckButton"] = {
		["Title"] = "Check for debuff",
		["Description"] = "When this checkbox is marked the addon will use this ability if the target does not have a debuff with the same name as the ability."
	},
	["Icon"] = {
		["Title"] = "Drag ability here",
		["Description"] = "Drag a spell or ability from your spellbook here."
	},
	["PreviousNuke"] = {
		["Title"] = "Previous",
		["Description"] = "Select the previous nukeclass."
	},
	["NextNuke"] = {
		["Title"] = "Next",
		["Description"] = "Select the next nukeclass."
	}
};

-- key bindings
BINDING_HEADER_HEALER = "Healer";
BINDING_NAME_HEALER_SHOWHIDEGUI = "Show/Hide GUI";
BINDING_NAME_HEALER_AUTOCAST = "Autocast";
BINDING_NAME_HEALER_BATTLEHEAL = "Battle healing";
BINDING_NAME_HEALER_INSTANT = "Instant healing";
BINDING_NAME_HEALER_STANDARD = "Standard healing";
BINDING_NAME_HEALER_DEBUFF = "Debuff";
BINDING_NAME_HEALER_BUFF = "Buff ('default' buffclass)";
BINDING_NAME_HEALER_REVIVE = "Revive";
BINDING_NAME_HEALER_MOUSEKEY_1 = "Mousekey 1";
BINDING_NAME_HEALER_MOUSEKEY_2 = "Mousekey 2";
BINDING_NAME_HEALER_MOUSEKEY_3 = "Mousebutton 4";
BINDING_NAME_HEALER_MOUSEKEY_4 = "Mousebutton 5";

-- rank
SPELL_RANK = "Rank";

-- language
LANGUAGE_COMMON = "Common";

-- debuff types
TYPE_CURSE = "Curse";
TYPE_DISEASE = "Disease";
TYPE_MAGIC = "Magic";
TYPE_POISON = "Poison";

-- healing text
HEAL_TEXT_1 = "Heals a friendly target for (%d+%.?%d*) to (%d+%.?%d*) and another (%d+%.?%d*) over (%d+%.?%d*) sec%.";
HEAL_TEXT_1b = "Heals a friendly target for (%d+%.?%d*) to (%d+%.?%d*) and another (%d+%.?%d*) to (%d+%.?%d*) over (%d+%.?%d*) sec%.";
HEAL_TEXT_2 = "Heals a friendly target for (%d+%.?%d*) to (%d+%.?%d*)%.";
HEAL_TEXT_3 = "Heals the target for (%d+%.?%d*) over (%d+%.?%d*) sec%.";
HEAL_TEXT_3b = "Heals the target for (%d+%.?%d*) to (%d+%.?%d*) over (%d+%.?%d*) sec%.";
HEAL_TEXT_4 = "Heal your target for (%d+%.?%d*) to (%d+%.?%d*).";
HEAL_TEXT_5 = "Heals the target of (%d+%.?%d*) damage over (%d+%.?%d*) sec%.";
HEAL_TEXT_5b = "Heals the target of (%d+%.?%d*) to (%d+%.?%d*) damage over (%d+%.?%d*) sec%.";
HEAL_TEXT_6 = "A slow casting spell that heals a single target for (%d+%.?%d*) to (%d+%.?%d*).";
-- note!
-- since german clients use "," instead of "." we need to replace all "," with "." or the spells won't be detected
HEAL_TEXT_7 = "Heals the friendly target for (%d+%.?%d*) to (%d+%.?%d*). then jumps to heal additional nearby targets.  If cast on a party member. the heal will only jump to other party members.  Each jump reduces the effectiveness of the heal by (%d+%.?%d*)%%.  Heals (%d+%.?%d*) total targets."
HEAL_TEXT_8 = "Draws on the soul of the party member to shield them. absorbing (%d+%.?%d*) damage.  Lasts (%d+%.?%d*) sec.  While the shield holds. spellcasting will not be interrupted by damage.  Once shielded. the target cannot be shielded again for (%d+%.?%d*) sec.";
HEAL_TEXT_9 = "or (%d+%.?%d*) to (%d+%.?%d*) healing to an ally."

-- debuff over time text
DOT_TEXT_1 = "for (%d+%.?%d*) sec";
DOT_TEXT_2 = "over (%d+%.?%d*) sec";
DOT_TEXT_3 = "up to (%d+%.?%d*) sec";
DOT_TEXT_4 = "lasts (%d+%.?%d*) sec";
DOT_TEXT_5 = "for (%d+%.?%d*) min";
DOT_TEXT_6 = "over (%d+%.?%d*) min";
DOT_TEXT_7 = "up to (%d+%.?%d*) min";
DOT_TEXT_8 = "lasts (%d+%.?%d*) min";
DIE_TEXT = "(.+) dies.";
AFFLICT_TEXT = "(.+) is afflicted by (.+)%.";
HIT_TEXT = "Your (.+) hits (.+) for";

-- some extra stuff needed to fetch data from spells
HEAL_INSTANT = "Instant cast";

-- mount text
MOUNT_TEXT_1 = "Increases speed by 60%.";
MOUNT_TEXT_2 = "Increases speed by 100%.";

-- text from extra healing from items
ITEM_HEAL_1 = "Increases healing done by spells and effects by up to (%d+%.?%d*)%.";
ITEM_HEAL_2 = "Increases damage and healing done by magical spells and effects by up to (%d+%.?%d*)%.";

-- unit classes
CLASS_DRUID = "Druid";
CLASS_HUNTER = "Hunter";
CLASS_MAGE = "Mage";
CLASS_PALADIN = "Paladin";
CLASS_PRIEST = "Priest";
CLASS_ROGUE = "Rogue";
CLASS_SHAMAN = "Shaman";
CLASS_WARLOCK = "Warlock";
CLASS_WARRIOR = "Warrior";
CLASS_SELF = "Self";

-- some spells we need to know
SPELL_REGROWTH = "Regrowth";
SPELL_RENEW = "Renew";
SPELL_REJUVENATION = "Rejuvenation";
SPELL_BOP = "Blessing of Protection";
SPELL_PWS = "Power Word: Shield";
SPELL_WEAKENED_SOUL = "Weakened Soul";
SPELL_PHASE_SHIFT = "Phase Shift";
SPELL_FIRST_AID = "First Aid";
SPELL_RECENTLY_BANDAGED = "Recently Bandaged";
SPELL_MIND_CONTROL = "Mind Control";
SPELL_NATURES_GRACE = "Nature's Grace";
SPELL_NATURES_SWIFTNESS = "Nature's Swiftness";
SPELL_INNER_FOCUS = "Inner Focus";
SPELL_CLEARCASTING = "Clearcasting";
SPELL_MOONKIN_FORM = "Moonkin Form";
SPELL_BANISH = "Banish";
SPELL_DEEP_SLUMBER = "Deep Slumber";
SPELL_SPIRIT_TAP = "Spirit Tap";

-- let's try to add resurrection
REVIVES = {
	["Resurrection"] = 1,
	["Redemption"] = 1,
	["Rebirth"] = 1,
	["Ancestral Spirit"] = 1
};

-- debuffs
SPELL_REMOVECURSE = "Remove Curse";
SPELL_CUREPOISON = "Cure Poison";
SPELL_CLEANSE = "Cleanse";
SPELL_PURIFY = "Purify";
SPELL_CUREDISEASE = "Cure Disease";
SPELL_DISPELMAGIC = "Dispel Magic";
SPELL_REMOVELESSERCURSE = "Remove Lesser Curse";
SPELL_ABOLISHPOISON = "Abolish Poison";
SPELL_ABOLISHDISEASE = "Abolish Disease";

-- buffs
-- druid
SPELL_MOTW = "Mark of the Wild";
SPELL_GOTW = "Gift of the Wild";
SPELL_THORNS = "Thorns";
SPELL_OMEN = "Omen of Clarity";

-- hunter
SPELL_TRUESHOT_AURA = "Trueshot Aura";

-- mage
SPELL_AMPLIFY = "Amplify Magic";
SPELL_ARCANE_BRILLIANCE = "Arcane Brilliance";
SPELL_ARCANE_INTELLECT = "Arcane Intellect";
SPELL_DAMPEN_MAGIC = "Dampen Magic";
SPELL_DETECT_MAGIC = "Detect Magic";
SPELL_MAGE_ARMOR = "Mage Armor";
SPELL_FIRE_WARD = "Fire Ward";
SPELL_FROST_ARMOR = "Frost Armor";
SPELL_FROST_WARD = "Frost Ward";
SPELL_ICE_ARMOR = "Ice Armor";
SPELL_MANA_SHIELD = "Mana Shield";

-- paladin
SPELL_BOF = "Blessing of Freedom";
SPELL_BOL = "Blessing of Light";
SPELL_BOW = "Blessing of Wisdom";
SPELL_BOSAC = "Blessing of Sacrifice";
SPELL_BOSAL = "Blessing of Salvation";
SPELL_BOSAN = "Blessing of Sanctuary";
SPELL_BOK = "Blessing of Kings";
SPELL_BOM = "Blessing of Might";
SPELL_GBOL = "Greater Blessing of Light";
SPELL_GBOW = "Greater Blessing of Wisdom";
SPELL_GBOSAL = "Greater Blessing of Salvation";
SPELL_GBOSAN = "Greater Blessing of Sanctuary";
SPELL_GBOM = "Greater Blessing of Might";
SPELL_GBOK = "Greater Blessing of Kings";
SPELL_RIGHTEOUS_FURY = "Righteous Fury";
SPELL_HOLY_SHOCK = "Holy Shock";
SPELL_DIVINE_FAVOR = "Divine Favor";

-- priest
SPELL_DIVINE_SPIRIT = "Divine Spirit";
SPELL_ELUNES_GRACE = "Elune's Grace";
SPELL_FEEDBACK = "Feedback";
SPELL_PWF = "Power Word: Fortitude";
SPELL_POF = "Prayer of Fortitude";
SPELL_SHADOW_PROTECTION = "Shadow Protection";
SPELL_INNER_FIRE = "Inner Fire";
SPELL_FEAR_WARD = "Fear Ward";
SPELL_TOW = "Touch of Weakness";
SPELL_SHADOWFORM = "Shadowform";
SPELL_PRAYER_OF_SPIRIT = "Prayer of Spirit";
SPELL_PRAYER_OF_SHADOW_PROTECTION = "Prayer of Shadow Protection";

-- rogue
SPELL_DETECT_TRAPS = "Detect Traps";

-- shaman
SPELL_ELEMENTAL_FOCUS = "Elemental Focus";
SPELL_LIGHTNING_SHIELD = "Lightning Shield";
SPELL_ROCKBITER_WEAPON = "Rockbiter Weapon";
SPELL_WINDFURY_WEAPON = "Windfury Weapon";
SPELL_FROSTBRAND_WEAPON = "Frostbrand Weapon";
SPELL_FLAMETONGUE_WEAPON = "Flametongue Weapon";

-- warlock
SPELL_DEMON_ARMOR = "Demon Armor";
SPELL_DEMON_SKIN = "Demon Skin";
SPELL_DETECT_LINV = "Detect Lesser Invisibility";
SPELL_DETECT_INV = "Detect Invisibility";
SPELL_DETECT_GINV = "Detect Greater Invisibility";
SPELL_SHADOW_WARD = "Shadow Ward";
SPELL_UNENDING_BREATH = "Unending Breath";
SPELL_FIRE_SHIELD = "Fire Shield";
