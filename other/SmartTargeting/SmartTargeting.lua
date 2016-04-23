--[[
	Project....: SmartTargeting
	File.......: SmartTargeting.lua
	Description: Swaps keybindings for targeting depending on various pvp states to aid the player.
	Author.....: canidae [Tarren Mill] <Flåklypa>
	Maintainer.: Hix [Trollbane] <Lingering>
]]


-- Addon namespace.
local addonName, nameSpace = ...

------------------------------------------------------
-- / SmartTargeting / --
------------------------------------------------------

-- Create frame.
nameSpace.SmartTargeting = CreateFrame("Frame", addonName)

-- Create local shortcuts.
local ST = nameSpace.SmartTargeting
local db = nil

-- Register events.
ST:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Variables
ST.account = nil
ST.pvpZone = nil
ST.targetAll = nil
ST.targetPlayers = nil

-- Set scripts.
ST:SetScript("OnEvent", function(self)
	-- Regitser events.
	ST:RegisterEvent("UPDATE_WORLD_STATES")
	ST:RegisterEvent("ZONE_CHANGED")
	ST:RegisterEvent("ZONE_CHANGED_NEW_AREA")

	-- Load database.
	SmartTargeting_DB = SmartTargeting_DB or {}

	-- Link shortcuts.
	nameSpace.db = SmartTargeting_DB
	db = nameSpace.db

	-- Default database.
	if db.pvpZone == nil and GetCurrentBindingSet() == 1 then db.pvpZone = self:InPvpZone() end
	if db.quiet == nil then db.quiet = false end

	-- Collect key bindings.
	self.UpdateKeyBindings()

	-- Hook key bindings update.
	KeyBindingFrame:HookScript("OnHide", self.UpdateKeyBindings)

	-- Set scripts.
	self:SetScript("OnEvent", function(self, event)
		if self.targetAll or self.targetPlayers then
			-- Check state.
			return self:CheckState()
		end
	end)
end)

function ST:CheckState()
	-- Find correct bindings.
	local pvpZone = self:InPvpZone()
	if pvpZone == self.pvpZone then return end

	-- Check for combat.
	if InCombatLockdown() then return self:RegisterEvent("PLAYER_REGEN_ENABLE") end

	-- Attemp set bindings.
	if self.targetPlayers and not SetBinding(self.targetPlayers, "TARGETNEARESTENEMY") then return end
	if self.targetAll and not SetBinding(self.targetAll, "TARGETNEARESTENEMYPLAYER") then return end

	-- Save updated bindings.
	SaveBindings(GetCurrentBindingSet())

	-- Swapped bindings successfully.
	self.targetAll, self.targetPlayers = self.targetPlayers, self.targetAll

	-- Update pvp zone state.
	self.pvpZone = pvpZone

	-- Update account wide pvp zone state.
	if self.account then db.pvpZone = pvpZone end

	-- Unregister events.
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")

	-- Print update message.
	if not db.quiet then
		print("|cffC9A61B" .. (self.targetPlayers or "<unbound>"), "|rset to |cff00CCFFenemy players|r,|cffC9A61B", (self.targetAll or "<unbound>"), "|rset to |cff00CCFFall enemies|r.")
	end
end

function ST:GetBindings()
	return GetBindingKey("TARGETNEARESTENEMY"), GetBindingKey("TARGETNEARESTENEMYPLAYER")
end

function ST:InPvpZone()
	-- Return true if player is in pvp area.
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" then return true end

	local pvpType = GetZonePVPInfo()
	if pvpType == "arena" then return true end
	if pvpType == "combat" and IsInActiveWorldPVP() then return true end

	return false
end

function ST.SlashCommand(command)
	if strlower(command) == "quiet" then
		db.quiet = not db.quiet
		print("|cff00CCFFSmarttargeting:|r Quieting", db.quiet and "Enabled" or "Disabled")
	else
		ST.pvpZone = not ST.pvpZone
		ST:CheckState()
	end
end

function ST.UpdateKeyBindings()
	-- Check binding state.
	ST.account = GetCurrentBindingSet() == 1

	-- Get current bindings.
	ST.targetAll, ST.targetPlayers = ST:GetBindings()

	if ST.account then
		-- Set pvp state to previous account wide pvp state.
		ST.pvpZone = db.pvpZone

		-- Check state.
		ST:CheckState()
	else
		-- Get pvp state.
		ST.pvpZone = ST:InPvpZone()
	end
end

-- Create slash command.
SLASH_SMARTTARGETING1, SLASH_SMARTTARGETING2 = "/smarttargeting", "/st"
SlashCmdList["SMARTTARGETING"] = ST.SlashCommand
