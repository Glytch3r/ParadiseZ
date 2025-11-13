ParadiseZ = ParadiseZ or {}
LuaEventManager.AddEvent("OnZoneCrossed")

function ParadiseZ.tp(pl, x, y, z)
    pl = pl or getPlayer()
    if not pl then return end
    z = z or 0
    if not (x and y and z) then return end

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

function ParadiseZ.forceExitCar()
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

function ParadiseZ.carTp(player, vehicle)
    if not vehicle or not player then return end

    local lx, ly, lz = ParadiseZ.getZoneEdge(player)
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

function ParadiseZ.doRebound(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    if ParadiseZ.isOutsideZone(pl:getUsername()) then return false end

    local x, y, z = ParadiseZ.getZoneEdge(pl:getUsername())
    if not (x and y and z) then return false end

    local car = pl:getVehicle()
    if car then
        ParadiseZ.carTp(pl, car)
    else
        ParadiseZ.tp(pl, x, y, z)
    end

    return true
end

function ParadiseZ.getReboundXYZ(pl, vx, vy, vz)
    pl = pl or getPlayer()
    if not pl then return end

    local curSq = pl:getCurrentSquare()
    if not curSq then return end
    
    local cx, cy, cz = curSq:getX(), curSq:getY(), curSq:getZ()
    local lx, ly, lz = ParadiseZ.getLastCoord()
    if vx and vy then
        lx = vx
        ly = vy
        lz = vz
    end
    if not lx or not ly or not lz then return end
    
    local cell = getWorld():getCell()
    if not cell then return end

    local lastSq = cell:getGridSquare(math.floor(lx+0.5), math.floor(ly+0.5), lz)
    if not lastSq then lastSq = cell:getGridSquare(lx, ly, lz) end
    if not lastSq then return end

    local sx, sy = lastSq:getX(), lastSq:getY()
    local dx, dy = cx - sx, cy - sy
    local len = math.sqrt(dx * dx + dy * dy)
    local dist = 8
    local dirX, dirY
    if len < 0.0001 then
        dirX, dirY = 0, -1
    else
        dirX, dirY = dx / len, dy / len
    end

    local targetX, targetY, targetSq
    for i = dist, dist + 6 do
        targetX = sx - dirX * i
        targetY = sy - dirY * i
        local tx = math.floor(targetX + 0.5)
        local ty = math.floor(targetY + 0.5)
        targetSq = cell:getGridSquare(tx, ty, lz)
        if targetSq then
            return targetSq:getX(), targetSq:getY(), targetSq:getZ()
        end
    end
    
    local fallbackTx = math.floor(sx - dirX * dist + 0.5)
    local fallbackTy = math.floor(sy - dirY * dist + 0.5)
    local fallbackSq = cell:getGridSquare(fallbackTx, fallbackTy, lz)
    if fallbackSq then
        return fallbackSq:getX(), fallbackSq:getY(), fallbackSq:getZ()
    end
    
    return sx, sy, lz
end

function ParadiseZ.getZoneEdge(targUser, name, margin)
    margin = margin or 3
    local targ = getPlayerFromUsername(targUser) or getPlayer()
    if not targ then return nil end
    if ParadiseZ.isOutSide(targUser) then return nil end
    name = name or ParadiseZ.getCurrentZoneName(targUser)
    if not name then return end

    local px, py = ParadiseZ.getXY(targUser)
    if not px then return nil end
    local pz = targ:getZ()

    local x1, y1, x2, y2 = ParadiseZ.getZoneArea(name)
    if not x1 then return nil end

    local edgeX, edgeY = px, py

    if px >= x1 and px <= x1 + margin then
        edgeX = x1
    elseif px <= x2 and px >= x2 - margin then
        edgeX = x2
    end

    if py >= y1 and py <= y1 + margin then
        edgeY = y1
    elseif py <= y2 and py >= y2 - margin then
        edgeY = y2
    end

    if edgeX ~= px or edgeY ~= py then
        return edgeX, edgeY, pz
    end

    return nil
end

function ParadiseZ.saveRebound(pl, name)
    local user = pl:getUsername() 
    name = name or ParadiseZ.getCurrentZoneName(user)
    local zX, zY, zZ = ParadiseZ.getZoneEdge(user, name)
    if not zX then      
        return
    end
    pl:getModData()['Rebound'] = {
        x = zX,
        y = zY,
        z = zZ
    }
end

function ParadiseZ.getLastCoord(pl)
    pl = pl or getPlayer()
    if not pl then return nil end

    local md = pl:getModData()
    if not md or not md.Rebound then return nil end

    local rebound = md.Rebound
    if not rebound.x or not rebound.y or not rebound.z then return nil end

    return rebound.x, rebound.y, rebound.z
end

function ParadiseZ.saveTravelInfo(pl)
    local user = pl:getUsername() 
    local name = ParadiseZ.getCurrentZoneName(user)
    local modData = pl:getModData()
    local prev = modData['TravelInfo'] and modData['TravelInfo'].cur or "Outside"
    local cur = name
    ParadiseZ.saveRebound(pl, name)
    modData['TravelInfo'] = {
        prev = prev,
        cur = cur,
    }

    if prev ~= cur then        
        triggerEvent("OnZoneCrossed", pl, prev, cur)
    end
end
Events.OnPlayerMove.Remove(ParadiseZ.saveTravelInfo)
Events.OnPlayerMove.Add(ParadiseZ.saveTravelInfo)
    
function ParadiseZ.shouldRebound(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    local user = pl:getUsername() 
    if not user then return end
    local zoneName = ParadiseZ.getCurrentZoneName(user)
    if zoneName == "Outside" then return false end
    if not ParadiseZ.isZoneIsBlocked(user) then
        return true
    end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end

    if zone.isBlocked or (ParadiseZ.isPvE(pl) and zone.isKos) then
        return true
    end
    
    return false
end

function ParadiseZ.reboundHandler(pl, prev, cur)
    if pl and ParadiseZ.shouldRebound(pl) then
        ParadiseZ.doRebound(pl)
    end
end
Events.OnZoneCrossed.Remove(ParadiseZ.reboundHandler)
Events.OnZoneCrossed.Add(ParadiseZ.reboundHandler)