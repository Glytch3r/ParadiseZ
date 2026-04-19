--client\ParadiseZ_Zones.lua
ParadiseZ = ParadiseZ or {}



function ParadiseZ.getPlOrSq(char)
    if not char then return getPlayer() end
    if type(char) == "string" then
        return getPlayerFromUsername(char)
    elseif instanceof(char, "IsoPlayer") then
        return char
    elseif instanceof(char, "IsoGridSquare")  then
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

function ParadiseZ.isOutside(pl)
    local targ = ParadiseZ.getPlOrSq(pl)
    if not targ then return false end
    return ParadiseZ.getZoneName(targ) == tostring(SandboxVars.ParadiseZ.OutsideStr)
end
-----------------------            ---------------------------
function ParadiseZ.isHuntZone(pl)
    local targ = ParadiseZ.getPlOrSq(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isHunt == true
end

function ParadiseZ.isHuntZoneSq(sq)
    if not sq then return false end   
    local zoneName = ParadiseZ.getZoneName(sq)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isHunt == true
end
-----------------------            ---------------------------

function ParadiseZ.isPveZone(pl)
    local targ = ParadiseZ.getPlOrSq(pl)
    if not targ then return false end

    if SandboxVars.ParadiseZpvp.VanillaNonPvpZone then
        local x, y = targ:getX(), targ:getY()
        if x and y and NonPvpZone.getNonPvpZone(x, y) then
            return true
        end
    end

    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isPvE == true
end

function ParadiseZ.isKosZone(pl)
    local targ = ParadiseZ.getPlOrSq(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isKos == true
end

function ParadiseZ.isBlockedZone(pl)
    local targ = ParadiseZ.getPlOrSq(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isBlocked == true
end

-----------------------            ---------------------------

function ParadiseZ.isTypelessZone(pl)
    local targ = ParadiseZ.getPlOrSq(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    
    if zone.isKos or zone.isPvE or zone.isSafe or zone.isBlocked or zone.isRad or zone.isHunt or zone.isBlaze or zone.isFrost or zone.isBomb or zone.isMine or zone.isNoCamp or zone.isNoFire or zone.isCage or zone.isParty or zone.isRally or zone.isSpecial or zone.isTrade or zone.isSprint then
        return false
    end
    return true
end


function ParadiseZ.checkZoneFlag(pl, flag)
    local targ = ParadiseZ.getPlOrSq(pl)
    if not targ then return false end

    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end

    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end

    return zone[flag] == true
end

function ParadiseZ.isNoFireZone(pl)  return ParadiseZ.checkZoneFlag(pl, "isNoFire") end
function ParadiseZ.isBlazeZone(pl)   return ParadiseZ.checkZoneFlag(pl, "isBlaze") end
function ParadiseZ.isFrostZone(pl)   return ParadiseZ.checkZoneFlag(pl, "isFrost") end
function ParadiseZ.isBombZone(pl)    return ParadiseZ.checkZoneFlag(pl, "isBomb") end
function ParadiseZ.isMineZone(pl)    return ParadiseZ.checkZoneFlag(pl, "isMine") end
function ParadiseZ.isNoCampZone(pl)  return ParadiseZ.checkZoneFlag(pl, "isNoCamp") end
function ParadiseZ.isCageZone(pl)    return ParadiseZ.checkZoneFlag(pl, "isCage") end
function ParadiseZ.isPartyZone(pl)   return ParadiseZ.checkZoneFlag(pl, "isParty") end
function ParadiseZ.isRallyZone(pl)   return ParadiseZ.checkZoneFlag(pl, "isRally") end
function ParadiseZ.isSpecialZone(pl) return ParadiseZ.checkZoneFlag(pl, "isSpecial") end
function ParadiseZ.isTradeZone(pl)   return ParadiseZ.checkZoneFlag(pl, "isTrade") end
function ParadiseZ.isSprintZone(pl)  return ParadiseZ.checkZoneFlag(pl, "isSprint") end