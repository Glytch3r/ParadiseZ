--ParadiseZ_Squares.lua
ParadiseZ = ParadiseZ or {}

function ParadiseZ.getSprName(obj)
    if not obj then return nil end
    local spr = obj:getSprite()
    return spr and spr:getName() or nil
end



-----------------------            ---------------------------
function ParadiseZ.isSameZone(pl, sq)
    pl = pl or getPlayer()
    if not sq then return false end
    local plZone = ParadiseZ.getZoneName(pl)
    local checkZone = ParadiseZ.getZoneName(sq)
    return plZone == checkZone
end

function ParadiseZ.isPveZoneFromSquare(sq)
    if not sq then return false end
    if SandboxVars.ParadiseZ.VanillaNonPvpZone then
        local x = sq:getX()
        local y = sq:getY()
        if x and y and NonPvpZone.getNonPvpZone(x, y) then
            return true
        end
    end
    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isPvE == true and not zone.isKos
end


function ParadiseZ.isSquareWalkable(sq)
    if not sq then return false end
    if sq:isSolid() then return false end
    --if sq:getMovingObjects():size() > 0 then return false end
    local props = sq:getProperties()
    if props and props:Is(IsoFlagType.solid) then return false end
    if props and props:Is(IsoFlagType.solidtrans) then return false end
    return true
end
--[[ 
local sq = getPlayer():getSquare() 
print(ParadiseZ.isSquareWalkable(sq))

 ]]
function ParadiseZ.isKosZoneFromSquare(sq)
    if not sq then return false end
    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end

    if SandboxVars.ParadiseZ.VanillaNonPvpZone then
        local x = sq:getX()
        local y = sq:getY()
        if x and y and NonPvpZone.getNonPvpZone(x, y) then
            return true or zone.isKos == true
        end
    end

    return zone.isKos == true
end

function ParadiseZ.isOutsideSq(sq)
    return ParadiseZ.getZoneName(sq) == tostring(SandboxVars.ParadiseZ.OutsideStr)
end


function ParadiseZ.isSafeZoneFromSquare(sq)
    if not sq then return false end
    if SandboxVars.ParadiseZ.VanillaNonPvpZone then
        local x = sq:getX()
        local y = sq:getY()
        if x and y and NonPvpZone.getNonPvpZone(x, y) then
            return false
        end
    end
    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isSafe == true
end
-----------------------     name*       ---------------------------

--[[ 
ParadiseZ.getZoneName()             -- defaults to pl
ParadiseZ.getZoneName(pl)           -- pl
ParadiseZ.getZoneName("username")   -- player by name
ParadiseZ.getZoneName(sq)           -- IsoGridSquare
ParadiseZ.getZoneName(10, 20)       -- x, y
 ]]

function ParadiseZ.getZoneName(var, var2)    
    local pl = getPlayer()
    if type(var) == "string" then
        pl = getPlayerFromUsername(var)
        if pl then
            return ParadiseZ.getPlZoneName(pl)
        end
    elseif instanceof(var, "IsoPlayer") then
        return ParadiseZ.getPlZoneName(var)
    elseif type(var) == "number" and type(var2) == "number" then
        return ParadiseZ.getXYZoneName(var, var2)
    elseif instanceof(var, "IsoGridSquare") then
        return ParadiseZ.getSqZoneName(var)
    end
    if pl then
        return ParadiseZ.getPlZoneName(pl)
    end
    return tostring(SandboxVars.ParadiseZ.OutsideStr)
end
--*tostring(SandboxVars.ParadiseZ.OutsideStr)
function ParadiseZ.getXYZoneName(x, y)
    local outStr = tostring(SandboxVars.ParadiseZ.OutsideStr)
    if type(ParadiseZ.ZoneData) ~= "table" then return outStr end

    local matches = {}

    for name, zone in pairs(ParadiseZ.ZoneData) do
        if zone and zone.x1 and zone.x2 and zone.y1 and zone.y2 then
            if x >= zone.x1 and x <= zone.x2 and y >= zone.y1 and y <= zone.y2 then
                local area = (zone.x2 - zone.x1) * (zone.y2 - zone.y1)
                matches[#matches + 1] = {name = name, area = area}
            end
        end
    end

    if #matches == 0 then
        return tostring(SandboxVars.ParadiseZ.OutsideStr)
    end

    table.sort(matches, function(a, b) return a.area < b.area end)

    return matches[1].name
end

function ParadiseZ.getPlZoneName(pl)
    local outStr = tostring(SandboxVars.ParadiseZ.OutsideStr)
    
    if not pl then return outStr end
    local sq = pl:getCurrentSquare()
    if not sq then return outStr end
    return ParadiseZ.getXYZoneName(sq:getX(), sq:getY())
end

function ParadiseZ.getSqZoneName(sq)
    if not sq then return tostring(SandboxVars.ParadiseZ.OutsideStr) end

    return ParadiseZ.getXYZoneName(sq:getX(), sq:getY())
end

-----------------------    zone*        ---------------------------
--[[ 
function ParadiseZ.getZone(var, var2)
    local name

    if type(var) == "string" then
        local pl = getPlayerFromUsername(var)
        if pl then
            name = ParadiseZ.getPlZoneName(pl)
        end

    elseif instanceof(var, "IsoPlayer") then
        name = ParadiseZ.getPlZoneName(var)

    elseif type(var) == "number" and type(var2) == "number" then
        name = ParadiseZ.getXYZoneName(var, var2)

    elseif instanceof(var, "IsoGridSquare") then
        name = ParadiseZ.getSqZoneName(var)
    end

    if not name then
        local pl = getPlayer()
        if pl then
            name = ParadiseZ.getPlZoneName(pl)
        else
            return nil
        end
    end

    return ParadiseZ.ZoneData[name]
end
 ]]