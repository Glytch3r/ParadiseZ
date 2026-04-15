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

function ParadiseZ.getZoneEdgeSquares(name)
    if not name then return {} end

    local x1, y1, x2, y2 = ParadiseZ.getZoneArea(name)
    if not (x1 and y1 and x2 and y2) then return {} end

    x1 = math.floor(x1)
    y1 = math.floor(y1)
    x2 = math.floor(x2)
    y2 = math.floor(y2)

    if x1 > x2 then x1, x2 = x2, x1 end
    if y1 > y2 then y1, y2 = y2, y1 end

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

function ParadiseZ.ZoneHighlight()
    ParadiseZ.clearZoneHighlights()
    
    local pl = getPlayer()
    if not pl then return end

    local sq = pl:getSquare()
    if not sq then return end

    local zName = ParadiseZ.getZoneName(pl) or ParadiseZ.getSqZoneName(sq)
    if not zName then return end
    if zName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return end
    local r, g, b, a = ParadiseZ.getZoneDataColor(zName)    
    local edgeSquares = ParadiseZ.getZoneEdgeSquares(zName)
    if not edgeSquares then return end

    local z = pl:getZ()

    for i = 1, #edgeSquares do
        local d = edgeSquares[i]
        local sq = getCell():getGridSquare(d.x, d.y, z)
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