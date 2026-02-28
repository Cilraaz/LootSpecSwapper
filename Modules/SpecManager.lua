-- Modules\SpecManager.lua
-- Handles specialization switching and tracking

local _, LSS = ...

local SpecManager = {}
LSS.specManager = SpecManager

-- Local variables
local specCache = {}
local classID
local autoSwapActive = false
local inDefaultSpecAlready = false
local pendingDefaultSpec = nil

-- Initialize spec manager
function SpecManager:Initialize()
	_, _, classID = UnitClass("player")
	self:BuildSpecCache()
	LSS:Debug("SpecManager initialized for class %d", classID)
end

-- Build cache of available specs
function SpecManager:BuildSpecCache()
	specCache = {}
	local numSpecs = GetNumSpecializations()
	
	for i = 1, numSpecs do
		local specID, specName, _, icon = GetSpecializationInfoForClassID(classID, i)
		specCache[specID] = {
			id = specID,
			name = specName,
			icon = icon,
			index = i,
		}
	end
	
	LSS:Debug("Built spec cache with %d specializations", numSpecs)
end

-- Get spec info by ID
function SpecManager:GetSpecInfo(specID)
	-- First check cache
	if specCache[specID] then
		return specCache[specID]
	end
	
	-- If not in cache, get it directly (for loot spec IDs)
	local id, name, description, icon = GetSpecializationInfoByID(specID)
	if id then
		local info = {
			id = id,
			name = name,
			icon = icon,
			index = nil,
		}
		-- Cache it for future use
		specCache[specID] = info
		return info
	end
	
	return nil
end

-- Get all available specs
function SpecManager:GetAllSpecs()
	local specs = {}
	for _, spec in pairs(specCache) do
		table.insert(specs, spec)
	end
	
	-- Sort by index
	table.sort(specs, function(a, b) return a.index < b.index end)
	
	return specs
end

-- Get next spec in rotation (for cycling)
function SpecManager:GetNextSpec(currentSpecID)
	local numSpecs = GetNumSpecializations()
	
	if numSpecs == 0 then
		return nil
	end
	
	-- Build list of all spec IDs for this class
	local specIDs = {}
	for i = 1, numSpecs do
		local specID = GetSpecializationInfoForClassID(classID, i)
		table.insert(specIDs, specID)
	end
	
	-- If no current spec, return first spec
	if not currentSpecID then
		return specIDs[1]
	end
	
	-- Find current spec in list
	local currentIndex = nil
	for i, specID in ipairs(specIDs) do
		if specID == currentSpecID then
			currentIndex = i
			break
		end
	end
	
	-- If current spec found, return next (or wrap to first)
	if currentIndex then
		local nextIndex = (currentIndex % numSpecs) + 1
		return specIDs[nextIndex]
	end
	
	-- If current spec not found, return first
	return specIDs[1]
end

-- Get next default spec (includes "Current Spec" and "None" options)
function SpecManager:GetNextDefaultSpec(currentDefault)
	local numSpecs = GetNumSpecializations()
	
	if numSpecs == 0 then
		return nil
	end
	
	-- Build list: -1 (Current Spec), then all spec IDs, then 0 (None)
	local options = {-1} -- Start with "Current Spec"
	
	for i = 1, numSpecs do
		local specID = GetSpecializationInfoForClassID(classID, i)
		table.insert(options, specID)
	end
	
	table.insert(options, 0) -- End with "None"
	
	-- If no current default, return first option
	if not currentDefault then
		return options[1]
	end
	
	-- Find current in list
	local currentIndex = nil
	for i, option in ipairs(options) do
		if option == currentDefault then
			currentIndex = i
			break
		end
	end
	
	-- Return next (or wrap to first)
	if currentIndex then
		local nextIndex = (currentIndex % #options) + 1
		return options[nextIndex]
	end
	
	-- Default to first option
	return options[1]
end

-- Switch to a specific spec
function SpecManager:SwitchToSpec(specID)
	local currentSpec = GetLootSpecialization()
	
	if currentSpec == specID then
		LSS:Debug("Already using spec %d, no switch needed", specID)
		return false
	end
	
	if specID == -1 then
		-- Special case: switch to current actual spec
		SetLootSpecialization(0)
		LSS:Print("Loot spec changed to CURRENT SPEC")
		return true
	elseif specID == 0 then
		-- No spec set
		SetLootSpecialization(0)
		return true
	else
		local specInfo = self:GetSpecInfo(specID)
		if specInfo then
			SetLootSpecialization(specID)
			LSS:Print("Loot spec changed to |cff00ff00%s|r", specInfo.name)
			return true
		else
			LSS:Error("Invalid spec ID: %d", specID)
			return false
		end
	end
end

-- Handle encounter start
function SpecManager:OnEncounterStart(encounterID, difficultyID)
	if LSS.db:IsDisabled() then
		return
	end

	LSS:Debug("Encounter started: encounterID=%d, difficulty=%d", encounterID, difficultyID)

	local specID = LSS.db:GetBossSpec(encounterID, difficultyID)

	if specID then
		LSS:Debug("Found spec %d for encounterID %d", specID, encounterID)
		self:SwitchToSpec(specID)
		autoSwapActive = true
		inDefaultSpecAlready = false
	else
		LSS:Debug("No spec configured for encounterID: %d", encounterID)
	end
end

-- Handle loot closed (restore default spec)
function SpecManager:OnLootClosed()
	if LSS.db:IsDisabled() then
		return
	end
	
	if autoSwapActive and not inDefaultSpecAlready then
		autoSwapActive = false
		local defaultSpec = LSS.db:GetDefaultSpec()
		
		if defaultSpec ~= 0 then
			-- Check if bonus roll window is visible
			if GroupLootContainer and GroupLootContainer:IsVisible() then
				-- Defer spec change until after bonus roll
				pendingDefaultSpec = defaultSpec
				LSS:Debug("Bonus roll window visible, deferring default spec change")
			else
				self:SwitchToSpec(defaultSpec)
				inDefaultSpecAlready = true
			end
		end
	end
end

-- Handle bonus roll completion
function SpecManager:OnBonusRollComplete()
	if pendingDefaultSpec then
		self:SwitchToSpec(pendingDefaultSpec)
		pendingDefaultSpec = nil
		inDefaultSpecAlready = true
	end
end

-- Get current loot spec
function SpecManager:GetCurrentLootSpec()
	return GetLootSpecialization()
end

-- Get spec name from ID
function SpecManager:GetSpecName(specID)
	if specID == 0 then
		return "None"
	elseif specID == -1 then
		return "Current Spec"
	else
		-- Use GetSpecializationInfoByID directly, which works with loot spec IDs
		local _, name = GetSpecializationInfoByID(specID)
		return name or "Unknown"
	end
end
