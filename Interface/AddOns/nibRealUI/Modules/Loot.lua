-- Code based on: sGroupLoot by Shantalya, modified by Alza.
--                Butsu by Haste, heavily modified by Alza
--[[-------------------------------------------------------------------------
  Copyright (c) 2007-2008, Trond A Ekseth
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * Neither the name of Butsu nor the names of its contributors may
        be used to endorse or promote products derived from this
        software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------]]

local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")
local db, ndbc

local MODNAME = "Loot"
local Loot = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false

-- Options
local table_AnchorPoints = {
	"BOTTOM",
	"BOTTOMLEFT",
	"BOTTOMRIGHT",
	"CENTER",
	"LEFT",
	"RIGHT",
	"TOP",
	"TOPLEFT",
	"TOPRIGHT",
}

local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Loot",
		desc = "Modifies the appearance of the Loot windows.",
		childGroups = "tab",
		arg = MODNAME,
		order = 1215,
		args = {
			header = {
				type = "header",
				name = "Loot",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Modifies the appearance of the Loot windows.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Loot module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
					nibRealUI:ReloadUIDialog()
				end,
				order = 30,
			},
			loot = {
				name = "Loot Window",
				type = "group",
				inline = true,
				order = 40,
				args = {
					enabled = {
						type = "toggle",
						name = "Enabled",
						desc = "Skins the Loot window.",
						get = function() return db.loot.enabled end,
						set = function(info, value) 
							db.loot.enabled = value
							nibRealUI:ReloadUIDialog()
						end,
						order = 10,
					},
					position = {
						name = "Position",
						type = "group",
						inline = true,
						order = 20,
						args = {
							cursor = {
								type = "toggle",
								name = "Position at Cursor",
								get = function() return db.loot.cursor end,
								set = function(info, value) 
									db.loot.cursor = value
									Loot:UpdateLootPosition()
								end,
								order = 10,
							},
							position = {
								name = "Custom Position",
								type = "group",
								inline = true,
								order = 20,
								disabled = function() return db.loot.cursor end,
								args = {
									x = {
										type = "input",
										name = "Padding",
										width = "half",
										order = 10,
										get = function(info) return tostring(db.loot.static.x) end,
										set = function(info, value)
											value = nibRealUI:ValidateOffset(value)
											db.loot.static.x = value
											Loot:UpdateLootPosition()
										end,
									},
									y = {
										type = "input",
										name = "Y Offset",
										width = "half",
										order = 20,
										get = function(info) return tostring(db.loot.static.y) end,
										set = function(info, value)
											value = nibRealUI:ValidateOffset(value)
											db.loot.static.y = value
											Loot:UpdateLootPosition()
										end,
									},
									anchor = {
										type = "select",
										name = "Anchor From",
										get = function(info) 
											for k,v in pairs(table_AnchorPoints) do
												if v == db.loot.static.anchor then return k end
											end
										end,
										set = function(info, value)
											db.loot.static.anchor = table_AnchorPoints[value]
											Loot:UpdateLootPosition()
										end,
										style = "dropdown",
										values = table_AnchorPoints,
										order = 30,
									},
								},
							},
						},
					},
				},
			},
			roll = {
				name = "Group Loot",
				type = "group",
				inline = true,
				order = 50,
				args = {
					enabled = {
						type = "toggle",
						name = "Enabled",
						width = "full",
						desc = "Skins the Group Loot frames.",
						get = function() return db.roll.enabled end,
						set = function(info, value) 
							db.roll.enabled = value
							nibRealUI:ReloadUIDialog()
						end,
						order = 10,
					},
					vertical = {
						type = "input",
						name = "Y Offset",
						width = "half",
						order = 20,
						get = function(info) return tostring(db.roll.vertical) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.roll.vertical = value
							Loot:GroupLootPosition()
						end,
					},
					horizontal = {
						type = "input",
						name = "X Offset",
						width = "half",
						order = 30,
						get = function(info) return tostring(db.roll.horizontal) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.roll.horizontal = value
							Loot:GroupLootPosition()
						end,
					},
				},
			},
		},
	}
	end
	return options
end

--------------------
---- GROUP LOOT ----
--------------------
local GroupLootIconSize = 32
local grouplootlist, grouplootframes = {}, {}

local RealUIGroupLootFrame
local positioner

local function GroupLootOnEvent(self, event, rollId)
	local _, name, _, quality, bop, _, _, canDE = GetLootRollItemInfo(rollId)
	tinsert(grouplootlist, {rollId = rollId})
	Loot:UpdateGroupLoot()
end

local function GroupLootFrameOnEvent(self, event, rollId)
	if (self.rollId and rollId==self.rollId) then
		for index, value in next, grouplootlist do
			if(self.rollId==value.rollId) then
				tremove(grouplootlist, index)
				break
			end
		end
		StaticPopup_Hide("CONFIRM_LOOT_ROLL", self.rollId)
		self.rollId = nil
		Loot:UpdateGroupLoot()
	end
end

local function GroupLootFrameOnClick(self)
	HandleModifiedItemClick(self.rollLink)
end

local function GroupLootFrameOnEnter(self)
	if(not self.rollId) then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetLootRollItem(self.rollId)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	CursorUpdate(self)
end

local function GroupLootFrameOnLeave(self)
	GameTooltip:Hide()
	ResetCursor()
end

local function GroupLootButtonOnClick(self, button)
	RollOnLoot(self:GetParent().rollId, self.type)
end

local function GroupLootSortFunc(a, b)
	return a.rollId < b.rollId
end

function Loot:UpdateGroupLoot()
	sort(grouplootlist, GroupLootSortFunc)
	for index, value in next, grouplootframes do value:Hide() end

	local frame
	for index, value in next, grouplootlist do
		frame = grouplootframes[index]
		if(not frame) then
			frame = CreateFrame("Frame", "RealUI_GroupLootFrame"..index, UIParent)
			frame:EnableMouse(true)
			frame:SetWidth(240)
			frame:SetHeight(24)
			frame:SetPoint("BOTTOM", RealUIGroupLootFrame, 0, ((index-1)*(GroupLootIconSize+3)))
			frame:RegisterEvent("CANCEL_LOOT_ROLL")
			frame:SetScript("OnEvent", GroupLootFrameOnEvent)
			frame:SetScript("OnMouseUp", GroupLootFrameOnClick)
			frame:SetScript("OnLeave", GroupLootFrameOnLeave)
			frame:SetScript("OnEnter", GroupLootFrameOnEnter)

			nibRealUI:CreateBD(frame)

			frame.pass = CreateFrame("Button", nil, frame)
			frame.pass.type = 0
			frame.pass.roll = "pass"
			frame.pass:SetWidth(28)
			frame.pass:SetHeight(28)
			frame.pass:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
			frame.pass:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
			frame.pass:SetPoint("RIGHT", 0, 1)
			frame.pass:SetScript("OnClick", GroupLootButtonOnClick)
			
			frame.greed = CreateFrame("Button", nil, frame)
			frame.greed.type = 2
			frame.greed.roll = "greed"
			frame.greed:SetWidth(28)
			frame.greed:SetHeight(28)
			frame.greed:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
			frame.greed:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Down")
			frame.greed:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Highlight")
			frame.greed:SetPoint("RIGHT", frame.pass, "LEFT", -1, -4)
			frame.greed:SetScript("OnClick", GroupLootButtonOnClick)
			
			frame.disenchant = CreateFrame("Button", nil, frame)
			frame.disenchant.type = 3
			frame.disenchant.roll = "disenchant"
			frame.disenchant:SetWidth(28)
			frame.disenchant:SetHeight(28)
			frame.disenchant:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-DE-Up")
			frame.disenchant:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-DE-Down")
			frame.disenchant:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-DE-Highlight")
			frame.disenchant:SetPoint("RIGHT", frame.greed, "LEFT", -1, 2)
			frame.disenchant:SetScript("OnClick", GroupLootButtonOnClick)

			frame.need = CreateFrame("Button", nil, frame)
			frame.need.type = 1
			frame.need.roll = "need"
			frame.need:SetWidth(28)
			frame.need:SetHeight(28)
			frame.need:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
			frame.need:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Down")
			frame.need:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Highlight")
			frame.need:SetPoint("RIGHT", frame.disenchant, "LEFT", -1, 0)
			frame.need:SetScript("OnClick", GroupLootButtonOnClick)
			
			frame.text = nibRealUI:CreateFS(frame, "LEFT")
			frame.text:SetPoint("LEFT", 2, 0)
			frame.text:SetPoint("RIGHT", frame.need, "LEFT")

			local iconFrame = CreateFrame("Frame", nil, frame)
			iconFrame:SetHeight(GroupLootIconSize)
			iconFrame:SetWidth(GroupLootIconSize)
			iconFrame:ClearAllPoints()
			iconFrame:SetPoint("RIGHT", frame, "LEFT", -2, 0)

			local icon = iconFrame:CreateTexture(nil, "OVERLAY")
			icon:SetPoint("TOPLEFT")
			icon:SetPoint("BOTTOMRIGHT")
			icon:SetTexCoord(.08, .92, .08, .92)
			frame.icon = icon

			nibRealUI:CreateBG(icon)

			tinsert(grouplootframes, frame)
		end

		local texture, name, count, quality, bindOnPickUp, Needable, Greedable, Disenchantable = GetLootRollItemInfo(value.rollId)

		if Disenchantable then frame.disenchant:Enable() else frame.disenchant:Disable() end
		if Needable then frame.need:Enable() else frame.need:Disable() end
		if Greedable then frame.greed:Enable() else frame.greed:Disable() end

		SetDesaturation(frame.disenchant:GetNormalTexture(), not Disenchantable)
		SetDesaturation(frame.need:GetNormalTexture(), not Needable)
		SetDesaturation(frame.greed:GetNormalTexture(), not Greedable)

		frame.text:SetText(ITEM_QUALITY_COLORS[quality].hex..name)

		frame.icon:SetTexture(texture) 

		frame.rollId = value.rollId
		frame.rollLink = GetLootRollItemLink(value.rollId)

		frame:Show()
	end
end

function Loot:GroupLootPosition()
	RealUIGroupLootFrame:ClearAllPoints()
	RealUIGroupLootFrame:SetPoint("LEFT", db.roll.horizontal + 41, db.roll.vertical)
end

function Loot:InitializeGroupLoot()
	RealUIGroupLootFrame = CreateFrame("Frame", "RealUI_GroupLoot", UIParent)
	RealUIGroupLootFrame:RegisterEvent("START_LOOT_ROLL")
	RealUIGroupLootFrame:SetScript("OnEvent", GroupLootOnEvent)
	RealUIGroupLootFrame:SetFrameStrata("HIGH")
	RealUIGroupLootFrame:SetWidth(db.resolution[ndbc.resolution].grouplootwidth)
	RealUIGroupLootFrame:SetHeight(24)
	self:GroupLootPosition()
	
	for i = 1,4 do
		local glf = _G["GroupLootFrame"..i]
		glf:UnregisterAllEvents()
		glf:Hide()
		glf:SetScript("OnShow", function(self) self:Hide() end)
	end
end

--------------
---- LOOT ----
--------------
local LootIconSize = 32
local LootSQ, LootSS, LootSN

local RealUILootFrame = CreateFrame("Button", "RealUI_Loot", UIParent)
RealUILootFrame:SetFrameStrata("HIGH")
RealUILootFrame:SetHeight(64)

RealUILootFrame.close = CreateFrame("Button", "RealUI_Loot_Close", RealUILootFrame, "UIPanelCloseButton")
RealUILootFrame.close:SetPoint("TOPRIGHT", RealUILootFrame, "TOPRIGHT", 8, 20)
RealUILootFrame.slots = {}

local LootOnEnter = function(self)
	local slot = self:GetID()
	if(GetLootSlotType(slot)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end
	self.bg:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
end

local LootOnLeave = function(self)
	GameTooltip:Hide()
	ResetCursor()
	self.bg:SetBackdropColor(0, 0, 0, 0.6)
end

local LootOnClick = function(self)
	if(IsModifiedClick()) then
		HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		LootSS = self:GetID()
		LootSQ = self.quality
		LootSN = self.name:GetText()
		LootSlot(LootSS)
	end
end

local createSlot = function(id)
	local frame = CreateFrame("Button", "ButsuSlot"..id, RealUILootFrame)
	frame:SetPoint("TOP", RealUILootFrame, 0, -((id-1)*(LootIconSize+1)))
	frame:SetPoint("RIGHT")
	frame:SetPoint("LEFT")
	frame:SetHeight(24)
	frame:SetFrameStrata("HIGH")
	frame:SetFrameLevel(20)
	frame:SetID(id)
	RealUILootFrame.slots[id] = frame

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOPLEFT", frame, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", frame, 1, -1)
	bg:SetFrameLevel(frame:GetFrameLevel()-1)
	nibRealUI:CreateBD(bg)
	
	frame.bg = bg

	frame:SetScript("OnClick", LootOnClick)
	frame:SetScript("OnEnter", LootOnEnter)
	frame:SetScript("OnLeave", LootOnLeave)

	local iconFrame = CreateFrame("Frame", nil, frame)
	iconFrame:SetHeight(LootIconSize)
	iconFrame:SetWidth(LootIconSize)
	iconFrame:SetFrameStrata("HIGH")
	iconFrame:SetFrameLevel(20)
	iconFrame:ClearAllPoints()
	iconFrame:SetPoint("RIGHT", frame, "LEFT", -2, 0)

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(.08, .92, .08, .92)
	icon:SetPoint("TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", -1, 1)
	frame.icon = icon

	nibRealUI:CreateBG(icon)

	local count = nibRealUI:CreateFS(iconFrame, "CENTER")
	count:SetPoint("TOP", iconFrame, 1, -2)
	count:SetText(1)
	frame.count = count

	local name = nibRealUI:CreateFS(frame, "LEFT")
	name:SetPoint("RIGHT", frame)
	name:SetPoint("LEFT", icon, "RIGHT", 8, 0)
	name:SetNonSpaceWrap(true)
	frame.name = name

	return frame
end

local anchorSlots = function(self)
	local shownSlots = 0
	for i=1, #self.slots do
		local frame = self.slots[i]
		if(frame:IsShown()) then
			shownSlots = shownSlots + 1

			-- We don't have to worry about the previous slots as they're already hidden.
			frame:SetPoint("TOP", RealUILootFrame, 4, (-8 + LootIconSize) - (shownSlots * (LootIconSize+1)))
		end
	end

	self:SetHeight(math.max(shownSlots * LootIconSize + 16, 20))
end

function Loot:UpdateLootPosition()
	local x, y = GetCursorPosition()
	x = x / RealUILootFrame:GetEffectiveScale()
	y = y / RealUILootFrame:GetEffectiveScale()
	
	RealUILootFrame:ClearAllPoints()
	if db.loot.cursor then
		RealUILootFrame:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x-40, y+20)
	else
		RealUILootFrame:SetPoint(db.loot.static.anchor, UIParent, db.loot.static.anchor, db.loot.static.x, db.loot.static.y)
	end
end

RealUILootFrame:SetScript("OnHide", function(self)
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
	CloseLoot()
end)

function Loot:LOOT_CLOSED()
	StaticPopup_Hide"LOOT_BIND"
	RealUILootFrame:Hide()

	for _, v in next, RealUILootFrame.slots do
		v:Hide()
	end
end

function Loot:LOOT_OPENED(event, autoloot)
	RealUILootFrame:Show()
	RealUILootFrame:SetWidth(db.resolution[ndbc.resolution].lootwidth)
	
	if(not RealUILootFrame:IsShown()) then
		CloseLoot(not autoLoot)
	end

	local items = GetNumLootItems()

	Loot:UpdateLootPosition()
	RealUILootFrame:Raise()

	if(items > 0) then
		for i = 1, items do
			local slot = RealUILootFrame.slots[i] or createSlot(i)
			local texture, item, quantity, quality, locked = GetLootSlotInfo(i)
			if texture then
				local color = ITEM_QUALITY_COLORS[quality]

				if (GetLootSlotType(i) == 2) then
					item = item:gsub("\n", ", ")
				end

				if(quantity > 1) then
					slot.count:SetText(quantity)
					slot.count:Show()
				else
					slot.count:Hide()
				end

				slot.quality = quality
				slot.name:SetText(item)
				slot.name:SetTextColor(color.r, color.g, color.b)
				slot.icon:SetTexture(texture)
				slot.icon:SetDesaturated(false)

				slot:Enable()
				slot:Show()
			end
		end
	else
		local slot = RealUILootFrame.slots[1] or createSlot(1)

		slot.name:SetText(":\\ "..EMPTY)
		slot.icon:SetTexture[[Interface\Icons\Inv_box_01]]
		slot.icon:SetDesaturated(true)

		items = 1

		slot.count:Hide()
		slot:Disable()
		slot:Show()
	end

	anchorSlots(RealUILootFrame)
end

function Loot:LOOT_SLOT_CLEARED(event, slot)
	if(not RealUILootFrame:IsShown()) then return end
	RealUILootFrame.slots[slot]:Hide()
	anchorSlots(RealUILootFrame)
end

function Loot:OPEN_MASTER_LOOT_LIST()
	ToggleDropDownMenu(1, nil, GroupLootDropDown, RealUILootFrame.slots[LootSS], 0, 0)
end

function Loot:UPDATE_MASTER_LOOT_LIST()
	UIDropDownMenu_Refresh(GroupLootDropDown)
end

function Loot:InitializeLoot()
	LootFrame:UnregisterAllEvents()
	table.insert(UISpecialFrames, "RealUI_Loot")

	function _G.GroupLootDropDown_GiveLoot(self)
		if ( LootSQ >= MASTER_LOOT_THREHOLD ) then
			local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", ITEM_QUALITY_COLORS[LootSQ].hex..LootSN..FONT_COLOR_CODE_CLOSE, self:GetText())
			if (dialog) then
				dialog.data = self.value
			end
		else
			GiveMasterLoot(LootSS, self.value)
		end
		CloseDropDownMenus()
	end

	StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"].OnAccept = function(self, data)
		GiveMasterLoot(LootSS, data)
	end
	
	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("LOOT_SLOT_CLEARED")
	self:RegisterEvent("LOOT_CLOSED")
	self:RegisterEvent("OPEN_MASTER_LOOT_LIST")
	self:RegisterEvent("UPDATE_MASTER_LOOT_LIST")
end

-----------------------
function Loot:RefreshMod()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	
	if db.loot.enabled then
		self:InitializeLoot()
	end
	if db.roll.enabled then
		self:InitializeGroupLoot()
	end
end

function Loot:PLAYER_LOGIN()
	self:RefreshMod()
end

function Loot:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			["**"] = {
				enabled = true,
			},
			loot = {
				cursor = true,
				static = {
					x = 0,
					y = 0,
					anchor = "CENTER",
				},
			},
			roll = {
				vertical = -210,
				horizontal = 0,
			},
			resolution = {
				[1] = {
					lootwidth = 180,
					grouplootwidth = 240,
				},
				[2] = {
					lootwidth = 200,
					grouplootwidth = 270,
				},
			}
		},
	})
	db = self.db.profile
	ndbc = nibRealUI.db.char
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterPlainOptions(MODNAME, GetOptions)
end

function Loot:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
end