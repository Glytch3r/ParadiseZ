require "ISUI/ISPanelJoypad"
require "ISUI/ISButton"
require "ISUI/ISSliderPanel"

ISQuantityModal = ISPanelJoypad:derive("ISQuantityModal")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function ISQuantityModal:initialise()
    ISPanel.initialise(self)

    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 6)
    local padBottom = 10

    self.sliderPanel = ISSliderPanel:new(20, 50, self.width - 40, 60, self.quantity)
    self.sliderPanel:initialise()
    self.sliderPanel:instantiate()
    self.sliderPanel:setValues(0, self.maxValue, 1, 1, true)
    self.sliderPanel:setCurrentValue(self.quantity)
    self:addChild(self.sliderPanel)

    self.ok = ISButton:new((self:getWidth() / 2) - btnWid - 5, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Ok"), self, ISQuantityModal.onClick)
    self.ok.internal = "OK"
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise()
    self.ok:instantiate()
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.ok)

    self.cancel = ISButton:new((self:getWidth() / 2) + 5, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, ISQuantityModal.onClick)
    self.cancel.internal = "CANCEL"
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.cancel)
end

function ISQuantityModal:onClick(button)
    local value = math.floor(self.sliderPanel:getCurrentValue())
    self:destroy()
    if self.onclick then
        button.player = self.player
        self.onclick(self.target, button, value, self.param1)
    end
end

function ISQuantityModal:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawTextCentre(self.text, self:getWidth() / 2, 20, 1, 1, 1, 1, UIFont.Small)
end

function ISQuantityModal:destroy()
    self:setVisible(false)
    self:removeFromUIManager()
    if self.player ~= nil then
        setJoypadFocus(self.player, self.prevFocus)
    end
end

function ISQuantityModal.CalcSize(width, height, text)
    local fontHgt = getTextManager():getFontHeight(UIFont.Small)
    local textWid = getTextManager():MeasureStringX(UIFont.Small, text)
    local textHgt = fontHgt

    local buttonWid = 100
    if width < math.max(textWid + 20, buttonWid * 2 + 10) then
        width = math.max(textWid + 20, buttonWid * 2 + 10)
    end

    local buttonHgt = 25
    local padBottom = 10
    if height < 20 + textHgt + 80 + buttonHgt + padBottom then
        height = 20 + textHgt + 80 + buttonHgt + padBottom
    end

    return width, height
end

function ISQuantityModal:new(x, y, width, height, text, maxValue, target, onclick, player, quantity, param1)
    text = text:gsub("\\n", "\n")
    width, height = ISQuantityModal.CalcSize(width, height, text)

    local o = ISPanelJoypad.new(self, x, y, width, height)

    if y == 0 then
        o.y = o:getMouseY() - (height / 2)
        o:setY(o.y)
    end
    if x == 0 then
        o.x = o:getMouseX() - (width / 2)
        o:setX(o.x)
    end

    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.anchorLeft = true
    o.anchorRight = true
    o.anchorTop = true
    o.anchorBottom = true
    o.text = text
    o.target = target
    o.onclick = onclick
    o.player = player
    o.maxValue = maxValue or 100
    o.quantity = quantity or 0
    o.param1 = param1
    o.moveWithMouse = false

    return o
end
