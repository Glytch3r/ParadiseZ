--[[ ParadiseZ = ParadiseZ or {}
ParadiseZ.ticketTimestamps = {}
function ParadiseZ.getGameDateTime()
    local gt = getGameTime()
    local months = { "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec" }
    local year = gt:getYear()
    local month = months[gt:getMonth() + 1]
    local day = string.format("%02d", gt:getDay())
    local tod = gt:getTimeOfDay()
    local hour = math.floor(tod)
    local min = math.floor((tod - hour) * 60)
    return month .. " " .. day .. " " .. year .. " / " .. string.format("%02d:%02d", hour, min)
end

function ParadiseZ.getRealWorldDateTime()
    local t = os.date("*t")
    local months = { "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec" }
    return months[t.month] .. " " .. string.format("%02d", t.day) .. " " .. t.year .. " / " .. string.format("%02d:%02d", t.hour, t.min)
end

function ParadiseZ.getTimestamp()
    local stamp = ParadiseZ.getGameDateTime()
    if SandboxVars.ParadiseZ.TicketTimestampType == 2 then
        stamp = ParadiseZ.getRealWorldDateTime()
    elseif SandboxVars.ParadiseZ.TicketTimestampType == 3 then
        stamp = ParadiseZ.getServerDateTime()
    end
    return tostring(stamp)
end

-----------------------            ---------------------------

function ISTicketsUI:onAddTicket(button)
    if button.internal == "OK" then
        if (button.parent.entry:getText() and button.parent.entry:getText() ~= "") then
            local timestamp = ParadiseZ.getTimestamp()
            local message = button.parent.entry:getText()
            ParadiseZ.ticketTimestamps[self.player:getUsername() .. "_" .. message] = timestamp
            addTicket(self.player:getUsername(), message, -1)
        end
    end
end

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local HEADER_HGT = FONT_HGT_SMALL + 2 * 2

local hook_ISTicketsUI_populateList = ISTicketsUI.populateList
function ISTicketsUI:populateList()
    self.datas:clear()
    for i=0,self.tickets:size()-1 do
        local ticket = self.tickets:get(i)
        local item = {}
        item.ticket = ticket
        
        local key1 = ticket:getAuthor() .. "_" .. ticket:getTicketID()
        local key2 = ticket:getAuthor() .. "_" .. ticket:getMessage()
        item.timestamp = ParadiseZ.ticketTimestamps[key1] or ParadiseZ.ticketTimestamps[key2] or ParadiseZ.getTimestamp()
        if not ParadiseZ.ticketTimestamps[key1] then
            ParadiseZ.ticketTimestamps[key1] = item.timestamp
        end

        item.richText = ISRichTextLayout:new(self.datas:getWidth() - 100 - 150 - 10 * 2)
        item.richText.marginLeft = 0
        item.richText.marginTop = 0
        item.richText.marginRight = 0
        item.richText.marginBottom = 0
        item.richText:setText(ticket:getMessage())
        item.richText:initialise()
        item.richText:paginate()

        if ticket:getAnswer() then
            item.richText2 = ISRichTextLayout:new(self.datas:getWidth() - 20 - 10 * 2)
            item.richText2.marginLeft = 0
            item.richText2.marginTop = 0
            item.richText2.marginRight = 0
            item.richText2.marginBottom = 0
            item.richText2:setText(ticket:getAnswer():getAuthor() .. ": " .. ticket:getAnswer():getMessage())
            item.richText2:initialise()
            item.richText2:paginate()
        end

        self.datas:addItem(ticket:getAuthor(), item)
    end
end

local hook_ISTicketsUI_render = ISTicketsUI.render
function ISTicketsUI:render()
    self:drawRectBorder(self.datas.x, self.datas.y - HEADER_HGT, self.datas:getWidth(), HEADER_HGT + 1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawRect(self.datas.x, 1 + self.datas.y - HEADER_HGT, self.datas.width, HEADER_HGT, self.listHeaderColor.a, self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b)
    self:drawRect(self.datas.x + 100, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    
    local timestampX = self.datas.width - 150
    self:drawRect(self.datas.x + timestampX, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    self:drawText("TicketID", self.datas.x + 5, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small)
    self:drawText("Message", self.datas.x + 110, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small)
    self:drawText("Timestamp", self.datas.x + timestampX + 5, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small)
end

local hook_ISTicketsUI_drawDatas = ISTicketsUI.drawDatas
function ISTicketsUI:drawDatas(y, item, alt)
    local a = 0.9
    local answerHeight = 0

    self:drawRectBorder(0, (y), self:getWidth(), item.height - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), item.height - 1, 0.3, 0.7, 0.35, 0.15)
    end

    local ticket = item.item.ticket
    self:drawText(ticket:getTicketID() .. "", 10, y + 2, 1, 1, 1, a, self.font)
    item.item.richText:render(110, y + 2, self)
    local messageHeight = math.max(item.item.richText:getHeight() + 4, self.itemheight)

    local timestampX = self:getWidth() - 150
    self:drawText(item.item.timestamp, timestampX + 5, y + 2, 1, 1, 1, a, self.font)

    if ticket:getAnswer() then
        answerHeight = math.max(item.item.richText2:getHeight() + 4, self.itemheight)
        item.item.richText2:render(20, y + 2 + messageHeight, self)
        self:drawRect(0, (y + messageHeight), self:getWidth(), answerHeight - 1, 0.15, 1, 1, 1)
    end

    self:drawRect(100, y-1, 1, messageHeight, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawRect(timestampX, y-1, 1, messageHeight, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    return y + messageHeight + answerHeight
end

local hook_ISAdminTicketsUI_populateList = ISAdminTicketsUI.populateList
function ISAdminTicketsUI:populateList()
    self.datas:clear()
    self.selectedTicket = nil
    for i=0,self.tickets:size()-1 do
        local ticket = self.tickets:get(i)
        local item = {}
        item.ticket = ticket
        
        local key1 = ticket:getAuthor() .. "_" .. ticket:getTicketID()
        local key2 = ticket:getAuthor() .. "_" .. ticket:getMessage()
        item.timestamp = ParadiseZ.ticketTimestamps[key1] or ParadiseZ.ticketTimestamps[key2] or ParadiseZ.getServerRealWorldDateTime()
        if not ParadiseZ.ticketTimestamps[key1] then
            ParadiseZ.ticketTimestamps[key1] = item.timestamp
        end

        item.richText = ISRichTextLayout:new(self.datas:getWidth() - 200 - 150 - 10 * 2)
        item.richText.marginLeft = 0
        item.richText.marginTop = 0
        item.richText.marginRight = 0
        item.richText.marginBottom = 0
        item.richText:setText(ticket:getMessage())
        item.richText:initialise()
        item.richText:paginate()

        if ticket:getAnswer() then
            item.richText2 = ISRichTextLayout:new(self.datas:getWidth() - 20 - 10 * 2)
            item.richText2.marginLeft = 0
            item.richText2.marginTop = 0
            item.richText2.marginRight = 0
            item.richText2.marginBottom = 0
            item.richText2:setText(ticket:getAnswer():getAuthor() .. ": " .. ticket:getAnswer():getMessage())
            item.richText2:initialise()
            item.richText2:paginate()
        end

        self.datas:addItem(ticket:getAuthor(), item)
        if i == 0 then
            self.selectedTicket = ticket
        end
    end
end

local hook_ISAdminTicketsUI_render = ISAdminTicketsUI.render
function ISAdminTicketsUI:render()
    self:drawRectBorder(self.datas.x, self.datas.y - HEADER_HGT, self.datas:getWidth(), HEADER_HGT + 1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawRect(self.datas.x, 1 + self.datas.y - HEADER_HGT, self.datas.width, HEADER_HGT, self.listHeaderColor.a, self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b)
    self:drawRect(self.datas.x + 100, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawRect(self.datas.x + 200, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    
    local timestampX = self.datas.width - 150
    self:drawRect(self.datas.x + timestampX, 1 + self.datas.y - HEADER_HGT, 1, HEADER_HGT, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    self:drawText("Author", self.datas.x + 5, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small)
    self:drawText("TicketID", self.datas.x + 105, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small)
    self:drawText("Message", self.datas.x + 205, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small)
    self:drawText("Timestamp", self.datas.x + timestampX + 5, self.datas.y - HEADER_HGT + 2, 1, 1, 1, 1, UIFont.Small)
end

local hook_ISAdminTicketsUI_drawDatas = ISAdminTicketsUI.drawDatas
function ISAdminTicketsUI:drawDatas(y, item, alt)
    local a = 0.9
    local answerHeight = 0

    self:drawRectBorder(0, (y), self:getWidth(), item.height - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local ticket = item.item.ticket

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), item.height - 1, 0.3, 0.7, 0.35, 0.15)
        self.parent.selectedTicket = ticket
    end

    self:drawText(ticket:getAuthor(), 10, y + 2, 1, 1, 1, a, self.font)
    self:drawText(ticket:getTicketID() .. "", 105, y + 2, 1, 1, 1, a, self.font)
    item.item.richText:render(205, y + 2, self)
    local messageHeight = math.max(item.item.richText:getHeight() + 4, self.itemheight)

    local timestampX = self:getWidth() - 150
    self:drawText(item.item.timestamp, timestampX + 5, y + 2, 1, 1, 1, a, self.font)

    if ticket:getAnswer() then
        answerHeight = math.max(item.item.richText2:getHeight() + 4, self.itemheight)
        item.item.richText2:render(20, y + 2 + messageHeight, self)
        self:drawRect(0, (y + messageHeight), self:getWidth(), answerHeight - 1, 0.15, 1, 1, 1)
    end

    self:drawRect(100, y, 1, messageHeight-1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawRect(200, y, 1, messageHeight-1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawRect(timestampX, y, 1, messageHeight-1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    return y + messageHeight + answerHeight
end ]]