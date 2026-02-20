--client\ParadiseZ_Zones.lua
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

function ParadiseZ.isOutside(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    return ParadiseZ.getZoneName(targ) == tostring(SandboxVars.ParadiseZ.OutsideStr)
end
--[[ 
function ParadiseZ.isRegularZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end

    local isKosZone = ParadiseZ.isKosZone(targ)
    local isPveZone = ParadiseZ.isPveZone(targ)
    local isOutsideZone = ParadiseZ.isOutside(targ)

    if isOutsideZone then
        return false
    end

    if (isKosZone and isPveZone) or (not isKosZone and not isPveZone) then
        return true
    end

    return false
end
 ]]
-----------------------            ---------------------------
function ParadiseZ.isHuntZone(pl)
    local targ = ParadiseZ.getPl(pl)
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
    local targ = ParadiseZ.getPl(pl)
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
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isKos == true
end

function ParadiseZ.isBlockedZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isBlocked == true
end

-----------------------            ---------------------------

function ParadiseZ.isRegularZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    
    if zone.isKos or zone.isPvE or zone.isSafe or zone.isBlocked or
       zone.isRad or zone.isHunt or zone.isBlaze or zone.isFrost or
       zone.isBomb or zone.isMine or zone.isNoCamp or zone.isNoFire or
       zone.isCage or zone.isParty or zone.isRally or zone.isSpecial or
       zone.isTrade or zone.isSprint then
        return false
    end
    
    return true
end


function ParadiseZ.isBlazeZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isBlaze == true
end

function ParadiseZ.isFrostZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isFrost == true
end

function ParadiseZ.isBombZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isBomb == true
end

function ParadiseZ.isMineZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isMine == true
end

function ParadiseZ.isNoCampZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isNoCamp == true
end

function ParadiseZ.isNoFireZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isNoFire == true
end

function ParadiseZ.isCageZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isCage == true
end

function ParadiseZ.isPartyZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isParty == true
end

function ParadiseZ.isRallyZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isRally == true
end

function ParadiseZ.isSpecialZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isSpecial == true
end

function ParadiseZ.isTradeZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isTrade == true
end

function ParadiseZ.isSprintZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getZoneName(targ)
    if zoneName == tostring(SandboxVars.ParadiseZ.OutsideStr) then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isSprint == true
end
