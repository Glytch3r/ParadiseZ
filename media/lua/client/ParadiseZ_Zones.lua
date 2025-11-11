ParadiseZ = ParadiseZ or {}
-----------------------            ---------------------------

function ParadiseZ.getXY(targUser)
    local targ = getPlayerFromUsername(targUser) or getPlayer()
    if not targ then return nil end
    return round(targ:getX()), round(targ:getY())
end

function ParadiseZ.isPlayerInArea(x1, y1, x2, y2, targUser)
    local px, py = ParadiseZ.getXY(targUser)
    if not px or not py then return false end
    local minX, maxX = math.min(x1, x2), math.max(x1, x2)
    local minY, maxY = math.min(y1, y2), math.max(y1, y2)
    return px >= minX and px <= maxX and py >= minY and py <= maxY
end

function ParadiseZ.getZoneArea(name)
    local zone = ParadiseZ.ZoneData[tostring(name)]
    if not zone then return nil, nil, nil, nil end
    return zone.x1, zone.y1, zone.x2, zone.y2
end

function ParadiseZ.isOutSide(targUser)
    if not targUser then return true end
    local px, py = ParadiseZ.getXY(targUser)
    if not px or not py then return true end
    for _, zone in pairs(ParadiseZ.ZoneData) do
        if ParadiseZ.isPlayerInArea(zone.x1, zone.y1, zone.x2, zone.y2, targUser) then
            return false
        end
    end
    return true
end

-----------------------            ---------------------------
function ParadiseZ.getCurrentZoneName(targUser)
    local targ = getPlayerFromUsername(targUser) or getPlayer()
    if not targ then return "Outside" end

    local px, py = ParadiseZ.getXY(targUser)
    if not px then return "Outside" end

    for name, zone in pairs(ParadiseZ.ZoneData) do
        if ParadiseZ.isPlayerInArea(zone.x1, zone.y1, zone.x2, zone.y2, targUser) then
            return name
        end
    end
    return "Outside"
end

-----------------------            ---------------------------

function ParadiseZ.getZoneEdge(targUser, name, margin)
    margin = margin or 3
    local targ = getPlayerFromUsername(targUser) or getPlayer()
    if not targ then return nil end

    name = name or ParadiseZ.getCurrentZoneName(targUser)
    if not name or ParadiseZ.isOutSide(targUser) then return nil end

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

function ParadiseZ.saveRebound(targUser, name)
    name = name or ParadiseZ.getCurrentZoneName(targUser)
    local zX, zY, zZ = ParadiseZ.getZoneEdge(targUser, name)
    local targ = getPlayerFromUsername(targUser) or getPlayer()

    if not zX or targ ~= getPlayer() then      
        return
    end
    
    targ:getModData()['Rebound'] = {
        x = zX,
        y = zY,
        z = zZ
    }
end
LuaEventManager.AddEvent("OnZoneCrossed")
function ParadiseZ.saveTravelInfo(targUser)
    local targ = getPlayerFromUsername(targUser) or getPlayer()
    if not targ or targ ~= getPlayer() then return end

    local name = ParadiseZ.getCurrentZoneName(targUser)
    local modData = targ:getModData()
    local prev = modData['TravelInfo'] and modData['TravelInfo'].cur or "Outside"
    local cur = name

    modData['TravelInfo'] = {
        prev = prev,
        cur = cur,
    }

    if prev ~= cur then
        triggerEvent("OnZoneCrossed", targUser, prev, cur)
    end
end

function ParadiseZ.OnZoneCrossed(targUser, prev, cur)
    print(targUser .. " crossed from " .. prev .. " to " .. cur)
    if ParadiseZ.isOutSide(targUser) then return end
    
end

Events.OnZoneCrossed.Add(ParadiseZ.OnZoneCrossed)
-----------------------            ---------------------------
--[[ 
isInZone
isPvP
isPvE
isNonPvP (player)
isCanToggle
isAdmin

function isCanToggle()

--disable if olayer has pve trait
if isNonPvP then return false end
-- dont know the syntax but lets check for vanilla nonPvP zone theb return true
--admin bypass or not inside zone can toggle
if not isInZone or isAdmin then
 return true
end

--both true or both false allows toggle
if  isPvP == isPvE then 
return true 
end

--if no conditions met then its not toggleable

return false
end

for the saveRebound
modify it to save only if the spot is on 


 ]]

--[[ 
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

    if px >= x1 and px <= x1 + margin then
        return x1, py, pz
    elseif px <= x2 and px >= x2 - margin then
        return x2, py, pz
    elseif py >= y1 and py <= y1 + margin then
        return px, y1, pz
    elseif py <= y2 and py >= y2 - margin then
        return px, y2, pz
    end
    return nil
end

function ParadiseZ.saveRebound(targUser, name)
    name = name or ParadiseZ.getCurrentZoneName(targUser)
    local zX, zY, zZ = ParadiseZ.getZoneEdge(targUser, name)
    local targ = getPlayerFromUsername(targUser) or getPlayer()
    local zData
    if zX == nil or targ ~= getPlayer() then 
        targ:getModData()['Rebound'] = nil
        return 
    end
    zData = {
        x = zX, 
        y = zY, 
        z = zZ
    }
    targ:getModData()['Rebound'] = zData
end 
]]