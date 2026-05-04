ParadiseZ = ParadiseZ or {}
ParadiseZ.ScoreboardUI = ISPanel:derive("ParadiseZ.ScoreboardUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local ROW_H = FONT_HGT_SMALL + 6

function ParadiseZ.ScoreboardUI:initialise()
    ISPanel.initialise(self)
    self.sortColumn = "username"
    self.sortAscending = true
    self.columnHeaders = {"Username", "Online", "PvP Kills", "Zombie Kills", "Total Death", "Total Time Alive"}
    self.columnKeys    = {"username", "online", "pvpKillCount", "zedKillCount", "deathCount", "totalTimeAlive"}
    self.columnWidths  = {120, 80, 100, 120, 100, 120, 120}
    self.headerY       = 30
    self.headerHeight  = FONT_HGT_MEDIUM + 10
    self.playerList    = {}
    self.scrollOffset  = 0
end

function ParadiseZ.ScoreboardUI:render()
    ISPanel.render(self)
    local titleX = self.width / 2 - getTextManager():MeasureStringX(UIFont.Medium, "Paradise Z Scoreboard") / 2
    self:drawText("Scoreboard", titleX, 8, 1, 1, 1, 1, UIFont.Medium)
    self:drawColumnHeaders()
    self:drawRows()
end

function ParadiseZ.ScoreboardUI:drawColumnHeaders()
    local xPos = 10
    local padY = (self.headerHeight - FONT_HGT_SMALL) / 2

    for i, header in ipairs(self.columnHeaders) do
        local colWidth = self.columnWidths[i] or 100
        local colKey   = self.columnKeys[i]
        local isActive = self.sortColumn == colKey

        if isActive then
            self:drawRect(xPos - 2, self.headerY, colWidth - 2, self.headerHeight, 0.3, 0.4, 0.4, 0.7)
        else
            self:drawRect(xPos - 2, self.headerY, colWidth - 2, self.headerHeight, 0.1, 0.1, 0.1, 0.5)
        end

        local label = header .. (isActive and (self.sortAscending and " ↑" or " ↓") or "")
        self:drawText(label, xPos, self.headerY + padY, 0.9, 0.9, 0.9, 1, UIFont.Small)
        xPos = xPos + colWidth
    end
end

function ParadiseZ.ScoreboardUI:drawRows()
    local startY   = self.headerY + self.headerHeight + 4
    local endY     = self.scrollAreaBottom
    local clipH    = endY - startY
    if clipH <= 0 then return end

    self:setStencilRect(10, startY, self.width - 20, clipH)

    for idx, p in ipairs(self.playerList) do
        local y = startY + (idx - 1) * ROW_H - self.scrollOffset
        if y + ROW_H >= startY and y <= endY then
            if idx % 2 == 0 then
                self:drawRect(10, y, self.width - 20, ROW_H, 0.15, 0.15, 0.15, 0.5)
            end
            local cols = {
                p.username,
                p.online,
                tostring(p.pvpKillCount),
                tostring(p.zedKillCount),
                tostring(p.deathCount),
                tostring(p.totalTimeAlive),              
            }
            local xPos = 10
            local padY = (ROW_H - FONT_HGT_SMALL) / 2
            for i, val in ipairs(cols) do
                self:drawText(tostring(val), xPos, y + padY, 1, 1, 1, 1, UIFont.Small)
                xPos = xPos + (self.columnWidths[i] or 100)
            end
        end
    end

    self:clearStencilRect()

    local totalH = #self.playerList * ROW_H
    if totalH > clipH then
        local trackX = self.width - 12
        local trackH = clipH
        self:drawRect(trackX, startY, 8, trackH, 0.1, 0.1, 0.1, 0.8)
        local thumbH   = math.max(20, trackH * (clipH / totalH))
        local thumbMaxY = trackH - thumbH
        local thumbY   = startY + (self.scrollOffset / (totalH - clipH)) * thumbMaxY
        self:drawRect(trackX, thumbY, 8, thumbH, 0.5, 0.5, 0.5, 0.9)
    end
end

function ParadiseZ.ScoreboardUI:onMouseWheel(del)
    local startY = self.headerY + self.headerHeight + 4
    local clipH  = self.scrollAreaBottom - startY
    local totalH = #self.playerList * ROW_H
    local maxScroll = math.max(0, totalH - clipH)
    self.scrollOffset = math.max(0, math.min(maxScroll, self.scrollOffset - del * ROW_H * 3))
    return true
end

function ParadiseZ.ScoreboardUI:onMouseDown(x, y)
    if ISPanel.onMouseDown(self, x, y) then return true end

    if y >= self.headerY and y < self.headerY + self.headerHeight then
        local xPos = 10
        for i, colKey in ipairs(self.columnKeys) do
            local colWidth = self.columnWidths[i] or 100
            if x >= xPos - 2 and x < xPos - 2 + colWidth then
                self:onColumnClick(colKey)
                return true
            end
            xPos = xPos + colWidth
        end
    end
    return false
end

function ParadiseZ.ScoreboardUI:buildPlayerData()
    local raw = ParadiseZ.Scoreboard or {}

    local modRaw = ModData.get("ParadiseZ_Scoreboard")
    if type(modRaw) == "table" then
        for k, v in pairs(modRaw) do
            if not raw[k] then raw[k] = v end
        end
    end

    local searchTerm  = self.searchBox and self.searchBox:getText():lower() or ""
    local showOffline = self.showOfflineTicked or false

    local onlineNames = {}
    local onlinePlayers = getOnlinePlayers()
    for i = 0, onlinePlayers:size() - 1 do
        local pl = onlinePlayers:get(i)
        if pl and pl:getUsername() then
            onlineNames[pl:getUsername()] = true
        end
    end
    local localPl = getPlayer()
    if localPl and localPl:getUsername() then
        onlineNames[localPl:getUsername()] = true
    end

    local function numVal(v)
        if type(v) == "number" then return v end
        if type(v) == "table"  then return tonumber(v[1]) or 0 end
        return 0
    end

    local newData = {}
    for username, scoreData in pairs(raw) do
        if type(username) == "string" then
            local isOnline    = onlineNames[username] == true
            local passOffline = showOffline or isOnline
            local passSearch  = searchTerm == "" or string.find(username:lower(), searchTerm, 1, true)
            if passOffline and passSearch then
                table.insert(newData, {
                    username       = username,
                    online         = isOnline and "ONLINE" or "OFFLINE",
                    isOnline       = isOnline,
                    pvpKillCount   = numVal(scoreData.pvpKillCount),
                    zedKillCount   = numVal(scoreData.zedKillCount),
                    deathCount     = numVal(scoreData.deathCount),
                    totalTimeAlive = numVal(scoreData.totalTimeAlive or scoreData.timeAlive),
                    --lastLogin      = type(scoreData.lastLogin) == "string" and scoreData.lastLogin or "",
                })
            end
        end
    end

    table.sort(newData, function(a, b)
        local col = self.sortColumn
        if col == "online" then
            if a.isOnline ~= b.isOnline then
                return self.sortAscending and a.isOnline or b.isOnline
            end
        else
            local av, bv = a[col], b[col]
            if av ~= bv then
                if type(av) == "number" then
                    return self.sortAscending and av < bv or av > bv
                else
                    return self.sortAscending and tostring(av) < tostring(bv) or tostring(av) > tostring(bv)
                end
            end
        end
        return a.username < b.username
    end)

    return newData
end

function ParadiseZ.ScoreboardUI:updatePlayerList()
    self.scrollOffset = 0
    self.playerList   = self:buildPlayerData()
end

function ParadiseZ.ScoreboardUI:onSearchChange()
    self:updatePlayerList()
end

function ParadiseZ.ScoreboardUI:onToggleTick(_, selected)
    self.showOfflineTicked = selected
    self:updatePlayerList()
end

function ParadiseZ.ScoreboardUI:onColumnClick(key)
    if self.sortColumn == key then
        self.sortAscending = not self.sortAscending
    else
        self.sortColumn    = key
        self.sortAscending = true
    end
    self:updatePlayerList()
end

function ParadiseZ.ScoreboardUI:onReset()
    if ParadiseZ.isAdm() then
        for k in pairs(ParadiseZ.Scoreboard) do
            ParadiseZ.Scoreboard[k] = nil
        end
        ParadiseZ.saveScoreboard(ParadiseZ.Scoreboard, nil)
        --ModData.remove("ParadiseZ_Scoreboard")
        self:updatePlayerList()
    else
        
    end
end



function ParadiseZ.ScoreboardUI:createChildren()
    ISPanel.createChildren(self)

    local btnH    = math.max(25, FONT_HGT_SMALL + 6)
    local padBot  = 10
    local tickH   = FONT_HGT_SMALL + 6
    local searchH = 20
    local bottomH = searchH + 6 + tickH + 6 + btnH + padBot

    self.scrollAreaBottom = self.height - bottomH

    local searchY = self.height - bottomH
    self.searchBox = ISTextEntryBox:new("", 10, searchY, 150, searchH)
    self.searchBox:initialise()
    self.searchBox:instantiate()
    self.searchBox.onTextChange = function() self:onSearchChange() end
    self:addChild(self.searchBox)

    local tickY = searchY + searchH + 6
    self.ShowOffline = ISTickBox:new(10, tickY, 200, tickH, "", self, ParadiseZ.ScoreboardUI.onToggleTick)
    self.ShowOffline:initialise()
    self.ShowOffline:instantiate()
    self.ShowOffline:addOption("Show Offline")
    self:addChild(self.ShowOffline)

    local btnY = self.height - btnH - padBot
    self.reset = ISButton:new(10, btnY, 100, btnH, "Reset", self, ParadiseZ.ScoreboardUI.onOptionMouseDown)
    self.reset.internal = "RESET"
    self.reset:initialise()
    self.reset:instantiate()
    self.reset.borderColor = self.buttonBorderColor
    self.reset.enable = ParadiseZ.isAdm()
    self:addChild(self.reset)
    
    self.close = ISButton:new(self.width - 110, btnY, 100, btnH, "Close", self, ParadiseZ.ScoreboardUI.onOptionMouseDown)
    self.close.internal = "CLOSE"
    self.close:initialise()
    self.close:instantiate()
    self.close.borderColor = self.buttonBorderColor
    self:addChild(self.close)

    self:updatePlayerList()
end

function ParadiseZ.ScoreboardUI:onOptionMouseDown(button, x, y)
    if button.internal == "CLOSE" then self:closeSelf()
    elseif button.internal == "RESET" then self:onReset() end
end

function ParadiseZ.ScoreboardUI:closeSelf()
    self:setVisible(false)
    self:removeFromUIManager()
    ParadiseZ.ScoreboardUI.instance = nil
end

function ParadiseZ.ScoreboardUI:new(x, y, width, height)
    local o = ISPanel:new(
        (getCore():getScreenWidth()  / 2) - (width  / 2),
        (getCore():getScreenHeight() / 2) - (height / 2),
        width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor   = {r=0, g=0, b=0, a=0.8}
    o.borderColor       = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.moveWithMouse     = true
    o.scrollOffset      = 0
    o.playerList        = {}
    ParadiseZ.ScoreboardUI.instance = o
    return o
end

function ParadiseZ.openScoreboard()
    if ParadiseZ.ScoreboardUI.instance then
        ParadiseZ.ScoreboardUI.instance:setVisible(true)
        ParadiseZ.ScoreboardUI.instance:toFront()
        ParadiseZ.ScoreboardUI.instance = nil
    else
        local ui = ParadiseZ.ScoreboardUI:new(0, 0, 900, 600)
        ui:initialise()
        ui:addToUIManager()
    end
end

function ParadiseZ.closeScoreboard()
    if ParadiseZ.ScoreboardUI.instance then
        ParadiseZ.ScoreboardUI.instance:closeSelf()
    end
end