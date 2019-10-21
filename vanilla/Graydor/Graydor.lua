Graydor = CreateFrame("Frame", nil, MerchantFrame)

function Graydor:Sell(...)
	ClearCursor()
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, _, locked = GetContainerItemInfo(bag, slot)
			if texture and not locked then
                _, _, itemid = string.find(GetContainerItemLink(bag, slot),"item:(%d+):")
				local itemname, _, quality, _, _, _, _, _, _, _, itemvendorprice = GetItemInfo(itemid)
				if quality == 0 then -- TODO? this doesn't work in WoW 1.12.1: and itemvendorprice and itemvendorprice > 0 then
					UseContainerItem(bag, slot)
				end
			end
		end
	end
end

Graydor:SetScript("OnShow", Graydor.Sell)
