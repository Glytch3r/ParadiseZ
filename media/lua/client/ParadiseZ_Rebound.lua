ParadiseZ = ParadiseZ or {}
LuaEventManager.AddEvent("OnZoneCrossed")

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
        x = plX,
        y = plY,
        z = plZ
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







--[[ 



-- inside whole zone
function ParadiseZ.isXYInsideZone(x, y, name)
    if not name or name == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local x1, y1, x2, y2 = ParadiseZ.getZoneArea(name)
    if not (x1 and y1 and x2 and y2) then return false end

    local x, y, z = ParadiseZ.parseCoords()
    if not (x and y and z) then return false end

    if not x1 then return false end
    return x >= x1 and x <= x2 and y >= y1 and y <= y2
end

-- 3 tiles of any edges
function ParadiseZ.isXYZoneOuter(x, y, name)
    if not name or name == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end

    if not ParadiseZ.isXYInsideZone(x, y, name) then return false end
    local x1, y1, x2, y2 = ParadiseZ.getZoneArea(name)
    if not (x1 and y1 and x2 and y2) then return false end

    if x <= x1 + 2 or x >= x2 - 2 then return true end
    if y <= y1 + 2 or y >= y2 - 2 then return true end
    return false
end

-- inside zone NOT within 3 tiles of any edge
function ParadiseZ.isXYZoneInner(x, y, name)
    if not name or name == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    
   -- if not ParadiseZ.isXYInsideZone(x, y, name) then return false end
    local x1, y1, x2, y2 = ParadiseZ.getZoneArea(name)
    if not (x1 and y1 and x2 and y2) then return false end

    if x <= x1 + 2 then return false end
    if x >= x2 - 2 then return false end
    if y <= y1 + 2 then return false end
    if y >= y2 - 2 then return false end
    return true
end
 ]]
-----------------------            ---------------------------

function ParadiseZ.saveRebound(pl, name)
    pl = pl or getPlayer()
    if not pl then return nil end
    local plX, plY = ParadiseZ.getXY(pl)
    if not plX or not plY then return nil end
    
    name = name or ParadiseZ.getZoneName(pl)
    local md = pl:getModData()
    
    if ParadiseZ.isXYZoneOuter(plX, plY, name) then
        local tab = {
            name = name,
            x = plX,
            y = plY,
            z = pl:getZ()
        }
        md['Rebound'] = tab
        pl:setHaloNote("rebound updated\n:"..tostring(plX)..',    '..tostring(plY), 150, 250, 150, 180)
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

function ParadiseZ.doRebound(pl, isChat)
    if not SandboxVars.ParadiseZ.ReboundSystem then return end
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    
    local x, y, z = ParadiseZ.getLastCoord(pl, isChat)
    if not x or not y or not z then return end
    
    local car = pl:getVehicle()
    if car then
        ParadiseZ.carTp(pl, car)
        return
    end
    
    ParadiseZ.tp(pl, x, y, z)
    local sq = getCell():getOrCreateGridSquare(x, y, z)
    if sq then ParadiseZ.addTempMarker(sq) end
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
function ParadiseZ.parseExileCoords()   
    local strList = SandboxVars.ParadiseZ.ExileCoords
    local tx, ty, tz = strList:match("^(-?%d+)[;:](-?%d+)[;:](-?%d+)")
    tx, ty, tz = tonumber(tx), tonumber(ty), tonumber(tz)    
    return tx, ty, tz
end




function ParadiseZ.doExile(pl)
    if not SandboxVars.ParadiseZ.ReboundSystem then return end
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    
    local car = pl:getVehicle()
    if car then
        ISVehicleMenu.onExit(pl)
    end
    local x, y, z = ParadiseZ.parseExileCoords()   
    if not (x and y and z) then return end
    ParadiseZ.tp(pl, x, y, z)
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

function ParadiseZ.getZoneEdge(targUser, name, margin)
    margin = margin or 3
    local targ = ParadiseZ.getPl(targUser)
    if not targ then return nil end
    if ParadiseZ.isOutSide(targ) then return nil end
    name = name or ParadiseZ.getZoneName(targUser)
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

function ParadiseZ.isZoneEdge(targUser, name, margin)
    margin = margin or 3
    local targ = ParadiseZ.getPl(targUser)
    if not targ then return false end
    if ParadiseZ.isOutSide(targ) then return false end
    name = name or ParadiseZ.getZoneName(targUser)
    if not name then return false end
    local px, py = ParadiseZ.getXY(targUser)
    if not px then return false end
    local x1, y1, x2, y2 = ParadiseZ.getZoneArea(name)
    if not x1 then return false end
    if (px >= x1 and px <= x1 + margin) or (px <= x2 and px >= x2 - margin) then
        return true
    end
    if (py >= y1 and py <= y1 + margin) or (py <= y2 and py >= y2 - margin) then
        return true
    end
    return false
end


function ParadiseZ.isRestricted(sq, pl)
    pl = ParadiseZ.getPl(pl)
    if not pl then return false end
    sq = sq or pl:getCurrentSquare()
    if not sq then return false end
    if ParadiseZ.isOutsideSq(sq) then return false end
    local name = ParadiseZ.getZoneName(sq)
    local x, y = ParadiseZ.getXY(pl)
    if ParadiseZ.isXYZoneInner(x, y, name) then
        if (ParadiseZ.isKosZone(pl) and ParadiseZ.isPvE(pl)) or ParadiseZ.isBlockedZone(pl) then
            return true
        end
    end
    return false
end

local ticks = 0
function ParadiseZ.reboundHandler(pl)
    ticks = ticks + 1
    if ticks % 3 == 0 then        
        if not pl then return end
        local plX, plY = ParadiseZ.getXY(pl) 
        if not plX or not plY then return end
        local sq = getCell():getOrCreateGridSquare(plX, plY, pl:getZ()) 
        if not sq then return end 
        local name = ParadiseZ.getZoneName(pl) or ParadiseZ.getSqZoneName(sq) 
        if not name or name == tostring(SandboxVars.ParadiseZ.OutsideStr) then return end
        if ParadiseZ.isXYZoneOuter(plX, plY, name) then
            ParadiseZ.saveRebound(pl, name)
            if getCore():getDebug() then 
                if sq then ParadiseZ.addTempMarker(sq) end
            end
        else        
            if ParadiseZ.isXYZoneInner(plX, plY, name) and ParadiseZ.isRestricted(sq, pl) then
                ParadiseZ.doRebound(pl)
                local sq = getCell():getOrCreateGridSquare(plX, plY, pl:getZ())
                if sq then ParadiseZ.addTempMarker(sq) end
            end
        end
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.reboundHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.reboundHandler)

