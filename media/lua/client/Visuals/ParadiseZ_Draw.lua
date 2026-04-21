ParadiseZ = ParadiseZ or {}
ParadiseZ.showZoneInfo = true
ParadiseZ.lastZone = nil
LuaEventManager.AddEvent("OnZoneCrossed")


function ParadiseZ.OnZoneCrossed(lastZoneName, curZoneName)
    if not getCore():getDebug() then return end
    print("Previous Zone: "..tostring(lastZoneName))
    print("Current Zone: "..tostring(curZoneName))    
end
Events.OnZoneCrossed.Add(ParadiseZ.OnZoneCrossed)

function ParadiseZ.getZoneHeader(pl)
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
    table.insert(info, "X: " .. tostring(round(x)) .. "    Y: " .. tostring(round(y)))
    return table.concat(info, "\n")
end

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
    local info = { }
    if ParadiseZ.isKosZone(pl) then table.insert(info, "KoS") end
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
    return table.concat(info, "\n")
end

function ParadiseZ.getDrawStr(char)
    if not isIngameState() then return end
    local pl = ParadiseZ.getPlOrSq(char)
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
    elseif ParadiseZ.isBlazeZone(pl) then
        if ParadiseZ.isBlazeZoneFromSquare(sq) and EnvColor.isDay() then
            zoneKey = "Blaze ACTIVE"
        else
            zoneKey = "Blaze"
        end
    elseif ParadiseZ.isFrostZone(pl) then
        if ParadiseZ.isFrostZoneFromSquare(sq) and EnvColor.isNight() then
            zoneKey = "Frost ACTIVE"
        else
            zoneKey = "Frost"
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
        .. tostring(rebound.z) .. "\n"
end

function ParadiseZ.getZoneIcons(pl)
    local icons = {}
    
    if ParadiseZ.isKosZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_PvP.png"), label = "KoS", color = { r = 0.9, g = 0.2, b = 0.2 } })
    end
    if ParadiseZ.isPveZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_NonPvP.png"), label = "NonPvp", color = { r = 0, g = 1, b = 0 } })
    end
    if ParadiseZ.isBlockedZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Blocked.png"), label = "Blocked", color = { r = 0.13, g = 0.13, b = 0.13 } })
    end
    if ParadiseZ.isSafeZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Protected.png"), label = "Protected", color = { r = 0.84, g = 0.76, b = 0.67 } })
    end
    if ParadiseZ.isRadZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Rad.png"), label = "Radiation", color = { r = 1, g = 1, b = 1 } })
    end
    if ParadiseZ.isHuntZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Hunt.png"), label = "Hunt", color = { r = 1, g = 0, b = 0 } })
    end
    if ParadiseZ.isBlazeZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Blaze.png"), label = "Blaze", color = { r = 1, g = 0, b = 0 } })
    end
    if ParadiseZ.isFrostZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Frost.png"), label = "Frost", color = { r = 0.5, g = 0.4, b = 1 } })
    end
    if ParadiseZ.isBombZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Bomb.png"), label = "Bomb", color = { r = 1, g = 0, b = 0 } })
    end
    if ParadiseZ.isMineZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_MineField.png"), label = "MineField", color = { r = 1, g = 0, b = 0 } })
    end
    if ParadiseZ.isNoCampZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_NoCamp.png"), label = "NoCamp", color = { r = 0.7, g = 0.7, b = 0.7 } })
    end
    if ParadiseZ.isNoFireZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_NoFire.png"), label = "NoFire", color = { r = 0.8, g = 0.8, b = 0.8 } })
    end
    if ParadiseZ.isCageZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Cage.png"), label = "Cage", color = { r = 0.7, g = 0.7, b = 0.7 } })
    end
    if ParadiseZ.isPartyZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Party.png"), label = "Party", color = { r = 1, g = 1, b = 0.6 } })
    end
    if ParadiseZ.isRallyZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Rally.png"), label = "Rally", color = { r = 0, g = 1, b = 0 } })
    end
    if ParadiseZ.isSpecialZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Special.png"), label = "Special", color = { r = 0.9, g = 0.4, b = 0.9 } })
    end
    if ParadiseZ.isTradeZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Trade.png"), label = "Trade", color = { r = 0, g = 1, b = 0 } })
    end
    if ParadiseZ.isSprintZone(pl) then
        table.insert(icons, { texture = getTexture("media/textures/zone/ParadiseZ_Zone_Sprint.png"), label = "Sprint", color = { r = 1, g = 0.7, b = 0.7 } })
    end
    return icons
end

function ParadiseZ.getStatusIcons(pl)
    local icons = {}
    if pl:HasTrait("InjuredPvP") then
        table.insert(icons, { texture = getTexture("media/ui/Traits/trait_InjuredPvP.png"), label = "Injured" })
    end 
    if pl:HasTrait("Caged") then
        table.insert(icons, { texture = getTexture("media/ui/Traits/trait_Caged.png"), label = "Caged" })
    end
    return icons
end


-----------------------            ---------------------------


function ParadiseZ.doDrawZone()
    if not isIngameState() then return end
    local pl = getPlayer()
    if not pl then return end
    local md = pl:getModData()

    local curZoneName = ParadiseZ.getZoneName(pl)
    if not curZoneName then return end
    
    if md['lastZone'] == nil then
        md['lastZone'] = curZoneName
    end

    if md['lastZone'] ~= curZoneName then
        triggerEvent("OnZoneCrossed", md['lastZone'], curZoneName)
        ParadiseZ.ZoneHighlighter = ParadiseZ.ZoneHighlighter or false
        local isOut = curZoneName == tostring(SandboxVars.ParadiseZ.OutsideStr)
        if (ParadiseZ.ZoneEditorWindow.instance or ParadiseZ.ZoneHighlighter ) and not isOut then 
            ParadiseZ.ZoneHighlight()
        end
        ISChat.instance.servermsgTimer = 9000
        ISChat.instance.servermsg = tostring(curZoneName)
        md['lastZone'] = curZoneName
        
        if isOut then 
            ParadiseZ.clearZoneHighlights()
        end
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

    local texture = textures[zoneKey]
    local isAdm = string.lower(pl:getAccessLevel()) == "admin"
    local zoneHeader = ParadiseZ.getZoneHeader(pl) or ""
    local zoneInfo = ParadiseZ.getZoneInfo(pl) or ""

    if zoneKey == "Hunt" then
        if TheRange.isMember(pl) then
            local card = TheRange.getMembershipCard(pl)
            if card then
                zoneInfo = zoneInfo .. TheRange.getCardTotalsString(pl)
            end
        end
    end
    
    local alpha = (not zoneKey or zoneKey == "") and (isAdm and 1 or 0.4) or 0.8
    md['HUDSettings'] = md['HUDSettings'] or {
        x = 68,
        y = 73,
    }
    local baseX = md['HUDSettings'].x
    local baseY = md['HUDSettings'].y
    local headerY = baseY
    getTextManager():DrawString(UIFont.Large, baseX, headerY, zoneHeader, 1, 1, 1, alpha)
    
    local iconX = baseX
    local iconY = headerY + 50
    local spacer = 24
    local strX = iconX + spacer
    local strY = iconY + spacer
    local currentY = iconY
    local traitsX = baseX + 162

    local zoneIcons = ParadiseZ.getZoneIcons(pl)
    for i = 1, #zoneIcons do
        if zoneIcons[i].texture then
            UIManager.DrawTexture(zoneIcons[i].texture, iconX, currentY, 24, 24, 0.8)
            local label = tostring(zoneIcons[i].label)
            local r, g, b = ParadiseZ.getZoneSandboxColor(label)
            getTextManager():DrawString(UIFont.Medium, strX + spacer, currentY, label, r, g, b, alpha)
            currentY = currentY + 26
        end
    end
    local statusIcons = ParadiseZ.getStatusIcons(pl)
    for i = 1, #statusIcons do
        if statusIcons[i].texture then
            UIManager.DrawTexture(statusIcons[i].texture, traitsX, 50, 24, 24, 1)
            traitsX = traitsX + 26
        end
    end
    
    local reboundY = baseY + 100 + (currentY - iconY)
    if reboundText and reboundText ~= "" then
        getTextManager():DrawString(UIFont.Small, baseX, reboundY, reboundText, 1, 1, 1, alpha)
    end
end
Events.OnPostUIDraw.Remove(ParadiseZ.doDrawZone)
Events.OnPostUIDraw.Add(ParadiseZ.doDrawZone)
-----------------------            ---------------------------
function ParadiseZ.initHUD()
    local pl = getPlayer() 
    if not pl then return end
    local md = pl:getModData()
    md['HUDSettings'] = md['HUDSettings'] or {
        x = 68,
        y = 73,
    }
end
Events.OnCreatePlayer.Add(ParadiseZ.initHUD)