-- Core.lua
-- Main addon initialization and namespace

local ADDON_NAME, LSS = ...

-- Addon info
LSS.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
LSS.author = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Author")

-- Module references (will be populated by modules)
LSS.db = nil
LSS.specManager = nil
LSS.eventHandler = nil
LSS.commands = nil
LSS.ui = nil
LSS.config = nil

-- Constants
LSS.DIFFICULTY_NAMES = {
	[1] = "Dungeon Normal",
	[2] = "Dungeon Heroic",
	[14] = "Raid Normal",
	[15] = "Raid Heroic",
	[16] = "Raid Mythic",
	[17] = "Raid LFR",
	[23] = "Dungeon Mythic",
}

-- Utility functions
function LSS:Print(msg, ...)
	if not self.db or not self.db:IsSilenced() then
		print("|cff00ff00[LSS]|r", string.format(msg, ...))
	end
end

function LSS:Debug(msg, ...)
	if self.db and self.db:IsDebugMode() then
		print("|cffff8800[LSS Debug]|r", string.format(msg, ...))
	end
end

function LSS:Error(msg, ...)
	print("|cffff0000[LSS Error]|r", string.format(msg, ...))
end

-- Global accessor
_G[ADDON_NAME] = LSS
