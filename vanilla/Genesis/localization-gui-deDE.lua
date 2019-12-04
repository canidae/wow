if (GetLocale() ~= "deDE") then
    return;
end

-- bindings
BINDING_HEADER_GENESIS = "Genesis";
BINDING_NAME_GENESIS_CUSTOM_1 = "Custom 1";
BINDING_NAME_GENESIS_CUSTOM_2 = "Custom 2";

-- tab titles
Genesis_GUI_tab_title = {"Klassen", "Maus/Keys", "Priorit\195\164ten", "Raid", "Konfig"};

-- custom classes
Genesis_GUI_new = "Neu";
Genesis_GUI_delete = "L\195\182schen";
Genesis_GUI_percent = "Prozent";
Genesis_GUI_rank = "Rang";
Genesis_GUI_new_class = "Name der neuen Klasse";
Genesis_GUI_okay = "Okay";
Genesis_GUI_cancel = "Abbrechen";

-- keys thingy
Genesis_GUI_keys = {"Off", "None", "Alt", "Control", "Shift", "Alt + Control", "Alt + Shift", "Control + Shift"};
Genesis_GUI_heal_enough = "Heal enough";
Genesis_GUI_heal_self = "Heal self";
Genesis_GUI_heal_max = "Heal max";
Genesis_GUI_heal_targettarget = "Heal targettarget";

-- mousehealing
Genesis_GUI_left_button = "Linke Maustaste";
Genesis_GUI_right_button = "Rechte Maustaste";
Genesis_GUI_middle_button = "Middle Button";
Genesis_GUI_custom_1 = "Custom 1";
Genesis_GUI_custom_2 = "Custom 2";

-- priorities
Genesis_GUI_player_priority = "Spieler";
Genesis_GUI_party_priority = "Gruppe";
Genesis_GUI_raid_priority = "Schlachtzug";
Genesis_GUI_pet_priority = "Begleiter";
Genesis_GUI_bop_priority = "Malus:Segen d.Schutz.";
Genesis_GUI_pws_priority = "Malus:MaWo Schild";
Genesis_GUI_rb_priority = "Bonus:Bandagiert";
Genesis_GUI_ws_priority = "Bonus:geschw. Seele";
Genesis_GUI_druid_priority = "Druide";
Genesis_GUI_hunter_priority = "J\195\164ger";
Genesis_GUI_mage_priority = "Magier";
Genesis_GUI_paladin_priority = "Paladin";
Genesis_GUI_priest_priority = "Priester";
Genesis_GUI_rogue_priority = "Schurke";
Genesis_GUI_shaman_priority = "Schamane";
Genesis_GUI_warlock_priority = "Hexenmeister";
Genesis_GUI_warrior_priority = "Krieger";

-- raid
Genesis_GUI_check_all = "Check all";
Genesis_GUI_uncheck_all = "Uncheck all";
Genesis_GUI_invert_checked = "Invert checked";
Genesis_GUI_unchecked_priority = "Unchecked priority";

-- settings
Genesis_GUI_hook_useaction = "UseAction einbinden";
Genesis_GUI_hook_shields = "Schilde einbinden";
Genesis_GUI_useaction_wounded = "UseAction: nutze Priorit\195\164ten";
Genesis_GUI_show_all = "Zeige alle Heilung";
Genesis_GUI_show_me = "Zeige nur erhaltene Heilung";
Genesis_GUI_shapeshifted_druids = "Treat shapeshifted druids as rogues/warriors";
Genesis_GUI_safe_cancel = "Sicheres Abbrechen";
Genesis_GUI_scale_spells = "Skaliere Zauber";
Genesis_GUI_hot_cancel = "HoT Grenze";
Genesis_GUI_hot_value = "HoT MOD";
Genesis_GUI_hot_value_battle = "HoT MOD im Kampf";
Genesis_GUI_max_overheal = "Max. \195\156berheilung";
Genesis_GUI_min_heal_threshold = "Heilgrenze";
Genesis_GUI_heal_power = "Heilkraft";
Genesis_GUI_update_time = "Intervall";
Genesis_GUI_heal_strategy = "Heilstrategie";
Genesis_GUI_heal_strategies = {"Least HP", "Least % life", "Most HP missing"};

-- tooltip help
Genesis_GUI_help = {
    ["Tab1"] = {
        ["Title"] = "Klassen",
        ["Description"] = "Erstelle deine eigenen Klassen von Heilzaubern."
    },
    ["Tab2"] = {
        ["Title"] = "Maus/Keys",
        ["Description"] = "Configure how the addon will react when you press certain buttons (alt/ctrl/shift) while healing.\nBinde einen Heilzauber an eine Maustaste, so dass du einfach per Mausklick auf einen Spielerframe heilen kannst."
    },
    ["Tab3"] = {
        ["Title"] = "Priorit\195\164ten",
        ["Description"] = "Lege die Priorit\195\164ten für Spieler bei Nutzung von \"UseAction: nutze Priorit\195\164ten\" (siehe Konfig) fest"
    },
    ["Tab4"] = {
        ["Title"] = "Raid",
        ["Description"] = "Here you can chose which players to heal when you're in a raid and are healing using the \"heal most wounded\" feature."
    },
    ["Tab5"] = {
        ["Title"] = "Konfig",
        ["Description"] = "Stelle hier ein, wie sich Genesis verhalten soll."
    },
    ["Genesis_GUIClass"] = {
        ["Title"] = "Klassen",
        ["Description"] = "Ziehe einen Heilzauber aus deinem Zauberbuch hier rein, um ihn zu dieser Klasse hinzuzuf\195\188gen."
    },
    ["ClassDropDownMenu"] = {
        ["Title"] = "Klasse w\195\164hlen",
        ["Description"] = "Selektiere eine Klasse um sie zu konfigurieren."
    },
    ["NewClassButton"] = {
        ["Title"] = "Neue Klasse",
        ["Description"] = "Klicke hier, um eine neue Klasse zu generieren."
    },
    ["DeleteClassButton"] = {
        ["Title"] = "Klasse l\195\182schen",
        ["Description"] = "Klicke hier um die ausgew\195\164hlte Klasse zu l\195\182schen."
    },
    ["Genesis_GUIClass%dRankSlider"] = {
        ["Title"] = "Rang",
        ["Description"] = "W\195\164hle den h\195\182chsten Rang, den du bei diesem Zauber nutzen willst."
    },
    ["Genesis_GUIClass%dPercentSlider"] = {
        ["Title"] = "Prozent",
        ["Description"] = "W\195\164hle den maximalen Prozentsatz an Leben den ein Spieler haben darf, damit dieser Spruch auf ihn angewandt wird. Falls der Spieler unter diesen Prozentwert f\195\164llt und es einen weiteren Spruch in dieser Klasse gibt , der einen niedrigeren Prozentwert hat, wird stattdessen dieser angewandt."
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
        ["Description"] = "Hold down this button to heal the target of your current. This setting can not be the same setting as \"Heal self modifier\". This setting have no impact on \"mouse healing\"."
    },
    ["Genesis_GUILeftButtonDrop"] = {
        ["Title"] = "Linke Maustaste",
        ["Description"] = "W\195\164hle eine Klasse oder einen Spruch, um die linke Maustaste damit zu belegen."
    },
    ["Genesis_GUILeftButtonRank"] = {
        ["Title"] = "Zauberrang",
        ["Description"] = "W\195\164hle den h\195\182chsten Rang, den du bei diesem Zauber nutzen willst."
    },
    ["Genesis_GUIRightButtonDrop"] = {
        ["Title"] = "Rechte Maustaste",
        ["Description"] = "W\195\164hle eine Klasse oder einen Spruch, um die rechte Maustaste damit zu belegen."
    },
    ["Genesis_GUIRightButtonRank"] = {
        ["Title"] = "Zauberrang",
        ["Description"] = "W\195\164hle den h\195\182chsten Rang, den du bei diesem Zauber nutzen willst."
    },
    ["Genesis_GUIMiddleButtonDrop"] = {
        ["Title"] = "Middle button",
        ["Description"] = "W\195\164hle eine Klasse oder einen Spruch, um die mittlere Maustaste damit zu belegen."
    },
    ["Genesis_GUIMiddleButtonRank"] = {
        ["Title"] = "Zauberrang",
        ["Description"] = "W\195\164hle den h\195\182chsten Rang, den du bei diesem Zauber nutzen willst."
    },
    ["Genesis_GUIButton4Drop"] = {
        ["Title"] = "Button 4",
        ["Description"] = "W\195\164hle eine Klasse oder einen Spruch, um Button 4 damit zu belegen."
    },
    ["Genesis_GUIButton4Rank"] = {
        ["Title"] = "Zauberrang",
        ["Description"] = "W\195\164hle den h\195\182chsten Rang, den du bei diesem Zauber nutzen willst."
    },
    ["Genesis_GUIButton5Drop"] = {
        ["Title"] = "Button 5",
        ["Description"] = "W\195\164hle eine Klasse oder einen Spruch, um Button 5 damit zu belegen."
    },
    ["Genesis_GUIButton5Rank"] = {
        ["Title"] = "Zauberrang",
        ["Description"] = "W\195\164hle den h\195\182chsten Rang, den du bei diesem Zauber nutzen willst."
    },
    ["Genesis_GUICustomButton1Drop"] = {
        ["Title"] = "Custom button 1",
        ["Description"] = "W\195\164hle eine Klasse oder einen Spruch, um den Custom Button 1 damit zu belegen."
    },
    ["Genesis_GUICustomButton1Rank"] = {
        ["Title"] = "Zauberrang",
        ["Description"] = "W\195\164hle den h\195\182chsten Rang, den du bei diesem Zauber nutzen willst."
    },
    ["Genesis_GUICustomButton2Drop"] = {
        ["Title"] = "Custom button 2",
        ["Description"] = "W\195\164hle eine Klasse oder einen Spruch, um den Custom Button 2 damit zu belegen."
    },
    ["Genesis_GUICustomButton2Rank"] = {
        ["Title"] = "Zauberrang",
        ["Description"] = "W\195\164hle den h\195\182chsten Rang, den du bei diesem Zauber nutzen willst."
    },
    ["PlayerPriority"] = {
        ["Title"] = "Priorit\195\164t des Spielers",
        ["Description"] = "Stelle deine eigene Priorit\195\164t ein."
    },
    ["PartyPriority"] = {
        ["Title"] = "Priorit\195\164t der Gruppe",
        ["Description"] = "Stelle die Priorit\195\164t deiner Gruppe ein."
    },
    ["RaidPriority"] = {
        ["Title"] = "Priorit\195\164t des Schlachtzugs",
        ["Description"] = "Stelle die Priorit\195\164t deines Schlachtzugs ein.",
    },
    ["PetPriority"] = {
        ["Title"] = "Priorit\195\164t der Begleiter",
        ["Description"] = "Stelle die Priorit\195\164t von Begleitern ein.",
    },
    ["BOPPriority"] = {
        ["Title"] = "Malus bei Segen des Schutzes",
        ["Description"] = "Stelle ein, um wieviel Prozent die Priorit\195\164t von Spielern abnimmt, wenn sie mit \"Segen des Schutzes\" gebufft sind."
    },
    ["PWSPriority"] = {
        ["Title"] = "Malus bei Machtwort: Schild",
        ["Description"] = "Stelle ein, um wieviel Prozent die Priorit\195\164t von Spielern abnimmt, wenn sie mit \"Machtwort: Schild\" gebufft sind. Dieser Wert sollte mindestens so hoch sein wie der Bonus, den du bei dem \"geschw\195\164chter Seele\" Debuff eingestellt hast."
    },
    ["RBPriority"] = {
        ["Title"] = "Bonus bei k\195\188rzlicher Bandage",
        ["Description"] = "Stelle ein, um wieviel Prozent die Priorit\195\164t von Spielern zunimmt, wenn sie von dem Debuff \"k\195\188rzlich bandagiert\" betroffen sind."
    },
    ["WSPriority"] = {
        ["Title"] = "Bonus bei geschw\195\164chter Seele",
        ["Description"] = "Stelle ein, um wieviel Prozent die Priorit\195\164t von Spielern zunimmt, wenn sie von dem Debuff \"Bonus bei geschw\195\164chter Seele\" betroffen sind. Dieser Wert sollte kleiner oder gleich dem Malus sein, den du dem \"Machtwort: Schild\" Buff eingestellt hast."
    },
    ["DruidPriority"] = {
        ["Title"] = "Priorit\195\164t der Druiden",
        ["Description"] = "Stellt die Priorit\195\164t ein, die Genesis den Druiden zukommen lassen wird."
    },
    ["HunterPriority"] = {
        ["Title"] = "Priorit\195\164t der J\195\164ger",
        ["Description"] = "Stellt die Priorit\195\164t ein, die Genesis den J\195\164gern zukommen lassen wird."
    },
    ["MagePriority"] = {
        ["Title"] = "Priorit\195\164t der Magier",
        ["Description"] = "Stellt die Priorit\195\164t ein, die Genesis den Magiern zukommen lassen wird."
    },
    ["PaladinPriority"] = {
        ["Title"] = "Priorit\195\164t der Paladin",
        ["Description"] = "Stellt die Priorit\195\164t ein, die Genesis den Paladin zukommen lassen wird."
    },
    ["PriestPriority"] = {
        ["Title"] = "Priorit\195\164t der Priester",
        ["Description"] = "Stellt die Priorit\195\164t ein, die Genesis den Priestern zukommen lassen wird."
    },
    ["RoguePriority"] = {
        ["Title"] = "Priorit\195\164t der Schurken",
        ["Description"] = "Stellt die Priorit\195\164t ein, die Genesis den Schurken zukommen lassen wird."
    },
    ["ShamanPriority"] = {
        ["Title"] = "Priorit\195\164t der Schamanen",
        ["Description"] = "Stellt die Priorit\195\164t ein, die Genesis den Schamanen zukommen lassen wird."
    },
    ["WarlockPriority"] = {
        ["Title"] = "Priorit\195\164t der Hexenmeister",
        ["Description"] = "Stellt die Priorit\195\164t ein, die Genesis den Schamanen zukommen lassen wird."
    },
    ["WarriorPriority"] = {
        ["Title"] = "Priorit\195\164t der Krieger",
        ["Description"] = "Stellt die Priorit\195\164t ein, die Genesis den Kriegern zukommen lassen wird."
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
        ["Title"] = "UseAction einbinden",
        ["Description"] = "Wenn du hier ein H\195\164kchen setzt, wird Genesis deine Actionbar auf von dir ausgef\195\188hrte Heilzauber \195\188berwachen. Das bedeutet, dass Genesis in der Lage ist, dir die Funktionalit\195\164t zum Abbruch bei \195\188berheilung zur Verf\195\188gung zu stellen (dies funktioniert zur Zeit NICHT, falls du erst deinen Zauber ausw\195\164hlst und dann erst dein Ziel). Es wird empfohlen, diese Funktion eingeschaltet zu lassen."
    },
    ["HookShields"] = {
        ["Title"] = "Schilde einbinden",
        ["Description"] = "Wenn du hier ein H\195\164kchen setzt, wird Genesis \"Machtword: Schild\" und \"Segen d. Schutzes\" einbinden. Das bedeutet, dass du diese Spr\195\188che als \"Heilzauber\" innerhalb von Genesis nutzen kannst. Mache das H\195\164kchen weg, wenn Genesis keine Schilde benutzen soll."
    },
    ["UseActionHealMostWounded"] = {
        ["Title"] = "UseAction: nutze Priorit\195\164ten",
        ["Description"] = "Wenn du hier und bei \"UseAction einbinden\" ein H\195\164kchen gesetzt hast, kann Genesis automatisch den priorisierten Verwundeten aussuchen. Falls du einen Freund als Ziel selektiert hast, wird dieser geheilt, andernfalls wird das Ziel von Genesis bestimmt."
    },
    ["Autocancel"] = {
        ["Title"] = "Autocancel healing",
        ["Description"] = "Check this box if you want your healing spells used through Genesis to be automatically cancelled if you're about to overheal. It's recommended you keep this box checked."
    },
    ["ShowHealingAll"] = {
        ["Title"] = "Zeige alle Heilung",
        ["Description"] = "Zeige alle Heilungen, die Benutzer von Genesis ausf\195\188hren. Generell empfohlen f\195\188r Heiler."
    },
    ["ShowHealingMe"] = {
        ["Title"] = "Zeige nur empfangene Heilung",
        ["Description"] = "Genesis zeigt nur die Heilung an, die du empf\195\164ngst. Kann von Nicht-Heilern genutzt werden, um fest zu stellen, ob gerade eine Heilung auf sie im Gange ist."
    },
    ["TreatShapeshifted"] = {
        ["Title"] = "Treat shapeshifted druids as rogues/warriors",
        ["Description"] = "Check this box to give druids the same priority as rogues when they're in cat form and the same priority as warriors when they're in bear form."
    },
    ["HealStrategy"] = {
        ["Title"] = "Heilstrategie",
        ["Description"] = "Dieser Schieberegler bestimmt, welche Strategie Genesis verfolgt, wenn es bei aktiviertem \"UseAction: nutze Priorit\195\164ten\" Ziele selbst\195\164ndig aussucht. Es gibt 3 Einstellungen:\nStrategie 0: Heile den, der die wenigsten Gesundheitspunkte \195\188brig hat (Voreinstellung).\nStrategie 1: Heile den, dem die wenigsten Prozent seiner Gesundheit geblieben sind.\nStrategie 2: Heile den, der die meissten Gesundheitspunkte ben\195\182tigt, um sich wieder voller Gesundheit zu erfreuen."
    },
    ["SafeCancel"] = {
        ["Title"] = "Sicheres Abbrechen",
        ["Description"] = "Wenn du hier ein H\195\164kchen setzt, werden Heilzauber/Makros nicht abgebrochen, wenn du w\195\164hrend des Zauberns wieder auf den Button dr\195\188ckst, ausser du \195\188berschreitest den Wert, den du bei \"Maximale \195\188berheilung\" eingestellt hast."
    },
    ["ScaleSpells"] = {
        ["Title"] = "Skaliere Zauber",
        ["Description"] = "Wenn du hier ein H\195\164kchen setzt, wird Genesis Zauber skalieren um Mana zu sparen falls du kein \"target healing\" betreibst. Es wird schwer empfohlen, diese Funktion aktiviert zu lassen, allerdings mag es Situationen geben, in denen du sie vielleicht besser deaktivierst (Vaelastrasz in BWL zum Beispiel)."
    },
    ["HOTMinCancelThreshold"] = {
        ["Title"] = "HOT Grenze",
        ["Description"] = "Wenn das Leben eines Spielers unter den eingestellten Prozentwert f\195\164llt, wird Genesis die HoTs mit denen er belegt ist ignorieren. Falls du diesen Wert auf 100% stellst, wird Genesis HoTs bei der Berechnung der Priorit\195\164t g\195\164nzlich ignorieren. Wenn ein Spieler diesen Wert unterschreitet wird Genesis dir auch erlauben, einen HoT auf ihn zu sprechen obwohl dieser schon einen solchen hat."
    },
    ["HOTMultiply"] = {
        ["Title"] = "HoT MOD",
        ["Description"] = "Dieser Wert bestimmt, wieviel Heilung eines HoTs nach Genesis Glauben ankommt - au\195\159erhalb des Kampfes. Da Buffs nur anzeigen, wieviel der HoT ohne Heilboni heilt (z.B. \"Verj\195\188ngung\" zeigt nur 189 pro tick, aber es kann auch 300 pro tick mit entsprechendem Equipment), kannst du diesen Schieberegler auf \195\188ber 100% stellen. Falls du eine Menge Equipment mit +Heilung hast, ist es eine gute Idee diesen Wert hochzuschrauben."
    },
    ["HOTMultiplyBattle"] = {
        ["Title"] = "HoT MOD im Kampf",
        ["Description"] = "Siehe \"HoT Wert\" nur innerhalb des Kampfes."
    },
    ["MaxOverheal"] = {
        ["Title"] = "Maximale \195\156berheilung",
        ["Description"] = "Hier kannst du einstellen, ab wieviel \195\156berheilung der Heilframe rot angezeigt. Der Frame ist gr\195\188n solange du nicht \195\188berheilst, gelb wenn du \195\188berheilst aber globalen Cooldown hast, und rot falls du \195\188berheilst und keinen globalen Cooldown hast. Gibt auch den Wert f\195\188r \"Sicheres Abbrechen\" vor."
    },
    ["MinHealThreshold"] = {
        ["Title"] = "Heilgrenze",
        ["Description"] = "Genesis wird niemanden heilen, der noch mehr Prozent seiner Gesundheitspunkte \195\188brig hat als hier eingestellt. Empfohlen ein wenig unter 100% zu bleiben da es witzlos ist jemanden mit fast vollem Leben zu heilen."
    },
    ["HealPower"] = {
        ["Title"] = "Heilkraft",
        ["Description"] = "Dies ist eine schicke aber auch riskante Funktion. Wenn dieser Wert auf 100% steht wirst du auf 100% Leben heilen (falls deine Zauber das hergeben), aber falls der Wert z.B. auf 50% steht, wirst du nur die Hälfte seines fehlenden Lebens wiederherstellen. Falls er 50% hat, wirst du ihn so auf 75% hochheilen. Das kann sehr n\195\188tzlich sein, wenn einer von mehreren Crosshealern in einem Schlachtzug bist, da du weit weniger Mana verbrauchst, allerdings kann ein niedriger Wert auch fatale Folgen haben..."
    },
    ["UpdatePlayerDataTime"] = {
        ["Title"] = "Intervall der Abfragen",
        ["Description"] = "Genesis pr\195\188ft regelm\195\164\195\159ig alle Buffs & Debuffs der Spieler, damit es besser bestimmen kann, wie lange die Buffs schon andauern. Dies wird zur Prognose genutzt, wieviel von einem HoT ankommt. Der Wert legt fest, in welchem Intervall (Millisekunden) Genesis die Daten sammelt. Verringere den Wert um die Genauigkeit der Prognose zu verbessern, erh\195\182he ihn um weniger FPS zu verlieren. Die Funktion wurde in diversen 40-Mann Schlachtgruppen getestet, und die Methoden sind daraufhin optimiert dass der FPS Verlust nicht feststellbar sein sollte."
    }
};
