Graydor = CreateFrame("Frame", nil, MerchantFrame)

function Graydor:Sell(...)
	ClearCursor()
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, _, locked = GetContainerItemInfo(bag, slot)
			if texture and not locked then
				local itemlink = GetContainerItemLink(bag, slot)
				local itemname, _, quality, _, _, _, _, _, _, _, itemvendorprice = GetItemInfo(itemlink)
				if quality == 0 and itemvendorprice and itemvendorprice > 0 then
					UseContainerItem(bag, slot)
				end
			end
		end
	end
end

Graydor:SetScript("OnShow", Graydor.Sell)
