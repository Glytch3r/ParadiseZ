ParadiseZ = ParadiseZ or {}
TheRange = TheRange or {}
LuaEventManager.AddEvent("OnZoneCrossed")

-----------------------            ---------------------------



function ParadiseZ.doRegularTp(pl, x, y, z)
    if not pl then return end
    if pl:getVehicle() then
        ParadiseZ.forceExitCar()
    end
    if not x or not y or not z then return end
    ParadiseZ.doTp(pl, x, y, z)
end


function ParadiseZ.spawnRebound()
    if not SandboxVars.ParadiseZ.ReboundSystem then return end
    local pl = getPlayer() 
    if not pl then return false end
    local md = pl:getModData()
    if md['Rebound'] == nil then
        if not ParadiseZ.checkRestrictions(pl) then
            ParadiseZ.saveRebound(pl)
        end
    end
    if ParadiseZ.checkRestrictions(pl) then
        local x, y, z = ParadiseZ.getLastCoord(pl, false)
        if not x or not y or not z then return false end        
        ParadiseZ.doRegularTp(pl, x, y, z)
        timer:Simple(3, function() 
            pl:Say(tostring('Not Allowed From Spawned Location')) 
        end)
    end
end
Events.OnCreatePlayer.Remove(ParadiseZ.spawnRebound)
Events.OnCreatePlayer.Add(ParadiseZ.spawnRebound)


function ParadiseZ.checkRestrictions(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    if (ParadiseZ.isKosZone(pl) and ParadiseZ.isPvE(pl)) or ParadiseZ.isBlockedZone(pl)  or (ParadiseZ.isHuntZone(pl) and (not TheRange.isStaff(pl) and not TheRange.canHunt(pl))) then
        return true    
    end
    return false
end


function ParadiseZ.isRestrictedCoord(pl, x, y)
    pl = pl or getPlayer()
    if not pl then return false end
    if not (x and y) then return false end
    local zName = ParadiseZ.getZoneName(x, y)
    local data
    if zName then
        data = ParadiseZ.ZoneData[zName]
    end
    if data then 
        if (data.isKos and ParadiseZ.isPvE(pl)) or data.isBlocked or (data.isHunt and (not TheRange.isStaff(pl) and not TheRange.canHunt(pl))) then
            return true    
        end
    end
    return false
end





function ParadiseZ.isRestricted(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    if instanceof(pl, "IsoGridSquare") then
        return false
    end
    local zName = ParadiseZ.getZoneName(sq)
    local x, y = ParadiseZ.getXY(pl)
    if ParadiseZ.isXYZoneInner(x, y, zName) then
        if ParadiseZ.checkRestrictions(pl) then
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
    local reboundStr = SandboxVars.ParadiseZ.reboundMsg or 'NOT ALLOWED IN THIS ZONE'
    local car = pl:getVehicle()
    if car then
        local isDriving = pl:isDriving()
        if ParadiseZ.isRestricted(pl) then
            if isDriving then 
                if ParadiseZ.carTp(pl, car, x, y, z) then 
                    pl:setHaloNote(tostring(reboundStr),150,250,150,900) 
                    return 
                end
            else 
                if not ParadiseZ.isBlockedZone(pl) then
                    ParadiseZ.forceExitCar()
                end
            end
        end
    end
    pl:setHaloNote(tostring(reboundStr),150,250,150,900) 
    ParadiseZ.doTp(pl, x, y, z)
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
        local zName = ParadiseZ.getZoneName(pl) or ParadiseZ.getSqZoneName(sq) 
        if not zName or zName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return end
        
        if ParadiseZ.isXYZoneOuter(plX, plY, zName) then
            if not ParadiseZ.isRestricted(pl) then
                ParadiseZ.saveRebound(pl, zName)
            end
        elseif ParadiseZ.isXYZoneInner(plX, plY, zName) then                        
            if ParadiseZ.isRestricted(pl) then
                ParadiseZ.doRebound(pl, false)
            end
        end
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.reboundHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.reboundHandler)

function ParadiseZ.carTp(pl, vehicle, x, y, z)
    if not vehicle or not pl then return false end
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

-----------------------            ---------------------------


-----------------------            ---------------------------
function ParadiseZ.initializeRebound(pl)
    pl = pl or getPlayer()
    if not pl then return end

    local md = pl:getModData()
    if md['Rebound'] then return end

    local plX, plY = ParadiseZ.getXY(pl)
    local plZ = pl:getZ()
    local zName = ParadiseZ.getZoneName(pl)

    if not plX or not plY then
        plX, plY, plZ = ParadiseZ.getFallbackCoord()
        if not plX or not plY or not plZ then return end
        zName = tostring(SandboxVars.ParadiseZ.OutsideStr)
    end
    
    local tab = {
        name = zName,
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

-----------------------            ---------------------------

function ParadiseZ.saveRebound(pl, zName)
    pl = pl or getPlayer()
    if not pl then return nil end

    local sq = pl:getCurrentSquare()
    if not sq then return nil end
    local sx, sy = sq:getX(), sq:getY()

    zName = zName or ParadiseZ.getZoneName(pl)
    local md = pl:getModData()

    --if ParadiseZ.isXYZoneOuter(sx, sy, zName) then
    local tab = {
        name = zName,
        x = sx + 0.5,
        y = sy + 0.5,
        z = pl:getZ(),
        ax = ParadiseZ.roundN(pl:getX(), 3),
        ay = ParadiseZ.roundN(pl:getY(), 3)
    }
    md['Rebound'] = tab
    --pl:setHaloNote("rebound updated\n:"..tostring(sx)..',    '..tostring(sy), 150, 250, 150, 180)
    return tab
    --end
    --return nil
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
    
    if rebound  then 
        if rebound.x and rebound.y and rebound.z then     
            if not ParadiseZ.isRestrictedCoord(pl, rebound.x, rebound.y) then
                return rebound.x, rebound.y, rebound.z      
            end  
        end
        if not isChat then
            local sh = SafeHouse.hasSafehouse(pl)
            if sh then
                return sh:getX(), sh:getY(), 0
            end
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
