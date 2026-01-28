-- Modules\Database.lua
-- Handles SavedVariables and database operations

local _, LSS = ...

local Database = {}
LSS.db = Database

-- Default database structure
local defaults = {
	version = 1,
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
end

-- Get spec for a boss
function Database:GetBossSpec(instanceID, bossName, difficulty)
	if not instanceID or not bossName then
		return nil
	end
	
	if self.data.perDifficulty and difficulty then
		if self.data.specPerBoss[difficulty] and 
		   self.data.specPerBoss[difficulty][instanceID] then
			return self.data.specPerBoss[difficulty][instanceID][bossName]
		end
	else
		if self.data.specPerBoss.allDifficulties[instanceID] then
			return self.data.specPerBoss.allDifficulties[instanceID][bossName]
		end
	end
	
	return nil
end

-- Set spec for a boss
function Database:SetBossSpec(instanceID, bossName, specID, difficulty)
	if not instanceID or not bossName or not specID then
		return false
	end
	
	if self.data.perDifficulty and difficulty then
		-- Ensure structure exists
		if not self.data.specPerBoss[difficulty] then
			self.data.specPerBoss[difficulty] = {}
		end
		if not self.data.specPerBoss[difficulty][instanceID] then
			self.data.specPerBoss[difficulty][instanceID] = {}
		end
		
		self.data.specPerBoss[difficulty][instanceID][bossName] = specID
	else
		-- Ensure structure exists
		if not self.data.specPerBoss.allDifficulties[instanceID] then
			self.data.specPerBoss.allDifficulties[instanceID] = {}
		end
		
		self.data.specPerBoss.allDifficulties[instanceID][bossName] = specID
	end
	
	return true
end

-- Remove spec for a boss
function Database:RemoveBossSpec(instanceID, bossName, difficulty)
	if not instanceID or not bossName then
		return false
	end
	
	if self.data.perDifficulty and difficulty then
		if self.data.specPerBoss[difficulty] and 
		   self.data.specPerBoss[difficulty][instanceID] then
			self.data.specPerBoss[difficulty][instanceID][bossName] = nil
			return true
		end
	else
		if self.data.specPerBoss.allDifficulties[instanceID] then
			self.data.specPerBoss.allDifficulties[instanceID][bossName] = nil
			return true
		end
	end
	
	return false
end

-- Get all boss specs (for listing)
function Database:GetAllBossSpecs()
	local results = {}
	
	if self.data.perDifficulty then
		for difficulty, instances in pairs(self.data.specPerBoss) do
			if difficulty ~= "allDifficulties" then
				for instanceID, bosses in pairs(instances) do
					for bossName, specID in pairs(bosses) do
						table.insert(results, {
							difficulty = difficulty,
							instanceID = instanceID,
							bossName = bossName,
							specID = specID,
						})
					end
				end
			end
		end
	else
		for instanceID, bosses in pairs(self.data.specPerBoss.allDifficulties) do
			for bossName, specID in pairs(bosses) do
				table.insert(results, {
					difficulty = nil,
					instanceID = instanceID,
					bossName = bossName,
					specID = specID,
				})
			end
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
