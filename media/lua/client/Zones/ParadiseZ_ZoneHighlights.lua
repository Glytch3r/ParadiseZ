ParadiseZ = ParadiseZ or {}
ParadiseZ.ZoneHighlightedSquares = ParadiseZ.ZoneHighlightedSquares or {}

function ParadiseZ.clearZoneHighlights()
    for i = #ParadiseZ.ZoneHighlightedSquares, 1, -1 do
        local sq = ParadiseZ.ZoneHighlightedSquares[i]
        if sq then
            local flr = sq:getFloor()
            if flr then
                flr:setHighlighted(false)
            end
        end
        table.remove(ParadiseZ.ZoneHighlightedSquares, i)
    end
end
function ParadiseZ.getZoneEdgeSquares(zName)
    if not zName then return end

    local zone = ParadiseZ.ZoneData and ParadiseZ.ZoneData[zName]
    if not zone then return {} end

    ParadiseZ.normalizeZone(zone)
    local x1, y1, x2, y2 = ParadiseZ.normalizeArea(math.floor(zone.x1), math.floor(zone.y1), math.floor(zone.x2), math.floor(zone.y2))

    local edgeSquares = {}
    
    for x = x1, x2 do
        edgeSquares[#edgeSquares+1] = {x = x, y = y1}
        edgeSquares[#edgeSquares+1] = {x = x, y = y2}
    end

    for y = y1 + 1, y2 - 1 do
        edgeSquares[#edgeSquares+1] = {x = x1, y = y}
        edgeSquares[#edgeSquares+1] = {x = x2, y = y}
    end

    return edgeSquares
end

function ParadiseZ.ZoneHighlight(x, y, zName)
    --ParadiseZ.clearZoneHighlights()
    if not ParadiseZ.ZoneHighlighter then
        if #ParadiseZ.ZoneHighlightedSquares > 0 then
            ParadiseZ.clearZoneHighlights()
        end
        return 
    end
    local pl = getPlayer()
    if not pl then return end
    
    local sq = pl:getSquare()
    if not sq then return end
    if zName == nil then
        if x and y then
            zName = ParadiseZ.getZoneName(x, y)
        else
            zName = ParadiseZ.getZoneName(pl) or ParadiseZ.getSqZoneName(sq)
        end
    end
    if not zName then return end
    if zName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return end
    local r, g, b, a = ParadiseZ.getZoneDataColor(zName)    
    local edgeSquares = ParadiseZ.getZoneEdgeSquares(zName)
    if not edgeSquares then return end

    local z = pl:getZ()

    for i = 1, #edgeSquares do
        local d = edgeSquares[i]
        local sq = getCell():getOrCreateGridSquare(d.x, d.y, z)
        if sq then
            local flr = sq:getFloor()
            if flr then
                flr:setHighlighted(true, false)
                flr:setHighlightColor(r, g, b, a)
                ParadiseZ.ZoneHighlightedSquares[#ParadiseZ.ZoneHighlightedSquares+1] = sq
            end
        end
    end
end

function ParadiseZ.dbgZoneHighlight()
    ParadiseZ.ZoneHighlight()
    timer:Simple(3, function()
        ParadiseZ.clearZoneHighlights()
    end)
end