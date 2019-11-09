function C_Error(message)
	-- print a message to the UIErrorsFrame
	UIErrorsFrame:AddMessage(message, 1.0, 0.0, 0.0, 1.0, UIERRORS_HOLD_TIME);
end
