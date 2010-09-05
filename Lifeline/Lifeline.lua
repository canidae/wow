Lifeline = CreateFrame("Frame")

function Lifeline:OnUpdate()
	local _, instance = IsInInstance()
	Lifeline.players = {}
	if instance == "arena" then
		for i = 1, 5 do
			Lifeline:AddUnit("arena" .. i)
		end
--	elseif instance == "pvp" then
--		for i = 1, GetNumRaidMembers() do
--			Lifeline:AddUnit("raid" .. i .. "target")
--		end
	else
		return
	end
	local maxname
	local maxcount = 0
	for playername, count in pairs(Lifeline.players) do
		if count > maxcount then
			maxname = playername
			maxcount = count
		end
	end
	if maxcount > 1 and (Lifeline.starname == nil or Lifeline.starname ~= maxname) then
		Lifeline.starname = maxname
		if IsRaidLeader() or IsRaidOfficer() then
			SetRaidTarget(maxname, 8)
		elseif GetNumPartyMembers() > 0 then
			SendChatMessage(maxname .. " is targeted by " .. maxcount .. "!", "PARTY")
		end
	end
end

function Lifeline:AddUnit(unit)
	if UnitIsEnemy("player", unit) and not UnitIsDeadOrGhost(unit) then
		local friendunit = unit .. "target"
		if (UnitPlayerOrPetInParty(friendunit) or UnitPlayerOrPetInRaid(friendunit)) and not UnitIsDeadOrGhost(friendunit) then
			local playername = GetUnitName(friendunit, true)
			if playername then
				if not Lifeline.players[playername] then
					Lifeline.players[playername] = 1
				else
					Lifeline.players[playername] = Lifeline.players[playername] + 1
				end
			end
		end
	end
end

Lifeline:SetScript("OnUpdate", Lifeline.OnUpdate)
