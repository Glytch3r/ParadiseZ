
ParadiseZ = ParadiseZ or {}
LifeBarUI = LifeBarUI or {}

LifeBarUI.panel = nil
LifeBarUI.visible = true
LifeBarUI.maxValue = 100

LifeBarUI.UI = ISPanel:derive("LifeBarUI_UI")

function LifeBarUI.UI:initialise()
    ISPanel.initialise(self)
end
  
function LifeBarUI.UI:render()
    local pl = getPlayer()
    if not pl then return end
    local md = pl:getModData()
    local life = md.LifePoints or 0
    local w = self.width - 4
    local h = self.height - 4
    local barW = (life / LifeBarUI.maxValue) * w
    self:drawRect(2, 2, w, h, 1, 0, 0, 0)
    self:drawRect(2, 2, barW, h, 1, 0.8, 0.1, 0.1)
    self:drawRectBorder(2, 2, w, h, 1, 1, 1, 1)
end

function LifeBarUI.create()

    local x, y, w, h = 63, 50, 200, 20
    local ui = LifeBarUI.UI:new(x, y, w, h)
    ui:initialise()
    ui:addToUIManager()
    LifeBarUI.panel = ui
end

function LifeBarUI.UI:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end

function LifeBarUI.show()
    if not LifeBarUI.panel then LifeBarUI.create() end
    LifeBarUI.visible = true
    LifeBarUI.panel:setVisible(true)
end

function LifeBarUI.hide()
    if not LifeBarUI.panel then return end
    LifeBarUI.visible = false
    LifeBarUI.panel:setVisible(false)
end

Events.OnCreatePlayer.Add(function()
    LifeBarUI.create()
end)
