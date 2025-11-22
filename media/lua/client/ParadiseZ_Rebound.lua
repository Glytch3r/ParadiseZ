--ParadiseZ_Rebound.lua
ParadiseZ = ParadiseZ or {}
LuaEventManager.AddEvent("OnZoneCrossed")

function ParadiseZ.isXYOnZoneEdge(x, y, name, margin)
    if not x or not y or not name then return false end
    margin = margin or 0
    local x1, y1, x2, y2 = ParadiseZ.getZoneArea(name)
    if not x1 or not y1 or not x2 or not y2 then return false end

    return x <= x1 + margin or x >= x2 - margin or y <= y1 + margin or y >= y2 - margin
end


function ParadiseZ.reboundHandler(pl)
    local plX, plY = ParadiseZ.getXY(pl)
    if not plX or not plY then return end

    local name = ParadiseZ.getCurrentZoneName(pl)
    if ParadiseZ.isXYOnZoneEdge(plX, plY, name) then
        print(tostring(saveRebound),'    ',plX,'    ',mplY)
        ParadiseZ.saveRebound(pl, name)
        local sq = getCell():getOrCreateGridSquare(plX, plY, pl:getZ()) 
        ParadiseZ.addTempMarker(sq)
    end
    if name == "Outside" then return end

    local md = pl:getModData()
    local rebound = md.Rebound



    if not rebound or rebound.x ~= plX or rebound.y ~= plY or rebound.name ~= name then
        if ParadiseZ.isXYOnZoneEdge(plX, plY, name) then
            print(tostring(saveRebound),'    ',plX,'    ',mplY)
            ParadiseZ.saveRebound(pl, name)
            local sq = getCell():getOrCreateGridSquare(plX, plY, pl:getZ()) 
            ParadiseZ.addTempMarker(sq)
        end
    else
        if ParadiseZ.isRestricted(pl:getCurrentSquare(), pl) and not ParadiseZ.isXYInZoneMargin(plX, plY, name) then    
            local sq = getCell():getOrCreateGridSquare(plX, plY, pl:getZ()) 
            ParadiseZ.doRebound(pl)

            ParadiseZ.addTempMarker(sq)
        end
    end
end

Events.OnPlayerMove.Remove(ParadiseZ.reboundHandler)
Events.OnPlayerMove.Add(ParadiseZ.reboundHandler)

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
-----------------------            ---------------------------
function ParadiseZ.getFallbackCoord(pl)
    local x, y, z = ParadiseZ.parseCoords()
    if x and y and z then
        return x, y, z
    end
    return nil, nil, nil
end


function ParadiseZ.saveRebound(pl, name)
    pl = pl or getPlayer()
    if not pl then return nil end
    local plX, plY = ParadiseZ.getXY(pl)
    if not plX or not plY then return nil end
    local isOutSide = ParadiseZ.isOutSide(pl)
    local md = pl:getModData()
    name = name or ParadiseZ.getCurrentZoneName(pl)
    local isNil = md['Rebound'] == nil

    if (isOutSide and isNil) or ParadiseZ.isZoneEdge(pl, name) then
        local tab = {
            name = name,
            x = plX,
            y = plY,
            z = pl:getZ()
        }
        md['Rebound'] = tab
        pl:setHaloNote("rebound updated\n:"..tostring(plX)..',    '..(plY),150,250,150,180)
        return tab
    end
    return nil
end
-----------------------            ---------------------------

function ParadiseZ.reboundCountdown()
    local pl = getPlayer() 

    if not  timer:Exists('countdown') then
        timer:Create('countdown', 1, 10, function() 
            if c >= 1 then
                ParadiseZ.doRebound(pl)
            else
                local c = timer:RepsLeft('countdown')
                print(c)
                pl:setHaloNote('Rebound '..tostring(c),150,250,150,180)  
            end

        end)
    else
        ParadiseZ.doRebound(pl)
    end
end

function ParadiseZ.getLastCoord(pl)
    pl = pl or getPlayer()
    if not pl then return ParadiseZ.getFallbackCoord(pl) end
    local md = pl:getModData()

    local rebound = md['Rebound']
    local name = rebound and rebound.name or ParadiseZ.getCurrentZoneName(pl)

    if rebound and rebound.x and rebound.y and rebound.z then     
        return rebound.x, rebound.y, rebound.z        
    end

    return ParadiseZ.getFallbackCoord(pl)
end




function ParadiseZ.doRebound(pl)
    if not SandboxVars.ParadiseZ.ReboundSystem then return end

    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    local x,y,z = ParadiseZ.getLastCoord(pl)
    local md = pl:getModData()
    local rb = md.Rebound
    if not rb then
        local name = ParadiseZ.getCurrentZoneName(pl)
        
        if not (x and y and z) then return end
        rb = {
            name = name,

            x = x,
            y = y,
            z = z,
        }
        md.Rebound = rb

    end

    x = x or rb.x
    y = y or rb.y
    z = z or rb.z
    if not x or not y or not z then return end

    local car = pl:getVehicle()
    if car then
        ParadiseZ.carTp(pl, car)
        return
    end
    ParadiseZ.tp(pl, x, y, z)
    local sq = getCell():getOrCreateGridSquare(x, y, z)
    if not sq then return end
    ParadiseZ.addTempMarker(sq)
end




-----------------------            ---------------------------

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
function ParadiseZ.isZoneEdge(targUser, name, margin)
    margin = margin or 3
    local targ = ParadiseZ.getPl(targUser)
    if not targ then return false end
    if ParadiseZ.isOutSide(targ) then return false end
    name = name or ParadiseZ.getCurrentZoneName(targUser)
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



-----------------------            ---------------------------
