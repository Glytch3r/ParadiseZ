--client\ParadiseZ_Draw.lua
ParadiseZ = ParadiseZ or {}

ParadiseZ.showZoneInfo = true

function ParadiseZ.getZoneInfo(pl)
    pl = pl or getPlayer()
    if not pl then return end

    local name = ParadiseZ.getZoneName(pl)
    local x, y = ParadiseZ.getXY(pl)
    if not (x and y) then return end

    local zoneName = name
    if name ~= tostring(SandboxVars.ParadiseZ.OutsideStr)
        and ParadiseZ.isXYZoneOuter(x, y, name) then
        zoneName = zoneName .. " (Border)"
    end

    local info = { zoneName }

    if ParadiseZ.isKosZone(pl) then table.insert(info, "KosZone") end
    if ParadiseZ.isPveZone(pl) then table.insert(info, "PvE") end
    if ParadiseZ.isBlockedZone(pl) then table.insert(info, "Blocked") end
    if ParadiseZ.isSafeZone(pl) then table.insert(info, "Protected") end
    if ParadiseZ.isRadZone(pl) then table.insert(info, "Radiation") end
    if ParadiseZ.isHuntZone(pl) then table.insert(info, "Hunt") end
    if ParadiseZ.isBlazeZone(pl) then table.insert(info, "Blaze") end
    if ParadiseZ.isFrostZone(pl) then table.insert(info, "Frost") end
    if ParadiseZ.isBombZone(pl) then table.insert(info, "Bomb") end
    if ParadiseZ.isMineZone(pl) then table.insert(info, "MineField") end
    if ParadiseZ.isNoCampZone(pl) then table.insert(info, "NoCamp") end
    if ParadiseZ.isNoFireZone(pl) then table.insert(info, "NoFire") end
    if ParadiseZ.isCageZone(pl) then table.insert(info, "Cage") end
    if ParadiseZ.isPartyZone(pl) then table.insert(info, "Party") end
    if ParadiseZ.isRallyZone(pl) then table.insert(info, "Rally") end
    if ParadiseZ.isSpecialZone(pl) then table.insert(info, "Special") end
    if ParadiseZ.isTradeZone(pl) then table.insert(info, "Trade") end
    if ParadiseZ.isSprintZone(pl) then table.insert(info, "Sprint") end

    table.insert(info, "X:" .. tostring(round(x)) .. "    Y:" .. tostring(round(y)))

    return table.concat(info, "\n")
end


function ParadiseZ.getDrawStr(char)
    if not isIngameState() then return end
    local pl = ParadiseZ.getPl(char)
    if not pl then return end
    local sq = pl:getCurrentSquare()
    if not sq then return end

    local zoneKey

    if ParadiseZ.isPartOfSH(sq) then
        zoneKey = "HQ"
    elseif ParadiseZ.isOutside(pl) then
        zoneKey = tostring(SandboxVars.ParadiseZ.OutsideStr)
    elseif ParadiseZ.isKosZone(pl) then
        zoneKey = "PvP"
    elseif ParadiseZ.isPveZone(pl) then
        zoneKey = "NonPvp"
    elseif ParadiseZ.isBlockedZone(pl) then
        zoneKey = "Blocked"
    elseif ParadiseZ.isSafeZone(pl) then
        zoneKey = "Protected"
    elseif ParadiseZ.isRadZone(pl) then
        zoneKey = "Radiation"
    elseif ParadiseZ.isHuntZone(pl) then
        zoneKey = "Hunt"
    if ParadiseZ.isBlazeZone(pl) then 
        if ParadiseZ.isBlazeZoneFromSquare(sq) and EnvColor.isDay() then
            zoneKey = "Blaze ACTIVE"
        else
            zoneKey = "Blaze"
        end  
    end
    if ParadiseZ.isFrostZone(pl) then
        if ParadiseZ.isFrostZoneFromSquare(sq) and EnvColor.isNight() then
            zoneKey = "Frost ACTIVE"
        else
            zoneKey = "Frost"
        end        
    end
    elseif ParadiseZ.isBombZone(pl) then
        zoneKey = "Bomb"
    elseif ParadiseZ.isMineZone(pl) then
        zoneKey = "MineField"
    elseif ParadiseZ.isNoCampZone(pl) then
        zoneKey = "NoCamp"
    elseif ParadiseZ.isNoFireZone(pl) then
        zoneKey = "NoFire"
    elseif ParadiseZ.isCageZone(pl) then
        zoneKey = "Cage"
    elseif ParadiseZ.isPartyZone(pl) then
        zoneKey = "Party"
    elseif ParadiseZ.isRallyZone(pl) then
        zoneKey = "Rally"
    elseif ParadiseZ.isSpecialZone(pl) then
        zoneKey = "Special"
    elseif ParadiseZ.isTradeZone(pl) then
        zoneKey = "Trade"
    elseif ParadiseZ.isSprintZone(pl) then
        zoneKey = "Sprint"
    elseif ParadiseZ.isRegularZone(pl) then
        zoneKey = "Zone"
    end

    zoneKey = zoneKey or ""

    local reboundText = ""
    local isShowInfo = SandboxVars.ParadiseZ.AdminOnlyZoneInfo

    if getCore():getDebug() or not isShowInfo then
        reboundText = ParadiseZ.getReboundInfo() or ""
    end

    return zoneKey, reboundText
end


function ParadiseZ.getReboundInfo()
    local pl = getPlayer()
    if not pl then return "" end
    if not getCore():getDebug() or pl:isTeleporting() then return "" end

    local modData = pl:getModData()
    local rebound = modData["Rebound"]

    if type(rebound) ~= "table" or not (rebound.x and rebound.y and rebound.z) then
        local x, y, z = ParadiseZ.getFallbackCoord()
        if not (x and y and z) then return "" end
        rebound = { x = x, y = y, z = z, name = "Fallback" }
        modData["Rebound"] = rebound
    end

    return "\n\nREBOUND:\n"
        .. tostring(round(rebound.x)) .. ", "
        .. tostring(round(rebound.y)) .. ", "
        .. tostring(rebound.z)
end


ParadiseZ.lastZone = nil
function ParadiseZ.doDrawZone()
    if not isIngameState() then return end
    local pl = getPlayer()
    if not pl then return end

    ParadiseZ.lastZone = ParadiseZ.lastZone or ParadiseZ.getZoneName(pl)
    local currentZone = ParadiseZ.getZoneName(pl)

    if ParadiseZ.lastZone ~= currentZone then
        ISChat.instance.servermsgTimer = 9000
        ISChat.instance.servermsg = tostring(currentZone)
        ParadiseZ.lastZone = currentZone
    end

    local zoneKey, reboundText = ParadiseZ.getDrawStr(pl)

    local textures = {
        HQ = getTexture("media/textures/zone/ParadiseZ_Zone_HQ.png"),
        Outside = getTexture("media/textures/zone/ParadiseZ_Zone_Outside.png"),
        Zone = getTexture("media/textures/zone/ParadiseZ_Zone_Inside.png"),
        NonPvp = getTexture("media/textures/zone/ParadiseZ_Zone_NonPvP.png"),
        PvP = getTexture("media/textures/zone/ParadiseZ_Zone_PvP.png"),
        Blocked = getTexture("media/textures/zone/ParadiseZ_Zone_Blocked.png"),
        Protected = getTexture("media/textures/zone/ParadiseZ_Zone_Protected.png"),
        Radiation = getTexture("media/textures/zone/ParadiseZ_Zone_Rad.png"),
        Hunt = getTexture("media/textures/zone/ParadiseZ_Zone_Hunt.png"),
        Blaze = getTexture("media/textures/zone/ParadiseZ_Zone_Blaze.png"),
        Frost = getTexture("media/textures/zone/ParadiseZ_Zone_Frost.png"),
        Bomb = getTexture("media/textures/zone/ParadiseZ_Zone_Bomb.png"),
        MineField = getTexture("media/textures/zone/ParadiseZ_Zone_MineField.png"),
        NoCamp = getTexture("media/textures/zone/ParadiseZ_Zone_NoCamp.png"),
        NoFire = getTexture("media/textures/zone/ParadiseZ_Zone_NoFire.png"),
        Cage = getTexture("media/textures/zone/ParadiseZ_Zone_Cage.png"),
        Party = getTexture("media/textures/zone/ParadiseZ_Zone_Party.png"),
        Rally = getTexture("media/textures/zone/ParadiseZ_Zone_Rally.png"),
        Special = getTexture("media/textures/zone/ParadiseZ_Zone_Special.png"),
        Trade = getTexture("media/textures/zone/ParadiseZ_Zone_Trade.png"),
        Sprint = getTexture("media/textures/zone/ParadiseZ_Zone_Sprint.png"),
    }

    local colors = {
        HQ = { r = 0, g = 0, b = 1 },
        Outside = { r = 1, g = 0.4, b = 0 },
        Zone = { r = 1, g = 1, b = 1 },
        NonPvp = { r = 0, g = 1, b = 0 },
        PvP = { r = 0.9, g = 0.2, b = 0.2 },
        Blocked = { r = 0.13, g = 0.13, b = 0.13 },
        Protected = { r = 0.84, g = 0.76, b = 0.67 },
        Radiation = { r = 1, g = 1, b = 1 },
        Hunt = { r = 1, g = 0, b = 0 },
        Blaze = { r = 1, g = 0, b = 0 },
        Frost = { r = 0.5, g = 0.4, b = 1 },
        Bomb = { r = 1, g = 0, b = 0 },
        MineField = { r = 1, g = 0, b = 0 },
        NoCamp = { r = 0.7, g = 0.7, b = 0.7 },
        NoFire = { r = 0.8, g = 0.8, b = 0.8 },
        Cage = { r = 0.7, g = 0.7, b = 0.7 },
        Party = { r = 1, g = 1, b = 0.6 },
        Rally = { r = 0, g = 1, b = 0 },
        Special = { r = 0.9, g = 0.4, b = 0.9 },
        Trade = { r = 0, g = 1, b = 0 },
        Sprint = { r = 1, g = 0.7, b = 0.7 },
    }

    local texture = textures[zoneKey]
    local color = colors[zoneKey] or { r = 1, g = 1, b = 1 }

    local isAdm = string.lower(pl:getAccessLevel()) == "admin"
    local alpha = (not zoneKey or zoneKey == "") and (isAdm and 1 or 0.4) or 0.8

    local zoneInfo = ParadiseZ.getZoneInfo(pl) or ""

    if zoneKey == "Hunt" then
        if  TheRange.isMember(pl) then
            local card = TheRange.getMembershipCard(pl)
            if card then
                zoneInfo = zoneInfo .. TheRange.getCardTotalsString(pl)
            end
        end
    end



    getTextManager():DrawString(UIFont.Medium, 68, 100,
        zoneInfo, color.r, color.g, color.b, alpha)

    if reboundText and reboundText ~= "" then
        getTextManager():DrawString(UIFont.Small, 68, 160,
            reboundText, color.r, color.g, color.b, alpha)
    end

    if texture then
        UIManager.DrawTexture(texture, 68, 70, 32, 32, 0.8)
    end
end


Events.OnPostUIDraw.Remove(ParadiseZ.doDrawZone)
Events.OnPostUIDraw.Add(ParadiseZ.doDrawZone)

