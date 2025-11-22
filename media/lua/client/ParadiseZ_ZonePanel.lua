require "ISUI/ISCollapsableWindow"
ParadiseZ = ParadiseZ or {}
ParadiseZ.ZoneEditorWindow = ISCollapsableWindow:derive("ParadiseZ.ZoneEditorWindow")

function ParadiseZ.saveZoneData()
    if isClient() then
        ModData.transmit("ParadiseZ_ZoneData")
    else
        local md = ModData.getOrCreate("ParadiseZ_ZoneData")
        for k in pairs(md) do md[k] = nil end
        for k, v in pairs(ParadiseZ.ZoneData) do
            md[k] = v
        end
    end
end

function ParadiseZ.loadZoneData()
    local gameModData = ModData.getOrCreate("ParadiseZ_ZoneData")
    if next(gameModData) == nil then
        for k, v in pairs(ParadiseZ.ZoneDataBackup) do
            local zone = {}
            for key, val in pairs(v) do
                zone[key] = val
            end
            gameModData[k] = zone
        end
    end
    ParadiseZ.ZoneData = gameModData
end

function ParadiseZ.recieveData(key, modData)
    if key == "ParadiseZ_ZoneData" then
        ParadiseZ.ZoneData = modData
        if ParadiseZ.ZoneEditorWindow.instance then
            ParadiseZ.ZoneEditorWindow.instance:refreshList()
        end
    end
end

function ParadiseZ.onGameStart()
    ParadiseZ.loadZoneData()
    if isClient() then
        ModData.request("ParadiseZ_ZoneData")
    end
end
Events.OnGameStart.Add(ParadiseZ.onGameStart)
Events.OnReceiveGlobalModData.Add(ParadiseZ.recieveData)


local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local MARGIN = 15

function ParadiseZ.ZoneEditorWindow:initialise()
    ISCollapsableWindow.initialise(self)
end

function ParadiseZ.ZoneEditorWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Glytch3r's   ParadiseZ    Zone    Editor"
    o.resizable = true
    o.minimumWidth = 650
    o.minimumHeight = 400
    o.listHeaderColor = {r = 0.4, g = 0.4, b = 0.4, a = 0.3}
    o.borderColor =     { r = 0.81, g = 0.92, b = 0.84, a = 1}
    o.backgroundColor = { r = 0.18, g = 0.02, b = 0.22 , a = 0.7} 
    o.buttonBorderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.5}
    o.totalResult = 0
    o.filterWidgets = {}
    o.filterWidgetMap = {}
    o.moveWithMouse = true
    ParadiseZ.ZoneEditorWindow.instance = o
    o:setResizable(true)
    return o
end

function ParadiseZ.ZoneEditorWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local entryHgt = FONT_HGT_MEDIUM + 2 * 2
    local titleBarHgt = self:titleBarHeight()
    
    local contentY = titleBarHgt + MARGIN
    local contentX = MARGIN
    local contentW = self.width - MARGIN * 2
    
    self.totalLabel = ISLabel:new(contentX , contentY-12, FONT_HGT_SMALL, "Total Zones: 0", 1, 1, 1, 0.8, UIFont.Small, true)
    self.totalLabel:initialise()
    self.totalLabel:instantiate()
    self:addChild(self.totalLabel)
        
    self.infoLabel = ISLabel:new(contentX+ 350, contentY-12, FONT_HGT_SMALL, "Double-click to edit zone coordinates", 1, 1, 1, 0.8, UIFont.Small, true)
    self.infoLabel:initialise()
    self.infoLabel:instantiate()
    self:addChild(self.infoLabel)
    
    local listY = contentY + FONT_HGT_SMALL + MARGIN
    local bottomHgt = (btnHgt + MARGIN) * 2 + FONT_HGT_LARGE + MARGIN + entryHgt + MARGIN * 2
    local listH = self.height - listY - bottomHgt - MARGIN
    
    self.datas = ISScrollingListBox:new(contentX, listY, contentW, listH)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = FONT_HGT_SMALL + 4 * 2
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true
    self.datas.borderColor = {r = 0.5, g = 0.5, b = 0.5, a = 0.9}
    self.datas:addColumn("Name", 0)
    self.datas:addColumn("Point1", 120)
    self.datas:addColumn("Point2", 220)
    self.datas:addColumn("isKos", 320)
    self.datas:addColumn("isPvE", 390)
    self.datas:addColumn("isSafe", 460)
    self.datas:addColumn("isBlocked", 530)

    self.datas:setOnMouseDoubleClick(self, ParadiseZ.ZoneEditorWindow.onEditZone)
    self:addChild(self.datas)
    
    local btnY = self.datas:getBottom() + MARGIN
    
    self.btnPoint1 = ISButton:new(contentX, btnY, btnWid, btnHgt, "Set Point1", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnPoint1.internal = "POINT1"
    self.btnPoint1:initialise()
    self.btnPoint1:instantiate()
    self.btnPoint1.enable = false
--    self.btnPoint1.borderColor = self.buttonBorderColor
    self.btnPoint1.borderColor = {r = 0.3, g = 0.7, b = 0.3, a = 0.8}

    self:addChild(self.btnPoint1)
    
    self.btnToggleKos = ISButton:new(self.btnPoint1:getRight() + MARGIN, btnY, btnWid, btnHgt, "Toggle KOS", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnToggleKos.internal = "TOGGLE_KOS"
    self.btnToggleKos:initialise()
    self.btnToggleKos:instantiate()
    self.btnToggleKos.enable = false
    self.btnToggleKos.borderColor = self.buttonBorderColor
    self:addChild(self.btnToggleKos)
    
    self.btnToggleSafe = ISButton:new(self.btnToggleKos:getRight() + MARGIN, btnY, btnWid, btnHgt, "Toggle Safe", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnToggleSafe.internal = "TOGGLE_SAFE"
    self.btnToggleSafe:initialise()
    self.btnToggleSafe:instantiate()
    self.btnToggleSafe.enable = false
    self.btnToggleSafe.borderColor = self.buttonBorderColor
    self:addChild(self.btnToggleSafe)
    
    self.btnReset = ISButton:new(self.btnToggleSafe:getRight() + MARGIN, btnY, btnWid, btnHgt, "Reset Zone", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnReset.internal = "RESET"
    self.btnReset:initialise()
    self.btnReset:instantiate()
    self.btnReset.enable = false
    self.btnReset.borderColor = {r = 1, g = 0.7, b = 0.3, a = 0.8}
    --self.btnReset.borderColor = self.buttonBorderColor
    self:addChild(self.btnReset)
    
    local btnY2 = btnY + btnHgt + MARGIN
    
    self.btnPoint2 = ISButton:new(contentX, btnY2, btnWid, btnHgt, "Set Point2", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnPoint2.internal = "POINT2"
    self.btnPoint2:initialise()
    self.btnPoint2:instantiate()
    self.btnPoint2.enable = false
    self.btnPoint2.borderColor = {r = 0.3, g = 0.7, b = 0.3, a = 0.8}
--    self.btnPoint2.borderColor = self.buttonBorderColor

    self:addChild(self.btnPoint2)
    
    self.btnTogglePvE = ISButton:new(self.btnPoint2:getRight() + MARGIN, btnY2, btnWid, btnHgt, "Toggle PvE", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnTogglePvE.internal = "TOGGLE_PVE"
    self.btnTogglePvE:initialise()
    self.btnTogglePvE:instantiate()
    self.btnTogglePvE.enable = false
    self.btnTogglePvE.borderColor = self.buttonBorderColor
    self:addChild(self.btnTogglePvE)
    
    self.btnToggleBlocked = ISButton:new(self.btnTogglePvE:getRight() + MARGIN, btnY2, btnWid, btnHgt, "Toggle Blocked", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnToggleBlocked.internal = "TOGGLE_BLOCKED"
    self.btnToggleBlocked:initialise()
    self.btnToggleBlocked:instantiate()
    self.btnToggleBlocked.enable = false
    self.btnToggleBlocked.borderColor = self.buttonBorderColor
    self:addChild(self.btnToggleBlocked)
    
    self.btnSave = ISButton:new(self.btnToggleBlocked:getRight() + MARGIN, btnY2, btnWid, btnHgt, "Save to Server", self, ParadiseZ.ZoneEditorWindow.onOptionMouseDown)
    self.btnSave.internal = "SAVE"
    self.btnSave:initialise()
    self.btnSave:instantiate()
    self.btnSave.enable = true
    self.btnSave.borderColor = {r = 0.3, g = 0.7, b = 1, a = 0.8}
    self:addChild(self.btnSave)
    
    local filterY = btnY2 + btnHgt + MARGIN
    
    self.filtersLabel = ISLabel:new(contentX, filterY, FONT_HGT_LARGE, "Filters", 1, 1, 1, 1, UIFont.Large, true)
    self.filtersLabel:initialise()
    self.filtersLabel:instantiate()
    self:addChild(self.filtersLabel)
    
    local entryY = filterY + FONT_HGT_LARGE + 5
    local x = contentX
    
    for i, column in ipairs(self.datas.columns) do
        local size
        if i == #self.datas.columns then
            size = contentW - (x - contentX)
        else
            size = self.datas.columns[i + 1].size - self.datas.columns[i].size
        end
        
        if column.name == "isKos" or column.name == "isPvE" or column.name == "isSafe" or column.name == "isBlocked" then
            local combo = ISComboBox:new(x, entryY, size - 5, entryHgt)
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
            table.insert(self.filterWidgets, combo)
            self.filterWidgetMap[column.name] = combo
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
            table.insert(self.filterWidgets, entry)
            self.filterWidgetMap[column.name] = entry
        end
        x = x + size
    end
    
    self:initList()
end

function ParadiseZ.ZoneEditorWindow:onEditZone(item)
    local zone = item
    local x = (getCore():getScreenWidth() - width) / 2 + 160
    local y = (getCore():getScreenHeight() - height) / 2
    local modal = ISTextBox:new(x, y, 350, 200, "Edit Zone: " .. zone.name .. "\nFormat: x1,y1,x2,y2", zone.x1 .. "," .. zone.y1 .. "," .. zone.x2 .. "," .. zone.y2, self, ParadiseZ.ZoneEditorWindow.onEditConfirm, nil, zone)
    modal:initialise()
    modal:addToUIManager()
end

function ParadiseZ.ZoneEditorWindow:onEditConfirm(button, zone)
    if button.internal == "OK" then
        local text = button.parent.entry:getText()
        local coords = {}
        for num in string.gmatch(text, "[^,]+") do
            table.insert(coords, tonumber(num:match("^%s*(.-)%s*$")))
        end
        if #coords == 4 and coords[1] and coords[2] and coords[3] and coords[4] then
            zone.x1 = coords[1]
            zone.y1 = coords[2]
            zone.x2 = coords[3]
            zone.y2 = coords[4]
            self:refreshList()
        end
    end
end

function ParadiseZ.ZoneEditorWindow:onOptionMouseDown(button, x, y)
    local selected = self.datas.items[self.datas.selected]
    if not selected then return end
    local zone = selected.item
    local pl = getPlayer()
    if button.internal == "POINT1" then
        zone.x1 = round(pl:getX())
        zone.y1 = round(pl:getY())
    elseif button.internal == "POINT2" then
        zone.x2 = round(pl:getX())
        zone.y2 = round(pl:getY())
    elseif button.internal == "TOGGLE_KOS" then
        zone.isKos = not zone.isKos
    elseif button.internal == "TOGGLE_PVE" then
        zone.isPvE = not zone.isPvE
    elseif button.internal == "TOGGLE_SAFE" then
        zone.isSafe = not zone.isSafe
    elseif button.internal == "TOGGLE_BLOCKED" then
        zone.isBlocked = not zone.isBlocked
    elseif button.internal == "RESET" then
        local backup = ParadiseZ.ZoneDataBackup[zone.name]
        if backup then
            zone.x1 = backup.x1
            zone.y1 = backup.y1
            zone.x2 = backup.x2
            zone.y2 = backup.y2
            zone.isKos = backup.isKos
            zone.isPvE = backup.isPvE
            zone.isSafe = backup.isSafe
            zone.isBlocked = backup.isBlocked
        end
    elseif button.internal == "SAVE" then
        ParadiseZ.saveZoneData()
        return
    end
    self:refreshList()
end

function ParadiseZ.ZoneEditorWindow:initList()
    self.totalResult = 0
    self.datas:clear()
    self.datas.fullList = nil
    
    if not ParadiseZ.ZoneData then return end
    
    for name, zone in pairs(ParadiseZ.ZoneData) do
        self.datas:addItem(zone.name, zone)
        self.totalResult = self.totalResult + 1
    end
    
    table.sort(self.datas.items, function(a, b)
        return not string.sort(a.item.name, b.item.name)
    end)
    
    self.totalLabel:setName("Total Zones: " .. self.totalResult)
end

function ParadiseZ.ZoneEditorWindow:refreshList()
    local selectedIdx = self.datas.selected
    self:initList()
    if #self.filterWidgets > 0 then
        ParadiseZ.ZoneEditorWindow.onFilterChange(self.filterWidgets[1])
    end
    self.datas.selected = selectedIdx
end

function ParadiseZ.ZoneEditorWindow:update()
    ISCollapsableWindow.update(self)
    local hasSelection = self.datas.selected > 0
    self.btnPoint1.enable = hasSelection
    self.btnPoint2.enable = hasSelection
    self.btnToggleKos.enable = hasSelection
    self.btnTogglePvE.enable = hasSelection
    self.btnToggleSafe.enable = hasSelection
    self.btnToggleBlocked.enable = hasSelection
    self.btnReset.enable = hasSelection
    self.datas.doDrawItem = self.drawDatas
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
    if not datas.fullList then datas.fullList = datas.items end
    widget.parent.totalResult = 0
    datas:clear()
    
    for i, v in ipairs(datas.fullList) do
        local add = true
        for j, w in ipairs(widget.parent.filterWidgets) do
            if not w.zoneFilter(self, w, v.item) then
                add = false
                break
            end
        end
        if add then
            datas:addItem(i, v.item)
            widget.parent.totalResult = widget.parent.totalResult + 1
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
    
    local kosColor = zone.isKos and {1, 0.3, 0.3} or {0.2, 0.2, 0.2}
    self:drawText(tostring(zone.isKos), self.columns[4].size + xoffset, y + 4, kosColor[1], kosColor[2], kosColor[3], a, self.font)
    
    local pveColor = zone.isPvE and {0.3, 0, 1} or {0.2, 0.2, 0.2}
    self:drawText(tostring(zone.isPvE), self.columns[5].size + xoffset, y + 4, pveColor[1], pveColor[2], pveColor[3], a, self.font)
    
    local safeColor = zone.isSafe and {0.3, 0.8, 1} or {0.8, 0.8, 0.8}
    self:drawText(tostring(zone.isSafe), self.columns[6].size + xoffset, y + 4, safeColor[1], safeColor[2], safeColor[3], a, self.font)
    
    local blockedColor = zone.isBlocked and {1, 0.5, 0} or {0.8, 0.8, 0.8}
    self:drawText(tostring(zone.isBlocked), self.columns[7].size + xoffset, y + 4, blockedColor[1], blockedColor[2], blockedColor[3], a, self.font)
    
    return y + self.itemheight
end

function ParadiseZ.ZoneEditorWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
    ParadiseZ.ZoneEditorWindow.instance = nil
end

function ParadiseZ.editor(activate)
    if ParadiseZ.ZoneEditorWindow.instance then
        ParadiseZ.ZoneEditorWindow.instance:removeFromUIManager()
        ParadiseZ.ZoneEditorWindow.instance = nil
    end
    if activate then
        local width = 760
        local height = 600
        local x = (getCore():getScreenWidth() - width) / 2
        local y = (getCore():getScreenHeight() - height) / 2
        local editor = ParadiseZ.ZoneEditorWindow:new(x, y, width, height)
        editor:initialise()
        editor:addToUIManager()
    end
end
