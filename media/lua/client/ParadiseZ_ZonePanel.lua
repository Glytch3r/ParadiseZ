--client/ParadiseZ_ZonePanel.lua
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

local Blocked_TEX_OFF = getTexture("media/ui/Paradise/Blocked_off.png")
local Blocked_TEX_ON = getTexture("media/ui/Paradise/Blocked.png")
local isKos_TEX_OFF = getTexture("media/ui/Paradise/isKos_off.png")
local isKos_TEX_ON = getTexture("media/ui/Paradise/isKos.png")
local isPvE_TEX_OFF = getTexture("media/ui/Paradise/isPvE_off.png")
local isPvE_TEX_ON = getTexture("media/ui/Paradise/isPvE.png")
local isSafe_TEX_OFF = getTexture("media/ui/Paradise/isSafe_off.png")
local isSafe_TEX_ON = getTexture("media/ui/Paradise/isSafe.png")

local TP_TEX_ON = getTexture("media/ui/Paradise/TP.png")
local TP_TEX_OFF = getTexture("media/ui/Paradise/TP_off.png")
local delete_TEX_ON = getTexture("media/ui/Paradise/delete.png")
local delete_TEX_OFF = getTexture("media/ui/Paradise/delete_off.png")


local Point1_TEX = getTexture("media/ui/Paradise/Point1.png")
local Point2_TEX = getTexture("media/ui/Paradise/Point2.png")


local sync_TEX_ON  = getTexture("media/ui/Paradise/sync_on.png")
local sync_TEX_OFF = getTexture("media/ui/Paradise/sync.png")

local reset_TEX_ON = getTexture("media/ui/Paradise/reset_on.png")
local reset_TEX_OFF = getTexture("media/ui/Paradise/reset_off.png")

local add_TEX = getTexture("media/ui/Paradise/add.png")
local bg_TEX = getTexture("media/ui/Paradise/bg.png")




function ParadiseZ.ZoneEditorWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local btnWid = 125
    local btnHgt = math.max(25, FONT_HGT_SMALL + 6)
    local entryHgt = FONT_HGT_MEDIUM + 4
    local titleBarHgt = self:titleBarHeight()
    local pl = getPlayer() 
    local contentY = titleBarHgt + MARGIN + 5
    local labelY = MARGIN + 15
    local contentX = 10
    local contentW = self.width - MARGIN * 2
    self.totalLabel = ISLabel:new(contentX +10, labelY, FONT_HGT_SMALL, "Total Zones: 0", 1, 1, 1, 0.8, UIFont.Medium, true)
    self.totalLabel:initialise()
    self.totalLabel:instantiate()
    self:addChild(self.totalLabel)

    self.infoLabel = ISLabel:new(contentX+ 160, labelY, FONT_HGT_SMALL, "Double-click to edit zones", 1, 1, 1, 0.8, UIFont.Medium, true)
    self.infoLabel:initialise()
    self.infoLabel:instantiate()
    self:addChild(self.infoLabel)

    local listY = contentY + FONT_HGT_SMALL + MARGIN +2
    local bottomHgt = (btnHgt + MARGIN) * 2 + FONT_HGT_LARGE + MARGIN + entryHgt * 2 + MARGIN * 3
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
    self.datas.listHeaderColor = {r=0.0, g=0.0, b=0.4, a=0.1}

    self.datas:addColumn("Name", 4)
    self.datas:addColumn("Point1", 185)
    self.datas:addColumn("Point2", 355)
    self.datas:addColumn("isKos", 510)
    self.datas:addColumn("isPvE", 605)
    self.datas:addColumn("isSafe", 695)
    self.datas:addColumn("isBlocked", 790)
    self.datas:setOnMouseDoubleClick(self, ParadiseZ.ZoneEditorWindow.onEditZone)
    self:addChild(self.datas)

    local btnY = self.datas:getBottom() + MARGIN

    self.btnPoint1 = ISButton:new(contentX, btnY, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnPoint1.internal = "POINT1"
    self.btnPoint1:initialise()
    self.btnPoint1:instantiate()
    self.btnPoint1:setImage(Point1_TEX)
    self.btnPoint1.enable = true
    self.btnPoint1.borderColor = {r = 0.5, g = 1, b = 0.5, a = 0.9}
    self:addChild(self.btnPoint1)

    self.btnToggleKos = ISButton:new(self.btnPoint1:getRight() + MARGIN, btnY, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnToggleKos.internal = "TOGGLE_KOS"
    self.btnToggleKos:initialise()
    self.btnToggleKos:instantiate()
    self.btnToggleKos:setImage(isKos_TEX_OFF)
    self.btnToggleKos.enable = false
    self.btnToggleKos.borderColor = self.buttonBorderColor
    self:addChild(self.btnToggleKos)

    self.btnToggleSafe = ISButton:new(self.btnToggleKos:getRight() + MARGIN, btnY, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnToggleSafe.internal = "TOGGLE_SAFE"
    self.btnToggleSafe:initialise()
    self.btnToggleSafe:instantiate()
    self.btnToggleKos:setImage(isSafe_TEX_OFF)
    self.btnToggleSafe.enable = false
    self.btnToggleSafe.borderColor = self.buttonBorderColor
    self:addChild(self.btnToggleSafe)

    self.btnDelete = ISButton:new(self.btnToggleSafe:getRight() + MARGIN, btnY, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnDelete.internal = "DELETE"
    self.btnDelete:initialise()
    self.btnDelete:instantiate()
    self.btnDelete:setImage(delete_TEX_OFF)
    self.btnDelete.enable = false
    self.btnDelete.borderColor = self.buttonBorderColor
    self:addChild(self.btnDelete)

    self.btnReset = ISButton:new(self.btnDelete:getRight() + MARGIN-2, btnY, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnReset.internal = "RESET"
    self.btnReset:initialise()
    self.btnReset:instantiate()
    self.btnReset:setImage(reset_TEX_ON)
    self.btnReset.enable = false
    self.btnReset.borderColor = self.buttonBorderColor
    self:addChild(self.btnReset)

    local btnY2 = btnY + btnHgt + MARGIN

    self.btnPoint2 = ISButton:new(contentX, btnY2, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnPoint2.internal = "POINT2"
    self.btnPoint2:initialise()
    self.btnPoint2:instantiate()
    self.btnPoint2:setImage(Point2_TEX)
    self.btnPoint2.enable = true
    self.btnPoint2.borderColor =  {r = 0.5, g = 1, b = 0.5, a = 0.9}
    self:addChild(self.btnPoint2)
    
    self.btnTogglePvE = ISButton:new(self.btnPoint2:getRight() + MARGIN, btnY2, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnTogglePvE.internal = "TOGGLE_PVE"
    self.btnTogglePvE:initialise()
    self.btnTogglePvE:instantiate()
    self.btnTogglePvE:setImage(isPvE_TEX_OFF)
    self.btnTogglePvE.enable = false
    self.btnTogglePvE.borderColor = self.buttonBorderColor
    self:addChild(self.btnTogglePvE)

    self.btnToggleBlocked = ISButton:new(self.btnTogglePvE:getRight() + MARGIN, btnY2, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnToggleBlocked.internal = "TOGGLE_BLOCKED"
    self.btnToggleBlocked:initialise()
    self.btnToggleBlocked:instantiate()
    self.btnToggleBlocked:setImage(Blocked_TEX_OFF)
    self.btnToggleBlocked.enable = false
    self.btnToggleBlocked.borderColor = self.buttonBorderColor
    self:addChild(self.btnToggleBlocked)

    self.btnTp = ISButton:new(self.btnToggleBlocked:getRight() + MARGIN, btnY2, btnWid, btnHgt, "", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnTp.internal = "TP"
    self.btnTp:initialise()
    self.btnTp:instantiate()
    self.btnTp:setImage(TP_TEX_OFF)
    self.btnTp.enable = false
    self.btnTp.borderColor = self.buttonBorderColor
    self:addChild(self.btnTp)

    local filterY = btnY2 + btnHgt + MARGIN -7

    self.filtersLabel = ISLabel:new(contentX, filterY, FONT_HGT_LARGE, "Filters:", 1, 1, 1, 1, UIFont.Medium, true)
    self.filtersLabel:initialise()
    self.filtersLabel:instantiate()
    self:addChild(self.filtersLabel)



    local entryY = filterY + FONT_HGT_LARGE 
    local x = contentX
    local newZoneEntryWid
    for i, column in ipairs(self.datas.columns) do
        if i == #self.datas.columns then
            size = contentW - (x - contentX)
        else
            size = self.datas.columns[i + 1].size - self.datas.columns[i].size
        end

        if column.name == "isKos" or column.name == "isPvE" or column.name == "isSafe" or column.name == "isBlocked" then
            local combo = ISComboBox:new(x, entryY, size, entryHgt)
            combo.font = UIFont.Medium
            combo:initialise()
            combo:instantiate()
            combo.columnName = column.name
            combo.target = combo
            combo.onChange = self.onFilterChange
            combo.zoneFilter = self["filter" .. column.name]
            combo:addOption("<Any>")
            combo:addOption("true")
            combo:addOption("false")
            self:addChild(combo)
            table.insert(self.filter, combo)
            self.filterMap[column.name] = combo
        else
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
        end
        x = x + size
    end

    local newZoneEntryWid = btnWid + 48
    local newZoneEntryWid2 = btnWid - 20
    local newZoneEntryHgt = math.max(25, FONT_HGT_SMALL + 6)
    local newZoneRowX = contentX
    local newZoneRowY = self.height - MARGIN - newZoneEntryHgt - 13
    local newZoneSpacing = 6
    local newZonefont = UIFont.Medium

    self.newZoneLabel = ISLabel:new(newZoneRowX, newZoneRowY - MARGIN-10, FONT_HGT_LARGE, "New Zone:", 1, 1, 1, 1, UIFont.Medium, true)
    self.newZoneLabel:initialise()
    self.newZoneLabel:instantiate()
    self:addChild(self.newZoneLabel)

    self.newZoneName = ISTextEntryBox:new("", newZoneRowX, newZoneRowY, newZoneEntryWid, newZoneEntryHgt)
    self.newZoneName.font =  newZonefont
    self.newZoneName.tooltip =  "Zone Name"
    self.newZoneName:initialise()
    self.newZoneName:instantiate()
    self.newZoneName.target = self
    self:addChild(self.newZoneName)
    
    newZoneRowX = newZoneRowX + newZoneEntryWid + newZoneSpacing
    self.newZoneX1 = ISTextEntryBox:new("", newZoneRowX, newZoneRowY, newZoneEntryWid2, newZoneEntryHgt)
    self.newZoneX1.font = newZonefont
    self.newZoneX1.tooltip =  "X1"
    self.newZoneX1:initialise()
    self.newZoneX1:instantiate()
    self.newZoneX1.target = self
    self:addChild(self.newZoneX1)
    
    newZoneRowX = newZoneRowX + newZoneEntryWid2 + newZoneSpacing
    self.newZoneY1 = ISTextEntryBox:new("", newZoneRowX, newZoneRowY, newZoneEntryWid2, newZoneEntryHgt)
    self.newZoneY1.font = newZonefont
    self.newZoneY1.tooltip =  "Y1"
    self.newZoneY1:initialise()
    self.newZoneY1:instantiate()
    self.newZoneY1.target = self
    self:addChild(self.newZoneY1)

    newZoneRowX = newZoneRowX + newZoneEntryWid2 + newZoneSpacing
    self.newZoneX2 = ISTextEntryBox:new("", newZoneRowX, newZoneRowY, newZoneEntryWid2, newZoneEntryHgt)
    self.newZoneX2.font = newZonefont
    self.newZoneX2.tooltip =  "X2"
    self.newZoneX2:initialise()
    self.newZoneX2:instantiate()
    self.newZoneX2.target = self
    self:addChild(self.newZoneX2)

    newZoneRowX = newZoneRowX + newZoneEntryWid2 + newZoneSpacing
    self.newZoneY2 = ISTextEntryBox:new("", newZoneRowX, newZoneRowY, newZoneEntryWid2, newZoneEntryHgt)
    self.newZoneY2.font = newZonefont
    self.newZoneY2.tooltip =  "Y2"
    self.newZoneY2:initialise()
    self.newZoneY2:instantiate()
    self.newZoneY2.target = self
    self:addChild(self.newZoneY2)

    --add*d
    newZoneRowX = newZoneRowX + newZoneEntryWid2 + newZoneSpacing
    self.btnAdd = ISButton:new(newZoneRowX, newZoneRowY, btnWid, btnHgt, "", self, function()
      --  local tempZone = ParadiseZ.snapshot(ParadiseZ.ZoneData) or {}
        
        local name =  self.newZoneName:getText()
        if name == "" then
            name = "New Zone"
        end
        
        ParadiseZ.ZoneData[name] = {
            name = name,
            x1 = tonumber(self.newZoneX1:getText()) or round(pl:getX()-5),
            y1 = tonumber(self.newZoneY1:getText()) or round(pl:getY()-5),
            x2 = tonumber(self.newZoneX2:getText()) or round(pl:getX()+5),
            y2 = tonumber(self.newZoneY2:getText()) or round(pl:getY()+5),
            isKos = false,
            isPvE = false,
            isSafe = false,
            isBlocked = false,
            isRad = false,
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
    end)
    self.btnAdd.internal = "ADD"
    self.btnAdd:initialise()
    self.btnAdd:instantiate()
    self.btnAdd:setImage(add_TEX)
    self.btnAdd.enable = true
    self.btnAdd.borderColor = {r = 0.2, g = 0.6, b = 1, a = 0.8}
    self:addChild(self.btnAdd)

    newZoneRowX = newZoneRowX + newZoneEntryWid2 + newZoneSpacing
    --save*
    self.btnSave = ISButton:new(self.btnDelete:getRight() + MARGIN - 2, btnY2, btnWid, btnHgt, "", self, function()
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
                isRad = false,
            }
        end
        ParadiseZ.saveZoneData(zones)
        self:refreshList()
        self.shouldSync = false
    end)

    self.btnSave.internal = "SAVE"
    self.btnSave:initialise()
    self.btnSave:instantiate()
    self.btnSave:setImage(sync_TEX_OFF)
    self.btnSave.enable = true
    self.btnSave.borderColor = {r = 0.3, g = 0.8, b = 0.3, a = 0.8}
    self:addChild(self.btnSave)

    self:initList()
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
    o.title = "Glytch3r's    ParadiseZ    Zone    Editor"
    o.resizable = true
    o.minimumWidth = 650
    o.minimumHeight = 400
    o.listHeaderColor = { r = 0.23, g = 0.83, b = 0.89, a = 0.3}
    o.borderColor =     { r = 0.81, g = 0.92, b = 0.84, a = 0.75}
    o.backgroundColor = { r = 0.18, g = 0.02, b = 0.22 , a = 0.8}
    o.buttonBorderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.5}
    o.totalResult = 0
    o.shouldSync = false
    o.ZoneData = {}
    o.filter = {}
    o.filterMap = {}
    o.moveWithMouse = true
    o.childEditor = nil
    o.bgTexture  = getTexture("media/ui/paradise/bg.png")
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
        self:drawTexture(self.bgTexture, self.bgX, self.bgY+20, 1, 1, 1, 1, 0.3)
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

    if not zone then return end
    if button.internal == "POINT1" then
        zone.x1 = round(pl:getX())
        zone.y1 = round(pl:getY())
        self.shouldSync = true
    elseif button.internal == "POINT2" then
        zone.x2 = round(pl:getX())
        zone.y2 = round(pl:getY())
        self.shouldSync = true
    elseif button.internal == "TOGGLE_KOS" then
        zone.isKos = not zone.isKos
        self.shouldSync = true
    elseif button.internal == "TOGGLE_PVE" then
        zone.isPvE = not zone.isPvE
        self.shouldSync = true
    elseif button.internal == "TOGGLE_SAFE" then
        zone.isSafe = not zone.isSafe
        self.shouldSync = true
    elseif button.internal == "TOGGLE_BLOCKED" then
        zone.isBlocked = not zone.isBlocked
        self.shouldSync = true
    elseif button.internal == "TP" then
        local midX = math.floor((zone.x1 + zone.x2) / 2)
        local midY = math.floor((zone.y1 + zone.y2) / 2)
        ParadiseZ.tp(pl, midX, midY, 0)
        self.btnTp:setImage(TP_TEX_ON)
        timer:Simple(1, function() 
            self.btnTp:setImage(TP_TEX_OFF)
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
    elseif button.internal == "RESET" then
 
        self.ZoneData = ParadiseZ.ZoneDataBackup 

        ModData.add("ParadiseZ_ZoneData", ParadiseZ.ZoneDataBackup)
     
        ParadiseZ.saveZoneData(ParadiseZ.ZoneDataBackup)
        self.shouldSync = false
        self:refreshList()
--[[ 
        self.ZoneData = ParadiseZ.ZoneDataBackup
        self:refreshTemporaryList()
 ]]
        self.btnReset:setImage(reset_TEX_ON)
        timer:Simple(1, function() 
            self.btnReset:setImage(reset_TEX_OFF)
        end)

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
    self.btnToggleKos.enable = hasSelection
    self.btnTogglePvE.enable = hasSelection
    self.btnToggleSafe.enable = hasSelection
    self.btnToggleBlocked.enable = hasSelection
    self.btnReset.enable = hasSelection
    self.btnDelete.enable = hasSelection
    self.btnTp.enable = hasSelection
    self.btnSave.enable = true

    self.datas.doDrawItem = self.drawDatas

    if hasSelection and self.datas.items[self.datas.selected] then
        local zone = self.datas.items[self.datas.selected].item
        if zone then
            self.btnToggleKos:setImage(zone.isKos and isKos_TEX_ON or isKos_TEX_OFF)
            self.btnTogglePvE:setImage(zone.isPvE and isPvE_TEX_ON or isPvE_TEX_OFF)
            self.btnToggleSafe:setImage(zone.isSafe and isSafe_TEX_ON or isSafe_TEX_OFF)
            self.btnToggleBlocked:setImage(zone.isBlocked and Blocked_TEX_ON or Blocked_TEX_OFF)
        end
    
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

function ParadiseZ.ZoneEditorWindow:filterisKos(widget, zone)
    if widget.selected == 1 then return true end
    return tostring(zone.isKos) == widget:getOptionText(widget.selected)
end

function ParadiseZ.ZoneEditorWindow:filterisPvE(widget, zone)
    if widget.selected == 1 then return true end
    return tostring(zone.isPvE) == widget:getOptionText(widget.selected)
end

function ParadiseZ.ZoneEditorWindow:filterisSafe(widget, zone)
    if widget.selected == 1 then return true end
    return tostring(zone.isSafe) == widget:getOptionText(widget.selected)
end

function ParadiseZ.ZoneEditorWindow:filterisBlocked(widget, zone)
    if widget.selected == 1 then return true end
    return tostring(zone.isBlocked) == widget:getOptionText(widget.selected)
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

    local kosColor = zone.isKos and {1, 0.2, 0.1} or {0.3, 1, 0.3}
    self:drawText(tostring(zone.isKos), self.columns[4].size + xoffset, y + 4, kosColor[1], kosColor[2], kosColor[3], a, self.font)

    local pveColor = zone.isPvE and {0.3, 1, 0.3} or {0.8, 0.8, 0.4}
    self:drawText(tostring(zone.isPvE), self.columns[5].size + xoffset, y + 4, pveColor[1], pveColor[2], pveColor[3], a, self.font)

    local safeColor = zone.isSafe and {0.3, 0.8, 1} or {0.8, 0.8, 0.8}
    self:drawText(tostring(zone.isSafe), self.columns[6].size + xoffset, y + 4, safeColor[1], safeColor[2], safeColor[3], a, self.font)

    local blockedColor = zone.isBlocked and {1, 0.5, 0} or {0.8, 0.8, 0.8}
    self:drawText(tostring(zone.isBlocked), self.columns[7].size + xoffset, y + 4, blockedColor[1], blockedColor[2], blockedColor[3], a, self.font)

    return y + self.itemheight
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
    self.entryX1.tooltip =  "X1"
    self.entryX1:initialise()
    self.entryX1:instantiate()
    self:addChild(self.entryX1)

    self.entryY1 = ISTextEntryBox:new(tostring(self.zoneRef.y1 or 0), x + cw + 10, y, cw, h)
    self.entryY1.tooltip =  "Y1"
    self.entryY1:initialise()
    self.entryY1:instantiate()
    self:addChild(self.entryY1)
    
    self.entryX2 = ISTextEntryBox:new(tostring(self.zoneRef.x2 or 0), x + (cw + 10) * 2, y, cw, h)
    self.entryX2.tooltip =  "X2"
    self.entryX2:initialise()
    self.entryX2:instantiate()
    self:addChild(self.entryX2)

    self.entryY2 = ISTextEntryBox:new(tostring(self.zoneRef.y2 or 0), x + (cw + 10) * 3, y, cw, h)
    self.entryY2.tooltip =  "Y2"
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
        local width = 914 --1244 --800 
        local height = 568 --620
        local x = (getCore():getScreenWidth() - width) / 2 -622
        local y = (getCore():getScreenHeight() - height) / 2
        local editor = ParadiseZ.ZoneEditorWindow:new(x, y, width, height)
        editor:initialise()
        editor:addToUIManager()
    end
end