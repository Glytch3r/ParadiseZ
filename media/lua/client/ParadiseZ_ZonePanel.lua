require "ISUI/ISCollapsableWindow"
ParadiseZ = ParadiseZ or {}

function ParadiseZ.snapshot(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

ParadiseZ.ZoneEditorWindow = ISCollapsableWindow:derive("ParadiseZ.ZoneEditorWindow")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local HEADER_HGT = FONT_HGT_MEDIUM + 4 * 2
local MARGIN = 13

local Point1_TEX = getTexture("media/ui/Paradise/Point1.png")
local Point2_TEX = getTexture("media/ui/Paradise/Point2.png")
local sync_TEX_ON = getTexture("media/ui/Paradise/sync_on.png")
local sync_TEX_OFF = getTexture("media/ui/Paradise/sync.png")
local reset_TEX = getTexture("media/ui/Paradise/reset.png")
local reset_TEX_ON = getTexture("media/ui/Paradise/reset_on.png")
local reset_TEX_OFF = getTexture("media/ui/Paradise/reset_off.png")
local add_TEX = getTexture("media/ui/Paradise/add.png")
local bg_TEX = getTexture("media/ui/Paradise/bg.png")

local delete_TEX = getTexture("media/ui/Paradise/delete.png")
local delete_TEX_ON = getTexture("media/ui/Paradise/delete_on.png")
local delete_TEX_OFF = getTexture("media/ui/Paradise/delete_off.png")

local TP_TEX = getTexture("media/ui/Paradise/TP.png")
local TP_TEX_ON = getTexture("media/ui/Paradise/TP_on.png")
local TP_TEX_OFF = getTexture("media/ui/Paradise/TP_off.png")

ParadiseZ.flagTextures = {
    HQ = getTexture("media/textures/zone/ParadiseZ_Zone_HQ.png"),
    Outside = getTexture("media/textures/zone/ParadiseZ_Zone_Outside.png"),
    Zone = getTexture("media/textures/zone/ParadiseZ_Zone_Inside.png"),
    NonPvp = getTexture("media/textures/zone/ParadiseZ_Zone_NonPvP.png"),
    PvP = getTexture("media/textures/zone/ParadiseZ_Zone_PvP.png"),
    Blocked = getTexture("media/textures/zone/ParadiseZ_Zone_Blocked.png"),
    Protected = getTexture("media/textures/zone/ParadiseZ_Zone_Protected.png"),
    Radiation = getTexture("media/textures/zone/ParadiseZ_Zone_Rad.png"),
    Hunt = getTexture("media/textures/zone/ParadiseZ_Zone_Hunt.png"),
    Blaze = getTexture("media/textures/zone/ParadiseZ_Zone_Blaze.png"),
    Frost = getTexture("media/textures/zone/ParadiseZ_Zone_Frost.png"),
    Bomb = getTexture("media/textures/zone/ParadiseZ_Zone_Bomb.png"),
    MineField = getTexture("media/textures/zone/ParadiseZ_Zone_MineField.png"),
    NoCamp = getTexture("media/textures/zone/ParadiseZ_Zone_NoCamp.png"),
    NoFire = getTexture("media/textures/zone/ParadiseZ_Zone_NoFire.png"),
    Cage = getTexture("media/textures/zone/ParadiseZ_Zone_Cage.png"),
    Party = getTexture("media/textures/zone/ParadiseZ_Zone_Party.png"),
    Rally = getTexture("media/textures/zone/ParadiseZ_Zone_Rally.png"),
    Special = getTexture("media/textures/zone/ParadiseZ_Zone_Special.png"),
    Trade = getTexture("media/textures/zone/ParadiseZ_Zone_Trade.png"),
    Sprint = getTexture("media/textures/zone/ParadiseZ_Zone_Sprint.png"),
}


function ParadiseZ.ZoneEditorWindow:getFlagsString(zone)
    local flags = {}
    if zone.isKos then table.insert(flags, "Kos") end
    if zone.isPvE then table.insert(flags, "PvE") end
    if zone.isSafe then table.insert(flags, "Safe") end
    if zone.isBlocked then table.insert(flags, "Blocked") end
    if zone.isRad then table.insert(flags, "Rad") end

    if zone.isHunt then table.insert(flags, "Hunt") end
    if zone.isBlaze then table.insert(flags, "Blaze") end
    if zone.isFrost then table.insert(flags, "Frost") end
    if zone.isBomb then table.insert(flags, "Bomb") end
    if zone.isMine then table.insert(flags, "Mine") end
    if zone.isNoCamp then table.insert(flags, "NoCamp") end
    if zone.isNoFire then table.insert(flags, "NoFire") end
    if zone.isCage then table.insert(flags, "Cage") end
    if zone.isParty then table.insert(flags, "Party") end
    if zone.isRally then table.insert(flags, "Rally") end
    if zone.isSpecial then table.insert(flags, "Special") end
    if zone.isTrade then table.insert(flags, "Trade") end
    if zone.isSprint then table.insert(flags, "Sprint") end
    
    if #flags == 0 then
        return ""
    end
    return table.concat(flags, ", ")
end


function ParadiseZ.ZoneEditorWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    
    local btnWid = 160
    local btnHgt = 32
    local btnSWid = 32
    local btnSHgt = 32
    local entryHgt = FONT_HGT_MEDIUM + 4
    local titleBarHgt = self:titleBarHeight()
    local pl = getPlayer() 
    local contentY = titleBarHgt + MARGIN + 5
    local labelY = MARGIN + 15
    local contentX = 10
    local contentW = self.width - MARGIN * 2
    
    self.totalLabel = ISLabel:new(contentX + 10, labelY, FONT_HGT_SMALL, "Total Zones: 0", 1, 1, 1, 0.8, UIFont.Medium, true)
    self.totalLabel:initialise()
    self.totalLabel:instantiate()
    self:addChild(self.totalLabel)
    
    self.infoLabel = ISLabel:new(contentX + 160, labelY, FONT_HGT_SMALL, "Double-click to edit zones", 1, 1, 1, 0.8, UIFont.Medium, true)
    self.infoLabel:initialise()
    self.infoLabel:instantiate()
    self:addChild(self.infoLabel)
    
    local listY = contentY + FONT_HGT_SMALL + MARGIN + 2
    local bottomHgt = (btnHgt + 4) * 2 + FONT_HGT_LARGE + MARGIN + entryHgt * 2 + MARGIN * 3
    local listH = self.height - listY - bottomHgt - MARGIN
    
    self.datas = ISScrollingListBox:new(contentX, listY, contentW, listH)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = 24
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.anchorRight = true
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true
    self.datas.borderColor = {r = 0.2, g = 0.2, b = 0.5, a = 0.1}
    self.datas.altBgColor = {r = 0.1, g = 0.1, b = 0.7, a = 0.3}
    self.datas.listHeaderColor = {r = 0.0, g = 0.0, b = 0.4, a = 0.1}
    self.datas:addColumn("Name", 4)
    self.datas:addColumn("Point1", 185)
    self.datas:addColumn("Point2", 355)
    self.datas:addColumn("Flags", 510)
    self.datas:setOnMouseDoubleClick(self, ParadiseZ.ZoneEditorWindow.onEditZone)
    self:addChild(self.datas)
    
    local btnY = self.datas:getBottom() + MARGIN
    local btnSpacing = 4
    local btnX = contentX
    
    self.btnPoint1 = ISButton:new(btnX, btnY, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnPoint1.internal = "POINT1"
    self.btnPoint1.tooltip = "POINT1"
    self.btnPoint1:initialise()
    self.btnPoint1:instantiate()
    self.btnPoint1:setImage(Point1_TEX)
    self.btnPoint1.enable = true
    self.btnPoint1.borderColor = {r = 0.5, g = 1, b = 0.5, a = 0.9}
    self:addChild(self.btnPoint1)
    btnX = btnX + btnWid + btnSpacing
    
    self.btnDelete = ISButton:new(btnX, btnY, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnDelete.internal = "DELETE"
    self.btnDelete.tooltip = "DELETE"
    self.btnDelete:initialise()
    self.btnDelete:instantiate()
    self.btnDelete:setImage(delete_TEX_OFF)
    self.btnDelete.enable = false
    self.btnDelete.borderColor = self.buttonBorderColor
    self:addChild(self.btnDelete)
    btnX = btnX + btnWid + btnSpacing
    
    self.btnReset = ISButton:new(btnX, btnY, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnReset.internal = "RESET"
    self.btnReset.tooltip = "RESET"
    self.btnReset:initialise()
    self.btnReset:instantiate()
    self.btnReset:setImage(reset_TEX)
    self.btnReset.enable = true
    self.btnReset.borderColor = self.buttonBorderColor
    self:addChild(self.btnReset)
    btnX = btnX + btnWid + btnSpacing
    
    self.btnRadiation = ISButton:new(btnX, btnY, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnRadiation.internal = "RADIATION"
    self.btnRadiation.tooltip = "RADIATION"
    self.btnRadiation:initialise()
    self.btnRadiation:instantiate()
    self.btnRadiation:setImage(ParadiseZ.flagTextures.Radiation)
    self.btnRadiation.enable = false
    self.btnRadiation.borderColor = self.buttonBorderColor
    self:addChild(self.btnRadiation)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnHunt = ISButton:new(btnX, btnY, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnHunt.internal = "HUNT"
    self.btnHunt.tooltip = "HUNT"
    self.btnHunt:initialise()
    self.btnHunt:instantiate()
    self.btnHunt:setImage(ParadiseZ.flagTextures.Hunt)
    self.btnHunt.enable = false
    self.btnHunt.borderColor = self.buttonBorderColor
    self:addChild(self.btnHunt)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnBlaze = ISButton:new(btnX, btnY, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnBlaze.internal = "BLAZE"
    self.btnBlaze.tooltip = "BLAZE"
    self.btnBlaze:initialise()
    self.btnBlaze:instantiate()
    self.btnBlaze:setImage(ParadiseZ.flagTextures.Blaze)
    self.btnBlaze.enable = false
    self.btnBlaze.borderColor = self.buttonBorderColor
    self:addChild(self.btnBlaze)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnFrost = ISButton:new(btnX, btnY, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnFrost.internal = "FROST"
    self.btnFrost.tooltip = "FROST"
    self.btnFrost:initialise()
    self.btnFrost:instantiate()
    self.btnFrost:setImage(ParadiseZ.flagTextures.Frost)
    self.btnFrost.enable = false
    self.btnFrost.borderColor = self.buttonBorderColor
    self:addChild(self.btnFrost)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnBomb = ISButton:new(btnX, btnY, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnBomb.internal = "BOMB"
    self.btnBomb.tooltip = "BOMB"
    self.btnBomb:initialise()
    self.btnBomb:instantiate()
    self.btnBomb:setImage(ParadiseZ.flagTextures.Bomb)
    self.btnBomb.enable = false
    self.btnBomb.borderColor = self.buttonBorderColor
    self:addChild(self.btnBomb)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnMineField = ISButton:new(btnX, btnY, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnMineField.internal = "MINEFIELD"
    self.btnMineField.tooltip = "MINEFIELD"
    self.btnMineField:initialise()
    self.btnMineField:instantiate()
    self.btnMineField:setImage(ParadiseZ.flagTextures.MineField)
    self.btnMineField.enable = false
    self.btnMineField.borderColor = self.buttonBorderColor
    self:addChild(self.btnMineField)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnPvP = ISButton:new(btnX, btnY, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnPvP.internal = "PVP"
    self.btnPvP.tooltip = "PVP"
    self.btnPvP:initialise()
    self.btnPvP:instantiate()
    self.btnPvP:setImage(ParadiseZ.flagTextures.PvP)
    self.btnPvP.enable = false
    self.btnPvP.borderColor = self.buttonBorderColor
    self:addChild(self.btnPvP)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnNonPvp = ISButton:new(btnX, btnY, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnNonPvp.internal = "NONPVP"
    self.btnNonPvp.tooltip = "NONPVP"
    self.btnNonPvp:initialise()
    self.btnNonPvp:instantiate()
    self.btnNonPvp:setImage(ParadiseZ.flagTextures.NonPvp)
    self.btnNonPvp.enable = false
    self.btnNonPvp.borderColor = self.buttonBorderColor
    self:addChild(self.btnNonPvp)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnProtected = ISButton:new(btnX, btnY, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnProtected.internal = "PROTECTED"
    self.btnProtected.tooltip = "PROTECTED"
    self.btnProtected:initialise()
    self.btnProtected:instantiate()
    self.btnProtected:setImage(ParadiseZ.flagTextures.Protected)
    self.btnProtected.enable = false
    self.btnProtected.borderColor = self.buttonBorderColor
    self:addChild(self.btnProtected)

    local btnY2 = btnY + btnHgt + btnSpacing
    btnX = contentX
    
    self.btnPoint2 = ISButton:new(btnX, btnY2, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnPoint2.internal = "POINT2"
    self.btnPoint2.tooltip = "POINT2"
    self.btnPoint2:initialise()
    self.btnPoint2:instantiate()
    self.btnPoint2:setImage(Point2_TEX)
    self.btnPoint2.enable = true
    self.btnPoint2.borderColor = {r = 0.5, g = 1, b = 0.5, a = 0.9}
    self:addChild(self.btnPoint2)
    btnX = btnX + btnWid + btnSpacing
    
    self.btnTeleport = ISButton:new(btnX, btnY2, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnTeleport.internal = "TP"
    self.btnTeleport.tooltip = "TELEPORT"
    self.btnTeleport:initialise()
    self.btnTeleport:instantiate()
    self.btnTeleport:setImage(TP_TEX_OFF)
    self.btnTeleport.enable = false
    self.btnTeleport.borderColor = self.buttonBorderColor
    self:addChild(self.btnTeleport)
    btnX = btnX + btnWid + btnSpacing
    --**
    self.btnSave = ISButton:new(btnX, btnY2, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnSave.internal = "SAVE"
    self.btnSave.tooltip = "SYNC"
    self.btnSave:initialise()
    self.btnSave:instantiate()
    self.btnSave:setImage(sync_TEX_OFF)
    self.btnSave.enable = true
    self.btnSave.borderColor = {r = 0.3, g = 0.8, b = 0.3, a = 0.8}
    self:addChild(self.btnSave)
    btnX = btnX + btnWid + btnSpacing
    
    self.btnNoCamp = ISButton:new(btnX, btnY2, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnNoCamp.internal = "NOCAMP"
    self.btnNoCamp.tooltip = "NOCAMP"
    self.btnNoCamp:initialise()
    self.btnNoCamp:instantiate()
    self.btnNoCamp:setImage(ParadiseZ.flagTextures.NoCamp)
    self.btnNoCamp.enable = false
    self.btnNoCamp.borderColor = self.buttonBorderColor
    self:addChild(self.btnNoCamp)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnNoFire = ISButton:new(btnX, btnY2, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnNoFire.internal = "NOFIRE"
    self.btnNoFire.tooltip = "NOFIRE"
    self.btnNoFire:initialise()
    self.btnNoFire:instantiate()
    self.btnNoFire:setImage(ParadiseZ.flagTextures.NoFire)
    self.btnNoFire.enable = false
    self.btnNoFire.borderColor = self.buttonBorderColor
    self:addChild(self.btnNoFire)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnCage = ISButton:new(btnX, btnY2, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnCage.internal = "CAGE"
    self.btnCage.tooltip = "CAGE"
    self.btnCage:initialise()
    self.btnCage:instantiate()
    self.btnCage:setImage(ParadiseZ.flagTextures.Cage)
    self.btnCage.enable = false
    self.btnCage.borderColor = self.buttonBorderColor
    self:addChild(self.btnCage)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnParty = ISButton:new(btnX, btnY2, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnParty.internal = "PARTY"
    self.btnParty.tooltip = "PARTY"
    self.btnParty:initialise()
    self.btnParty:instantiate()
    self.btnParty:setImage(ParadiseZ.flagTextures.Party)
    self.btnParty.enable = false
    self.btnParty.borderColor = self.buttonBorderColor
    self:addChild(self.btnParty)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnRally = ISButton:new(btnX, btnY2, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnRally.internal = "RALLY"
    self.btnRally.tooltip = "RALLY"
    self.btnRally:initialise()
    self.btnRally:instantiate()
    self.btnRally:setImage(ParadiseZ.flagTextures.Rally)
    self.btnRally.enable = false
    self.btnRally.borderColor = self.buttonBorderColor
    self:addChild(self.btnRally)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnSpecial = ISButton:new(btnX, btnY2, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnSpecial.internal = "SPECIAL"
    self.btnSpecial.tooltip = "SPECIAL"
    self.btnSpecial:initialise()
    self.btnSpecial:instantiate()
    self.btnSpecial:setImage(ParadiseZ.flagTextures.Special)
    self.btnSpecial.enable = false
    self.btnSpecial.borderColor = self.buttonBorderColor
    self:addChild(self.btnSpecial)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnTrade = ISButton:new(btnX, btnY2, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnTrade.internal = "TRADE"
    self.btnTrade.tooltip = "TRADE"
    self.btnTrade:initialise()
    self.btnTrade:instantiate()
    self.btnTrade:setImage(ParadiseZ.flagTextures.Trade)
    self.btnTrade.enable = false
    self.btnTrade.borderColor = self.buttonBorderColor
    self:addChild(self.btnTrade)
    btnX = btnX + btnSWid + btnSpacing
    
    self.btnSprint = ISButton:new(btnX, btnY2, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnSprint.internal = "SPRINT"
    self.btnSprint.tooltip = "SPRINT"
    self.btnSprint:initialise()
    self.btnSprint:instantiate()
    self.btnSprint:setImage(ParadiseZ.flagTextures.Sprint)
    self.btnSprint.enable = false
    self.btnSprint.borderColor = self.buttonBorderColor
    self:addChild(self.btnSprint)
    

    btnX = btnX + btnSWid + btnSpacing
    
    self.btnBlocked = ISButton:new(btnX, btnY2, btnSWid, btnSHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnBlocked.internal = "BLOCKED"
    self.btnBlocked.tooltip = "BLOCKED"
    self.btnBlocked:initialise()
    self.btnBlocked:instantiate()
    self.btnBlocked:setImage(ParadiseZ.flagTextures.Blocked)
    self.btnBlocked.enable = false
    self.btnBlocked.borderColor = self.buttonBorderColor
    self:addChild(self.btnBlocked)
    

    local filterY = btnY2 + btnHgt + MARGIN - 7
    self.filtersLabel = ISLabel:new(contentX, filterY, FONT_HGT_LARGE, "Filters:", 1, 1, 1, 1, UIFont.Medium, true)
    self.filtersLabel:initialise()
    self.filtersLabel:instantiate()
    self:addChild(self.filtersLabel)
    
    local entryY = filterY + FONT_HGT_LARGE
    local x = contentX
    local size
    for i, column in ipairs(self.datas.columns) do
        if i == #self.datas.columns then
            size = contentW - (x - contentX)
        else
            size = self.datas.columns[i + 1].size - self.datas.columns[i].size
        end
        
        local entry = ISTextEntryBox:new("", x, entryY, size - 5, entryHgt)
        entry.font = UIFont.Medium
        entry:initialise()
        entry:instantiate()
        entry.columnName = column.name
        entry.zoneFilter = self["filter" .. column.name]
        entry.onTextChange = ParadiseZ.ZoneEditorWindow.onFilterChange
        entry.target = self
        entry:setClearButton(true)
        self:addChild(entry)
        table.insert(self.filter, entry)
        self.filterMap[column.name] = entry
        
        x = x + size
    end
    
    local newZoneEntryWid = 125 + 48
    local newZoneEntryWid2 = 125 - 20
    local newZoneEntryHgt = math.max(25, FONT_HGT_SMALL + 6)
    local newZoneRowX = contentX
    local newZoneRowY = self.height - MARGIN - newZoneEntryHgt - 13
    local newZoneSpacing = 6
    local newZonefont = UIFont.Medium
    
    self.newZoneLabel = ISLabel:new(newZoneRowX, newZoneRowY - MARGIN - 10, FONT_HGT_LARGE, "New Zone:", 1, 1, 1, 1, UIFont.Medium, true)
    self.newZoneLabel:initialise()
    self.newZoneLabel:instantiate()
    self:addChild(self.newZoneLabel)
    
    self.newZoneName = ISTextEntryBox:new("", newZoneRowX, newZoneRowY, newZoneEntryWid, newZoneEntryHgt)
    self.newZoneName.font = newZonefont
    self.newZoneName.tooltip = "Zone Name"
    self.newZoneName:initialise()
    self.newZoneName:instantiate()
    self.newZoneName.target = self
    self:addChild(self.newZoneName)
    
    newZoneRowX = newZoneRowX + newZoneEntryWid + newZoneSpacing
    self.newZoneX1 = ISTextEntryBox:new("", newZoneRowX, newZoneRowY, newZoneEntryWid2, newZoneEntryHgt)
    self.newZoneX1.font = newZonefont
    self.newZoneX1.tooltip = "X1"
    self.newZoneX1:initialise()
    self.newZoneX1:instantiate()
    self.newZoneX1.target = self
    self:addChild(self.newZoneX1)
    
    newZoneRowX = newZoneRowX + newZoneEntryWid2 + newZoneSpacing
    self.newZoneY1 = ISTextEntryBox:new("", newZoneRowX, newZoneRowY, newZoneEntryWid2, newZoneEntryHgt)
    self.newZoneY1.font = newZonefont
    self.newZoneY1.tooltip = "Y1"
    self.newZoneY1:initialise()
    self.newZoneY1:instantiate()
    self.newZoneY1.target = self
    self:addChild(self.newZoneY1)
    
    newZoneRowX = newZoneRowX + newZoneEntryWid2 + newZoneSpacing
    self.newZoneX2 = ISTextEntryBox:new("", newZoneRowX, newZoneRowY, newZoneEntryWid2, newZoneEntryHgt)
    self.newZoneX2.font = newZonefont
    self.newZoneX2.tooltip = "X2"
    self.newZoneX2:initialise()
    self.newZoneX2:instantiate()
    self.newZoneX2.target = self
    self:addChild(self.newZoneX2)
    
    newZoneRowX = newZoneRowX + newZoneEntryWid2 + newZoneSpacing
    self.newZoneY2 = ISTextEntryBox:new("", newZoneRowX, newZoneRowY, newZoneEntryWid2, newZoneEntryHgt)
    self.newZoneY2.font = newZonefont
    self.newZoneY2.tooltip = "Y2"
    self.newZoneY2:initialise()
    self.newZoneY2:instantiate()
    self.newZoneY2.target = self
    self:addChild(self.newZoneY2)
    
    newZoneRowX = newZoneRowX + newZoneEntryWid2 + newZoneSpacing
    self.btnAdd = ISButton:new(newZoneRowX, newZoneRowY, 125, newZoneEntryHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnAdd.internal = "ADD"
    self.btnAdd:initialise()
    self.btnAdd:instantiate()
    self.btnAdd:setImage(add_TEX)
    self.btnAdd.borderColor = {r = 0.2, g = 0.6, b = 1, a = 0.8}
    self:addChild(self.btnAdd)
    
    self:initList()
end


function ParadiseZ.ZoneEditorWindow:filterFlags(widget, zone)
    local filterTxt = string.lower(widget:getInternalText())
    if filterTxt == "" then return true end
    
    local flagsStr = string.lower(self:getFlagsString(zone))
    return string.match(flagsStr, filterTxt) ~= nil
end

function ParadiseZ.ZoneEditorWindow:initialise()
    ISCollapsableWindow.initialise(self)
end

function ParadiseZ.ZoneEditorWindow:titleBarHeight()
    return 24
end

function ParadiseZ.ZoneEditorWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    local tStr = "Glytch3r's    ParadiseZ    Zone    Editor"
    if string.lower(getPlayer():getAccessLevel()) ~= "admin" then
        tStr = "Glytch3r's    ParadiseZ    Zone    Directory"
    end
    o.title = tStr
    o.resizable = true
    o.minimumWidth = 900
    o.minimumHeight = 400
    o.listHeaderColor = {r = 0.23, g = 0.83, b = 0.89, a = 0.3}
    o.borderColor = {r = 0.81, g = 0.92, b = 0.84, a = 0.75}
    o.backgroundColor = {r = 0.18, g = 0.02, b = 0.22, a = 0.8}
    o.buttonBorderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.5}
    o.totalResult = 0
    o.shouldSync = false
    o.ZoneData = {}
    o.filter = {}
    o.filterMap = {}
    o.moveWithMouse = true
    o.childEditor = nil
    --o.bgTexture = getTexture("media/ui/paradise/bg.png")
    ParadiseZ.ZoneEditorWindow.instance = o
    o:setResizable(true)
    return o
end
function ParadiseZ.ZoneEditorWindow:prerender()
    ISCollapsableWindow.prerender(self)
    self.bgTexture = bg_TEX
    if self.bgTexture then
        self.bgX = (self.width / 2) - (self.bgTexture:getWidth() / 2)
        self.bgY = 25
        self:drawTexture(self.bgTexture, self.bgX, self.bgY + 20, 1, 1, 1, 1, 0.3)
    end

    if self._lastW ~= self.width or self._lastH ~= self.height then
        self._lastW = self.width
        self._lastH = self.height

        local contentX = 10
        local contentW = self.width - MARGIN * 2
        local titleBarHgt = self:titleBarHeight()
        local contentY = titleBarHgt + MARGIN + 5
        local listY = contentY + FONT_HGT_SMALL + MARGIN + 2
        local btnHgt = 32
        local btnSpacing = 4
        local entryHgt = FONT_HGT_MEDIUM + 4
        local bottomHgt = (btnHgt + 4) * 2 + FONT_HGT_LARGE + MARGIN + entryHgt * 2 + MARGIN * 3
        local listH = self.height - listY - bottomHgt - MARGIN

        self.datas:setWidth(contentW)
        self.datas:setHeight(listH)

        local btnY = self.datas:getBottom() + MARGIN
        local btnY2 = btnY + btnHgt + btnSpacing
        local btnWid = 160
        local btnSWid = 32

        local row1 = {
            self.btnPoint1, self.btnDelete, self.btnReset,
            self.btnRadiation, self.btnHunt, self.btnBlaze, self.btnFrost,
            self.btnBomb, self.btnMineField, self.btnPvP, self.btnNonPvp, self.btnProtected
        }
        local row1Widths = {btnWid, btnWid, btnWid, btnSWid, btnSWid, btnSWid, btnSWid, btnSWid, btnSWid, btnSWid, btnSWid, btnSWid}

        local x = contentX
        for i, btn in ipairs(row1) do
            btn:setY(btnY)
            btn:setX(x)
            x = x + row1Widths[i] + btnSpacing
        end

        local row2 = {
            self.btnPoint2, self.btnTeleport, self.btnSave,
            self.btnNoCamp, self.btnNoFire, self.btnCage, self.btnParty,
            self.btnRally, self.btnSpecial, self.btnTrade, self.btnSprint, self.btnBlocked
        }
        local row2Widths = {btnWid, btnWid, btnWid, btnSWid, btnSWid, btnSWid, btnSWid, btnSWid, btnSWid, btnSWid, btnSWid, btnSWid}

        x = contentX
        for i, btn in ipairs(row2) do
            btn:setY(btnY2)
            btn:setX(x)
            x = x + row2Widths[i] + btnSpacing
        end

        local filterY = btnY2 + btnHgt + MARGIN - 7
        self.filtersLabel:setY(filterY)

        local entryY = filterY + FONT_HGT_LARGE
        x = contentX
        for i, entry in ipairs(self.filter) do
            entry:setY(entryY)
            entry:setX(x)
            local size
            if i == #self.datas.columns then
                size = contentW - (x - contentX)
            else
                size = self.datas.columns[i + 1].size - self.datas.columns[i].size
            end
            entry:setWidth(size - 5)
            x = x + size
        end

        local newZoneEntryHgt = math.max(25, FONT_HGT_SMALL + 6)
        local newZoneRowY = self.height - MARGIN - newZoneEntryHgt - 13
        self.newZoneLabel:setY(newZoneRowY - MARGIN - 10)
        self.newZoneName:setY(newZoneRowY)
        self.newZoneX1:setY(newZoneRowY)
        self.newZoneY1:setY(newZoneRowY)
        self.newZoneX2:setY(newZoneRowY)
        self.newZoneY2:setY(newZoneRowY)
        self.btnAdd:setY(newZoneRowY)
    end
end

function ParadiseZ.ZoneEditorWindow:initList()
    self.totalResult = 0
    self.datas:clear()
    self.datas.fullList = nil
    self.ZoneData = ParadiseZ.snapshot(ParadiseZ.ZoneData) or {}
    
    if not self.ZoneData then return end
    for name, zone in pairs(self.ZoneData) do
        self.datas:addItem(zone.name, zone)
        self.totalResult = self.totalResult + 1
    end
    table.sort(self.datas.items, function(a, b)
        if not a or not b or not a.item or not b.item then return false end
        return a.item.name < b.item.name
    end)
    self.totalLabel:setName("Total Zones: " .. self.totalResult)
end

function ParadiseZ.ZoneEditorWindow:refreshList()
    self.ZoneData = ParadiseZ.snapshot(ParadiseZ.ZoneData) or {}
    local selectedIdx = self.datas.selected
    self.datas.fullList = nil
    self:initList()
    if #self.filter > 0 then
        ParadiseZ.ZoneEditorWindow.onFilterChange(self.filter[1])
    end
    if selectedIdx > #self.datas.items then
        selectedIdx = #self.datas.items
    end
    self.datas.selected = selectedIdx
end

function ParadiseZ.ZoneEditorWindow:onOptionMouseDown(button, x, y)
    local selected = self.datas.items[self.datas.selected]
    local pl = getPlayer()
    local zone = selected and selected.item
    --if not zone then return end
    if string.lower(pl:getAccessLevel()) == "admin" then
        if button.internal == "RESET" then
            self.ZoneData = ParadiseZ.ZoneDataBackup
            ModData.add("ParadiseZ_ZoneData", ParadiseZ.ZoneDataBackup)
            ParadiseZ.saveZoneData(ParadiseZ.ZoneDataBackup)
            self.shouldSync = false
            self:refreshList()
            self.btnReset:setImage(reset_TEX_ON)
            timer:Simple(1, function()
                self.btnReset:setImage(reset_TEX_OFF)
            end)
            timer:Simple(1.2, function()
                self.btnReset:setImage(reset_TEX)
            end)
        end

        if button.internal == "ADD" then
            local name = self.newZoneName:getText()
            if name == "" then
                name = "New Zone"
            end
            
            ParadiseZ.ZoneData[name] = {
                name = name,
                x1 = tonumber(self.newZoneX1:getText()) or round(pl:getX() - 5),
                y1 = tonumber(self.newZoneY1:getText()) or round(pl:getY() - 5),
                x2 = tonumber(self.newZoneX2:getText()) or round(pl:getX() + 5),
                y2 = tonumber(self.newZoneY2:getText()) or round(pl:getY() + 5),
                isKos = false,
                isPvE = false,
                isSafe = false,
                isBlocked = false,
                isRad = false,
                isHunt = false,
                isBlaze = false,
                isFrost = false,
                isBomb = false,
                isMine = false,
                isNoCamp = false,
                isNoFire = false,
                isCage = false,
                isParty = false,
                isRally = false,
                isSpecial = false,
                isTrade = false,
                isSprint = false,
            }
            
            ParadiseZ.saveZoneData(ParadiseZ.ZoneData)
            self.newZoneName:setText("")
            self.newZoneX1:setText("")
            self.newZoneY1:setText("")
            self.newZoneX2:setText("")
            self.newZoneY2:setText("")
            self.shouldSync = false
            self:refreshList()
            print('auto synced')
    

        elseif button.internal == "SAVE" then
            
            print('ParadiseZ.saveZoneData')
            local zones = {}
            for i = 1, #self.datas.items do
                local entry = self.datas.items[i]
                local z = entry.item
                zones[entry.text] = {
                    name = entry.text,
                    x1 = z.x1,
                    y1 = z.y1,
                    x2 = z.x2,
                    y2 = z.y2,
                    isKos = z.isKos,
                    isPvE = z.isPvE,
                    isSafe = z.isSafe,
                    isBlocked = z.isBlocked,
                    isRad = z.isRad or false,
                    isHunt = z.isHunt or false,
                    isBlaze = z.isBlaze or false,
                    isFrost = z.isFrost or false,
                    isBomb = z.isBomb or false,
                    isMine = z.isMine or false,
                    isNoCamp = z.isNoCamp or false,
                    isNoFire = z.isNoFire or false,
                    isCage = z.isCage or false,
                    isParty = z.isParty or false,
                    isRally = z.isRally or false,
                    isSpecial = z.isSpecial or false,
                    isTrade = z.isTrade or false,
                    isSprint = z.isSprint or false,
                }
            end
            ParadiseZ.saveZoneData(zones)
            self:refreshList()
            self.shouldSync = false

        end

        if zone then
            if button.internal == "POINT1" then
                zone.x1 = round(pl:getX())
                zone.y1 = round(pl:getY())
                self.shouldSync = true
            elseif button.internal == "POINT2" then
                zone.x2 = round(pl:getX())
                zone.y2 = round(pl:getY())
                self.shouldSync = true
            elseif button.internal == "PVP" then
                zone.isKos = not zone.isKos
                self.shouldSync = true
            elseif button.internal == "NONPVP" then
                zone.isPvE = not zone.isPvE
                self.shouldSync = true
            elseif button.internal == "PROTECTED" then
                zone.isSafe = not zone.isSafe
                self.shouldSync = true
            elseif button.internal == "BLOCKED" then
                zone.isBlocked = not zone.isBlocked
                self.shouldSync = true
            elseif button.internal == "RADIATION" then
                zone.isRad = not zone.isRad
                self.shouldSync = true
            elseif button.internal == "HUNT" then
                zone.isHunt = not zone.isHunt
                self.shouldSync = true
            elseif button.internal == "BLAZE" then
                zone.isBlaze = not zone.isBlaze
                self.shouldSync = true
            elseif button.internal == "FROST" then
                zone.isFrost = not zone.isFrost
                self.shouldSync = true
            elseif button.internal == "BOMB" then
                zone.isBomb = not zone.isBomb
                self.shouldSync = true
            elseif button.internal == "MINEFIELD" then
                zone.isMine = not zone.isMine
                self.shouldSync = true
            elseif button.internal == "NOCAMP" then
                zone.isNoCamp = not zone.isNoCamp
                self.shouldSync = true
            elseif button.internal == "NOFIRE" then
                zone.isNoFire = not zone.isNoFire
                self.shouldSync = true
            elseif button.internal == "CAGE" then
                zone.isCage = not zone.isCage
                self.shouldSync = true
            elseif button.internal == "PARTY" then
                zone.isParty = not zone.isParty
                self.shouldSync = true
            elseif button.internal == "RALLY" then
                zone.isRally = not zone.isRally
                self.shouldSync = true
            elseif button.internal == "SPECIAL" then
                zone.isSpecial = not zone.isSpecial
                self.shouldSync = true
            elseif button.internal == "TRADE" then
                zone.isTrade = not zone.isTrade
                self.shouldSync = true
            elseif button.internal == "SPRINT" then
                zone.isSprint = not zone.isSprint
                self.shouldSync = true
            elseif button.internal == "TP" then
                local midX = math.floor((zone.x1 + zone.x2) / 2)
                local midY = math.floor((zone.y1 + zone.y2) / 2)
                ParadiseZ.tp(pl, midX, midY, 0)
                self.btnTeleport:setImage(TP_TEX_ON)
                timer:Simple(1, function()
                    self.btnTeleport:setImage(TP_TEX_OFF)
                end)
            elseif button.internal == "DELETE" then
                self.ZoneData[tostring(zone.name)] = nil
                self.shouldSync = true
                self.datas.fullList = nil
                self.datas:clear()
                for name, z in pairs(self.ZoneData) do
                    self.datas:addItem(z.name, z)
                end
                table.sort(self.datas.items, function(a, b)
                    if not a or not b or not a.item or not b.item then return false end
                    return a.item.name < b.item.name
                end)
                self.btnDelete:setImage(delete_TEX_ON)
                timer:Simple(1, function()
                    self.btnDelete:setImage(delete_TEX_OFF)
                end)
            end
        end
        timer:Simple(1.2, function()
            self:update()
        end)
    else
        pl:setHaloNote(tostring('The Panel Buttons are for Admins ONLY'), 150,250,150,900) 
    end
end

function ParadiseZ.ZoneEditorWindow:update()
    ISCollapsableWindow.update(self)
    if ParadiseZ.updated then
        print("ParadiseZ.updated")
        ParadiseZ.updated = nil
        self:refreshList()
    end
    
    local hasSelection = self.datas.selected > 0 and self.datas.selected <= #self.datas.items
    self.btnPoint1.enable = hasSelection
    self.btnPoint2.enable = hasSelection
    self.btnPvP.enable = hasSelection
    self.btnNonPvp.enable = hasSelection
    self.btnProtected.enable = hasSelection
    self.btnBlocked.enable = hasSelection
    self.btnReset.enable = true
    self.btnDelete.enable = hasSelection
    self.btnTeleport.enable = hasSelection
    self.btnSave.enable = true
    self.btnRadiation.enable = hasSelection
    self.btnHunt.enable = hasSelection
    self.btnBlaze.enable = hasSelection
    self.btnFrost.enable = hasSelection
    self.btnBomb.enable = hasSelection
    self.btnMineField.enable = hasSelection
    self.btnNoCamp.enable = hasSelection
    self.btnNoFire.enable = hasSelection
    self.btnCage.enable = hasSelection
    self.btnParty.enable = hasSelection
    self.btnRally.enable = hasSelection
    self.btnSpecial.enable = hasSelection
    self.btnTrade.enable = hasSelection
    self.btnSprint.enable = hasSelection
    
    self.datas.doDrawItem = self.drawDatas
    
    local texturePath = "media/textures/zone/"
    local function getFlagTexture(name, isActive)
        local suffix = isActive and ".png" or "_off.png"
        return getTexture(texturePath .. name .. suffix)
    end
    
    if hasSelection and self.datas.items[self.datas.selected] then
        local zone = self.datas.items[self.datas.selected].item
        if zone then
            self.btnPvP:setImage(getFlagTexture("ParadiseZ_Zone_PvP", zone.isKos))
            self.btnNonPvp:setImage(getFlagTexture("ParadiseZ_Zone_NonPvP", zone.isPvE))
            self.btnProtected:setImage(getFlagTexture("ParadiseZ_Zone_Protected", zone.isSafe))
            self.btnBlocked:setImage(getFlagTexture("ParadiseZ_Zone_Blocked", zone.isBlocked))
            self.btnRadiation:setImage(getFlagTexture("ParadiseZ_Zone_Rad", zone.isRad))
            self.btnHunt:setImage(getFlagTexture("ParadiseZ_Zone_Hunt", zone.isHunt))
            self.btnBlaze:setImage(getFlagTexture("ParadiseZ_Zone_Blaze", zone.isBlaze))
            self.btnFrost:setImage(getFlagTexture("ParadiseZ_Zone_Frost", zone.isFrost))
            self.btnBomb:setImage(getFlagTexture("ParadiseZ_Zone_Bomb", zone.isBomb))
            self.btnMineField:setImage(getFlagTexture("ParadiseZ_Zone_MineField", zone.isMine))
            self.btnNoCamp:setImage(getFlagTexture("ParadiseZ_Zone_NoCamp", zone.isNoCamp))
            self.btnNoFire:setImage(getFlagTexture("ParadiseZ_Zone_NoFire", zone.isNoFire))
            self.btnCage:setImage(getFlagTexture("ParadiseZ_Zone_Cage", zone.isCage))
            self.btnParty:setImage(getFlagTexture("ParadiseZ_Zone_Party", zone.isParty))
            self.btnRally:setImage(getFlagTexture("ParadiseZ_Zone_Rally", zone.isRally))
            self.btnSpecial:setImage(getFlagTexture("ParadiseZ_Zone_Special", zone.isSpecial))
            self.btnTrade:setImage(getFlagTexture("ParadiseZ_Zone_Trade", zone.isTrade))
            self.btnSprint:setImage(getFlagTexture("ParadiseZ_Zone_Sprint", zone.isSprint))


            self.btnDelete:setImage(delete_TEX)
            self.btnTeleport:setImage(TP_TEX)

        end
    else
        self.btnPvP:setImage(getFlagTexture("ParadiseZ_Zone_PvP", false))
        self.btnNonPvp:setImage(getFlagTexture("ParadiseZ_Zone_NonPvP", false))
        self.btnProtected:setImage(getFlagTexture("ParadiseZ_Zone_Protected", false))
        self.btnBlocked:setImage(getFlagTexture("ParadiseZ_Zone_Blocked", false))
        self.btnRadiation:setImage(getFlagTexture("ParadiseZ_Zone_Rad", false))
        self.btnHunt:setImage(getFlagTexture("ParadiseZ_Zone_Hunt", false))
        self.btnBlaze:setImage(getFlagTexture("ParadiseZ_Zone_Blaze", false))
        self.btnFrost:setImage(getFlagTexture("ParadiseZ_Zone_Frost", false))
        self.btnBomb:setImage(getFlagTexture("ParadiseZ_Zone_Bomb", false))
        self.btnMineField:setImage(getFlagTexture("ParadiseZ_Zone_MineField", false))
        self.btnNoCamp:setImage(getFlagTexture("ParadiseZ_Zone_NoCamp", false))
        self.btnNoFire:setImage(getFlagTexture("ParadiseZ_Zone_NoFire", false))
        self.btnCage:setImage(getFlagTexture("ParadiseZ_Zone_Cage", false))
        self.btnParty:setImage(getFlagTexture("ParadiseZ_Zone_Party", false))
        self.btnRally:setImage(getFlagTexture("ParadiseZ_Zone_Rally", false))
        self.btnSpecial:setImage(getFlagTexture("ParadiseZ_Zone_Special", false))
        self.btnTrade:setImage(getFlagTexture("ParadiseZ_Zone_Trade", false))
        self.btnSprint:setImage(getFlagTexture("ParadiseZ_Zone_Sprint", false))
        --**
        
        self.btnDelete:setImage(delete_TEX_OFF)
        self.btnTeleport:setImage(TP_TEX_OFF)

    end
    
    local syncImg = sync_TEX_OFF
    if self.shouldSync then
        syncImg = sync_TEX_ON
    end
    self.btnSave:setImage(syncImg)
    if self.btnSave.blinkImageAlpha ~= self.shouldSync then
        self.btnSave.blinkImageAlpha = self.shouldSync
    end
end
function ParadiseZ.ZoneEditorWindow:filterName(widget, zone)
    local txtToCheck = string.lower(zone.name)
    local filterTxt = string.lower(widget:getInternalText())
    if filterTxt == "" then return true end
    return checkStringPattern(filterTxt) and string.match(txtToCheck, filterTxt)
end

function ParadiseZ.ZoneEditorWindow:filterPoint1(widget, zone)
    local filterTxt = widget:getInternalText()
    if filterTxt == "" then return true end
    local coordStr = zone.x1 .. "," .. zone.y1
    return string.match(coordStr, filterTxt)
end

function ParadiseZ.ZoneEditorWindow:filterPoint2(widget, zone)
    local filterTxt = widget:getInternalText()
    if filterTxt == "" then return true end
    local coordStr = zone.x2 .. "," .. zone.y2
    return string.match(coordStr, filterTxt)
end

function ParadiseZ.ZoneEditorWindow:filterFlags(widget, zone)
    local filterTxt = string.lower(widget:getInternalText())
    if filterTxt == "" then return true end
    
    local flagsStr = string.lower(self:getFlagsString(zone))
    return string.match(flagsStr, filterTxt) ~= nil
end

function ParadiseZ.ZoneEditorWindow:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end
    local a = 0.9
    local zone = item.item
    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15)
    end
    if alt then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.15, 0.3, 0.3, 0.3)
    end
    self:drawRectBorder(0, y, self:getWidth(), self.itemheight, 0.5, 0.3, 0.3, 0.3)
    
    local xoffset = 10
    self:drawText(zone.name, self.columns[1].size + xoffset, y + 4, 1, 1, 1, a, self.font)
    
    local point1Str = zone.x1 .. "," .. zone.y1
    self:drawText(point1Str, self.columns[2].size + xoffset, y + 4, 0.8, 0.8, 0.8, a, self.font)
    
    local point2Str = zone.x2 .. "," .. zone.y2
    self:drawText(point2Str, self.columns[3].size + xoffset, y + 4, 0.8, 0.8, 0.8, a, self.font)
    
    local flagsStr = ParadiseZ.ZoneEditorWindow.getFlagsString(self, zone)
    self:drawText(flagsStr, self.columns[4].size + xoffset, y + 4, 0.7, 0.9, 1, a, self.font)
    
    return y + self.itemheight
end

function ParadiseZ.ZoneEditorWindow.onFilterChange(widget)
    local datas = widget.parent.datas
    if not datas.fullList then
        datas.fullList = {}
        for i, v in ipairs(datas.items) do
            table.insert(datas.fullList, v)
        end
    end
    widget.parent.totalResult = 0
    datas:clear()
    for i, v in ipairs(datas.fullList) do
        if v.item and widget.parent.ZoneData[v.item.name] then
            local add = true
            for j, w in ipairs(widget.parent.filter) do
                if not w.zoneFilter(widget.parent, w, v.item) then
                    add = false
                    break
                end
            end
            if add then
                datas:addItem(v.text, v.item)
                widget.parent.totalResult = widget.parent.totalResult + 1
            end
        end
    end
    widget.parent.totalLabel:setName("Total Zones: " .. widget.parent.totalResult)
end


function ParadiseZ.ZoneEditorWindow:close()
    if self.childEditor then
        if self.childEditor.onCancel then
            self.childEditor:onCancel()
        else
            self.childEditor:close()
        end
        self.childEditor = nil
    end
    self:setVisible(false)
    self:removeFromUIManager()
end
-----------------------            ---------------------------
ParadiseZ.ZoneEditorPopupPanel = ISCollapsableWindow:derive("ZoneEditorPopupPanel")

function ParadiseZ.ZoneEditorPopupPanel:new(x, y, w, h, zone, parent)
    local o = ISCollapsableWindow:new(x, y, w, h)
    setmetatable(o, self)
    self.__index = self
    o.zoneRef = zone
    o.originalName = zone.name
    o.parentWindow = parent
    o.isNew = false
    return o
end

function ParadiseZ.ZoneEditorPopupPanel:createChildren()
    ISCollapsableWindow.createChildren(self)
    local y = self:titleBarHeight() + 20
    local x = 20
    local w = self.width - 40
    local h = 28
    
    self.entryName = ISTextEntryBox:new(self.zoneRef.name or "", x, y, w, h)
    self.entryName:initialise()
    self.entryName:instantiate()
    self:addChild(self.entryName)
    y = y + h + 10
    
    local cw = math.floor((w - 30) / 4)
    self.entryX1 = ISTextEntryBox:new(tostring(self.zoneRef.x1 or 0), x, y, cw, h)
    self.entryX1.tooltip = "X1"
    self.entryX1:initialise()
    self.entryX1:instantiate()
    self:addChild(self.entryX1)
    
    self.entryY1 = ISTextEntryBox:new(tostring(self.zoneRef.y1 or 0), x + cw + 10, y, cw, h)
    self.entryY1.tooltip = "Y1"
    self.entryY1:initialise()
    self.entryY1:instantiate()
    self:addChild(self.entryY1)
    
    self.entryX2 = ISTextEntryBox:new(tostring(self.zoneRef.x2 or 0), x + (cw + 10) * 2, y, cw, h)
    self.entryX2.tooltip = "X2"
    self.entryX2:initialise()
    self.entryX2:instantiate()
    self:addChild(self.entryX2)
    
    self.entryY2 = ISTextEntryBox:new(tostring(self.zoneRef.y2 or 0), x + (cw + 10) * 3, y, cw, h)
    self.entryY2.tooltip = "Y2"
    self.entryY2:initialise()
    self.entryY2:instantiate()
    self:addChild(self.entryY2)
    y = y + h + 20
    
    local bw = math.floor((w - 30) / 4)
    self.comboKos = ISComboBox:new(x, y, bw, h)
    self.comboKos:initialise()
    self.comboKos:instantiate()
    self.comboKos:addOption("false")
    self.comboKos:addOption("true")
    self.comboKos.selected = (self.zoneRef.isKos and 2 or 1)
    self:addChild(self.comboKos)
    
    self.comboPvE = ISComboBox:new(x + bw + 10, y, bw, h)
    self.comboPvE:initialise()
    self.comboPvE:instantiate()
    self.comboPvE:addOption("false")
    self.comboPvE:addOption("true")
    self.comboPvE.selected = (self.zoneRef.isPvE and 2 or 1)
    self:addChild(self.comboPvE)
    
    self.comboSafe = ISComboBox:new(x + (bw + 10) * 2, y, bw, h)
    self.comboSafe:initialise()
    self.comboSafe:instantiate()
    self.comboSafe:addOption("false")
    self.comboSafe:addOption("true")
    self.comboSafe.selected = (self.zoneRef.isSafe and 2 or 1)
    self:addChild(self.comboSafe)
    
    self.comboBlocked = ISComboBox:new(x + (bw + 10) * 3, y, bw, h)
    self.comboBlocked:initialise()
    self.comboBlocked:instantiate()
    self.comboBlocked:addOption("false")
    self.comboBlocked:addOption("true")
    self.comboBlocked.selected = (self.zoneRef.isBlocked and 2 or 1)
    self:addChild(self.comboBlocked)
    y = y + h + 30
    
    self.btnOK = ISButton:new(x, y, 120, 30, "Save", self, ParadiseZ.ZoneEditorPopupPanel.onOK)
    self.btnOK:initialise()
    self.btnOK:instantiate()
    self:addChild(self.btnOK)
    
    self.btnCancel = ISButton:new(x + 130, y, 120, 30, "Cancel", self, ParadiseZ.ZoneEditorPopupPanel.onCancel)
    self.btnCancel:initialise()
    self.btnCancel:instantiate()
    self:addChild(self.btnCancel)
end

function ParadiseZ.ZoneEditorPopupPanel:onOK(button)
    local name = self.entryName:getText():match("^%s*(.-)%s*$")
    local x1 = tonumber(self.entryX1:getText())
    local y1 = tonumber(self.entryY1:getText())
    local x2 = tonumber(self.entryX2:getText())
    local y2 = tonumber(self.entryY2:getText())
    if not name or name == "" then return end
    if not (x1 and y1 and x2 and y2) then return end
    
    local zone = self.zoneRef
    local orig = self.originalName or zone.name
    zone.name = name
    zone.x1 = x1
    zone.y1 = y1
    zone.x2 = x2
    zone.y2 = y2
    zone.isKos = (self.comboKos.options[self.comboKos.selected] == "true")
    zone.isPvE = (self.comboPvE.options[self.comboPvE.selected] == "true")
    zone.isSafe = (self.comboSafe.options[self.comboSafe.selected] == "true")
    zone.isBlocked = (self.comboBlocked.options[self.comboBlocked.selected] == "true")
    
    if orig and orig ~= name then
        ParadiseZ.ZoneData = ParadiseZ.snapshot(ParadiseZ.ZoneData) or {}
        ParadiseZ.ZoneData[name] = zone
        ParadiseZ.ZoneData[orig] = nil
    end
    
    if self.parentWindow and self.parentWindow.refreshList then
        self.parentWindow:refreshList()
    end
    self:close()
end

function ParadiseZ.ZoneEditorPopupPanel:onCancel(button)
    self:close()
end

function ParadiseZ.ZoneEditorWindow:onEditZone(item)
    if string.lower(getPlayer():getAccessLevel()) == "admin" then
        if not self.childEditor then
            local zone = (item and item.item) and item.item or item
            if not zone then return end
            local w = 650
            local h = 258
            local x = (getCore():getScreenWidth() - w) / 2 + 330
            local y = (getCore():getScreenHeight() - h) / 2 - 60
            ParadiseZ.PopupPanel = ParadiseZ.ZoneEditorPopupPanel:new(x, y, w, h, zone, self)
            ParadiseZ.PopupPanel.isNew = false
            ParadiseZ.PopupPanel:initialise()
            ParadiseZ.PopupPanel:addToUIManager()
            self.childEditor = ParadiseZ.PopupPanel
        end
    end
end

function ParadiseZ.ZoneEditorPopupPanel:close()
    if self.parentWindow and self.parentWindow.childEditor == self then
        self.parentWindow.childEditor = nil
    end
    self:setVisible(false)
    self:removeFromUIManager()
    self.childEditor = nil
end

function ParadiseZ.editor(activate)
    if ParadiseZ.ZoneEditorWindow.instance then
        ParadiseZ.ZoneEditorWindow.instance:close()
        ParadiseZ.ZoneEditorWindow.instance = nil
    end
    if activate then
        local width = 970--1200
        local height = 400--568
        local x = (getCore():getScreenWidth() - width) / 2 + 150
        local y = (getCore():getScreenHeight() - height) / 2
        local editor = ParadiseZ.ZoneEditorWindow:new(x, y, width, height)
        editor:initialise()
        editor:addToUIManager()
    end
end




function ParadiseZ.editor(activate)
    if ParadiseZ.ZoneEditorWindow.instance then
        ParadiseZ.ZoneEditorWindow.instance:close()
        ParadiseZ.ZoneEditorWindow.instance = nil
    end
    if activate then
        local width = 1200
        local height = 568
        local x = (getCore():getScreenWidth() - width) / 2 - 300
        local y = (getCore():getScreenHeight() - height) / 2
        local editor = ParadiseZ.ZoneEditorWindow:new(x, y, width, height)
        editor:initialise()
        editor:addToUIManager()
    end
end