require "ISUI/ISPanel" 
require "ISUI/ISButton"
require "ISUI/ISScrollingListBox"
require "ISUI/ISCollapsableWindow"
require "ISUI/ISTextEntryBox"
require "ISUI/ISTickBox"

ParadiseZ = ParadiseZ or {}

ZoneEditorPanel = ISCollapsableWindow:derive("ZoneEditorPanel")
ZoneEditorPanel.instance = nil

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function ZoneEditorPanel:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o:setResizable(false)
    o.moveWithMouse = true
    o.title = "Zone Editor Panel"
    o.zones = {}
    return o
end

function ZoneEditorPanel:initialise()
    ISCollapsableWindow.initialise(self)

    local btnWidth, btnHeight, margin = 70, 25, 10
    local listY, listHeight = 70, self.height - 280
    local labelY = listY - FONT_HGT_SMALL - 10
    local nameX, coordsX, kosX, pveX, safeX, blockedX = 20, 180, 360, 420, 480, 540

    self.labelName = ISLabel:new(nameX + 35, labelY, FONT_HGT_SMALL, "Zone Name", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelName)
    self.labelCoords = ISLabel:new(coordsX + 20, labelY, FONT_HGT_SMALL, "Coordinates", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelCoords)
    self.labelKos = ISLabel:new(kosX, labelY, FONT_HGT_SMALL, "KOS", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelKos)
    self.labelPve = ISLabel:new(pveX, labelY, FONT_HGT_SMALL, "PvE", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelPve)
    self.labelSafe = ISLabel:new(safeX, labelY, FONT_HGT_SMALL, "Safe", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelSafe)
    self.labelBlocked = ISLabel:new(blockedX, labelY, FONT_HGT_SMALL, "Block", 1, 1, 1, 1, UIFont.Medium)
    self:addChild(self.labelBlocked)

    self.scrollPanel = ISScrollingListBox:new(margin, listY, self.width - margin * 2, listHeight)
    self.scrollPanel:initialise()
    self.scrollPanel.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0}
    self.scrollPanel.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    self.scrollPanel.drawBorder = true
    self.scrollPanel.itemheight = 25
    self.scrollPanel.doDrawItem = function(panel, y, item, alt)
        local rectY, rectH = y + 1, panel.itemheight - 2
        if panel.selected == item.index then
            panel:drawRect(0, rectY, panel.width, rectH, 0.4, 0.8, 0.4, 0.8)
        else
            panel:drawRect(0, rectY, panel.width, rectH, 0.2, 0.2, 0.2, 0.25)
        end
        local textY = y + (panel.itemheight - FONT_HGT_SMALL) / 2
        panel:drawText(item.item.name or "", nameX, textY, 1, 1, 1, 1, UIFont.Small)
        panel:drawText(item.item.coords or "", coordsX, textY, 1, 1, 1, 1, UIFont.Small)
        local kosColor = item.item.isKos and {1, 0.2, 0.2} or {0.5, 0.5, 0.5}
        panel:drawText(item.item.isKos and "YES" or "NO", kosX, textY, kosColor[1], kosColor[2], kosColor[3], 1, UIFont.Small)
        local pveColor = item.item.isPvE and {0.2, 0.8, 0.2} or {0.5, 0.5, 0.5}
        panel:drawText(item.item.isPvE and "YES" or "NO", pveX, textY, pveColor[1], pveColor[2], pveColor[3], 1, UIFont.Small)
        local safeColor = item.item.isSafe and {0.2, 0.6, 1} or {0.5, 0.5, 0.5}
        panel:drawText(item.item.isSafe and "YES" or "NO", safeX, textY, safeColor[1], safeColor[2], safeColor[3], 1, UIFont.Small)
        local blockedColor = item.item.isBlocked and {1, 0.5, 0} or {0.5, 0.5, 0.5}
        panel:drawText(item.item.isBlocked and "YES" or "NO", blockedX, textY, blockedColor[1], blockedColor[2], blockedColor[3], 1, UIFont.Small)
        return y + panel.itemheight
    end
    self:addChild(self.scrollPanel)

    local inputY = self.height - 195
    self.nameLabel = ISLabel:new(margin, inputY, FONT_HGT_SMALL, "Zone Name:", 1, 1, 1, 1, UIFont.Small)
    self:addChild(self.nameLabel)
    self.nameEntry = ISTextEntryBox:new("", margin + 80, inputY, 200, 25)
    self.nameEntry:initialise()
    self:addChild(self.nameEntry)

    inputY = inputY + 35
    self.x1Label = ISLabel:new(margin, inputY, FONT_HGT_SMALL, "X1:", 1, 1, 1, 1, UIFont.Small)
    self:addChild(self.x1Label)
    self.x1Entry = ISTextEntryBox:new("", margin + 30, inputY, 80, 25)
    self.x1Entry:initialise()
    self.x1Entry:setOnlyNumbers(true)
    self:addChild(self.x1Entry)
    self.y1Label = ISLabel:new(margin + 120, inputY, FONT_HGT_SMALL, "Y1:", 1, 1, 1, 1, UIFont.Small)
    self:addChild(self.y1Label)
    self.y1Entry = ISTextEntryBox:new("", margin + 150, inputY, 80, 25)
    self.y1Entry:initialise()
    self.y1Entry:setOnlyNumbers(true)
    self:addChild(self.y1Entry)
    self.x2Label = ISLabel:new(margin + 240, inputY, FONT_HGT_SMALL, "X2:", 1, 1, 1, 1, UIFont.Small)
    self:addChild(self.x2Label)
    self.x2Entry = ISTextEntryBox:new("", margin + 270, inputY, 80, 25)
    self.x2Entry:initialise()
    self.x2Entry:setOnlyNumbers(true)
    self:addChild(self.x2Entry)
    self.y2Label = ISLabel:new(margin + 360, inputY, FONT_HGT_SMALL, "Y2:", 1, 1, 1, 1, UIFont.Small)
    self:addChild(self.y2Label)
    self.y2Entry = ISTextEntryBox:new("", margin + 390, inputY, 80, 25)
    self.y2Entry:initialise()
    self.y2Entry:setOnlyNumbers(true)
    self:addChild(self.y2Entry)

    inputY = inputY + 35
    self.kosCheck = ISTickBox:new(margin, inputY, 100, 25, "", self, nil)
    self.kosCheck:initialise()
    self.kosCheck:addOption("KOS Zone")
    self:addChild(self.kosCheck)
    self.pveCheck = ISTickBox:new(margin + 120, inputY, 100, 25, "", self, nil)
    self.pveCheck:initialise()
    self.pveCheck:addOption("PvE Zone")
    self:addChild(self.pveCheck)
    self.safeCheck = ISTickBox:new(margin + 240, inputY, 100, 25, "", self, nil)
    self.safeCheck:initialise()
    self.safeCheck:addOption("Safe Zone")
    self:addChild(self.safeCheck)
    self.blockedCheck = ISTickBox:new(margin + 360, inputY, 100, 25, "", self, nil)
    self.blockedCheck:initialise()
    self.blockedCheck:addOption("Blocked")
    self:addChild(self.blockedCheck)

    local btnY = self.height - 50
    self.addBtn = ISButton:new(margin, btnY, btnWidth, btnHeight, "Add", self, ZoneEditorPanel.onAddZone)
    self.addBtn.backgroundColor = {r=0.2, g=0.6, b=0.2, a=1}
    self:addChild(self.addBtn)
    self.updateBtn = ISButton:new(margin + btnWidth + 10, btnY, btnWidth, btnHeight, "Update", self, ZoneEditorPanel.onUpdateZone)
    self.updateBtn.backgroundColor = {r=0.2, g=0.4, b=0.6, a=1}
    self:addChild(self.updateBtn)
    self.deleteBtn = ISButton:new(margin + (btnWidth + 10) * 2, btnY, btnWidth, btnHeight, "Delete", self, ZoneEditorPanel.onDeleteZone)
    self.deleteBtn.backgroundColor = {r=0.6, g=0.2, b=0.2, a=1}
    self:addChild(self.deleteBtn)
    self.clearBtn = ISButton:new(margin + (btnWidth + 10) * 3, btnY, btnWidth, btnHeight, "Clear", self, ZoneEditorPanel.onClearFields)
    self.clearBtn.backgroundColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.clearBtn)
    self.exportBtn = ISButton:new(margin + (btnWidth + 10) * 4, btnY, btnWidth, btnHeight, "Export", self, ZoneEditorPanel.onExportData)
    self.exportBtn.backgroundColor = {r=0.6, g=0.4, b=0.2, a=1}
    self:addChild(self.exportBtn)
    self.loadBtn = ISButton:new(margin + (btnWidth + 10) * 5, btnY, btnWidth, btnHeight, "Load", self, ZoneEditorPanel.onLoadData)
    self.loadBtn.backgroundColor = {r=0.4, g=0.2, b=0.6, a=1}
    self:addChild(self.loadBtn)

    --self:loadFromModData()
    self:loadData()
    self:refreshList()
end
--[[ 
function ZoneEditorPanel:loadFromModData()
    local modData = ModData.getOrCreate("ParadiseZ_ZoneData")
    self.zones = {}
    if modData.zones then
        for _, zone in pairs(modData.zones) do
            table.insert(self.zones, {
                name = zone.name,
                x1 = zone.x1,
                y1 = zone.y1,
                x2 = zone.x2,
                y2 = zone.y2,
                isKos = zone.isKos or false,
                isPvE = zone.isPvE or false,
                isSafe = zone.isSafe or false,
                isBlocked = zone.isBlocked or false
            })
        end
    end
    ParadiseZ.ZoneData = {}
    for i, zone in ipairs(self.zones) do
        ParadiseZ.ZoneData[zone.name] = zone
    end
end
]]

function ZoneEditorPanel:loadData()
    --local modData = ModData.getOrCreate("ParadiseZ_ZoneData")
    self.zones = {}
    if ParadiseZ.ZoneData then
        for _, zone in pairs(ParadiseZ.ZoneData) do
            table.insert(self.zones, {
                name = zone.name,
                x1 = zone.x1,
                y1 = zone.y1,
                x2 = zone.x2,
                y2 = zone.y2,
                isKos = zone.isKos or false,
                isPvE = zone.isPvE or false,
                isSafe = zone.isSafe or false,
                isBlocked = zone.isBlocked or false
            })
        end
    end
    ParadiseZ.ZoneData = {}
    for i, zone in ipairs(self.zones) do
        ParadiseZ.ZoneData[zone.name] = zone
    end
end
function ZoneEditorPanel:refreshList()
    self.scrollPanel:clear()
    for i, zone in ipairs(self.zones) do
        local coords = string.format("(%d,%d)-(%d,%d)", zone.x1, zone.y1, zone.x2, zone.y2)
        self.scrollPanel:addItem(zone.name, {
            name = zone.name,
            coords = coords,
            isKos = zone.isKos,
            isPvE = zone.isPvE,
            isSafe = zone.isSafe,
            isBlocked = zone.isBlocked,
            index = i
        })
    end
    self:saveData()
    --self:saveToModData()
end

function ZoneEditorPanel:saveData()
    --ParadiseZ.ZoneData
    print('saveData')
end

--[[ 
function ZoneEditorPanel:saveToModData()
    local modData = ModData.getOrCreate("ParadiseZ_ZoneData")
    modData.zones = {}
    for _, zone in ipairs(self.zones) do
        modData.zones[zone.name] = zone
    end
    ModData.transmit("ParadiseZ_ZoneData")
    ParadiseZ.ZoneData = {}
    for key, zone in pairs(modData.zones) do
        ParadiseZ.ZoneData[key] = zone
    end
end
 ]]
function ZoneEditorPanel:onAddZone()
    local name = self.nameEntry:getText()
    if name == "" then return end
    local newZone = {
        name = name,
        x1 = tonumber(self.x1Entry:getText()) or 0,
        y1 = tonumber(self.y1Entry:getText()) or 0,
        x2 = tonumber(self.x2Entry:getText()) or 0,
        y2 = tonumber(self.y2Entry:getText()) or 0,
        isKos = self.kosCheck:isSelected(1),
        isPvE = self.pveCheck:isSelected(1),
        isSafe = self.safeCheck:isSelected(1),
        isBlocked = self.blockedCheck:isSelected(1)
    }
    table.insert(self.zones, newZone)
    self:refreshList()
    self:onClearFields()
end

function ZoneEditorPanel:onUpdateZone()
    local selected = self.scrollPanel.selected
    if selected <= 0 then return end
    local zone = self.zones[selected]
    zone.name = self.nameEntry:getText()
    zone.x1 = tonumber(self.x1Entry:getText()) or 0
    zone.y1 = tonumber(self.y1Entry:getText()) or 0
    zone.x2 = tonumber(self.x2Entry:getText()) or 0
    zone.y2 = tonumber(self.y2Entry:getText()) or 0
    zone.isKos = self.kosCheck:isSelected(1)
    zone.isPvE = self.pveCheck:isSelected(1)
    zone.isSafe = self.safeCheck:isSelected(1)
    zone.isBlocked = self.blockedCheck:isSelected(1)
    self:refreshList()
    self:onClearFields()
end

function ZoneEditorPanel:onDeleteZone()
    local selected = self.scrollPanel.selected
    if selected > 0 then
        table.remove(self.zones, selected)
        self:refreshList()
        self:onClearFields()
    end
end

function ZoneEditorPanel:onClearFields()
    self.nameEntry:setText("")
    self.x1Entry:setText("")
    self.y1Entry:setText("")
    self.x2Entry:setText("")
    self.y2Entry:setText("")
    self.kosCheck:setSelected(1, false)
    self.pveCheck:setSelected(1, false)
    self.safeCheck:setSelected(1, false)
    self.blockedCheck:setSelected(1, false)
    self.scrollPanel.selected = 0
end

function ZoneEditorPanel:onLoadData()
    --self:loadFromModData()
    self:loadData()
    self:refreshList()
end

function ZoneEditorPanel:onExportData()
    print("[ParadiseZ.ZoneData Export]")
    print("ParadiseZ.ZoneData = {")
    for _, zone in ipairs(self.zones) do
        print(string.format('    ["%s"] = {', zone.name))
        print(string.format('        name = "%s",', zone.name))
        print(string.format('        x1 = %d,', zone.x1))
        print(string.format('        y1 = %d,', zone.y1))
        print(string.format('        x2 = %d,', zone.x2))
        print(string.format('        y2 = %d,', zone.y2))
        print(string.format('        isKos = %s,', tostring(zone.isKos)))
        print(string.format('        isPvE = %s,', tostring(zone.isPvE)))
        print(string.format('        isSafe = %s,', tostring(zone.isSafe)))
        print(string.format('        isBlocked = %s,', tostring(zone.isBlocked)))
        print('    },')
    end
    print("}")
end

function ZoneEditorPanel:prerender()
    ISCollapsableWindow.prerender(self)
    local selected = self.scrollPanel.selected
    if selected > 0 then
        local zone = self.zones[selected]
        self.nameEntry:setText(zone.name)
        self.x1Entry:setText(tostring(zone.x1))
        self.y1Entry:setText(tostring(zone.y1))
        self.x2Entry:setText(tostring(zone.x2))
        self.y2Entry:setText(tostring(zone.y2))
        self.kosCheck:setSelected(1, zone.isKos)
        self.pveCheck:setSelected(1, zone.isPvE)
        self.safeCheck:setSelected(1, zone.isSafe)
        self.blockedCheck:setSelected(1, zone.isBlocked)
    end
end

function ZoneEditorPanel.OpenPanel()
    if not ZoneEditorPanel.instance then
        local x = getCore():getScreenWidth() / 3
        local y = getCore():getScreenHeight() / 2 - 250
        local w, h = 850, 650
        ZoneEditorPanel.instance = ZoneEditorPanel:new(x, y, w, h)
        ZoneEditorPanel.instance:initialise()
    end
    ZoneEditorPanel.instance:addToUIManager()
    ZoneEditorPanel.instance:setVisible(true)
end

function ZoneEditorPanel.TogglePanel()
    if ZoneEditorPanel.instance then
        ZoneEditorPanel.instance:setVisible(not ZoneEditorPanel.instance:isVisible())
    else
        ZoneEditorPanel.OpenPanel()
    end
end

function ZoneEditorPanel:ClosePanel()
    if ZoneEditorPanel.instance then
        ZoneEditorPanel.instance:close()
        ZoneEditorPanel.instance = nil
    end
end
