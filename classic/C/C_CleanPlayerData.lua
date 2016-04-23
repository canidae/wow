function C_CleanPlayerData()
	if (C_player_data) then
		local time = GetTime();
		-- Delete all names that haven't been updated in 5 minutes (300 sec)
		for name in C_player_data do 
			if (time - C_player_data[name]["UpdateTime"] > 300) then
				C_player_data[name] = nil;
			end
		end
	end
end
