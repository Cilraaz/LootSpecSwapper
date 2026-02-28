-- Modules\Commands.lua
-- Handles slash commands

local _, LSS = ...

local Commands = {}
LSS.commands = Commands

-- Command handlers
local commandHandlers = {}

-- /lss toggle - Enable/disable addon
commandHandlers.toggle = function()
	local disabled = LSS.db:IsDisabled()
	LSS.db:SetDisabled(not disabled)
	
	if LSS.db:IsDisabled() then
		LSS:Print("Addon |cffff0000DISABLED|r")
		if LSS.ui and LSS.ui.Hide then
			LSS.ui:Hide()
		end
	else
		LSS:Print("Addon |cff00ff00ENABLED|r")
		if LSS.ui and LSS.ui.Show then
			LSS.ui:Show()
		end
	end
end

-- /lss quiet - Toggle silence
commandHandlers.quiet = function()
	local silenced = LSS.db:ToggleSilence()
	
	if not silenced then
		-- Only print if we're unsilencing
		LSS:Print("Messages |cff00ff00ENABLED|r")
	end
end

-- /lss debug - Toggle debug mode
commandHandlers.debug = function()
	local debug = LSS.db:ToggleDebugMode()
	LSS:Print("Debug mode: |cff00ff00%s|r", debug and "ON" or "OFF")
end

-- /lss diff - Toggle per-difficulty mode
commandHandlers.diff = function()
	local perDiff = LSS.db:TogglePerDifficulty()
	LSS:Print("Per-difficulty mode: |cff00ff00%s|r", perDiff and "ON" or "OFF")
end

-- /lss list - List all configured specs
commandHandlers.list = function()
	LSS:Print("=== Loot Spec Configuration ===")
	
	local specs = LSS.db:GetAllBossSpecs()
	
	if #specs == 0 then
		LSS:Print("No boss specs configured yet.")
	else
		for _, entry in ipairs(specs) do
			local diffName = entry.difficulty and LSS.DIFFICULTY_NAMES[entry.difficulty] or "All Difficulties"
			local specName = LSS.specManager:GetSpecName(entry.specID)
			-- Resolve a human-readable boss name from the EJ for display only
			local bossName = EJ_GetEncounterInfo(entry.encounterID) or ("encounterID:" .. entry.encounterID)
			
			LSS:Print("%s - %s: |cff00ff00%s|r", diffName, bossName, specName)
		end
	end
	
	-- Show default spec
	local defaultSpec = LSS.db:GetDefaultSpec()
	local defaultName = LSS.specManager:GetSpecName(defaultSpec)
	LSS:Print("Default Spec (after loot): |cff00ff00%s|r", defaultName)
end

-- /lss setspecafter - Set default spec to current loot spec
commandHandlers.setspecafter = function()
	local currentSpec = GetLootSpecialization()
	
	if currentSpec == 0 then
		LSS.db:SetDefaultSpec(-1)
		LSS:Print("Default spec set to |cff00ff00Current Spec|r")
	else
		LSS.db:SetDefaultSpec(currentSpec)
		local specName = LSS.specManager:GetSpecName(currentSpec)
		LSS:Print("Default spec set to |cff00ff00%s|r", specName)
	end
end

-- /lss setactualafter - Set default spec to current actual spec
commandHandlers.setactualafter = function()
	LSS.db:SetDefaultSpec(-1)
	LSS:Print("Default spec set to |cff00ff00Current Spec|r")
end

-- /lss forgetdefault - Clear default spec
commandHandlers.forgetdefault = function()
	LSS.db:SetDefaultSpec(0)
	LSS:Print("Default spec cleared")
end

-- /lss reset - Reset all settings
commandHandlers.reset = function()
	LSS:Print("|cffff0000WARNING:|r This will reset ALL settings. Type |cffff8800/lss confirmreset|r to confirm.")
end

commandHandlers.confirmreset = function()
	LSS:Print("Resetting all settings...")
	LSS.db:Reset()
	ReloadUI()
end

-- /lss help or unknown command
commandHandlers.help = function()
	LSS:Print("=== Loot Spec Swapper Commands ===")
	LSS:Print("|cffff8800/lss toggle|r - Enable/disable the addon")
	LSS:Print("|cffff8800/lss quiet|r - Toggle chat messages")
	LSS:Print("|cffff8800/lss debug|r - Toggle debug mode")
	LSS:Print("|cffff8800/lss diff|r - Toggle per-difficulty settings")
	LSS:Print("|cffff8800/lss list|r - List all configured specs")
	LSS:Print("|cffff8800/lss setspecafter|r - Set default spec (after loot)")
	LSS:Print("|cffff8800/lss setactualafter|r - Set default to current spec")
	LSS:Print("|cffff8800/lss forgetdefault|r - Clear default spec")
	LSS:Print("|cffff8800/lss reset|r - Reset all settings")
	LSS:Print("Use the Encounter Journal interface to configure boss specs")
end

-- Main command handler
function Commands:HandleCommand(input)
	local command = string.lower(input or "")
	
	-- Remove leading/trailing whitespace
	command = strtrim(command)
	
	-- Get the handler
	local handler = commandHandlers[command]
	
	if handler then
		handler()
	else
		commandHandlers.help()
	end
end

-- Initialize slash commands
function Commands:Initialize()
	SLASH_LOOTSPECSWAPPER1 = "/lootspecswapper"
	SLASH_LOOTSPECSWAPPER2 = "/lss"
	
	SlashCmdList["LOOTSPECSWAPPER"] = function(msg)
		Commands:HandleCommand(msg)
	end
	
	LSS:Debug("Slash commands initialized")
end
