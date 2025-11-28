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
    if zoneName == "Outside" then return false end
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
    if SandboxVars.ParadiseZ.VanillaNonPvpZone then
        local x = sq:getX()
        local y = sq:getY()
        if x and y and NonPvpZone.getNonPvpZone(x, y) then
            return false
        end
    end
    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == "Outside" then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isKos == true and not zone.isPvE
end

function ParadiseZ.isOutsideSq(sq)
    return ParadiseZ.getZoneName(sq) == "Outside"
end

function ParadiseZ.isBlockedZone(sq)
    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == "Outside" then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isBlocked == true
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
    if zoneName == "Outside" then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isSafe == true
end
-----------------------            ---------------------------

function ParadiseZ.getZoneName(var, var2)
    if type(var) == 'string' then
        var = getPlayerFromUsername(var)
        if var then
            return ParadiseZ.getPlZoneName(var)
        end
    elseif instanceof(var, "IsoPlayer") then
        return ParadiseZ.getPlZoneName(var)
    elseif type(var) == 'number' and var2 then
        return ParadiseZ.getXYZoneName(var, var2)
    elseif instanceof(var, "IsoGridSquare") then
        return ParadiseZ.getSqZoneName(var)
    end
    return "Outside"
end



-----------------------            ---------------------------


function ParadiseZ.getPlZoneName(pl)
    if not isIngameState() then return "Outside" end
    local targ = ParadiseZ.getPl(pl)
    if not targ then return "Outside" end
    local px, py = ParadiseZ.getXY(targ)
    if not px then return "Outside" end
    if not ParadiseZ.ZoneData then return "Outside" end
    for name, zone in pairs(ParadiseZ.ZoneData) do
        if zone and zone.x1 and zone.y1 and zone.x2 and zone.y2 then
            if ParadiseZ.isPlayerInArea(zone.x1, zone.y1, zone.x2, zone.y2, targ) then
                return tostring(name)
            end
        end
    end
    return "Outside"
end

function ParadiseZ.getSqZoneName(sq)
    if not sq then return "Outside" end
    local x = sq:getX()
    local y = sq:getY()
    if not x or not y then return "Outside" end
    if not ParadiseZ.ZoneData then return "Outside" end
    for name, zone in pairs(ParadiseZ.ZoneData) do
        if x >= zone.x1 and x <= zone.x2 and y >= zone.y1 and y <= zone.y2 then
            return name
        end
    end
    return "Outside"
end

function ParadiseZ.getXYZoneName(x, y)
    if not x or not y then return "Outside" end
    if not ParadiseZ.ZoneData then return "Outside" end
    for name, zone in pairs(ParadiseZ.ZoneData) do
        if x >= zone.x1 and x <= zone.x2 and y >= zone.y1 and y <= zone.y2 then
            return name
        end
    end
    return "Outside"
end
