ParadiseZ = ParadiseZ or {}


function ParadiseZ.isPlayerInArea(x1, y1, x2, y2, pl)
    local targ = ParadiseZ.getPlOrSq(pl)
    if not targ then return false end
    local px, py = ParadiseZ.getXY(targ)
    if not px or not py then return false end
    local minX, maxX = math.min(x1, x2), math.max(x1, x2)
    local minY, maxY = math.min(y1, y2), math.max(y1, y2)
    return px >= minX and px <= maxX and py >= minY and py <= maxY
end

function ParadiseZ.normalizeZone(zone)
    if not zone then return end

    local x1 = tonumber(zone.x1)
    local y1 = tonumber(zone.y1)
    local x2 = tonumber(zone.x2)
    local y2 = tonumber(zone.y2)
    if not (x1 and y1 and x2 and y2) then return end

    if x1 > x2 then x1, x2 = x2, x1 end
    if y1 > y2 then y1, y2 = y2, y1 end

    zone.x1 = x1
    zone.y1 = y1
    zone.x2 = x2
    zone.y2 = y2
end

function ParadiseZ.normalizeArea(x1, y1, x2, y2)
    x1 = tonumber(x1)
    y1 = tonumber(y1)
    x2 = tonumber(x2)
    y2 = tonumber(y2)
    if not (x1 and y1 and x2 and y2) then return end

    if x1 > x2 then x1, x2 = x2, x1 end
    if y1 > y2 then y1, y2 = y2, y1 end

    return x1, y1, x2, y2
end

function ParadiseZ.normalizeAllZones(data)
    data = data or ParadiseZ.ZoneData
    for _, z in pairs(data) do
        ParadiseZ.normalizeZone(z)
    end
    return data
end

function ParadiseZ.getZoneArea(name)
    if not name or name == tostring(SandboxVars.ParadiseZ.OutsideStr) then return nil, nil, nil, nil end

    local zone = ParadiseZ.ZoneData[name]
    if not zone then return nil, nil, nil, nil end

    return ParadiseZ.normalizeArea(zone.x1, zone.y1, zone.x2, zone.y2)
end

function ParadiseZ.isXYInsideZone(x, y, zName)
    if not x or not y then return false end

    zName = zName or ParadiseZ.getZoneName(x, y)
    if zName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end

    local nX1, nY1, nX2, nY2 = ParadiseZ.getZoneArea(zName)
    if not nX1 then return false end

    return x >= nX1 and x <= nX2 and y >= nY1 and y <= nY2
end

function ParadiseZ.isXYZoneOuter(x, y, zName, margin)
    margin = margin or 3
    if not x or not y then return false end
    zName = zName or ParadiseZ.getZoneName(x, y)  
    local nX1, nY1, nX2, nY2 = ParadiseZ.getZoneArea(zName)
    if not nX1 then return false end

    if not (x >= nX1 and x <= nX2 and y >= nY1 and y <= nY2) then return false end

    local m = margin - 1

    return x <= nX1 + m
        or x >= nX2 - m
        or y <= nY1 + m
        or y >= nY2 - m
end

function ParadiseZ.isXYZoneInner(x, y, zName, margin)
    if not x or not y then return false end
    zName = zName or ParadiseZ.getZoneName(x, y)  
    if not ParadiseZ.isXYInsideZone(x, y, zName) then return false end
    return not ParadiseZ.isXYZoneOuter(x, y, zName, margin)
end