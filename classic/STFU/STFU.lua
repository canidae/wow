STFU_chat_types = {
	["CHAT_MSG_SAY"] = 1,
	["CHAT_MSG_YELL"] = 1,
	["CHAT_MSG_EMOTE"] = 1,
	["CHAT_MSG_TEXT_EMOTE"] = 1,
	["CHAT_MSG_CHANNEL"] = 1
}

STFU_lastlines = {};
STFU_history = 10;
STFU_chatframe = nil;

function STFU_Command(msg)
	msg = (msg or "");
	if (msg == "" and not STFU_block_whispers_message) then
		C_Print("Whispers from unknown people will be blocked with no reply");
		STFU_block_whispers_message = "";
	elseif (msg == "" and STFU_block_whispers_message) then
		C_Print("Whispers from unknown people will no longer be blocked");
		STFU_block_whispers_message = nil;
	else
		C_Print("Whispers from unknown people will be blocked and you'll reply with this message: " .. msg);
		STFU_block_whispers_message = msg;
	end
end

function STFU_IsFriend(name)
	-- uhm, check if i whispered myself
	if (UnitName("player") == name) then
		return 1;
	end
	-- check raid/party
	local players = GetNumRaidMembers();
	local por = "raid";
	if (players == 0) then
		players = GetNumPartyMembers();
		por = "party";
	end
	for a = 1, players do
		local unit = por .. a;
		if (UnitExists(unit) and UnitName(unit) == name) then
			return 1;
		end
	end
	-- check friends
	for a = 1, GetNumFriends() do
		if (GetFriendInfo(a) == name) then
			return 1;
		end
	end
	-- check guild
	GuildRoster(); -- this one won't actually update the guild roster right away
	for a = 1, GetNumGuildMembers(true) do
		if (GetGuildRosterInfo(a) == name) then
			return 1;
		end
	end
end

function STFU_OnLoad()
	STFU_chatframe = ChatFrame_OnEvent;
	ChatFrame_OnEvent = STFU_ChatFrame_OnEvent;

	SLASH_STFU1 = "/stfu";
	SlashCmdList["STFU"] = function(msg)
		STFU_Command(msg)
	end
end

function STFU_ChatFrame_OnEvent()
	if (event == "CHAT_MSG_WHISPER" and STFU_block_whispers_message and arg6 and arg6 ~= "GM" and arg2 and not STFU_IsFriend(arg2)) then
		-- someone tried to whisper me, but i don't like him or her
		if (STFU_block_whispers_message ~= "") then
			SendChatMessage(STFU_block_whispers_message, "WHISPER", nil, arg2);
		end
		return;
	end
	if (event == "CHAT_MSG_WHISPER_INFORM" and arg1 and arg1 == STFU_block_whispers_message) then
		-- the message we sent, we don't want this in our chatframe either
		return;
	end
	if (not STFU_lastlines[this:GetName()]) then
		STFU_lastlines[this:GetName()] = {};
		STFU_lastlines[this:GetName()]["Text"] = {};
		STFU_lastlines[this:GetName()]["Counter"] = 1;
	end
	if (STFU_chat_types[event] and arg1 and arg2) then
		for index, value in STFU_lastlines[this:GetName()]["Text"] do
			if (string.lower(arg1 .. arg2) == value) then
				-- seems like the same message recently was in this window
				return;
			end
		end
		STFU_lastlines[this:GetName()]["Text"][STFU_lastlines[this:GetName()]["Counter"]] = string.lower(arg1 .. arg2);
		STFU_lastlines[this:GetName()]["Counter"] = math.mod(STFU_lastlines[this:GetName()]["Counter"], STFU_history);
		STFU_lastlines[this:GetName()]["Counter"] = STFU_lastlines[this:GetName()]["Counter"] + 1;
	end
	-- filter out characters (except numbers) repeated more than 3 times in a row
	if (arg1) then
		local char;
		local counter;
		local text = arg1;
		arg1 = "";
		for a = 1, string.len(text) do
			local curchar = string.sub(text, a, a);
			if (not char or curchar ~= char or string.find(curchar, "[%da-fA-F]")) then
				counter = 0;
			end
			counter = counter + 1;
			if (counter <= 3) then
				arg1 = arg1 .. curchar;
			end
			char = curchar;
		end
	end
	return STFU_chatframe(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
end
