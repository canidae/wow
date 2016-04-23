-- don't mess with this ;)
HEALER_VERSION = "6.6";
HEALERGUI_TITLE = "Healer " .. HEALER_VERSION .. "\n\"unsane, beyond sanity, and yet not insane\"";
NUKER_VERSION = HEALER_VERSION;
NUKERGUI_TITLE = "Nuker " .. NUKER_VERSION .. "\n\"and the day turned to fright\"";
HEALER_HEALS = {};
HEALER_BUFFS = {};
HEALER_DEBUFFS = {};
HEALER_DEBUFFS_CAN_CURE_TYPES = {};
HEALER_REVIVE = {};
HEALER_DOTS = {};
NUKER_NUKES = {};
HEALER_REQUIRED_C_VERSION = 1;
-- *sigh*
HEALER_SPELL_LEVELS = {
	[SPELL_HOLY_SHOCK] = {
		[1] = 40,
		[2] = 48,
		[3] = 46
	},
	[SPELL_BOP] = {
		[1] = 10,
		[2] = 24,
		[3] = 38
	},
	[SPELL_PWS] = {
		[1] = 6,
		[2] = 12,
		[3] = 18,
		[4] = 24,
		[5] = 30,
		[6] = 36,
		[7] = 42,
		[8] = 48,
		[9] = 54,
		[10] = 60
	},
	[SPELL_REGROWTH] = {
		[1] = 12,
		[2] = 18,
		[3] = 24,
		[4] = 30,
		[5] = 36,
		[6] = 42,
		[7] = 48,
		[8] = 54,
		[9] = 60
	},
	[SPELL_REJUVENATION] = {
		[1] = 4,
		[2] = 10,
		[3] = 16,
		[4] = 22,
		[5] = 28,
		[6] = 34,
		[7] = 40,
		[8] = 46,
		[9] = 52,
		[10] = 58,
		[11] = 60
	},
	[SPELL_RENEW] = {
		[1] = 8,
		[2] = 14,
		[3] = 20,
		[4] = 26,
		[5] = 32,
		[6] = 38,
		[7] = 44,
		[8] = 50,
		[9] = 56,
		[10] = 62
	}
};
HEALER_HEAL_MULTIPLY = {
	[CLASS_DRUID] = 60,
	[CLASS_HUNTER] = 65,
	[CLASS_MAGE] = 50,
	[CLASS_PALADIN] = 70,
	[CLASS_PRIEST] = 50,
	[CLASS_ROGUE] = 65,
	[CLASS_SHAMAN] = 70,
	[CLASS_WARLOCK] = 65,
	[CLASS_WARRIOR] = 90
};
UNITCLASSES = {
	CLASS_DRUID,
	CLASS_HUNTER,
	CLASS_MAGE,
	CLASS_PALADIN,
	CLASS_PRIEST,
	CLASS_ROGUE,
	CLASS_SHAMAN,
	CLASS_WARLOCK,
	CLASS_WARRIOR,
	CLASS_SELF
};
HEALER_CANT_CAST_ON = {};
HEALER_CANT_CAST_ON_TICK=0;
HEALER_AUTOCASTING = nil;
HEALER_DOING_SOMETHING = nil;
HEALER_IN_BATTLE = nil;
HEALER_ACTION = nil;
HEALER_TARGETLASTTARGET = nil;
HEALER_BUFF_CACHE = {};
HEALER_TANK = nil;
HEALER_BEING_HEALED = {};
HEALER_OTHER_HEALERS = {};
HEALER_OLD_CHATFRAME = nil;
HEALER_REPEATED_MESSAGE = nil;
HEALER_CHECK_SITTING = nil;
HEALER_REVIVE_BAN = {};
HEALER_EQUIP_CACHE = {};
NUKER_PICKUP_SPELLID = nil;
NUKER_PICKUP_SPELLBOOKTABNUM = nil;
NUKER_NUKECLASS = nil;
NUKER_IMMUNE = nil;
NUKER_FADE = nil;
NUKER_FLASH = nil;
HEALER_LAST_MINIMAP_CLICK = nil;

-- some crap needed for gui
HEALERGUI_CUR_HEAL_CLASS = nil;

-- function hooks
Healer_old_MoveBackwardStart = nil;
Healer_old_MoveForwardStart = nil;
Healer_old_StrafeLeftStart = nil;
Healer_old_StrafeRightStart = nil;
Healer_old_TurnLeftStart = nil;
Healer_old_TurnRightStart = nil;
Healer_old_PlayerFrame_OnClick = nil;
Healer_old_PartyMemberFrame_OnClick = nil;
Healer_old_RaidPulloutButton_OnClick = nil;
Nuker_old_PickupSpell = nil;

-- argh, the spellbook is so damn slow
HEALER_HAS_CHECKED_SPELLBOOK = nil;

function Healer_OnLoad()
	this:RegisterEvent("CHAT_MSG_WHISPER"); --added by pilardi
	this:RegisterEvent("MINIMAP_PING");
	this:RegisterEvent("LEARNED_SPELL_IN_TAB");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("SPELLCAST_START");
	this:RegisterEvent("SPELLCAST_DELAYED");
	this:RegisterEvent("SPELLCAST_STOP");
	this:RegisterEvent("SPELLCAST_FAILED");
	this:RegisterEvent("SPELLCAST_INTERRUPTED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("PLAYER_QUITTING");
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH");
	this:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
	SLASH_HEALERCMD1 = "/healer";
	SlashCmdList["HEALERCMD"] = function(msg)
		Healer_Cmd(msg);
	end
	SLASH_NUKERCMD1 = "/nuker";
	SlashCmdList["NUKERCMD"] = function(msg)
		Nuker_Cmd(msg);
	end

	Healer_old_PlayerFrame_OnClick = PlayerFrame_OnClick;
	PlayerFrame_OnClick = Healer_PlayerFrame_OnClick;
	Healer_old_PartyMemberFrame_OnClick = PartyMemberFrame_OnClick;
	PartyMemberFrame_OnClick = Healer_PartyMemberFrame_OnClick;
	Healer_old_RaidPulloutButton_OnClick = RaidPulloutButton_OnClick;
	RaidPulloutButton_OnClick = Healer_RaidPulloutButton_OnClick;
	Nuker_old_PickupSpell = PickupSpell;
	PickupSpell = Nuker_PickupSpell;

	-- and one more
	HEALER_OLD_CHATFRAME = ChatFrame_OnEvent;
	ChatFrame_OnEvent = Healer_ChatFrame_OnEvent;

	-- init HealerUpdateStatusBar variables
	Healer_BuffsNeededList={};
	Healer_DebuffsNeededList={};
end

function Healer_OnEvent()
	-- added by pilardi for WhisperHandling
	if (event == "CHAT_MSG_WHISPER") then
		if (arg1 and arg2 and not HEALER_WCDISABLED) then
			Healer_HandleWhisper(arg2, arg1);
		end
	end

	if (event == "VARIABLES_LOADED") then
		-- fetch data from table
		if (not Healer_Data) then
			Healer_Data = {};
		end
		local me = UnitName("player");
		if (Healer_Data[me]) then
			HEALER_PLAYER_PRI = Healer_Data[me]["HEALER_PLAYER_PRI"];
			HEALER_PARTY_PRI = Healer_Data[me]["HEALER_PARTY_PRI"];
			HEALER_PARTYPET_PRI = Healer_Data[me]["HEALER_PARTYPET_PRI"];
			HEALER_RAID_PRI = Healer_Data[me]["HEALER_RAID_PRI"];
			HEALER_RAIDPET_PRI = Healer_Data[me]["HEALER_RAIDPET_PRI"];
			HEALER_HEAL_CLASSES = Healer_Data[me]["HEALER_HEAL_CLASSES"];
			HEALER_BUFF_CLASSES = Healer_Data[me]["HEALER_BUFF_CLASSES"];
			HEALER_AUTOHEAL = Healer_Data[me]["HEALER_AUTOHEAL"];
			HEALER_AUTOBUFF = Healer_Data[me]["HEALER_AUTOBUFF"];
			HEALER_AUTODEBUFF = Healer_Data[me]["HEALER_AUTODEBUFF"];
			HEALER_MAX_OVERHEAL = Healer_Data[me]["HEALER_MAX_OVERHEAL"];
			HEALER_ANNOUNCE_OOM = Healer_Data[me]["HEALER_ANNOUNCE_OOM"];
			HEALER_ANNOUNCE_NOT_READY = Healer_Data[me]["HEALER_ANNOUNCE_NOT_READY"];
			HEALER_ANNOUNCE_OUT_OF_REACH = Healer_Data[me]["HEALER_ANNOUNCE_OUT_OF_REACH"];
			HEALER_ANNOUNCE_NOBODY_NEEDS = Healer_Data[me]["HEALER_ANNOUNCE_NOBODY_NEEDS"];
			HEALER_ANNOUNCE_ACTION = Healer_Data[me]["HEALER_ANNOUNCE_ACTION"];
			HEALER_ANNOUNCE_GOT_BUFF = Healer_Data[me]["HEALER_ANNOUNCE_GOT_BUFF"];
			HEALER_ANNOUNCE_OVERHEALING = Healer_Data[me]["HEALER_ANNOUNCE_OVERHEALING"];
			HEALER_ANNOUNCE_AUTOCASTING = Healer_Data[me]["HEALER_ANNOUNCE_AUTOCASTING"];
			HEALER_DEBUFF_RAID = Healer_Data[me]["HEALER_DEBUFF_RAID"];
			HEALER_BUFF_RAID = Healer_Data[me]["HEALER_BUFF_RAID"];
			HEALER_HEAL_RAID = Healer_Data[me]["HEALER_HEAL_RAID"];
			HEALER_AUTODEBUFF_RAID = Healer_Data[me]["HEALER_AUTODEBUFF_RAID"];
			HEALER_AUTOBUFF_RAID = Healer_Data[me]["HEALER_AUTOBUFF_RAID"];
			HEALER_BUFF_PETS = Healer_Data[me]["HEALER_BUFF_PETS"];
			HEALER_DEBUFF_PETS = Healer_Data[me]["HEALER_DEBUFF_PETS"];
			HEALER_CHANNEL = Healer_Data[me]["HEALER_CHANNEL"];
			HEALER_CAST_BUFF_IN_BATTLE = Healer_Data[me]["HEALER_CAST_BUFF_IN_BATTLE"];
			HEALER_CAST_SELFBUFF_IN_BATTLE = Healer_Data[me]["HEALER_CAST_SELFBUFF_IN_BATTLE"];
			HEALER_AUTOBUFF_TARGET = Healer_Data[me]["HEALER_AUTOBUFF_TARGET"];
			HEALER_SHOW_HEALBARS = Healer_Data[me]["HEALER_SHOW_HEALBARS"];
			HEALER_SHOW_ONLY_ME = Healer_Data[me]["HEALER_SHOW_ONLY_ME"];
			HEALER_COOPERATIVE_HEALING = Healer_Data[me]["HEALER_COOPERATIVE_HEALING"];
			HEALER_MOUSE_HEALCLASSES = Healer_Data[me]["HEALER_MOUSE_HEALCLASSES"];
			HEALER_SHOW_DOTBARS = Healer_Data[me]["HEALER_SHOW_DOTBARS"];
			NUKER_NUKE_CLASSES = Healer_Data[me]["NUKER_NUKE_CLASSES"];
			HEALER_AVOID_SPIRIT_TAP = Healer_Data[me]["HEALER_AVOID_SPIRIT_TAP"];
			HEALER_SHOW_WHO_CLICK_MINIMAP = Healer_Data[me]["HEALER_SHOW_WHO_CLICK_MINIMAP"];
			HEALER_WHISPERCAST = Healer_Data[me]["HEALER_WHISPERCAST"];
			HEALER_WHISPERNOCAST = Healer_Data[me]["HEALER_WHISPERNOCAST"];
			HEALER_WCBLACKLIST = Healer_Data[me]["HEALER_WCBLACKLIST"];
			HEALER_WCDISABLED = Healer_Data[me]["HEALER_WCDISABLED"];
			HEALER_STATUS_BAR_HIDE_BUFFS = Healer_Data[me]["HEALER_STATUS_BAR_HIDE_BUFFS"];
			HEALER_STATUS_BAR_HIDE_DEBUFFS = Healer_Data[me]["HEALER_STATUS_BAR_HIDE_DEBUFFS"];
			HEALER_STATUS_BAR_HIDE_OVERHEAL = Healer_Data[me]["HEALER_STATUS_BAR_HIDE_OVERHEAL"];
		end
		if (not HEALER_HEAL_CLASSES) then
			-- probably a new user. set up some default stuff
			Healer_Print("Healer: Hi there, you seem to be a new user. Write \"/healer\" to set up this addon :)");
			HEALER_HEAL_RAID = 1;
			HEALER_BUFF_RAID = 1;
			HEALER_BUFF_PETS = 1;
			HEALER_AUTOBUFF_RAID = 1;
			HEALER_DEBUFF_RAID = 1;
			HEALER_AUTODEBUFF = 1;
			HEALER_AUTODEBUFF_RAID = 1;
			HEALER_ANNOUNCE_ACTION = 2;
			HEALER_ANNOUNCE_OVERHEALING = 2;
			HEALER_ANNOUNCE_OOM = 2;
			HEALER_ANNOUNCE_NOT_READY = 2;
			HEALER_ANNOUNCE_OUT_OF_REACH = 2;
			HEALER_CAST_SELFBUFF_IN_BATTLE = 1;
			HEALER_SHOW_HEALBARS = 1;
			if (UnitClass("player") ~= CLASS_DRUID and UnitClass("player") ~= CLASS_PRIEST and UnitClass("player") ~= CLASS_PALADIN and UnitClass("player") ~= CLASS_SHAMAN) then
				-- we're not a healer, show only healbars for people healing us
				-- show dotbars by default as well :)
				HEALER_SHOW_ONLY_ME = 1;
				HEALER_SHOW_DOTBARS = 1;
			end
			HEALER_COOPERATIVE_HEALING = 1;
			
			HEALER_HEAL_CLASSES = {};
			if (GetLocale() == "enUS") then
				HEALER_HEAL_CLASSES = {
					["standard"] = {
						["Healing Touch"] = 0.75,
						[SPELL_REJUVENATION] = 0.9,
						["Holy Light"] = 0.8,
						["Lesser Heal"] = 0.75,
						["Heal"] = 0.75,
						["Greater Heal"] = 0.75,
						[SPELL_RENEW] = 0.9,
						["Healing Wave"] = 0.8,
						[SPELL_BOP] = 0.1
					},
					["battle"] = {
						[SPELL_REJUVENATION] = 0.9,
						[SPELL_REGROWTH] = 0.75,
						["Flash of Light"] = 0.8,
						["Flash Heal"] = 0.75,
						[SPELL_PWS] = 0.3,
						[SPELL_RENEW] = 0.9,
						["Lesser Healing Wave"] = 0.8,
						[SPELL_BOP] = 0.1
					},
					["instant"] = {
						[SPELL_REJUVENATION] = 0.9,
						[SPELL_RENEW] = 0.9,
						[SPELL_PWS] = 0.1,
						[SPELL_BOP] = 0.1
					}
				};
				if (UnitClass("player") == CLASS_SHAMAN) then
					HEALER_HEAL_CLASSES["chainheal"] = {
						["Chain Heal"] = 0.75
					};
				end
				Healer_Save();
			end
		end
		if (not HEALER_BUFF_CLASSES) then
			HEALER_BUFF_CLASSES = {};
		end
		if (not HEALER_PLAYER_PRI) then
			HEALER_PLAYER_PRI = 1.0;
		end
		if (not HEALER_PARTY_PRI) then
			HEALER_PARTY_PRI = 0.9;
		end
		if (not HEALER_PARTYPET_PRI) then
			HEALER_PARTYPET_PRI = 0.7;
		end
		if (not HEALER_RAID_PRI) then
			HEALER_RAID_PRI = 0.8;
		end
		if (not HEALER_RAIDPET_PRI) then
			HEALER_RAIDPET_PRI = 0.6;
		end
		if (not HEALER_MAX_OVERHEAL) then
			HEALER_MAX_OVERHEAL = 0.25;
		end
		if (not HEALER_DEBUFF_NEW) then
			HEALER_DEBUFF_NEW = {};
		end
		if (not HEALER_DEBUFF_LIST) then
			HEALER_DEBUFF_LIST = {};
		end
		if (not HEALER_MOUSE_HEALCLASSES) then
			HEALER_MOUSE_HEALCLASSES = {};
		end
		if (not NUKER_NUKE_CLASSES) then
			NUKER_NUKE_CLASSES = {};
		end
		if (SPELLIMMUNESELFOTHER) then
			NUKER_IMMUNE = string.gsub(SPELLIMMUNESELFOTHER, "(%%s)", "%(%.%+%)");
			NUKER_IMMUNE = string.gsub(NUKER_IMMUNE, "(%%%d$s)", "%(%.%+%)");
		end
	elseif (event == "SPELLCAST_START" and arg2) then
		if (HEALER_IN_BATTLE) then
			HEALER_IN_BATTLE = 120;
		end
		HEALER_DOING_SOMETHING = 1;
		-- we need to clear the cache due to a regrowth feature
		if(Healer_UseOldChecks) then HEALER_BUFF_CACHE = {};end;
		if (HEALER_CHANNEL and HEALER_ACTION) then
			local message = "[Healer]: Update, na, 0, 0, " .. arg2 / 1000.0;
			SendChatMessage(message, "CHANNEL", LANGUAGE_COMMON, GetChannelName(HEALER_CHANNEL));
		end
		if (HEALER_ACTION and HEALER_ACTION["Name"] and CastingBarText:GetText()) then
			CastingBarText:SetText(CastingBarText:GetText() .. " -> " .. HEALER_ACTION["Name"]);
		end
	elseif (event == "SPELLCAST_DELAYED" and arg1) then
		if (HEALER_IN_BATTLE) then
			HEALER_IN_BATTLE = 120;
		end
		if (HEALER_CHANNEL and HEALER_ACTION) then
			local message = "[Healer]: Delay, na, 0, 0, " .. arg1 / 1000.0;
			HEALER_ACTION["Curtime"] = HEALER_ACTION["Curtime"] + arg1 / 1000.0
			SendChatMessage(message, "CHANNEL", LANGUAGE_COMMON, GetChannelName(HEALER_CHANNEL));
		end
	elseif (event == "SPELLCAST_STOP" or event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED") then
		HEALER_CHECK_SITTING = 1;
		if (HEALER_IN_BATTLE) then
			HEALER_IN_BATTLE = 120;
		end
		if (HEALER_CHANNEL and (HEALER_ACTION or event ~= "SPELLCAST_STOP")) then
			-- let the others know we stopped spellcasting
			local message = "[Healer]: ";
			if (event == "SPELLCAST_STOP") then
				message = message .. "Stop, ";
			elseif (event == "SPELLCAST_FAILED") then
				message = message .. "Fail, ";
			elseif (event == "SPELLCAST_INTERRUPTED") then
				message = message .. "Interrupt, ";
			end
			message = message .. "na, 0, 0, 0";
			SendChatMessage(message, "CHANNEL", LANGUAGE_COMMON, GetChannelName(HEALER_CHANNEL));
		end
		if (HEALER_DOING_SOMETHING) then
			HEALER_ACTION = nil;
		end
		HEALER_DOING_SOMETHING = nil;
	elseif (event == "PLAYER_REGEN_ENABLED") then
		HEALER_IN_BATTLE = nil;
	elseif (event == "PLAYER_REGEN_DISABLED") then
		HEALER_IN_BATTLE = 120;
	elseif (event == "LEARNED_SPELL_IN_TAB") then
		-- we just learned a new spell
		HEALER_HAS_CHECKED_SPELLBOOK = nil;
	elseif (event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" or event == "CHAT_MSG_COMBAT_XP_GAIN") then
		local start, stop, who = string.find(arg1, DIE_TEXT);
		if (who) then
			if (HEALER_SHOW_DOTBARS) then
				for person, healers in HEALER_BEING_HEALED do
					if (who == person) then
						for healer, data in healers do
							HEALER_BEING_HEALED[person][healer]["Curtime"] = 0;
						end
					end
				end
			end
			for nukeclass, nukedata in NUKER_NUKE_CLASSES do
				for priority, data in nukedata do
					if (data["Targets"][who] and (not UnitExists("target") or UnitName("target") ~= who or UnitHealth("target") <= 1)) then
						NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][who] = nil;
					end
				end
			end
		end
	elseif ((event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" or event == "CHAT_MSG_SPELL_SELF_DAMAGE") and HEALER_SHOW_DOTBARS) then
		local start, stop, who, debuff = string.find(arg1, AFFLICT_TEXT);
		if (not who or not debuff) then
			start, stop, debuff, who = string.find(arg1, HIT_TEXT);
		end
		if (who and HEALER_DOTS[debuff]) then
			local ok;
			for person, healers in HEALER_BEING_HEALED do
				if (who == person) then
					for healer, data in healers do
						if (debuff .. " -> " .. who == healer) then
							HEALER_BEING_HEALED[person][healer]["Curtime"] = HEALER_DOTS[debuff];
							ok = 1;
						end
					end
				end
			end
			if (not ok) then
				if (not HEALER_BEING_HEALED[who]) then
					HEALER_BEING_HEALED[who] = {};
				end
				HEALER_BEING_HEALED[who][debuff .. " -> " .. who] = {
					["Action"] = "DOT",
					["Value"] = "-1",
					["Casttime"] = HEALER_DOTS[debuff],
					["Curtime"] = HEALER_DOTS[debuff]
				};
				for a = 1, 7 do
					if (not HEALER_OTHER_HEALERS[a] or HEALER_OTHER_HEALERS[a] == debuff) then
						HEALER_OTHER_HEALERS[a] = debuff .. " -> " .. who;
						getglobal("HealerBar" .. a .. "FrameStatusBar"):SetMinMaxValues(0, HEALER_DOTS[debuff]);
						getglobal("HealerBar" .. a .. "Text"):SetText(debuff .. " -> " .. who);
						getglobal("HealerBar" .. a):SetAlpha(1.0);
						getglobal("HealerBar" .. a .. "FrameStatusBar"):SetStatusBarColor(0.0, 1.0, 0.0);
						getglobal("HealerBar" .. a .. "FrameStatusBar"):SetValue(HEALER_DOTS[debuff]);
						getglobal("HealerBar" .. a .. "Spark"):SetPoint("CENTER", getglobal("HealerBar" .. a .. "FrameStatusBar"), "LEFT", 195, 0);
						getglobal("HealerBar" .. a):Show();
						return;
					end
				end
			end
		end
	elseif (event == "MINIMAP_PING") then
		if (HEALER_SHOW_WHO_CLICK_MINIMAP and arg1 and (not HEALER_LAST_MINIMAP_CLICK or HEALER_LAST_MINIMAP_CLICK ~= arg1)) then
			HEALER_LAST_MINIMAP_CLICK = arg1;
			Healer_Print(UnitName(arg1) .. " clicked on the minimap");
		end
	end
end

function Healer_OnUpdate(arg1)
	--Healer_BuffChecksOnUpdate(arg1)
	Healer_HealerUpdateStatusBar();
	Healer_OverhealDetected=false;

	if (not HEALER_HAS_CHECKED_SPELLBOOK) then
		-- to prevent a bunch of errors
		return;
	end
	if (HEALER_ACTION and HEALER_ACTION["Curtime"]) then
		HEALER_ACTION["Curtime"] = HEALER_ACTION["Curtime"] - arg1;
		if (HEALER_ACTION["Curtime"] < -5) then
			-- somehow HEALER_ACTION wasn't erased when it should've been
			HEALER_ACTION = nil;
		end
	end
	if (HEALER_IN_BATTLE) then
		HEALER_IN_BATTLE = HEALER_IN_BATTLE - arg1;
		if (HEALER_IN_BATTLE < 0) then
			HEALER_IN_BATTLE = nil;
		end
	end
	for unit, bantime in HEALER_REVIVE_BAN do
		HEALER_REVIVE_BAN[unit] = bantime - arg1;
		if (HEALER_REVIVE_BAN[unit] <= 0) then
			HEALER_REVIVE_BAN[unit] = nil;
		end
	end

	for nukeclass, nukedata in NUKER_NUKE_CLASSES do
		if (NUKER_NUKECLASS and NUKER_NUKECLASS == nukeclass) then
			local target = "none";
			local debuffs;
			local nextset;
			if (UnitExists("target")) then
				target = UnitName("target");
				debuffs = Healer_GetDebuffs("target");
			end
			local keepbars;
			local maxpriority = 1;
			for priority, data in nukedata do
				maxpriority = priority;
				local interval;
				local timeleft;
				if (data["Ability"]) then
					interval = data["Interval"];
					if (data["Targets"] and data["Targets"][target]) then
						timeleft = data["Targets"][target]["TimeLeft"];
					end
				end
				local gotdebuff = ((data["CheckDebuff"] and debuffs and debuffs[data["Ability"]]) or (debuffs and debuffs[SPELL_BANISH]));
				if(not data["CheckDebuff"]) then gotdebuff=true;end;
				local spellstart, spellduration = GetSpellCooldown(NUKER_NUKES[data["Ability"]][1]["ID"], 1);
				local cooldown = spellduration + spellstart - GetTime();
				if (timeleft and timeleft > cooldown and gotdebuff) then
					cooldown = timeleft;
				end
				if (cooldown < 0) then
					cooldown = 0;
				end
				local bar = getglobal("NukerAbility" .. priority);
				local bartext = getglobal("NukerAbility" .. priority .. "Text");
				local maxvalue;
				if (interval and timeleft and gotdebuff) then
					keepbars = 1;
					maxvalue = interval;
				elseif (spellduration) then
					maxvalue = spellduration;
				else
					maxvalue = 1.5;
				end
				bar:SetMinMaxValues(0, maxvalue);
				bar:SetValue(cooldown);
				bartext:SetText(data["Ability"]);
				bartext:SetVertexColor(1.0, 0.0, 0.0);
				if ((not timeleft or timeleft <= 3600) and cooldown <= 0 and (not gotdebuff or data["Interval"]) and UnitMana("player") >= NUKER_NUKES[data["Ability"]][1]["Cost"]) then
					if (nextset) then
						-- ability that's ready
						bartext:SetVertexColor(0.0, 1.0, 0.0);
					else
						-- next ability to be used
						if (not NUKER_FLASH) then
							bartext:SetVertexColor(1.0, 1.0, 1.0);
							NUKER_FLASH = 1;
						elseif (NUKER_FLASH > 0.5) then
							bartext:SetVertexColor(1.0, 1.0, 1.0);
						else
							bartext:SetVertexColor(0.0, 0.0, 0.0);
						end
						NUKER_FLASH = NUKER_FLASH - arg1;
						if (NUKER_FLASH < 0) then
							NUKER_FLASH = nil;
						end
						bar:SetMinMaxValues(0, maxvalue);
						bar:SetValue(maxvalue);
					end
					nextset = 1;
				elseif (timeleft and timeleft > 3600 and not gotdebuff) then
					-- target is immune to this ability
					bartext:SetVertexColor(0.0, 0.0, 1.0);
				elseif ((cooldown <= 0 and gotdebuff) or (timeleft and spellstart == 0)) then
					-- spell is ready, but we don't want to use it yet
					bartext:SetVertexColor(0.5, 0.5, 0.5);
				end
				bar:Show();
				NukerAbilities:SetAlpha(1.0);
				NukerAbilities:Show();
			end
			if (not keepbars and NUKER_FADE) then
				-- all bars are ready, fade it out after a certain time
				NUKER_FADE = NUKER_FADE - arg1;
				if (NUKER_FADE < 0) then
					if (NUKER_FADE < -1) then
						-- time to hide the bars
						NukerAbilities:Hide();
					else
						-- just fade
						NukerAbilities:SetAlpha(NUKER_FADE + 1);
					end
				end
			elseif (keepbars) then
				-- some bars are busy, don't fade the bars
				NUKER_FADE = 15;
			end
			while (maxpriority < 10) do
				maxpriority = maxpriority + 1;
				getglobal("NukerAbility" .. maxpriority):Hide();
			end
		end
		for priority, data in nukedata do
			for target, targetdata in data["Targets"] do
				local gotdebuff = Healer_GotDebuff("target", data["Ability"]);
				if(not data["CheckDebuff"]) then gotdebuff=true;end;
				if (targetdata["TimeLeft"]) then
					local spellstart, spellduration = GetSpellCooldown(NUKER_NUKES[data["Ability"]][1]["ID"], 1);
					if (spellstart == 0 and UnitExists("target") and not UnitIsDead("target") and UnitName("target") == target and targetdata["Seen"] and not gotdebuff) then
						NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"] = nil;
					else
						NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"] = targetdata["TimeLeft"] - arg1;
						if (NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"] <= 0) then
							NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"] = nil;
						end
					end
				end
				if (UnitExists("target") and (not data["CheckDebuff"] or (targetdata["Seen"] and not gotdebuff)) and not NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"]) then
					NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target] = nil;
				end
			end
			if (not NUKER_NUKECLASS) then
				getglobal("NukerAbility" .. priority):Hide();
			end
		end
	end
	if (UnitExists("target") and not UnitIsFriend("player", "target")) then
		-- check for debuffs
		local debuffs = Healer_GetDebuffs("target");
		if (debuffs) then
			local who = UnitName("target");
			for debuff, index in debuffs do
				for nukeclass, nukedata in NUKER_NUKE_CLASSES do
					for priority, data in nukedata do
						for target, targetdata in data["Targets"] do
							if (data["Ability"] == debuff and not NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["Seen"]) then
								NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["Seen"] = 1;
							end
						end
					end
				end
				local gotbaralready;
				if (HEALER_SHOW_DOTBARS) then
					for a = 1, 7 do
						if (HEALER_OTHER_HEALERS[a] == debuff .. " -> " .. who) then
							gotbaralready = 1;
							if (not HEALER_BEING_HEALED[who][debuff .. " -> " .. who]["Seen"]) then
								HEALER_BEING_HEALED[who][debuff .. " -> " .. who]["Seen"] = 1;
							end
							a = 8;
						end
					end
					if (not gotbaralready and HEALER_DOTS[debuff]) then
						if (not HEALER_BEING_HEALED[who]) then
							HEALER_BEING_HEALED[who] = {};
						end
						HEALER_BEING_HEALED[who][debuff .. " -> " .. who] = {
							["Action"] = "DOT",
							["Value"] = "-1",
							["Casttime"] = HEALER_DOTS[debuff],
							["Curtime"] = HEALER_DOTS[debuff],
							["Seen"] = 1
						};
						for a = 1, 7 do
							if (not HEALER_OTHER_HEALERS[a] or HEALER_OTHER_HEALERS[a] == debuff) then
								HEALER_OTHER_HEALERS[a] = debuff .. " -> " .. who;
								getglobal("HealerBar" .. a .. "FrameStatusBar"):SetMinMaxValues(0, HEALER_DOTS[debuff]);
								getglobal("HealerBar" .. a .. "Text"):SetText(debuff .. " -> " .. who);
								getglobal("HealerBar" .. a):SetAlpha(1.0);
								getglobal("HealerBar" .. a .. "FrameStatusBar"):SetStatusBarColor(0.0, 1.0, 0.0);
								getglobal("HealerBar" .. a):Show();
								a = 8;
							end
						end
					end
				end
			end
		end
	end
	for person, healers in HEALER_BEING_HEALED do
		local diealready;
		for healer, data in healers do
			diealready = 1;
			HEALER_BEING_HEALED[person][healer]["Curtime"] = data["Curtime"] - arg1;
			local start, stop, debuff, lad = string.find(healer, "(.+) %-> (.+)");
			for a = 1, 7 do
				if (HEALER_OTHER_HEALERS[a] == healer) then
					local curtime = HEALER_BEING_HEALED[person][healer]["Curtime"];
					if (curtime < 0) then
						curtime = 0;
					end
					if (HEALER_BEING_HEALED[person][healer]["Action"] == "DOT") then
						if (UnitExists("target") and not UnitIsFriend("player", "target")) then
							local who = UnitName("target");
							if (who == person and HEALER_BEING_HEALED[person][healer]["Seen"] and curtime > 0 and not Healer_GotDebuff("target", debuff)) then
								-- seems like our target lost the debuff...?
								curtime = 0;
								HEALER_BEING_HEALED[person][healer]["Curtime"] = 0;
							end
						end
						local sparkpos = curtime / HEALER_BEING_HEALED[person][healer]["Casttime"] * 195;
						local green = curtime / HEALER_BEING_HEALED[person][healer]["Casttime"];
						local red = (HEALER_BEING_HEALED[person][healer]["Casttime"] - curtime) / HEALER_BEING_HEALED[person][healer]["Casttime"];
						getglobal("HealerBar" .. a .. "FrameStatusBar"):SetValue(curtime);
						getglobal("HealerBar" .. a .. "Spark"):SetPoint("CENTER", getglobal("HealerBar" .. a .. "FrameStatusBar"), "LEFT", sparkpos, 0);
						getglobal("HealerBar" .. a .. "FrameStatusBar"):SetStatusBarColor(red, green, 0.0);
						if (curtime >= 0) then
							getglobal("HealerBar" .. a):SetAlpha(1.0);
						end
					else
						local sparkpos = (HEALER_BEING_HEALED[person][healer]["Casttime"] - curtime) / HEALER_BEING_HEALED[person][healer]["Casttime"] * 195;
						getglobal("HealerBar" .. a .. "FrameStatusBar"):SetValue(HEALER_BEING_HEALED[person][healer]["Casttime"] - curtime);
						getglobal("HealerBar" .. a .. "Spark"):SetPoint("CENTER", getglobal("HealerBar" .. a .. "FrameStatusBar"), "LEFT", sparkpos, 0);
						if (curtime >= 0) then
							getglobal("HealerBar" .. a):SetAlpha(1.0);
						end
					end
					-- stop the loop
					a = 8;
				end
			end
			if (HEALER_BEING_HEALED[person][healer]["Curtime"] < -1 and (HEALER_BEING_HEALED[person][healer]["Action"] ~= "DOT" or not Healer_GotDebuff("target", debuff))) then
				for a = 1, 7 do
					if (HEALER_OTHER_HEALERS[a] == healer) then
						-- fade it
						local alpha = HEALER_BEING_HEALED[person][healer]["Curtime"] + 2;
						if (alpha < 0) then
							alpha = 0;
						elseif (alpha > 1) then
							alpha = 1;
						end
						getglobal("HealerBar" .. a):SetAlpha(alpha);
						if (HEALER_BEING_HEALED[person][healer]["Curtime"] < -2) then
							-- hide it
							HEALER_OTHER_HEALERS[a] = nil;
							getglobal("HealerBar" .. a):Hide();
						end
						-- stop the loop
						a = 8;
					end
				end
				if (HEALER_BEING_HEALED[person][healer]["Curtime"] < -2) then
					HEALER_BEING_HEALED[person][healer] = nil;
					local anotherhealer;
					for a, b in HEALER_BEING_HEALED[person] do
						anotherhealer = 1;
					end
					if (not anotherhealer) then
						-- nobody healing this person
						HEALER_BEING_HEALED[person] = nil;
					end
				end
			end
		end
		if (not diealready) then
			-- argh, this one refuse to go away :\
			HEALER_BEING_HEALED[person] = nil;
		end
	end
	if (not HEALER_MAX_OVERHEAL or not HEALER_DOING_SOMETHING or not HEALER_ACTION or HEALER_ACTION["Heal"] == 0 or HEALER_AUTOCASTING) then
		-- we're not currently healing, just return
		return;
	end
	local tmpperson = HEALER_ACTION["Person"];
	if (not tmpperson) then
		return;
	end
	if (tmpperson == "target" and HEALER_ACTION["AKA"]) then
		tmpperson = HEALER_ACTION["AKA"];
	end
	-- now how should we handle the different situations?
	local extrahp = 0;
	if (HEALER_ACTION["Person"] == "target" and HEALER_ACTION["AKA"]) then
		-- we're target-healing someone in our party/raid
		-- we should only cancel just before the spell completes
		if (HEALER_ACTION["Spell"] == SPELL_REGROWTH and not Healer_GotBuff("target", SPELL_REGROWTH)) then
			return;
		end
	elseif (HEALER_ACTION["TankUnit"] and HEALER_ACTION["Person"] == HEALER_ACTION["TankUnit"]) then
		-- we're doing some dedicated healing. do not cancel before the very end :)
		if (HEALER_ACTION["Spell"] == SPELL_REGROWTH and not Healer_GotBuff(HEALER_ACTION["TankUnit"], SPELL_REGROWTH)) then
			return;
		end
	elseif ((HEALER_ACTION["Person"] == "target" or HEALER_ACTION["Person"] == "mouseover") and not HEALER_ACTION["AKA"]) then
		-- we're target-healing someone not in out party/raid
		-- we should cancel as soon as possible, as we might change target & screw stuff up
		-- don't return so we will stop the spellcasting
		if (HEALER_ACTION["Spell"] == SPELL_REGROWTH and not HEALER_ACTION["GotBuff"]) then
			-- well, since we're casting regrowth and the target doesn't seem to have it, let's cast afterall :p
			return;
		elseif (UnitName(HEALER_ACTION["Person"]) ~= HEALER_ACTION["Name"]) then
			-- changed target. we can't risk that the player will be healed by someone else, don't cancel
			return;
		end
	else
		-- we're just healing someone in our party/raid
		-- let's see if there's someone else healing the same person we're healing
		-- and if they will finish before us and heal enough then we should cancel
		if (HEALER_COOPERATIVE_HEALING and HEALER_ACTION["Person"] and HEALER_BEING_HEALED[HEALER_ACTION["Person"]]) then 
			for healer, data in HEALER_BEING_HEALED[HEALER_ACTION["Person"]] do
				if (healer ~= UnitName("player")) then
					if (data["Action"] == "Healing") then
						if (data["Curtime"] + 50 < HEALER_ACTION["Curtime"]) then
							-- another healer will finish "way" before us, let's cancel
							extrahp = extrahp + data["Value"];
						end
					end
				end
			end
		end
	end
	local uhm = UnitHealthMax(tmpperson);
	local uh = UnitHealth(tmpperson);
	if (uhm == 100) then
		-- most likely got percent, not actual values
		uhm = uhm * UnitLevel(tmpperson) * HEALER_HEAL_MULTIPLY[UnitClass(tmpperson)];
		uh = uh * UnitLevel(tmpperson) * HEALER_HEAL_MULTIPLY[UnitClass(tmpperson)];
	end
	uh = uh + extrahp;
	if (uh > uhm) then
		uh = uhm;
	end
	if (uh + HEALER_ACTION["Heal"] - uhm <= HEALER_ACTION["Heal"] * HEALER_MAX_OVERHEAL) then
		-- more healing than overhealing, don't cancel
		return;
	end
	local overhealing = math.floor((uh + HEALER_ACTION["Heal"] - uhm) / HEALER_ACTION["Heal"] * 1000 + 0.5) / 10.0;
	-- if we've gotten this far, we should stop casting this spell as someone healed our target
	Healer_OverhealDetected = true;
	--SpellStopCasting(); --removed for 1.10
	--if (UnitExists(tmpperson)) then
		--Healer_OverhealCancelMessage="Spell canceled, " .. UnitName(tmpperson) .. " was about to be overhealed for " .. overhealing .. "%";
		--Healer_Announce("|cffead9ac", "Spell canceled, " .. UnitName(tmpperson) .. " was about to be overhealed for " .. overhealing .. "%", HEALER_ANNOUNCE_OVERHEALING, HEALER_HEAL_RAID);
	--else
	--	Healer_OverhealCancelMessage="Spell canceled, we lost our target";
	--end
end

function Healer_Save()
	if (not Healer_Data) then
		Healer_Data = {};
	end
	local me = UnitName("player");
	Healer_Data[me] = {
		["HEALER_PLAYER_PRI"] = HEALER_PLAYER_PRI,
		["HEALER_PARTY_PRI"] = HEALER_PARTY_PRI,
		["HEALER_PARTYPET_PRI"] = HEALER_PARTYPET_PRI,
		["HEALER_RAID_PRI"] = HEALER_RAID_PRI,
		["HEALER_RAIDPET_PRI"] = HEALER_RAIDPET_PRI,
		["HEALER_HEAL_CLASSES"] = HEALER_HEAL_CLASSES,
		["HEALER_BUFF_CLASSES"] = HEALER_BUFF_CLASSES,
		["HEALER_AUTOHEAL"] = HEALER_AUTOHEAL,
		["HEALER_AUTOBUFF"] = HEALER_AUTOBUFF,
		["HEALER_AUTODEBUFF"] = HEALER_AUTODEBUFF,
		["HEALER_MAX_OVERHEAL"] = HEALER_MAX_OVERHEAL,
		["HEALER_ANNOUNCE_OOM"] = HEALER_ANNOUNCE_OOM,
		["HEALER_ANNOUNCE_NOT_READY"] = HEALER_ANNOUNCE_NOT_READY,
		["HEALER_ANNOUNCE_OUT_OF_REACH"] = HEALER_ANNOUNCE_OUT_OF_REACH,
		["HEALER_ANNOUNCE_NOBODY_NEEDS"] = HEALER_ANNOUNCE_NOBODY_NEEDS,
		["HEALER_ANNOUNCE_ACTION"] = HEALER_ANNOUNCE_ACTION,
		["HEALER_ANNOUNCE_GOT_BUFF"] = HEALER_ANNOUNCE_GOT_BUFF,
		["HEALER_ANNOUNCE_OVERHEALING"] = HEALER_ANNOUNCE_OVERHEALING,
		["HEALER_ANNOUNCE_AUTOCASTING"] = HEALER_ANNOUNCE_AUTOCASTING,
		["HEALER_DEBUFF_RAID"] = HEALER_DEBUFF_RAID,
		["HEALER_BUFF_RAID"] = HEALER_BUFF_RAID,
		["HEALER_HEAL_RAID"] = HEALER_HEAL_RAID,
		["HEALER_AUTODEBUFF_RAID"] = HEALER_AUTODEBUFF_RAID,
		["HEALER_AUTOBUFF_RAID"] = HEALER_AUTOBUFF_RAID,
		["HEALER_BUFF_PETS"] = HEALER_BUFF_PETS,
		["HEALER_DEBUFF_PETS"] = HEALER_DEBUFF_PETS,
		["HEALER_CHANNEL"] = HEALER_CHANNEL,
		["HEALER_CAST_BUFF_IN_BATTLE"] = HEALER_CAST_BUFF_IN_BATTLE,
		["HEALER_CAST_SELFBUFF_IN_BATTLE"] = HEALER_CAST_SELFBUFF_IN_BATTLE,
		["HEALER_AUTOBUFF_TARGET"] = HEALER_AUTOBUFF_TARGET,
		["HEALER_SHOW_HEALBARS"] = HEALER_SHOW_HEALBARS,
		["HEALER_SHOW_ONLY_ME"] = HEALER_SHOW_ONLY_ME,
		["HEALER_COOPERATIVE_HEALING"] = HEALER_COOPERATIVE_HEALING,
		["HEALER_MOUSE_HEALCLASSES"] = HEALER_MOUSE_HEALCLASSES,
		["HEALER_SHOW_DOTBARS"] = HEALER_SHOW_DOTBARS,
		["NUKER_NUKE_CLASSES"] = NUKER_NUKE_CLASSES,
		["HEALER_AVOID_SPIRIT_TAP"] = HEALER_AVOID_SPIRIT_TAP,
		["HEALER_SHOW_WHO_CLICK_MINIMAP"] = HEALER_SHOW_WHO_CLICK_MINIMAP,
		["HEALER_WHISPERCAST"] = HEALER_WHISPERCAST,
		["HEALER_WHISPERNOCAST"] = HEALER_WHISPERNOCAST,
		["HEALER_WCBLACKLIST"] = HEALER_WCBLACKLIST,
		["HEALER_WCDISABLED"] = HEALER_WCDISABLED,
		["HEALER_STATUS_BAR_HIDE_BUFFS"] = HEALER_STATUS_BAR_HIDE_BUFFS,
		["HEALER_STATUS_BAR_HIDE_DEBUFFS"] = HEALER_STATUS_BAR_HIDE_DEBUFFS,
		["HEALER_STATUS_BAR_HIDE_OVERHEAL"] = HEALER_STATUS_BAR_HIDE_OVERHEAL
	};
end

function Healer_ChatFrame_OnEvent()
	local tmp = HEALER_OLD_CHATFRAME(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
	if (arg1 and arg9 and (event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_RAID")) then
		local start, stop, channel = string.find(arg1, "%[Healer%]: The Healer channel is \"(.+)\"$");
		if (channel) then
			-- join a channel
			Healer_Cmd("join " .. channel);
			return tmp;
		end
	elseif (arg1 and arg2 and arg9 and HEALER_CHANNEL and HEALER_BEING_HEALED and string.lower(arg9) == string.lower(HEALER_CHANNEL) and Healer_UnitName(arg2)) then
		-- a message in the channel we're monitoring
		if (arg1 .. arg2 .. arg9 == HEALER_REPEATED_MESSAGE) then
			-- of some weird reason a message is repeated n times. highly annoying
			return tmp;
		end
		HEALER_REPEATED_MESSAGE = arg1 .. arg2 .. arg9;
		local start, stop, what, who, value, value2, casttime = string.find(arg1, "%[Healer%]: (.+), (.+), (%d+%.?%d*), (%d+%.?%d*), (%d+%.?%d*)");
		if (what and who and value and value2 and casttime) then
			value = value / 1.0;
			value2 = value2 / 1.0;
			casttime = casttime / 1.0;
			if (what == "Stop" or what == "Fail" or what == "Interrupt") then
				-- spellcasting stopped
				for person, healers in HEALER_BEING_HEALED do
					for healer, data in healers do
						if (healer == arg2) then
							HEALER_BEING_HEALED[person][healer]["Curtime"] = -0.5;
						end
					end
				end
				if (not HEALER_SHOW_HEALBARS) then
					return tmp;
				end
				for a = 1, 7 do
					if (HEALER_OTHER_HEALERS[a] == arg2) then
						if (what == "Stop") then
							getglobal("HealerBar" .. a .. "FrameStatusBar"):SetStatusBarColor(0.0, 1.0, 0.0);
						else
							if (what == "Fail") then
								getglobal("HealerBar" .. a .. "Text"):SetText("Failed");
							else
								getglobal("HealerBar" .. a .. "Text"):SetText("Interrupt");
							end
							getglobal("HealerBar" .. a .. "FrameStatusBar"):SetStatusBarColor(1.0, 0.0, 0.0);
						end
						return tmp;
					end
				end
				return tmp;
			elseif (what == "Delay") then
				-- spellcasting was delayed of some reason (healer was struck while casting?)
				for person, healers in HEALER_BEING_HEALED do
					for healer, data in healers do
						if (healer == arg2) then
							HEALER_BEING_HEALED[person][healer]["Curtime"] = data["Curtime"] + casttime;
							return tmp;
						end
					end
				end
				return tmp;
			elseif (what == "Update") then
				-- update the spellcasting in case something is causing the spell to take longer/shorter time than usual
				for person, healers in HEALER_BEING_HEALED do
					for healer, data in healers do
						if (healer == arg2) then
							HEALER_BEING_HEALED[person][healer]["Curtime"] = HEALER_BEING_HEALED[person][healer]["Curtime"] + casttime - HEALER_BEING_HEALED[person][healer]["Casttime"];
							HEALER_BEING_HEALED[person][healer]["Casttime"] = casttime;
							if (not HEALER_SHOW_HEALBARS) then
								return tmp;
							end
							for a = 1, 7 do
								if (HEALER_OTHER_HEALERS[a] == arg2) then
									getglobal("HealerBar" .. a .. "FrameStatusBar"):SetMinMaxValues(0, casttime);
									return tmp;
								end
							end
							return tmp;
						end
					end
				end
				return tmp;
			elseif (casttime > 0) then
				if (not HEALER_BEING_HEALED[who]) then
					HEALER_BEING_HEALED[who] = {};
				end
				for person, healers in HEALER_BEING_HEALED do
					for healer, data in healers do
						if (healer == arg2) then
							-- this healer just healed someone else, and fading out
							-- remove the fading out as it'll be replaced
							for a = 1, 7 do
								if (HEALER_OTHER_HEALERS[a] and HEALER_OTHER_HEALERS[a] == healer) then
									-- hide this frame
									getglobal("HealerBar" .. a):Hide();
									HEALER_OTHER_HEALERS[a] = nil;
								end
							end
							HEALER_BEING_HEALED[person][healer] = nil;
						end
					end
				end
				HEALER_BEING_HEALED[who][arg2] = {
					["Action"] = what,
					["Value"] = value,
					["Casttime"] = casttime,
					["Curtime"] = casttime
				};
				if (not HEALER_SHOW_HEALBARS) then
					return tmp;
				end
				if (arg2 == UnitName("player")) then
					-- don't show a bar for our own healing
					return tmp;
				end
				if (HEALER_SHOW_ONLY_ME and (who ~= UnitName("player") and who ~= UnitName("pet"))) then
					-- i only want to see people healing me or my pet
					return tmp;
				end
				for a = 1, 7 do
					if (not HEALER_OTHER_HEALERS[a] or HEALER_OTHER_HEALERS[a] == arg2) then
						HEALER_OTHER_HEALERS[a] = arg2;
						getglobal("HealerBar" .. a .. "FrameStatusBar"):SetMinMaxValues(0, casttime);
						local text = arg2;
						if (value2 and value2 > 0) then
							text = text .. "(" .. math.floor(value2 + 0.5) .. ")";
						end
						text = text .. " -> " .. who;
						getglobal("HealerBar" .. a .. "Text"):SetText(text);
						getglobal("HealerBar" .. a):Show();
						getglobal("HealerBar" .. a):SetAlpha(1.0);
						if (what == "Healing") then
							getglobal("HealerBar" .. a .. "FrameStatusBar"):SetStatusBarColor(1.0, 0.7, 0.0);
						elseif (what == "Reviving") then
							getglobal("HealerBar" .. a .. "FrameStatusBar"):SetStatusBarColor(0.0, 0.7, 1.0);
						end
						return tmp;
					end
				end
				return tmp;
			end
		end
	elseif (NUKER_NUKECLASS and arg1 and NUKER_IMMUNE) then
		local start, stop, ability, target = string.find(arg1, NUKER_IMMUNE);
		for priority, data in NUKER_NUKE_CLASSES[NUKER_NUKECLASS] do
			if (data["Ability"] == ability) then
				if (not NUKER_NUKE_CLASSES[NUKER_NUKECLASS][priority]["Targets"]) then
					NUKER_NUKE_CLASSES[NUKER_NUKECLASS][priority]["Targets"] = {};
				end
				if (not NUKER_NUKE_CLASSES[NUKER_NUKECLASS][priority]["Targets"][target]) then
					NUKER_NUKE_CLASSES[NUKER_NUKECLASS][priority]["Targets"][target] = {};
				end
				NUKER_NUKE_CLASSES[NUKER_NUKECLASS][priority]["Targets"][target]["TimeLeft"] = 17682;
			end
		end
	end
end

function HealerGUI_SetUp()
	-- just set up the values for the gui stuff
	-- heal tab
	HealerGUIMaxOverhealSlider:SetValue(HEALER_MAX_OVERHEAL * 100);
	if (HEALER_HEAL_RAID) then
		HealerGUIHealRaidCheckButton:SetChecked(1);
	else
		HealerGUIRaidPriority:Hide();
		HealerGUIRaidHealPrioritySlider:Hide();
		HealerGUIRaidHealPrioritySlider:Hide();
		HealerGUIRaidHealPrioritySliderValue:Hide();
		HealerGUIRaidpetPriority:Hide();
		HealerGUIRaidpetHealPrioritySlider:Hide();
		HealerGUIRaidpetHealPrioritySlider:Hide();
		HealerGUIRaidpetHealPrioritySliderValue:Hide();
	end
	if (HEALER_COOPERATIVE_HEALING) then
		HealerGUICooperativeHealingCheckButton:SetChecked(1);
	end
	if (HEALER_SHOW_HEALBARS) then
		HealerGUIShowHealbarsCheckButton:SetChecked(1);
	end
	if (HEALER_SHOW_ONLY_ME) then
		HealerGUIShowOnlyMeCheckButton:SetChecked(1);
	end
	HealerGUIPlayerHealPrioritySlider:SetValue(HEALER_PLAYER_PRI * 100);
	HealerGUIPartyHealPrioritySlider:SetValue(HEALER_PARTY_PRI * 100);
	HealerGUIPartypetHealPrioritySlider:SetValue(HEALER_PARTYPET_PRI * 100);
	HealerGUIRaidHealPrioritySlider:SetValue(HEALER_RAID_PRI * 100);
	HealerGUIRaidpetHealPrioritySlider:SetValue(HEALER_RAIDPET_PRI * 100);
	if (HEALER_MOUSE_HEALCLASSES[1]) then
		HealerGUIMousekey1HealclassButton:SetText(HEALER_MOUSE_HEALCLASSES[1]);
	end
	if (HEALER_MOUSE_HEALCLASSES[2]) then
		HealerGUIMousekey2HealclassButton:SetText(HEALER_MOUSE_HEALCLASSES[2]);
	end
	if (HEALER_MOUSE_HEALCLASSES[3]) then
		HealerGUIMousekey3HealclassButton:SetText(HEALER_MOUSE_HEALCLASSES[3]);
	end
	if (HEALER_MOUSE_HEALCLASSES[4]) then
		HealerGUIMousekey4HealclassButton:SetText(HEALER_MOUSE_HEALCLASSES[4]);
	end
	HealerGUIHealclassScrollBar_Update();
	HealerGUIHealspellScrollBar_Update();

	-- buff tab
	if (HEALER_BUFF_RAID) then
		HealerGUIBuffRaidCheckButton:SetChecked(1);
	end
	if (HEALER_BUFF_PETS) then
		HealerGUIBuffPetsCheckButton:SetChecked(1);
	end
	if (HEALER_AUTOBUFF_RAID) then
		HealerGUIAutobuffRaidCheckButton:SetChecked(1);
	end
	if (HEALER_CAST_BUFF_IN_BATTLE) then
		HealerGUICastBuffInBattleCheckButton:SetChecked(1);
	end
	if (HEALER_CAST_SELFBUFF_IN_BATTLE) then
		HealerGUICastSelfbuffInBattleCheckButton:SetChecked(1);
	end
	if (HEALER_AUTOBUFF_TARGET) then
		HealerGUIAutobuffTargetCheckButton:SetChecked(1);
	end
	HealerGUIBuffclassScrollBar_Update();
	HealerGUIBuffUnitScrollBar_Update();
	HealerGUIBuffspellScrollBar_Update();

	-- debuff tab
	if (HEALER_DEBUFF_RAID) then
		HealerGUIDebuffRaidCheckButton:SetChecked(1);
	end
	if (HEALER_DEBUFF_PETS) then
		HealerGUIDebuffPetsCheckButton:SetChecked(1);
	end
	if (HEALER_AUTODEBUFF) then
		HealerGUIAutodebuffCheckButton:SetChecked(1);
	end
	if (HEALER_AUTODEBUFF_RAID) then
		HealerGUIAutodebuffRaidCheckButton:SetChecked(1);
	end
	HealerGUIDebuffListScrollBar_Update();
	HealerGUIDebuffUnitScrollBar_Update();

	-- misc tab
	if (HEALER_ANNOUNCE_AUTOCASTING) then
		HealerGUIAnnounceAutocastingCheckButton:SetChecked(1);
	end
	if (HEALER_ANNOUNCE_OOM) then
		if (HEALER_ANNOUNCE_OOM == 1) then
			HealerGUIAnnounceOOMAllCheckButton:SetChecked(1);
		else
			HealerGUIAnnounceOOMSelfCheckButton:SetChecked(1);
		end
	end
	if (HEALER_ANNOUNCE_NOT_READY) then
		if (HEALER_ANNOUNCE_NOT_READY == 1) then
			HealerGUIAnnounceNotReadyAllCheckButton:SetChecked(1);
		else
			HealerGUIAnnounceNotReadySelfCheckButton:SetChecked(1);
		end
	end
	if (HEALER_ANNOUNCE_OUT_OF_REACH) then
		if (HEALER_ANNOUNCE_OUT_OF_REACH == 1) then
			HealerGUIAnnounceOutOfReachAllCheckButton:SetChecked(1);
		else
			HealerGUIAnnounceOutOfReachSelfCheckButton:SetChecked(1);
		end
	end
	if (HEALER_ANNOUNCE_NOBODY_NEEDS) then
		if (HEALER_ANNOUNCE_NOBODY_NEEDS == 1) then
			HealerGUIAnnounceNobodyNeedsAllCheckButton:SetChecked(1);
		else
			HealerGUIAnnounceNobodyNeedsSelfCheckButton:SetChecked(1);
		end
	end
	if (HEALER_ANNOUNCE_ACTION) then
		if (HEALER_ANNOUNCE_ACTION == 1) then
			HealerGUIAnnounceActionAllCheckButton:SetChecked(1);
		else
			HealerGUIAnnounceActionSelfCheckButton:SetChecked(1);
		end
	end
	if (HEALER_ANNOUNCE_GOT_BUFF) then
		if (HEALER_ANNOUNCE_GOT_BUFF == 1) then
			HealerGUIAnnounceGotBuffAllCheckButton:SetChecked(1);
		else
			HealerGUIAnnounceGotBuffSelfCheckButton:SetChecked(1);
		end
	end
	if (HEALER_ANNOUNCE_OVERHEALING) then
		if (HEALER_ANNOUNCE_OVERHEALING == 1) then
			HealerGUIAnnounceOverhealingAllCheckButton:SetChecked(1);
		else
			HealerGUIAnnounceOverhealingSelfCheckButton:SetChecked(1);
		end
	end
	if (HEALER_SHOW_DOTBARS) then
		HealerGUIShowDOTbarsCheckButton:SetChecked(1);
	end
	if (HEALER_AVOID_SPIRIT_TAP) then
		HealerGUIAvoidSpiritTapCheckButton:SetChecked(1);
	end
	if (HEALER_SHOW_WHO_CLICK_MINIMAP) then
		HealerGUIShowWhoClickMinimapCheckButton:SetChecked(1);
	end
	if (not HEALER_STATUS_BAR_HIDE_BUFFS) then
		HealerGUIShowStatusBarsBuffCheckButton:SetChecked(1);
	end
	if (not HEALER_STATUS_BAR_HIDE_DEBUFFS) then
		HealerGUIShowStatusBarsDebuffCheckButton:SetChecked(1);
	end
	if (not HEALER_STATUS_BAR_HIDE_OVERHEAL) then
		HealerGUIShowStatusBarsOverhealCheckButton:SetChecked(1);
	end

	HealerGUITab1:LockHighlight();
end

function HealerGUIHealclassScrollBar_Update()
	local offset = FauxScrollFrame_GetOffset(HealerGUIHealclassScrollBar);
	local classes = 0;
	local a = 1;
	for a = 1, 5 do
		getglobal("HealerGUIHealclassEntry" .. a .. "Text"):SetText();
		getglobal("HealerGUIHealclassEntry" .. a):Hide();
		getglobal("HealerGUIHealclassEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIAutoHealclassCheckButton" .. a):Hide();
		getglobal("HealerGUIAutoHealclassCheckButton" .. a):SetChecked(0);
	end
	a = 1;
	for healclass, data in HEALER_HEAL_CLASSES do
		classes = classes + 1;
		if (offset > 0) then
			offset = offset - 1;
		else
			if (getglobal("HealerGUIHealclassEntry" .. a .. "Text")) then
				getglobal("HealerGUIHealclassEntry" .. a .. "Text"):SetText(healclass);
				if (healclass == HEALER_AUTOHEAL) then
					getglobal("HealerGUIAutoHealclassCheckButton" .. a):SetChecked(1);
				end
				if (HEALER_CUR_HEAL_CLASS and healclass == HEALER_CUR_HEAL_CLASS) then
					getglobal("HealerGUIHealclassEntry" .. a):LockHighlight();
				end
				getglobal("HealerGUIHealclassEntry" .. a):Show();
				getglobal("HealerGUIAutoHealclassCheckButton" .. a):Show();
				a = a + 1;
			end
		end
	end
	FauxScrollFrame_Update(HealerGUIHealclassScrollBar, classes, 5, 32);
end

function HealerGUIHealclassScrollButton_Click()
	for a = 1, 5 do
		getglobal("HealerGUIHealclassEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIHealspellEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIHealPercentSlider" .. a):Hide();
		getglobal("HealerGUIHealPercentSlider" .. a .. "Value"):Hide();
	end
	if (getglobal(this:GetName() .. "Text")) then
		HEALER_CUR_HEAL_CLASS = getglobal(this:GetName() .. "Text"):GetText();
		this:LockHighlight();
		for healclass, data in HEALER_HEAL_CLASSES do
			if (healclass == HEALER_CUR_HEAL_CLASS) then
				for spell, percent in data do
					for a = 1, 5 do
						if (spell == getglobal("HealerGUIHealspellEntry" .. a .. "Text"):GetText()) then
							getglobal("HealerGUIHealspellEntry" .. a):LockHighlight();
							getglobal("HealerGUIHealPercentSlider" .. a):SetValue(percent * 100);
							getglobal("HealerGUIHealPercentSlider" .. a):Show();
							getglobal("HealerGUIHealPercentSlider" .. a .. "Value"):SetText(percent * 100 .. "%");
							getglobal("HealerGUIHealPercentSlider" .. a .. "Value"):Show();
						end
					end
				end
			end
		end
	else
		HEALER_CUR_HEAL_CLASS = nil;
	end
end

function HealerGUIHealspellScrollBar_Update()
	local offset = FauxScrollFrame_GetOffset(HealerGUIHealspellScrollBar);
	local a = 1;
	local list = {};
	local spells = 0;
	for spellid, spelldata in HEALER_HEALS do
		if (not list[spelldata["Spell"]]) then
			list[spelldata["Spell"]] = 1;
			spells = spells + 1;
		end
	end
	for a = 1, 5 do
		getglobal("HealerGUIHealspellEntry" .. a .. "Text"):SetText();
		getglobal("HealerGUIHealspellEntry" .. a):Hide();
		getglobal("HealerGUIHealspellEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIHealPercentSlider" .. a):Hide();
		getglobal("HealerGUIHealPercentSlider" .. a .. "Value"):Hide();
	end
	a = 1;
	for spellname, one in list do
		if (offset > 0) then
			offset = offset - 1;
		else
			if (getglobal("HealerGUIHealspellEntry" .. a .. "Text")) then
				getglobal("HealerGUIHealspellEntry" .. a .. "Text"):SetText(spellname);
				getglobal("HealerGUIHealspellEntry" .. a):Show();
				if (HEALER_HEAL_CLASSES and HEALER_HEAL_CLASSES[HEALER_CUR_HEAL_CLASS]) then
					local percent = HEALER_HEAL_CLASSES[HEALER_CUR_HEAL_CLASS][spellname];
					if (percent) then
						getglobal("HealerGUIHealspellEntry" .. a):LockHighlight();
						getglobal("HealerGUIHealPercentSlider" .. a):SetValue(percent * 100);
						getglobal("HealerGUIHealPercentSlider" .. a):Show();
						getglobal("HealerGUIHealPercentSlider" .. a .. "Value"):SetText(percent * 100 .. "%");
						getglobal("HealerGUIHealPercentSlider" .. a .. "Value"):Show();
					end
				end
				a = a + 1;
			end
		end
	end
	FauxScrollFrame_Update(HealerGUIHealspellScrollBar, spells, 5, 32);
end

function HealerGUIHealspellScrollButton_Click()
	if (not HEALER_CUR_HEAL_CLASS) then
		return;
	end
	if (getglobal("HealerGUIHealPercentSlider" .. this:GetID()):IsVisible()) then
		local spell = getglobal(this:GetName() .. "Text"):GetText();
		HEALER_HEAL_CLASSES[HEALER_CUR_HEAL_CLASS][spell] = nil;
		this:UnlockHighlight();
		getglobal("HealerGUIHealPercentSlider" .. this:GetID()):Hide();
		getglobal("HealerGUIHealPercentSlider" .. this:GetID() .. "Value"):Hide();
	else
		local spell = getglobal(this:GetName() .. "Text"):GetText();
		this:LockHighlight();
		getglobal("HealerGUIHealPercentSlider" .. this:GetID()):SetValue(50);
		getglobal("HealerGUIHealPercentSlider" .. this:GetID()):Show();
		getglobal("HealerGUIHealPercentSlider" .. this:GetID() .. "Value"):Show();
		local percent = getglobal("HealerGUIHealPercentSlider" .. this:GetID()):GetValue() / 100.0;
		HEALER_HEAL_CLASSES[HEALER_CUR_HEAL_CLASS][spell] = percent;
	end
end

function HealerGUIBuffclassScrollBar_Update()
	local offset = FauxScrollFrame_GetOffset(HealerGUIBuffclassScrollBar);
	local classes = 0;
	local a = 1;
	for a = 1, 5 do
		getglobal("HealerGUIBuffclassEntry" .. a .. "Text"):SetText();
		getglobal("HealerGUIBuffclassEntry" .. a):Hide();
		getglobal("HealerGUIBuffclassEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIAutobuffclassCheckButton" .. a):Hide();
		getglobal("HealerGUIAutobuffclassCheckButton" .. a):SetChecked(0);
	end
	a = 1;
	for buffclass, data in HEALER_BUFF_CLASSES do
		classes = classes + 1;
		if (offset > 0) then
			offset = offset - 1;
		else
			if (getglobal("HealerGUIBuffclassEntry" .. a .. "Text")) then
				getglobal("HealerGUIBuffclassEntry" .. a .. "Text"):SetText(buffclass);
				if (buffclass == HEALER_AUTOBUFF) then
					getglobal("HealerGUIAutobuffclassCheckButton" .. a):SetChecked(1);
				end
				if (HEALER_CUR_BUFF_CLASS and buffclass == HEALER_CUR_BUFF_CLASS) then
					getglobal("HealerGUIBuffclassEntry" .. a):LockHighlight();
				end
				getglobal("HealerGUIBuffclassEntry" .. a):Show();
				getglobal("HealerGUIAutobuffclassCheckButton" .. a):Show();
				a = a + 1;
			end
		end
	end
	FauxScrollFrame_Update(HealerGUIBuffclassScrollBar, classes, 5, 32);
end

function HealerGUIBuffclassScrollButton_Click()
	for a = 1, 5 do
		getglobal("HealerGUIBuffclassEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIBuffUnitEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIBuffspellEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIBuffPrioritySlider" .. a):Hide();
		getglobal("HealerGUIBuffPrioritySlider" .. a .. "Value"):Hide();
	end
	if (getglobal(this:GetName() .. "Text")) then
		HEALER_CUR_BUFF_CLASS = getglobal(this:GetName() .. "Text"):GetText();
		this:LockHighlight();
	else
		HEALER_CUR_BUFF_CLASS = nil;
	end
	HEALER_CUR_UNIT_CLASS = nil;
end

function HealerGUIBuffUnitScrollBar_Update()
	local offset = FauxScrollFrame_GetOffset(HealerGUIBuffUnitScrollBar);
	local classes = 0;
	local a = 1;
	for a = 1, 5 do
		getglobal("HealerGUIBuffUnitEntry" .. a .. "Text"):SetText();
		getglobal("HealerGUIBuffUnitEntry" .. a):Hide();
		getglobal("HealerGUIBuffUnitEntry" .. a):UnlockHighlight();
	end
	a = 1;
	for index, class in UNITCLASSES do
		classes = classes + 1;
		if (offset > 0) then
			offset = offset - 1;
		else
			if (getglobal("HealerGUIBuffUnitEntry" .. a .. "Text")) then
				getglobal("HealerGUIBuffUnitEntry" .. a .. "Text"):SetText(class);
				if (HEALER_CUR_UNIT_CLASS and class == HEALER_CUR_UNIT_CLASS) then
					getglobal("HealerGUIBuffUnitEntry" .. a):LockHighlight();
				end
				getglobal("HealerGUIBuffUnitEntry" .. a):Show();
				a = a + 1;
			end
		end
	end
	FauxScrollFrame_Update(HealerGUIBuffUnitScrollBar, classes, 5, 32);
end

function HealerGUIBuffUnitScrollButton_Click()
	if (not HEALER_CUR_BUFF_CLASS) then
		return;
	end
	for a = 1, 5 do
		getglobal("HealerGUIBuffUnitEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIBuffspellEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIBuffPrioritySlider" .. a):Hide();
		getglobal("HealerGUIBuffPrioritySlider" .. a .. "Value"):Hide();
	end
	if (getglobal(this:GetName() .. "Text")) then
		HEALER_CUR_UNIT_CLASS = getglobal(this:GetName() .. "Text"):GetText();
		this:LockHighlight();
		for buffclass, data in HEALER_BUFF_CLASSES do
			if (buffclass == HEALER_CUR_BUFF_CLASS) then
				for unitclass, moredata in data do
					if (unitclass == HEALER_CUR_UNIT_CLASS) then
						for buff, priority in moredata do
							for a = 1, 5 do
								if (buff == getglobal("HealerGUIBuffspellEntry" .. a .. "Text"):GetText()) then
									getglobal("HealerGUIBuffspellEntry" .. a):LockHighlight();
									getglobal("HealerGUIBuffPrioritySlider" .. a):SetValue(priority);
									getglobal("HealerGUIBuffPrioritySlider" .. a):Show();
									getglobal("HealerGUIBuffPrioritySlider" .. a .. "Value"):SetText(priority);
									getglobal("HealerGUIBuffPrioritySlider" .. a .. "Value"):Show();
								end
							end
						end
					end
				end
			end
		end
	else
		HEALER_CUR_UNIT_CLASS = nil;
	end
end

function HealerGUIBuffspellScrollBar_Update()
	local offset = FauxScrollFrame_GetOffset(HealerGUIBuffspellScrollBar);
	local a = 1;
	local buffs = 0;
	for a = 1, 5 do
		getglobal("HealerGUIBuffspellEntry" .. a .. "Text"):SetText();
		getglobal("HealerGUIBuffspellEntry" .. a):Hide();
		getglobal("HealerGUIBuffspellEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIBuffPrioritySlider" .. a):Hide();
		getglobal("HealerGUIBuffPrioritySlider" .. a .. "Value"):Hide();
	end
	a = 1;
	for buff, data in HEALER_BUFFS do
		buffs = buffs + 1;
		if (offset > 0) then
			offset = offset - 1;
		else
			if (getglobal("HealerGUIBuffspellEntry" .. a .. "Text")) then
				getglobal("HealerGUIBuffspellEntry" .. a .. "Text"):SetText(buff);
				getglobal("HealerGUIBuffspellEntry" .. a):Show();
				if (HEALER_BUFF_CLASSES and HEALER_BUFF_CLASSES[HEALER_CUR_BUFF_CLASS] and HEALER_BUFF_CLASSES[HEALER_CUR_BUFF_CLASS][HEALER_CUR_UNIT_CLASS]) then
					local priority = HEALER_BUFF_CLASSES[HEALER_CUR_BUFF_CLASS][HEALER_CUR_UNIT_CLASS][buff];
					if (priority) then
						getglobal("HealerGUIBuffspellEntry" .. a):LockHighlight();
						getglobal("HealerGUIBuffPrioritySlider" .. a):SetValue(priority);
						getglobal("HealerGUIBuffPrioritySlider" .. a):Show();
						getglobal("HealerGUIBuffPrioritySlider" .. a .. "Value"):SetText(priority);
						getglobal("HealerGUIBuffPrioritySlider" .. a .. "Value"):Show();
					end
				end
				a = a + 1;
			end
		end
	end
	FauxScrollFrame_Update(HealerGUIBuffspellScrollBar, buffs, 5, 32);
end

function HealerGUIBuffspellScrollButton_Click()
	if (not HEALER_CUR_BUFF_CLASS or not HEALER_CUR_UNIT_CLASS) then
		return;
	end
	if (getglobal("HealerGUIBuffPrioritySlider" .. this:GetID()):IsVisible()) then
		local buff = getglobal(this:GetName() .. "Text"):GetText();
		if (not HEALER_BUFF_CLASSES[HEALER_CUR_BUFF_CLASS][HEALER_CUR_UNIT_CLASS]) then
			HEALER_BUFF_CLASSES[HEALER_CUR_BUFF_CLASS][HEALER_CUR_UNIT_CLASS] = {};
		end
		HEALER_BUFF_CLASSES[HEALER_CUR_BUFF_CLASS][HEALER_CUR_UNIT_CLASS][buff] = nil;
		this:UnlockHighlight();
		getglobal("HealerGUIBuffPrioritySlider" .. this:GetID()):Hide();
		getglobal("HealerGUIBuffPrioritySlider" .. this:GetID() .. "Value"):Hide();
	else
		local buff = getglobal(this:GetName() .. "Text"):GetText();
		if (not HEALER_BUFF_CLASSES[HEALER_CUR_BUFF_CLASS][HEALER_CUR_UNIT_CLASS]) then
			HEALER_BUFF_CLASSES[HEALER_CUR_BUFF_CLASS][HEALER_CUR_UNIT_CLASS] = {};
		end
		this:LockHighlight();
		getglobal("HealerGUIBuffPrioritySlider" .. this:GetID()):SetValue(5);
		getglobal("HealerGUIBuffPrioritySlider" .. this:GetID()):Show();
		getglobal("HealerGUIBuffPrioritySlider" .. this:GetID() .. "Value"):Show();
		local priority = getglobal("HealerGUIBuffPrioritySlider" .. this:GetID()):GetValue();
		HEALER_BUFF_CLASSES[HEALER_CUR_BUFF_CLASS][HEALER_CUR_UNIT_CLASS][buff] = priority;
	end
end

function HealerGUIDebuffListScrollButton_Click()
	for a = 1, 5 do
		getglobal("HealerGUIDebuffListEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIDebuffUnitEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIDebuffPrioritySlider" .. a):Hide();
		getglobal("HealerGUIDebuffPrioritySlider" .. a .. "Value"):Hide();
	end
	if (getglobal(this:GetName() .. "Text")) then
		local debuff = getglobal(this:GetName() .. "Text"):GetText();
		if (not debuff) then
			return;
		end
		HEALER_CUR_DEBUFF = debuff;
		this:LockHighlight();
		local debuffdata = HEALER_DEBUFF_NEW[debuff];
		if (not debuffdata) then
			debuffdata = HEALER_DEBUFF_LIST[debuff];
		end
		if (not debuffdata) then
			return;
		end
		for index, unit in UNITCLASSES do
			local priority = debuffdata[unit];
			if (priority) then
				for a = 1, 5 do
					if (unit == getglobal("HealerGUIDebuffUnitEntry" .. a .. "Text"):GetText()) then
						getglobal("HealerGUIDebuffUnitEntry" .. a):LockHighlight();
						getglobal("HealerGUIDebuffPrioritySlider" .. a):SetValue(priority);
						getglobal("HealerGUIDebuffPrioritySlider" .. a):Show();
						getglobal("HealerGUIDebuffPrioritySlider" .. a .. "Value"):SetText(priority);
						getglobal("HealerGUIDebuffPrioritySlider" .. a .. "Value"):Show();
					end
				end
			end
		end
	end
end

function HealerGUIDebuffListScrollBar_Update()
	local offset = FauxScrollFrame_GetOffset(HealerGUIDebuffListScrollBar);
	local a = 1;
	local debuffs = 0;
	for a = 1, 5 do
		getglobal("HealerGUIDebuffListEntry" .. a .. "Text"):SetText();
		getglobal("HealerGUIDebuffListEntry" .. a):Hide();
		getglobal("HealerGUIDebuffListEntry" .. a):UnlockHighlight();
	end
	a = 1;
	-- first the new debuffs
	-- we want the list alphabetically sorted
	local debufflist = {};
	for debuff, data in HEALER_DEBUFF_NEW do
		if (HEALER_DEBUFFS_CAN_CURE_TYPES[HEALER_DEBUFF_NEW[debuff]["Type"]]) then
			table.insert(debufflist, debuff);
			debuffs = debuffs + 1;
		end
	end
	table.sort(debufflist);
	for index, debuff in debufflist do
		if (offset > 0) then
			offset = offset - 1;
		else
			if (getglobal("HealerGUIDebuffListEntry" .. a .. "Text")) then
				getglobal("HealerGUIDebuffListEntry" .. a .. "Text"):SetText(debuff);
				getglobal("HealerGUIDebuffListEntry" .. a .. "Text"):SetVertexColor(1.0, 0.0, 0.0);
				if (debuff == HEALER_CUR_DEBUFF) then
					getglobal("HealerGUIDebuffListEntry" .. a):LockHighlight();
				end
				getglobal("HealerGUIDebuffListEntry" .. a):Show();
				a = a + 1;
			end
		end
	end
	-- then the known debuffs
	-- we want the list alphabetically sorted
	local debufflist = {};
	for debuff, data in HEALER_DEBUFF_LIST do
		if (HEALER_DEBUFFS_CAN_CURE_TYPES[HEALER_DEBUFF_LIST[debuff]["Type"]]) then
			table.insert(debufflist, debuff);
			debuffs = debuffs + 1;
		end
	end
	table.sort(debufflist);
	for index, debuff in debufflist do
		if (offset > 0) then
			offset = offset - 1;
		else
			if (getglobal("HealerGUIDebuffListEntry" .. a .. "Text")) then
				getglobal("HealerGUIDebuffListEntry" .. a .. "Text"):SetText(debuff);
				getglobal("HealerGUIDebuffListEntry" .. a .. "Text"):SetVertexColor(1.0, 1.0, 1.0);
				if (debuff == HEALER_CUR_DEBUFF) then
					getglobal("HealerGUIDebuffListEntry" .. a):LockHighlight();
				end
				getglobal("HealerGUIDebuffListEntry" .. a):Show();
				a = a + 1;
			end
		end
	end
	FauxScrollFrame_Update(HealerGUIDebuffListScrollBar, debuffs, 5, 32);
end

function HealerGUIDebuffUnitScrollButton_Click()
	if (not HEALER_CUR_DEBUFF) then
		return;
	end
	if (getglobal("HealerGUIDebuffPrioritySlider" .. this:GetID()):IsVisible()) then
		this:UnlockHighlight();
		getglobal("HealerGUIDebuffPrioritySlider" .. this:GetID()):Hide();
		getglobal("HealerGUIDebuffPrioritySlider" .. this:GetID() .. "Value"):Hide();
		local unit = getglobal(this:GetName() .. "Text"):GetText();
		if (HEALER_DEBUFF_NEW[HEALER_CUR_DEBUFF]) then
			HEALER_DEBUFF_NEW[HEALER_CUR_DEBUFF][unit] = nil;
		elseif (HEALER_DEBUFF_LIST[HEALER_CUR_DEBUFF]) then
			HEALER_DEBUFF_LIST[HEALER_CUR_DEBUFF][unit] = nil;
		end
	else
		this:LockHighlight();
		getglobal("HealerGUIDebuffPrioritySlider" .. this:GetID()):SetValue(10);
		getglobal("HealerGUIDebuffPrioritySlider" .. this:GetID()):Show();
		getglobal("HealerGUIDebuffPrioritySlider" .. this:GetID() .. "Value"):Show();
		local unit = getglobal(this:GetName() .. "Text"):GetText();
		local priority = getglobal("HealerGUIDebuffPrioritySlider" .. this:GetID()):GetValue();
		if (HEALER_DEBUFF_NEW[HEALER_CUR_DEBUFF]) then
			HEALER_DEBUFF_NEW[HEALER_CUR_DEBUFF][unit] = priority;
		elseif (HEALER_DEBUFF_LIST[HEALER_CUR_DEBUFF]) then
			HEALER_DEBUFF_LIST[HEALER_CUR_DEBUFF][unit] = priority;
		end
	end
end

function HealerGUIDebuffUnitScrollBar_Update()
	local offset = FauxScrollFrame_GetOffset(HealerGUIDebuffUnitScrollBar);
	local a = 1;
	local units = 0;
	for a = 1, 5 do
		getglobal("HealerGUIDebuffUnitEntry" .. a .. "Text"):SetText();
		getglobal("HealerGUIDebuffUnitEntry" .. a):Hide();
		getglobal("HealerGUIDebuffUnitEntry" .. a):UnlockHighlight();
		getglobal("HealerGUIDebuffPrioritySlider" .. a):Hide();
		getglobal("HealerGUIDebuffPrioritySlider" .. a .. "Value"):Hide();
	end
	a = 1;
	for index, unit in UNITCLASSES do
		-- list up all classes
		units = units + 1;
		if (offset > 0) then
			offset = offset - 1;
		else
			if (getglobal("HealerGUIDebuffUnitEntry" .. a .. "Text")) then
				getglobal("HealerGUIDebuffUnitEntry" .. a .. "Text"):SetText(unit);
				
				local debuffdata = HEALER_DEBUFF_NEW[HEALER_CUR_DEBUFF];
				if (not debuffdata) then
					debuffdata = HEALER_DEBUFF_LIST[HEALER_CUR_DEBUFF];
				end
				if (debuffdata) then
					local priority = debuffdata[unit];
					if (priority) then
						getglobal("HealerGUIDebuffUnitEntry" .. a):LockHighlight();
						getglobal("HealerGUIDebuffPrioritySlider" .. a):SetValue(priority);
						getglobal("HealerGUIDebuffPrioritySlider" .. a):Show();
						getglobal("HealerGUIDebuffPrioritySlider" .. a .. "Value"):SetText(priority);
						getglobal("HealerGUIDebuffPrioritySlider" .. a .. "Value"):Show();
					end
				end
				getglobal("HealerGUIDebuffUnitEntry" .. a):Show();
				a = a + 1;
			end
		end
	end
	FauxScrollFrame_Update(HealerGUIDebuffUnitScrollBar, units, 5, 32);
end

function HealerGUI_ShowTooltip()
	-- show the user a simple tooltip for his or hers amusement :)
	local show = nil;
	for element, data in HEALERGUI_HELP do
		if (string.find(this:GetName(), element)) then
			GameTooltip_SetDefaultAnchor(GameTooltip, this);
			GameTooltip:SetText(data["Title"], 0.9, 0.9, 0.9, 1.0, 1);
			GameTooltip:AddLine(data["Description"], 0.6, 0.6, 0.6, 1.0, 1);
			GameTooltip:Show();
			show = 1;
		elseif (string.find(this:GetName(), "HealerGUIDebuffListEntry")) then
			-- a bit special
			GameTooltip_SetDefaultAnchor(GameTooltip, this);
			local debuffname = getglobal(this:GetName() .. "Text"):GetText();
			local text, type;
			if (HEALER_DEBUFF_LIST[debuffname]) then
				text = HEALER_DEBUFF_LIST[debuffname]["Text"];
				type = HEALER_DEBUFF_LIST[debuffname]["Type"];
			end
			if (not text and HEALER_DEBUFF_NEW[debuffname]) then
				text = HEALER_DEBUFF_NEW[debuffname]["Text"];
				type = HEALER_DEBUFF_NEW[debuffname]["Type"];
			end
			if (type) then
				debuffname = debuffname .. " (" .. type .. ")";
			end
			GameTooltip:SetText(debuffname, 0.9, 0.9, 0.9, 1.0, 1);
			GameTooltip:AddLine(text, 0.6, 0.6, 0.6, 1.0, 1);
			GameTooltip:Show();
			show = 1;
		end
	end
	if (not show) then
		GameTooltip_SetDefaultAnchor(GameTooltip, this);
		GameTooltip:SetText("Missing");
		GameTooltip:AddLine(this:GetName());
		GameTooltip:Show();
	end
end

function Healer_AutoCast()
	local cancast = Healer_CanCast();
	if (not cancast) then
		return;
	end
	-- we don't want spam
	HEALER_AUTOCASTING = 1;
	-- first debuffs, they're more urgent than buffs
	if (cancast == 1 and HEALER_AUTODEBUFF and Healer_Debuff()) then
		HEALER_AUTOCASTING = nil;
		return;
	end
	-- then buffs
	if (Healer_Buff(HEALER_AUTOBUFF)) then
		HEALER_AUTOCASTING = nil;
		return;
	end
	if (UnitIsFriend("player", "target") or cancast == 2) then
		-- don't want to autoheal when we got a friendly target
		HEALER_AUTOCASTING = nil;
		return;
	end
	-- then heal :)
	Healer_Heal(HEALER_AUTOHEAL);
	HEALER_AUTOCASTING = nil;
end

function Healer_PlayerFrame_OnClick(button)
	if (button == "Button4") then
		Healer_MouseHeal("player", HEALER_MOUSE_HEALCLASSES[3]);
	elseif (button == "Button5") then
		Healer_MouseHeal("player", HEALER_MOUSE_HEALCLASSES[4]);
	end
	Healer_old_PlayerFrame_OnClick(button);
end

function Healer_PartyMemberFrame_OnClick(partyFrame)
	if (not partyFrame) then
		partyFrame = this;
	end
	local unit = "party" .. partyFrame:GetID();
	if (arg1 == "Button4") then
		Healer_MouseHeal(unit, HEALER_MOUSE_HEALCLASSES[3]);
	elseif (arg1 == "Button5") then
		Healer_MouseHeal(unit, HEALER_MOUSE_HEALCLASSES[4]);
	end
	Healer_old_PartyMemberFrame_OnClick(partyFrame);
end

function Healer_RaidPulloutButton_OnClick()
	local unit = this.unit;
	if (not unit) then
		unit = this:GetParent().unit;
	end
	if (arg1 == "Button4") then
		Healer_MouseHeal(unit, HEALER_MOUSE_HEALCLASSES[3]);
	elseif (arg1 == "Button5") then
		Healer_MouseHeal(unit, HEALER_MOUSE_HEALCLASSES[4]);
	end
	Healer_old_RaidPulloutButton_OnClick();
end

function Healer_MouseSpecialClick(healclassid)
	--Healer_Print(GetMouseFocus():GetName().." "..(UnitName("mouseover") or ""));

	if (not healclassid) then
		healclassid = 1;
	end
	local healclass = HEALER_MOUSE_HEALCLASSES[healclassid];
	if (string.find(GetMouseFocus():GetName(), "PlayerFrame")) then
		Healer_MouseHeal("player", healclass);
	elseif (string.find(GetMouseFocus():GetName(), "PartyMemberFrame")) then
		local unit = "party" .. GetMouseFocus():GetID();
		Healer_MouseHeal(unit, healclass);
	elseif (string.find(GetMouseFocus():GetName(), "RaidPullout(%d?)Button")) then
		local unit = GetMouseFocus().unit;
		if (not unit) then
			unit = GetMouseFocus():GetParent().unit;
		end
		Healer_MouseHeal(unit, healclass);
	elseif (UnitName("mouseover")) then
		Healer_MouseHeal("mouseover", healclass);
	elseif (string.find(GetMouseFocus():GetName(), "CT_RAMember")) then
		local id = GetMouseFocus():GetParent():GetParent():GetID();
		--Healer_Print("raid" .. id);
		Healer_MouseHeal("raid" .. id, healclass);
	end
end

function Healer_MouseHeal(unit, healclass)
	if (Healer_CanCast() ~= 1) then
		return;
	end
	if (not healclass) then
		return;
	end
	if (not HEALER_HEAL_CLASSES or not HEALER_HEAL_CLASSES[healclass]) then
		return;
	end
	local tank;
	if (IsShiftKeyDown()) then
		tank = 1;
	end
	if (unit and tank) then
		-- tank heal
		if (UnitIsFriend("player", unit)) then
			if (not Healer_CanCastOn(unit)) then
				return;
			end
			local person, spell, rank, spellid, oom;
			if (UnitHealthMax(unit) == 100) then
				-- normal heal someone outside party/raid
				person, spell, rank, spellid, oom = Healer_BestHealSpell(healclass, unit, HEALER_HEAL_MULTIPLY[UnitClass(unit)] * UnitLevel(unit) * (UnitHealthMax(unit) - UnitHealth(unit)) / 100, UnitHealth(unit) / UnitHealthMax(unit));
			else
				-- tank heal self/party/raid
				person, spell, rank, spellid, oom = Healer_BestHealSpell(healclass, unit, UnitHealthMax(unit), 0);
			end
			Healer_CastSpell(person, spell, rank, spellid, oom, "Healing");
			HEALER_CANT_CAST_ON_TICK = HEALER_CANT_CAST_ON_TICK + 1;
		end
	elseif (unit) then
		-- normal heal
		if (UnitIsFriend("player", unit)) then
			if (not Healer_CanCastOn(unit)) then
				return;
			end
			local person, spell, rank, spellid, oom;
			if (UnitHealthMax(unit) == 100) then
				-- normal heal someone not in our party/raid
				person, spell, rank, spellid, oom = Healer_BestHealSpell(healclass, unit, HEALER_HEAL_MULTIPLY[UnitClass(unit)] * UnitLevel(unit) * (UnitHealthMax(unit) - UnitHealth(unit)) / 100, UnitHealth(unit) / UnitHealthMax(unit));
			else
				-- normal heal self/party/raid
				local extrahp, priority = Healer_ExtraHealing(unit, 1.0);
				local hp = UnitHealthMax(unit) - UnitHealth(unit) - extrahp;
				local percent = 1.0 - (1.0 - (UnitHealth(unit) + extrahp) / UnitHealthMax(unit));
				person, spell, rank, spellid, oom = Healer_BestHealSpell(healclass, unit, hp, percent);
			end
			Healer_CastSpell(person, spell, rank, spellid, oom, "Healing");
			HEALER_CANT_CAST_ON_TICK = HEALER_CANT_CAST_ON_TICK + 1;
		end
	end
end

function Healer_CanCast()
	-- this method is called each time we want to heal/buff/debuff
	Healer_CheckSpells();
	-- this is a nice place to clean the cache :)
	if(Healer_UseOldChecks) then HEALER_BUFF_CACHE = {};end;
	if (HEALER_DOING_SOMETHING) then
		return;
	end
	if (UnitIsDeadOrGhost("player") or UnitOnTaxi("player")) then
		return;
	end
	-- check that we're not shapeshifted
	if (UnitClass("player") == CLASS_DRUID) then 
		for a = 1, GetNumShapeshiftForms() do
			local icon, name, active, castable = GetShapeshiftFormInfo(a);
			if (active) then
				if (name == SPELL_MOONKIN_FORM) then
					-- yey, a really cool druid here
					-- we're only allowed to cast "omen of clarity" and "thorns" in this form
					Healer_CheckSpells();
					return 2;
				end
				return;
			end
		end
	end
	if (Healer_OnMount()) then
		return;
	end
	-- check if we got the "spirit tap" buff
	if (HEALER_AVOID_SPIRIT_TAP and UnitClass("player") == CLASS_PRIEST and Healer_GotBuff("player", SPELL_SPIRIT_TAP) and not HEALER_AUTOCASTING) then
		return;
	end
	return 1;
end

function Healer_OnMount()
	local a = 1;
	C_TooltipTextLeft2:SetText();
	C_Tooltip:SetUnitBuff("player", a);
	local bufftext = C_TooltipTextLeft2:GetText();

	-- loop thru the buffs this player got
	while (bufftext and a <= 16) do
		if (bufftext == MOUNT_TEXT_1 or bufftext == MOUNT_TEXT_2) then
			-- the player is on a mount
			return 1;
		end
		a = a + 1;
		C_TooltipTextLeft2:SetText();
		C_Tooltip:SetUnitBuff("player", a);
		bufftext = C_TooltipTextLeft2:GetText();
	end
	-- the player is not mounted
	return;
end

function Healer_CancelIfOverheal()
	if(Healer_OverhealDetected) then
		SpellStopCasting();
		--Healer_Announce("|cffead9ac", Healer_OverhealCancelMessage, HEALER_ANNOUNCE_OVERHEALING, HEALER_HEAL_RAID);
		return true;
	end
	return false;
end

function Healer_Heal(healclass)
	if(Healer_CancelIfOverheal()) then
		return;
	end

	-- let's heal
	if (not healclass) then
		if (not HEALER_AUTOCASTING) then
			Healer_Print("Your macro is wrong, apparently you forgot to add a \" before and after the name of the healclass", "|cffff0000");
		end
		return;
	end
	healclass = string.lower(healclass);
	if (not HEALER_HEAL_CLASSES or not HEALER_HEAL_CLASSES[healclass]) then
		if (not HEALER_AUTOCASTING) then
			Healer_Print("No healing spells registered in this class", "|cffff0000");
		end
		return;
	end
	-- if we're not autocasting we need to check if we can cast
	if (not HEALER_AUTOCASTING and Healer_CanCast() ~= 1) then
		return;
	end

	local person, spell, rank, spellid, oom;
	person = "blah";
	while (person) do
		person, spell, rank, spellid, oom = Healer_BestHealSpell(healclass);
		local outcome = Healer_CastSpell(person, spell, rank, spellid, oom, "Healing");
		if (outcome and outcome == 1) then
			HEALER_CANT_CAST_ON_TICK = HEALER_CANT_CAST_ON_TICK + 1;
			return 1;
		elseif (outcome and outcome == 2) then
			HEALER_CANT_CAST_ON_TICK = HEALER_CANT_CAST_ON_TICK + 1;
			return;
		end
	end
	-- seems like there was no need for healing, go on to next thingy
	HEALER_CANT_CAST_ON_TICK = HEALER_CANT_CAST_ON_TICK + 1;
	return;
end

function Healer_Debuff()
	-- if we're not autocasting we need to check if we can cast
	if (not HEALER_AUTOCASTING and Healer_CanCast() ~= 1) then
		return;
	end

	local person, spell, rank, spellid, oom;
	person = "blah";
	while (person) do
		person, spell, rank, spellid, oom = Healer_RemoveDebuff();
		outcome = Healer_CastSpell(person, spell, rank, spellid, oom, "Debuffing");
		if (outcome and outcome == 1) then
			HEALER_CANT_CAST_ON_TICK = HEALER_CANT_CAST_ON_TICK + 1;
			return 1;
		elseif (outcome and outcome == 2) then
			HEALER_CANT_CAST_ON_TICK = HEALER_CANT_CAST_ON_TICK + 1;
			return;
		end
	end
	-- seems like there was no need for debuffing, go on to next thingy
	HEALER_CANT_CAST_ON_TICK = HEALER_CANT_CAST_ON_TICK + 1;
	return;
end

function Healer_Revive()
	-- revive someone :)
	if (Healer_CanCast() ~= 1) then
		return;
	end
	-- target
	if (UnitIsFriend("player", "target")) then
		HEALER_ACTION = {
			["Person"] = "target",
			["Name"] = UnitName("target"),
			["Spell"] = HEALER_REVIVE["Spell"],
			["Rank"] = HEALER_REVIVE["Rank"],
			["Heal"] = 0,
			["Curtime"] = HEALER_REVIVE["Casttime"],
			["Casttime"] = HEALER_REVIVE["Casttime"],
			["ID"] = HEALER_REVIVE["ID"],
			["Percent"] = 0
		};
		if (Healer_CanRevive("target") and Healer_CastSpell("target", HEALER_REVIVE["Spell"], HEALER_REVIVE["Rank"], HEALER_REVIVE["ID"], nil, "Reviving")) then
			-- reviving target
			return 1;
		else
			-- can't revive target (let's not try anyone else either)
			HEALER_ACTION = nil;
			return;
		end
	end
	-- party/raid
	local tmppor = "raid";
	if (GetNumRaidMembers() == 0) then
		tmppor = "party";
	end
	local players = GetNumPartyMembers();
	if (tmppor == "raid") then
		players = GetNumRaidMembers();
	end
	local person = "blah";
	while (person) do
		person = nil;
		local dead = 0;
		for a = 1, players do
			local tmpperson = tmppor .. a;
			if (Healer_CanRevive(tmpperson) and not HEALER_REVIVE_BAN[tmpperson]) then
				local beingrevived;
				if (HEALER_BEING_HEALED[UnitName(tmpperson)]) then
					for healer, data in HEALER_BEING_HEALED[UnitName(tmpperson)] do
						if (data["Action"] == "Reviving") then
							beingrevived = 1;
						end
					end
				end
				dead = dead + 1;
				if (not beingrevived and UnitClass(tmpperson) == CLASS_PRIEST or UnitClass(tmpperson) == CLASS_PALADIN or UnitClass(tmpperson) == CLASS_SHAMAN) then
					-- prioritize these classes (they can revive others)
					HEALER_ACTION = {
						["Person"] = tmpperson,
						["Name"] = UnitName(tmpperson),
						["Spell"] = HEALER_REVIVE["Spell"],
						["Rank"] = HEALER_REVIVE["Rank"],
						["Heal"] = 0,
						["Curtime"] = HEALER_REVIVE["Casttime"],
						["Casttime"] = HEALER_REVIVE["Casttime"],
						["ID"] = HEALER_REVIVE["ID"],
						["Percent"] = 0
					};
					if (Healer_CastSpell(tmpperson, HEALER_REVIVE["Spell"], HEALER_REVIVE["Rank"], HEALER_REVIVE["ID"], nil, "Reviving")) then
						-- reviving priest/paladin/shaman
						HEALER_REVIVE_BAN[tmpperson] = HEALER_REVIVE["Casttime"] + 15;
						return 1;
					end
				elseif (not beingrevived and not person) then
					person = tmpperson;
				elseif (not beingrevived and math.random(dead) == 1) then
					-- to randomize-ish whom to res
					person = tmpperson;
				end
			end
		end
		if (person) then
			HEALER_ACTION = {
				["Person"] = tmpperson,
				["Name"] = UnitName(person),
				["Spell"] = HEALER_REVIVE["Spell"],
				["Rank"] = HEALER_REVIVE["Rank"],
				["Heal"] = 0,
				["Curtime"] = HEALER_REVIVE["Casttime"],
				["Casttime"] = HEALER_REVIVE["Casttime"],
				["ID"] = HEALER_REVIVE["ID"],
				["Percent"] = 0
			};
			if (Healer_CastSpell(person, HEALER_REVIVE["Spell"], HEALER_REVIVE["Rank"], HEALER_REVIVE["ID"], nil, "Reviving")) then
				-- reviving some other class than priest/paladin/shaman
				HEALER_REVIVE_BAN[person] = HEALER_REVIVE["Casttime"] + 15;
				return 1;
			else
				HEALER_ACTION = nil;
			end
		end
	end
	return;
end

function Healer_Buff(buffclass)
	-- buff someone :)
	if (not buffclass) then
		if (not HEALER_AUTOCASTING) then
			Healer_Print("Your macro is wrong, apparently you forgot to add a \" before and after the name of the buffclass", "|cffff0000");
		end
		return;
	end
	buffclass = string.lower(buffclass);
	if (not HEALER_BUFF_CLASSES or not HEALER_BUFF_CLASSES[buffclass]) then
		if (not HEALER_AUTOCASTING) then
			Healer_Print("No buffs registered in this class", "|cffff0000");
		end
		return;
	end
	-- if we're not autocasting we need to check if we can cast
	local cancast = Healer_CanCast();
	if (not HEALER_AUTOCASTING and not cancast) then
		return;
	end

	local person, spell, rank, spellid, oom;
	person = "blah";
	while (person) do
		person, spell, rank, spellid, pri = Healer_CastBuff(buffclass, cancast);
		local outcome = Healer_CastSpell(person, spell, rank, spellid, pri, "Buffing");
		if (outcome and outcome == 1) then
			HEALER_CANT_CAST_ON_TICK = HEALER_CANT_CAST_ON_TICK + 1;
			return 1;
		elseif (outcome and outcome == 2) then
			HEALER_CANT_CAST_ON_TICK = HEALER_CANT_CAST_ON_TICK + 1;
			return;
		end
	end
	-- seems like there was no need for debuffing, go on to next thingy
	HEALER_CANT_CAST_ON_TICK = HEALER_CANT_CAST_ON_TICK + 1;
	return;
end

function Healer_CheckSpells()
	if (HEALER_HAS_CHECKED_SPELLBOOK) then
		return;
	end
	HEALER_HAS_CHECKED_SPELLBOOK = 1;
	-- check which spells this player got
	HEALER_HEALS = {};
	HEALER_BUFFS = {
		[SPELL_GOTW] = {
			["GroupBuff"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 50
				},
				[2] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_MOTW] = {
			["Super"] = SPELL_GOTW,
			["Levels"] = {
				[1] = {
					["Level"] = 1
				},
				[2] = {
					["Level"] = 10
				},
				[3] = {
					["Level"] = 20
				},
				[4] = {
					["Level"] = 30
				},
				[5] = {
					["Level"] = 40
				},
				[6] = {
					["Level"] = 50
				},
				[7] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_THORNS] = {
			["Moonkin"] = 1,
			["Super"] = SPELL_FIRE_SHIELD,
			["Levels"] = {
				[1] = {
					["Level"] = 6
				},
				[2] = {
					["Level"] = 14
				},
				[3] = {
					["Level"] = 24
				},
				[4] = {
					["Level"] = 34
				},
				[5] = {
					["Level"] = 44
				},
				[6] = {
					["Level"] = 54
				}
			}
		},
		[SPELL_OMEN] = {
			["Moonkin"] = 1,
			["Selfcast"] = 1
		},
		[SPELL_TRUESHOT_AURA] = {
			["GroupBuff"] = 1,
			["Selfcast"] = 1
		},
		[SPELL_AMPLIFY] = {
			["Levels"] = {
				[1] = {
					["Level"] = 18
				},
				[2] = {
					["Level"] = 30
				},
				[3] = {
					["Level"] = 42
				},
				[4] = {
					["Level"] = 54
				}
			}
		},
		[SPELL_ARCANE_BRILLIANCE] = {
			["GroupBuff"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 56
				}
			}
		},
		[SPELL_ARCANE_INTELLECT] = {
			["Super"] = SPELL_ARCANE_BRILLIANCE,
			["Levels"] = {
				[1] = {
					["Level"] = 1
				},
				[2] = {
					["Level"] = 14
				},
				[3] = {
					["Level"] = 28
				},
				[4] = {
					["Level"] = 42
				},
				[5] = {
					["Level"] = 56
				}
			}
		},
		[SPELL_DAMPEN_MAGIC] = {
			["Levels"] = {
				[1] = {
					["Level"] = 12
				},
				[2] = {
					["Level"] = 24
				},
				[3] = {
					["Level"] = 36
				},
				[4] = {
					["Level"] = 48
				},
				[5] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_DETECT_MAGIC] = {
			["Levels"] = {
				[1] = {
					["Level"] = 16
				}
			}
		},
		[SPELL_MAGE_ARMOR] = {
			["Selfcast"] = 1
		},
		[SPELL_FIRE_WARD] = {
			["Selfcast"] = 1
		},
		[SPELL_FROST_ARMOR] = {
			["Selfcast"] = 1
		},
		[SPELL_FROST_WARD] = {
			["Selfcast"] = 1
		},
		[SPELL_ICE_ARMOR] = {
			["Selfcast"] = 1
		},
		[SPELL_MANA_SHIELD] = {
			["Super"] = SPELL_PWS,
			["Selfcast"] = 1
		},
		[SPELL_BOL] = {
			["Super"] = SPELL_GBOL,
			["Levels"] = {
				[1] = {
					["Level"] = 40
				},
				[2] = {
					["Level"] = 50
				},
				[3] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_GBOL] = {
			["GroupBuff"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_BOW] = {
			["Super"] = SPELL_GBOW,
			["Levels"] = {
				[1] = {
					["Level"] = 14
				},
				[2] = {
					["Level"] = 24
				},
				[3] = {
					["Level"] = 34
				},
				[4] = {
					["Level"] = 44
				},
				[5] = {
					["Level"] = 54
				},
				[6] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_GBOW] = {
			["GroupBuff"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 54
				},
				[2] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_BOSAC] = {
			["Levels"] = {
				[1] = {
					["Level"] = 46
				},
				[2] = {
					["Level"] = 54
				}
			}
		},
		[SPELL_BOSAL] = {
			["Super"] = SPELL_GBOSAL,
			["Levels"] = {
				[1] = {
					["Level"] = 26
				}
			}
		},
		[SPELL_GBOSAL] = {
			["GroupBuff"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_BOSAN] = {
			["Super"] = SPELL_GBOSAN,
			["Levels"] = {
				[1] = {
					["Level"] = 20
				},
				[2] = {
					["Level"] = 30
				},
				[3] = {
					["Level"] = 40
				},
				[4] = {
					["Level"] = 50
				},
				[5] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_GBOSAN] = {
			["GroupBuff"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_BOK] = {
			["Super"] = SPELL_GBOK,
			["Levels"] = {
				[1] = {
					["Level"] = 40
				}
			}
		},
		[SPELL_GBOK] = {
			["GroupBuff"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_BOM] = {
			["Super"] = SPELL_GBOM,
			["Levels"] = {
				[1] = {
					["Level"] = 4
				},
				[2] = {
					["Level"] = 12
				},
				[3] = {
					["Level"] = 22
				},
				[4] = {
					["Level"] = 32
				},
				[5] = {
					["Level"] = 42
				},
				[6] = {
					["Level"] = 52
				},
				[7] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_GBOM] = {
			["GroupBuff"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 52
				},
				[2] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_RIGHTEOUS_FURY] = {
			["Selfcast"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 16
				},
			}
		},
		[SPELL_DIVINE_FAVOR] = {
			["Selfcast"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 30
				},
			}
		},
		[SPELL_DIVINE_SPIRIT] = {
			["Super"] = SPELL_PRAYER_OF_SPIRIT,
			["Levels"] = {
				[1] = {
					["Level"] = 30
				},
				[2] = {
					["Level"] = 40
				},
				[3] = {
					["Level"] = 50
				},
				[4] = {
					["Level"] = 60
				},
				[5] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_ELUNES_GRACE] = {
			["Selfcast"] = 1
		},
		[SPELL_FEEDBACK] = {
			["Selfcast"] = 1,
			["Weapon"] = 1
		},
		[SPELL_POF] = {
			["GroupBuff"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 48
				},
				[2] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_PWF] = {
			["Super"] = SPELL_POF,
			["Levels"] = {
				[1] = {
					["Level"] = 1
				},
				[2] = {
					["Level"] = 12
				},
				[3] = {
					["Level"] = 24
				},
				[4] = {
					["Level"] = 36
				},
				[5] = {
					["Level"] = 48
				},
				[6] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_SHADOW_PROTECTION] = {
			["Super"] = SPELL_PRAYER_OF_SHADOW_PROTECTION,
			["Levels"] = {
				[1] = {
					["Level"] = 30
				},
				[2] = {
					["Level"] = 42
				},
				[3] = {
					["Level"] = 56
				}
			}
		},
		[SPELL_PRAYER_OF_SPIRIT] = {
			["GroupBuff"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_PRAYER_OF_SHADOW_PROTECTION] = {
			["GroupBuff"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 56
				}
			}
		},
		[SPELL_INNER_FIRE] = {
			["Selfcast"] = 1
		},
		[SPELL_FEAR_WARD] = {
			["Levels"] = {
				[1] = {
					["Level"] = 20
				}
			}
		},
		[SPELL_TOW] = {
			["Selfcast"] = 1
		},
		[SPELL_DETECT_TRAPS] = {
			["Selfcast"] = 1
		},
		[SPELL_ELEMENTAL_FOCUS] = {
			["Selfcast"] = 1
		},
		[SPELL_LIGHTNING_SHIELD] = {
			["Selfcast"] = 1
		},
		[SPELL_ROCKBITER_WEAPON] = {
			["Selfcast"] = 1,
			["Weapon"] = 1
		},
		[SPELL_WINDFURY_WEAPON] = {
			["Selfcast"] = 1,
			["Weapon"] = 1
		},
		[SPELL_FROSTBRAND_WEAPON] = {
			["Selfcast"] = 1,
			["Weapon"] = 1
		},
		[SPELL_FLAMETONGUE_WEAPON] = {
			["Selfcast"] = 1,
			["Weapon"] = 1
		},
		[SPELL_DEMON_ARMOR] = {
			["Selfcast"] = 1
		},
		[SPELL_DEMON_SKIN] = {
			["Selfcast"] = 1
		},
		[SPELL_DETECT_LINV] = {
			["Levels"] = {
				[1] = {
					["Level"] = 26
				}
			}
		},
		[SPELL_DETECT_INV] = {
			["Levels"] = {
				[1] = {
					["Level"] = 38
				}
			}
		},
		[SPELL_DETECT_GINV] = {
			["Levels"] = {
				[1] = {
					["Level"] = 50
				}
			}
		},
		[SPELL_PWS] = {
			["Levels"] = {
				[1] = {
					["Level"] = 6
				},
				[2] = {
					["Level"] = 12
				},
				[3] = {
					["Level"] = 18
				},
				[4] = {
					["Level"] = 24
				},
				[5] = {
					["Level"] = 30
				},
				[6] = {
					["Level"] = 36
				},
				[7] = {
					["Level"] = 42
				},
				[8] = {
					["Level"] = 48
				},
				[9] = {
					["Level"] = 54
				},
				[10] = {
					["Level"] = 60
				}
			}
		},
		[SPELL_SHADOW_WARD] = {
			["Selfcast"] = 1,
			["Levels"] = {
				[1] = {
					["Level"] = 32
				},
				[2] = {
					["Level"] = 42
				},
				[3] = {
					["Level"] = 52
				}
			}
		},
		[SPELL_UNENDING_BREATH] = {
			["Levels"] = {
				[1] = {
					["Level"] = 16
				}
			}
		}
	};
	HEALER_DEBUFFS = {
		[SPELL_REMOVECURSE] = {
			[1] = {
				[TYPE_CURSE] = 1
			}
		},
		[SPELL_REMOVELESSERCURSE] = {
			[1] = {
				[TYPE_CURSE] = 1
			}
		},
		[SPELL_CUREPOISON] = {
			[1] = {
				[TYPE_POISON] = 1
			}
		},
		[SPELL_CLEANSE] = {
			[1] = {
				[TYPE_DISEASE] = 1,
				[TYPE_MAGIC] = 1,
				[TYPE_POISON] = 1
			}
		},
		[SPELL_PURIFY] = {
			[1] = {
				[TYPE_DISEASE] = 1,
				[TYPE_POISON] = 1
			}
		},
		[SPELL_CUREDISEASE] = {
			[1] = {
				[TYPE_DISEASE] = 1
			}
		},
		[SPELL_ABOLISHDISEASE] = {
			[1] = {
				[TYPE_DISEASE] = 2,
				["SpellLevel"] = 32
			}
		},
		[SPELL_ABOLISHPOISON] = {
			[1] = {
				[TYPE_POISON] = 2,
				["SpellLevel"] = 26
			}
		},
		[SPELL_DISPELMAGIC] = {
			[1] = {
				[TYPE_MAGIC] = 1
			},
			[2] = {
				[TYPE_MAGIC] = 2
			}
		}
	};
	HEALER_REVIVE = {};
	HEALER_DOTS = {};
	NUKER_NUKES = {};
	-- erase our previous targets
	for nukeclass, data in NUKER_NUKE_CLASSES do
		for priority, moredata in data do
			NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"] = {};
		end
	end
	local a = 1;
	local spellname, spellrank = GetSpellName(a, BOOKTYPE_SPELL);
	while (spellname) do
		if (spellrank == "") then
			-- only one rank for this spell
			-- set spellrank to be "Rank 1"
			spellrank = 1;
		else
			local start, stop, realrank = string.find(spellrank, "(%d+%.?%d*)");
			if (realrank) then
				realrank = realrank / 1.0;
				spellrank = realrank;
			else
				spellrank = 1;
			end
		end
		local mana, casttime, healmin, healmax, healtime, duration = Healer_GetSpellData(a);
		if (not mana) then
			mana = 0;
		end
		if (mana and casttime and (healmin or healmax or healtime)) then
			HEALER_HEALS[a] = {
				["Spell"] = spellname,
				["Rank"] = spellrank,
				["Mana"] = mana,
				["Casttime"] = casttime,
				["Healmin"] = healmin,
				["Healmax"] = healmax,
				["Healtime"] = healtime,
				["Healduration"] = duration
			};

			-- For spells that are both Heals and Buffs (CRS 'Power Word: Shield' as a buff)
			if (HEALER_BUFFS[spellname]) then
				if (HEALER_BUFFS[spellname]["Levels"]) then
					if (HEALER_BUFFS[spellname]["Levels"][spellrank]) then
						HEALER_BUFFS[spellname]["Levels"][spellrank]["Mana"] = mana;
						HEALER_BUFFS[spellname]["Levels"][spellrank]["ID"] = a;
					end
				else
					HEALER_BUFFS[spellname]["Mana"] = mana;
					HEALER_BUFFS[spellname]["ID"] = a;
				end
			end


		elseif (mana and HEALER_DEBUFFS[spellname] and HEALER_DEBUFFS[spellname][spellrank]) then
			HEALER_DEBUFFS[spellname][spellrank]["Mana"] = mana;
			HEALER_DEBUFFS[spellname][spellrank]["ID"] = a;
		elseif (mana and HEALER_BUFFS[spellname]) then
			if (HEALER_BUFFS[spellname]["Levels"]) then
				if (HEALER_BUFFS[spellname]["Levels"][spellrank]) then
					HEALER_BUFFS[spellname]["Levels"][spellrank]["Mana"] = mana;
					HEALER_BUFFS[spellname]["Levels"][spellrank]["ID"] = a;
				end
			else
				HEALER_BUFFS[spellname]["Mana"] = mana;
				HEALER_BUFFS[spellname]["ID"] = a;
			end
		elseif (REVIVES[spellname]) then
			HEALER_REVIVE = {
				["Spell"] = spellname,
				["Rank"] = spellrank,
				["ID"] = a,
				["Casttime"] = casttime,
				["Mana"] = mana
			};
		elseif (duration) then
			-- this is a dot :)
			HEALER_DOTS[spellname] = duration;
		end
		-- NUKER_NUKES is a bit special, we want to save all abilities we got
		if (spellname and spellrank and a) then
			if (not NUKER_NUKES[spellname]) then
				NUKER_NUKES[spellname] = {};
			end
			NUKER_NUKES[spellname][spellrank] = {
				["Cost"] = mana,
				["Duration"] = duration,
				["ID"] = a
			};
			-- this is a bit cheating, but some spells/abilties only got the last rank stored
			if (not NUKER_NUKES[spellname][1]) then
				NUKER_NUKES[spellname][1] = NUKER_NUKES[spellname][spellrank];
			end
		end
		a = a + 1;
		spellname, spellrank = GetSpellName(a, BOOKTYPE_SPELL);
	end
	-- clean up HEALER_BUFFS and HEALER_DEBUFFS
	for buffname, buffdata in HEALER_BUFFS do
		if (HEALER_BUFFS[buffname]["Levels"]) then
			local gotit;
			for rankindex, rank in buffdata["Levels"] do
				if (not rank["ID"]) then
					HEALER_BUFFS[buffname][rankindex] = nil;
				else
					gotit = 1;
				end
			end
			if (not gotit) then
				-- we don't have this spell, remove it from the list
				HEALER_BUFFS[buffname] = nil;
			end
		else
			if (not buffdata["ID"]) then
				-- we don't have this spell, remove it from the list
				HEALER_BUFFS[buffname] = nil;
			end
		end
	end
	for spellname, spell in HEALER_DEBUFFS do
		local gotit;
		for rankindex, rank in spell do
			if (not rank["ID"]) then
				-- we don't have this rank, remove it from the list
				HEALER_DEBUFFS[spellname][rankindex] = nil;
			else
				-- we got this spell, learn what kind of magic we can remove
				if (rank[TYPE_CURSE]) then
					HEALER_DEBUFFS_CAN_CURE_TYPES[TYPE_CURSE] = 1;
				end
				if (rank[TYPE_DISEASE]) then
					HEALER_DEBUFFS_CAN_CURE_TYPES[TYPE_DISEASE] = 1;
				end
				if (rank[TYPE_MAGIC]) then
					HEALER_DEBUFFS_CAN_CURE_TYPES[TYPE_MAGIC] = 1;
				end
				if (rank[TYPE_POISON]) then
					HEALER_DEBUFFS_CAN_CURE_TYPES[TYPE_POISON] = 1;
				end
				gotit = 1;
			end
		end
		if (not gotit) then
			-- we don't have the spell, remove it from the list
			HEALER_DEBUFFS[spellname] = nil;
		end
	end
	-- set up gui now
	HealerGUI_SetUp();
	NukerGUI_SetUp();
end

function Healer_GetSpellData(spellid)
	C_TooltipTextLeft1:SetText();
	C_TooltipTextLeft2:SetText();
	C_TooltipTextLeft3:SetText();
	C_TooltipTextRight3:SetText();
	C_TooltipTextLeft4:SetText();
	C_TooltipTextLeft5:SetText();
	C_TooltipTextLeft6:SetText();
	C_TooltipTextLeft7:SetText();
	C_TooltipTextLeft8:SetText();
	C_Tooltip:SetSpell(spellid, BOOKTYPE_SPELL);
	local spellname = C_TooltipTextLeft1:GetText();
	local spellmana = C_TooltipTextLeft2:GetText();
	local spelltime = C_TooltipTextLeft3:GetText();
	local spelltext = C_TooltipTextLeft4:GetText();
	local spelltext2 = C_TooltipTextLeft5:GetText();
	local spelltext3 = C_TooltipTextLeft6:GetText();
	local spelltext4 = C_TooltipTextLeft7:GetText();
	local spelltext5 = C_TooltipTextLeft8:GetText();
	if (not spellmana or not spelltime or not spelltext) then
		return;
	end
	if (spelltext2) then
		spelltext = spelltext .. spelltext2;
	end
	if (spelltext3) then
		spelltext = spelltext .. spelltext3;
	end
	if (spelltext4) then
		spelltext = spelltext .. spelltext4;
	end
	if (spelltext5) then
		spelltext = spelltext .. spelltext5;
	end
	spellmana = string.gsub(spellmana, ",", ".");
	spelltime = string.gsub(spelltime, ",", ".");
	spelltext = string.gsub(spelltext, ",", ".");
	local start, stop, mana, casttime, healmin, healmax, healtime, duration;
	start, stop, mana = string.find(spellmana, "(%d+%.?%d*)");
	if (mana) then
		mana = mana / 1.0;
	else
		-- can this happen?
		mana = 0;
	end
	if (spelltime == HEAL_INSTANT) then
		casttime = 0;
	else
		start, stop, casttime = string.find(spelltime, "(%d+%.?%d*)");
		if (casttime) then
			casttime = casttime / 1.0;
		end
	end
	start, stop, healmin, healmax, healtime, duration = string.find(spelltext, HEAL_TEXT_1);
	if (healmin and healmax and healtime and duration) then
		healmin = healmin / 1.0;
		healmax = healmax / 1.0;
		healtime = healtime / 1.0;
		duration = duration / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	start, stop, healmin, healmax, healtimea, healtimeb, duration = string.find(spelltext, HEAL_TEXT_1b);
	if (healmin and healmax and healtimea and healtimeb and duration) then
		healmin = healmin / 1.0;
		healmax = healmax / 1.0;
		healtimea = healtimea / 1.0;
		healtimeb = healtimeb / 1.0;
		healtime = (healtimea + healtimeb) / 2.0;
		duration = duration / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	start, stop, healmin, healmax = string.find(spelltext, HEAL_TEXT_2);
	if (healmin and healmax) then
		healmin = healmin / 1.0;
		healmax = healmax / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	if (GetLocale() == "deDE") then
		-- german client got this one reversed
		start, stop, duration, healtime = string.find(spelltext, HEAL_TEXT_3);
	else
		start, stop, healtime, duration = string.find(spelltext, HEAL_TEXT_3);
	end
	if (healtime and duration) then
		healtime = healtime / 1.0;
		duration = duration / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	if (GetLocale() == "deDE") then
		-- german client got this one reversed
		start, stop, duration, healtimea, healtimeb = string.find(spelltext, HEAL_TEXT_3b);
	else
		start, stop, healtimea, healtimeb, duration = string.find(spelltext, HEAL_TEXT_3b);
	end
	if (healtimea and healtimeb and duration) then
		healtimea = healtimea / 1.0;
		healtimeb = healtimeb / 1.0;
		healtime = (healtimea + healtimeb) / 2.0;
		duration = duration / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	start, stop, healmin, healmax = string.find(spelltext, HEAL_TEXT_4);
	if (healmin and healmax) then
		healmin = healmin / 1.0;
		healmax = healmax / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	if (GetLocale() == "deDE") then
		-- german client got this one reversed
		start, stop, duration, healtime = string.find(spelltext, HEAL_TEXT_5);
	else
		start, stop, healtime, duration = string.find(spelltext, HEAL_TEXT_5);
	end
	if (healtime and duration) then
		healtime = healtime / 1.0;
		duration = duration / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	if (GetLocale() == "deDE") then
		-- german client got this one reversed
		start, stop, duration, healtimea, healtimeb = string.find(spelltext, HEAL_TEXT_5b);
	else
		start, stop, healtimea, healtimeb, duration = string.find(spelltext, HEAL_TEXT_5b);
	end
	if (healtimea and healtimeb and duration) then
		healtimea = healtimea / 1.0;
		healtimeb = healtimeb / 1.0;
		healtime = (healtimea + healtimeb) / 2.0;
		duration = duration / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	start, stop, healmin, healmax = string.find(spelltext, HEAL_TEXT_6);
	if (healmin and healmax) then
		healmin = healmin / 1.0;
		healmax = healmax / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	start, stop, healmin, healmax = string.find(spelltext, HEAL_TEXT_7);
	if (healmin and healmax) then
		-- chain heal, shouldn't be used with other healing spells
		healmin = healmin / 1.0;
		healmax = healmax / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	start, stop, healmin = string.find(spelltext, HEAL_TEXT_8);
	if (healmin) then
		-- power word: shield. make it look really good :)
		healmin = healmin / 1.0;
		healmax = healmin / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	start, stop, healmin, healmax = string.find(spelltext, HEAL_TEXT_9);
	if (healmin and healmax) then
		healmin = healmin / 1.0;
		healmax = healmax / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	if (spellname == SPELL_BOP) then
		-- blessing of protection, tricky one :\
		healmin = mana;
		healmax = mana;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	-- some dots
	spelltext = string.lower(spelltext);
	start, stop, duration = string.find(spelltext, DOT_TEXT_1);
	if (not duration) then
		start, stop, duration = string.find(spelltext, DOT_TEXT_2);
	end
	if (not duration) then
		start, stop, duration = string.find(spelltext, DOT_TEXT_3);
	end
	if (not duration) then
		start, stop, duration = string.find(spelltext, DOT_TEXT_4);
	end
	if (duration) then
		duration = duration / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration;
	end
	if (not duration) then
		start, stop, duration = string.find(spelltext, DOT_TEXT_5);
	end
	if (not duration) then
		start, stop, duration = string.find(spelltext, DOT_TEXT_6);
	end
	if (not duration) then
		start, stop, duration = string.find(spelltext, DOT_TEXT_7);
	end
	if (not duration) then
		start, stop, duration = string.find(spelltext, DOT_TEXT_8);
	end
	if (duration) then
		duration = duration / 1.0;
		return mana, casttime, healmin, healmax, healtime, duration * 60;
	end
	return mana, casttime, healmin, healmax, healtime, duration;
end

function Healer_RemoveDebuffCheckTarget(person)
	if(Healer_UseOldRemoveDebuffCheck) then
		return Healer_OldRemoveDebuffCheckTarget(person)
	else
		return Healer_NewRemoveDebuffCheckTarget(person)
	end
end

function Healer_NewRemoveDebuffCheckTarget(person)
	-- check whether this target got a debuff we can remove
	if (not Healer_CanCastOn(person)) then
		return nil, nil, nil, nil, 0;
	end

	local castspell, castid, oom;
	local castrank = -1;
	local castmana = -1;
	local priority = -1;

	-- Clear beingcured table
	Healer_beingcured=(Healer_beingcured or {});
	Healer_beingcured[TYPE_CURSE] = nil;
	Healer_beingcured[TYPE_DISEASE] = nil;
	Healer_beingcured[TYPE_MAGIC] = nil;
	Healer_beingcured[TYPE_POISON] = nil;
	
	-- check if the target already got a (known) buff that removes debuffs ("abolist poison" for example)
	for spellname, spell in HEALER_DEBUFFS do
		if (Healer_GotBuff(person, spellname)) then
			for rankindex, rank in spell do
				Healer_beingcured[TYPE_CURSE] = rank[TYPE_CURSE];
				Healer_beingcured[TYPE_DISEASE] = rank[TYPE_DISEASE];
				Healer_beingcured[TYPE_MAGIC] = rank[TYPE_MAGIC];
				Healer_beingcured[TYPE_POISON] = rank[TYPE_POISON];
			end
		end
	end

	Healer_UpdatePlayerDataWrapper(person);

	local name = Healer_Unit2CName(person);
	local numCurableDebuffs = 0;

	for texture, data in C_player_data[name]["Debuff"] do
		if (data["Tick"] == C_player_data[name]["CurrentTick"]) then
			local canBeCured = false;
			local debuffname=data["Name"];
			local debufftype=data["Type"];
			if (debufftype and not HEALER_DEBUFF_LIST[debuffname] and not HEALER_DEBUFF_NEW[debuffname]) then
				local text=data["Text"];
				HEALER_DEBUFF_NEW[debuffname] = {
					["Type"] = debufftype,
					["Text"] = text
				};	
				if (HEALER_DEBUFFS_CAN_CURE_TYPES[debufftype]) then
					-- we can cure this debuff, alert the user
					-- even if we can't cure it, we learn it anyways
					Healer_Print("New debuff learned (" .. debuffname .. ")");
				end
				-- save, just in case (it's quick anyways)
				Healer_Save();
			end
			
			if (debufftype and not Healer_beingcured[debufftype]) then
				for spellname, spell in HEALER_DEBUFFS do
					for rankindex, rank in spell do
						if (rank["Mana"] <= UnitMana("player")) then
							if (rank["ID"] and rank[debufftype] and (not rank["SpellLevel"] or rank["SpellLevel"] - 10 <= UnitLevel(person))) then
								canBeCured = true;

								-- we got a spell that can remove this debuff
								if (not HEALER_DEBUFF_LIST[debuffname]) then
									-- we haven't set up this debuff yet
									if ((priority == -1 or castspell == spellname) and rankindex > castrank) then
										-- this debuffer is probably better than the previous
										castspell = spellname;
										castrank = rankindex;
										castid = rank["ID"];
										priority = 0;
										castmana = rank["Mana"];
										oom = nil;
									end
								elseif (HEALER_DEBUFF_LIST[debuffname][CLASS_SELF] and (person == "player" or (person == "target" and UnitIsUnit("player", "target"))) and HEALER_DEBUFF_LIST[debuffname][CLASS_SELF] >= priority) then
									-- we're supposed to clean ourself in battle
									if (rankindex > castrank) then
										-- this debuffer is probably better than the previous
										castspell = spellname;
										castrank = rankindex;
										castid = rank["ID"];
										priority = HEALER_DEBUFF_LIST[debuffname][CLASS_SELF];
										castmana = rank["Mana"];
										oom = nil;
									end
								elseif (not HEALER_DEBUFF_LIST[debuffname][UnitClass(person)]) then
									-- we're not supposed to clean this unitclass in battle
									if (not HEALER_IN_BATTLE and (priority == -1 or castspell == spellname) and rankindex > castrank) then
										-- but we're not in battle :)
										-- this debuffer is probably better than the previous
										castspell = spellname;
										castrank = rankindex;
										castid = rank["ID"];
										priority = 0;
										castmana = rank["Mana"];
										oom = nil;
									end
								elseif (HEALER_DEBUFF_LIST[debuffname][UnitClass(person)] >= priority) then
									-- we're supposed to clean this unitclass in battle
									if (rankindex > castrank) then
										-- this debuffer is probably better than the previous
										castspell = spellname;
										castrank = rankindex;
										castid = rank["ID"];
										priority = HEALER_DEBUFF_LIST[debuffname][UnitClass(person)];
										castmana = rank["Mana"];
										oom = nil;
									end
								end
							end
						else
							-- not enough mana
							oom = 1;
						end
					end
				end
				if(canBeCured) then
					numCurableDebuffs = numCurableDebuffs + 1;
				end
			end
		end
	end
	if (not castid and oom) then
		priority = 1;
		person = nil;
	end
	return person, castspell, castrank, castid, priority, numCurableDebuffs;
end

function Healer_OldRemoveDebuffCheckTarget(person)
	-- check whether this target got a debuff we can remove
	if (not Healer_CanCastOn(person)) then
		return nil, nil, nil, nil, 0;
	end
	local a = 1;
	C_TooltipTextLeft1:SetText();
	C_TooltipTextLeft2:SetText();
	C_TooltipTextLeft3:SetText();
	C_TooltipTextLeft4:SetText();
	C_TooltipTextLeft5:SetText();
	C_TooltipTextLeft6:SetText();
	C_TooltipTextRight1:SetText();
	C_Tooltip:SetUnitDebuff(person, a);
	local debuffname = C_TooltipTextLeft1:GetText();
	local debufftext1 = C_TooltipTextLeft2:GetText();
	local debufftext2 = C_TooltipTextLeft3:GetText();
	local debufftext3 = C_TooltipTextLeft4:GetText();
	local debufftext4 = C_TooltipTextLeft5:GetText();
	local debufftext5 = C_TooltipTextLeft6:GetText();
	local debufftype = C_TooltipTextRight1:GetText();
	local castspell, castid, oom;
	local castrank = -1;
	local castmana = -1;
	local priority = -1;
	local beingcured = {};

	-- check if the target already got a (known) buff that removes debuffs ("abolist poison" for example)
	for spellname, spell in HEALER_DEBUFFS do
		if (Healer_GotBuff(person, spellname)) then
			for rankindex, rank in spell do
				beingcured[TYPE_CURSE] = rank[TYPE_CURSE];
				beingcured[TYPE_DISEASE] = rank[TYPE_DISEASE];
				beingcured[TYPE_MAGIC] = rank[TYPE_MAGIC];
				beingcured[TYPE_POISON] = rank[TYPE_POISON];
			end
		end
	end
	while (debuffname and a <= 16) do
		if (debufftype and not HEALER_DEBUFF_LIST[debuffname] and not HEALER_DEBUFF_NEW[debuffname]) then
			-- ooh, a new debuff. we gotta learn this one :)
			local text = debufftext1;
			if (debufftext2) then
				text = text .. "\n" .. debufftext2;
			end
			if (debufftext3) then
				text = text .. "\n" .. debufftext3;
			end
			if (debufftext4) then
				text = text .. "\n" .. debufftext4;
			end
			if (debufftext5) then
				text = text .. "\n" .. debufftext5;
			end
			HEALER_DEBUFF_NEW[debuffname] = {
				["Type"] = debufftype,
				["Text"] = text
			};
			if (HEALER_DEBUFFS_CAN_CURE_TYPES[debufftype]) then
				-- we can cure this debuff, alert the user
				-- even if we can't cure it, we learn it anyways
				Healer_Print("New debuff learned (" .. debuffname .. ")");
			end
			-- save, just in case (it's quick anyways)
			Healer_Save();
		end
		if (debufftype and not beingcured[debufftype]) then
			for spellname, spell in HEALER_DEBUFFS do
				for rankindex, rank in spell do
					if (rank["Mana"] <= UnitMana("player")) then
						if (rank["ID"] and rank[debufftype] and (not rank["SpellLevel"] or rank["SpellLevel"] - 10 <= UnitLevel(person))) then
							-- we got a spell that can remove this debuff
							if (not HEALER_DEBUFF_LIST[debuffname]) then
								-- we haven't set up this debuff yet
								if ((priority == -1 or castspell == spellname) and rankindex > castrank) then
									-- this debuffer is probably better than the previous
									castspell = spellname;
									castrank = rankindex;
									castid = rank["ID"];
									priority = 0;
									castmana = rank["Mana"];
									oom = nil;
								end
							elseif (HEALER_DEBUFF_LIST[debuffname][CLASS_SELF] and (person == "player" or (person == "target" and UnitIsUnit("player", "target"))) and HEALER_DEBUFF_LIST[debuffname][CLASS_SELF] >= priority) then
								-- we're supposed to clean ourself in battle
								if (rankindex > castrank) then
									-- this debuffer is probably better than the previous
									castspell = spellname;
									castrank = rankindex;
									castid = rank["ID"];
									priority = HEALER_DEBUFF_LIST[debuffname][CLASS_SELF];
									castmana = rank["Mana"];
									oom = nil;
								end
							elseif (not HEALER_DEBUFF_LIST[debuffname][UnitClass(person)]) then
								--[[
								-- we're not supposed to clean this unitclass in battle
								if (not HEALER_IN_BATTLE and (priority == -1 or castspell == spellname) and rankindex > castrank) then
									-- but we're not in battle :)
									-- this debuffer is probably better than the previous
									castspell = spellname;
									castrank = rankindex;
									castid = rank["ID"];
									priority = 0;
									castmana = rank["Mana"];
									oom = nil;
								end
								]]--
							elseif (HEALER_DEBUFF_LIST[debuffname][UnitClass(person)] >= priority) then
								-- we're supposed to clean this unitclass in battle
								if (rankindex > castrank) then
									-- this debuffer is probably better than the previous
									castspell = spellname;
									castrank = rankindex;
									castid = rank["ID"];
									priority = HEALER_DEBUFF_LIST[debuffname][UnitClass(person)];
									castmana = rank["Mana"];
									oom = nil;
								end
							end
						end
					else
						-- not enough mana
						oom = 1;
					end
				end
			end
		end
		a = a + 1;
		C_TooltipTextLeft1:SetText();
		C_TooltipTextLeft2:SetText();
		C_TooltipTextLeft3:SetText();
		C_TooltipTextLeft4:SetText();
		C_TooltipTextLeft5:SetText();
		C_TooltipTextLeft6:SetText();
		C_TooltipTextRight1:SetText();
		C_Tooltip:SetUnitDebuff(person, a);
		debuffname = C_TooltipTextLeft1:GetText();
		debufftext1 = C_TooltipTextLeft2:GetText();
		debufftext2 = C_TooltipTextLeft3:GetText();
		debufftext3 = C_TooltipTextLeft4:GetText();
		debufftext4 = C_TooltipTextLeft5:GetText();
		debufftext5 = C_TooltipTextLeft6:GetText();
		debufftype = C_TooltipTextRight1:GetText();
	end
	if (not castid and oom) then
		priority = 1;
		person = nil;
	end
	return person, castspell, castrank, castid, priority;
end

function Healer_RemoveDebuff()
	-- remove a debuff from a friendly target
	-- target
	if (UnitIsFriend("player", "target") or Healer_GotDebuff("target", SPELL_MIND_CONTROL)) then
		local b, c, d, e, f, g = Healer_RemoveDebuffCheckTarget("target");
		-- if we've targetted a friendly player cure that player first
		if (e and f >= 0) then
			return b, c, d, e, f;
		end
	end
	local person, castspell, castrank, castid, priority, numCurableDebuffs = Healer_RemoveDebuffCheckTarget("player");
	-- party
	for a = 1, GetNumPartyMembers() do
		b, c, d, e, f, g = Healer_RemoveDebuffCheckTarget("party" .. a);
		if (d and (f > priority or (f == 0 and priority == 0 and (UnitClass(b) == CLASS_DRUID or UnitClass(b) == CLASS_PRIEST)))) then
			person = b;
			castspell = c;
			castrank = d;
			castid = e;
			priority = f;
		end
	end
	-- raid
	if ((not HEALER_AUTOCASTING and HEALER_DEBUFF_RAID) or (HEALER_AUTOCASTING and HEALER_AUTODEBUFF_RAID)) then
		for a = 1, GetNumRaidMembers() do
			b, c, d, e, f, g = Healer_RemoveDebuffCheckTarget("raid" .. a);
			if (d and (f > priority or (f == 0 and priority == 0 and (UnitClass(b) == CLASS_DRUID or UnitClass(b) == CLASS_PRIEST)))) then
				person = b;
				castspell = c;
				castrank = d;
				castid = e;
				priority = f;
			end
		end
	end
	-- pets
	if (HEALER_DEBUFF_PETS) then
		-- partypets
		for a = 1, GetNumPartyMembers() do
			b, c, d, e, f, g = Healer_RemoveDebuffCheckTarget("partypet" .. a);
			if (d and (not priority or f > priority)) then
				person = b;
				castspell = c;
				castrank = d;
				castid = e;
				priority = f;
			end
		end
		-- raidpets
		if ((not HEALER_AUTOCASTING and HEALER_DEBUFF_RAID) or (HEALER_AUTOCASTING and HEALER_AUTODEBUFF_RAID)) then
			for a = 1, GetNumRaidMembers() do
				b, c, d, e, f, g = Healer_RemoveDebuffCheckTarget("raidpet" .. a);
				if (d and (not priority or f > priority)) then
					person = b;
					castspell = c;
					castrank = d;
					castid = e;
					priority = f;
				end
			end
		end
	end

	if (priority == 0) then
		priority = nil;
	end
	return person, castspell, castrank, castid, priority;
end

function Healer_GotBuff(person, buff)
	if (not person or not buff or not UnitExists(person) or UnitHealth(person) <= 1) then
		return;
	end
	if(not Healer_UseOldChecks) then
		-- If weapon buffs, check manually
		if (HEALER_BUFFS and HEALER_BUFFS[buff] and HEALER_BUFFS[buff]["Weapon"]) then
			-- we don't really need a cache on weaponbuff as we (should) only check it once per buffclass
			local start, stop, alt = string.find(buff, "(.+)%s+Weapon");
			C_Tooltip:SetInventoryItem(person, 16);
			for a = 1, C_Tooltip:NumLines() do
				local text = getglobal("C_TooltipTextLeft" .. a);
				if (not text or not text:GetText() or string.find(text:GetText(), buff) or (alt and string.find(text:GetText(), alt))) then
					-- player seems to have this weapon buff
					return a;
				end
			end
			-- player don't have this weaponbuff
			return;
		end

		Healer_UpdatePlayerDataWrapper(person);

		-- If buff has super, check for that
		if(HEALER_BUFFS and HEALER_BUFFS[buff] and HEALER_BUFFS[buff]["Super"]) then
			local gotsuper=C_UnitGotBuff(person, HEALER_BUFFS[buff]["Super"]);
			if(gotsuper) then return gotsuper;end;
		end

		-- Check for buff
		return C_UnitGotBuff(person, buff);
	else
		return Healer_GotBuff_Old(person, buff);
	end
end

function Healer_GotBuff_Old(person, buff)
	if (not person or not buff or not UnitExists(person) or UnitHealth(person) <= 1) then
		return;
	end
	if (HEALER_BUFFS[buff] and HEALER_BUFFS[buff]["Weapon"]) then
		-- we don't really need a cache on weaponbuff as we (should) only check it once per buffclass
		local start, stop, alt = string.find(buff, "(.+)%s+Weapon");
		C_Tooltip:SetInventoryItem(person, 16);
		for a = 1, C_Tooltip:NumLines() do
			local text = getglobal("C_TooltipTextLeft" .. a);
			if (not text or not text:GetText() or string.find(text:GetText(), buff) or (alt and string.find(text:GetText(), alt))) then
				-- player seems to have this weapon buff
				return a;
			end
		end
		-- player don't have this weaponbuff
		return;
	end
	if (HEALER_BUFF_CACHE[person]) then
		-- let's make a simple cache to speed up things
		if (HEALER_BUFF_CACHE[person][buff]) then
			-- got this buff :)
			return HEALER_BUFF_CACHE[person][buff];
		elseif (HEALER_BUFFS[buff] and HEALER_BUFF_CACHE[person][HEALER_BUFFS[buff]["Super"]]) then
			-- got a superior buff :)
			return HEALER_BUFF_CACHE[person][HEALER_BUFFS[buff]["Super"]];
		end
		-- person don't have this buff
		return;
	end
	HEALER_BUFF_CACHE[person] = {};
	local gotit;
	local a = 1;
	C_TooltipTextLeft1:SetText();
	C_Tooltip:SetUnitBuff(person, a);
	local buffname = C_TooltipTextLeft1:GetText();

	-- loop thru the buffs this player got
	while (buffname and a <= 16) do
		if (buffname == buff or (HEALER_BUFFS[buff] and buffname == HEALER_BUFFS[buff]["Super"])) then
			-- this player got this buff
			gotit = a;
		end
		HEALER_BUFF_CACHE[person][buffname] = a;
		a = a + 1;
		C_TooltipTextLeft1:SetText();
		C_Tooltip:SetUnitBuff(person, a);
		buffname = C_TooltipTextLeft1:GetText();
	end
	return gotit;
end

function Healer_GetDebuffs(person)
	if (not person or not UnitExists(person)) then
		return;
	end
	local a = 1;
	local debuffs = {};
	C_TooltipTextLeft1:SetText();
	C_Tooltip:SetUnitDebuff(person, a);
	local buffname = C_TooltipTextLeft1:GetText();

	-- loop thru the debuffs this player got
	while (buffname and a <= 16) do
		debuffs[buffname] = a;
		a = a + 1;
		C_TooltipTextLeft1:SetText();
		C_Tooltip:SetUnitDebuff(person, a);
		buffname = C_TooltipTextLeft1:GetText();
	end
	return debuffs;
end

function Healer_GotDebuff(person, debuff)
	if (not person or not debuff or not UnitExists(person) or UnitHealth(person) <= 1) then
		return;
	end
	if(not Healer_UseOldChecks) then
		Healer_UpdatePlayerDataWrapper(person);
		return C_UnitGotDebuff(person, debuff);
	else	
		return Healer_GotDebuff_old(person, debuff);
	end
end

function Healer_GotDebuff_old(person, debuff)
	if (not person or not debuff or not UnitExists(person)) then
		return;
	end
	local a = 1;
	C_TooltipTextLeft1:SetText();
	C_Tooltip:SetUnitDebuff(person, a);
	local buffname = C_TooltipTextLeft1:GetText();

	-- loop thru the debuffs this player got
	while (buffname and a <= 16) do
		if (buffname == debuff) then
			-- this player got this debuff
			return a;
		end
		a = a + 1;
		C_TooltipTextLeft1:SetText();
		C_Tooltip:SetUnitDebuff(person, a);
		buffname = C_TooltipTextLeft1:GetText();
	end
	-- this player does not have this debuff
	return;
end

function Healer_CastBuffCheckTarget(person, buffclass, cancast, minCooldown)
	if (not Healer_CanCastOn(person)) then
		return;
	end
	if (UnitClass("player") == CLASS_PALADIN and (Healer_GotBuff(person, SPELL_BOP) or Healer_GotBuff(person, SPELL_BOF))) then
		-- we're a paladin, and this person got the buff "blessing of protection" or "blessing of freedom"
		-- let's not buff as that might remove the protection
		return;
	end
	local castbuff, castrank, castid, pri, cooldown, oom;
	local numBuffsNeeded=0;
	local notready;
	for buffname, buffdata in HEALER_BUFFS do
		-- ooh, the next line is pretty... or maybe not :\
		if (HEALER_CAST_BUFF_IN_BATTLE or ((not HEALER_AUTOCASTING or not HEALER_IN_BATTLE) or (buffdata["Selfcast"] and HEALER_CAST_SELFBUFF_IN_BATTLE)) and (not buffdata["Selfcast"] or (person == "player" or (person == "target" and UnitIsUnit("player", "target"))))) then
			local id, mana, buffrank, moonkin;
			if (not buffdata["ID"]) then
				-- this is a spell with more than 1 rank, figure out which one to use
				for rankindex, rank in buffdata["Levels"] do
					if (rank["ID"] and rank["Level"] and rank["Level"] - 10 <= UnitLevel(person) and (not id or rank["ID"] > id)) then
						id = rank["ID"];
						mana = rank["Mana"];
						buffrank = rankindex;
					end
				end
			else
				-- only one rank (or selfbuff) for this buff
				id = buffdata["ID"];
				mana = buffdata["Mana"];
			end
			if (id and mana and (cancast ~= 2 or buffdata["Moonkin"])) then
				local spellstart, spellduration = GetSpellCooldown(id, 1);
				local cooldownRemaining = spellduration - ( GetTime() - spellstart);
				if (spellstart > 0 and cooldownRemaining > (minCooldown or 0)) then
					-- cooldown on spell
					cooldown = 1;
					if (Healer_InBuffClass(UnitClass(person), buffname, buffclass) >= 0 or Healer_InBuffClass(CLASS_SELF, buffname, buffclass) >= 0) then
						if (notready) then
							notready = notready .. ", " .. buffname;
						else
							notready = buffname;
						end
					end
				else
					local tmppri;
					if (person == "player" or UnitIsUnit(person, "player")) then
						tmppri = Healer_InBuffClass(CLASS_SELF, buffname, buffclass);
						if (tmppri < 0) then
							tmppri = Healer_InBuffClass(UnitClass(person), buffname, buffclass);
						end
					else
						tmppri = Healer_InBuffClass(UnitClass(person), buffname, buffclass);
					end

					Healer_WhisperCheckInit();

					-- added by pilardi for WhisperCast
					if (HEALER_WHISPERCAST[UnitName(person)] and HEALER_WHISPERCAST[UnitName(person)][buffname]) then
						-- this person wants this buff, let's give buff this person
						tmppri = 10;
					elseif (UnitClass("player") == CLASS_PALADIN and HEALER_WHISPERCAST[UnitName(person)] and buffname~=SPELL_RIGHTEOUS_FURY and buffname~=SPELL_DIVINE_FAVOR) then
						-- but we're a paladin, so we have to remove other blessings if we're overriding
						for buffname, one in HEALER_WHISPERCAST[UnitName(person)] do
							tmppri = -1;
						end
					end

					-- added by pilardi for WhisperNoCast
					if (HEALER_WHISPERNOCAST[UnitName(person)] and HEALER_WHISPERNOCAST[UnitName(person)][buffname]) then
						-- if user has whispered "no [buffname]" don't cast this one 
						tmppri = -1;
					end

					-- CRS A priest can't case 'Fear Ward' while in Shadowform
					if (buffname == SPELL_FEAR_WARD and Healer_GotBuff("player", SPELL_SHADOWFORM)) then
						tmppri = -1;
					end

					if (tmppri > 0 and not Healer_GotBuff(person, buffname)) then
						numBuffsNeeded = numBuffsNeeded + 1;
						if (not pri or tmppri > pri or not castid) then
							if (mana <= UnitMana("player")) then
								castbuff = buffname;
								castrank = buffrank;
								castid = id;
								pri = tmppri;
								oom = nil;
							else
								-- can't afford casting :\
								castbuff = buffname;
								castrank = buffrank;
								oom = 1;
							end
						end
					end
				end
			end
		end
	end
	if (not castid and oom) then
		pri = 1;
		person = nil;
	end
	if (not castid and cooldown) then
		pri = 2;
		castbuff = notready;
		person = nil;
	end
	return person, castbuff, castrank, castid, pri, numBuffsNeeded;
end

function Healer_CastBuff(buffclass, cancast)
	-- put a buff on a friendly target
	-- target
	local person, castbuff, castrank, castid, pri, numBuffsNeeded;
	if (UnitIsFriend("player", "target") and (not HEALER_AUTOCASTING or (UnitPlayerControlled("target") and HEALER_AUTOBUFF_TARGET))) then
		-- if we've targetted a friendly target, buff this friendly target :)
		person, castbuff, castrank, castid, pri, numBuffsNeeded = Healer_CastBuffCheckTarget("target", buffclass, cancast);
		if (castbuff) then
			return person, castbuff, castrank, castid, pri;
		end
	end
	-- player
	person, castbuff, castrank, castid, pri, numBuffsNeeded = Healer_CastBuffCheckTarget("player", buffclass, cancast);
	-- party
	for a = 1, GetNumPartyMembers() do
		local b, c, d, e, f, g = Healer_CastBuffCheckTarget("party" .. a, buffclass, cancast);
		if ((not pri and c and f) or (pri and c and f > pri)) then
			person = b;
			castbuff = c;
			castrank = d;
			castid = e;
			pri = f;
		end
	end
	-- raid
	if ((not HEALER_AUTOCASTING and HEALER_BUFF_RAID) or (HEALER_AUTOCASTING and HEALER_AUTOBUFF_RAID)) then
		for a = 1, GetNumRaidMembers() do
			local b, c, d, e, f, g = Healer_CastBuffCheckTarget("raid" .. a, buffclass, cancast);
			if ((not pri and c and f) or (pri and c and f > pri)) then
				person = b;
				castbuff = c;
				castrank = d;
				castid = e;
				pri = f;
			end
		end
	end
	-- partypet
	if (HEALER_BUFF_PETS) then
		for a = 1, GetNumPartyMembers() do
			local b, c, d, e, f, g = Healer_CastBuffCheckTarget("partypet" .. a, buffclass, cancast);
			if ((not pri and c and f) or (pri and c and f > pri)) then
				person = b;
				castbuff = c;
				castrank = d;
				castid = e;
				pri = f;
			end
		end
		-- raidpet
		if ((not HEALER_AUTOCASTING and HEALER_BUFF_RAID) or (HEALER_AUTOCASTING and HEALER_AUTOBUFF_RAID)) then
			for a = 1, GetNumRaidMembers() do
				local b, c, d, e, f, g = Healer_CastBuffCheckTarget("raidpet" .. a, buffclass, cancast);
				if ((not pri and c and f) or (pri and c and f > pri)) then
					person = b;
					castbuff = c;
					castrank = d;
					castid = e;
					pri = f;
				end
			end
		end
	end
	return person, castbuff, castrank, castid, pri;
end

function Healer_InBuffClass(unitclass, buffname, buffclass)
	if (not unitclass or not buffname or not buffclass or not HEALER_BUFF_CLASSES) then
		return -1;
	end
	if (not HEALER_BUFF_CLASSES[buffclass]) then
		return -1;
	end
	if (not HEALER_BUFF_CLASSES[buffclass][unitclass]) then
		return -1;
	end
	if (not HEALER_BUFF_CLASSES[buffclass][unitclass][buffname]) then
		return -1;
	end
	return HEALER_BUFF_CLASSES[buffclass][unitclass][buffname];
end

function Healer_CanRevive(person)
	-- quite like "Healer_CanCastOn()"
	if (HEALER_CANT_CAST_ON[person]==HEALER_CANT_CAST_ON_TICK or not UnitExists(person) or UnitHealth(person) > 1 or not UnitIsVisible(person)) then
		return;
	end
	return 1;
end

function Healer_CanCastOn(person)
	if (HEALER_CANT_CAST_ON[person]==HEALER_CANT_CAST_ON_TICK or not UnitExists(person) or UnitHealth(person) <= 1 or not UnitIsVisible(person)) then
		return;
	end
	if (Healer_GotDebuff(person, SPELL_MIND_CONTROL) and UnitIsFriend("player", person)) then
		-- person got the mc debuff and is a friend, don't heal/buff/debuff
		return;
	end
	if (Healer_GotBuff(person, SPELL_PHASE_SHIFT)) then
		-- probably a shapeshifted imp, let's not do anything with this creature
		return;
	end
	return 1;
end

function Healer_InHealClass(spellname, healclass)
	if (not spellname or not healclass or not HEALER_HEAL_CLASSES) then
		return -1;
	end
	if (not HEALER_HEAL_CLASSES[healclass]) then
		return -1;
	end
	if (not HEALER_HEAL_CLASSES[healclass][spellname]) then
		return -1;
	end
	return HEALER_HEAL_CLASSES[healclass][spellname];
end

function Healer_BestHealSpell(healclass, person, hp, percent)
	-- find the most efficient healing spell & rank of the given healclass to cast
	if (not person or not hp or not percent) then
		person, hp, percent = Healer_MostWounded();
	end
	if (not person or not hp or hp <= 0) then
		-- noone is wounded, no healing
		return;
	end

	if (Healer_GotDebuff(person, SPELL_DEEP_SLUMBER) or Healer_GotDebuff(person, SPELL_BANISH)) then
		-- person got a spell that prevents us from healing him/her
		return;
	end

	local mana = UnitMana("player");
	local castheal = 0;
	local castmana = 0;
	local castpercent = 100;
	local castspell, castrank, castid, oom, targetpercent;
	local gotspell = {}; -- yay for cheap patching :)
	local notready;
	local extrahealing = Healer_EquipHealBonus();
	local gotcc = (Healer_GotBuff("player", SPELL_CLEARCASTING) or Healer_GotBuff("player", SPELL_INNER_FOCUS));
	oom = 1;

	for spellid, spelldata in HEALER_HEALS do
		local spellstart, spellduration = GetSpellCooldown(spellid, 1);
		if (spellstart > 0) then
			-- cooldown on spell
			oom = 2;
			if (not gotspell[spelldata["Spell"]] and Healer_InHealClass(spelldata["Spell"], healclass) >= 0) then
				if (not notready) then
					notready = spelldata["Spell"];
				else
					notready = notready .. ", " .. spelldata["Spell"];
				end
			end
			gotspell[spelldata["Spell"]] = 1;
		else
			if ((spelldata["Mana"] <= mana or gotcc) and (not HEALER_SPELL_LEVELS[spelldata["Spell"]] or HEALER_SPELL_LEVELS[spelldata["Spell"]][spelldata["Rank"]] - 10 <= UnitLevel(person)) and (not HEALER_AUTOCASTING or spelldata["Casttime"] == 0)) then
				targetpercent = Healer_InHealClass(spelldata["Spell"], healclass);
				oom = nil;
				if (not gotspell[spelldata["Spell"]] and targetpercent >= percent) then
					local gotbuff = Healer_GotBuff(person, spelldata["Spell"]);
					if (gotbuff and (percent > 0 or spelldata["Spell"] ~= SPELL_REGROWTH)) then
						Healer_Announce("|cffead9ac", UnitName(person) .. " already got " .. spelldata["Spell"], HEALER_ANNOUNCE_GOT_BUFF, HEALER_BUFF_RAID);
						gotspell[spelldata["Spell"]] = 1;
					elseif (spelldata["Spell"] == SPELL_PWS and Healer_GotDebuff(person, SPELL_WEAKENED_SOUL)) then
						Healer_Announce("|cffead9ac", UnitName(person) .. " got " .. SPELL_WEAKENED_SOUL, HEALER_ANNOUNCE_GOT_BUFF, HEALER_BUFF_RAID);
						gotspell[spelldata["Spell"]] = 1;
					elseif (spelldata["Spell"] == SPELL_BOP and (Healer_GotBuff(person, SPELL_PWS) or Healer_GotBuff(person, SPELL_MANA_SHIELD))) then
						if (Healer_GotBuff(person, SPELL_PWS)) then
							Healer_Announce("|cffead9ac", UnitName(person) .. " got " .. SPELL_PWS, HEALER_ANNOUNCE_GOT_BUFF, HEALER_BUFF_RAID);
						else
							Healer_Announce("|cffead9ac", UnitName(person) .. " got " .. SPELL_MANA_SHIELD, HEALER_ANNOUNCE_GOT_BUFF, HEALER_BUFF_RAID);
						end
						gotspell[spelldata["Spell"]] = 1;
					else
						-- this spell is of the given healclass and the person we're about to heal don't have a buff with same name (healing over time)
						-- now we gotta find the most effective spell
						local spellheal = 0;
						local impactheal = 0;
						if (spelldata["Healmin"] and spelldata["Healmax"]) then
							if (HEALER_IN_BATTLE) then
								spellheal = spellheal + spelldata["Healmin"];
							else
								spellheal = spellheal + spelldata["Healmax"];
							end
							impactheal = (spelldata["Healmin"] + spelldata["Healmax"]) / 2 + (extrahealing * spelldata["Casttime"] / 3.5);
						end
						if (spelldata["Healtime"] and spelldata["Healduration"]) then
							if (HEALER_IN_BATTLE) then
								spellheal = spellheal + (extrahealing + spelldata["Healtime"]) / spelldata["Healduration"];
							else
								spellheal = spellheal + (extrahealing + spelldata["Healtime"]) * 1.5;
							end
						else
							-- if this isn't a hot healing spell, we get some bonus on impact from equipment
							spellheal = spellheal + (extrahealing * (spelldata["Casttime"] / 3.5));
						end
						if (targetpercent <= castpercent and (targetpercent < castpercent or (castheal < hp and spellheal > castheal) or (spellheal >= hp and spelldata["Mana"] < castmana) or (gotcc and spellheal > castheal))) then
							-- this spell is better than the previous ;)
							castspell = spelldata["Spell"];
							castrank = spelldata["Rank"];
							castheal = spellheal;
							castmana = spelldata["Mana"];
							castid = spellid;
							castpercent = targetpercent;
							local cancelheal = hp;
							if (hp > castheal or (UnitIsFriend("player", "target") and UnitHealthMax("target") ~= 100)) then
								-- target healing or using a weak healing spell, set healing done to the "correct" value
								cancelheal = castheal;
							end
							if (spelldata["Casttime"] > 0) then
								HEALER_ACTION = {
									["Person"] = person,
									["Name"] = UnitName(person),
									["Spell"] = castspell,
									["Rank"] = castrank,
									["Heal"] = cancelheal,
									["ImpactHeal"] = impactheal,
									["Curtime"] = spelldata["Casttime"],
									["Casttime"] = spelldata["Casttime"],
									["ID"] = castid,
									["Percent"] = targetpercent,
									["GotBuff"] = gotbuff
								};
								if (percent == 0) then
									-- we're target/tank healing, save that in HEALER_ACTION
									HEALER_ACTION["TankUnit"] = person;
								end
							else
								HEALER_ACTION = nil;
							end
						end
					end
				end
			end
		end
	end
	if (oom and not castid) then
		person = nil;
		if (oom == 2) then
			castspell = notready;
		end
	end
	-- check if we got a buff that decrease our casting time
	if (HEALER_ACTION and HEALER_ACTION["Casttime"] and Healer_GotBuff("player", SPELL_NATURES_GRACE)) then
		-- decrease casting time with 1 sec
		HEALER_ACTION["Casttime"] = HEALER_ACTION["Casttime"] - 1;
		HEALER_ACTION["Curtime"] = HEALER_ACTION["Casttime"];
	elseif (HEALER_ACTION and Healer_GotBuff("player", SPELL_NATURES_SWIFTNESS)) then
		-- instant
		HEALER_ACTION = nil;
	end
	return person, castspell, castrank, castid, oom;
end

function Healer_MostWounded()
	-- which person in the party/raid is most wounded
	-- if we've targetted a friendly player, then that overrides this method
	if (UnitIsFriend("player", "target")) then
		if (not Healer_CanCastOn("target")) then
			return nil, 0, 0;
		end
		if (UnitHealthMax("target") == 100) then
			-- probably got percent instead of hp, use a "good enough" spell as the player isn't in our party/raid
			return "target", HEALER_HEAL_MULTIPLY[UnitClass("target")] * UnitLevel("target") * (UnitHealthMax("target") - UnitHealth("target")) / 100, UnitHealth("target") / UnitHealthMax("target");
		else
			-- probably got hp and not percent, use best spell as we targetted this player in out party/raid
			return "target", UnitHealthMax("target"), 0;
		end
	end
	if (HEALER_TANK) then
		if (HEALER_TANK["Name"] ~= UnitName(HEALER_TANK["Unit"])) then
			local aka = Healer_UnitName(HEALER_TANK["Name"]);
			if (aka) then
				-- somehow our tank got a new id
				HEALER_TANK["Unit"] = aka;
				if (HEALER_ACTION and HEALER_ACTION["TankUnit"]) then
					HEALER_ACTION["TankUnit"] = aka;
				end
			else
				-- our tank is gone :\
				Healer_Print(HEALER_TANK["Name"] .. " is not in the party/raid. Tank mode is off.");
				HEALER_TANK = nil;
				if (HEALER_ACTION and HEALER_ACTION["TankUnit"]) then
					HEALER_ACTION["TankUnit"] = nil;
				end
			end
		end
		if (HEALER_TANK and HEALER_TANK["Unit"] and Healer_CanCastOn(HEALER_TANK["Unit"])) then
			-- we got a tank to heal :)
			return HEALER_TANK["Unit"], UnitHealthMax(HEALER_TANK["Unit"]), 0;
		else
			-- tank is out of reach
			return nil, 0, 0;
		end
	end
	local person = "player";
	local extrahp, priority = Healer_ExtraHealing(person, HEALER_PLAYER_PRI);
	local extrahealing = extrahp;
	local percent = 1.0 - (1.0 - (UnitHealth(person) + extrahp) / UnitHealthMax(person)) * priority;
	if (not Healer_CanCastOn(person)) then
		person = nil;
		percent = 1;
	end
	local tmppor = "raid";
	if (GetNumRaidMembers() == 0 or not HEALER_HEAL_RAID) then
		tmppor = "party";
	end
	local players = GetNumPartyMembers();
	local tmppriority = HEALER_PARTY_PRI;
	local tmppetpriority = HEALER_PARTYPET_PRI;
	if (tmppor == "raid") then
		players = GetNumRaidMembers();
		tmppriority = HEALER_RAID_PRI;
		tmppetpriority = HEALER_RAIDPET_PRI;
	end
	for a = 1, players do
		local tmpperson = tmppor .. a;
		extrahp, priority = Healer_ExtraHealing(tmpperson, tmppriority);
		-- can we heal this player?
		if (Healer_CanCastOn(tmpperson)) then
			local tmppercent = 1.0 - (1.0 - (UnitHealth(tmpperson) + extrahp) / UnitHealthMax(tmpperson)) * priority;
			if (tmppercent < percent) then
				-- this person is wounded more than the last person
				percent = tmppercent;
				person = tmpperson;
				extrahealing = extrahp;
			end
		end
		tmpperson = tmppor .. "pet" .. a;
		extrahp, priority = Healer_ExtraHealing(tmpperson, tmppetpriority);
		-- let's check this players pet (if any) as well
		if (Healer_CanCastOn(tmpperson)) then
			local tmppercent = 1.0 - (1.0 - (UnitHealth(tmpperson) + extrahp) / UnitHealthMax(tmpperson)) * priority;
			if (tmppercent < percent) then
				-- we better heal this pet
				person = tmpperson;
				percent = tmppercent;
				extrahealing = extrahp;
			end
		end
	end
	local hp;
	if (person) then 
		hp = UnitHealthMax(person) - UnitHealth(person) - extrahealing;
		percent = (UnitHealth(person) + extrahealing) / UnitHealthMax(person);
	else
		hp = 0;
		percent = 1;
	end
	-- we need the "right" percent (the one we got is tweaked)
	return person, hp, percent;
end

function Healer_EquipHealBonus()
	local extrahealing = 0;
	for a = 1, 20 do
		C_TooltipTextLeft1:SetText();
		C_Tooltip:SetInventoryItem("player", a);
		local item = C_TooltipTextLeft1:GetText();
		if (item) then
			if (HEALER_EQUIP_CACHE[item]) then
				-- item is in the cache, horay!
				extrahealing = extrahealing + HEALER_EQUIP_CACHE[item];
			else
				local extrahp = 0;
				for b = 2, C_Tooltip:NumLines() do
					local text = getglobal("C_TooltipTextLeft" .. b);
					if (text and text:GetText()) then
						local start, stop, bonus = string.find(text:GetText(), ITEM_HEAL_1);
						if (not bonus) then
							start, stop, bonus = string.find(text:GetText(), ITEM_HEAL_2);
						end
						if (bonus) then
							extrahp = extrahp + bonus;
						end
					end
				end
				HEALER_EQUIP_CACHE[item] = extrahp;
				extrahealing = extrahealing + extrahp;
			end
		end
	end
	return extrahealing;
end

function Healer_ExtraHealing(person, priority)
	-- check if this player will receive healing from someone/something else
	local gotfa = Healer_GotBuff(person, SPELL_FIRST_AID);
	local extrahp = 0;
	if (gotfa) then
		-- player is getting some first aid
		-- figure out how much
		--C_TooltipTextLeft2:SetText();
		--C_Tooltip:SetUnitBuff(person, gotfa);
		local faTexture = C_buff_texture_map[SPELL_FIRST_AID];
		if (faTexture) then
			--Healer_Print("faTexture: "..person);
			local cName = Healer_Unit2CName(person);
			local faText = C_player_data[cName]["Buff"][faTexture]["Text"];
			if (faText) then
				local start, stop, healing, seconds = string.find(faText, "(%d+%.?%d*).+(%d+%.?%d*)");
				if (healing and seconds) then
					--Healer_Print("faParsed: "..healing.." "..seconds);
					-- assume 2 seconds of the bandage is used
					extrahp = healing / seconds * 6;
				end
			end
		end
	elseif (Healer_GotDebuff(person, SPELL_RECENTLY_BANDAGED)) then
		-- player is recently bandaged and can't use a bandage.
		-- increase priority
		priority = priority + 0.15;
		if (priority > 1.0) then
			priority = 1.0;
		end
	end
	-- check if someone else has announced that they're healing this player
	if (HEALER_BEING_HEALED[UnitName(person)]) then
		for healer, data in HEALER_BEING_HEALED[UnitName(person)] do
			if (data["Action"] == "Healing") then
				extrahp = extrahp + HEALER_BEING_HEALED[UnitName(person)][healer]["Value"];
			end
		end
	end
	return extrahp, priority;
end

function Healer_UnitName(person)
	-- check if person is in our party/raid
	if (not person or person == "") then
		return;
	end
	if (person == UnitName("player")) then
		return "player";
	end
	for a = 1, GetNumRaidMembers() do
		if (UnitExists("raid" .. a) and person == UnitName("raid" .. a)) then
			return "raid" .. a;
		elseif (UnitExists("raidpet" .. a) and person == UnitName("raidpet" .. a)) then
			return "raidpet" .. a;
		end
	end
	for a = 1, GetNumPartyMembers() do
		if (UnitExists("party" .. a) and person == UnitName("party" .. a)) then
			return "party" .. a;
		elseif (UnitExists("partypet" .. a) and person == UnitName("partypet" .. a)) then
			return "partypet" .. a;
		end
	end
	return;
end

function Healer_AKA(person)
	-- check if person is in our party/raid
	if (not person or person == "") then
		return;
	end
	for a = 1, GetNumRaidMembers() do
		if (UnitExists("raid" .. a) and UnitIsUnit(person, "raid" .. a)) then
			return "raid" .. a;
		elseif (UnitExists("raidpet" .. a) and UnitIsUnit(person, "raidpet" .. a)) then
			return "raidpet" .. a;
		end
	end
	for a = 1, GetNumPartyMembers() do
		if (UnitExists("party" .. a) and UnitIsUnit(person, "party" .. a)) then
			return "party" .. a;
		elseif (UnitExists("partypet" .. a) and UnitIsUnit(person, "partypet" .. a)) then
			return "partypet" .. a;
		end
	end
	if (UnitIsUnit(person, "player")) then
		return "player";
	end
	return;
end

function Healer_Announce(color, message, channel, entireraid)
	if (HEALER_AUTOCASTING and not HEALER_ANNOUNCE_AUTOCASTING) then
		return;
	end
	if (channel) then
		if (channel == 1) then
			Healer_SCM(message, entireraid);
		else
			Healer_Print(message, color);
		end
	end
end

function Healer_SCM(message, entireraid)
	if (GetNumRaidMembers() > 0 and entireraid) then
		SendChatMessage(message, "raid");
	elseif ((GetNumRaidMembers() == 0 or not entireraid) and GetNumPartyMembers() > 0) then
		SendChatMessage(message, "party");
	else
		Healer_Print(message);
	end
end


function Healer_Print(message, color)
	if (not color) then
		color = "|cffead9ac";
	end
	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage(color .. message);
	end
end

function Healer_CastSpell(person, spell, rank, spellid, oom, action)
	-- blacklist this person
	if (person) then
		HEALER_CANT_CAST_ON[person] = HEALER_CANT_CAST_ON_TICK;
	end
	local entireraid;
	if (action == "Healing") then
		entireraid = HEALER_HEAL_RAID;
	elseif (action == "Buffing") then
		entireraid = HEALER_BUFF_RAID;
	elseif (action == "Debuffing") then
		entireraid = HEALER_DEBUFF_RAID;
	end
	-- do the actual casting
	if (not spellid) then
		if (person) then
			-- we got a person, but no spellid
			-- we can't cast on this person for some or another reason
			-- try another dude
			return;
		end
		if (oom and oom == 1) then
			-- oom
			Healer_Announce("|cffff0000", "Out of mana!", HEALER_ANNOUNCE_OOM, entireraid);
		elseif (oom and oom == 2) then
			-- cooldown on spell(s)
			if (spell) then
				Healer_Announce("|cffff0000", spell .. ": not ready!", HEALER_ANNOUNCE_NOT_READY, entireraid);
			else
				Healer_Announce("|cffff0000", "Spell isn't ready!", HEALER_ANNOUNCE_NOT_READY, entireraid);
			end
		else
			-- nobody needs healing
			Healer_Announce("|cffead9ac", "Nobody needs " .. string.lower(action), HEALER_ANNOUNCE_NOBODY_NEEDS, entireraid);
		end
		-- we didn't cast a spell and won't cast one. retarget our last target here if we had a target
		if (HEALER_TARGETLASTTARGET) then
			TargetLastTarget();
			HEALER_TARGETLASTTARGET = nil;
		end
		-- no casting done, need this for autocasting
		return 2;
	end

	-- this one is needed for debuffing (no cooldown on debuff spells)
	local spellstart, spellduration = GetSpellCooldown(spellid, 1);
	if (spellstart > 0) then
		-- cooldown on spell
		Healer_Announce("|cffff0000", spell .. " isn't ready!", HEALER_ANNOUNCE_NOT_READY, entireraid);
		return 2;
	end

	-- see if we need to clear our current target to cast this spell
	if (UnitExists("target") and not UnitIsUnit(person, "target") and ((UnitIsFriend("player", "target") and (action ~= "Buffing" or not HEALER_BUFFS[spell]["Selfcast"])) or (spell == SPELL_DISPELMAGIC))) then
		HEALER_TARGETLASTTARGET = 1;
		ClearTarget();
	end
	HEALER_CHECK_SITTING = nil;
	CastSpell(spellid, 1);
	if (HEALER_CHECK_SITTING) then
		-- we got a "failed" event as soon as we tried to cast
		-- most likely we're sitting or unable to cast a spell somehow
		HEALER_CHECK_SITTING = nil;
		return;
	end
	if (SpellCanTargetUnit(person)) then
		SpellTargetUnit(person);
	end
	-- check if we're still targetting
	if (SpellIsTargeting()) then
		-- still targetting, hmm
		if (UnitIsFriend("player", person)) then
			Healer_Announce("|cffff0000", UnitName(person) .. " is out of reach!", HEALER_ANNOUNCE_OUT_OF_REACH, entireraid);
		end
		SpellStopTargeting();
		return;
	end
	-- we've casted a spell. target our last target if we had one.
	if (HEALER_TARGETLASTTARGET) then
		TargetLastTarget();
		HEALER_TARGETLASTTARGET = nil;
	end
	-- if we're healing "target" then let's see if our target is in our raid (could be useful)
	if (HEALER_ACTION and HEALER_ACTION["Person"] and HEALER_ACTION["Person"] == "target") then
		local aka = Healer_AKA("target");
		if (aka) then
			HEALER_ACTION["AKA"] = aka;
		end
	end
	-- no longer targetting, spell casted on target
	local message = action .. " " .. UnitName(person) .. " with " .. spell;
	if (rank) then
		message = message .. "(" .. rank .. ")";
	end
	Healer_Announce("|cffead9ac", message, HEALER_ANNOUNCE_ACTION, entireraid);
	-- announce in the healer channel (if any)
	if (HEALER_CHANNEL) then
		message = "[Healer]: " .. action .. ", ";
		if (HEALER_ACTION and action == "Healing" and HEALER_ACTION["Casttime"] > 0) then
			if (HEALER_ACTION["AKA"]) then
				message = message .. UnitName(HEALER_ACTION["AKA"]) .. ", ";
			elseif (HEALER_ACTION["Person"]) then
				message = message .. UnitName(HEALER_ACTION["Person"]) .. ", ";
			end
			message = message .. HEALER_ACTION["Heal"] .. ", " .. HEALER_ACTION["ImpactHeal"] .. ", " .. HEALER_ACTION["Casttime"];
		elseif (HEALER_ACTION and action == "Reviving" and HEALER_ACTION["Casttime"] > 0) then
			if (person) then
				message = message .. UnitName(person) .. ", 0, 0, " .. HEALER_ACTION["Casttime"];
			end
		else
			return 1;
		end
		SendChatMessage(message, "CHANNEL", LANGUAGE_COMMON, GetChannelName(HEALER_CHANNEL));
	end
	return 1;
end

function Healer_Cmd(msg)
	Healer_CheckSpells();
	if (not msg or msg == "") then
		if (HealerGUI:IsVisible()) then
			HealerGUI:Hide();
			Healer_Save();
		else
			HealerGUI:Show();
		end
		return;
	end
	msg = string.lower(msg);
	local start, stop, a, who, pri;
	start, stop, a = string.find(msg, "^autoheal (.+)$");
	if (a) then
		HEALER_AUTOHEAL = a;
		Healer_Print("Will automatically heal with healclass \"" .. a .. "\" while moving");
		Healer_Save();
		return;
	end
	if (msg == "autoheal") then
		HEALER_AUTOHEAL = nil;
		Healer_Print("Will no longer heal while moving");
		Healer_Save();
		return;
	end
	start, stop, a = string.find(msg, "^autobuff (.+)$");
	if (a) then
		HEALER_AUTOBUFF = a;
		Healer_Print("Will automatically buff with buffclass \"" .. a .. "\" while moving");
		Healer_Save();
		return;
	end
	if (msg == "autobuff") then
		HEALER_AUTOBUFF = nil;
		Healer_Print("Will no longer buff while moving");
		Healer_Save();
		return;
	end
	if (msg == "autodebuff on") then
		HEALER_AUTODEBUFF = 1;
		Healer_Print("Will automatically debuff while moving");
		Healer_Save();
		return;
	end
	if (msg == "autodebuff off") then
		HEALER_AUTODEBUFF = nil;
		Healer_Print("Will no longer debuff while moving");
		Healer_Save();
		return;
	end
	if (msg == "tank") then
		local aka = Healer_AKA("target");
		if (aka) then
			HEALER_TANK = {
				["Unit"] = aka,
				["Name"] = UnitName(aka)
			};
			Healer_Print("Will only heal " .. HEALER_TANK["Name"]);
		else
			if (HEALER_TANK and HEALER_TANK["Name"]) then
				Healer_Print("Will no longer only heal " .. HEALER_TANK["Name"]);
			else
				Healer_Print("No dedicated healing");
			end
			HEALER_TANK = nil;
		end
		return;
	end
	if (msg == "party") then
		HEALER_HEAL_RAID = nil;
		HealerGUIHealRaidCheckButton:SetChecked(0);
		HealerGUIRaidPriority:Hide();
		HealerGUIRaidHealPrioritySlider:Hide();
		HealerGUIRaidHealPrioritySlider:Hide();
		HealerGUIRaidHealPrioritySliderValue:Hide();
		HealerGUIRaidpetPriority:Hide();
		HealerGUIRaidpetHealPrioritySlider:Hide();
		HealerGUIRaidpetHealPrioritySlider:Hide();
		HealerGUIRaidpetHealPrioritySliderValue:Hide();
		Healer_Print("Will now only heal party");
		Healer_Save();
		return;
	end
	if (msg == "raid") then
		HEALER_HEAL_RAID = 1;
		HealerGUIHealRaidCheckButton:SetChecked(1);
		HealerGUIRaidPriority:Show();
		HealerGUIRaidHealPrioritySlider:Show();
		HealerGUIRaidHealPrioritySlider:Show();
		HealerGUIRaidHealPrioritySliderValue:Show();
		HealerGUIRaidpetPriority:Show();
		HealerGUIRaidpetHealPrioritySlider:Show();
		HealerGUIRaidpetHealPrioritySlider:Show();
		HealerGUIRaidpetHealPrioritySliderValue:Show();
		Healer_Print("Will now heal the entire raid");
		Healer_Save();
		return;
	end
	if (msg == "broadcast") then
		-- broadcast channel
		if (HEALER_CHANNEL) then
			Healer_Announce(nil, "[Healer]: The Healer channel is \"" .. HEALER_CHANNEL .. "\"", 1, 1);
		else
			Healer_Print("You have to join a channel before you can broadcast it");
		end
		return;
	end

	-- WhisperCast commands
	-- added by pilardi for whisperblessing
	Healer_WhisperCheckInit()

	if (msg == "wchelp") then
		Healer_Print("Whisper related commands:");
		Healer_Print("/healer wchelp -- this.");
		Healer_Print("/healer wclistbuffs -- lists all accepted whisper buff_shortcuts.");
		Healer_Print("/healer wclist -- list all current whisper overrides.");
		Healer_Print("/healer wcsetbuffoverride [person] [buff_shortcut] -- makes Healer cast [buff_shortcut] on [person].");
		Healer_Print("/healer wcblacklist [buff_shortcut] -- adds spell to the blacklist");
		Healer_Print("/healer wcwhitelist [buff_shortcut] -- removes spell from the blacklist");
		Healer_Print("/healer wcblacklist -- lists all spells on blacklist");
		Healer_Print("/healer wcreset -- clears overrides and blacklist");
		Healer_Print("/healer wcdisable -- disable whisper feature");
		Healer_Print("/healer wcenable -- enable whisper feature");
		return;
	end
	if (msg == "wclist") then
		local listEmpty = true;
		for person, buffdata in HEALER_WHISPERCAST do
			for buffname, one in buffdata do
				Healer_Print(person .. " - " .. buffname);
				listEmpty = false;
			end
		end

		for person, overrides in HEALER_WHISPERNOCAST do
			for buffname, bool in HEALER_WHISPERNOCAST[person] do
				Healer_Print(person .. " - no " .. buffname);
				listEmpty = false;
			end
		end

		if (listEmpty) then
			Healer_Print("No whisper overrides.");
		end
		return;
	end
	if (msg == "wcreset") then
		HEALER_WHISPERCAST = {};
		HEALER_WHISPERNOCAST = {};
		HEALER_WCBLACKLIST = {};
		Healer_Print("Healer Whisper overrides reset.");
		Healer_Save();
		return;
	end
	if (msg == "wclistbuffs") then
		Healer_WhisperListBuffs(UnitName("player"));
		return;
	end
	if (msg == "wcdisable") then
		HEALER_WCDISABLED=true;
		Healer_Print("Healer whisper feature disabled");
		Healer_Save();
		return;
	end
	if (msg == "wcenable") then
		HEALER_WCDISABLED=false;
		Healer_Print("Healer whisper feature enabled");
		Healer_Save();
		return;
	end
	if (string.sub(msg,1,12) == "wcblacklist ") then
		local sub_msg=string.sub(msg, 13);

		buffname=Healer_WhisperMatchSpell(sub_msg);
		if(not buffname) then Healer_Print(sub_msg .. " not found.");return;end;

		HEALER_WCBLACKLIST[buffname]=true;
		Healer_Print(buffname .. " blacklisted");
		Healer_Save();
		return;

	end
	if (string.sub(msg,1,12) == "wcwhitelist ") then
		local sub_msg=string.sub(msg, 13);

		buffname=Healer_WhisperMatchSpell(sub_msg);
		if(not buffname) then Healer_Print(sub_msg .. " not found.");return;end;

		HEALER_WCBLACKLIST[buffname]=false;
		Healer_Print(buffname .. " whitelisted");
		Healer_Save();
		return;
	end
	if (string.sub(msg,1,11) == "wcblacklist") then
		local listempty=true;
		Healer_Print("wcblacklist:");
		for buffname in HEALER_WCBLACKLIST do
			Healer_Print(buffname);
			listempty=false;
		end
		if(listempty) then
			Healer_Print("No blacklisted buffs");
		end
		return;
	end
	if (string.sub(msg,1,17) == "wcsetbuffoverride") then
		local sub_msg=string.sub(msg, 18);
		local start,stop,person,spell=string.find(sub_msg," +(%w+) +(.+%w) *$");

		if(person==nil or spell==nil) then
			Healer_Print("/healer wcsetbuffoverride [person] [buff_shortcut]");
			return;
		end

		local personChecked=Healer_WhisperMatchPlayer(person);

		-- check for "no "
		local spell_sub=spell;
		if(string.sub(spell,1,3)=="no ") then
			spell_sub=string.sub(spell,4);
		end

		if(personChecked==nil) then
			Healer_Print("Player not member of group/raid: "..person);
		elseif(Healer_WhisperMatchSpell(spell_sub) or spell=="default") then
			Healer_HandleWhisper(personChecked, spell);
		else
			Healer_Print("Spell not found: "..spell);
		end
		return;
	end

	start, stop, a = string.find(msg, "join (.+)$");
	if (a) then
		-- join channel
		if (HEALER_CHANNEL and HEALER_CHANNEL ~= a) then
			LeaveChannelByName(HEALER_CHANNEL);
		end
		HEALER_CHANNEL = a;
		JoinChannelByName(a);
		Healer_Print("Joined channel \"" .. a .. "\"");
		Healer_Save();
		return;
	end
	start, stop, a = string.find(msg, "^overheal (%d+%.?%d*)$");
	if (a) then
		a = a / 100.0;
		if (a < 0.01) then
			a = 0.01;
		end
		if (a > 1.0) then
			a = 1.0
		end
		HEALER_MAX_OVERHEAL = a;
		Healer_Print("Will cancel spells when overhealing with more than " .. a * 100.0 .. "%");
		Healer_Save();
		return;
	end
	start, stop, who, pri = string.find(msg, "^set (.+) (%d+%.?%d*)$");
	if (who and pri) then
		who = string.lower(who);
		pri = pri / 1;
		if (pri >= 0 and pri <= 1) then
			if (who == "player") then
				HEALER_PLAYER_PRI = pri;
				HealerGUIPlayerHealPrioritySlider:SetValue(pri * 100);
				Healer_Print("Player priority changed to " .. pri);
			elseif (who == "party") then
				HEALER_PARTY_PRI = pri;
				HealerGUIPartyHealPrioritySlider:SetValue(pri * 100);
				Healer_Print("Party priority changed to " .. pri);
			elseif (who == "pet") then
				HEALER_PARTYPET_PRI = pri;
				HealerGUIPartypetHealPrioritySlider:SetValue(pri * 100);
				Healer_Print("Pet priority changed to " .. pri);
			elseif (who == "raid") then
				HEALER_RAID_PRI = pri;
				HealerGUIRaidHealPrioritySlider:SetValue(pri * 100);
				Healer_Print("Raid priority changed to " .. pri);
			elseif (who == "raidpet") then
				HEALER_RAIDPET_PRI = pri;
				HealerGUIRaidpetHealPrioritySlider:SetValue(pri * 100);
				Healer_Print("Raidpet priority changed to " .. pri);
			else
				Healer_Print("I don't know who " .. who .. " is");
			end
		else
			Healer_Print("The priority must be between 0.0 and 1.0");
		end
		Healer_Save();
	else
		Healer_Print("\"/healer set <player/party/pet/raid/raidpet> <0.0-1.0>\" - set healing priority of a unit, 0 means no healing");
		Healer_Print("\"/healer overheal <1-100>\" - max overhealing allowed when using autocancel");
		Healer_Print("\"/healer join <channel>\" - join a healing channel");
		Healer_Print("\"/healer broadcast\" - broadcast the healing channel");
		Healer_Print("\"/healer autoheal [healclass]\" - heal while moving (can only be instant spells in healclass)");
		Healer_Print("\"/healer autobuff [buffclass]\" - buff while moving");
		Healer_Print("\"/healer autodebuff <on/off>\" - debuff while moving");
		Healer_Print("\"/healer tank\" - set a tank to always heal (don't use unless you know what it does)");
		Healer_Print("\"/healer party\" - only heal party");
		Healer_Print("\"/healer raid\" - heal entire raid");
		Healer_Print("\"/healer wchelp\" - print whisper related help");
	end
end

function Nuker_Cmd(msg)
	Healer_CheckSpells();
	if (not msg or msg == "") then
		if (NukerGUI:IsVisible()) then
			NukerGUI:Hide();
			Healer_Save();
		else
			NukerGUI:Show();
		end
		return;
	end
end

function Nuker_Override(nukeclass)
	-- see if we got another nukeclass to "override" our current nukeclass
	if (not UnitExists("target")) then
		-- no target, no override
		return nukeclass;
	end
	local creaturetype = string.lower(UnitCreatureType("target"));
	local class = string.lower(UnitClass("target"));
	local name = string.lower(UnitName("target"));

	if (creaturetype and class and name and NUKER_NUKE_CLASSES[nukeclass .. " - " .. creaturetype .. " - " .. class .. " - " .. name]) then
		return nukeclass .. " - " .. creaturetype .. " - " .. class .. " - " .. name;
	elseif (creaturetype and name and NUKER_NUKE_CLASSES[nukeclass .. " - " .. creaturetype .. " - " .. name]) then
		return nukeclass .. " - " .. creaturetype .. " - " .. name;
	elseif (class and name and NUKER_NUKE_CLASSES[nukeclass .. " - " .. class .. " - " .. name]) then
		return nukeclass .. " - " .. class .. " - " .. name;
	elseif (name and NUKER_NUKE_CLASSES[nukeclass .. " - " .. name]) then
		return nukeclass .. " - " .. name;
	elseif (creaturetype and class and NUKER_NUKE_CLASSES[nukeclass .. " - " .. creaturetype .. " - " .. class]) then
		return nukeclass .. " - " .. creaturetype .. " - " .. class;
	elseif (creaturetype and NUKER_NUKE_CLASSES[nukeclass .. " - " .. creaturetype]) then
		return nukeclass .. " - " .. creaturetype;
	elseif (class and NUKER_NUKE_CLASSES[nukeclass .. " - " .. class]) then
		return nukeclass .. " - " .. class;
	end

	-- no overrides found
	return nukeclass;
end

function Nuker_Attack(nukeclass)
	if (not nukeclass) then
		if (not HEALER_AUTOCASTING) then
			Healer_Print("Your macro is wrong, apparently you forgot to add a \" before and after the name of the nukeclass", "|cffff0000");
		end
		return;
	end
	nukeclass = string.lower(nukeclass);
	-- check for override
	nukeclass = Nuker_Override(nukeclass);
	if (not NUKER_NUKE_CLASSES or not NUKER_NUKE_CLASSES[nukeclass]) then
		if (not HEALER_AUTOCASTING) then
			Healer_Print("No abilities registered in this class", "|cffff0000");
		end
		return;
	end
	if (not Healer_CanCast()) then
		return;
	end

	local target = "none";
	if (UnitExists("target")) then
		target = UnitName("target");
	end
	local priority = 1;
	while (NUKER_NUKE_CLASSES[nukeclass][priority] and NUKER_NUKE_CLASSES[nukeclass][priority]["Ability"]) do
		local spellname, spellrank, spellid, skip;
		if (NUKER_NUKE_CLASSES[nukeclass][priority]["CheckDebuff"] and Healer_GotDebuff("target", NUKER_NUKE_CLASSES[nukeclass][priority]["Ability"])) then
			-- target got debuff and we've marked the "check debuff" thingy
			
			if (NUKER_NUKE_CLASSES[nukeclass][priority]["Interval"] and NUKER_NUKE_CLASSES[nukeclass][priority]["Interval"] > 0) then
				-- however, we've also set a delay, check if the time's up
				if (NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target] and (NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"] and NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"] > 0)) then
					-- still time left before we can use this ability
					skip = 1;
				end
			else
				skip = 1;
			end
		end
		if (not skip and not NUKER_NUKE_CLASSES[nukeclass][priority]["CheckDebuff"] and NUKER_NUKE_CLASSES[nukeclass][priority]["Interval"] and NUKER_NUKE_CLASSES[nukeclass][priority]["Interval"] > 0) then
			-- and in case we've not marked "check debuff", but set a delay
			if (NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target] and NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"] and NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"] > 0) then
				-- still time left before we can use this ability
				skip = 1;
			end
		end
		if (not skip and NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target] and NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"] and NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"] > 3600) then
			-- target is immune to this ability
			skip = 1;
		end
		if (not skip and Healer_GotDebuff("target", SPELL_BANISH)) then
			-- target is banished
			skip = 1;
		end
		if (not skip) then
			spellname = NUKER_NUKE_CLASSES[nukeclass][priority]["Ability"];
			if (NUKER_NUKES[spellname]) then
				local spellstart, spellduration = GetSpellCooldown(NUKER_NUKES[spellname][1]["ID"], 1);
				if (spellstart == 0) then
					for rank, data in NUKER_NUKES[spellname] do
						if (data["Cost"] and data["ID"] and UnitMana("player") >= data["Cost"] and (not spellrank or spellrank < rank)) then
							spellrank = rank;
							spellid = data["ID"];
						end
					end
				end
			end
			if (spellid) then
				-- we got an ability we want to use
				HEALER_CHECK_SITTING = nil;
				CastSpell(spellid, 1);
				if (HEALER_CHECK_SITTING) then
					-- we got a "failed" event as soon as we tried to cast
					-- most likely we're sitting or unable to use an ability somehow
					HEALER_CHECK_SITTING = nil;
					return;
				end
				-- check if we're still targetting
				if (SpellIsTargeting()) then
					-- still targetting, hmm
					--SpellStopTargeting();
					--return;
				end
				if (not NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"]) then
					NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"] = {};
				end
				NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target] = {};
				-- if we've come this far we've used an ability
				-- set timeleft to interval
				NUKER_NUKE_CLASSES[nukeclass][priority]["Targets"][target]["TimeLeft"] = NUKER_NUKE_CLASSES[nukeclass][priority]["Interval"];
				-- and the spells cooldown
				NUKER_NUKECLASS = nukeclass;
				-- set the fading thingy
				NUKER_FADE = 15;
				-- show the frame thingy
				NukerAbilities:Show();
				return;
			end
		end
		priority = priority + 1;
	end
end

function Nuker_PickupSpell(spellid, spellbookTabNum)
	NUKER_PICKUP_SPELLID = spellid;
	NUKER_PICKUP_SPELLBOOKTABNUM = spellbookTabNum;
	return Nuker_old_PickupSpell(spellid, spellbookTabNum);
end

function Nuker_DropSpell()
	if (CursorHasItem() or CursorHasMoney()) then
		Healer_Print("You have to pick up your spells from your spellbook", "|cffff0000");
		return;
	end
	if (not NUKER_PICKUP_SPELLID or not NUKER_PICKUP_SPELLBOOKTABNUM or not CursorHasSpell()) then
		return;
	end
	local nukeclass = NukerGUINukeclass:GetText();
	local bleh, blah, priority = string.find(this:GetName(), "Ability(%d+)");
	local ability, rank = GetSpellName(NUKER_PICKUP_SPELLID, NUKER_PICKUP_SPELLBOOKTABNUM);
	local spelltexture = GetSpellTexture(NUKER_PICKUP_SPELLID, NUKER_PICKUP_SPELLBOOKTABNUM);
	if (nukeclass and ability and NUKER_NUKES[ability] and priority) then
		priority = priority / 1.0;
		if (not NUKER_NUKE_CLASSES) then
			NUKER_NUKE_CLASSES = {};
		end
		if (not NUKER_NUKE_CLASSES[nukeclass]) then
			NUKER_NUKE_CLASSES[nukeclass] = {};
		end
		local move;
		while (not NUKER_NUKE_CLASSES[nukeclass][priority] and priority > 0) do
			-- decrease priority
			move = 1;
			priority = priority - 1;
		end
		if (move) then
			priority = priority + 1;
		end
		local delay;
		if (HEALER_DOTS[ability]) then
			-- it seems like this is an ability that does dot
			-- let's use this to set the delay
			delay = HEALER_DOTS[ability];
		end
		-- move all spells with lower priority 1 step down
		for counter = 9, priority, -1 do
			NUKER_NUKE_CLASSES[nukeclass][counter + 1] = NUKER_NUKE_CLASSES[nukeclass][counter];
			local tmptexture;
			if (NUKER_NUKE_CLASSES[nukeclass][counter + 1]) then
				tmptexture = GetSpellTexture(NUKER_NUKES[NUKER_NUKE_CLASSES[nukeclass][counter + 1]["Ability"]][1]["ID"], BOOKTYPE_SPELL);
				getglobal("NukerGUIAbility" .. counter + 1 .. "IconTexture"):SetTexture(tmptexture);
				getglobal("NukerGUIAbility" .. counter + 1 .. "Ability"):SetText(getglobal("NukerGUIAbility" .. counter .. "Ability"):GetText());
				getglobal("NukerGUIAbility" .. counter + 1 .. "Ability"):Show();
				getglobal("NukerGUIAbility" .. counter + 1 .. "DebuffCheckButton"):SetChecked(getglobal("NukerGUIAbility" .. counter .. "DebuffCheckButton"):GetChecked());
				getglobal("NukerGUIAbility" .. counter + 1 .. "DebuffCheckButton"):Show();
				getglobal("NukerGUIAbility" .. counter + 1 .. "DelaySlider"):SetValue(getglobal("NukerGUIAbility" .. counter .. "DelaySlider"):GetValue());
				getglobal("NukerGUIAbility" .. counter + 1 .. "DelaySlider"):Show();
				getglobal("NukerGUIAbility" .. counter + 1 .. "DelaySliderValue"):SetText(getglobal("NukerGUIAbility" .. counter .. "DelaySliderValue"):GetText());
				getglobal("NukerGUIAbility" .. counter + 1 .. "DelaySliderValue"):Show();
			else
				getglobal("NukerGUIAbility" .. counter + 1 .. "IconTexture"):SetTexture();
				getglobal("NukerGUIAbility" .. counter + 1 .. "Ability"):Hide();
				getglobal("NukerGUIAbility" .. counter + 1 .. "DebuffCheckButton"):Hide();
				getglobal("NukerGUIAbility" .. counter + 1 .. "DelaySlider"):Hide();
				getglobal("NukerGUIAbility" .. counter + 1 .. "DelaySliderValue"):Hide();
			end
		end
		NUKER_NUKE_CLASSES[nukeclass][priority] = {
			["Texture"] = spelltexture,
			["Ability"] = ability,
			["Interval"] = delay,
			["Targets"] = {}
		};
		if (delay) then
			NUKER_NUKE_CLASSES[nukeclass][priority]["CheckDebuff"] = 1;
		end
		local position = (delay or 0);
		if (position > 60) then
			-- delay is in minutes
			-- we want to place the slider from 37 to 71
			if (position > 1800) then
				position = (position / 60 - 30) / 5 + 65;
			else
				position = (position / 60) + 35;
			end
		else
			-- delay is in seconds
			-- want to place the slider from 0 to 36
			if (position > 30) then
				position = (position - 30) / 5 + 30;
			end
		end
		local value = position;
		if (value >= 60) then
			value = (value - 65) * 5 + 30;
		elseif (value > 36) then
			value = value - 35;
		elseif (value > 30) then
			value = (value - 30) * 5 + 30;
		end
		getglobal("NukerGUIAbility" .. priority .. "IconTexture"):SetTexture(spelltexture);
		getglobal("NukerGUIAbility" .. priority .. "Ability"):SetText(ability);
		getglobal("NukerGUIAbility" .. priority .. "Ability"):Show();
		if (position == 0) then
			getglobal("NukerGUIAbility" .. priority .. "DebuffCheckButton"):SetChecked(0);
		else
			getglobal("NukerGUIAbility" .. priority .. "DebuffCheckButton"):SetChecked(1);
		end
		getglobal("NukerGUIAbility" .. priority .. "DebuffCheckButton"):Show();
		getglobal("NukerGUIAbility" .. priority .. "DelaySlider"):SetValue(position);
		getglobal("NukerGUIAbility" .. priority .. "DelaySlider"):Show();
		if (position > 36) then
			getglobal("NukerGUIAbility" .. priority .. "DelaySliderValue"):SetText(value .. " min");
		else
			if (position == 0) then
				getglobal("NukerGUIAbility" .. priority .. "DelaySliderValue"):SetText("None");
			else
				getglobal("NukerGUIAbility" .. priority .. "DelaySliderValue"):SetText(value .. " sec");
			end
		end
		getglobal("NukerGUIAbility" .. priority .. "DelaySliderValue"):Show();
	end
	PickupSpell(NUKER_PICKUP_SPELLID, NUKER_PICKUP_SPELLBOOKTABNUM);
	NUKER_PICKUP_SPELLID = nil;
	NUKER_PICKUP_SPELLBOOKTABNUM = nil;
	return 1;
end

function Nuker_PickupAbility()
	local nukeclass = NukerGUINukeclass:GetText();
	local bleh, blah, priority = string.find(this:GetName(), "Ability(%d+)");
	if (not priority or not nukeclass) then
		return;
	end
	priority = priority / 1.0;
	if (NUKER_NUKE_CLASSES and NUKER_NUKE_CLASSES[nukeclass] and NUKER_NUKE_CLASSES[nukeclass][priority]) then
		NUKER_PICKUP_SPELLID = NUKER_NUKES[NUKER_NUKE_CLASSES[nukeclass][priority]["Ability"]][1]["ID"];
		NUKER_PICKUP_SPELLBOOKTABNUM = BOOKTYPE_SPELL;
		PickupSpell(NUKER_PICKUP_SPELLID, NUKER_PICKUP_SPELLBOOKTABNUM);
		-- move all spells with lower priority 1 step up
		for counter = priority, 10 do
			NUKER_NUKE_CLASSES[nukeclass][counter] = NUKER_NUKE_CLASSES[nukeclass][counter + 1];
			local spelltexture;
			if (NUKER_NUKE_CLASSES[nukeclass][counter]) then
				spelltexture = GetSpellTexture(NUKER_NUKES[NUKER_NUKE_CLASSES[nukeclass][counter]["Ability"]][1]["ID"], BOOKTYPE_SPELL);
				getglobal("NukerGUIAbility" .. counter .. "IconTexture"):SetTexture(spelltexture);
				getglobal("NukerGUIAbility" .. counter .. "Ability"):SetText(getglobal("NukerGUIAbility" .. counter + 1 .. "Ability"):GetText());
				getglobal("NukerGUIAbility" .. counter .. "Ability"):Show();
				getglobal("NukerGUIAbility" .. counter .. "DebuffCheckButton"):SetChecked(getglobal("NukerGUIAbility" .. counter + 1 .. "DebuffCheckButton"):GetChecked());
				getglobal("NukerGUIAbility" .. counter .. "DebuffCheckButton"):Show();
				getglobal("NukerGUIAbility" .. counter .. "DelaySlider"):SetValue(getglobal("NukerGUIAbility" .. counter + 1 .. "DelaySlider"):GetValue());
				getglobal("NukerGUIAbility" .. counter .. "DelaySlider"):Show();
				getglobal("NukerGUIAbility" .. counter .. "DelaySliderValue"):SetText(getglobal("NukerGUIAbility" .. counter + 1 .. "DelaySliderValue"):GetText());
				getglobal("NukerGUIAbility" .. counter .. "DelaySliderValue"):Show();
			else
				getglobal("NukerGUIAbility" .. counter .. "IconTexture"):SetTexture();
				getglobal("NukerGUIAbility" .. counter .. "Ability"):Hide();
				getglobal("NukerGUIAbility" .. counter .. "DebuffCheckButton"):Hide();
				getglobal("NukerGUIAbility" .. counter .. "DelaySlider"):Hide();
				getglobal("NukerGUIAbility" .. counter .. "DelaySliderValue"):Hide();
			end
		end
	end
end

function NukerGUI_SetUp()
	local nukeclass = NukerGUINukeclass:GetText();
	if (nukeclass == "") then
		nukeclass = nil;
	end
	for tmpclass, data in NUKER_NUKE_CLASSES do
		if (not nukeclass) then
			nukeclass = tmpclass;
		end
	end
	if (not nukeclass) then
		nukeclass = "default";
	end
	if (not NUKER_NUKE_CLASSES[nukeclass]) then
		NUKER_NUKE_CLASSES[nukeclass] = {};
	end
	NukerGUINukeclass:SetText(nukeclass);
	for counter = 1, 10 do
		if (NUKER_NUKE_CLASSES[nukeclass][counter]) then
			spelltexture = GetSpellTexture(NUKER_NUKES[NUKER_NUKE_CLASSES[nukeclass][counter]["Ability"]][1]["ID"], BOOKTYPE_SPELL);
			getglobal("NukerGUIAbility" .. counter .. "IconTexture"):SetTexture(spelltexture);
			getglobal("NukerGUIAbility" .. counter .. "Ability"):SetText(NUKER_NUKE_CLASSES[nukeclass][counter]["Ability"]);
			getglobal("NukerGUIAbility" .. counter .. "Ability"):Show();
			getglobal("NukerGUIAbility" .. counter .. "DebuffCheckButton"):SetChecked(NUKER_NUKE_CLASSES[nukeclass][counter]["CheckDebuff"]);
			getglobal("NukerGUIAbility" .. counter .. "DebuffCheckButton"):Show();
			local position = NUKER_NUKE_CLASSES[nukeclass][counter]["Interval"];
			position = (position or 0);
			if (position > 60) then
				-- delay is in minutes
				-- we want to place the slider from 37 to 71
				if (position > 1800) then
					position = (position / 60 - 30) / 5 + 65;
				else
					position = (position / 60) + 35;
				end
			else
				-- delay is in seconds
				-- want to place the slider from 0 to 36
				if (position > 30) then
					position = (position - 30) / 5 + 30;
				end
			end
			getglobal("NukerGUIAbility" .. counter .. "DelaySlider"):SetValue(position);
			getglobal("NukerGUIAbility" .. counter .. "DelaySlider"):Show();
			local value = position;
			if (value >= 60) then
				value = (value - 65) * 5 + 30;
			elseif (value > 36) then
				value = value - 35;
			elseif (value > 30) then
				value = (value - 30) * 5 + 30;
			end
			if (position > 36) then
				getglobal("NukerGUIAbility" .. counter .. "DelaySliderValue"):SetText(value .. " min");
			else
				if (position == 0) then
					getglobal("NukerGUIAbility" .. counter .. "DelaySliderValue"):SetText("None");
				else
					getglobal("NukerGUIAbility" .. counter .. "DelaySliderValue"):SetText(value .. " sec");
				end
			end
			getglobal("NukerGUIAbility" .. counter .. "DelaySliderValue"):Show();
		else
			getglobal("NukerGUIAbility" .. counter .. "IconTexture"):SetTexture();
			getglobal("NukerGUIAbility" .. counter .. "Ability"):Hide();
			getglobal("NukerGUIAbility" .. counter .. "DebuffCheckButton"):Hide();
			getglobal("NukerGUIAbility" .. counter .. "DelaySlider"):Hide();
			getglobal("NukerGUIAbility" .. counter .. "DelaySliderValue"):Hide();
		end
	end
end

function NukerGUIAbilityDebuffCheckButtonOnClick()
	local nukeclass = NukerGUINukeclass:GetText();
	local bleh, blah, tmppri = string.find(this:GetName(), "Ability(%d+)");
	local priority = tmppri / 1.0;
	NUKER_NUKE_CLASSES[nukeclass][priority]["CheckDebuff"] = this:GetChecked();
end

function NukerGUIAbilityDelaySliderOnValueChanged()
	local nukeclass = NukerGUINukeclass:GetText();
	local bleh, blah, tmppri = string.find(this:GetName(), "Ability(%d+)");
	local priority = tmppri / 1.0;
	local text = getglobal(this:GetName() .. "Value");
	local value = this:GetValue();
	if (text and value and priority and NUKER_NUKE_CLASSES and NUKER_NUKE_CLASSES[nukeclass] and NUKER_NUKE_CLASSES[nukeclass][priority]) then
		if (value > 65) then
			value = (value - 65) * 5 + 30;
		elseif (value > 36) then
			value = value - 35;
		elseif (value > 30) then
			value = (value - 30) * 5 + 30;
		end
		if (this:GetValue() > 36) then
			text:SetText(value .. " min");
			NUKER_NUKE_CLASSES[nukeclass][priority]["Interval"] = value * 60;
		else
			if (this:GetValue() == 0) then
				text:SetText("None");
				NUKER_NUKE_CLASSES[nukeclass][priority]["Interval"] = nil;
			else
				text:SetText(value .. " sec");
				NUKER_NUKE_CLASSES[nukeclass][priority]["Interval"] = value;
			end
		end
	end
end

function Healer_WhisperCheckInit()
	if (HEALER_WHISPERCAST == nil) then
		HEALER_WHISPERCAST = {};
	end

	if (HEALER_WHISPERNOCAST == nil) then
		HEALER_WHISPERNOCAST = {};
	end

	if(HEALER_WCBLACKLIST==nil) then
		HEALER_WCBLACKLIST={};
	end			

	if (Healer_WhisperBuffList==nil) then
		Healer_CreateWhisperBuffList();
	end
end

-- added by pilardi for whisperblessing
function Healer_HandleWhisper(user, message)
	if(Healer_WhisperMatchPlayer(user)==nil) then
		--Healer_Print("Player not member of group/raid: "..user);
		return;
	end

	Healer_WhisperCheckInit();

	message = string.lower(message);

	-- Handle WhisperNoCast
	if (string.sub(message, 1, 3) == "no ") then      
		local sub_message=string.sub(message, 4);
		buffname=Healer_WhisperMatchSpell(sub_message);
		if(not buffname) then return;end;

		if (HEALER_WHISPERNOCAST[user] == nil) then
			HEALER_WHISPERNOCAST[user] = {};
		end
		if (HEALER_WHISPERCAST and HEALER_WHISPERCAST[user] and HEALER_WHISPERCAST[user][buffname]) then
			HEALER_WHISPERCAST[user][buffname] = nil;
		end
		HEALER_WHISPERNOCAST[user][buffname] = true;
		SendChatMessage("Won't cast " .. buffname .. " on " .. user, "WHISPER", nil, user);
		Healer_Save();

	-- Cancel WhisperCast and WhisperNoCast
	elseif (message == "default") then
		HEALER_WHISPERCAST[user] = nil;
		HEALER_WHISPERNOCAST[user] = nil;
		SendChatMessage("Default buffs will be casted on " .. user, "WHISPER", nil, user);
		Healer_Save();


	elseif (message == "listbuffs") then
		Healer_WhisperListBuffs(user)

	-- Handle WhisperCast
	else
		buffname=Healer_WhisperMatchSpell(message);
		if(not buffname) then return;end;

		if(HEALER_WCBLACKLIST and HEALER_WCBLACKLIST[buffname]) then
			SendChatMessage("Sorry, won't cast " .. buffname, "WHISPER", nil, user);
		else 
			if (HEALER_WHISPERCAST[user] == nil or UnitClass("player") == CLASS_PALADIN) then
				-- erase table if we're a paladin (to get rid of other blessings)
				HEALER_WHISPERCAST[user] = {};
			end
			HEALER_WHISPERCAST[user][buffname] = 1;
			if (HEALER_WHISPERNOCAST and HEALER_WHISPERNOCAST[user] and HEALER_WHISPERNOCAST[user][buffname]) then
				HEALER_WHISPERNOCAST[user][buffname] = nil;
			end
			SendChatMessage("Will cast " .. buffname .. " on " .. user, "WHISPER", nil, user);
			Healer_Save();
		end
	end
end

function Healer_CreateWhisperBuffList()
	Healer_WhisperBuffList={
		[CLASS_PALADIN]={
			["sanctuary"]=SPELL_BOSAN,
			["sacrifice"]=SPELL_BOSAC,
			["wisdom"]=SPELL_BOW,
			["salvation"]=SPELL_BOSAL,
			["kings"]=SPELL_BOK,
			["might"]=SPELL_BOM,
			["light"]=SPELL_BOL
		},
		[CLASS_DRUID]={
			["gift"]=SPELL_GOTW,
			["gotw"]=SPELL_GOTW,
			["group mark"]=SPELL_GOTW,
			["mark"]=SPELL_MOTW,
			["motw"]=SPELL_MOTW,
			["thorns"]=SPELL_THORNS
			--["omen"]=SPELL_OMEN ???
		},
		[CLASS_MAGE]={
			["amplify"]=SPELL_AMPLIFY,
			["ai"]=SPELL_ARCANE_INTELLECT,
			["int"]=SPELL_ARCANE_INTELLECT,
			["dampen"]=SPELL_DAMPEN_MAGIC,
			["group ai"]=SPELL_ARCANE_BRILLIANCE,
			["group int"]=SPELL_ARCANE_BRILLIANCE,
			["brilliance"]=SPELL_ARCANE_BRILLIANCE,
		},
		[CLASS_PRIEST]={
			["spirit"]=SPELL_DIVINE_SPIRIT,
			["group fort"]=SPELL_POF,
			["group fortitude"]=SPELL_POF,
			["group stam"]=SPELL_POF,
			["group stamina"]=SPELL_POF,
			--["shield"]=,
			["fear"]=SPELL_FEAR_WARD,
			["ward"]=SPELL_FEAR_WARD,
			["fort"]=SPELL_PWF,
			["fortitude"]=SPELL_PWF,
			["stam"]=SPELL_PWF,
			["stamina"]=SPELL_PWF,
			--["disease"]=,
			["shadow"]=SPELL_SHADOW_PROTECTION,
			--["dispel"]=,
		},
	};
end

function Healer_WhisperListBuffs(user)
	Healer_WhisperCheckInit();
	Healer_CheckSpells();
	if(Healer_WhisperBuffList and Healer_WhisperBuffList[UnitClass("player")]) then
		if(user==UnitName("player")) then 
			Healer_Print("Listing Healer whisperbuff shortcuts:");
		else
			SendChatMessage("Listing Healer whisperbuff shortcuts:", "WHISPER", nil, user);
		end
		for shortcut, buffname1 in Healer_WhisperBuffList[UnitClass("player")]  do
			if((not HEALER_WCBLACKLIST) or (not HEALER_WCBLACKLIST[buffname1])) then
				for buffname2, buffdata in HEALER_BUFFS do
					if (not buffdata["Selfcast"] and not buffdata["GroupBuff"] and buffname1==buffname2) then
						if(user==UnitName("player")) then
							Healer_Print(shortcut .. " = " .. buffname1);
						else
							SendChatMessage(shortcut .. " = " .. buffname1, "WHISPER", nil, user);
						end
					end
				end
			end
		end
	else
		Healer_Print("No whisper buffs available for " .. UnitClass("player"));
	end
end

function Healer_WhisperMatchSpell(shortcut)
	shortcut=string.lower(shortcut);
	Healer_CheckSpells();
	Healer_WhisperCheckInit();
	for buffname, buffdata in HEALER_BUFFS do
		--if (not buffdata["Selfcast"] and not buffdata["GroupBuff"] and string.find(string.lower(buffname), shortcut)) then
		if (not buffdata["Selfcast"] and not buffdata["GroupBuff"] and
				(string.lower(buffname)==shortcut or
				(Healer_WhisperBuffList[UnitClass("player")] and Healer_WhisperBuffList[UnitClass("player")][shortcut]==buffname))) then

			return buffname;
		end
	end
	return nil;
end

function Healer_WhisperMatchPlayer(playername)
	local nameFound=nil;
	playername=string.lower(playername);

	if(string.lower(UnitName("player"))==playername) then
		nameFound=UnitName("player");
	end
	if(UnitName("pet") and string.lower(UnitName("pet"))==playername) then
		nameFound=UnitName("pet");
	end

	for a = 1, GetNumPartyMembers() do
		if(string.lower(UnitName("party"..a))==playername) then
			nameFound=UnitName("party"..a);
		end
		if(UnitName("partypet"..a) and string.lower(UnitName("partypet"..a))==playername) then
			nameFound=UnitName("partypet"..a);
		end
	end

	for a = 1, GetNumRaidMembers() do
		if(string.lower(UnitName("raid"..a))==playername) then
			nameFound=UnitName("raid"..a);
		end
		if(UnitName("raidpet"..a) and string.lower(UnitName("raidpet"..a))==playername) then
			nameFound=UnitName("raidpet"..a);
		end
	end

	return nameFound;
end

function Healer_HealerUpdateStatusBar()
	if(Healer_DontUpdateStatusBar) then return;end;
	
	if(Healer_UseOldChecks) then HEALER_BUFF_CACHE = {};end;
	Healer_CheckSpells();
	local cancast=1;--Healer_CanCast();
	local numParty=GetNumPartyMembers();
	local numRaid=GetNumRaidMembers();
	local maxPlayer=max(numParty,numRaid);
	local i=(Healer_CurrentPlayerUpdated or 0);
	local name,petname;

	if(i>maxPlayer) then 
		i=0;
		Healer_PrintNeededBuffsOn=false;		
	end;

	if(i==0 and numRaid>0) then -- player is also a raid member
		Healer_BuffsNeededList[0]=nil;
		Healer_DebuffsNeededList[0]=nil;
		i=1;
	end; 

	if(i==0) then name="player";petname="pet";
	elseif(numRaid>0) then name="raid"..i;petname="raidpet"..i;
	elseif(numParty>0) then name="party"..i;petname="partypet"..i;
	else Healer_Print("Healer_HealerUpdateStatusBar error 1");
	end

	if((not HEALER_STATUS_BAR_HIDE_BUFFS) or HealerGUI:IsVisible()) then
		Healer_HealerUpdateStatusBarBuff(i,maxPlayer,name,petname)
	end

	if((not HEALER_STATUS_BAR_HIDE_DEBUFFS) or HealerGUI:IsVisible()) then
		Healer_HealerUpdateStatusBarDebuff(i,maxPlayer,name,petname)
	end

	--update overheal bar
	if((not HEALER_STATUS_BAR_HIDE_OVERHEAL) or HealerGUI:IsVisible()) then
		if((not Healer_lastOverhealDetected) or (Healer_OverhealDetected~=Healer_lastOverhealDetected)) then
			HealerStatusHeal:SetStatusBarColor(1,0,0); 
			HealerStatusHealText:SetVertexColor(1,1,0);
			HealerStatusHealText:SetText("Overheal Detected");
			Healer_lastOverhealDetected=debuffTotal;
		end
		if(Healer_OverhealDetected or HealerGUI:IsVisible()) then HealerStatusHeal:Show();
		else HealerStatusHeal:Hide();end;
	end

	Healer_CurrentPlayerUpdated=i+1;
end


function Healer_HealerUpdateStatusBarBuff(i,maxPlayer,name,petname)
	local person, castbuff, castrank, castid, pri;
	local numBuffsNeeded;

	-- Buff status
	Healer_BuffsNeededList[i]=0;
	person, castbuff, castrank, castid, pri, numBuffsNeeded = Healer_CastBuffCheckTarget(name, HEALER_AUTOBUFF, cancast,2);
	if(person and pri and pri>=0) then
		if(Healer_PrintNeededBuffsOn) then
			local cName = Healer_Unit2CName(person);
			local timeDiff;
			if(cName and C_player_data[cName] and C_player_data[cName]["UpdateTime"]) then
				timeDiff = GetTime()-C_player_data[cName]["UpdateTime"];
				timeDiff = floor(timeDiff*1000);
			end
			Healer_Print(UnitName(person)..", "..(castbuff or 0)..", "..(timeDiff or "nodiff"));
		end
		Healer_BuffsNeededList[i]=Healer_BuffsNeededList[i] + (numBuffsNeeded or 1);
	end

	if(HEALER_BUFF_PETS) then
		person, castbuff, castrank, castid, pri, numBuffsNeeded = Healer_CastBuffCheckTarget(petname, HEALER_AUTOBUFF, cancast,2);
		if(person and pri and pri>=0) then
			if(Healer_PrintNeededBuffsOn) then
				local cName = Healer_Unit2CName(person);
				local timeDiff;
				if(cName and C_player_data[cName] and C_player_data[cName]["UpdateTime"]) then
					timeDiff = GetTime()-C_player_data[cName]["UpdateTime"];
					timeDiff = floor(timeDiff*1000);
				end
				Healer_Print(UnitName(person).."("..UnitName(name).."), "..(castbuff or 0)..", "..(timeDiff or "nodiff"));

			end
			Healer_BuffsNeededList[i]=Healer_BuffsNeededList[i] + (numBuffsNeeded or 1);
		end
	end

	local buffTotal=0;
	for j = 0, maxPlayer do
		buffTotal=buffTotal+(Healer_BuffsNeededList[j] or 0);
	end

	-- update buff status bar
	if((not Healer_lastBuffTotal) or (buffTotal~=Healer_lastBuffTotal)) then
		HealerStatusBuff:SetStatusBarColor(0,1,0); 
		HealerStatusBuffText:SetVertexColor(1,1,0);
		--HealerStatusBuffText:SetText("Buff needed");
		HealerStatusBuffText:SetText(buffTotal.." buffs needed");
		Healer_lastBuffTotal=buffTotal;
	end
	if((buffTotal>0 and not Healer_OnMount() and not UnitOnTaxi("player")) or HealerGUI:IsVisible()) then HealerStatusBuff:Show();
	else HealerStatusBuff:Hide();end;
end

function Healer_HealerUpdateStatusBarDebuff(i,maxPlayer,name,petname)
	local person, castspell, castrank, castid, pri, numCurableDebuffs;

	-- Debuff status
	Healer_DebuffsNeededList[i]=0;
	if(HEALER_AUTODEBUFF) then
		person, castspell, castrank, castid, pri, numCurableDebuffs = Healer_RemoveDebuffCheckTarget(name);
		if(person and pri and pri>=0) then
			Healer_DebuffsNeededList[i]=Healer_DebuffsNeededList[i]+ (numCurableDebuffs or 1);
		end
	end
	
	if(HEALER_AUTODEBUFF and HEALER_DEBUFF_PETS) then
		person, castspell, castrank, castid, pri, numCurableDebuffs = Healer_RemoveDebuffCheckTarget(petname);
		if(person and pri and pri>=0) then
			Healer_DebuffsNeededList[i]=Healer_DebuffsNeededList[i]+ (numCurableDebuffs or 1);
		end
	end

	local debuffTotal=0;
	for j = 0, maxPlayer do
		debuffTotal=debuffTotal+(Healer_DebuffsNeededList[j] or 0);
	end

	--update debuff status bar
	if((not Healer_lastDebuffTotal) or (debuffTotal~=Healer_lastDebuffTotal)) then
		HealerStatusDebuff:SetStatusBarColor(1,1,0); 
		HealerStatusDebuffText:SetVertexColor(1,0,0);
		--HealerStatusDebuffText:SetText("Remove debuff needed");
		HealerStatusDebuffText:SetText(debuffTotal.." debuffs need removal");
		Healer_lastDebuffTotal=debuffTotal;
	end
	if(debuffTotal>0 or HealerGUI:IsVisible()) then HealerStatusDebuff:Show();
	else HealerStatusDebuff:Hide();end;
end	
	
function Healer_PrintBuffsNeeded()
	Healer_CurrentPlayerUpdated=0;
	Healer_PrintNeededBuffsOn=true;
end

function Healer_UpdatePlayerDataWrapper(unit)

	-- Make sure using compatible version of C add-on
	if(not Healer_C_version_checked and (not C_GetVersionNumber or C_GetVersionNumber() < HEALER_REQUIRED_C_VERSION)) then
		--TODO: find a better place for this
		message("Healer requires the C add-on version "..HEALER_REQUIRED_C_VERSION.." or above.  "..
			"Please make sure to use the version include in Healer or newer.");
		Healer_C_version_checked=true;
	end

	local name = Healer_Unit2CName(unit);

	-- Update player data if needed
	local time=GetTime();
	local threshold=.01;
	if((not C_player_data) or (not C_player_data[name]) or (time-C_player_data[name]["UpdateTime"]>threshold) or (time-C_player_data[name]["UpdateTime"]<0)) then
		C_UpdatePlayerData(0,unit);
	end

end

function Healer_Unit2CName(unit)
	-- Get name of unit
	local name = UnitName(unit);
	if (string.find(unit, "pet")) then
		-- pet
		if (unit == "pet") then
			name = UnitName("player") .. "-" .. name;
		else
			name = UnitName(string.gsub(unit, "pet", "")) .. "-" .. name;
		end
	end
	return name;
end
