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
