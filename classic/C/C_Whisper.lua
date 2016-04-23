function C_Whisper(name, message)
	-- whisper a message to someone
	if (not name or not message) then
		-- no name or no message
		return;
	end
	SendChatMessage(message, "WHISPER", nil, name);
end
