Broadcast_update_interval = 5.0;
Broadcast_receivers = {};
Broadcast_player_logged_in = nil;

function Broadcast_Message(id, message)
	-- broadcast a message
	if (not id or not message or not Broadcast_channel or GetChannelName(Broadcast_channel) == 0) then
		-- no message, we're not in a channel or channel is not found
		return;
	end
	message = "[" .. id .. "]: " .. message;
	-- replace all "s" with "&_;"
	message = string.gsub(message, "s", "&%-;");
	-- and all "S" with "&_;"
	message = string.gsub(message, "S", "&_;");
	-- and all "|" with "&^;"
	message = string.gsub(message, "|", "&^;");
	SendChatMessage(message, "CHANNEL", nil, GetChannelName(Broadcast_channel));
	return 1;
end

function Broadcast_OnEvent()
	if (event == "VARIABLES_LOADED") then
		if (type(Broadcast_channel) ~= "string") then
			-- this should be a string, most likely caused by recent changes in the addon
			-- this check may be removed in the future
			Broadcast_channel = nil;
		end
		C_variables_loaded = 1;
	elseif (event == "PLAYER_LOGIN") then
		Broadcast_player_logged_in = 1;
	elseif (event == "CHAT_MSG_CHANNEL" and arg1 and arg2 and arg9 and arg9 == Broadcast_channel) then
		-- replace all "&-;" with "s"
		arg1 = string.gsub(arg1, "&%-;", "s");
		-- and all "&_;" with "S"
		arg1 = string.gsub(arg1, "&_;", "S");
		-- and all "&^;" with "|"
		arg1 = string.gsub(arg1, "&^;", "|");
		-- and remove " ...hic!" if it's on the end of the line
		arg1 = string.gsub(arg1, " %.%.%.hic!$", "");
		local start, stop, id, message = string.find(arg1, "^%[(.+)%]: (.+)$");
		-- and send the message to the right addons
		if (id and message and Broadcast_receivers[id]) then
			for id, func in Broadcast_receivers[id] do
				func(arg2, message);
			end
		end
	end
	Broadcast_UpdateChannel();
end

function Broadcast_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("CHAT_MSG_CHANNEL");
end

function Broadcast_OnUpdate(elapsed)
	Broadcast_update_time = (Broadcast_update_time or 0) + elapsed;
	if (Broadcast_update_time > Broadcast_update_interval) then
		Broadcast_update_time = 0;
		if (C_Variables_loaded and Broadcast_player_logged_in) then
			-- try to update channel every 5th second
			Broadcast_UpdateChannel();
		end
	end
end

function Broadcast_Register(id, receiver)
	-- every addon that wants to use broadcast must register
	-- what method that should receive messages from other clients
	if (not id) then
		return;
	end
	Broadcast_receivers[id] = (Broadcast_receivers[id] or {});
	table.insert(Broadcast_receivers[id], receiver);
	return 1;
end

function Broadcast_UpdateChannel()
	-- channelname is name of party/raid leader plus "Broadcast"
	-- if we're not in a party/raid it's guild name plus "Broadcast"
	local new_channel;
	if (GetNumRaidMembers() > 0) then
		if (Broadcast_last_leader_id and Broadcast_last_leader_id <= GetNumRaidMembers()) then
			local name, rank = GetRaidRosterInfo(Broadcast_last_leader_id);
			if (rank == 2 and name .. "Broadcast" == Broadcast_channel) then
				-- same leader, return
				return;
			end
		end
		local leader;
		for a = 1, GetNumRaidMembers() do
			local name, rank = GetRaidRosterInfo(a);
			if (rank == 2) then
				-- this is our leader
				leader = name;
				Broadcast_last_leader_id = a;
				a = GetNumRaidMembers();
			end
		end
		if (not leader or leader == "") then
			-- hmm, weird
			return;
		end
		new_channel = leader .. "Broadcast";
	elseif (GetNumPartyMembers() > 0) then
		if (UnitIsPartyLeader("player") and UnitName("player") .. "Broadcast" == Broadcast_channel) then
			-- same leader (me!), return
			return;
		end
		if (Broadcast_last_leader_id and UnitExists("party" .. Broadcast_last_leader_id) and UnitIsPartyLeader("party" .. Broadcast_last_leader_id)) then
			if (UnitName("party" .. Broadcast_last_leader_id) .. "Broadcast" == Broadcast_channel) then
				-- same leader, return
				return;
			end
		end
		local leader;
		for a = 1, GetNumPartyMembers() do
			if (UnitExists("party" .. a) and UnitIsPartyLeader("party" .. a)) then
				leader = UnitName("party" .. a);
				Broadcast_last_leader_id = a;
				a = GetNumPartyMembers();
			end
		end
		if (not leader or leader == "") then
			-- apparently player is the leader
			leader = UnitName("player");
		end
		new_channel = leader .. "Broadcast";
	else
		-- we're not in a raid nor party
		local guildname = GetGuildInfo("player");
		if (not guildname or guildname == "") then
			-- we're not in a guild?
			return;
		end
		new_channel = guildname .. "Broadcast";
	end
	if (not new_channel) then
		return;
	end
	new_channel = string.gsub(new_channel, "%s+", "");
	if (Broadcast_channel and Broadcast_channel ~= new_channel) then
		-- leave old channel
		LeaveChannelByName(Broadcast_channel);
		-- this is a hack, as channels tend to get stuck with no good reason at all
		--for a = 1, 10 do
		--	local id, channel = GetChannelName(a);
		--	if (channel and string.find(channel, "Broadcast$")) then
		--		LeaveChannelByName(channel);
		--	end
		--end
		Broadcast_channel = nil;
	elseif (not Broadcast_channel) then
		-- and join new channel after a short delay to allow the
		-- chatframe to update its channel listing
		Broadcast_channel = new_channel;
		JoinChannelByName(Broadcast_channel);
	end
end
