local addonName, addon = ...

-- Create our base frame
local lssFrame = CreateFrame("frame")
addon.frame = lssFrame

-- Initialize SavedVariables
if type(LSSDB) ~= "table" then
  LSSDB = {}
end

-- Difficulty Name Table
local difficultyNames = {
  ["1"] = "Dungeon Normal",
  ["2"] = "Dungeon Heroic",
  ["14"] = "Raid Normal",
  ["15"] = "Raid Heroic",
  ["16"] = "Raid Mythic",
  ["17"] = "Raid LFR",
  ["23"] = "Dungeon Mythic"
}

-- Table for boss names that don't match the Encounter Journal encounter name
-- ["Actual Boss Name"] = "Encounter Journal Boss Name",
local bossFixes = {
  -- Dungeons (Cataclysm)
  ["Asaad"] = "Asaad, Caliph of Zephyrs",
  -- Dungeons (Legion)
  ["Dargrul"] = "Dargrul the Underking",
  -- Dungeons (BfA)
  ["Captain Eudora"] = "Council o\' Captains",
  ["Captain Jolly"] = "Council o\' Captains",
  ["Captain Raoul"] = "Council o\' Captains",
  ["Shark Puncher"] = "Ring of Booty",
  -- Dungeons (SL)
  ["Milificent Manastorm"] = "The Manastorms",
  ["Millhouse Manastorm"] = "The Manastorms",
  ["Halkias"] = "Halkias, the Sin-Stained Goliath",
  ["Azules"] = "Kin-Tara",
  ["Devos"] = "Devos, Paragon of Doubt",
  ["Stitchflesh's Creation"] = "Surgeon Stitchflesh",
  ["Dessia the Decapitator"] = "An Affront of Challengers",
  ["Paceran the Virulent"] = "An Affront of Challengers",
  ["Sathel the Accursed"] = "An Affront of Challengers",
  -- Dungeons (DF)
  ["Rira Hackclaw"] = "Hackclaw's War-Band",
  ["Gashtooth"] = "Hackclaw's War-Band",
  ["Tricktotem"] = "Hackclaw's War-Band",
  ["Erkhart Stormvein"] = "Kyrakka and Erkhart Stormvein",
  ["Teera"] = "Teera and Maruuk",
  ["Maruuk"] = "Teera and Maruuk",
  ["Baelog"] = "The Lost Dwarves",
  ["Eric \"The Swift\""] = "The Lost Dwarves",
  ["Olaf"] = "The Lost Dwarves",
  -- Dungeons (TWW)
  ["Nx"] = "Fangs of the Queen",
  ["Vx"] = "Fangs of the Queen",
  ["Starved Crawler"] = "Avanoxx",
  ["Thirsty Patron"] = "Brew Master Aldryr",
  ["Brew Drop"] = "I'pa",
  ["Cindy"] = "Benk Buzzbee",
  ["Ravenous Cinderbee"] = "Benk Buzzbee",
  ["Yes Man"] = "Goldie Baronbottom",
  ["Elaena Emberlanz"] = "Captain Dailcry",
  ["Sergeant Shaynemail"] = "Captain Dailcry",
  ["Taener Duelmal"] = "Captain Dailcry",
  ["E.D.N.A"] = "E.D.N.A.",
  ["Speaker Dorlita"] = "Master Machinists",
  ["Speaker Brokk"] = "Master Machinists",

  -- Raids
  --- World Bosses (SL)
  ["Valinor"] = "Valinor, the Light of Eons",
  ["Mor'geth"] = "Mor'geth, Tormentor of the Damned",
  ["Sav'thul"] = "Antros",
  --- Castle Nathria (SL)
  ["Margore"] = "Huntsman Altimor",
  ["Kael'thas Sunstrider"] = "Sun King's Salvation",
  ["High Torturor Darithos"] = "Sun King's Salvation",
  ["Bleakwing Assassin"] = "Sun King's Salvation",
  ["Vile Occultist"] = "Sun King's Salvation",
  ["Castellan Niklaus"] = "The Council of Blood",
  ["Baroness Frieda"] = "The Council of Blood",
  ["Lord Stavros"] = "The Council of Blood",
  ["General Kaal"] = "Stone Legion Generals",
  ["General Grashaal"] = "Stone Legion Generals",
  --- Sanctum of Domination (SL)
  ["Eye of the Jailer"] = "The Eye of the Jailer",
  ["Kyra"] = "The Nine",
  ["Signe"] = "The Nine",
  ["Skyja"] = "The Nine",
  --- Sepulcher of the First Ones (SL)
  ["Vigilant Custodian"] = "Vigilant Guardian",
  ["Skolex"] = "Skolex, the Insatiable Ravener",
  ["Dausegne"] = "Dausegne, the Fallen Oracle",
  ["Prototype of War"] = "Prototype Pantheon",
  ["Prototype of Duty"] = "Prototype Pantheon",
  ["Lihuvim"] = "Lihuvim, Principal Architect",
  ["Halondrus"] = "Halondrus the Reclaimer",
  ["Mal'Ganis"] = "Lords of Dread",
  ["Kin'tessa"] = "Lords of Dread",
  --- World Bosses (DF)
  ["Strunraan"] = "Strunraan, The Sky's Misery",
  ["Basrikron"] = "Basrikron, The Shale Wing",
  ["Bazual"] = "Bazual, The Dreaded Flame",
  ["Liskanoth"] = "Liskanoth, The Futurebane",
  --- Vault of the Incarnates (DF)
  ["Kadros Icewrath"] = "The Primal Council",
  ["Dathea Stormlash"] = "The Primal Council",
  ["Opalfang"] = "The Primal Council",
  ["Embar Firepath"] = "The Primal Council",
  ["Sennarth"] = "Sennarth, the Cold Breath",
  --- Aberrus, the Shadowed Crucible (DF)
  ["Kazzara"] = "Kazzara, the Hellforged",
  ["Essence of Shadow"] = "The Amalgamation Chamber",
  ["Eternal Blaze"] = "The Amalgamation Chamber",
  ["Neldris"] = "The Forgotten Experiments",
  ["Thadrion"] = "The Forgotten Experiments",
  ["Rionthus"] = "The Forgotten Experiments",
  ["Rashok"] = "Rashok, the Elder",
  ["Warlord Kagni"] = "Assault of the Zaqali",
  ["Zskarn"] = "The Vigilant Steward, Zskarn",
  ["Neltharion"] = "Echo of Neltharion",
  ["Sarkareth"] = "Scalecommander Sarkareth",
  --- Amidrassil (DF)
  ["Urctos"] = "Council of Dreams",
  ["Aerwynn"] = "Council of Dreams",
  ["Pip"] = "Council of Dreams",
  ["Nymue"] = "Nymue, Weaver of the Cycle",
  ["Tindral Sageswift"] = "Tindral Sageswift, Seer of the Flame",
  ["Fyrakk"] = "Fyrakk the Blazing",
  --- World Bosses (TWW)
  ["Kordac"] = "Kordac, the Dormant Protector",
  ["Shurrai"] = "Shurrai, Atrocity of the Undersea",
  ["Orta"] = "Orta, the Broken Mountain",
  --- Nerub-ar Palace (TWW)
  ["Sikran"] = "Sikran, Captain of the Sureki",
  ["Anum'arash"] = "The Silken Court",
  ["Skeinspinner Takazj"] = "The Silken Court",
  ["Shattershell Scarab"] = "The Silken Court",
}

-- Generic Variables
local autoSwapActive = false

-- EJ frame stuffs
local journalSaveButton = CreateFrame("Button", "EncounterJournalEncounterFrameInfoCreatureButton1LSSSaveButton",UIParent,"UIPanelButtonTemplate")
local journalDefaultButton = CreateFrame("Button", "EncounterJournalEncounterFrameInfoCreatureButton1LSSDefaultButton",UIParent,"UIPanelButtonTemplate")
local journalRestoreButton = CreateFrame("Button", "EncounterJournalEncounterFrameInfoCreatureButton1LSSRestoreButton",UIParent,"UIPanelButtonTemplate")
local f = CreateFrame("frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")

-- Spec Variables
local currPlayerSpecTable = {}
local maxSpecs = GetNumSpecializations()
local _,_,classID = UnitClass("player")
local nextSpecTable = {}
local lastSpec
local firstSpec

-- LUA locals
local print = print
local UnitName = UnitName
local UnitIsDead = UnitIsDead
local EJ_GetDifficulty = EJ_GetDifficulty
local EJ_GetInstanceInfo = EJ_GetInstanceInfo

local printOutput = function(msg)
  if (not LSSDB.globalSilence) then
    print(msg)
  end
end

local debugPrint = function(msg)
  if (LSSDB.debugOn) then
    print(msg)
  end
end

local function BonusWindowClosed()
  if ( (lssFrame.onBonusWindowClosedSpec) and (lssFrame.onBonusWindowClosedSpec) ~= (GetLootSpecialization()) ) then
    local newSpec = lssFrame.onBonusWindowClosedSpec
    if (newSpec == -1) then
      SetLootSpecialization(0)
      printOutput("Loot Spec Swapper: CHANGED LOOT SPEC TO FOLLOW CURRENT SPEC")
    else
      SetLootSpecialization(newSpec)
      printOutput("Loot Spec Swapper: CHANGED LOOT SPEC TO: <<"..(select(2,GetSpecializationInfoByID(newSpec)))..">>")
    end
  end

  lssFrame.onBonusWindowClosedSpec = nil
end

lssFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
lssFrame:RegisterEvent("LOOT_CLOSED")
lssFrame:SetScript("OnEvent", function(self, event)
  if (LSSDB.disabled) then return end
  local newSpec = nil
  if (event == "PLAYER_TARGET_CHANGED") then
    if (not UnitIsDead("target")) then
      local currMapID = (C_Map.GetBestMapForUnit("player")) or 0
      local EJInstanceID = EJ_GetInstanceForMap(currMapID)
      local targetName = UnitName("target")
      if not targetName then return end
      if not (targetName == "General Kaal" and EJInstanceID == 1189) then
        if bossFixes[targetName] then targetName = bossFixes[targetName] end
      end
	  debugPrint("targetName: "..targetName)
	  if bossFixes[targetName] then
	    debugPrint("bossFixes: "..bossFixes[targetName])
	  end

      if LSSDB.perDifficulty then
        local _,_,diff = GetInstanceInfo()
        if diff then
          if LSSDB.specPerBoss[diff] then
            if LSSDB.specPerBoss[diff][EJInstanceID] then
              newSpec = LSSDB.specPerBoss[diff][EJInstanceID][targetName]
            end
          end
        end
      else
        if LSSDB.specPerBoss.allDifficulties[EJInstanceID] then
          newSpec = LSSDB.specPerBoss.allDifficulties[EJInstanceID][targetName]
        end
      end
      if newSpec then
        inDefaultSpecAlready = false
        autoSwapActive = true
      else
        --printOutput("LSS: An error has occurred. Spec setting for this boss (all difficulties) not found.")
      end
    end
  elseif (autoSwapActive and (not (inDefaultSpecAlready--[[ or InCombatLockdown()]]))) then
    autoSwapActive = false
    if (LSSDB.afterLootSpec ~= 0) then
      if (GroupLootContainer and GroupLootContainer:IsVisible()) then
        lssFrame.onBonusWindowClosedSpec = LSSDB.afterLootSpec
        hooksecurefunc("BonusRollFrame_OnHide", BonusWindowClosed)
        hooksecurefunc("BonusRollFrame_CloseBonusRoll", BonusWindowClosed)
        hooksecurefunc("BonusRollFrame_FinishedFading", BonusWindowClosed)
        hooksecurefunc("BonusRollFrame_AdvanceLootSpinnerAnim", BonusWindowClosed)
      else
        newSpec = LSSDB.afterLootSpec
      end
      inDefaultSpecAlready = true
    end
  end
  if (newSpec and GetLootSpecialization() ~= newSpec) then
    if (newSpec == -1) then
      SetLootSpecialization(0)
      printOutput("Loot Spec Swapper: CHANGED LOOT SPEC TO FOLLOW CURRENT SPEC")
    else
      SetLootSpecialization(newSpec)
      printOutput("Loot Spec Swapper: CHANGED LOOT SPEC TO: <<"..(select(2,GetSpecializationInfoByID(newSpec)))..">>")
    end
  end
end)

local overrideTarget = nil
local overrideSpec = nil
function lssFrame.SlashCommandHandler(cmd)
  if cmd and string.lower(cmd) == "record" then
    local currSpec = overrideSpec or (GetLootSpecialization())
    local currTarget = overrideTarget or UnitName("target")

    if (type(currSpec) == "number" and type(currTarget) == "string") then
      if (currSpec == 0) then
        printOutput("Loot Spec Swapper: You must set a spec first (right-click your character frame).")
      else
        local EJInstanceID = EncounterJournal.instanceID
        if LSSDB.perDifficulty then
          local diff = EJ_GetDifficulty()
          if diff then
            LSSDB.specPerBoss[diff][EJInstanceID][currTarget] = currSpec
          end
        else
          LSSDB.specPerBoss.allDifficulties[EJInstanceID][currTarget] = currSpec
        end
      end
    end
  elseif cmd and string.lower(cmd) == "setspecafter" then
    local currSpec = (GetLootSpecialization())
    if (type(currSpec) == "number") then
      if (currSpec == 0) then
        LSSDB.afterLootSpec = -1
      else
        LSSDB.afterLootSpec = currSpec
      end
    end
    printOutput("Loot Spec Swapper: Set your after loot spec to your currently selected loot spec.")
  elseif cmd and string.lower(cmd) == "setactualafter" then
    LSSDB.afterLootSpec = -1
    printOutput("Loot Spec Swapper: Set your after loot spec to your actual spec.")
  elseif cmd and string.lower(cmd) == "list" then
    printOutput("Loot Spec Swapper: List")
    if LSSDB.perDifficulty then
      for k,v in pairs(LSSDB.specPerBoss) do
        if k ~= "allDifficulties" then
          for instance, bossInfo in pairs(v) do
            for boss, spec in pairs(bossInfo) do
              local _, specName = GetSpecializationInfoByID(spec)
              printOutput("Difficulty: "..difficultyNames[tostring(k)].." - Instance ID: "..instance.." - Boss: "..boss.." - "..specName)
            end
          end
        end
      end
    else
      for instance, bossInfo in pairs(LSSDB.specPerBoss.allDifficulties) do
        for boss, spec in pairs(bossInfo) do
          local _, specName = GetSpecializationInfoByID(spec)
          printOutput("All Difficulties - Instance ID: "..instance.." - Boss: "..boss.." - "..specName)
        end
      end
    end
    if (LSSDB.afterLootSpec) then
      if (LSSDB.afterLootSpec == 0) then
        printOutput("Default Spec: <<No default>>")
      elseif (LSSDB.afterLootSpec == -1) then
        printOutput("Default Spec: <<Current Spec>>")
      else
        local _, specName = GetSpecializationInfoByID(LSSDB.afterLootSpec)
        printOutput("Default Spec: "..specName)
      end
    end
  elseif cmd and string.lower(cmd) == "forget" then
    local currTarget = overrideTarget or UnitName("target")
    if (type(currTarget) == "string") then
      local EJInstanceID = EncounterJournal.instanceID
      if LSSDB.perDifficulty then
        local diff = EJ_GetDifficulty()
        if diff then
          LSSDB.specPerBoss[diff][EJInstanceID][currTarget] = nil
        end
      else
        LSSDB.specPerBoss.allDifficulties[EJInstanceID][currTarget] = nil
      end
    end
  elseif cmd and string.lower(cmd) == "forgetdefault" then
    LSSDB.afterLootSpec = 0
    printOutput("Loot Spec Swapper: Forgot default spec.")
  elseif cmd and string.lower(cmd) == "diff" then
    LSSDB.perDifficulty = not LSSDB.perDifficulty
    printOutput("Store per difficulty-level: " .. (LSSDB.perDifficulty and "true" or "false"))
  elseif cmd and string.lower(cmd) == "toggle" then
    LSSDB.disabled = not LSSDB.disabled
    if LSSDB.disabled then
      f:Hide()
      journalRestoreButton:Hide()
    else
      journalRestoreButton:Show()
    end
    printOutput("Loot Spec Swapper: " .. ((not LSSDB.disabled) and "Enabled." or "Disabled."))
  elseif cmd and string.lower(cmd) == "quiet" then
    printOutput("Loot Spec Swapper: Silenced")
    LSSDB.globalSilence = not LSSDB.globalSilence
    printOutput("Loot Spec Swapper: Unsilenced")
  elseif cmd and string.lower(cmd) == "debug" then
    LSSDB.debugOn = not LSSDB.debugOn
	printOutput("Loot Spec Swapper: "..LSSDB.debugOn)
  elseif cmd and string.lower(cmd) == "reset" then
    printOutput("Resetting Loot Spec Swapper.")
    LSSDB.specPerBoss = nil
    LSSDB.afterLootSpec = 0
    LSSDB.globalSilence = false
    LSSDB.perDifficulty = false
    LSSDB.disabled = false
    ReloadUI()
  else
    printOutput("LSS: Command not found or help requested")
    printOutput("Loot Spec Swapper usage:")
    printOutput("/lss toggle - Disable the addon's functionality")
    printOutput("/lss quiet - Silence or Unsilence the addon")
    printOutput("/lss list - Show Default Spec and all selected per-boss specs")
    printOutput("/lss diff - Enable or disable per-difficulty spec handling")
    printOutput("/lss setspecafter - LSS will change to your currently selected loot spec after looting a boss")
    printOutput("/lss setactualafter - LSS will change to your current actual spec after looting a boss")
    printOutput("/lss forgetdefault - Forget your selected default spec")
    printOutput("/lss reset - Reset all LSS settings and reload UI")
  end
end

journalRestoreButton:SetScript("OnClick",function(self)
  f:Show()
  self:Hide()
  LSSDB.minimized = false
end)
journalSaveButton:SetScript("OnClick",function(self, button)
  local EJInstanceID = EncounterJournal.instanceID
  if (not EncounterJournalEncounterFrameInfoCreatureButton1) or (not EncounterJournalEncounterFrameInfoCreatureButton1.name) or (not EJInstanceID) then
    printOutput("Select a boss first.")
    return
  end
  if (button == "RightButton") then
    overrideTarget = EJ_GetEncounterInfo(EncounterJournal.encounterID)
    lssFrame.SlashCommandHandler("forget")
    overrideTarget = nil
  else
    overrideTarget = EJ_GetEncounterInfo(EncounterJournal.encounterID)
    overrideSpec = firstSpec
    local selectedSpec = nil
    if LSSDB.perDifficulty then
      local diff = EJ_GetDifficulty()
      if diff then
        selectedSpec = LSSDB.specPerBoss[diff][EJInstanceID][overrideTarget]
      else
        printOutput("Select a difficulty first.")
      end
    else
      selectedSpec = LSSDB.specPerBoss.allDifficulties[EJInstanceID][overrideTarget]
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
  if (button == "RightButton") then
    lssFrame.SlashCommandHandler("forgetdefault")
  else
    lssFrame.SlashCommandHandler("setspecafter")
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
  if (type(bossSpec) == "number") then
    local _, _, _, icon = GetSpecializationInfoByID(bossSpec)
    journalSaveButton:SetNormalTexture(icon)
    journalSaveButton:SetText("")
  else
    journalSaveButton:SetNormalTexture(0,0,0,0,1)
    journalSaveButton:SetText("<none>")
  end
end

local function UpdateDefaultButton(bossSpec)
  if (type(bossSpec) == "number") then
    if (bossSpec == 0) then
      journalDefaultButton:SetNormalTexture(0,0,0,0,1)
      journalDefaultButton:SetText("<none>")
    elseif (bossSpec == -1) then
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
  if (self:IsVisible()) then
    local bossID = EncounterJournal.encounterID
    local bossName = ""
    if bossID ~= nil then
      bossName = EJ_GetEncounterInfo(EncounterJournal.encounterID)
    end
    local EJInstanceID = EncounterJournal.instanceID

    if (type(bossName) == "string" and bossName ~= "") then
      local bossSpec
      if LSSDB.perDifficulty then
        local diff = EJ_GetDifficulty()
        if diff then
          if not LSSDB.specPerBoss[diff] then
            LSSDB.specPerBoss[diff] = {}
          end
          if not LSSDB.specPerBoss[diff][EJInstanceID] then
            LSSDB.specPerBoss[diff][EJInstanceID] = {}
          end
          bossSpec = LSSDB.specPerBoss[diff][EJInstanceID][bossName]
        end
      else
        if not LSSDB.specPerBoss.allDifficulties[EJInstanceID] then
          LSSDB.specPerBoss.allDifficulties[EJInstanceID] = {}
        end
        bossSpec = LSSDB.specPerBoss.allDifficulties[EJInstanceID][bossName]
      end
      saveButtonDesc:SetText("Boss: "..bossName.."\nLMB:Toggle, RMB:Clear")
      UpdateSaveButton(bossSpec)
    end

    UpdateDefaultButton(LSSDB.afterLootSpec)
  end
end)

SlashCmdList["LOOTSPECSWAPPER"] = lssFrame.SlashCommandHandler
SLASH_LOOTSPECSWAPPER1 = "/lootspecswapper"
SLASH_LOOTSPECSWAPPER2 = "/lss"

local loadframe = CreateFrame("frame")
loadframe:RegisterEvent("ADDON_LOADED")
loadframe:SetScript("OnEvent",function(self,event,addon)
  if (addon == "Blizzard_EncounterJournal") then
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
    journalRestoreButton:SetFrameStrata(EncounterJournalCloseButton:GetFrameStrata())
    journalRestoreButton:SetFrameLevel(EncounterJournalCloseButton:GetFrameLevel() + 100)
    if (LSSDB.minimized) then fClose:Click() end
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

  if addon == "LootSpecSwapper" then
    -- Create defaults
    LSSDB.specPerBoss = LSSDB.specPerBoss or {}
    LSSDB.specPerBoss.allDifficulties = LSSDB.specPerBoss.allDifficulties or {}
    LSSDB.perDifficulty = LSSDB.perDifficulty or false
    LSSDB.afterLootSpec = LSSDB.afterLootSpec or 0
    LSSDB.globalSilence = LSSDB.globalSilence or false
    LSSDB.minimized = LSSDB.minimized or false
    LSSDB.disabled = LSSDB.disabled or false
    LSSDB.debugOn = LSSDB.debugOn or false

    -- Remove old SavedVariables data
    if LSSDB.bossNameToSpecMapping then LSSDB.bossNameToSpecMapping = nil; end
    if LSSDB.bossNameToSpecMapping_L then LSSDB.bossNameToSpecMapping_L = nil; end
    if LSSDB.bossNameToSpecMapping_N then LSSDB.bossNameToSpecMapping_N = nil; end
    if LSSDB.bossNameToSpecMapping_H then LSSDB.bossNameToSpecMapping_H = nil; end
    if LSSDB.bossNameToSpecMapping_M then LSSDB.bossNameToSpecMapping_M = nil; end
    if LSSDB.specToSwitchToAfterLooting then LSSDB.specToSwitchToAfterLooting = nil; end

    -- Create Options Panel
    LSS_CreateOptionsPanel()
  end
end)
