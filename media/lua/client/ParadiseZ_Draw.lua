ParadiseZ = ParadiseZ or {}

ParadiseZ.showZoneInfo = true

--[[ 
    ParadiseZ.showZoneInfo = false
 ]]

 function ParadiseZ.LifeBarVisibility(pl)
    pl = pl or getPlayer()
    if not pl then return end

    local name = ParadiseZ.getZoneName(pl)
    local isOutsideZone = ParadiseZ.isOutsideZone(pl)
    local isKosZone = ParadiseZ.isKosZone(pl)
    local isPveZone = ParadiseZ.isPveZone(pl)
    local x, y = ParadiseZ.getXY(pl)
    local isBlockedZone = ParadiseZ.isBlockedZone(pl)
    local isPvpPlayer = ParadiseZ.isPvE(pl)

    if isPvpPlayer or (isPveZone and not isKosZone) then
        LifeBarUI.hide()   
    end
    if not isPvpPlayer and (isKosZone and not isPveZone)or isOutsideZone then
        LifeBarUI.show()
    end
    
end
Events.OnPlayerUpdate.Remove(ParadiseZ.LifeBarVisibility)
Events.OnPlayerUpdate.Add(ParadiseZ.LifeBarVisibility)



function ParadiseZ.getZoneInfo(pl)
    pl = pl or getPlayer()
    if not pl then return end

    local name = ParadiseZ.getZoneName(pl)
    local x, y = ParadiseZ.getXY(pl)
    local zoneName = name

    if name ~= "Outside" and ParadiseZ.isXYOnZoneEdge(x, y, name) then
        zoneName = zoneName .. " (Border)"
    end

    local info = {zoneName}

    if ParadiseZ.isKosZone(pl) then
        table.insert(info, "KosZone")
    end
    if ParadiseZ.isPveZone(pl) then
        table.insert(info, "PvE")
    end
    if ParadiseZ.isBlockedZone(pl) then
        table.insert(info, "Blocked")
    end

    table.insert(info, "X:" .. round(x) .. "    Y:" .. round(y))

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
    elseif ParadiseZ.isOutsideZone(pl) then
        str = "Outside"
    elseif ParadiseZ.isRegularZone(pl) then
        str = "Zone"
    elseif ParadiseZ.isPveZone(pl) then
        str = "NonPvp"
    elseif ParadiseZ.isKosZone(pl) then
        str = "PvP"
    elseif ParadiseZ.isBlockedZone(pl) then
        str = "Blocked"
    elseif ParadiseZ.isSafeZone(pl) then
        str = "Protected"
    end
    return str or ""
   
end

function ParadiseZ.getReboundData()
   local data = getPlayer():getModData()

    local name =  data['Rebound'].name
    if not name then return end

    local X =  data['Rebound'].X
    local Y =  data['Rebound'].y
    local z =  data['Rebound'].z
    if not (x and y and z) then return end
    return "Rebound:".. tostring(name).."\nCoord:   X " ..tostring( round(x) ).. "   ,   Y " .. tostring(round(y))
end

function ParadiseZ.doDrawZone()
    if not isIngameState() then return end
    local pl = getPlayer()
    if not pl then return end


    local str = ParadiseZ.getDrawStr(pl)


    local textures = {
        ['HQ'] = getTexture("media/textures/zone/ParadiseZ_Zone_HQ.png"),
        ['Outside'] = getTexture("media/textures/zone/ParadiseZ_Zone_Outside.png"),
        ['Zone'] = getTexture("media/textures/zone/ParadiseZ_Zone_Inside.png"),
        ['NonPvp'] = getTexture("media/textures/zone/ParadiseZ_Zone_NonPvP.png"),
        ['PvP'] = getTexture("media/textures/zone/ParadiseZ_Zone_PvP.png"), 
        ['Blocked']  = getTexture("media/textures/zone/ParadiseZ_Zone_Blocked.png"),
        ['Protected']  = getTexture("media/textures/zone/ParadiseZ_Zone_Protected.png"),
        
    }

    local colors = {
        ['HQ'] = {r=0,g=0,b=1},
        ['Outside'] = {r=1,g=0.4,b=0},
        ['Zone'] = {r=1,g=1,b=1},
        ['NonPvp'] = {r=0,g=1,b=0},
        ['PvP'] = {r=0.9,g=0.2,b=0.2},
        ['Blocked'] = { r = 0.13, g = 0.13, b = 0.13 },
        ['Protected'] = { r = 0.84, g = 0.76, b = 0.67 },
    }
    
    local texture = textures[str]
    local color = colors[str] or {r=1,g=1,b=1}
    local isAdm = string.lower(pl:getAccessLevel()) == "admin"
    local alpha
    if str == nil or str == "" then
        if not isAdm then
            alpha = 0
        else
            alpha = 0.1
        end
    else
        alpha = 0.8
    end
    local isShowInfo = SandboxVars.ParadiseZ.AdminOnlyZoneInfo  
    local msg = ParadiseZ.getZoneName(pl)
    if isAdm or not isShowInfo then
--[[  ]]
      --[[   local x, y = ParadiseZ.getXY(pl)
        local name = ParadiseZ.getXYZoneName(x, y)
        local Inside = ParadiseZ.isXYInsideZone(x, y, name)
        local Border = ParadiseZ.isXYOnZoneEdge(x, y, name)
 ]]
        msg = tostring(ParadiseZ.getZoneInfo(pl))..'\n'..tostring(ParadiseZ.getReboundInfo())
    end
    getTextManager():DrawString(UIFont.Medium, 68, 100, msg, color.r, color.g, color.b, alpha)
    if texture then
        UIManager.DrawTexture(texture, 68, 70, 32, 32, 0.8)
    end
end
Events.OnPostUIDraw.Remove(ParadiseZ.doDrawZone)
Events.OnPostUIDraw.Add(ParadiseZ.doDrawZone)

function ParadiseZ.getReboundInfo()
    local pl = getPlayer() 
    if getCore():getDebug() then 
		local rebound = ParadiseZ.getReboundXYZ(pl)
		local x = rebound.x
		local y = rebound.y
		local z = rebound.z

		local msg = "\nREBOUND: \n"..tostring(round(x)) ..',  '.. tostring(round(y)) ..', '..tostring(z)
		return msg
		--ParadiseZ.echo(msg, true)   
    end
end
