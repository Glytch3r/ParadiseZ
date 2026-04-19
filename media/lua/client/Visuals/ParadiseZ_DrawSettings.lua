
require "ISUI/ISSliderPanel"

ParadiseZ = ParadiseZ or {}
local hook = ISUserPanelUI.create
function ISUserPanelUI:create()
    hook(self)
    local pl = getPlayer()
    if not pl then return end
    local md = pl:getModData()
    md.HUDSettings = md.HUDSettings or { 
        x = 68,
        y = 73,
    }
    
    local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
    local btnWid = 150
    local btnHgt = math.max(18, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10
    local sliderX = self.showPingInfo.x
    local sliderY = self.showPingInfo.y + btnHgt + 5
    
    self.HUDScrollX = ISSliderPanel:new(sliderX, sliderY, btnWid, btnHgt, self, function(target, value)
        md.HUDSettings.x = value
    end)
    self.HUDScrollX:initialise()
    self.HUDScrollX:instantiate()
    self.HUDScrollX.currentValue = md.HUDSettings.x
    self.HUDScrollX:setValues(0, getCore():getScreenWidth(), 1, 10)
    --self.HUDScrollX:setCurrentValue(md.HUDSettings.x, true)
    self:addChild(self.HUDScrollX)
    
    self.HUDScrollY = ISSliderPanel:new(sliderX, sliderY + btnHgt + 5, btnWid, btnHgt, self, function(target, value)
        md.HUDSettings.y = value
    end)
    self.HUDScrollY:initialise()
    self.HUDScrollY:instantiate()
    self.HUDScrollY.currentValue = md.HUDSettings.y
    self.HUDScrollY:setValues(0, getCore():getScreenHeight(), 1, 10)
    --self.HUDScrollY:setCurrentValue(md.HUDSettings.y, true)
    self:addChild(self.HUDScrollY)
end