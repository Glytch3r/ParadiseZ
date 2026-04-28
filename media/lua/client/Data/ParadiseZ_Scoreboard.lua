ParadiseZ = ParadiseZ or {}

ParadiseZ.ScoreboardUI = ISPanel:derive("ParadiseZ.ScoreboardUI")
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function ParadiseZ.ScoreboardUI:initialise()
    ISPanel.initialise(self)
end

function ParadiseZ.ScoreboardUI:render()
    ISPanel.render(self)
    
    local z = 10
    self:drawText("Scoreboard", self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, "Scoreboard") / 2), z, 1, 1, 1, 1, UIFont.Medium)
    
    self:updatePlayerList()
end

function ParadiseZ.ScoreboardUI:updatePlayerList()
    if not self.scrollPane then return end
    
    local searchTerm = self.searchBox and self.searchBox:getText():lower() or ""
    local showOffline = self.showOfflineCheckBox and self.showOfflineCheckBox:isSelected()
    local onlinePlayers = getOnlinePlayers()
    local onlineNames = {}
    
    for i = 0, onlinePlayers:size() - 1 do
        onlineNames[onlinePlayers:get(i):getUsername()] = true
    end
    
    self.scrollPane:clear()
    self.playerList = {}
    
    for username, scoreData in pairs(ParadiseZ.Scoreboard or {}) do
        local isOnline = onlineNames[username] ~= nil
        
        if not showOffline and not isOnline then
        elseif searchTerm ~= "" and not string.find(username:lower(), searchTerm, 1, true) then
        else
            local deathCount = scoreData.deathCount or 0
            local pvpKillCount = scoreData.pvpKillCount or 0
            local zedKillCount = scoreData.zedKillCount or 0
            
            local statusStr = isOnline and " [ONLINE]" or " [OFFLINE]"
            local rowText = username .. statusStr .. " | Deaths: " .. deathCount .. " | PvP Kills: " .. pvpKillCount .. " | Zed Kills: " .. zedKillCount
            
            table.insert(self.playerList, {
                username = username,
                deathCount = deathCount,
                pvpKillCount = pvpKillCount,
                zedKillCount = zedKillCount,
                isOnline = isOnline,
                displayText = rowText
            })
        end
    end
    
    for _, player in ipairs(self.playerList) do
        local item = self.scrollPane:addItem(player.displayText, nil)
        item.userData = player
    end
end

function ParadiseZ.ScoreboardUI:onSearchChange()
    self:updatePlayerList()
end

function ParadiseZ.ScoreboardUI:onShowOfflineToggle()
    self:updatePlayerList()
end

function ParadiseZ.ScoreboardUI:createChildren()
    ISPanel.createChildren(self)
    
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10
    
    self.playerList = {}
    
    local searchY = 50
    self.searchBox = ISTextEntryBox:new("", 10, searchY + FONT_HGT_SMALL + 5, 150, 20)
    self.searchBox:initialise()
    self.searchBox:instantiate()
    self.searchBox.onTextChange = ParadiseZ.ScoreboardUI.onSearchChange
    self.searchBox.target = self
    self:addChild(self.searchBox)



    local scrollY = searchY + FONT_HGT_SMALL + 35
    local scrollHeight = self.height - scrollY - btnHgt - padBottom - 10

    self.scrollPane = ISScrollingListBox:new(10, scrollY, self.width - 20, scrollHeight)
    self.scrollPane:initialise()
    self.scrollPane:instantiate()
    self.scrollPane.font = UIFont.Small
    self.scrollPane.itemheight = FONT_HGT_SMALL + 3
    self:addChild(self.scrollPane)
    
    self.close = ISButton:new(self:getWidth() - 100 - 10, self:getHeight() - btnHgt - padBottom, btnWid, btnHgt, "Close", self, ParadiseZ.ScoreboardUI.onOptionMouseDown)
    self.close.internal = "CLOSE"
    self.close:initialise()
    self.close:instantiate()
    self.close.borderColor = self.buttonBorderColor
    self:addChild(self.close)
end

function ParadiseZ.ScoreboardUI:onOptionMouseDown(button, x, y)
    if button.internal == "CLOSE" then
        self:closeSelf()
    end
end

function ParadiseZ.ScoreboardUI:closeSelf()
    self:setVisible(false)
    self:removeFromUIManager()
end

function ParadiseZ.ScoreboardUI:new(x, y, width, height)
    local o = {}
    x = (getCore():getScreenWidth() / 2) - (width / 2)
    y = (getCore():getScreenHeight() / 2) - (height / 2)
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0.8}
    o.borderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.5}
    o.buttonBorderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.5}
    o.moveWithMouse = true
    self.__index = self
    ParadiseZ.ScoreboardUI.instance = o
    return o
end

function ParadiseZ.openScoreboard()
    if ParadiseZ.ScoreboardUI.instance then
        ParadiseZ.ScoreboardUI.instance:setVisible(true)
        ParadiseZ.ScoreboardUI.instance:toFront()
    else
        local sW = getCore():getScreenWidth()
        local sH = getCore():getScreenHeight()
        local sX = sW / 2
        local sY = sH / 2
        local ui = ParadiseZ.ScoreboardUI:new(sX, sY, 600, 500)
        ui:initialise()
        ui:addToUIManager()
    end
end

function ParadiseZ.closeScoreboard()
    if ParadiseZ.ScoreboardUI.instance then
        ParadiseZ.ScoreboardUI.instance:closeSelf()
    end
end