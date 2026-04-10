ParadiseZ = ParadiseZ or {}
ParadiseZ.ZoneVisuals = ParadiseZ.ZoneVisuals or {}

ParadiseZ.ZoneVisuals.enabled = true
function ParadiseZ.ZoneVisuals.getData()
    return ModData.get("ParadiseZ_ZoneData") or {}
end

function ParadiseZ.ZoneVisuals.drawWorldMap(self)
    if not ParadiseZ.ZoneVisuals.enabled then return end

    local data = ParadiseZ.ZoneVisuals.getData()
    if not data then return end

    local isometric = self.mapAPI:getBoolean("Isometric")

    local mx = self:getMouseX()
    local my = self:getMouseY()
    local wx = self.mapAPI:uiToWorldX(mx, my)
    local wy = self.mapAPI:uiToWorldY(mx, my)

    local hoverText
    local r,g,b,a = 1,1,1,1

    for _,z in pairs(data) do
        if z.x1 and z.y1 and z.x2 and z.y2 then
            a = 0.05

            if wx and wy then
                if wx >= z.x1 and wx <= z.x2 and wy >= z.y1 and wy <= z.y2 then
                    hoverText = ParadiseZ.getZoneName(wx, wy) 
                end
            end
            local borderA =  0.2
            if hoverText then 
                borderA =  0.3
            end
            if isometric then
                local x1y1x = self.mapAPI:worldToUIX(z.x1, z.y1)
                local x1y1y = self.mapAPI:worldToUIY(z.x1, z.y1)
                local x2y1x = self.mapAPI:worldToUIX(z.x2, z.y1)
                local x2y1y = self.mapAPI:worldToUIY(z.x2, z.y1)
                local x1y2x = self.mapAPI:worldToUIX(z.x1, z.y2)
                local x1y2y = self.mapAPI:worldToUIY(z.x1, z.y2)
                local x2y2x = self.mapAPI:worldToUIX(z.x2, z.y2)
                local x2y2y = self.mapAPI:worldToUIY(z.x2, z.y2)
             
                if x1y1x and x1y1y and x2y1x and x2y1y and x2y2x and x2y2y and x1y2x and x1y2y then
                    getRenderer():renderPoly(x1y1x, x1y1y, x2y1x, x2y1y, x2y2x, x2y2y, x1y2x, x1y2y, r, g, b, borderA)
                end
            else
                local x1 = self.mapAPI:worldToUIX(z.x1, z.y1)
                local y1 = self.mapAPI:worldToUIY(z.x1, z.y1)
                local x2 = self.mapAPI:worldToUIX(z.x2, z.y2)
                local y2 = self.mapAPI:worldToUIY(z.x2, z.y2)
                
                if x1 and y1 and x2 and y2 then
                    local w = x2 - x1
                    local h = y2 - y1   
                    self:drawRect(x1, y1, w, h, borderA, r, g, b)
                    self:drawRectBorder(x1, y1, w, h, borderA, r, g, b)
                end
            end
        end
    end
    if not hoverText then
        hoverText = SandboxVars.ParadiseZ.OutsideStr
    end

    if hoverText then
        local coordStr = "\nX: "..tostring(round(wx)).."  |  Y: "..tostring(round(wy))
        local font = UIFont.Small
        if hoverText ~= SandboxVars.ParadiseZ.OutsideStr then
            font = UIFont.Large
        end

        local offsetX = SandboxVars.ParadiseZmapVisual.offsetX
        local offsetY = SandboxVars.ParadiseZmapVisual.offsetY
        local colR = SandboxVars.ParadiseZmapVisual.colR
        local colG = SandboxVars.ParadiseZmapVisual.colG
        local colB = SandboxVars.ParadiseZmapVisual.colB
        local isInvertedX = SandboxVars.ParadiseZmapVisual.isInvertedX
        local isInvertedY = SandboxVars.ParadiseZmapVisual.isInvertedY

        local drawX = mx + offsetX
        local drawY = my + offsetY

        if isInvertedX then
            drawX = mx - offsetX
        end
        if isInvertedY then
            drawY = my - offsetY
        end
        
        self:drawText(hoverText, drawX, drawY, colR, colG, colB, 1, font)
        self:drawText(tostring(coordStr), drawX, drawY + 15, colR, colG, colB, 1, UIFont.Medium)
    end

 --[[    if hoverText then
        local coordStr = "\nX: "..tostring(round(wx)).."  |  Y: "..tostring(round(wy))
        local font = UIFont.Small
        if hoverText ~= SandboxVars.ParadiseZ.OutsideStr then
            font = UIFont.Large
        end
        self:drawText(hoverText, mx+64, my-64, 1, 1, 1, 1, font)
        self:drawText(tostring(coordStr), mx+64, my-64, 1, 1, 1, 1, UIFont.Medium)
    end ]]
end

function ParadiseZ.ZoneVisuals.onRightMouseUp(self, x, y)
    local playerNum = 0
    local context = getPlayerContextMenu(playerNum)
    if not context then return end

    local option = context:addOption("Zone Visuals", self, function()
        ParadiseZ.ZoneVisuals.enabled = not ParadiseZ.ZoneVisuals.enabled
    end)
    context:setOptionChecked(option, ParadiseZ.ZoneVisuals.enabled)
end

function ParadiseZ.ZoneVisuals.hookWorldMap()
    local hookrender = ISWorldMap.render
    ISWorldMap.render = function(self, ...)
        hookrender(self, ...)
        ParadiseZ.ZoneVisuals.drawWorldMap(self)
    end

    local hookcontext = ISWorldMap.onRightMouseUp
    ISWorldMap.onRightMouseUp = function(self, x, y, ...)
        local result = hookcontext(self, x, y, ...)
        ParadiseZ.ZoneVisuals.onRightMouseUp(self, x, y)
        return result
    end
end

Events.OnCreatePlayer.Add(function()
    ParadiseZ.ZoneVisuals.hookWorldMap()
end)

