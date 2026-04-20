ParadiseZ = ParadiseZ or {}

local ticks = 0

function ParadiseZ.cageHandler(pl)
    if not pl then return end
    if not pl:isAlive() then return end

    ticks = ticks + 1
    if ticks % 3 ~= 0 then return end

    local isCagedPl = ParadiseZ.isCagedPl(pl)
    local md = pl:getModData()
    local hasCageReturn = md['CageReturn'] ~= nil
    
    if isCagedPl and not hasCageReturn then
        local plx, ply, plz = round(pl:getX()), round(pl:getY()), pl:getZ()
        local zName = ParadiseZ.getZoneName(plx, ply)
        ParadiseZ.saveCageReturn(pl, zName)
    elseif not isCagedPl and hasCageReturn then
        local x, y, z = ParadiseZ.getCageReturn(pl)
        md['CageReturn'] = nil
        ParadiseZ.doRegularTp(pl, x, y, z)
        return
    end
    
    if not isCagedPl then
        return
    end

    local plx, ply, plz = round(pl:getX()), round(pl:getY()), pl:getZ()
    local zName = ParadiseZ.getZoneName(plx, ply)
    local cageZone = ParadiseZ.getCurrentCageZone(plx, ply)

    if not cageZone then
        local x, y, z = ParadiseZ.getClosestCageZoneCenter()
        if not x or not y or not z then
            x, y, z = ParadiseZ.parseCageCoords(false)
        end
        ParadiseZ.doRegularTp(pl, x, y, z)
        return
    end

    if ParadiseZ.isXYZoneOuter(plx, ply, cageZone, 3) then
        local x, y, z = ParadiseZ.getCageRebound(pl)
        if not x or not y or not z then
            local cx, cy = ParadiseZ.getZoneCenter(cageZone)
            if cx and cy then
                x, y, z = cx, cy, plz
            else
                x, y, z = ParadiseZ.parseCageCoords(false)
            end
        end
        ParadiseZ.doRegularTp(pl, x, y, z)
    else
        ParadiseZ.saveCageRebound(pl, cageZone)
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.cageHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.cageHandler)

function ParadiseZ.getCurrentCageZone(x, y)
    if not x or not y then return nil end
    for zName, data in pairs(ParadiseZ.ZoneData) do
        if data.isCage and ParadiseZ.isXYInsideZone(x, y, zName) then
            return zName
        end
    end
    return nil
end

function ParadiseZ.getClosestCageZoneCenter()
    local pl = getPlayer()
    if not pl then return nil, nil, nil end
    local plx, ply = round(pl:getX()), round(pl:getY())
    
    local closestDist = math.huge
    local closestX, closestY = nil, nil
    
    for zName, data in pairs(ParadiseZ.ZoneData) do
        if data.isCage then
            local cx, cy = ParadiseZ.getZoneCenter(zName)
            if cx and cy then
                local dist = math.sqrt((plx - cx) ^ 2 + (ply - cy) ^ 2)
                if dist < closestDist then
                    closestDist = dist
                    closestX, closestY = cx, cy
                end
            end
        end
    end
    
    if closestX and closestY then
        return closestX, closestY, getPlayer():getZ()
    end
    return nil, nil, nil
end

function ParadiseZ.getZoneCenter(name)
    local data = ParadiseZ.ZoneData and ParadiseZ.ZoneData[name]
    if not data then return nil, nil end

    local minX = math.min(data.x1, data.x2)
    local maxX = math.max(data.x1, data.x2)
    local minY = math.min(data.y1, data.y2)
    local maxY = math.max(data.y1, data.y2)

    return (minX + maxX) / 2, (minY + maxY) / 2
end

function ParadiseZ.isCagedPl(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return pl:getTraits():contains("Caged")
end

function ParadiseZ.setCaged(targUser, bool)
    if not targUser then return end
    local targPl = getPlayerFromUsername(targUser)
    if not targPl then return end
    if bool then
        targPl:getTraits():add("Caged")
    else
        targPl:getTraits():remove("Caged")
    end
    SyncXp(targPl)
end

function ParadiseZ.parseCageCoords(isReturn)
    local strList = SandboxVars.ParadiseZ.DefaultCageCoords
    if isReturn then
        strList = SandboxVars.ParadiseZ.DefaultCageReturnCoords
    end
    local tx, ty, tz = strList:match("^(-?%d+)[;:](-?%d+)[;:](-?%d+)")
    tx, ty, tz = tonumber(tx), tonumber(ty), tonumber(tz)
    return tx, ty, tz
end

function ParadiseZ.saveCageReturn(pl, zName, isInit)
    pl = pl or getPlayer()
    if not pl then return nil end
    
    local sq = pl:getCurrentSquare()
    if not sq then return nil end
    local sx, sy = sq:getX(), sq:getY()

    zName = zName or ParadiseZ.getZoneName(pl)
    local md = pl:getModData()
    
    local tab = {
        name = zName,
        x = round(sx),
        y = round(sy),
        z = pl:getZ(),
        ax = ParadiseZ.roundN(pl:getX(), 3),
        ay = ParadiseZ.roundN(pl:getY(), 3)
    }

    if isInit then
        local x, y, z = ParadiseZ.parseCageCoords(true)
        zName = ParadiseZ.getZoneName(x, y)
        tab = {
            name = zName,
            x = round(x),
            y = round(y),
            z = z,
            ax = ParadiseZ.roundN(x, 3),
            ay = ParadiseZ.roundN(y, 3)
        }
    end

    md['CageReturn'] = tab
    return tab
end

function ParadiseZ.saveCageRebound(pl, name)
    pl = pl or getPlayer()
    if not pl then return nil end
    local sq = pl:getCurrentSquare()
    if not sq then return nil end
    local sx, sy = sq:getX(), sq:getY()
    name = name or ParadiseZ.getZoneName(pl)
    local md = pl:getModData()
    if ParadiseZ.isXYZoneInner(sx, sy, name) then
        local tab = {
            name = name,
            x = round(sx),
            y = round(sy),
            z = pl:getZ(),
            ax = ParadiseZ.roundN(pl:getX(), 3),
            ay = ParadiseZ.roundN(pl:getY(), 3)
        }
        md['CageRebound'] = tab
        return tab
    end
    return nil
end

function ParadiseZ.getCageRebound(pl)
    pl = pl or getPlayer()
    if not pl then return nil, nil, nil end
    local md = pl:getModData()
    local rebound = md['CageRebound']
    if rebound and rebound.x and rebound.y and rebound.z then
        return rebound.x, rebound.y, rebound.z
    end
    local x, y, z = ParadiseZ.parseCageCoords(false)
    return x, y, z
end

function ParadiseZ.getCageReturn(pl)
    pl = pl or getPlayer()
    if not pl then return nil, nil, nil end
    local md = pl:getModData()
    local rebound = md['CageReturn']
    if rebound and rebound.x and rebound.y and rebound.z then
        return rebound.x, rebound.y, rebound.z
    end
    local x, y, z = ParadiseZ.parseCageCoords(true)
    return x, y, z
end