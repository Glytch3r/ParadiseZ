ParadiseZ = ParadiseZ or {}
TheRange = TheRange or {}
LuaEventManager.AddEvent("OnZoneCrossed")

-----------------------            ---------------------------


--[[ 
function ParadiseZ.isRestricted(sq, pl)
    pl = ParadiseZ.getPlOrSq(pl)
    if not pl then return false end
    sq = sq or pl:getCurrentSquare()
    if not sq then return false end
    if ParadiseZ.isOutsideSq(sq) then return false end
    local name = ParadiseZ.getZoneName(sq)
    local x, y = ParadiseZ.getXY(pl)
    if ParadiseZ.isXYZoneInner(x, y, name) then
        if (ParadiseZ.isKosZone(pl) and ParadiseZ.isPvE(pl)) or ParadiseZ.isBlockedZone(pl)  or (ParadiseZ.isHuntZone(pl) and (not TheRange.isStaff(pl) and not TheRange.canHunt(pl))) then
            return true
        end
    end
    return false
end ]]

function ParadiseZ.isRestricted(target)
    if not target then return false end

    local sq
    if instanceof(target, "IsoPlayer") then
        sq = target:getCurrentSquare()
    elseif instanceof(target, "IsoGridSquare") then
        sq = target
    else
        return false
    end

    if not sq then return false end

    local objects = sq:getObjects()
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if obj and obj:getModData().isRestricted then
            return true
        end
    end

    return false
end

function ParadiseZ.doRebound(pl, isChat)
    if not SandboxVars.ParadiseZ.ReboundSystem then return end
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    
    local x, y, z = ParadiseZ.getLastCoord(pl, isChat)
    if not x or not y or not z then return end
    
    local car = pl:getVehicle()
    if car then
        local driver = car:getDriver()
        local driverRestricted = driver and ParadiseZ.isRestricted(driver)

        if driver then
            if driverRestricted then
                if ParadiseZ.carTp(pl, car, x, y, z, true) then return end
            else
                local seat = car:getSeat(pl)
                if seat and seat ~= 0 then
                    if ParadiseZ.isRestricted(pl) then
                        ParadiseZ.forceExitCar()
                        return
                    end
                end
                if ParadiseZ.carTp(pl, car, x, y, z, false) then return end
            end
        end
    end
    
    ParadiseZ.tp(pl, x, y, z)
end

function ParadiseZ.carTp(pl, vehicle, x, y, z, forceAll)
    if not vehicle or not pl then return false end
    
    local driver = vehicle:getDriver()
    local driverRestricted = driver and ParadiseZ.isRestricted(driver)
    
    if not forceAll and not driverRestricted then
        if not pl:isDriving() then return false end
    end

    local lx, ly, lz = x, y, z
    if lx == nil or ly == nil or lz == nil then
        ParadiseZ.forceExitCar()
        return false
    end

    local sq = getCell():getOrCreateGridSquare(math.floor(lx), math.floor(ly), lz)
    if sq and ParadiseZ.checkDist(pl, sq) >= 200 then
        ParadiseZ.forceExitCar()
        return false
    end

    local curX, curY = pl:getX(), pl:getY()
    local md = pl:getModData()
    local rebound = md and md['Rebound'] or nil
    local tx, ty = lx, ly
    if type(rebound) == 'table' and rebound.ax and rebound.ay then
        tx, ty = rebound.ax, rebound.ay
    end

    local dx, dy = curX - tx, curY - ty
    local len = math.sqrt(dx * dx + dy * dy)
    if len == 0 then return false end

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
    if not transField then return false end

    local v_transform = getClassFieldVal(vehicle, transField)
    local w_transform = vehicle:getWorldTransform(v_transform)
    local origin_field = getClassField(w_transform, 1)
    local origin = getClassFieldVal(w_transform, origin_field)
    origin:set(origin:x() - px, origin:y(), origin:z() - py)
    vehicle:setWorldTransform(w_transform)

    if isClient() then
        pcall(vehicle.update, vehicle)
        pcall(vehicle.updateControls, vehicle)
        pcall(vehicle.updateBulletStats, vehicle)
        pcall(vehicle.updatePhysics, vehicle)
        pcall(vehicle.updatePhysicsNetwork, vehicle)
    end
    return true
end

local ticks = 0
function ParadiseZ.reboundHandler(pl)
    ticks = ticks + 1
    if ticks % 3 == 0 then        
        if not pl or not pl:isAlive() then return end

        local plX, plY = ParadiseZ.getXY(pl) 
        if not plX or not plY then return end

        local sq = getCell():getOrCreateGridSquare(plX, plY, pl:getZ()) 
        if not sq then return end 
        local name = ParadiseZ.getZoneName(pl) or ParadiseZ.getSqZoneName(sq) 
        if not name or name == tostring(SandboxVars.ParadiseZ.OutsideStr) then return end

        if ParadiseZ.isXYZoneOuter(plX, plY, name) then
            ParadiseZ.saveRebound(pl, name)
            if getCore():getDebug() and sq then
                ParadiseZ.addTempMarker(sq)
            end
        else                         
            if ParadiseZ.isXYZoneInner(plX, plY, name) and ParadiseZ.isRestricted(sq) then
                ParadiseZ.doRebound(pl, false)
            end
        end
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.reboundHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.reboundHandler)
-----------------------            ---------------------------


-----------------------            ---------------------------
function ParadiseZ.initializeRebound(pl)
    pl = pl or getPlayer()
    if not pl then return end

    local md = pl:getModData()
    if md['Rebound'] then return end

    local plX, plY = ParadiseZ.getXY(pl)
    local plZ = pl:getZ()
    local name = ParadiseZ.getZoneName(pl)

    if not plX or not plY then
        plX, plY, plZ = ParadiseZ.getFallbackCoord()
        if not plX or not plY or not plZ then return end
        name = tostring(SandboxVars.ParadiseZ.OutsideStr)
    end
    
    local tab = {
        name = name,
        x = plX + 0.5,
        y = plY + 0.5,
        z = plZ,
        ax = ParadiseZ.roundN(pl:getX(), 3),
        ay = ParadiseZ.roundN(pl:getY(), 3)
    }
    md['Rebound'] = tab
end

function ParadiseZ.getFallbackCoord()
    local x, y, z = ParadiseZ.parseCoords()
    if x and y and z then
        return x, y, z
    end
    return nil, nil, nil
end

function ParadiseZ.getZoneArea(name)
    if not name or name == tostring(SandboxVars.ParadiseZ.OutsideStr) then return nil, nil, nil, nil end

    if not name then return  nil, nil, nil, nil end
    local zone = ParadiseZ.ZoneData[name]
    if not zone then return  nil, nil, nil, nil end
    return zone.x1, zone.y1, zone.x2, zone.y2
end



function ParadiseZ.isXYInsideZone(x, y, name)
    if not name or name == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    if not x or not y then return false end

    local x1, y1, x2, y2 = ParadiseZ.getZoneArea(name)
    if not (x1 and y1 and x2 and y2) then return false end

    return x >= x1 and x <= x2 and y >= y1 and y <= y2
end
function ParadiseZ.isXYZoneOuter(x, y, name, margin)
    margin = margin or 3
    if not ParadiseZ.isXYInsideZone(x, y, name) then return false end

    local x1, y1, x2, y2 = ParadiseZ.getZoneArea(name)
    if not (x1 and y1 and x2 and y2) then return false end

    return x <= x1 + (margin - 1)
        or x >= x2 - (margin - 1)
        or y <= y1 + (margin - 1)
        or y >= y2 - (margin - 1)
end
function ParadiseZ.isXYZoneInner(x, y, name, margin)
    margin = margin or 3
    if not ParadiseZ.isXYInsideZone(x, y, name) then return false end
    return not ParadiseZ.isXYZoneOuter(x, y, name, margin)
end


-----------------------            ---------------------------

function ParadiseZ.saveRebound(pl, name)
    pl = pl or getPlayer()
    if not pl then return nil end

    local sq = pl:getCurrentSquare()
    if not sq then return nil end
    local sx, sy = sq:getX(), sq:getY()

    name = name or ParadiseZ.getZoneName(pl)
    local md = pl:getModData()

    if ParadiseZ.isXYZoneOuter(sx, sy, name) then
        local tab = {
            name = name,
            x = sx + 0.5,
            y = sy + 0.5,
            z = pl:getZ(),
            ax = ParadiseZ.roundN(pl:getX(), 3),
            ay = ParadiseZ.roundN(pl:getY(), 3)
        }
        md['Rebound'] = tab
        pl:setHaloNote("rebound updated\n:"..tostring(sx)..',    '..tostring(sy), 150, 250, 150, 180)
        return tab
    end
    return nil
end

function ParadiseZ.getReboundXYZ(pl)
    local x, y, z = ParadiseZ.getLastCoord(pl)
    return {x = x, y = y, z = z}
end

function ParadiseZ.getLastCoord(pl, isChat)
    pl = pl or getPlayer()
    if not pl then return ParadiseZ.getFallbackCoord() end
    
    local md = pl:getModData()
    local rebound = md['Rebound']
    
    if rebound and rebound.x and rebound.y and rebound.z then     
        return rebound.x, rebound.y, rebound.z        
    end
    if not isChat then
        local sh = SafeHouse.hasSafehouse(pl)
        if sh then
            return sh:getX(), sh:getY(), 0
        end
    end
    return ParadiseZ.getFallbackCoord()
end


function ParadiseZ.reboundCountdown(isChat)
    local pl = getPlayer() 
    isChat = isChat or false
    if not timer:Exists('countdown') then
        timer:Create('countdown', 1, 10, function() 
            if c >= 1 then
                ParadiseZ.doRebound(pl, isChat)
            else
                local c = timer:RepsLeft('countdown')
                print(c)
                pl:setHaloNote('Rebound '..tostring(c),150,250,150,180)  
            end
            
        end)
    else
        ParadiseZ.doRebound(pl, isChat)
    end
end
-----------------------            ---------------------------



function ParadiseZ.isPlayerInArea(x1, y1, x2, y2, pl)
    local targ = ParadiseZ.getPlOrSq(pl)
    if not targ then return false end
    local px, py = ParadiseZ.getXY(targ)
    if not px or not py then return false end
    local minX, maxX = math.min(x1, x2), math.max(x1, x2)
    local minY, maxY = math.min(y1, y2), math.max(y1, y2)
    return px >= minX and px <= maxX and py >= minY and py <= maxY
end
