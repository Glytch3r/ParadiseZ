ParadiseZ = ParadiseZ or {}

ParadiseZ.showZoneInfo = true

--[[ 
    ParadiseZ.showZoneInfo = false
 ]]

 function ParadiseZ.dbgZoneInfo(pl)
    local targ = ParadiseZ.getPl(pl)
    if not targ then return end
    local user = targ:getUsername()
    if not user then return end
    local name = ParadiseZ.getCurrentZoneName(user)
    local isOutsideZone = ParadiseZ.isOutsideZone(user)
    local isKosZone = ParadiseZ.isKosZone(user)
    local x, y = ParadiseZ.getXY(targ)


    if ParadiseZ.isPvE(pl) or (ParadiseZ.isPveZone(pl) and ParadiseZ.isZoneIsBlocked(pl)) then
        LifeBarUI.hide()
        return 
    end

    if ParadiseZ.isRegularZone(pl) or ((ParadiseZ.isKosZone(pl) and ParadiseZ.isZoneIsBlocked(pl))) or ParadiseZ.isOutsideZone(pl)  then
        LifeBarUI.show()
    end

    if getCore():getDebug() then  
        targ:setHaloNote("zone name: " .. tostring(name) ..
            "\nisKosZone: " .. tostring(isKosZone) ..
            "\nisOutsideZone: " .. tostring(isOutsideZone) ..
            "\nX: " .. tostring(x) ..
            " - Y: " .. tostring(y), 150, 250, 150, 900)
    end
    
end

Events.OnPlayerUpdate.Remove(ParadiseZ.dbgZoneInfo)
Events.OnPlayerUpdate.Add(ParadiseZ.dbgZoneInfo)


function ParadiseZ.getDrawStr(char)
    if not isIngameState() then return end
    local pl = ParadiseZ.getPl(char)
    if not pl then return end

    local sq = pl:getCurrentSquare()
    if not sq then return end

    local str
    if ParadiseZ.isPartOfSH(sq) then
        str = "HQ"
    elseif ParadiseZ.isOutsideZone(pl) then
        str = "Outside"
    elseif ParadiseZ.isRegularZone(pl) then
        str = "Zone"
    elseif ParadiseZ.isPveZone(pl) then
        str = "NonPvp"
    elseif ParadiseZ.isKosZone(pl) then
        str = "PvP"
    elseif ParadiseZ.isZoneIsBlocked(pl) then
        str = "Zone"
    end
    return str or ""
   
end

function ParadiseZ.doDrawZone()
    if not isIngameState() then return end
    local pl = getPlayer()
    if not pl then return end

    

    local str = ParadiseZ.getDrawStr(pl)


    local textures = {
        ['HQ'] = getTexture("media/textures/zone/ParadiseZ_Zone_HQ.png"),
        ['NonPvp'] = getTexture("media/textures/zone/ParadiseZ_Zone_NonPvP.png"),
        ['Outside'] = getTexture("media/textures/zone/ParadiseZ_Zone_Outside.png"),
        ['PvP'] = getTexture("media/textures/zone/ParadiseZ_Zone_PvP.png"), 
        ['Zone'] = getTexture("media/textures/zone/ParadiseZ_Zone_Inside.png"),
    }

    local colors = {
        ['HQ'] = {r=0,g=0,b=1},
        ['NonPvp'] = {r=0,g=1,b=0},
        ['Outside'] = {r=1,g=0.4,b=0},
        ['PvP'] = {r=1,g=0,b=0},
        ['Zone'] = {r=1,g=1,b=1},
    }
    
    local texture = textures[str]
    local color = colors[str] or {r=1,g=1,b=1}

    local alpha
    if str == nil or str == "" then
        if not isAdmin(pl) then
            alpha = 0
        else
            alpha = 0.1
        end
    else
        alpha = 0.8
    end

    local msg = ParadiseZ.getCurrentZoneName(pl)
    getTextManager():DrawString(UIFont.NewSmall, 68, 100, msg, color.r, color.g, color.b, alpha)
    if texture then
        UIManager.DrawTexture(texture, 68, 70, 32, 32, 0.8)
    end
end
Events.OnPostUIDraw.Remove(ParadiseZ.doDrawZone)
Events.OnPostUIDraw.Add(ParadiseZ.doDrawZone)
