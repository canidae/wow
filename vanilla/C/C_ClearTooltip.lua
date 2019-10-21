function C_ClearTooltip()
	-- clear our invisble tooltip
	for a = 1, 15 do
		getglobal("C_TooltipTextLeft" .. a):SetText();
		getglobal("C_TooltipTextRight" .. a):SetText();
	end
end
