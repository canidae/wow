function C_Print(message, color)
	-- print some text to the chatwindow
	if (not message) then
		return;
	end
	if (not color) then
		color = "|cffead9ac";
	end
	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage(color .. message);
	end
end
