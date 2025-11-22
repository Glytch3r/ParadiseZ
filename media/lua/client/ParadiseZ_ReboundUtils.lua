--ParadiseZ_Rebound.lua
ParadiseZ = ParadiseZ or {}

function ParadiseZ.forceExitCar()
    if not SandboxVars.ParadiseZ.ReboundExitsCar then return end

    local pl = getPlayer()
    if not pl then return end
    local car = pl:getVehicle()
    if not car then return end

    local seat = car:getSeat(pl)
    car:exit(pl)
    if seat then
        car:setCharacterPosition(pl, seat, "outside")
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

    local sq = getCell():getOrCreateGridSquare(x, y, z) 

    if getCore():getDebug() then 
        if sq and not ParadiseZ.isTempMarkerActive() then ParadiseZ.addTempMarker(sq) end
    end
	
    if SandboxVars.ParadiseZ.ReboundSystem then
            ParadiseZ.forceExitCar()
        
        if luautils.stringStarts(getCore():getVersion(), "42") then
            pl:teleportTo(tonumber(x), tonumber(y), tonumber(z))
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
end

function ParadiseZ.carTp(pl, vehicle)
    if not vehicle or not player then return end
    --if SandboxVars.ParadiseZ.ReboundExitsCar then return end


    local lx, ly, lz = ParadiseZ.getZoneEdge(pl)
    if not lx or not ly or not lz then return end

    local cx, cy, cz = vehicle:getX(), vehicle:getY(), vehicle:getZ()
    local dx, dy = cx - lx, cy - ly
    local len = math.sqrt(dx * dx + dy * dy)
    if len == 0 then return end

    dx, dy = dx / len, dy / len
    local dist = 5
    local px, py = dx * dist, dy * dist

    local fieldCount = getNumClassFields(vehicle)
    local transField
    local fieldName = 'public final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.jniTransform'

    for i = 0, fieldCount - 1 do
        local field = getClassField(vehicle, i)
        if tostring(field) == fieldName then
            transField = field
            break
        end
    end
    if not transField then return end

    local v_transform = getClassFieldVal(vehicle, transField)
    local w_transform = vehicle:getWorldTransform(v_transform)
    local origin_field = getClassField(w_transform, 1)
    local origin = getClassFieldVal(w_transform, origin_field)
    origin:set(origin:x() - px, origin:y() - py, origin:z())
    vehicle:setWorldTransform(w_transform)

    if isClient() then
        pcall(vehicle.update, vehicle)
        pcall(vehicle.updateControls, vehicle)
        pcall(vehicle.updateBulletStats, vehicle)
        pcall(vehicle.updatePhysics, vehicle)
        pcall(vehicle.updatePhysicsNetwork, vehicle)
    end
end

function ParadiseZ.getClosestReboundPoint(origin, margin)
    margin = margin or 4
    local pl = getPlayer()
    if not pl then return nil, nil, nil end
    local cell = pl:getCell()
    local ox, oy, oz = origin and origin:getX() or pl:getX(), origin and origin:getY() or pl:getY(), origin and origin:getZ() or pl:getZ()
    local originZone = ParadiseZ.getZoneNameFromSquare(origin)
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
                        local zoneName = ParadiseZ.getZoneNameFromSquare(testSq)
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



function ParadiseZ.getReboundXYZ(pl, vx, vy, vz)
    pl = pl or getPlayer()
    local originSq = pl:getCurrentSquare()
    if vx and vy then
        local cell = getWorld():getCell()
        originSq = cell:getGridSquare(math.floor(vx + 0.5), math.floor(vy + 0.5), vz)
    end

    local x, y, z = ParadiseZ.getClosestReboundPoint(originSq, 4)
    return x, y, z
end


function ParadiseZ.findReboundPoint(pl, originSq, outward)
    outward = outward or 4
    if not pl or not originSq then return nil end

    local px, py = ParadiseZ.getSqXY(originSq)
    if not px then return nil end
    local pz = originSq:getZ()
    local zoneName = ParadiseZ.getCurrentZoneName(pl)
    if not zoneName or zoneName == "Outside" then return nil end

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
function ParadiseZ.getZoneArea(name)
    if not name then return nil end
    local zones = ParadiseZ.Zones or {}
    local zone = zones[name]
    if not zone then return nil end
    return zone.x1, zone.y1, zone.x2, zone.y2
end

function ParadiseZ.isPlayerInArea(x1, y1, x2, y2, pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local px, py = ParadiseZ.getXY(targ)
    if not px or not py then return false end
    local minX, maxX = math.min(x1, x2), math.max(x1, x2)
    local minY, maxY = math.min(y1, y2), math.max(y1, y2)
    return px >= minX and px <= maxX and py >= minY and py <= maxY
end
-----------------------    margin*        ---------------------------

function ParadiseZ.isXYInsideZone(x, y, name)
    local pl = getPlayer() 
    name = name or ParadiseZ.getCurrentZoneName(pl)
    if not x or not y then 
        x , y = ParadiseZ.getXY(pl)
    end
    local zone = ParadiseZ.ZoneData[name]
    if not zone then return false end
    return x >= zone.x1 and x <= zone.x2 and y >= zone.y1 and y <= zone.y2
end
function ParadiseZ.isXYInZoneMargin(x, y, name)
    name = name or ParadiseZ.getCurrentZoneName(getPlayer())
    local z = ParadiseZ.ZoneData[name]
    if not z then return false end
    if x < z.x1 or x > z.x2 or y < z.y1 or y > z.y2 then
        return false
    end
    if x <= z.x1 + 2 then return true end
    if x >= z.x2 - 2 then return true end
    if y <= z.y1 + 2 then return true end
    if y >= z.y2 - 2 then return true end
    return false
end
function ParadiseZ.isXYInZoneArea(x, y, name)
    name = name or ParadiseZ.getCurrentZoneName(getPlayer())
    local z = ParadiseZ.ZoneData[name]
    if not z then return false end
    if x < z.x1 or x > z.x2 or y < z.y1 or y > z.y2 then
        return false
    end
    if x <= z.x1 + 2 then return false end
    if x >= z.x2 - 2 then return false end
    if y <= z.y1 + 2 then return false end
    if y >= z.y2 - 2 then return false end
    return true
end
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

-----------------------            ---------------------------



function ParadiseZ.isRestricted(sq, pl)
    pl = pl or getPlayer()
    if not pl then return false end
    sq = sq or pl:getCurrentSquare()
    if not sq then return false end
    if ParadiseZ.isOutsideSq(sq) then return false end

    local x, y = sq:getX(), sq:getY()
    local name = ParadiseZ.getZoneNameFromSquare(sq)

    if ParadiseZ.isXYInZoneArea(x, y, name) and not ParadiseZ.isXYInZoneMargin(x, y, name) then
        if (ParadiseZ.isKosZoneFromSquare(sq) and ParadiseZ.isPvE(pl)) 
           or ParadiseZ.isZoneIsBlocked(pl) then
            return true
        end
    end

    return false
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
