----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------

ParadiseZ = ParadiseZ or {}
--client\ParadiseZ_Color.lua

ParadiseZ.colorValues = {
    { r = 0.5, g = 0.5, b = 0.5 }, --1 Gray
    { r = 1, g = 0, b = 0 },       --2 Red
    { r = 1, g = 0.5, b = 0 },     --3 Orange
    { r = 1, g = 1, b = 0 },       --4 Yellow
    { r = 0, g = 1, b = 0 },       --5 Green
    { r = 0, g = 0, b = 1 },       --6 Blue
    { r = 0.5, g = 0, b = 0.5 },   --7 Purple
    { r = 0, g = 0, b = 0 },       --8 Black
    { r = 1, g = 1, b = 1 },       --9 White
    { r = 1, g = 0.75, b = 0.8 },  --10 Pink
}

function ParadiseZ.getFloatColor(col)
    if not col then return end
    return col / 255
end

function ParadiseZ.getIntColor(col)
    if not col then return end
    return math.floor(col * 255)
end

function ParadiseZ.getZoneSandboxColor(zoneType)
    local colorIndex = 9
    if zoneType == "HQ" then
        colorIndex = SandboxVars.ParadiseZcolor.HQ or 9
    elseif zoneType == "Outside" then
        colorIndex = SandboxVars.ParadiseZcolor.Outside or 9
    elseif zoneType == "NonPvp" then
        colorIndex = SandboxVars.ParadiseZcolor.NonPvp or 9
    elseif zoneType == "KoS" then
        colorIndex = SandboxVars.ParadiseZcolor.PvP or 9
    elseif zoneType == "Blocked" then
        colorIndex = SandboxVars.ParadiseZcolor.Blocked or 9
    elseif zoneType == "Protected" then
        colorIndex = SandboxVars.ParadiseZcolor.Protected or 9
    elseif zoneType == "Radiation" then
        colorIndex = SandboxVars.ParadiseZcolor.Radiation or 9
    elseif zoneType == "Hunt" then
        colorIndex = SandboxVars.ParadiseZcolor.Hunt or 9
    elseif zoneType == "Blaze" then
        colorIndex = SandboxVars.ParadiseZcolor.Blaze or 9
    elseif zoneType == "Frost" then
        colorIndex = SandboxVars.ParadiseZcolor.Frost or 9
    elseif zoneType == "Bomb" then
        colorIndex = SandboxVars.ParadiseZcolor.Bomb or 9
    elseif zoneType == "MineField" then
        colorIndex = SandboxVars.ParadiseZcolor.MineField or 9
    elseif zoneType == "NoCamp" then
        colorIndex = SandboxVars.ParadiseZcolor.NoCamp or 9
    elseif zoneType == "NoFire" then
        colorIndex = SandboxVars.ParadiseZcolor.NoFire or 9
    elseif zoneType == "Cage" then
        colorIndex = SandboxVars.ParadiseZcolor.Cage or 9
    elseif zoneType == "Party" then
        colorIndex = SandboxVars.ParadiseZcolor.Party or 9
    elseif zoneType == "Rally" then
        colorIndex = SandboxVars.ParadiseZcolor.Rally or 9
    elseif zoneType == "Special" then
        colorIndex = SandboxVars.ParadiseZcolor.Special or 9
    elseif zoneType == "Trade" then
        colorIndex = SandboxVars.ParadiseZcolor.Trade or 9
    elseif zoneType == "Sprint" then
        colorIndex = SandboxVars.ParadiseZcolor.Sprint or 9
    else
        colorIndex = SandboxVars.ParadiseZcolor.Typeless or 6        
    end
    
    if colorIndex == 11 then
        return 0, 0, 0, 0
    end
    
    local color = ParadiseZ.colorValues[colorIndex] or ParadiseZ.colorValues[9]
    return color.r, color.g, color.b, 1
end

function ParadiseZ.getZoneDataColor(zName)
    local zData = ParadiseZ.ZoneData and ParadiseZ.ZoneData[zName]
    if not zData then return 1,1,1,1 end

    local colorIndex = 9

    if zData.isKos then
        colorIndex = SandboxVars.ParadiseZcolor.PvP or 9
    elseif zData.isBlocked then
        colorIndex = SandboxVars.ParadiseZcolor.Blocked or 9
    elseif zData.isPvE then
        colorIndex = SandboxVars.ParadiseZcolor.NonPvp or 9
    elseif zData.isSpecial then
        colorIndex = SandboxVars.ParadiseZcolor.Special or 9
    elseif zData.isCage then
        colorIndex = SandboxVars.ParadiseZcolor.Cage or 9
    elseif zData.isHQ then
        colorIndex = SandboxVars.ParadiseZcolor.HQ or 9
    elseif zData.isOutside then
        colorIndex = SandboxVars.ParadiseZcolor.Outside or 9
    elseif zData.isProtected then
        colorIndex = SandboxVars.ParadiseZcolor.Protected or 9
    elseif zData.isRadiation then
        colorIndex = SandboxVars.ParadiseZcolor.Radiation or 9
    elseif zData.isHunt then
        colorIndex = SandboxVars.ParadiseZcolor.Hunt or 9
    elseif zData.isBlaze then
        colorIndex = SandboxVars.ParadiseZcolor.Blaze or 9
    elseif zData.isFrost then
        colorIndex = SandboxVars.ParadiseZcolor.Frost or 9
    elseif zData.isBomb then
        colorIndex = SandboxVars.ParadiseZcolor.Bomb or 9
    elseif zData.isMineField then
        colorIndex = SandboxVars.ParadiseZcolor.MineField or 9
    elseif zData.isNoCamp then
        colorIndex = SandboxVars.ParadiseZcolor.NoCamp or 9
    elseif zData.isNoFire then
        colorIndex = SandboxVars.ParadiseZcolor.NoFire or 9
    elseif zData.isParty then
        colorIndex = SandboxVars.ParadiseZcolor.Party or 9
    elseif zData.isRally then
        colorIndex = SandboxVars.ParadiseZcolor.Rally or 9
    elseif zData.isTrade then
        colorIndex = SandboxVars.ParadiseZcolor.Trade or 9
    elseif zData.isSprint then
        colorIndex = SandboxVars.ParadiseZcolor.Sprint or 9
    else
        colorIndex = SandboxVars.ParadiseZcolor.Typeless or 6
    end
    
    if colorIndex == 11 then
        return 1,1,1,1
    end

    local color = ParadiseZ.colorValues[colorIndex] or ParadiseZ.colorValues[9]
    return color.r, color.g, color.b, 1
end
--[[ 
function ParadiseZ.parseColor()
    if ParadiseZ.RoomLight then
        return ParadiseZ.RoomLight[1], ParadiseZ.RoomLight[2], ParadiseZ.RoomLight[3], ParadiseZ.RoomLight[4] 
    end

    local strList = SandboxVars.ParadiseZ.RoomLight or "255;255;255;255"
    local r, g, b, a = strList:match("^(%d+);(%d+);(%d+);(%d+)$")
    r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)

    ParadiseZ.RoomLight = { r, g, b, a }
    return r, g, b, a
end

 ]]