-- Modules\UI.lua
-- Handles UI integration with Encounter Journal

local _, LSS = ...

local UI = {}
LSS.ui = UI

-- UI Elements
local mainFrame
local bossButton
local defaultButton
local minimizeButton

-- Initialize UI
function UI:Initialize()
	self:CreateMainFrame()
	self:CreateButtons()
	self:SetupMinimizeButton()
	
	-- Start minimized when journal opens
	self:Minimize()
	
	LSS:Debug("UI initialized")
end

-- Create main frame
function UI:CreateMainFrame()
	-- Create backdrop template mixin check for compatibility
	local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
	
	mainFrame = CreateFrame("Frame", "LSSMainFrame", EncounterJournal, backdropTemplate)
	mainFrame:SetSize(220, 260)
	mainFrame:SetPoint("TOP", EncounterJournal, "TOP", 650, 0)
	
	-- Backdrop
	mainFrame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = {left = 11, right = 12, top = 12, bottom = 11},
	})
	mainFrame:SetBackdropColor(0, 0, 0, 1)
	
	-- Make it movable
	mainFrame:SetFrameStrata("HIGH")
	mainFrame:SetToplevel(true)
	mainFrame:EnableMouse(true)
	mainFrame:SetMovable(true)
	mainFrame:RegisterForDrag("LeftButton")
	mainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	mainFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	
	-- Title bar
	local titleBar = CreateFrame("Frame", nil, mainFrame)
	titleBar:SetSize(185, 40)
	titleBar:SetPoint("TOP", 0, 15)
	titleBar:EnableMouse(true)
	titleBar:RegisterForDrag("LeftButton")
	titleBar:SetScript("OnDragStart", function() mainFrame:StartMoving() end)
	titleBar:SetScript("OnDragStop", function() mainFrame:StopMovingOrSizing() end)
	
	local titleTexture = titleBar:CreateTexture(nil, "BACKGROUND")
	titleTexture:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
	titleTexture:SetPoint("TOPRIGHT", 57, 0)
	titleTexture:SetPoint("BOTTOMLEFT", -58, -24)
	
	local titleText = titleBar:CreateFontString(nil, "OVERLAY")
	titleText:SetFont("Fonts/MORPHEUS.ttf", 15)
	titleText:SetText("Loot Spec Swapper")
	titleText:SetPoint("CENTER", 0, 0)
	
	-- Close button
	local closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
	closeButton:SetPoint("TOPRIGHT", 12, 12)
	closeButton:SetScript("OnClick", function()
		self:Minimize()
	end)
	
	mainFrame:Hide()
end

-- Create boss and default spec buttons
function UI:CreateButtons()
	-- Boss Spec Button
	bossButton = CreateFrame("Button", "LSSBossButton", mainFrame, "UIPanelButtonTemplate")
	bossButton:SetSize(80, 80)
	bossButton:SetPoint("TOP", mainFrame, "TOP", 0, -25)
	bossButton:SetText("<none>")
	bossButton:RegisterForClicks("AnyDown")
	
	bossButton:SetScript("OnClick", function(self, button)
		UI:OnBossButtonClick(button)
	end)
	
	local bossDesc = bossButton:CreateFontString(nil, "OVERLAY")
	bossDesc:SetFont("Fonts/FRIZQT__.TTF", 10)
	bossDesc:SetText("Boss: <none selected>\nLMB: Toggle, RMB: Clear")
	bossDesc:SetPoint("BOTTOM", bossButton, "BOTTOM", 0, -20)
	bossButton.desc = bossDesc
	
	-- Default Spec Button
	defaultButton = CreateFrame("Button", "LSSDefaultButton", mainFrame, "UIPanelButtonTemplate")
	defaultButton:SetSize(80, 80)
	defaultButton:SetPoint("TOP", mainFrame, "TOP", 0, -135)
	defaultButton:RegisterForClicks("AnyDown")
	
	defaultButton:SetScript("OnClick", function(self, button)
		UI:OnDefaultButtonClick(button)
	end)
	
	local defaultDesc = defaultButton:CreateFontString(nil, "OVERLAY")
	defaultDesc:SetFont("Fonts/FRIZQT__.TTF", 10)
	defaultDesc:SetText("Default (switches back after looting):\nLMB: Save, RMB: Clear\n(Use the portrait menu to pick...)")
	defaultDesc:SetPoint("BOTTOM", defaultButton, "BOTTOM", 0, -20)
	defaultButton.desc = defaultDesc
	
	-- Update buttons on frame show and periodically
	mainFrame:SetScript("OnUpdate", function()
		self:UpdateButtons()
	end)
end

-- Setup minimize/restore button
function UI:SetupMinimizeButton()
	minimizeButton = CreateFrame("Button", "LSSMinimizeButton", EncounterJournal, "UIPanelButtonTemplate")
	minimizeButton:SetSize(60, 14)
	minimizeButton:SetPoint("TOP", EncounterJournal, "TOP", 340, -4)
	minimizeButton:SetText("LSS>>")
	minimizeButton:SetFrameStrata(EncounterJournalCloseButton:GetFrameStrata())
	minimizeButton:SetFrameLevel(EncounterJournalCloseButton:GetFrameLevel() + 100)
	minimizeButton:Hide()
	
	minimizeButton:SetScript("OnClick", function()
		self:Restore()
	end)
end

-- Get the combat encounterID (used by ENCOUNTER_START) from an EJ encounterID.
function UI:GetCombatEncounterID(ejEncounterID)
	if not ejEncounterID then return nil end
	local bossName, _, _, _, _, _, combatEncounterID = EJ_GetEncounterInfo(ejEncounterID)
	return bossName, combatEncounterID
end

-- Update button displays
function UI:UpdateButtons()
	if not mainFrame:IsVisible() then
		return
	end
	
	-- Update boss button
	local ejEncounterID = EncounterJournal.encounterID
	
	if ejEncounterID then
		local bossName, combatEncounterID = self:GetCombatEncounterID(ejEncounterID)
		
		if bossName and combatEncounterID then
			local difficulty = EJ_GetDifficulty()
			local specID = LSS.db:GetBossSpec(combatEncounterID, difficulty)
			
			bossButton.desc:SetText(string.format("Boss: %s\nLMB: Toggle, RMB: Clear", bossName))
			self:UpdateButtonIcon(bossButton, specID)
		end
	else
		bossButton.desc:SetText("Boss: <none selected>\nLMB: Toggle, RMB: Clear")
		self:UpdateButtonIcon(bossButton, nil)
	end
	
	-- Update default button
	local defaultSpec = LSS.db:GetDefaultSpec()
	self:UpdateButtonIcon(defaultButton, defaultSpec)
end

-- Update button icon
function UI:UpdateButtonIcon(button, specID)
	if type(specID) == "number" then
		if specID == 0 then
			-- No spec
			local normalTexture = button:GetNormalTexture()
			if normalTexture then
				normalTexture:SetTexture(nil)
			end
			button:SetText("<none>")
		elseif specID == -1 then
			-- Current spec
			local normalTexture = button:GetNormalTexture()
			if normalTexture then
				normalTexture:SetTexture(nil)
			end
			button:SetText("<auto>")
		else
			local specInfo = LSS.specManager:GetSpecInfo(specID)
			if specInfo then
				button:SetNormalTexture(specInfo.icon)
				button:SetText("")
			else
				local normalTexture = button:GetNormalTexture()
				if normalTexture then
					normalTexture:SetTexture(nil)
				end
				button:SetText("???")
			end
		end
	else
		-- nil specID - clear everything
		local normalTexture = button:GetNormalTexture()
		if normalTexture then
			normalTexture:SetTexture(nil)
		end
		button:SetText("<none>")
	end
end

-- Boss button click handler
function UI:OnBossButtonClick(button)
	local ejEncounterID = EncounterJournal.encounterID

	if not ejEncounterID then
		LSS:Print("Please select a boss first")
		return
	end

	local bossName, combatEncounterID = self:GetCombatEncounterID(ejEncounterID)
	local difficulty = EJ_GetDifficulty()

	if not combatEncounterID then
		LSS:Print("Could not resolve encounter ID for this boss")
		return
	end
	
	if button == "RightButton" then
		-- Clear spec
		LSS.db:RemoveBossSpec(combatEncounterID, difficulty)
		LSS:Print("Cleared spec for |cff00ff00%s|r", bossName or ejEncounterID)
	else
		-- Cycle through specs
		local currentSpec = LSS.db:GetBossSpec(combatEncounterID, difficulty)
		local newSpec = LSS.specManager:GetNextSpec(currentSpec)
		
		if newSpec then
			LSS.db:SetBossSpec(combatEncounterID, newSpec, difficulty)
			local specName = LSS.specManager:GetSpecName(newSpec)
			LSS:Print("Set |cff00ff00%s|r for %s", specName, bossName or ejEncounterID)
		else
			LSS:Print("No specializations available")
		end
	end
end

-- Default button click handler
function UI:OnDefaultButtonClick(button)
	if button == "RightButton" then
		-- Set to "Current Spec" (-1)
		LSS.db:SetDefaultSpec(-1)
		LSS:Print("Default spec set to |cff00ff00Current Spec|r")
	else
		-- Cycle through specs
		local currentDefault = LSS.db:GetDefaultSpec()
		local newSpec = LSS.specManager:GetNextDefaultSpec(currentDefault)
		
		if newSpec then
			LSS.db:SetDefaultSpec(newSpec)
			local specName = LSS.specManager:GetSpecName(newSpec)
			LSS:Print("Default spec set to |cff00ff00%s|r", specName)
		else
			LSS:Print("No specializations available")
		end
	end
end

-- Minimize UI
function UI:Minimize()
	if mainFrame then
		mainFrame:Hide()
	end
	if minimizeButton then
		minimizeButton:Show()
	end
	LSS.db:SetMinimized(true)
end

-- Restore UI
function UI:Restore()
	if mainFrame then
		mainFrame:Show()
	end
	if minimizeButton then
		minimizeButton:Hide()
	end
	LSS.db:SetMinimized(false)
end

-- Show UI
function UI:Show()
	if LSS.db:IsMinimized() then
		minimizeButton:Show()
	else
		mainFrame:Show()
	end
end

-- Hide UI
function UI:Hide()
	if mainFrame then
		mainFrame:Hide()
	end
	if minimizeButton then
		minimizeButton:Hide()
	end
end
