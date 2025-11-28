-- client/ParadiseZ_Zones.lua
ParadiseZ = ParadiseZ or {}


function ParadiseZ.getPl(char)
    if not char then return getPlayer() end
    if type(char) == "string" then
        return getPlayerFromUsername(char)
    elseif instanceof(char, "IsoPlayer") then
        return char
    end
    return nil
end

function ParadiseZ.getXY(pl)
    if not pl then return nil, nil end
    local sq = pl:getCurrentSquare()
    if not sq then return nil, nil end
    return sq:getX(), sq:getY()
end

--[[ 
function ParadiseZ.isOutSide(pl)
    local pl = ParadiseZ.getPl(pl)
    if not pl then return true end
    local px, py = ParadiseZ.getXY(pl)
    if not px or not py then return true end
    if not ParadiseZ.ZoneData then return end
    for _, zone in pairs(ParadiseZ.ZoneData) do
        if ParadiseZ.isPlayerInArea(zone.x1, zone.y1, zone.x2, zone.y2, targ) then 
            return false
        end
    end
    return true
end
 ]]
function ParadiseZ.isOutSide(pl)
    local pl = ParadiseZ.getPl(pl)
    local zoneName = ParadiseZ.getZoneName(pl)
    if zoneName == "Outside" then return true end
    return false
end


function ParadiseZ.isRegularZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local isKosZone = ParadiseZ.isKosZone(targ)
    local isPveZone = ParadiseZ.isPveZone(targ)
    local isOutsideZone = ParadiseZ.isOutsideZone(targ)    

    if isOutsideZone then
        return false     
    elseif (isKosZone and isPveZone) or (not isKosZone and not isPveZone) then   
        return true
    elseif (isKosZone and not isPveZone) or (isPveZone and not isKosZone) then
        return false
    end
    return true
end

function ParadiseZ.isPveZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    if SandboxVars.ParadiseZ.VanillaNonPvpZone then
        local x, y = targ:getX(), targ:getY()
        if x and y and NonPvpZone.getNonPvpZone(x, y) then
            return true
        end
    end

    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == "Outside" then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isPvE == true and not zone.isKos
end

function ParadiseZ.isKosZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == "Outside" then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isKos == true and not zone.isPvE 
end




function ParadiseZ.isOutsideZone(pl)
    local targ = ParadiseZ.getPl(pl)
    local zoneName = ParadiseZ.getZoneName(targ)
    return zoneName == "Outside"
end


function ParadiseZ.isBlockedZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == "Outside" then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isBlocked == true
end

