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
    local x, y, z = round(pl:getX()),  round(pl:getY()),  pl:getZ()
    if md['Rebound'] == nil then
        local isInit = ParadiseZ.isRestrictedCoord(pl, x, y) and ParadiseZ.isXYZoneInner(x, y, zName)
        ParadiseZ.saveRebound(pl, zName, isInit)
    end
    if ParadiseZ.checkRestrictions(pl) then
        local x, y, z = ParadiseZ.getLastCoord(pl, false)
        if not x or not y or not z then return false end
        if ParadiseZ.isRestrictedCoord(pl, x, y) then
            x, y, z = ParadiseZ.getFallbackCoord()
        end
        if not x or not y or not z then return false end
        ParadiseZ.doRegularTp(pl, x, y, z)
        timer:Simple(3, function() 
            pl:Say(tostring('Not Allowed From Spawned Location')) 
        end)
    end
end
Events.OnCreatePlayer.Remove(ParadiseZ.spawnRebound)
Events.OnCreatePlayer.Add(ParadiseZ.spawnRebound)


function ParadiseZ.saveRebound(pl, zName, isInit)
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
        local x, y, z = ParadiseZ.parseCoords()
        tab = {
            name = zName,
            x = round(x),
            y = round(y),
            z = z,
            ax = ParadiseZ.roundN(pl:getX(), 3),
            ay = ParadiseZ.roundN(pl:getY(), 3)
        }
    end
    md['Rebound'] = tab
    return tab

end

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
    --if ParadiseZ.isXYZoneInner(x, y, zName) then
        if ParadiseZ.checkRestrictions(pl) then
            return true
        end
    --end
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
                    pl:setHaloNote(tostring(reboundStr),250,0,0,100) 
                    return 
                end
            else 
                if not ParadiseZ.isBlockedZone(pl) then
                    ParadiseZ.forceExitCar()
                end
            end
        end
    end
    pl:setHaloNote(tostring(reboundStr),250,0,0,100) 
    if ParadiseZ.isRestrictedCoord(pl, x, y) and not ParadiseZ.isXYZoneOuter(x, y, zName, 2) then
        x, y, z = ParadiseZ.getFallbackCoord()     
    end
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
        if not zName then return end
        if zName == tostring(SandboxVars.ParadiseZ.OutsideStr) then 
            ParadiseZ.saveRebound(pl, zName)
        end
        local isRestricted = ParadiseZ.checkRestrictions(pl)


        if ParadiseZ.isXYZoneOuter(plX, plY, zName, 2) or not isRestricted then
            ParadiseZ.saveRebound(pl, zName)
        elseif ParadiseZ.isXYZoneInner(plX, plY, zName) and isRestricted then
            ParadiseZ.doRebound(pl, false)
        end
        
    end
end
Events.OnPlayerUpdate.Remove(ParadiseZ.reboundHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.reboundHandler)


-----------------------            ---------------------------


-----------------------            ---------------------------
function ParadiseZ.getFallbackCoord()
    local x, y, z = ParadiseZ.parseCoords()
    if x and y and z then
        return x, y, z
    end
    return nil, nil, nil
end

-----------------------            ---------------------------


function ParadiseZ.getLastCoord(pl, isChat)
    pl = pl or getPlayer()
    if not pl then return ParadiseZ.getFallbackCoord() end
    
    local md = pl:getModData()
    local rebound = md['Rebound']
    if rebound then 
        if rebound.x and rebound.y and rebound.z then     
            --if not ParadiseZ.isRestrictedCoord(pl, rebound.x, rebound.y) then
            return rebound.x, rebound.y, rebound.z     
           -- end  
        end
    end
    
    if not isChat then
        local sh = SafeHouse.hasSafehouse(pl)
        if sh then
            local shX, shY = sh:getX(), sh:getY()
            if not ParadiseZ.isRestrictedCoord(pl, shX, shY) then
                return shX, shY, 0
            end
        end
    end
    
    return ParadiseZ.getFallbackCoord()
end


function ParadiseZ.getReboundXYZ(pl)
    local x, y, z = ParadiseZ.getLastCoord(pl)
    return {x = x, y = y, z = z}
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

