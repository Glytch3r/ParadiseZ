--ParadiseZ_Rebound.lua
ParadiseZ = ParadiseZ or {}
LuaEventManager.AddEvent("OnZoneCrossed")

function ParadiseZ.reboundHandler(pl)
    local plX, plY = ParadiseZ.getXY(pl)
    if not plX or not plY then return end

    local name = ParadiseZ.getCurrentZoneName(pl)
    if name == "Outside" then return end

    local roundedX = round(plX)
    local roundedY = round(plY)

    local md = pl:getModData()
    local rebound = md.ZoneRebound

    if ParadiseZ.isXYInZoneMargin(roundedX, roundedY, name) then
        if not rebound or rebound.x ~= roundedX or rebound.y ~= roundedY or rebound.name ~= name then
            ParadiseZ.saveRebound(pl, name)
        end
    else
        if ParadiseZ.isRestricted(pl:getCurrentSquare(), pl) then
            local x, y, z = ParadiseZ.getLastCoord(pl)
            if x and y and z then
                ParadiseZ.doRebound(pl, x, y, z)
            end
        end
    end
end

Events.OnPlayerMove.Remove(ParadiseZ.reboundHandler)
Events.OnPlayerMove.Add(ParadiseZ.reboundHandler)

function ParadiseZ.getFallbackCoord(pl)
    local x, y, z = ParadiseZ.parseCoords()
    if x and y and z then
        return x, y, z
    end
    return nil, nil, nil
end

function ParadiseZ.saveRebound(pl, name)
    local plX, plY = ParadiseZ.getXY(pl)
    if not plX or not plY then return end

    name = name or ParadiseZ.getCurrentZoneName(pl)
    if name == "Outside" then return end

    local roundedX = round(plX)
    local roundedY = round(plY)

    if ParadiseZ.isXYInZoneMargin(roundedX, roundedY, name) then
        pl:getModData()['ZoneRebound'] = {
            name = name,
            x = roundedX,
            y = roundedY,
            z = pl:getZ()
        }
    end
end

function ParadiseZ.getLastCoord(pl)
    pl = pl or getPlayer()
    if not pl then return ParadiseZ.getFallbackCoord(pl) end

    local md = pl:getModData()
    local rebound = md.ZoneRebound
    local name = rebound and rebound.name or ParadiseZ.getCurrentZoneName(pl)

    if rebound and rebound.x and rebound.y and rebound.z and rebound.name == name then
        if ParadiseZ.isXYInsideZone(rebound.x, rebound.y, name) then
            return rebound.x, rebound.y, rebound.z
        end
    end

    return ParadiseZ.getFallbackCoord(pl)
end

function ParadiseZ.doRebound(pl, x, y, z)
    pl = pl or getPlayer()
    if not pl then return end
    if not pl:isAlive() then return end

    if not (x and y and z) then return end    
    local car = pl:getVehicle()
    if car then
        ParadiseZ.carTp(pl, car)
    else
        local sq = getCell():getOrCreateGridSquare(x, y, z) 
        if sq then
            ParadiseZ.addTempMarker(sq)
            
            ParadiseZ.tp(pl, x, y, z)
        end
    end

    return true
end


-----------------------            ---------------------------

-----------------------            ---------------------------
--[[ 
function ParadiseZ.reboundHandler(pl, prev, cur)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end

    local csq = pl:getCurrentSquare()
    if not csq then return end

    if not ParadiseZ.isRestricted(csq, pl) then
        return
    end


    local x, y, z
    
    x, y, z = ParadiseZ.getLastCoord(pl)
    if x and y and z then
        local sq = getCell():getOrCreateGridSquare(x, y, z)
        if sq and not ParadiseZ.isBlockedZone(sq) then
            ParadiseZ.doRebound(pl, x, y, z)
            return
        end
    end

    x, y, z = ParadiseZ.getClosestReboundPoint(csq, 4)  
    if x and y and z then
        local sq = getCell():getOrCreateGridSquare(x, y, z)
        if sq and not ParadiseZ.isBlockedZone(sq) then
            ParadiseZ.doRebound(pl, x, y, z)
            return
        end
    end

    x, y, z = ParadiseZ.parseCoords() 
    if x and y and z then
        local sq = getCell():getOrCreateGridSquare(x, y, z)
        if sq and not ParadiseZ.isBlockedZone(sq) then
            ParadiseZ.doRebound(pl, x, y, z)
            return
        end
    end

    local px, py, pz = pl:getX(), pl:getY(), pl:getZ()
    for dz = -3, 3 do
        local testZ = pz + dz
        local sq = getCell():getOrCreateGridSquare(px, py, testZ)
        if sq and not ParadiseZ.isBlockedZone(sq) then
            ParadiseZ.doRebound(pl, px, py, testZ)
            return
        end
    end

end

Events.OnZoneCrossed.Remove(ParadiseZ.reboundHandler)
Events.OnZoneCrossed.Add(ParadiseZ.reboundHandler)
 ]]
-----------------------            ---------------------------


function ParadiseZ.getZoneEdge(targUser, name, margin)
    margin = margin or 3
    local targ = ParadiseZ.getPl(targUser)
    if not targ then return nil end
    if ParadiseZ.isOutSide(targ) then return nil end
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


-----------------------            ---------------------------
function ParadiseZ.isKosZoneByName(name)
    local z = ParadiseZ.ZoneData[name]
    if not z then return false end
    return z.isKos == true
end
function ParadiseZ.isPvEZoneByName(name)
    local z = ParadiseZ.ZoneData[name]
    if not z then return false end
    return z.isPvE == true
end
function ParadiseZ.isSafeZoneByName(name)
    local z = ParadiseZ.ZoneData[name]
    if not z then return false end
    return z.isSafe == true
end
function ParadiseZ.isBlockedZoneByName(name)
    local z = ParadiseZ.ZoneData[name]
    if not z then return false end
    return z.isBlocked == true
end
function ParadiseZ.isBlockedZoneByName(name)
    local z = ParadiseZ.ZoneData[name]
    if not z then return false end
    return z.isBlocked == true
end


-----------------------            ---------------------------
