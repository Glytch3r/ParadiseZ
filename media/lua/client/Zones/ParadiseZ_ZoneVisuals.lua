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

    for _,z in pairs(data) do
        if z.x1 and z.y1 and z.x2 and z.y2 then
            local r,g,b,a = ParadiseZ.getColor(z)
            a = 0.05

            if wx and wy then
                if wx >= z.x1 and wx <= z.x2 and wy >= z.y1 and wy <= z.y2 then
                    hoverText = ParadiseZ.getZoneName(wx, wy)
                end
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
                    getRenderer():renderPoly(x1y1x, x1y1y, x2y1x, x2y1y, x2y2x, x2y2y, x1y2x, x1y2y, r, g, b, a)
                end
            else
                local x1 = self.mapAPI:worldToUIX(z.x1, z.y1)
                local y1 = self.mapAPI:worldToUIY(z.x1, z.y1)
                local x2 = self.mapAPI:worldToUIX(z.x2, z.y2)
                local y2 = self.mapAPI:worldToUIY(z.x2, z.y2)
                
                if x1 and y1 and x2 and y2 then
                    local w = x2 - x1
                    local h = y2 - y1
                    
                    self:drawRect(x1, y1, w, h, a, r, g, b)
                    self:drawRectBorder(x1, y1, w, h, 0.2, r, g, b)
                end
            end
        end
    end

    if hoverText then
        self:drawText(hoverText, mx + 12, my + 12, 1, 1, 1, 1, UIFont.Small)
    end
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