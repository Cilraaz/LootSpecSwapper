-- Modules\Database.lua
-- Handles SavedVariables and database operations

local _, LSS = ...

local Database = {}
LSS.db = Database

-- Default database structure
local defaults = {
	version = 2,
	perDifficulty = false,
	afterLootSpec = 0, -- 0 = none, -1 = current spec, >0 = specific spec ID
	globalSilence = false,
	debugMode = false,
	disabled = false,
	minimized = true,
	specPerBoss = {
		allDifficulties = {},
		-- Per-difficulty tables will be created as needed: [difficultyID] = {}
	},
}

-- Initialize database
function Database:Initialize()
	if type(LSSDB) ~= "table" then
		LSSDB = {}
	end
	
	self.data = LSSDB
	
	-- Apply defaults for missing values
	for key, value in pairs(defaults) do
		if self.data[key] == nil then
			if type(value) == "table" then
				self.data[key] = self:DeepCopy(value)
			else
				self.data[key] = value
			end
		end
	end
	
	-- Clean up old data structures from previous versions
	self:CleanupOldData()
	
	LSS:Debug("Database initialized (version %d)", self.data.version)
end

-- Deep copy a table
function Database:DeepCopy(orig)
	local copy
	if type(orig) == "table" then
		copy = {}
		for k, v in pairs(orig) do
			copy[k] = self:DeepCopy(v)
		end
	else
		copy = orig
	end
	return copy
end

-- Clean up old SavedVariables from previous addon versions
function Database:CleanupOldData()
	local oldKeys = {
		"bossNameToSpecMapping",
		"bossNameToSpecMapping_L",
		"bossNameToSpecMapping_N",
		"bossNameToSpecMapping_H",
		"bossNameToSpecMapping_M",
		"specToSwitchToAfterLooting",
	}
	
	for _, key in ipairs(oldKeys) do
		if self.data[key] ~= nil then
			self.data[key] = nil
			LSS:Debug("Removed old database key: %s", key)
		end
	end

	-- Old entries can't be migrated meaningfully, so wipe and start fresh.
	if (self.data.version or 1) < 2 then
		self.data.specPerBoss = self:DeepCopy(defaults.specPerBoss)
		self.data.version = 2
		LSS:Print("Saved data upgraded to v2 (boss specs reset — please reconfigure).")
	end
end

-- Get spec for a boss
function Database:GetBossSpec(encounterID, difficulty)
	if not encounterID then
		return nil
	end

	if self.data.perDifficulty and difficulty then
		if self.data.specPerBoss[difficulty] then
			return self.data.specPerBoss[difficulty][encounterID]
		end
	else
		return self.data.specPerBoss.allDifficulties[encounterID]
	end

	return nil
end

-- Set spec for a boss
function Database:SetBossSpec(encounterID, specID, difficulty)
	if not encounterID or not specID then
		return false
	end

	if self.data.perDifficulty and difficulty then
		if not self.data.specPerBoss[difficulty] then
			self.data.specPerBoss[difficulty] = {}
		end
		self.data.specPerBoss[difficulty][encounterID] = specID
	else
		self.data.specPerBoss.allDifficulties[encounterID] = specID
	end

	return true
end

-- Remove spec for a boss
function Database:RemoveBossSpec(encounterID, difficulty)
	if not encounterID then
		return false
	end

	if self.data.perDifficulty and difficulty then
		if self.data.specPerBoss[difficulty] then
			self.data.specPerBoss[difficulty][encounterID] = nil
			return true
		end
	else
		self.data.specPerBoss.allDifficulties[encounterID] = nil
		return true
	end

	return false
end

-- Get all boss specs (for listing)
function Database:GetAllBossSpecs()
	local results = {}

	if self.data.perDifficulty then
		for difficulty, encounters in pairs(self.data.specPerBoss) do
			if difficulty ~= "allDifficulties" then
				for encounterID, specID in pairs(encounters) do
					table.insert(results, {
						difficulty = difficulty,
						encounterID = encounterID,
						specID = specID,
					})
				end
			end
		end
	else
		for encounterID, specID in pairs(self.data.specPerBoss.allDifficulties) do
			table.insert(results, {
				difficulty = nil,
				encounterID = encounterID,
				specID = specID,
			})
		end
	end

	return results
end

-- Set default spec
function Database:SetDefaultSpec(specID)
	self.data.afterLootSpec = specID
end

-- Get default spec
function Database:GetDefaultSpec()
	return self.data.afterLootSpec
end

-- Toggle per-difficulty mode
function Database:TogglePerDifficulty()
	self.data.perDifficulty = not self.data.perDifficulty
	return self.data.perDifficulty
end

-- Reset all data
function Database:Reset()
	LSSDB = self:DeepCopy(defaults)
	self.data = LSSDB
end

-- Accessor methods for settings
function Database:IsDisabled()
	return self.data.disabled
end

function Database:SetDisabled(disabled)
	self.data.disabled = disabled
end

function Database:IsMinimized()
	return self.data.minimized
end

function Database:SetMinimized(minimized)
	self.data.minimized = minimized
end

function Database:IsSilenced()
	return self.data.globalSilence
end

function Database:ToggleSilence()
	self.data.globalSilence = not self.data.globalSilence
	return self.data.globalSilence
end

function Database:IsDebugMode()
	return self.data.debugMode
end

function Database:ToggleDebugMode()
	self.data.debugMode = not self.data.debugMode
	return self.data.debugMode
end

function Database:IsPerDifficulty()
	return self.data.perDifficulty
end
