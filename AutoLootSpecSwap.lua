local me = CreateFrame("frame")

AutoLootSpecSwap_bossNameToSpecMapping = {}
AutoLootSpecSwap_bossNameToSpecMapping_H = {}
AutoLootSpecSwap_bossNameToSpecMapping_N = {}
AutoLootSpecSwap_bossNameToSpecMapping_L = {}
AutoLootSpecSwap_bossNameToRMMapping = {}
AutoLootSpecSwap_bossNameToRMMapping_H = {}
AutoLootSpecSwap_bossNameToRMMapping_N = {}
AutoLootSpecSwap_bossNameToRMMapping_L = {}
AutoLootSpecSwap_perDifficulty = false
AutoLootSpecSwap_raidLeaderFeatures = false
AutoLootSpecSwap_specToSwitchToAfterLooting = 0
AutoLootSpecSwap_globalSilence = false
AutoLootSpecSwap_minimized = false

local perDiffIDToVarMap = {
	[14] = "AutoLootSpecSwap_bossNameToSpecMapping_N",
	[15] = "AutoLootSpecSwap_bossNameToSpecMapping_H",
	[17] = "AutoLootSpecSwap_bossNameToSpecMapping_L",
	[1] = "AutoLootSpecSwap_bossNameToSpecMapping_N",
	[2] = "AutoLootSpecSwap_bossNameToSpecMapping_H"
}

local autoSwapActive = false
local globalDisable = false
local journalSaveButton = CreateFrame("Button", "EncounterJournalEncounterFrameInfoCreatureButton1ALSSSaveButton",UIParent,"UIPanelButtonTemplate")
local journalDefaultButton = CreateFrame("Button", "EncounterJournalEncounterFrameInfoCreatureButton1ALSSDefaultButton",UIParent,"UIPanelButtonTemplate")
local journalRestoreButton = CreateFrame("Button", "EncounterJournalEncounterFrameInfoCreatureButton1ALSSRestoreButton",UIParent,"UIPanelButtonTemplate")
local journalRLButton = CreateFrame("Button", "EncounterJournalEncounterFrameInfoCreatureButton1ALSSRLButton",UIParent,"UIPanelButtonTemplate")
local f = CreateFrame("frame")
local frl = CreateFrame("frame", nil, f)
local currPlayerSpecTable = {}
local maxSpecs = GetNumSpecializations()
local _,_,classID = UnitClass("player")
local nextSpecTable = {}
local lastSpec
local firstSpec

local origprint = print
local print = function(msg)
	if(not AutoLootSpecSwap_globalSilence) then
		origprint(msg)
	end
end

local function BonusWindowClosed()
	if ( (me.onBonusWindowClosedSpec) and (me.onBonusWindowClosedSpec) ~= (GetLootSpecialization()) ) then
		local newSpec = me.onBonusWindowClosedSpec
		if(newSpec == -1) then
			SetLootSpecialization(0)
			print("AutoLootSpecSwap: CHANGED LOOT SPEC TO FOLLOW CURRENT SPEC")
		else
			SetLootSpecialization(newSpec)
			print("AutoLootSpecSwap: CHANGED LOOT SPEC TO: <<"..(select(2,GetSpecializationInfoByID(newSpec)))..">>")
		end
	end
	
	me.onBonusWindowClosedSpec = nil
end

me:RegisterEvent("PLAYER_TARGET_CHANGED")
me:RegisterEvent("LOOT_CLOSED")
local UnitName = _G["UnitName"]
local UnitIsDead = _G["UnitIsDead"]
me:SetScript("OnEvent", function(self, event)
	if(globalDisable) then return end
	local newSpec = nil
	local newRM = nil
	if(event == "PLAYER_TARGET_CHANGED") then
		if(not UnitIsDead("target")) then
			--if(UnitIsEnemy("player","target")) then
				local currMapID = (GetCurrentMapAreaID()) or 0
				local targetName = UnitName("target")
				if not targetName then return end
				newSpec = AutoLootSpecSwap_bossNameToSpecMapping[targetName..currMapID]
				newRM = AutoLootSpecSwap_bossNameToRMMapping[targetName..currMapID]
				if not newSpec then
					newSpec = AutoLootSpecSwap_bossNameToSpecMapping[targetName]
				end
				if AutoLootSpecSwap_perDifficulty then
					local _,_,diff = GetInstanceInfo()
					if perDiffIDToVarMap[diff] then
						newSpec = (_G[perDiffIDToVarMap[diff]])[targetName..currMapID]
						if(AutoLootSpecSwap_raidLeaderFeatures) then
							newRM = (_G[(perDiffIDToVarMap[diff]):gsub("Spec","RM")])[targetName..currMapID]
							print ((_G[(perDiffIDToVarMap[diff]):gsub("Spec","RM")])[targetName..currMapID])
							print ((perDiffIDToVarMap[diff]):gsub("Spec","RM"))
						end
						if not newSpec then
							newSpec = (_G[perDiffIDToVarMap[diff]])[targetName]
						end
					end
				end
				if(newSpec) then
					inDefaultSpecAlready = false
					autoSwapActive = true
				end
			--end
		end
	elseif(autoSwapActive and (not (inDefaultSpecAlready--[[ or InCombatLockdown()]]))) then
		autoSwapActive = false
		if(AutoLootSpecSwap_specToSwitchToAfterLooting ~= 0) then
			if (GroupLootContainer and GroupLootContainer:IsVisible()) then
				me.onBonusWindowClosedSpec = AutoLootSpecSwap_specToSwitchToAfterLooting
				hooksecurefunc("BonusRollFrame_OnHide", BonusWindowClosed)
				hooksecurefunc("BonusRollFrame_CloseBonusRoll", BonusWindowClosed)
				hooksecurefunc("BonusRollFrame_FinishedFading", BonusWindowClosed)
				hooksecurefunc("BonusRollFrame_AdvanceLootSpinnerAnim", BonusWindowClosed)
			else
				newSpec = AutoLootSpecSwap_specToSwitchToAfterLooting
			end
			inDefaultSpecAlready = true
		end
	end
	if(newSpec and ((GetLootSpecialization()) ~= newSpec)) then
		if(newSpec == -1) then
			SetLootSpecialization(0)
			print("AutoLootSpecSwap: CHANGED LOOT SPEC TO FOLLOW CURRENT SPEC")
		else
			SetLootSpecialization(newSpec)
			print("AutoLootSpecSwap: CHANGED LOOT SPEC TO: <<"..(select(2,GetSpecializationInfoByID(newSpec)))..">>")
		end
	end
	if(AutoLootSpecSwap_raidLeaderFeatures and newRM and (GetLootMethod() ~= newRM) and (UnitIsGroupLeader("player")) and (not InCombatLockdown())) then
		SetLootMethod(newRM)
		print("AutoLootSpecSwap: CHANGED LOOT METHOD TO: <<"..newRM..">>")
	end
end)

local overrideTarget = nil
local overrideSpec = nil
function me.SlashCommandHandler(cmd)
	if cmd and string.lower(cmd) == "record" then
		local currSpec = overrideSpec or (GetLootSpecialization())
		local currTarget = overrideTarget or UnitName("target")
		
		if(type(currSpec) == "number" and type(currTarget) == "string") then
			if(currSpec == 0) then
				origprint("AutoLootSpecSwap: You must set a spec first (right-click your character frame).")
			else
				if AutoLootSpecSwap_perDifficulty then
					local diff = EncounterJournalEncounterFrameInfoDifficulty:GetText()
					if diff then
						if diff:match(PLAYER_DIFFICULTY1) then
							AutoLootSpecSwap_bossNameToSpecMapping_N[currTarget] = currSpec
						elseif diff:match(PLAYER_DIFFICULTY2) then
							AutoLootSpecSwap_bossNameToSpecMapping_H[currTarget] = currSpec
						elseif diff:match(PLAYER_DIFFICULTY3) then
							AutoLootSpecSwap_bossNameToSpecMapping_L[currTarget] = currSpec
						else
							AutoLootSpecSwap_bossNameToSpecMapping[currTarget] = currSpec
						end
					end
				else
					AutoLootSpecSwap_bossNameToSpecMapping[currTarget] = currSpec
				end
			end
		end
	elseif cmd and string.lower(cmd) == "recordrlmode" then
		local currSpec = overrideSpec or (GetLootMethod())
		local currTarget = overrideTarget or UnitName("target")
		
		if(type(currSpec) == "string" and type(currTarget) == "string") then
			if AutoLootSpecSwap_perDifficulty then
				local diff = EncounterJournalEncounterFrameInfoDifficulty:GetText()
				if diff then
					if diff:match(PLAYER_DIFFICULTY1) then
						AutoLootSpecSwap_bossNameToRMMapping_N[currTarget] = currSpec
					elseif diff:match(PLAYER_DIFFICULTY2) then
						AutoLootSpecSwap_bossNameToRMMapping_H[currTarget] = currSpec
					elseif diff:match(PLAYER_DIFFICULTY3) then
						AutoLootSpecSwap_bossNameToRMMapping_L[currTarget] = currSpec
					else
						AutoLootSpecSwap_bossNameToRMMapping[currTarget] = currSpec
					end
				end
			else
				AutoLootSpecSwap_bossNameToRMMapping[currTarget] = currSpec
			end
		end
	elseif cmd and string.lower(cmd) == "setdefault" then
		local currSpec = (GetLootSpecialization())
		if(type(currSpec) == "number") then
			if(currSpec == 0) then
				AutoLootSpecSwap_specToSwitchToAfterLooting = -1
			else
				AutoLootSpecSwap_specToSwitchToAfterLooting = currSpec
			end
		end
	elseif cmd and string.lower(cmd) == "setdefaulttofollow" then
		AutoLootSpecSwap_specToSwitchToAfterLooting = -1
		print("AutoLootSpecSwap: Set default spec to follow your actual spec.")
	elseif cmd and string.lower(cmd) == "list" then
		print("AutoLootSpecSwap: List")
		for k,v in pairs(AutoLootSpecSwap_bossNameToSpecMapping) do
			if(type(v) == "number" and type(k) == "string") then
				print(k..": "..(select(2,GetSpecializationInfoByID(v))))
			end
		end
		if(AutoLootSpecSwap_specToSwitchToAfterLooting) then
			if(AutoLootSpecSwap_specToSwitchToAfterLooting == 0) then
				print("Default: <<No default>>")
			elseif(AutoLootSpecSwap_specToSwitchToAfterLooting == -1) then
				print("Default: <<Current Spec>>")
			else
				print("Default: "..(select(2,GetSpecializationInfoByID(AutoLootSpecSwap_specToSwitchToAfterLooting))))
			end
		end
	elseif cmd and string.lower(cmd) == "forget" then
		local currTarget = overrideTarget or UnitName("target")
		if(type(currTarget) == "string") then
			local noInstanceTarget = (currTarget:gsub("%d+$","")) or ""
			if AutoLootSpecSwap_perDifficulty then
				local diff = EncounterJournalEncounterFrameInfoDifficulty:GetText()
				if diff then
					if diff:match(PLAYER_DIFFICULTY1) then
						AutoLootSpecSwap_bossNameToSpecMapping_N[currTarget] = nil
						AutoLootSpecSwap_bossNameToSpecMapping_N[noInstanceTarget] = nil
					elseif diff:match(PLAYER_DIFFICULTY2) then
						AutoLootSpecSwap_bossNameToSpecMapping_H[currTarget] = nil
						AutoLootSpecSwap_bossNameToSpecMapping_H[noInstanceTarget] = nil
					elseif diff:match(PLAYER_DIFFICULTY3) then
						AutoLootSpecSwap_bossNameToSpecMapping_L[currTarget] = nil
						AutoLootSpecSwap_bossNameToSpecMapping_L[noInstanceTarget] = nil
					else
						AutoLootSpecSwap_bossNameToSpecMapping[currTarget] = nil
						AutoLootSpecSwap_bossNameToSpecMapping[noInstanceTarget] = nil
					end
				end
			else
				AutoLootSpecSwap_bossNameToSpecMapping[currTarget] = nil
				AutoLootSpecSwap_bossNameToSpecMapping[noInstanceTarget] = nil
			end
		end
	elseif cmd and string.lower(cmd) == "forgetrlmode" then
		local currTarget = overrideTarget or UnitName("target")
		if(type(currTarget) == "string") then
			local noInstanceTarget = (currTarget:gsub("%d+$","")) or ""
			if AutoLootSpecSwap_perDifficulty then
				local diff = EncounterJournalEncounterFrameInfoDifficulty:GetText()
				if diff then
					if diff:match(PLAYER_DIFFICULTY1) then
						AutoLootSpecSwap_bossNameToRMMapping_N[currTarget] = nil
						AutoLootSpecSwap_bossNameToRMMapping_N[noInstanceTarget] = nil
					elseif diff:match(PLAYER_DIFFICULTY2) then
						AutoLootSpecSwap_bossNameToRMMapping_H[currTarget] = nil
						AutoLootSpecSwap_bossNameToRMMapping_H[noInstanceTarget] = nil
					elseif diff:match(PLAYER_DIFFICULTY3) then
						AutoLootSpecSwap_bossNameToRMMapping_L[currTarget] = nil
						AutoLootSpecSwap_bossNameToRMMapping_L[noInstanceTarget] = nil
					else
						AutoLootSpecSwap_bossNameToRMMapping[currTarget] = nil
						AutoLootSpecSwap_bossNameToRMMapping[noInstanceTarget] = nil
					end
				end
			else
				AutoLootSpecSwap_bossNameToRMMapping[currTarget] = nil
				AutoLootSpecSwap_bossNameToRMMapping[noInstanceTarget] = nil
			end
		end
	elseif cmd and string.lower(cmd) == "forgetdefault" then
		AutoLootSpecSwap_specToSwitchToAfterLooting = 0
		print("AutoLootSpecSwap: Forgot default spec.")
	elseif cmd and string.lower(cmd) == "diff" then
		AutoLootSpecSwap_perDifficulty = not AutoLootSpecSwap_perDifficulty
		print("Store per difficulty-level: " .. (AutoLootSpecSwap_perDifficulty and "true" or "false"))
	elseif cmd and string.lower(cmd) == "lootmethod" then
		AutoLootSpecSwap_raidLeaderFeatures = not AutoLootSpecSwap_raidLeaderFeatures
		frl:SetShown(AutoLootSpecSwap_raidLeaderFeatures)
		print("AutoLootSpecSwap: Loot method option " .. ((AutoLootSpecSwap_raidLeaderFeatures) and "Enabled." or "Disabled."))
	elseif cmd and string.lower(cmd) == "onff" then
		globalDisable = not globalDisable
		f:SetShown(not globalDisable)
		print("AutoLootSpecSwap: " .. ((not globalDisable) and "Enabled." or "Disabled."))
	elseif cmd and string.lower(cmd) == "quiet" then
		AutoLootSpecSwap_globalSilence = not AutoLootSpecSwap_globalSilence
		print("AutoLootSpecSwap: Unsilenced")
	else
		print("AutoLootSpecSwap: Usage:\n/alss record | setdefault | setdefaulttofollow | list | forget | forgetdefault | quiet | onff")
	end
end

journalRestoreButton:SetScript("OnClick",function(self)
	f:Show()
	self:Hide()
	AutoLootSpecSwap_minimized = false
end)
journalSaveButton:SetScript("OnClick",function(self, button)
	local _,_,_,_,_,_,EJInstanceID = EJ_GetInstanceInfo()
	if (not EncounterJournalEncounterFrameInfoCreatureButton1) or (not EncounterJournalEncounterFrameInfoCreatureButton1.name) or (not EJInstanceID) then
		print("Select a boss first.")
		return
	end
	if(button == "RightButton") then
		overrideTarget = EncounterJournalEncounterFrameInfoCreatureButton1.name .. EJInstanceID
		me.SlashCommandHandler("forget")
		overrideTarget = nil
	else		
		overrideTarget = EncounterJournalEncounterFrameInfoCreatureButton1.name .. EJInstanceID
		overrideSpec = firstSpec
		local selectedSpec = nil
		selectedSpec = AutoLootSpecSwap_bossNameToSpecMapping[overrideTarget]
		if AutoLootSpecSwap_perDifficulty then
			local diff = EncounterJournalEncounterFrameInfoDifficulty:GetText()
			if diff then
				if diff:match(PLAYER_DIFFICULTY1) then
					selectedSpec = AutoLootSpecSwap_bossNameToSpecMapping_N[overrideTarget]
				elseif diff:match(PLAYER_DIFFICULTY2) then
					selectedSpec = AutoLootSpecSwap_bossNameToSpecMapping_H[overrideTarget]
				elseif diff:match(PLAYER_DIFFICULTY3) then
					selectedSpec = AutoLootSpecSwap_bossNameToSpecMapping_L[overrideTarget]
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
		me.SlashCommandHandler("record")
		overrideTarget = nil
		overrideSpec = nil
	end
end)
journalRLButton:SetScript("OnClick",function(self, button)
	local _,_,_,_,_,_,EJInstanceID = EJ_GetInstanceInfo()
	if (not EncounterJournalEncounterFrameInfoCreatureButton1) or (not EncounterJournalEncounterFrameInfoCreatureButton1.name) or (not EJInstanceID) then
		print("Select a boss first.")
		return
	end
	if(button == "RightButton") then
		overrideTarget = EncounterJournalEncounterFrameInfoCreatureButton1.name .. EJInstanceID
		me.SlashCommandHandler("forgetrlmode")
		overrideTarget = nil
	else		
		overrideTarget = EncounterJournalEncounterFrameInfoCreatureButton1.name .. EJInstanceID
		local selectedSpec = AutoLootSpecSwap_bossNameToRMMapping[overrideTarget]
		if AutoLootSpecSwap_perDifficulty then
			local diff = EncounterJournalEncounterFrameInfoDifficulty:GetText()
			if diff then
				if diff:match(PLAYER_DIFFICULTY1) then
					selectedSpec = AutoLootSpecSwap_bossNameToRMMapping_N[overrideTarget]
				elseif diff:match(PLAYER_DIFFICULTY2) then
					selectedSpec = AutoLootSpecSwap_bossNameToRMMapping_H[overrideTarget]
				elseif diff:match(PLAYER_DIFFICULTY3) then
					selectedSpec = AutoLootSpecSwap_bossNameToRMMapping_L[overrideTarget]
				end
			else
				print("Select a difficulty first.")
			end
		end
		overrideSpec = ((not selectedSpec) or selectedSpec:match("personalloot")) and "master" or "personalloot"
		me.SlashCommandHandler("recordrlmode")
		overrideTarget = nil
		overrideSpec = nil
	end
end)

journalSaveButton:RegisterForClicks("AnyDown")
journalDefaultButton:SetScript("OnClick",function(self, button)
	if(button == "RightButton") then
		me.SlashCommandHandler("forgetdefault")
	else
		me.SlashCommandHandler("setdefault")
	end
end)
journalDefaultButton:RegisterForClicks("AnyDown")
journalRLButton:RegisterForClicks("AnyDown")

journalSaveButton:SetWidth(80)
journalSaveButton:SetHeight(80)
journalSaveButton:SetPoint("CENTER",0,400)
journalDefaultButton:SetWidth(80)
journalDefaultButton:SetHeight(80)
journalDefaultButton:SetPoint("CENTER",0,400)
journalRLButton:SetWidth(120)
journalRLButton:SetHeight(40)
journalRLButton:SetText("Raid loot mode:\n<No change>")

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

frl:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",tile = true, tileSize = 32, edgeSize = 32,insets = { left = 11, right = 12, top = 12, bottom = 11 }})
frl:SetBackdropColor(0,0,0,1)
frl:SetFrameStrata("HIGH")
frl:SetToplevel(true)
frl:EnableMouse(true)
frl:SetMovable(true)
frl:SetWidth(220)
frl:SetHeight(100)
frl:ClearAllPoints()
frl:SetPoint("TOP", 0, -258)

journalRLButton:SetParent(frl)
journalRLButton:ClearAllPoints()
journalRLButton:SetPoint("CENTER",0,0)

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
ttlTxt:SetText("AutoLootSpecSwap")
ttlTxt:SetWidth(450)
ttlTxt:SetHeight(64)
ttlTxt:SetPoint("TOP", 0, 12)

local fClose = CreateFrame("Button", nil, f, "UIPanelCloseButton")
fClose:SetPoint("TOPRIGHT", 12, 12)
fClose:SetScript("OnClick", function(self) self:GetParent():Hide(); journalRestoreButton:Show(); AutoLootSpecSwap_minimized = true end)
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

local function UpdateRLButton(bossLM)
	if bossLM then
		journalRLButton:SetText("Raid loot mode:\n" .. bossLM)
	else
		journalRLButton:SetText("Raid loot mode:\n<No change>")
	end
end

journalSaveButton:SetScript("OnUpdate",function(self)
	if(self:IsVisible()) then
		frl:SetShown(AutoLootSpecSwap_raidLeaderFeatures)
		local bossName = EncounterJournalEncounterFrameInfoCreatureButton1.name
		local _,_,_,_,_,_,EJInstanceID = EJ_GetInstanceInfo()
		
		if(type(bossName) == "string") then
			bossName = bossName .. EJInstanceID
			local bossSpec = AutoLootSpecSwap_bossNameToSpecMapping[bossName]
			local bossRM = AutoLootSpecSwap_bossNameToRMMapping[bossName]
			if AutoLootSpecSwap_perDifficulty then
				local diff = EncounterJournalEncounterFrameInfoDifficulty:GetText()
				if diff and diff ~= "" then
					if diff:match(PLAYER_DIFFICULTY1) then
						bossSpec = AutoLootSpecSwap_bossNameToSpecMapping_N[bossName]
						bossRM = AutoLootSpecSwap_bossNameToRMMapping_N[bossName]
					elseif diff:match(PLAYER_DIFFICULTY2) then
						bossSpec = AutoLootSpecSwap_bossNameToSpecMapping_H[bossName]
						bossRM = AutoLootSpecSwap_bossNameToRMMapping_H[bossName]
					elseif diff:match(PLAYER_DIFFICULTY3) then
						bossSpec = AutoLootSpecSwap_bossNameToSpecMapping_L[bossName]
						bossRM = AutoLootSpecSwap_bossNameToRMMapping_L[bossName]
					end
				end
			end
			saveButtonDesc:SetText("Boss: "..bossName.."\nLMB:Toggle, RMB:Clear")
			UpdateSaveButton(bossSpec)
			UpdateRLButton(bossRM)
		end
		
		UpdateDefaultButton(AutoLootSpecSwap_specToSwitchToAfterLooting)
	end
end)

SlashCmdList["AUTOLOOTSPECSWAP"] = me.SlashCommandHandler
SLASH_AUTOLOOTSPECSWAP1 = "/autolootspecswap"
SLASH_AUTOLOOTSPECSWAP2 = "/alss"

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
		journalRestoreButton:SetText("ALSS>>")
		journalRestoreButton:SetParent(EncounterJournal)
		journalRestoreButton:ClearAllPoints()
		journalRestoreButton:SetPoint("TOP",EncounterJournal,"TOP",340,-4)
		if(AutoLootSpecSwap_minimized) then fClose:Click() end
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
	--self:UnregisterAllEvents()
end)


