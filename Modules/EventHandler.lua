-- Modules\EventHandler.lua
-- Handles game events

local _, LSS = ...

local EventHandler = {}
LSS.eventHandler = EventHandler

-- Initialize event handler immediately
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(_, event, ...)
	EventHandler:OnEvent(event, ...)
end)

-- Register events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

-- Initialize event handler
function EventHandler:Initialize()
	-- Events already registered at module load
end

-- Event dispatcher
function EventHandler:OnEvent(event, ...)
	local handler = self[event]
	if handler then
		handler(self, ...)
	end
end

-- ADDON_LOADED event
function EventHandler:ADDON_LOADED(addonName)
	if addonName == "LootSpecSwapper" then
		-- Initialize database
		if LSS.db and LSS.db.Initialize then
			LSS.db:Initialize()
		end
		
		-- Initialize spec manager
		if LSS.specManager and LSS.specManager.Initialize then
			LSS.specManager:Initialize()
		end
		
		-- Initialize slash commands
		if LSS.commands and LSS.commands.Initialize then
			LSS.commands:Initialize()
		end
		
		-- Initialize config panel
		if LSS.config and LSS.config.Initialize then
			LSS.config:Initialize()
		end
		
		LSS:Print("Loaded v%s", LSS.version or "unknown")
		
	elseif addonName == "Blizzard_EncounterJournal" then
		-- Initialize UI when Encounter Journal loads
		if LSS.ui and LSS.ui.Initialize then
			LSS.ui:Initialize()
		end
		LSS:Debug("Encounter Journal loaded, UI initialized")
	end
end

-- PLAYER_LOGIN event
function EventHandler:PLAYER_LOGIN()
	-- Register combat events
	--frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	frame:RegisterEvent("ENCOUNTER_START")
	frame:RegisterEvent("LOOT_CLOSED")
	
	LSS:Debug("Player logged in, combat events registered")
end

-- PLAYER_TARGET_CHANGED event
--function EventHandler:PLAYER_TARGET_CHANGED()
	--LSS.specManager:OnTargetChanged()
--end

-- ENCOUNTER_START event
function EventHandler:ENCOUNTER_START(encounterID, encounterName, difficultyID, groupSize)
	LSS.specManager:OnEncounterStart(encounterID, difficultyID)
end

-- LOOT_CLOSED event
function EventHandler:LOOT_CLOSED()
	LSS.specManager:OnLootClosed()
end
