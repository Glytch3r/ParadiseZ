ParadiseZ = ParadiseZ or {}
LifeBarUI = LifeBarUI or {}

LifeBarUI.panel = nil
LifeBarUI.visible = true
LifeBarUI.maxValue = 100
LifeBarUI.flashDecayRate = 1.8

LifeBarUI.UI = ISPanel:derive("LifeBarUI_UI")

function LifeBarUI.UI:initialise()
    ISPanel.initialise(self)
end


function LifeBarUI.UI:render()
  
    local pl = getPlayer()
    if not pl then return end

    if ParadiseZ.isPvE(pl) then 
        return 
    end

    local md = pl:getModData()
    md.LifePoints = md.LifePoints or 100
    md.LifeBarFlash = md.LifeBarFlash or 0

    local life = md.LifePoints
    local w = self.width - 4
    local h = self.height - 4
    local barW = (life / LifeBarUI.maxValue) * w

    local col = ParadiseZ.getConditionRGB(life)

    self:drawRect(0, 0, w, h, 1, 0, 0, 0)
    self:drawRect(0, 0, barW, h, 1, col.r, col.g, col.b)
    self:drawRectBorder(0, 0, w, h, 1, 1, 1, 1)
    

    if md.LifeBarFlash > 0 then
        local alpha = math.min(1, md.LifeBarFlash / 100)
        self:drawRect(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight(), alpha * 0.5, 1, 0, 0, 0)
        md.LifeBarFlash = math.max(0, md.LifeBarFlash - LifeBarUI.flashDecayRate)
    end
    
    md.LifePoints = math.min(100, md.LifePoints + tonumber(SandboxVars.ParadiseZ.LifeBarRecovery))



    
end

function LifeBarUI.UI:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end

function LifeBarUI.create()
    local x, y, w, h = 68, 50, 150, 20
    local ui = LifeBarUI.UI:new(x, y, w, h)
    ui:initialise()
    ui:addToUIManager()
    LifeBarUI.panel = ui
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
    if not ParadiseZ.isPvE(getPlayer()) then
        LifeBarUI.show()
    end
end)

function ParadiseZ.getConditionRGB(condition)
    local t = condition / 100
    return {r = 1 - t, g = 0, b = t}
end


function ParadiseZ.LifeBarVisibility(pl)
    pl = pl or getPlayer()
    if not pl then return end
--[[ 
    local isOutsideZone = ParadiseZ.isOutside(pl)
    local isKosZone = ParadiseZ.isKosZone(pl) ]]
    local isPveZone = ParadiseZ.isPveZone(pl)
    local isPvePlayer = ParadiseZ.isPvE(pl)

    if isPveZone or isPvePlayer or pl:isDead() then
        LifeBarUI.hide()
    else
        LifeBarUI.show()
    end
    
end

Events.OnPlayerUpdate.Remove(ParadiseZ.LifeBarVisibility)
Events.OnPlayerUpdate.Add(ParadiseZ.LifeBarVisibility)