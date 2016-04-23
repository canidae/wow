hooksecurefunc("StaticPopup_Show", function(arg1, ...)
	if arg1 == "DUEL_REQUESTED" then
		StaticPopup_Hide("DUEL_REQUESTED")
	end
end)
