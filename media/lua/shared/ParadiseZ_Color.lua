----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------

--client\ParadiseZ_Color.lua

ParadiseZ = ParadiseZ or {}
-----------------------            ---------------------------
function ParadiseZ.rgbToHex(r, g, b)
    r = math.floor((r or 0) * 255 + 0.5)
    g = math.floor((g or 0) * 255 + 0.5)
    b = math.floor((b or 0) * 255 + 0.5)

    return string.format("#%02x%02x%02x", r, g, b)
end


function ParadiseZ.promptColor(onDone)
    local sW = getCore():getScreenWidth()
    local sH = getCore():getScreenHeight()
    local x = sW / 2
    local y = sH / 2
    local picker = ISColorPicker:new(x, y)
    picker:initialise()
    picker:addToUIManager()

    picker:setPickedFunc(function(target, color, mouseUp)
        if not color then return end
        if onDone then
            onDone(color.r, color.g, color.b)
        end
    end)
end

function ParadiseZ.doSpawnerPicker(fType)
    ParadiseZ.promptColor(function(r, g, b)
        fType = fType or "Base.HairDyeWhite" --Base.LightBulb
        local scr = ScriptManager.instance:getItem(fType)
        local ref = InventoryItemFactory.CreateItem(fType)

        if ref and scr then
            local origR = round(255*ref:getColorRed())
            local origG = round(255*ref:getColorGreen())
            local origB = round(255*ref:getColorBlue())
            

            scr:DoParam("ColorRed = "..tostring(round(255*r)))
            scr:DoParam("ColorGreen = "..tostring(round(255*g)))
            scr:DoParam("ColorBlue = "..tostring(round(255*b)))
            
            local pl = getPlayer()
            local inv = pl:getInventory()
            local item = inv:AddItem(fType)    
            local name = ParadiseZ.rgbToHex(r, g, b)
            item:setName(name)
            
            scr:DoParam("ColorRed = "..tostring(origR))
            scr:DoParam("ColorGreen = "..tostring(origG))
            scr:DoParam("ColorBlue = "..tostring(origB))
        end
    end)
end
-----------------------            ---------------------------
ParadiseZColorPanel = ISCollapsableWindow:derive("ParadiseZColorPanel")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function ParadiseZColorPanel:HSVToRGB(h, s, v)
    local r, g, b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6

    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    else
        r, g, b = v, p, q
    end

    return r, g, b
end

function ParadiseZColorPanel:addLabel(_x, _y, _title)
    local label = ISLabel:new(_x, _y, FONT_HGT_SMALL, _title, 1, 1, 1, 1, UIFont.Small, true)
    label:initialise()
    label:instantiate()
    self:addChild(label)
    return label
end

function ParadiseZColorPanel:addSlider(_x, _y)
    local slider = ISSliderPanel:new(_x, _y, 200, 20, self, function() end)
    slider:initialise()
    slider:instantiate()
    slider:setValues(0, 100, 1, 10, true)
    self:addChild(slider)
    return slider
end

function ParadiseZColorPanel:createChildren()
    ISCollapsableWindow.createChildren(self)

    local y = self:titleBarHeight() + 15

    self:addLabel(10, y, "Hue")
    self.colorHue = self:addSlider(70, y)

    y = y + 40

    self:addLabel(10, y, "Saturation")
    self.colorSaturation = self:addSlider(70, y)

    y = y + 40

    self:addLabel(10, y, "Value")
    self.colorValue = self:addSlider(70, y)

    y = y + 30

    self.hexLabel = self:addLabel(100, y, "#FFFFFF")

    y = y + 60
    self.spawnButton = ISButton:new(10, y, 90, 25, "Spawn", self, function() ParadiseZColorPanel.onSpawn(self) end)
    self.spawnButton:initialise()
    self.spawnButton:instantiate()
    self:addChild(self.spawnButton)

    self.randomButton = ISButton:new(110, y, 90, 25, "Random", self, self.onRandom)
    self.randomButton:initialise()
    self.randomButton:instantiate()
    self:addChild(self.randomButton)

    self.closeButton = ISButton:new(200, y, 90, 25, "Picker", self, function() 
        ParadiseZ.closeHSVPanel()
        ParadiseZ.doSpawnerPicker(self.fType)
    end)

    self.closeButton:initialise()
    self.closeButton:instantiate()
    self:addChild(self.closeButton)

    self.colorHue:setCurrentValue(0)
    self.colorSaturation:setCurrentValue(100)
    self.colorValue:setCurrentValue(100)
end

function ParadiseZColorPanel:onRandom()
    self.colorHue:setCurrentValue(ZombRand(0, 101))
    self.colorSaturation:setCurrentValue(ZombRand(0, 101))
    self.colorValue:setCurrentValue(ZombRand(0, 101))
end

function ParadiseZColorPanel:onSpawn()
    local h = self.colorHue.currentValue / 100
    local s = self.colorSaturation.currentValue / 100
    local v = self.colorValue.currentValue / 100

    local r, g, b = self:HSVToRGB(h, s, v)

    local fType = self.fType
    local scr = ScriptManager.instance:getItem(fType)
    local ref = InventoryItemFactory.CreateItem(fType)

    if ref and scr then
        local origR = round(255 * ref:getColorRed())
        local origG = round(255 * ref:getColorGreen())
        local origB = round(255 * ref:getColorBlue())

        scr:DoParam("ColorRed = "..tostring(round(255 * r)))
        scr:DoParam("ColorGreen = "..tostring(round(255 * g)))
        scr:DoParam("ColorBlue = "..tostring(round(255 * b)))

        local pl = getPlayer()
        local item = pl:getInventory():AddItem(fType)

        if item then
            item:setName(ParadiseZ.rgbToHex(r, g, b))
        end

        scr:DoParam("ColorRed = "..tostring(origR))
        scr:DoParam("ColorGreen = "..tostring(origG))
        scr:DoParam("ColorBlue = "..tostring(origB))
    end
end

function ParadiseZColorPanel:prerender()
    ISCollapsableWindow.prerender(self)

    local h = self.colorHue.currentValue / 100
    local s = self.colorSaturation.currentValue / 100
    local v = self.colorValue.currentValue / 100

    local r, g, b = self:HSVToRGB(h, s, v)

    self.hexLabel.name = ParadiseZ.rgbToHex(r, g, b)

    self:drawRect(10, 160, 270, 40, 1, r, g, b)
    self:drawRectBorder(10, 160, 270, 40, 1, 1, 1, 1)
end

function ParadiseZColorPanel:new(fType)
    local width = 300
    local height = 240

    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2
    fType = fType or "Base.HairDyeWhite" -- "Base.LightBulb"
    local o = ISCollapsableWindow:new(x, y, width, height, fType)

    setmetatable(o, self)
    self.__index = self
    o.fType = tostring(fType)
    o.title = tostring(fType).." HSV Spawner"
    o:setResizable(false)

    return o
end
-----------------------            ---------------------------
function ParadiseZ.openHSVPanel(fType)
    ParadiseZ.closeHSVPanel()
    if not ParadiseZ.colorPanel then
        ParadiseZ.colorPanel = ParadiseZColorPanel:new(fType)
        ParadiseZ.colorPanel:initialise()
        ParadiseZ.colorPanel:addToUIManager()
    end

    ParadiseZ.colorPanel:setVisible(true)
    ParadiseZ.colorPanel:bringToTop()
end

function ParadiseZ.closeHSVPanel()
    if ParadiseZ.colorPanel then
        ParadiseZ.colorPanel:setVisible(false)
        ParadiseZ.colorPanel:removeFromUIManager()
        ParadiseZ.colorPanel = nil
    end
end
-----------------------            ---------------------------

function ParadiseZ.doColoredSpawner()
    if ParadiseZ.colorPanel and ParadiseZ.colorPanel:getIsVisible() then
        ParadiseZ.colorPanel:setVisible(true)
        return
    end

    ParadiseZ.colorPanel = ParadiseZColorPanel:new()
    ParadiseZ.colorPanel:initialise()
    ParadiseZ.colorPanel:addToUIManager()
end
-----------------------            ---------------------------
ParadiseZ.ZoneColorList = {
    HQ = { r = 0, g = 0, b = 1 },
    Outside = { r = 1, g = 0.4, b = 0 },
    Zone = { r = 1, g = 1, b = 1 },
    NonPvp = { r = 0, g = 1, b = 0 },
    PvP = { r = 0.9, g = 0.2, b = 0.2 },
    Blocked = { r = 0.13, g = 0.13, b = 0.13 },
    Protected = { r = 0.84, g = 0.76, b = 0.67 },
    Radiation = { r = 1, g = 1, b = 1 },
    Hunt = { r = 1, g = 0, b = 0 },
    Blaze = { r = 1, g = 0, b = 0 },
    Frost = { r = 0.5, g = 0.4, b = 1 },
    Bomb = { r = 1, g = 0, b = 0 },
    MineField = { r = 1, g = 0, b = 0 },
    NoCamp = { r = 0.7, g = 0.7, b = 0.7 },
    NoFire = { r = 0.8, g = 0.8, b = 0.8 },
    Cage = { r = 0.7, g = 0.7, b = 0.7 },
    Party = { r = 1, g = 1, b = 0.6 },
    Rally = { r = 0, g = 1, b = 0 },
    Special = { r = 0.9, g = 0.4, b = 0.9 },
    Trade = { r = 0, g = 1, b = 0 },
    Sprint = { r = 1, g = 0.7, b = 0.7 },
}

ParadiseZ.colorValues = {
    { r = 0.5, g = 0.5, b = 0.5 }, --1 Gray
    { r = 1, g = 0, b = 0 },       --2 Red
    { r = 1, g = 0.5, b = 0 },     --3 Orange
    { r = 1, g = 1, b = 0 },       --4 Yellow
    { r = 0, g = 1, b = 0 },       --5 Green
    { r = 0, g = 0, b = 1 },       --6 Blue
    { r = 0.5, g = 0, b = 0.5 },   --7 Purple
    { r = 0, g = 0, b = 0 },       --8 Black
    { r = 1, g = 1, b = 1 },       --9 White
    { r = 1, g = 0.75, b = 0.8 },  --10 Pink
}

function ParadiseZ.getFloatColor(col)
    if not col then return end
    return col / 255
end

function ParadiseZ.getIntColor(col)
    if not col then return end
    return math.floor(col * 255)
end

function ParadiseZ.getZoneSandboxColor(zoneType)
    local colorIndex = 9
    if zoneType == "HQ" then
        colorIndex = SandboxVars.ParadiseZcolor.HQ or 9
    elseif zoneType == "Outside" then
        colorIndex = SandboxVars.ParadiseZcolor.Outside or 9
    elseif zoneType == "NonPvp" then
        colorIndex = SandboxVars.ParadiseZcolor.NonPvp or 9
    elseif zoneType == "KoS" then
        colorIndex = SandboxVars.ParadiseZcolor.PvP or 9
    elseif zoneType == "Blocked" then
        colorIndex = SandboxVars.ParadiseZcolor.Blocked or 9
    elseif zoneType == "Protected" then
        colorIndex = SandboxVars.ParadiseZcolor.Protected or 9
    elseif zoneType == "Radiation" then
        colorIndex = SandboxVars.ParadiseZcolor.Radiation or 9
    elseif zoneType == "Hunt" then
        colorIndex = SandboxVars.ParadiseZcolor.Hunt or 9
    elseif zoneType == "Blaze" then
        colorIndex = SandboxVars.ParadiseZcolor.Blaze or 9
    elseif zoneType == "Frost" then
        colorIndex = SandboxVars.ParadiseZcolor.Frost or 9
    elseif zoneType == "Bomb" then
        colorIndex = SandboxVars.ParadiseZcolor.Bomb or 9
    elseif zoneType == "MineField" then
        colorIndex = SandboxVars.ParadiseZcolor.MineField or 9
    elseif zoneType == "NoCamp" then
        colorIndex = SandboxVars.ParadiseZcolor.NoCamp or 9
    elseif zoneType == "NoFire" then
        colorIndex = SandboxVars.ParadiseZcolor.NoFire or 9
    elseif zoneType == "Cage" then
        colorIndex = SandboxVars.ParadiseZcolor.Cage or 9
    elseif zoneType == "Party" then
        colorIndex = SandboxVars.ParadiseZcolor.Party or 9
    elseif zoneType == "Rally" then
        colorIndex = SandboxVars.ParadiseZcolor.Rally or 9
    elseif zoneType == "Special" then
        colorIndex = SandboxVars.ParadiseZcolor.Special or 9
    elseif zoneType == "Trade" then
        colorIndex = SandboxVars.ParadiseZcolor.Trade or 9
    elseif zoneType == "Sprint" then
        colorIndex = SandboxVars.ParadiseZcolor.Sprint or 9
    else
        colorIndex = SandboxVars.ParadiseZcolor.Typeless or 6        
    end
    
    if colorIndex == 11 then
        return 0, 0, 0, 0
    end
    
    local color = ParadiseZ.colorValues[colorIndex] or ParadiseZ.colorValues[9]
    return color.r, color.g, color.b, 1
end

function ParadiseZ.getZoneDataColor(zName)
    local zData = ParadiseZ.ZoneData and ParadiseZ.ZoneData[zName]
    if not zData then return 1,1,1,1 end

    local colorIndex = 9

    if zData.isKos then
        colorIndex = SandboxVars.ParadiseZcolor.PvP or 9
    elseif zData.isBlocked then
        colorIndex = SandboxVars.ParadiseZcolor.Blocked or 9
    elseif zData.isPvE then
        colorIndex = SandboxVars.ParadiseZcolor.NonPvp or 9
    elseif zData.isSpecial then
        colorIndex = SandboxVars.ParadiseZcolor.Special or 9
    elseif zData.isCage then
        colorIndex = SandboxVars.ParadiseZcolor.Cage or 9
    elseif zData.isHQ then
        colorIndex = SandboxVars.ParadiseZcolor.HQ or 9
    elseif zData.isOutside then
        colorIndex = SandboxVars.ParadiseZcolor.Outside or 9
    elseif zData.isProtected then
        colorIndex = SandboxVars.ParadiseZcolor.Protected or 9
    elseif zData.isRadiation then
        colorIndex = SandboxVars.ParadiseZcolor.Radiation or 9
    elseif zData.isHunt then
        colorIndex = SandboxVars.ParadiseZcolor.Hunt or 9
    elseif zData.isBlaze then
        colorIndex = SandboxVars.ParadiseZcolor.Blaze or 9
    elseif zData.isFrost then
        colorIndex = SandboxVars.ParadiseZcolor.Frost or 9
    elseif zData.isBomb then
        colorIndex = SandboxVars.ParadiseZcolor.Bomb or 9
    elseif zData.isMineField then
        colorIndex = SandboxVars.ParadiseZcolor.MineField or 9
    elseif zData.isNoCamp then
        colorIndex = SandboxVars.ParadiseZcolor.NoCamp or 9
    elseif zData.isNoFire then
        colorIndex = SandboxVars.ParadiseZcolor.NoFire or 9
    elseif zData.isParty then
        colorIndex = SandboxVars.ParadiseZcolor.Party or 9
    elseif zData.isRally then
        colorIndex = SandboxVars.ParadiseZcolor.Rally or 9
    elseif zData.isTrade then
        colorIndex = SandboxVars.ParadiseZcolor.Trade or 9
    elseif zData.isSprint then
        colorIndex = SandboxVars.ParadiseZcolor.Sprint or 9
    else
        colorIndex = SandboxVars.ParadiseZcolor.Typeless or 6
    end
    
    if colorIndex == 11 then
        return 1,1,1,1
    end

    local color = ParadiseZ.colorValues[colorIndex] or ParadiseZ.colorValues[9]
    return color.r, color.g, color.b, 1
end
--[[ 
function ParadiseZ.parseColor()
    if ParadiseZ.RoomLight then
        return ParadiseZ.RoomLight[1], ParadiseZ.RoomLight[2], ParadiseZ.RoomLight[3], ParadiseZ.RoomLight[4] 
    end

    local strList = SandboxVars.ParadiseZ.RoomLight or "255;255;255;255"
    local r, g, b, a = strList:match("^(%d+);(%d+);(%d+);(%d+)$")
    r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)

    ParadiseZ.RoomLight = { r, g, b, a }
    return r, g, b, a
end

 ]]