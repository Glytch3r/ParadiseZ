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


--client/ParadiseZ_Spectate.lua
ParadiseZ = ParadiseZ or {}
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

ParadiseZ.ISMiniScoreboardUI_doPlayerListContextMenu = ParadiseZ.ISMiniScoreboardUI_doPlayerListContextMenu or ISMiniScoreboardUI.doPlayerListContextMenu

function ISMiniScoreboardUI:doPlayerListContextMenu(targPl, x, y)
    local plNum = self.admin:getPlayerNum()
    local context = ISContextMenu.get(plNum, x + self:getAbsoluteX(), y + self:getAbsoluteY());
    context:addOption(getText("UI_Scoreboard_Teleport"), self, ISMiniScoreboardUI.onCommand, targPl, "TELEPORT");
    context:addOption(getText("UI_Scoreboard_TeleportToYou"), self, ISMiniScoreboardUI.onCommand, targPl, "TELEPORTTOYOU");
    context:addOption(getText("UI_Scoreboard_Invisible"), self, ISMiniScoreboardUI.onCommand, targPl, "INVISIBLE");
    context:addOption(getText("UI_Scoreboard_GodMod"), self, ISMiniScoreboardUI.onCommand, targPl, "GODMOD");
    context:addOption("Check Stats", self, ISMiniScoreboardUI.onCommand, targPl, "STATS");
    local targUser = targPl.username
    if targUser then
        context:addOption("Spectate: ".. tostring(targUser), self, function()
            ParadiseZ.setSpectate(targUser)
        end);
    end
end

ParadiseZ.ISMiniScoreboardUI_initialise = ParadiseZ.ISMiniScoreboardUI_initialise or ISMiniScoreboardUI.initialise

function ISMiniScoreboardUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 80
    local btnHgt = FONT_HGT_SMALL + 2
    local y = 10 + FONT_HGT_SMALL + 10
    self.playerList = ISScrollingListBox:new(10, y, self.width - 20, self.height - (5 + btnHgt + 5) - y);
    self.playerList:initialise();
    self.playerList:instantiate();
    self.playerList.itemheight = FONT_HGT_SMALL + 2 * 2;
    self.playerList.selected = 0;
    self.playerList.joypadParent = self;
    self.playerList.font = UIFont.NewSmall;
    self.playerList.doDrawItem = self.drawPlayers;
    self.playerList.drawBorder = true;
    self.playerList.onRightMouseUp = ISMiniScoreboardUI.onRightMousePlayerList;
    self:addChild(self.playerList);
    self.playerList:setOnMouseDoubleClick(self, ParadiseZ.onDoubleClick)
    self.no = ISButton:new(self.playerList.x + self.playerList.width - btnWid, self.playerList.y + self.playerList.height + 5, btnWid, btnHgt, getText("UI_btn_close"), self, ISMiniScoreboardUI.onClick);
    self.no.internal = "CLOSE";
    self.no.anchorTop = false
    self.no.anchorBottom = true
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9};
    self:addChild(self.no);
    scoreboardUpdate()
end

function ParadiseZ.onDoubleClick(item)
    if not item then return end
    
    local targ = (item and item.item) and item.item or item
    if not targ then return end
    
    local targUser
    if type(targ) == "string" then
        targUser = targ
    elseif targ.username then
        targUser = targ.username
    end
    
    if targUser then 
        ParadiseZ.setSpectate(targUser)
    end
end

function ParadiseZ.isSpectating(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    
    local targUser = pl:getModData().Spectating
    return targUser ~= nil
end

function ParadiseZ.getSpectateTarg(pl)
    pl = pl or getPlayer()
    if not pl then return nil end
    if not ParadiseZ.isSpectating(pl) then return nil end
    
    local targUser = pl:getModData().Spectating
    if not targUser then return nil end
    
    return getPlayerFromUsername(targUser)
end

function ParadiseZ.getSpectateTargUser(pl)
    pl = pl or getPlayer()
    if not pl then return nil end
    if not ParadiseZ.isSpectating(pl) then return nil end
    local targUser = pl:getModData().Spectating
    if not targUser then return nil end
    return targUser
end

function ParadiseZ.setSpectate(targ)
    local pl = getPlayer()
    if not pl or not targ then 
        pl:getModData().Spectating = nil
        return 
    end

    local targUser
    if instanceof(targ, "IsoPlayer") then
        targUser = targ:getUsername()
    else
        targUser = targ
    end

    local user = pl:getUsername()
    if not user or targUser == user then 
        pl:getModData().Spectating = nil
        return 
    end

    pl:getModData().Spectating = targUser

    local targPl = instanceof(targ, "IsoPlayer") and targ or getPlayerFromUsername(targUser)
    if targPl then
        pl:getModData().SpectateOffset = {x = 0, y = 0, z = targPl:getZ()}
    else
        pl:getModData().SpectateOffset = {x = 0, y = 0, z = 0}
    end
end

function ParadiseZ.getSpectateTarg(pl)
    pl = pl or getPlayer()
    if not pl then return nil end
    if not ParadiseZ.isSpectating(pl) then return nil end
    
    local u = pl:getModData().Spectating
    if not u then return nil end
    
    return getPlayerFromUsername(u)
end

function ParadiseZ.getSpectatePoint(pl)
    pl = pl or getPlayer()
    if not pl then return nil, nil, nil end
    if not ParadiseZ.isSpectating(pl) then return nil, nil, nil end
    
    local targ = ParadiseZ.getSpectateTarg(pl)
    if not targ then return nil, nil, nil end
    
    local offset = pl:getModData().SpectateOffset
    if not offset then return nil, nil, nil end
    
    local x = targ:getX() + offset.x
    local y = targ:getY() + offset.y
    local z = targ:getZ() + offset.z
    
    return x, y, z
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
    
    local targ = ParadiseZ.getSpectateTarg(pl)
    if not targ then
        pl:getModData().Spectating = nil
        return
    end
    
    if ParadiseZ.isPlayerInCar(pl) then
        pl:getModData().Spectating = nil
        return
    end
    
    local x, y, z = ParadiseZ.getSpectatePoint(pl)
    if not (x and y and z) then return end
    
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
    local isAuto = SandboxVars.ParadiseZ.AutoInvisible
    if ParadiseZ.isSpectating(pl) then 
        if isAuto then
            if not pl:isGhostMode() then
                pl:setGhostMode(true)
            end
            if not pl:isInvisible() then
                pl:setInvisible(true)
            end
        end
        if SandboxVars.ParadiseZ.HideAvatar then
            pl:renderShadow(0, 0, 0)
            pl:setAlpha(0)
            if not pl:isHideWeaponModel() then
                pl:setHideWeaponModel(true)
            end
        end

    else

        if pl:isHideWeaponModel() then
            pl:setHideWeaponModel(false)
        end
        pl:setAlpha(1)

        if isAuto then
            if pl:isInvisible() then
                pl:setInvisible(false)
            end
            if pl:isGhostMode() then
                pl:setGhostMode(false)
            end
        end
    end
end