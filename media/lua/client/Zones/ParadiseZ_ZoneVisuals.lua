ParadiseZ = ParadiseZ or {}
ParadiseZ.ZoneVisuals = ParadiseZ.ZoneVisuals or {}

ParadiseZ.ZoneVisuals.enabled = true
ParadiseZ.ZoneVisuals.highlight = true

function ParadiseZ.ZoneVisuals.getData()
    return ModData.get("ParadiseZ_ZoneData") or {}
end

function ParadiseZ.ZoneVisuals.drawWorldMap(self)

    local data = ParadiseZ.ZoneVisuals.getData()
    if not data then return end

    local isometric = self.mapAPI:getBoolean("Isometric")

    local mx = self:getMouseX()
    local my = self:getMouseY()
    local wx = self.mapAPI:uiToWorldX(mx, my)
    local wy = self.mapAPI:uiToWorldY(mx, my)

    local zName

    for _,z in pairs(data) do
        if z.x1 and z.y1 and z.x2 and z.y2 then
            if ParadiseZ.ZoneVisuals.enabled then

                local isHovered = false

                if wx and wy then
                    if wx >= z.x1 and wx <= z.x2 and wy >= z.y1 and wy <= z.y2 then
                        isHovered = true
                        zName = ParadiseZ.getZoneName(wx, wy)
                    end
                end

                local r,g,b,a = ParadiseZ.getZoneDataColor(z.zoneName or z.name)
                if not r or not g or not b then
                    r,g,b,a = 1,1,1,1
                end

                local fillA = 0.05
                local borderA = 0.2
                local borderThickness = 1

                if isHovered then
                    fillA = 0.05
                    borderA = 0.8
                    borderThickness = 2
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
                        getRenderer():renderPoly(
                            x1y1x, x1y1y,
                            x2y1x, x2y1y,
                            x2y2x, x2y2y,
                            x1y2x, x1y2y,
                            r, g, b, fillA
                        )

                        if ParadiseZ.ZoneVisuals.highlight then
                            for i=1,borderThickness do
                                local off = i * 0.5
                                getRenderer():renderPoly(
                                    x1y1x-off, x1y1y-off,
                                    x2y1x+off, x2y1y-off,
                                    x2y2x+off, x2y2y+off,
                                    x1y2x-off, x1y2y+off,
                                    r, g, b, borderA
                                )
                            end
                        end
                    end
                else
                    local x1 = self.mapAPI:worldToUIX(z.x1, z.y1)
                    local y1 = self.mapAPI:worldToUIY(z.x1, z.y1)
                    local x2 = self.mapAPI:worldToUIX(z.x2, z.y2)
                    local y2 = self.mapAPI:worldToUIY(z.x2, z.y2)

                    if x1 and y1 and x2 and y2 then
                        local w = x2 - x1
                        local h = y2 - y1

                        self:drawRect(x1, y1, w, h, fillA, r, g, b)

                        if ParadiseZ.ZoneVisuals.highlight then
                            for i=1,borderThickness do
                                self:drawRectBorder(
                                    x1-i, y1-i,
                                    w+(i*2), h+(i*2),
                                    borderA, r, g, b
                                )
                            end
                        end
                    end
                end
            end
        end
    end

    if not zName then
        zName = SandboxVars.ParadiseZ.OutsideStr
    end

    if zName then
        local coordStr = "\nX: "..tostring(round(wx)).."  |  Y: "..tostring(round(wy))
        local font = UIFont.Small
        if zName ~= SandboxVars.ParadiseZ.OutsideStr then
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

        if isInvertedX then drawX = mx - offsetX end
        if isInvertedY then drawY = my - offsetY end

        if ParadiseZ.ZoneVisuals.enabled2 then
            self:drawText(zName, drawX, drawY, colR, colG, colB, 1, font)
            self:drawText(tostring(coordStr), drawX, drawY + 15, colR, colG, colB, 1, UIFont.Medium)
        end
    end
end

function ParadiseZ.ZoneVisuals.onRightMouseUp(self, x, y)
    local playerNum = 0
    local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())
    if not context then return end


end

function ParadiseZ.ZoneVisuals.hookWorldMap()
    local hookrender = ISWorldMap.render
    ISWorldMap.render = function(self, ...)
        hookrender(self, ...)
        ParadiseZ.ZoneVisuals.drawWorldMap(self)
    end

    function ISWorldMap:onRightMouseUp(x, y)
        if self.symbolsUI:onRightMouseUpMap(x, y) then
            return true
        end
        
        local isNotAllowed = not (isClient() and (getAccessLevel() == "admin"))
        
        local playerNum = 0
        local playerObj = getSpecificPlayer(0)
        if not playerObj then return end 
        local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())

        if not isNotAllowed then
            local option = context:addOption("Show Cell Grid", self, function(self) self:setShowCellGrid(not self.showCellGrid) end)
            context:setOptionChecked(option, self.showCellGrid)

            option = context:addOption("Show Tile Grid", self, function(self) self:setShowTileGrid(not self.showTileGrid) end)
            context:setOptionChecked(option, self.showTileGrid)

            self.hideUnvisitedAreas = self.mapAPI:getBoolean("HideUnvisited")
            option = context:addOption("Hide Unvisited Areas", self, function(self) self:setHideUnvisitedAreas(not self.hideUnvisitedAreas) end)
            context:setOptionChecked(option, self.hideUnvisitedAreas)

            option = context:addOption("Isometric", self, function(self) self:setIsometric(not self.isometric) end)
            context:setOptionChecked(option, self.isometric)

            option = context:addOption("Reapply Style", self, function(self)
                MapUtils.initDefaultStyleV1(self)
                MapUtils.overlayPaper(self)
            end)
        end

        local option = context:addOption("Zone Visuals", self, function()
            ParadiseZ.ZoneVisuals.enabled = not ParadiseZ.ZoneVisuals.enabled
        end)
        context:setOptionChecked(option, ParadiseZ.ZoneVisuals.enabled)

        option = context:addOption("Map Tooltip", self, function()
            ParadiseZ.ZoneVisuals.enabled2 = not ParadiseZ.ZoneVisuals.enabled2
        end)
        context:setOptionChecked(option, ParadiseZ.ZoneVisuals.enabled2)

        option = context:addOption("Zone Highlight", self, function()
            ParadiseZ.ZoneVisuals.highlight = not ParadiseZ.ZoneVisuals.highlight
        end)
        context:setOptionChecked(option, ParadiseZ.ZoneVisuals.highlight)
        
        if not isNotAllowed then
            local worldX = self.mapAPI:uiToWorldX(x, y)
            local worldY = self.mapAPI:uiToWorldY(x, y)
            if getWorld():getMetaGrid():isValidChunk(worldX / 10, worldY / 10) then
                option = context:addOption("Teleport Here", self, self.onTeleport, worldX, worldY)
            end
        end

        return true
    end

end
Events.OnCreatePlayer.Add(function()
    ParadiseZ.ZoneVisuals.hookWorldMap()
end)