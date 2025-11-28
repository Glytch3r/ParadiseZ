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
--[[ 
function ParadiseZ.spectate(plNum, context, worldobjects, test)
	local pl = getSpecificPlayer(plNum)    
    if not pl then return end
    if not pl:isAlive() then return end
    if not clickedPlayer or clickedPlayer == pl then return end 
    print(clickedPlayer)
    if string.lower(pl:getAccessLevel()) == "admin" then
        local targUser = clickedPlayer:getUsername() 
        if targUser then          
            local optTip = context:addOptionOnTop("Spectate: "..tostring(targUser), worldobjects, function()            
                ParadiseZ.setSpectate(targUser)
                getSoundManager():playUISound("UIActivateMainMenuItem")
                context:hideAndChildren()
            end)
            optTip.iconTexture = getTexture("media/ui/Paradise/SpectateContextIcon.png")
        end
    end 

end
Events.OnFillWorldObjectContextMenu.Remove(ParadiseZ.hideAdminTrade)
Events.OnFillWorldObjectContextMenu.Add(ParadiseZ.hideAdminTrade)

 ]]

ParadiseZ.ISMiniScoreboardUI_doPlayerListContextMenu = ParadiseZ.ISMiniScoreboardUI_doPlayerListContextMenu or ISMiniScoreboardUI.doPlayerListContextMenu
function ISMiniScoreboardUI:doPlayerListContextMenu(targPl, x,y)
    local plNum = self.admin:getPlayerNum()
    local context = ISContextMenu.get(plNum, x + self:getAbsoluteX(), y + self:getAbsoluteY());
    context:addOption(getText("UI_Scoreboard_Teleport"), self, ISMiniScoreboardUI.onCommand, targPl, "TELEPORT");
    context:addOption(getText("UI_Scoreboard_TeleportToYou"), self, ISMiniScoreboardUI.onCommand, targPl, "TELEPORTTOYOU");
    context:addOption(getText("UI_Scoreboard_Invisible"), self, ISMiniScoreboardUI.onCommand, targPl, "INVISIBLE");
    context:addOption(getText("UI_Scoreboard_GodMod"), self, ISMiniScoreboardUI.onCommand, targPl, "GODMOD");
    context:addOption("Check Stats", self, ISMiniScoreboardUI.onCommand, targPl, "STATS");
    local targUser = targPl:getUsername()
    if targUser then
        context:addOption("Spectate: ".. tostring(targUser) , self, ISMiniScoreboardUI.onCommand, targPl, "SPECTATE");
    end
end

ParadiseZ.ISMiniScoreboardUI_onCommand = ParadiseZ.ISMiniScoreboardUI_onCommand or ISMiniScoreboardUI.onCommand
function ISMiniScoreboardUI:onCommand(player, command)
    if command == "SPECTATE" then
        ParadiseZ.setSpectate(player.username)
    else
        ParadiseZ.ISMiniScoreboardUI_onCommand(self, player. command)
    end
end

function ParadiseZ.setSpectate(targUser)
    local pl = getPlayer()
    if not pl or not targUser then return end
    local user = pl:getUsername() 
    if targUser == user then return end      
    pl:getModData().Spectating = targUser
    pl:getModData().SpectateOffset = pl:getModData().SpectateOffset or {x=0,y=0,z=0}
end

function ParadiseZ.isSpectating(pl)
    pl = pl or getPlayer()
    local u = pl:getModData().Spectating
    return u ~= nil
end

function ParadiseZ.getSpectateTarget(pl)
    pl = pl or getPlayer()
    if not pl then return nil end
    if not ParadiseZ.isSpectating(pl) then return nil end
    local u = pl:getModData().Spectating
    if not u then return nil end
    return getPlayerFromUsername(u)
end

function ParadiseZ.getSpectatePoint(pl)
    pl = pl or getPlayer()
    if not pl then return nil,nil,nil end
    if not ParadiseZ.isSpectating(pl) then return nil,nil,nil end
    local t = ParadiseZ.getSpectateTarget(pl)
    if not t then return nil,nil,nil end
    local offset = pl:getModData().SpectateOffset
    local x = t:getX() + offset.x
    local y = t:getY() + offset.y
    local z = t:getZ() + offset.z
    return x,y,z
end
function ParadiseZ.isPlayerInCar(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return pl:getVehicle() ~= nil
end

function ParadiseZ.doSpectateTP(pl)
    pl = pl or getPlayer()
    if not pl then return end
    ParadiseZ.setSpectateSkin(pl)
    if not ParadiseZ.isSpectating(pl) then return end
    local t = ParadiseZ.getSpectateTarget(pl)
    local x,y,z = ParadiseZ.getSpectatePoint(pl)
    if not t or ParadiseZ.isPlayerInCar(pl) or not x then
        pl:getModData().Spectating = nil
        return
    end
    if luautils.stringStarts(getCore():getVersion(), "42") then
        pl:teleportTo(tonumber(x), tonumber(y), tonumber(z))
    else
        pl:setX(x)
        pl:setY(y)
        pl:setZ(z)
        if isClient() then
            pl:setLx(x)
            pl:setLy(y)
            pl:setLz(z)
        end
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.doSpectateTP)
Events.OnPlayerUpdate.Add(ParadiseZ.doSpectateTP)

function ParadiseZ.setSpectateSkin(pl)
    pl = pl or getPlayer()
    if not pl then return end
    if ParadiseZ.isSpectating(pl) then 
        if not pl:isGhostMode() then
            pl:setGhostMode(true)
        end
        if not pl:isInvisible() then
            pl:setInvisible(true)
        end
        pl:renderShadow(0,0,0)   
        pl:setAlpha(0)
        if not pl:isHideWeaponModel() then
            pl:setHideWeaponModel(true)   
        end
    else
        if pl:isHideWeaponModel() then
            pl:setHideWeaponModel(false)
        end
    end

end

function ParadiseZ.setSpectateOffset(key)
    local pl = getPlayer()
    if not pl then return end
    if not ParadiseZ.isSpectating(pl) then return end
    local off = pl:getModData().SpectateOffset

    if key == getCore():getKey("Forward") then
        off.y = off.y - 1
    elseif key == getCore():getKey("Backward") then
        off.y = off.y + 1
    elseif key == getCore():getKey("Left") then
        off.x = off.x - 1
    elseif key == getCore():getKey("Right") then
        off.x = off.x + 1
    elseif key == getCore():getKey("CancelAction") or key == getCore():getKey("Map") then
        pl:getModData().Spectating = nil
    elseif key == 200 then --up
        off.z = math.min(7, math.max(0, off.z + 1))
    elseif key == 208 then --down
        off.z = math.min(7, math.max(0, off.z - 1))
    elseif key == 203 then --left
        local currentTarget = ParadiseZ.getSpectateTarget(pl)
        if currentTarget then
            local nextPl = ParadiseZ.getNextPlayer(currentTarget, false)
            if nextPl then
                pl:getModData().Spectating = nextPl:getUsername()
            end
        end
    elseif key == 205 then --right
        local currentTarget = ParadiseZ.getSpectateTarget(pl)
        if currentTarget then
            local nextPl = ParadiseZ.getNextPlayer(currentTarget, true)
            if nextPl then
                pl:getModData().Spectating = nextPl:getUsername()
            end
        end
    end
    
    return key
end

Events.OnKeyPressed.Remove(ParadiseZ.setSpectateOffset)
Events.OnKeyPressed.Add(ParadiseZ.setSpectateOffset)


function ParadiseZ.getNextPlayer(currentPl, forward)
    local players = {}
    for i=0,getNumActivePlayers()-1 do
        local p = getSpecificPlayer(i)
        if p and p:isAlive() and p ~= getPlayer() then
            table.insert(players, p)
        end
    end
    table.sort(players, function(a,b) return a:getUsername() < b:getUsername() end)
    for i,p in ipairs(players) do
        if p == currentPl then
            if forward then
                return players[i % #players + 1]
            else
                return players[(i - 2) % #players + 1]
            end
        end
        return nil
    end
end