local lssFrame = CreateFrame("frame")

if type(LSSDB) ~= "table" then
  LSSDB = {};
end

LSSDB.bossNameToSpecMapping = {}
LSSDB.bossNameToSpecMapping_H = {}
LSSDB.bossNameToSpecMapping_N = {}
LSSDB.bossNameToSpecMapping_L = {}
LSSDB.perDifficulty = false
LSSDB.specToSwitchToAfterLooting = 0
LSSDB.globalSilence = false
LSSDB.minimized = false

local perDiffIDToVarMap = {
  [14] = "LSSDB.bossNameToSpecMapping_N",
  [15] = "LSSDB.bossNameToSpecMapping_H",
  [17] = "LSSDB.bossNameToSpecMapping_L",
  [1] = "LSSDB.bossNameToSpecMapping_N",
  [2] = "LSSDB.bossNameToSpecMapping_H"
}

local autoSwapActive = false
local globalDisable = false
local journalSaveButton = CreateFrame("Button", "EncounterJournalEncounterFrameInfoCreatureButton1LSSSaveButton",UIParent,"UIPanelButtonTemplate")
local journalDefaultButton = CreateFrame("Button", "EncounterJournalEncounterFrameInfoCreatureButton1LSSDefaultButton",UIParent,"UIPanelButtonTemplate")
local journalRestoreButton = CreateFrame("Button", "EncounterJournalEncounterFrameInfoCreatureButton1LSSRestoreButton",UIParent,"UIPanelButtonTemplate")
local f = CreateFrame("frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
local currPlayerSpecTable = {}
local maxSpecs = GetNumSpecializations()
local _,_,classID = UnitClass("player")
local nextSpecTable = {}
local lastSpec
local firstSpec

local origprint = print
local UnitName = _G["UnitName"]
local UnitIsDead = _G["UnitIsDead"]

local print = function(msg)
  if(not LSSDB.globalSilence) then
    origprint(msg)
  end
end

local function BonusWindowClosed()
  if ( (lssFrame.onBonusWindowClosedSpec) and (lssFrame.onBonusWindowClosedSpec) ~= (GetLootSpecialization()) ) then
    local newSpec = lssFrame.onBonusWindowClosedSpec
    if(newSpec == -1) then
      SetLootSpecialization(0)
      print("Loot Spec Swapper: CHANGED LOOT SPEC TO FOLLOW CURRENT SPEC")
    else
      SetLootSpecialization(newSpec)
      print("Loot Spec Swapper: CHANGED LOOT SPEC TO: <<"..(select(2,GetSpecializationInfoByID(newSpec)))..">>")
    end
  end

  lssFrame.onBonusWindowClosedSpec = nil
end

lssFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
lssFrame:RegisterEvent("LOOT_CLOSED")
lssFrame:SetScript("OnEvent", function(self, event)
  if(globalDisable) then return end
  local newSpec = nil
  if(event == "PLAYER_TARGET_CHANGED") then
    if(not UnitIsDead("target")) then
      local currMapID = (C_Map.GetBestMapForUnit("player")) or 0
      local targetName = UnitName("target")
      if not targetName then return end
      newSpec = LSSDB.bossNameToSpecMapping[targetName..currMapID]
      if not newSpec then
        newSpec = LSSDB.bossNameToSpecMapping[targetName]
      end
      if LSSDB.perDifficulty then
        local _,_,diff = GetInstanceInfo()
        if perDiffIDToVarMap[diff] then
          newSpec = (_G[perDiffIDToVarMap[diff]])[targetName..currMapID]
          if not newSpec then
            newSpec = (_G[perDiffIDToVarMap[diff]])[targetName]
          end
        end
      end
      if(newSpec) then
        inDefaultSpecAlready = false
        autoSwapActive = true
      end
    end
  elseif(autoSwapActive and (not (inDefaultSpecAlready--[[ or InCombatLockdown()]]))) then
    autoSwapActive = false
    if(LSSDB.specToSwitchToAfterLooting ~= 0) then
      if (GroupLootContainer and GroupLootContainer:IsVisible()) then
        lssFrame.onBonusWindowClosedSpec = LSSDB.specToSwitchToAfterLooting
        hooksecurefunc("BonusRollFrame_OnHide", BonusWindowClosed)
        hooksecurefunc("BonusRollFrame_CloseBonusRoll", BonusWindowClosed)
        hooksecurefunc("BonusRollFrame_FinishedFading", BonusWindowClosed)
        hooksecurefunc("BonusRollFrame_AdvanceLootSpinnerAnim", BonusWindowClosed)
      else
        newSpec = LSSDB.specToSwitchToAfterLooting
      end
      inDefaultSpecAlready = true
    end
  end
  if(newSpec and ((GetLootSpecialization()) ~= newSpec)) then
    if(newSpec == -1) then
      SetLootSpecialization(0)
      print("Loot Spec Swapper: CHANGED LOOT SPEC TO FOLLOW CURRENT SPEC")
    else
      SetLootSpecialization(newSpec)
      print("Loot Spec Swapper: CHANGED LOOT SPEC TO: <<"..(select(2,GetSpecializationInfoByID(newSpec)))..">>")
    end
  end
end)

local overrideTarget = nil
local overrideSpec = nil
function lssFrame.SlashCommandHandler(cmd)
  if cmd and string.lower(cmd) == "record" then
    local currSpec = overrideSpec or (GetLootSpecialization())
    local currTarget = overrideTarget or UnitName("target")

    if(type(currSpec) == "number" and type(currTarget) == "string") then
      if(currSpec == 0) then
        origprint("Loot Spec Swapper: You must set a spec first (right-click your character frame).")
      else
        if LSSDB.perDifficulty then
          local diff = EncounterJournalEncounterFrameInfoDifficulty:GetText()
          if diff then
            if diff:match(PLAYER_DIFFICULTY1) then
              LSSDB.bossNameToSpecMapping_N[currTarget] = currSpec
            elseif diff:match(PLAYER_DIFFICULTY2) then
              LSSDB.bossNameToSpecMapping_H[currTarget] = currSpec
            elseif diff:match(PLAYER_DIFFICULTY3) then
              LSSDB.bossNameToSpecMapping_L[currTarget] = currSpec
            else
              LSSDB.bossNameToSpecMapping[currTarget] = currSpec
            end
          end
        else
          LSSDB.bossNameToSpecMapping[currTarget] = currSpec
        end
      end
    end
  elseif cmd and string.lower(cmd) == "setdefault" then
    local currSpec = (GetLootSpecialization())
    if(type(currSpec) == "number") then
      if(currSpec == 0) then
        LSSDB.specToSwitchToAfterLooting = -1
      else
        LSSDB.specToSwitchToAfterLooting = currSpec
      end
    end
  elseif cmd and string.lower(cmd) == "setdefaulttofollow" then
    LSSDB.specToSwitchToAfterLooting = -1
    origprint("Loot Spec Swapper: Set default spec to follow your actual spec.")
  elseif cmd and string.lower(cmd) == "list" then
    origprint("Loot Spec Swapper: List")
    for k,v in pairs(LSSDB.bossNameToSpecMapping) do
      if(type(v) == "number" and type(k) == "string") then
        origprint(k..": "..(select(2,GetSpecializationInfoByID(v))))
      end
    end
    if(LSSDB.specToSwitchToAfterLooting) then
      if(LSSDB.specToSwitchToAfterLooting == 0) then
        origprint("Default: <<No default>>")
      elseif(LSSDB.specToSwitchToAfterLooting == -1) then
        origprint("Default: <<Current Spec>>")
      else
        origprint("Default: "..(select(2,GetSpecializationInfoByID(LSSDB.specToSwitchToAfterLooting))))
      end
    end
  elseif cmd and string.lower(cmd) == "forget" then
    local currTarget = overrideTarget or UnitName("target")
    if(type(currTarget) == "string") then
      local noInstanceTarget = (currTarget:gsub("%d+$","")) or ""
      if LSSDB.perDifficulty then
        local diff = EncounterJournalEncounterFrameInfoDifficulty:GetText()
        if diff then
          if diff:match(PLAYER_DIFFICULTY1) then
            LSSDB.bossNameToSpecMapping_N[currTarget] = nil
            LSSDB.bossNameToSpecMapping_N[noInstanceTarget] = nil
          elseif diff:match(PLAYER_DIFFICULTY2) then
            LSSDB.bossNameToSpecMapping_H[currTarget] = nil
            LSSDB.bossNameToSpecMapping_H[noInstanceTarget] = nil
          elseif diff:match(PLAYER_DIFFICULTY3) then
            LSSDB.bossNameToSpecMapping_L[currTarget] = nil
            LSSDB.bossNameToSpecMapping_L[noInstanceTarget] = nil
          else
            LSSDB.bossNameToSpecMapping[currTarget] = nil
            LSSDB.bossNameToSpecMapping[noInstanceTarget] = nil
          end
        end
      else
        LSSDB.bossNameToSpecMapping[currTarget] = nil
        LSSDB.bossNameToSpecMapping[noInstanceTarget] = nil
      end
    end
  elseif cmd and string.lower(cmd) == "forgetdefault" then
    LSSDB.specToSwitchToAfterLooting = 0
    origprint("Loot Spec Swapper: Forgot default spec.")
  elseif cmd and string.lower(cmd) == "diff" then
    LSSDB.perDifficulty = not LSSDB.perDifficulty
    origprint("Store per difficulty-level: " .. (LSSDB.perDifficulty and "true" or "false"))
  elseif cmd and string.lower(cmd) == "onoff" then
    globalDisable = not globalDisable
    f:SetShown(not globalDisable)
    origprint("Loot Spec Swapper: " .. ((not globalDisable) and "Enabled." or "Disabled."))
  elseif cmd and string.lower(cmd) == "quiet" then
    print("Loot Spec Swapper: Silenced")
    LSSDB.globalSilence = not LSSDB.globalSilence
    print("Loot Spec Swapper: Unsilenced")
  else
    origprint("Loot Spec Swapper: Usage:\n/lss onoff | quiet | list | record | forget | setdefault | forgetdefault | setdefaulttofollow")
  end
end

journalRestoreButton:SetScript("OnClick",function(self)
  f:Show()
  self:Hide()
  LSSDB.minimized = false
end)
journalSaveButton:SetScript("OnClick",function(self, button)
  local _,_,_,_,_,_,EJInstanceID = EJ_GetInstanceInfo()
  if (not EncounterJournalEncounterFrameInfoCreatureButton1) or (not EncounterJournalEncounterFrameInfoCreatureButton1.name) or (not EJInstanceID) then
    print("Select a boss first.")
    return
  end
  if(button == "RightButton") then
    overrideTarget = EncounterJournalEncounterFrameInfoCreatureButton1.name .. EJInstanceID
    lssFrame.SlashCommandHandler("forget")
    overrideTarget = nil
  else
    overrideTarget = EncounterJournalEncounterFrameInfoCreatureButton1.name .. EJInstanceID
    overrideSpec = firstSpec
    local selectedSpec = nil
    selectedSpec = LSSDB.bossNameToSpecMapping[overrideTarget]
    if LSSDB.perDifficulty then
      local diff = EncounterJournalEncounterFrameInfoDifficulty:GetText()
      if diff then
        if diff:match(PLAYER_DIFFICULTY1) then
          selectedSpec = LSSDB.bossNameToSpecMapping_N[overrideTarget]
        elseif diff:match(PLAYER_DIFFICULTY2) then
          selectedSpec = LSSDB.bossNameToSpecMapping_H[overrideTarget]
        elseif diff:match(PLAYER_DIFFICULTY3) then
          selectedSpec = LSSDB.bossNameToSpecMapping_L[overrideTarget]
        end
      else
        print("Select a difficulty first.")
      end
    end
    if selectedSpec then
      overrideSpec = selectedSpec
      firstSpec = selectedSpec
      overrideSpec = currPlayerSpecTable[nextSpecTable[overrideSpec]][1]
      firstSpec = overrideSpec
    end
    lssFrame.SlashCommandHandler("record")
    overrideTarget = nil
    overrideSpec = nil
  end
end)

journalSaveButton:RegisterForClicks("AnyDown")
journalDefaultButton:SetScript("OnClick",function(self, button)
  if(button == "RightButton") then
    lssFrame.SlashCommandHandler("forgetdefault")
  else
    lssFrame.SlashCommandHandler("setdefault")
  end
end)
journalDefaultButton:RegisterForClicks("AnyDown")

journalSaveButton:SetWidth(80)
journalSaveButton:SetHeight(80)
journalSaveButton:SetPoint("CENTER",0,400)
journalDefaultButton:SetWidth(80)
journalDefaultButton:SetHeight(80)
journalDefaultButton:SetPoint("CENTER",0,400)

f:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",tile = true, tileSize = 32, edgeSize = 32,insets = { left = 11, right = 12, top = 12, bottom = 11 }})
f:SetBackdropColor(0,0,0,1)
f:SetFrameStrata("HIGH")
f:SetToplevel(true)
f:EnableMouse(true)
f:SetMovable(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", function(self) self:StartMoving() end)
f:SetScript("OnDragStop", function (self) self:StopMovingOrSizing() end)
f:SetWidth(220)
f:SetHeight(260)

local ttl = CreateFrame("frame", nil, f)
ttl:SetWidth(185)
ttl:SetHeight(40)
ttl:SetPoint("TOP", 0, 15)
ttl:SetFrameStrata("BACKGROUND")

ttl:EnableMouse(true)
ttl:RegisterForDrag("LeftButton")
ttl:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
ttl:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)

local ttx = ttl:CreateTexture(nil, "BACKGROUND")
ttx:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
ttx:SetPoint("TOPRIGHT", 57, 0)
ttx:SetPoint("BOTTOMLEFT", -58, -24)

local ttlTxt = ttl:CreateFontString(nil, "OVERLAY", nil)
ttlTxt:SetFont("Fonts/MORPHEUS.ttf", 15)
ttlTxt:SetText("Loot Spec Swapper")
ttlTxt:SetWidth(450)
ttlTxt:SetHeight(64)
ttlTxt:SetPoint("TOP", 0, 12)

local fClose = CreateFrame("Button", nil, f, "UIPanelCloseButton")
fClose:SetPoint("TOPRIGHT", 12, 12)
fClose:SetScript("OnClick", function(self) self:GetParent():Hide(); journalRestoreButton:Show(); LSSDB.minimized = true end)
fClose:Show()

journalSaveButton:SetParent(f)
journalSaveButton:SetText("<none>")
journalSaveButton:ClearAllPoints()
journalSaveButton:SetPoint("TOP",f,"TOP",0,-25)

local saveButtonDesc = journalSaveButton:CreateFontString(nil, "OVERLAY", nil)
saveButtonDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
saveButtonDesc:SetText("Boss: <none selected>\nLMB:Toggle, RMB:Clear")
saveButtonDesc:SetWidth(450)
saveButtonDesc:SetHeight(64)
saveButtonDesc:SetPoint("BOTTOM", 0, -43)

journalDefaultButton:SetParent(f)
journalDefaultButton:ClearAllPoints()
journalDefaultButton:SetPoint("TOP",f,"TOP",0,-135)
journalRestoreButton:Hide()

local defaultButtonDesc = journalDefaultButton:CreateFontString(nil, "OVERLAY", nil)
defaultButtonDesc:SetFont("Fonts\\FRIZQT__.TTF", 10)
defaultButtonDesc:SetText("Default (switches back after looting):\nLMB:Save, RMB: Clear\n(Use the portrait menu to pick...)")
defaultButtonDesc:SetWidth(450)
defaultButtonDesc:SetHeight(64)
defaultButtonDesc:SetPoint("BOTTOM", 0, -48)

f:Hide()

local function UpdateSaveButton(bossSpec)
  if(type(bossSpec) == "number") then
    local _, _, _, icon = GetSpecializationInfoByID(bossSpec)
    journalSaveButton:SetNormalTexture(icon)
    journalSaveButton:SetText("")
  else
    journalSaveButton:SetNormalTexture(0,0,0,0,1)
    journalSaveButton:SetText("<none>")
  end
end

local function UpdateDefaultButton(bossSpec)
  if(type(bossSpec) == "number") then
    if(bossSpec == 0) then
      journalDefaultButton:SetNormalTexture(0,0,0,0,1)
      journalDefaultButton:SetText("<none>")
    elseif(bossSpec == -1) then
      journalDefaultButton:SetNormalTexture(0,0,0,0,1)
      journalDefaultButton:SetText("<auto>")
    else
      local _, _, _, icon = GetSpecializationInfoByID(bossSpec)
      journalDefaultButton:SetNormalTexture(icon)
      journalDefaultButton:SetText("")
    end
  else
    journalDefaultButton:SetNormalTexture(0,0,0,0,1)
    journalDefaultButton:SetText("<none>")
  end
end

journalSaveButton:SetScript("OnUpdate",function(self)
  if(self:IsVisible()) then
    local bossName = EncounterJournalEncounterFrameInfoCreatureButton1.name
    local _,_,_,_,_,_,EJInstanceID = EJ_GetInstanceInfo()

    if(type(bossName) == "string") then
      bossName = bossName .. EJInstanceID
      local bossSpec = LSSDB.bossNameToSpecMapping[bossName]
      if LSSDB.perDifficulty then
        local diff = EncounterJournalEncounterFrameInfoDifficulty:GetText()
        if diff and diff ~= "" then
          if diff:match(PLAYER_DIFFICULTY1) then
            bossSpec = LSSDB.bossNameToSpecMapping_N[bossName]
          elseif diff:match(PLAYER_DIFFICULTY2) then
            bossSpec = LSSDB.bossNameToSpecMapping_H[bossName]
          elseif diff:match(PLAYER_DIFFICULTY3) then
            bossSpec = LSSDB.bossNameToSpecMapping_L[bossName]
          end
        end
      end
      saveButtonDesc:SetText("Boss: "..bossName.."\nLMB:Toggle, RMB:Clear")
      UpdateSaveButton(bossSpec)
    end

    UpdateDefaultButton(LSSDB.specToSwitchToAfterLooting)
  end
end)

SlashCmdList["LOOTSPECSWAPPER"] = lssFrame.SlashCommandHandler
SLASH_LOOTSPECSWAPPER1 = "/lootspecswapper"
SLASH_LOOTSPECSWAPPER2 = "/lss"

local loadframe = CreateFrame("frame")
loadframe:RegisterEvent("ADDON_LOADED")
loadframe:SetScript("OnEvent",function(self,event,addon)
  if(addon == "Blizzard_EncounterJournal") then
    maxSpecs = GetNumSpecializations()
    f:SetParent(EncounterJournal)
    f:Show()
    f:ClearAllPoints()
    f:SetPoint("TOP",EncounterJournal,"TOP",650,0)
    journalRestoreButton:SetWidth(60)
    journalRestoreButton:SetHeight(14)
    journalRestoreButton:SetText("LSS>>")
    journalRestoreButton:SetParent(EncounterJournal)
    journalRestoreButton:ClearAllPoints()
    journalRestoreButton:SetPoint("TOP",EncounterJournal,"TOP",340,-4)
    if(LSSDB.minimized) then fClose:Click() end
      for i=1,maxSpecs do
        local id, _, _, icon = GetSpecializationInfoForClassID(classID, i)
        currPlayerSpecTable[i] = {id, icon}
        if i == 1 then
          firstSpec = id
        end
        if i > 1 then
          nextSpecTable[lastSpec] = i
        end
        if i == maxSpecs then
          nextSpecTable[id] = 1
        end
        lastSpec = id
      end
    end
end)
