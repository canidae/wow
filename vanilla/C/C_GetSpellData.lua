function C_GetSpellData(spellid, bookid)
	C_ClearTooltip();
	C_Tooltip:SetSpell(spellid, bookid);
	local mana = C_TooltipTextLeft2:GetText();
	local range = C_TooltipTextRight2:GetText();
	local time = C_TooltipTextLeft3:GetText();
	local text = C_TooltipTextLeft4:GetText();
	local text2 = C_TooltipTextLeft5:GetText();
	local text3 = C_TooltipTextLeft6:GetText();
	local text4 = C_TooltipTextLeft7:GetText();
	local text5 = C_TooltipTextLeft8:GetText();
	local start, stop;
	start, stop, mana = string.find(string.gsub((mana or ""), ",", "."), "(%d+%.?%d*)");
	mana = (mana or 0) / 1.0;
	start, stop, time = string.find(string.gsub((time or ""), ",", "."), "(%d+%.?%d*)");
	time = (time or 0) / 1.0;
	start, stop, range = string.find(string.gsub((range or ""), ",", "."), "(%d+%.?%d*)");
	range = (range or 0) / 1.0;
	text = (text or "");
	text = text .. (text2 or "");
	text = text .. (text3 or "");
	text = text .. (text4 or "");
	text = text .. (text5 or "");
	text = string.gsub(text, ",", ".");
	return mana, range, time, text;
end
