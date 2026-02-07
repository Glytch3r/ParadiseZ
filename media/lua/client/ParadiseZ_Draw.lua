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
    if name ~= tostring(SandboxVars.ParadiseZ.OutsideStr) and ParadiseZ.isXYZoneOuter(x, y, name) then
        zoneName = zoneName .. " (Border)"
    end

    local info = { zoneName }

    if ParadiseZ.isKosZone(pl) then
        table.insert(info, "KosZone")
    end
    if ParadiseZ.isPveZone(pl) then
        table.insert(info, "PvE")
    end
    if ParadiseZ.isBlockedZone(pl) then
        table.insert(info, "Blocked")
    end    
    if ParadiseZ.isRadZone(pl) then
        table.insert(info, "Radiation")
    end

    table.insert(info, "X:" .. tostring(round(x)) .. "    Y:" .. tostring(round(y)))

    return table.concat(info, "\n")
end

function ParadiseZ.getDrawStr(char)
    if not isIngameState() then return end
    local pl = ParadiseZ.getPl(char)
    if not pl then return end

    local sq = pl:getCurrentSquare()
    if not sq then return end

    local str
    if ParadiseZ.isPartOfSH(sq) then
        str = "HQ"
    elseif ParadiseZ.isOutside(pl) then
        str = tostring(SandboxVars.ParadiseZ.OutsideStr)
    elseif ParadiseZ.isKosZone(pl) then
        str = "PvP"
    elseif ParadiseZ.isPveZone(pl) then
        str = "NonPvp"
    elseif ParadiseZ.isBlockedZone(pl) then
        str = "Blocked"
    elseif ParadiseZ.isSafeZone(pl) then
        str = "Protected"
    elseif ParadiseZ.isRadZone(pl) then
        str = "Radiation"
    elseif ParadiseZ.isRegularZone(pl) then
        str = "Zone"
    end

    return str or ""
end

function ParadiseZ.getReboundData()
    local data = getPlayer():getModData()
    local rebound = data["Rebound"]
    if not rebound or not rebound.name then return "" end
    local x, y, z = rebound.x, rebound.y, rebound.z
    if not (x and y and z) then return "" end
    return "Rebound:" .. tostring(rebound.name) .. "\nCoord:   X " .. tostring(round(x)) .. "   ,   Y " .. tostring(round(y))
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

    return "\nREBOUND: \n" .. tostring(round(rebound.x)) .. ", " .. tostring(round(rebound.y)) .. ", " .. tostring(rebound.z)
end

function ParadiseZ.doDrawZone()
    if not isIngameState() then return end
    local pl = getPlayer()
    if not pl then return end

    local str = ParadiseZ.getDrawStr(pl)

    local textures = {
        HQ = getTexture("media/textures/zone/ParadiseZ_Zone_HQ.png"),
        Outside = getTexture("media/textures/zone/ParadiseZ_Zone_Outside.png"),
        Zone = getTexture("media/textures/zone/ParadiseZ_Zone_Inside.png"),
        NonPvp = getTexture("media/textures/zone/ParadiseZ_Zone_NonPvP.png"),
        PvP = getTexture("media/textures/zone/ParadiseZ_Zone_PvP.png"),
        Blocked = getTexture("media/textures/zone/ParadiseZ_Zone_Blocked.png"),
        Protected = getTexture("media/textures/zone/ParadiseZ_Zone_Protected.png"),
        Radiation = getTexture("media/textures/zone/ParadiseZ_Zone_Rad.png"),


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

    }

    local texture = textures[str]
    local color = colors[str] or { r = 1, g = 1, b = 1 }
    local isAdm = string.lower(pl:getAccessLevel()) == "admin"
    local alpha = (not str or str == "") and (isAdm and 0.1 or 0) or 0.8
    local isShowInfo = SandboxVars.ParadiseZ.AdminOnlyZoneInfo
    local zoneInfo = ParadiseZ.getZoneInfo(pl) or ""
    local reboundInfo

    if isAdm or not isShowInfo then
        reboundInfo = ParadiseZ.getReboundInfo() or ""
    end

    getTextManager():DrawString(UIFont.Medium, 68, 100, zoneInfo, color.r, color.g, color.b, alpha)

    if reboundInfo and reboundInfo ~= "" then
        getTextManager():DrawString(UIFont.Small, 68, 140, reboundInfo, color.r, color.g, color.b, alpha)
    end

    if texture then
        UIManager.DrawTexture(texture, 68, 70, 32, 32, 0.8)
    end
end

Events.OnPostUIDraw.Remove(ParadiseZ.doDrawZone)
Events.OnPostUIDraw.Add(ParadiseZ.doDrawZone)
