function C_GetBuffData(unit, index)
	-- fetch the name, type and text of a buff
	if (not unit or not index) then
		return;
	end
	-- only remove as much as we need to as this method should be fast
	C_TooltipTextLeft1:SetText();
	C_TooltipTextRight1:SetText();
	C_TooltipTextLeft2:SetText();
	C_Tooltip:SetUnitBuff(unit, index);
	return C_TooltipTextLeft1:GetText(), C_TooltipTextRight1:GetText(), C_TooltipTextLeft2:GetText();
end
