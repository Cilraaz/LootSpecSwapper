local addonName, addon = ...
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

function LSS_CreateOptionsPanel()

  -- Create Main Panel
  local configFrame = CreateFrame('Frame', 'LSSConfigFrame', InterfaceOptionsFramePanelContainer)
  configFrame:Hide()
  configFrame.name = 'Loot Spec Swapper'

  local BuildInfo = { GetBuildInfo() }
  if BuildInfo[4] >= 110000 then
    local category, layout = Settings.RegisterCanvasLayoutCategory(configFrame, configFrame.name)
    Settings.RegisterAddOnCategory(category)
    addon.SettingsCategory = category
  else
    InterfaceOptions_AddCategory(configFrame)
  end

  -- Create Title
  local titleLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
  titleLabel:SetPoint('TOPLEFT', configFrame, 'TOPLEFT', 16, -16)
  titleLabel:SetText('Loot Spec Swapper')

  -- Version Info
  local versionLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
  versionLabel:SetPoint('BOTTOMLEFT', titleLabel, 'BOTTOMRIGHT', 8, 0)
  versionLabel:SetText(GetAddOnMetadata('LootSpecSwapper', 'Version'))

  -- Author Info
  local authorLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
  authorLabel:SetPoint('TOPRIGHT', configFrame, 'TOPRIGHT', -16, -24)
  authorLabel:SetText("Author: Cilraaz-Aerie Peak")

  -- Options
  local optionsLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
  optionsLabel:SetPoint('TOPLEFT', titleLabel, 'BOTTOMLEFT', 0, -20)
  optionsLabel:SetText("LSS Options")

  -- Enable/Disable Checkbox
  local disableCheckbox = CreateFrame('CheckButton', nil, configFrame, 'InterfaceOptionsCheckButtonTemplate')
  disableCheckbox:SetPoint('TOPLEFT', optionsLabel, 'BOTTOMLEFT', 20, -5)
  disableCheckbox:SetChecked(LSSDB.disabled)
  disableCheckbox:SetScript("OnClick", function(self)
    local tick = self:GetChecked()
    if tick then
      PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    else
      PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
    end
    addon.frame.SlashCommandHandler("toggle")
  end)

  -- Enable/Disable Label
  local disableLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
  disableLabel:SetPoint('LEFT', disableCheckbox, 'RIGHT', 0, 0)
  disableLabel:SetText("Check to disable Loot Spec Swapper")

  -- Per-Difficulty Checkbox
  local perDifficultyCheckbox = CreateFrame('CheckButton', nil, configFrame, 'InterfaceOptionsCheckButtonTemplate')
  perDifficultyCheckbox:SetPoint('TOPLEFT', disableCheckbox, 'BOTTOMLEFT', 0, -5)
  perDifficultyCheckbox:SetChecked(LSSDB.perDifficulty)
  perDifficultyCheckbox:SetScript("OnClick", function(self)
    local tick = self:GetChecked()
    if tick then
      PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    else
      PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
    end
    addon.frame.SlashCommandHandler("diff")
  end)

  -- Per-Difficulty Label
  local perDifficultyLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
  perDifficultyLabel:SetPoint('LEFT', perDifficultyCheckbox, 'RIGHT', 0, 0)
  perDifficultyLabel:SetText("Check to enable per-difficulty settings")

  -- Silence Checkbox
  local silenceCheckbox = CreateFrame('CheckButton', nil, configFrame, 'InterfaceOptionsCheckButtonTemplate')
  silenceCheckbox:SetPoint('TOPLEFT', perDifficultyCheckbox, 'BOTTOMLEFT', 0, -5)
  silenceCheckbox:SetChecked(LSSDB.globalSilence)
  silenceCheckbox:SetScript("OnClick", function(self)
    local tick = self:GetChecked()
    if tick then
      PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    else
      PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
    end
    addon.frame.SlashCommandHandler("quiet")
  end)

  -- Silence Label
  local silenceLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
  silenceLabel:SetPoint('LEFT', silenceCheckbox, 'RIGHT', 0, 0)
  silenceLabel:SetText("Check to disable addon messages")
  
  -- Debug Checkbox
  local debugCheckbox = CreateFrame('CheckButton', nil, configFrame, 'InterfaceOptionsCheckButtonTemplate')
  debugCheckbox:SetPoint('TOPLEFT', silenceCheckbox, 'BOTTOMLEFT', 0, -5)
  debugCheckbox:SetChecked(LSSDB.debugOn)
  debugCheckbox:SetScript("OnClick", function(self)
    local tick = self:GetChecked()
    if tick then
      PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    else
      PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
    end
    addon.frame.SlashCommandHandler("debug")
  end)
  
  -- Debug Label
  local debugLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
  debugLabel:SetPoint('LEFT', debugCheckbox, 'RIGHT', 0, 0)
  debugLabel:SetText("Check to Debug")

  -- Spec Options
  local specOptionsLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
  specOptionsLabel:SetPoint('TOPLEFT', debugCheckbox, 'BOTTOMLEFT', -20, -10)
  specOptionsLabel:SetText("Specializations Options")

  -- Forget Default Spec
  local forgetDefaultButton = CreateFrame('Button', nil, configFrame, 'UIPanelButtonTemplate')
  forgetDefaultButton:SetText("Forget Default Spec")
  forgetDefaultButton:SetWidth(150)
  forgetDefaultButton:SetHeight(24)
  forgetDefaultButton:SetPoint('TOPLEFT', specOptionsLabel, 'BOTTOMLEFT', 20, -5)
  forgetDefaultButton:SetScript("OnClick", function()
    addon.frame.SlashCommandHandler("forgetdefault")
  end)
  forgetDefaultButton.tooltipText = "This will make the addon forget your default loot spec."

  -- Set Default Spec to current loot spec
  local setDefaultButton = CreateFrame('Button', nil, configFrame, 'UIPanelButtonTemplate')
  setDefaultButton:SetText("Default - Loot")
  setDefaultButton:SetWidth(150)
  setDefaultButton:SetHeight(24)
  setDefaultButton:SetPoint('TOPLEFT', forgetDefaultButton, 'TOPLEFT', 160, 0)
  setDefaultButton:SetScript("OnClick", function()
    addon.frame.SlashCommandHandler("setdefault")
  end)
  setDefaultButton.tooltipText = "This will set the addon's default loot spec to your currently selected loot spec."
  
  local defaultFollowButton = CreateFrame('Button', nil, configFrame, 'UIPanelButtonTemplate')
  defaultFollowButton:SetText("Default - Actual")
  defaultFollowButton:SetWidth(150)
  defaultFollowButton:SetHeight(24)
  defaultFollowButton:SetPoint('TOPLEFT', setDefaultButton, 'TOPLEFT', 160, 0)
  defaultFollowButton:SetScript("OnClick", function()
    addon.frame.SlashCommandHandler("setdefaulttofollow")
  end)
  defaultFollowButton.tooltipText = "This will set the addon's default loot spec to your current actual spec."

  -- Other Options
  local otherOptionsLabel = configFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
  otherOptionsLabel:SetPoint('TOPLEFT', forgetDefaultButton, 'BOTTOMLEFT', -20, -10)
  otherOptionsLabel:SetText("Other Options")

  -- List Button
  local listButton = CreateFrame('Button', nil, configFrame, 'UIPanelButtonTemplate')
  listButton:SetText("List Selections")
  listButton:SetWidth(150)
  listButton:SetHeight(24)
  listButton:SetPoint('TOPLEFT', otherOptionsLabel, 'BOTTOMLEFT', 20, -5)
  listButton:SetScript("OnClick", function()
    addon.frame.SlashCommandHandler("list")
  end)
  listButton.tooltipText = "List all loot spec selections"

  local resetButton = CreateFrame('Button', nil, configFrame, 'UIPanelButtonTemplate')
  resetButton:SetText("RESET LSS")
  resetButton:SetWidth(150)
  resetButton:SetHeight(24)
  resetButton:SetPoint('TOPLEFT', listButton, 'BOTTOMLEFT', 0, -100)
  resetButton:SetScript("OnClick", function()
    addon.frame.SlashCommandHandler("reset")
  end)
  resetButton.tooltipText = "This will wipe all of your settings! Only press if you are certain you want to do this."

end
