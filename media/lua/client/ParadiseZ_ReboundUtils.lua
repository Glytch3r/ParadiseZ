--ParadiseZ_Rebound.lua
ParadiseZ = ParadiseZ or {}

function ParadiseZ.forceExitCar()
  --[[   if not SandboxVars.ParadiseZ.ReboundExitsCar then return end
    ISVehicleMenu.onExit(getPlayer()) ]]
    
    local pl = getPlayer()
    if not pl then return end
    local car = pl:getVehicle()
    if not car then return end
    
    local seat = car:getSeat(pl)
    car:exit(pl)
    if seat then
        car:setCharacterPosition(pl, seat, tostring(SandboxVars.ParadiseZ.OutsideStr))
    end
    
    pl:PlayAnim("Idle")
    triggerEvent("OnExitVehicle", pl)
    car:updateHasExtendOffsetForExitEnd(pl)
end

function ParadiseZ.tp(pl, x, y, z)
    pl = pl or getPlayer()
    if not pl then return end
    z = z or 0
    if not (x and y and z) then return end

    x = tonumber(x)
    y = tonumber(y)
    z = tonumber(z)

    local sq = getCell():getOrCreateGridSquare(x, y, z)

    if getCore():getDebug() then
        if sq and not ParadiseZ.isTempMarkerActive() then
            ParadiseZ.addTempMarker(sq)
        end
    end

    if not SandboxVars.ParadiseZ.ReboundSystem then return end

    ParadiseZ.tpTarg = { x = x, y = y, z = z }
    ParadiseZ.tpPl = pl
    ParadiseZ.tpTry = 0

    if not ParadiseZ.tpListener then
        ParadiseZ.tpListener = true
        Events.OnPlayerUpdate.Add(ParadiseZ.tpCheck)
    end

    ParadiseZ.doTp(pl, x, y, z)
end

function ParadiseZ.doTp(pl, x, y, z)
    if luautils.stringStarts(getCore():getVersion(), "42") then
        pl:teleportTo(x, y, z)
    else
        pl:setX(x)
        pl:setY(y)
        pl:setZ(z)
        if isClient() then
            pl:setLx(x)
            pl:setLy(y)
            pl:setLz(z)
        end
    end
end

function ParadiseZ.tpCheck(pl)
    local data = ParadiseZ.tpTarg
    local targetPl = ParadiseZ.tpPl

    if not data or not targetPl or pl ~= targetPl then return end

    local cx = math.floor(pl:getX())
    local cy = math.floor(pl:getY())
    local cz = math.floor(pl:getZ())

    if cx ~= data.x or cy ~= data.y or cz ~= data.z then
        ParadiseZ.tpTry = ParadiseZ.tpTry + 1

        if ParadiseZ.tpTry <= 10 then
            ParadiseZ.doTp(pl, data.x, data.y, data.z)
        else
            ParadiseZ.tpCleaner()
        end
    else
        ParadiseZ.tpCleaner()
    end
end

function ParadiseZ.tpCleaner()
    if ParadiseZ.tpListener then
        Events.OnPlayerUpdate.Remove(ParadiseZ.tpCheck)
        ParadiseZ.tpListener = nil
    end
    ParadiseZ.tpTarg = nil
    ParadiseZ.tpPl = nil
    ParadiseZ.tpTry = nil
end
--[[
function ParadiseZ.getClosestReboundPoint(origin, margin)
    margin = margin or 4
    local pl = getPlayer()
    if not pl then return nil, nil, nil end
    local cell = pl:getCell()
    local ox, oy, oz = origin and origin:getX() or pl:getX(), origin and origin:getY() or pl:getY(), origin and origin:getZ() or pl:getZ()
    local originZone = ParadiseZ.getZoneName(origin)
    local rad = 30
    local maxRad = 6000000
    
    while rad <= maxRad do
        for xDelta = -rad, rad do
            for yDelta = -rad, rad do
                local testSq = cell:getOrCreateGridSquare(ox + xDelta, oy + yDelta, oz)
                if testSq and not ParadiseZ.isRestricted(testSq, pl) then
                    
                    if not ParadiseZ.isSameZone(pl, testSq) then                             
                        local dx, dy = testSq:getX() - ox, testSq:getY() - oy
                        local dist = math.sqrt(dx*dx + dy*dy)
                        local zoneName = ParadiseZ.getZoneName(testSq)
                        if zoneName and dist >= margin and (ParadiseZ.isOutsideSq(testSq) or (not ParadiseZ.ZoneData[zoneName] or not ParadiseZ.ZoneData[zoneName].isBlocked)) then
                            return testSq:getX(), testSq:getY(), testSq:getZ()
                        end
                    end
                end
            end
        end
        rad = rad + 5
    end

    return ox, oy, oz
end
 ]]
--[[ 

function ParadiseZ.findReboundPoint(pl, originSq, outward)
    outward = outward or 4
    if not pl or not originSq then return nil end

    local px, py = ParadiseZ.getSqXY(originSq)
    if not px then return nil end
    local pz = originSq:getZ()
    local zoneName = ParadiseZ.getZoneName(pl)
    if not zoneName or zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return nil end

    local edgeX, edgeY, edgeZ = ParadiseZ.getZoneEdge(pl, zoneName)
    if not edgeX then return nil end

    local dx = edgeX - px
    local dy = edgeY - py
    local mag = math.sqrt(dx*dx + dy*dy)
    if mag == 0 then return nil end

    dx = dx / mag
    dy = dy / mag

    local outX = round(edgeX + dx * outward)
    local outY = round(edgeY + dy * outward)

    return outX, outY, edgeZ
end

-----------------------            ---------------------------

-----------------------            ---------------------------

function ParadiseZ.getClosestSafeZone(pl)
    pl = pl or getPlayer()
    if not pl then return nil end

    local px, py = ParadiseZ.getXY(pl)
    if not px or not py then return nil end

    local closestZone = nil
    local closestDist = math.huge
    local safeZones = {}

    for name, zone in pairs(ParadiseZ.ZoneData) do
        if zone.isSafe then
            table.insert(safeZones, zone)
        end
    end

    for _, zone in ipairs(safeZones) do
        local zx = (zone.x1 + zone.x2) / 2
        local zy = (zone.y1 + zone.y2) / 2
        local dist = math.sqrt((px - zx)^2 + (py - zy)^2)
        if dist < closestDist then
            closestDist = dist
            closestZone = zone
        end
    end

    return closestZone
end
function ParadiseZ.getClosestSafeEdge(pl)
    pl = pl or getPlayer()
    if not pl then return nil end

    local px, py = ParadiseZ.getXY(pl)
    if not px or not py then return nil end

    local closestEdge = nil
    local closestDist = math.huge

    for name, zone in pairs(ParadiseZ.ZoneData) do
        if zone.isSafe then
            local edgeX = math.max(zone.x1, math.min(px, zone.x2))
            local edgeY = math.max(zone.y1, math.min(py, zone.y2))

            if px >= zone.x1 and px <= zone.x2 then
                if math.abs(px - zone.x1) < math.abs(px - zone.x2) then
                    edgeX = zone.x1
                else
                    edgeX = zone.x2
                end
            end
            if py >= zone.y1 and py <= zone.y2 then
                if math.abs(py - zone.y1) < math.abs(py - zone.y2) then
                    edgeY = zone.y1
                else
                    edgeY = zone.y2
                end
            end

            local dist = math.sqrt((px - edgeX)^2 + (py - edgeY)^2)
            if dist < closestDist then
                closestDist = dist
                closestEdge = {x = edgeX, y = edgeY, z = pl:getZ()}
            end
        end
    end

    return closestEdge.x, closestEdge.y, closestEdge.z
end
 ]]
-----------------------            ---------------------------

-----------------------            ---------------------------

-----------------------            ---------------------------
--[[ 

function ParadiseZ.localData(pl, str, default, val)
    local md = pl:getModData()
    local key = tostring(str)

    if val ~= nil then
        md[key] = val
        return val
    end

    local v = md[key]
    if v == nil then
        md[key] = default
        v = default
    end
    return v
end

-----------------------            ---------------------------
function ParadiseZ.getReboundDestination(px, py, x1, y1, x2, y2, outward)
    outward = outward or 4
    if not px or not py then return nil end

    local dN = math.abs(py - y1)
    local dS = math.abs(y2 - py)
    local dW = math.abs(px - x1)
    local dE = math.abs(x2 - px)

    local min = dN
    local dir = "N"

    if dS < min then
        min = dS
        dir = "S"
    end
    if dW < min then
        min = dW
        dir = "W"
    end
    if dE < min then
        min = dE
        dir = "E"
    end

    local edgeX = px
    local edgeY = py

    if dir == "N" then
        edgeY = y1
        edgeY = edgeY - outward
    elseif dir == "S" then
        edgeY = y2
        edgeY = edgeY + outward
    elseif dir == "W" then
        edgeX = x1
        edgeX = edgeX - outward
    elseif dir == "E" then
        edgeX = x2
        edgeX = edgeX + outward
    end

    return edgeX, edgeY, dir
end

function ParadiseZ.getClosestEdgeDir(px, py, x1, y1, x2, y2)
    if not px or not py or not x1 then return nil end

    local dN = math.abs(py - y1)
    local dS = math.abs(y2 - py)
    local dW = math.abs(px - x1)
    local dE = math.abs(x2 - px)

    local min = dN
    local dir = "N"

    if dS < min then
        min = dS
        dir = "S"
    end
    if dW < min then
        min = dW
        dir = "W"
    end
    if dE < min then
        min = dE
        dir = "E"
    end

    return dir
end
 ]]
----------
--[[ 
function ParadiseZ.isBadTeleportPos(pl, x, y, z)
    pl = pl or getPlayer()
    if not pl then return true end
    if not x or not y then return true end
    if not ParadiseZ.ZoneData then return true end

    local insideName = nil
    for name, zone in pairs(ParadiseZ.ZoneData) do
        if x >= zone.x1 and x <= zone.x2 and y >= zone.y1 and y <= zone.y2 then
            insideName = name
            break
        end
    end

    if not insideName then
        return true
    end

    local data = ParadiseZ.ZoneData[insideName]
    if not data then
        return true
    end

    if data.isKos and not data.isPvE and ParadiseZ.isPvE(pl) then
        return true
    end

    return false
end
 ]]
-------------            ---------------------------

--[[ 
function ParadiseZ.findZoneExit(pl, x, y, z, step, maxDist)
    pl = pl or getPlayer()
    if not pl then return nil end
    if not x or not y then return nil end
    z = z or 0
    step = step or 1
    maxDist = maxDist or 300

    local dirs = {
        { dx = 0, dy = -1, name = "N" },
        { dx = 1, dy = 0,  name = "E" },
        { dx = 0, dy = 1,  name = "S" },
        { dx = -1,dy = 0,  name = "W" },
    }

    for i = 1, #dirs do
        local d = dirs[i]
        local nx = x
        local ny = y
        local dist = 0

        while dist <= maxDist do
            if not ParadiseZ.isBadTeleportPos(pl, nx, ny, z) then
                return nx, ny, z, d.name
            end
            nx = nx + d.dx * step
            ny = ny + d.dy * step
            dist = dist + step
        end
    end

    return nil
end
 ]]
--[[ 
function ParadiseZ.vanillaChecks(obj)
    isSomethingTo(sq)
	if not obj or not obj:getSprite() then return false end
	if not obj:hasWater() then return false end
	return obj:getSprite():getProperties():Is(IsoFlagType.solidfloor)
isFreeOrMidair(boolean bCountOtherCharacters, boolean bDoZombie)
hasFloor 
isNotBlocked 
end
 ]]