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
    local targ = ParadiseZ.getPl(pl)
    if not targ then return nil end
    return round(targ:getX()), round(targ:getY())
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

function ParadiseZ.getZoneArea(name)
    local zone = ParadiseZ.ZoneData[tostring(name)]
    if not zone then return nil, nil, nil, nil end
    return zone.x1, zone.y1, zone.x2, zone.y2
end

function ParadiseZ.isOutSide(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return true end
    local px, py = ParadiseZ.getXY(targ)
    if not px or not py then return true end
    for _, zone in pairs(ParadiseZ.ZoneData) do
        if ParadiseZ.isPlayerInArea(zone.x1, zone.y1, zone.x2, zone.y2, targ) then
            return false
        end
    end
    return true
end

function ParadiseZ.getCurrentZoneName(pl)
    if not isIngameState() then return "Outside" end
    local targ = ParadiseZ.getPl(pl)
    if not targ then return "Outside" end
    local px, py = ParadiseZ.getXY(targ)
    if not px then return "Outside" end
    for name, zone in pairs(ParadiseZ.ZoneData) do
        if ParadiseZ.isPlayerInArea(zone.x1, zone.y1, zone.x2, zone.y2, targ) then
            return name
        end
    end
    return "Outside"
end

function ParadiseZ.isRegularZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local isPvpZone = ParadiseZ.isPvpZone(targ)
    local isPveZone = ParadiseZ.isPveZone(targ)
    local isOutsideZone = ParadiseZ.isOutsideZone(targ)    

    if isOutsideZone then
        return false 
    end
    if not ParadiseZ.isZoneEnabled(pl) then
        return false 
    end
    if isPvpZone ~= isPveZone then
        return false
    end
    if not isPvpZone and not isPveZone then
        return false
    end
  
    return true
end

function ParadiseZ.isPveZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local x, y = targ:getX(), targ:getY()
    if x and y and NonPvpZone.getNonPvpZone(x, y) then
        return true
    end
    local zoneName = ParadiseZ.getCurrentZoneName(targ)
    if zoneName == "Outside" then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isPvE == true and not zone.isPvP
end

function ParadiseZ.isPvpZone(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local zoneName = ParadiseZ.getCurrentZoneName(targ)
    if zoneName == "Outside" then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isPvP == true and not zone.isPvE 
end




function ParadiseZ.isOutsideZone(pl)
    local targ = ParadiseZ.getPl(pl)
    local zoneName = ParadiseZ.getCurrentZoneName(targ)
    return zoneName == "Outside"
end

function ParadiseZ.isZoneEnabled(pl)
    local targ = ParadiseZ.getPl(pl)
    local zoneName = ParadiseZ.getCurrentZoneName(targ)
    if zoneName == "Outside" then return false end
    local zone = ParadiseZ.ZoneData[zoneName]
    if not zone then return false end
    return zone.isBlocked ~= true
end


function ParadiseZ.pvpMode(pl)
    if not isIngameState() then return end
    local targ = ParadiseZ.getPl(pl)
    if not targ then return end
    local plNum = targ:getPlayerNum()
    local data = getPlayerData(plNum)
    if not data then return end
    local safe = targ:getSafety()
    local isEnabled = safe:isEnabled()
    local isPvpZone = ParadiseZ.isPvpZone(targ)
    local isPvE = ParadiseZ.isNonPvP(targ)
    local isOutsideZone = ParadiseZ.isOutsideZone(targ)
    local isVisible = data.safetyUI:getIsVisible()
    if isPvE then
        if isVisible then
            data.safetyUI:setVisible(false)
            data.safetyUI:removeFromUIManager()
        end
        if not isEnabled then
            getPlayerSafetyUI(plNum):toggleSafety()
        end
        return
    else
        if not isVisible then
            data.safetyUI:setVisible(true)
            data.safetyUI:addToUIManager()
        end
        if not isOutsideZone then
            if isPvpZone and isEnabled then
                getPlayerSafetyUI(plNum):toggleSafety()
            elseif (not isPvpZone) and not isEnabled then
                getPlayerSafetyUI(plNum):toggleSafety()
            end
        end
    end
end

function ParadiseZ.isCanToggle(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return false end
    local isPvpZone = ParadiseZ.isPvpZone(targ)
    local isNonPvP = ParadiseZ.isNonPvP(targ)
    local isPvE = ParadiseZ.isPvE(pl)
    local isOutsideZone = ParadiseZ.isOutsideZone(targ)
    if not isPvE and (isPvpZone == isNonPvP or isOutsideZone) then
        return true
    end
    return false
end

function ParadiseZ.doToggle(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return end
    local plNum = targ:getPlayerNum()
    if getPlayerSafetyUI(plNum) and ParadiseZ.isCanToggle(targ) then
        getPlayerSafetyUI(plNum):toggleSafety()
    end
end


--[[ 
function ParadiseZ.doToggle(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return end
    local plNum = targ:getPlayerNum()
    local safe = targ:getSafety()
    local isEnabled = safe:isEnabled()
    local isPvpZone = ParadiseZ.isPvpZone(targ)
    local isNonPvP = ParadiseZ.isNonPvP(targ)
    local isPvE = ParadiseZ.isNonPvP(targ)
    local isOutsideZone = ParadiseZ.isOutsideZone(targ)
    local canToggle = false
    if not isPvE and (isPvpZone == isNonPvP) then
        canToggle = true
    end
    if getPlayerSafetyUI(plNum) and canToggle then
        getPlayerSafetyUI(plNum):toggleSafety()
    end
end
 ]]