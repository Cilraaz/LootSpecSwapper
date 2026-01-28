-- Modules\Config.lua
-- Settings panel for interface options

local _, LSS = ...

local Config = {}
LSS.config = Config

-- Create settings panel
function Config:CreatePanel()
	local panel = CreateFrame("Frame", "LSSConfigPanel")
	panel.name = "Loot Spec Swapper"
	
	-- Check WoW version for settings API
	local buildInfo = {GetBuildInfo()}
	local isRetail = buildInfo[4] >= 110000
	
	if isRetail then
		-- Modern settings API (11.0+)
		local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
		Settings.RegisterAddOnCategory(category)
	else
		-- Legacy interface options
		InterfaceOptions_AddCategory(panel)
	end
	
	-- Create UI elements
	self:CreateTitle(panel)
	self:CreateOptions(panel)
	self:CreateSpecOptions(panel)
	self:CreateOtherOptions(panel)
	
	LSS:Debug("Config panel created")
end

-- Create title
function Config:CreateTitle(parent)
	local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("Loot Spec Swapper")
	
	local version = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	version:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 8, 0)
	version:SetText(LSS.version)
	
	local author = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	author:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, -24)
	author:SetText("Author: " .. LSS.author)
	
	return title
end

-- Create main options
function Config:CreateOptions(parent)
	local lastCheckbox
	
	-- Section label
	local label = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetPoint("TOPLEFT", 16, -60)
	label:SetText("Options")
	
	-- Disable checkbox
	local disableCheck = self:CreateCheckbox(parent, "Disable addon")
	disableCheck:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 20, -5)
	disableCheck:SetChecked(LSS.db:IsDisabled())
	disableCheck:SetScript("OnClick", function(self)
		LSS.commands.HandleCommand(LSS.commands, "toggle")
		self:SetChecked(LSS.db:IsDisabled())
	end)
	lastCheckbox = disableCheck
	
	-- Per-difficulty checkbox
	local diffCheck = self:CreateCheckbox(parent, "Enable per-difficulty settings")
	diffCheck:SetPoint("TOPLEFT", lastCheckbox, "BOTTOMLEFT", 0, -5)
	diffCheck:SetChecked(LSS.db:IsPerDifficulty())
	diffCheck:SetScript("OnClick", function(self)
		LSS.commands.HandleCommand(LSS.commands, "diff")
		self:SetChecked(LSS.db:IsPerDifficulty())
	end)
	lastCheckbox = diffCheck
	
	-- Silence checkbox
	local silenceCheck = self:CreateCheckbox(parent, "Disable addon messages")
	silenceCheck:SetPoint("TOPLEFT", lastCheckbox, "BOTTOMLEFT", 0, -5)
	silenceCheck:SetChecked(LSS.db:IsSilenced())
	silenceCheck:SetScript("OnClick", function(self)
		LSS.commands.HandleCommand(LSS.commands, "quiet")
		self:SetChecked(LSS.db:IsSilenced())
	end)
	lastCheckbox = silenceCheck
	
	-- Debug checkbox
	local debugCheck = self:CreateCheckbox(parent, "Enable debug mode")
	debugCheck:SetPoint("TOPLEFT", lastCheckbox, "BOTTOMLEFT", 0, -5)
	debugCheck:SetChecked(LSS.db:IsDebugMode())
	debugCheck:SetScript("OnClick", function(self)
		LSS.commands.HandleCommand(LSS.commands, "debug")
		self:SetChecked(LSS.db:IsDebugMode())
	end)
	
	return label
end

-- Create spec options
function Config:CreateSpecOptions(parent)
	local label = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetPoint("TOPLEFT", 16, -200)
	label:SetText("Specialization Options")
	
	-- Forget default button
	local forgetBtn = self:CreateButton(parent, "Forget Default Spec", 150, 24)
	forgetBtn:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 20, -5)
	forgetBtn:SetScript("OnClick", function()
		LSS.commands.HandleCommand(LSS.commands, "forgetdefault")
	end)
	
	-- Set default to loot spec button
	local setLootBtn = self:CreateButton(parent, "Default - Loot", 150, 24)
	setLootBtn:SetPoint("LEFT", forgetBtn, "RIGHT", 10, 0)
	setLootBtn:SetScript("OnClick", function()
		LSS.commands.HandleCommand(LSS.commands, "setspecafter")
	end)
	
	-- Set default to actual spec button
	local setActualBtn = self:CreateButton(parent, "Default - Actual", 150, 24)
	setActualBtn:SetPoint("LEFT", setLootBtn, "RIGHT", 10, 0)
	setActualBtn:SetScript("OnClick", function()
		LSS.commands.HandleCommand(LSS.commands, "setactualafter")
	end)
end

-- Create other options
function Config:CreateOtherOptions(parent)
	local label = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetPoint("TOPLEFT", 16, -280)
	label:SetText("Other Options")
	
	-- List button
	local listBtn = self:CreateButton(parent, "List Selections", 150, 24)
	listBtn:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 20, -5)
	listBtn:SetScript("OnClick", function()
		LSS.commands.HandleCommand(LSS.commands, "list")
	end)
	
	-- Reset button
	local resetBtn = self:CreateButton(parent, "RESET LSS", 150, 24)
	resetBtn:SetPoint("TOPLEFT", listBtn, "BOTTOMLEFT", 0, -100)
	resetBtn:SetScript("OnClick", function()
		LSS.commands.HandleCommand(LSS.commands, "reset")
	end)
end

-- Helper: Create checkbox
function Config:CreateCheckbox(parent, text)
	local checkbox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	
	local label = checkbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetPoint("LEFT", checkbox, "RIGHT", 0, 0)
	label:SetText(text)
	checkbox.label = label
	
	checkbox:SetScript("OnClick", function(self)
		if self:GetChecked() then
			PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		else
			PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
		end
	end)
	
	return checkbox
end

-- Helper: Create button
function Config:CreateButton(parent, text, width, height)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width, height)
	button:SetText(text)
	return button
end

-- Initialize config
function Config:Initialize()
	self:CreatePanel()
end
