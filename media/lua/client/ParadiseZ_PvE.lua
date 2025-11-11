--[[██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
   ░▒▓█████▓▒░     ░▒▓█▓▒░        ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓███████▓▒░   ░▒▓██████▓▒░   ░▒▓█▓▒░ ░▒▓█▓▒░  ░▒▓███████▓▒░    ░▒▓███████▓▒░
  ░▒▓█▓▒░░▒▓█▓▒░   ░▒▓█▓▒░        ░▒▓█▓▒░░▒▓█▓▒░     ░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░ ░▒▓█▓▒░  ▒▓░    ░▒▓█▓▒░   ░▒▓█▒░  ░▒▓█▒░
  ░▒▓█▓▒░          ░▒▓█▓▒░        ░▒▓█▓▒░░▒▓█▓▒░     ░▒▓█▓▒░     ░▒▓█▓▒░         ░▒▓█▓▒░ ░▒▓█▓▒░         ░▒▓█▓▒░   ░▒▓█▒░  ░▒▓█▒░
  ░▒▓█▓▒▒▓███▓▒░   ░▒▓█▓▒░         ░▒▓██████▓▒░      ░▒▓█▓▒░     ░▒▓█▓▒░         ░▒▓█████████▓▒░     ░▒▓███▓▒░     ░▒▓███████▓▒░
  ░▒▓█▓▒░░▒▓█▓▒░   ░▒▓█▓▒░           ░▒▓█▓▒░         ░▒▓█▓▒░     ░▒▓█▓▒░         ░▒▓█▓▒░ ░▒▓█▓▒░         ░▒▓█▓▒░   ░▒▓█▓▒░  ░▒▓▒░
  ░▒▓█▓▒░░▒▓█▓▒░   ░▒▓█▓▒░           ░▒▓█▓▒░         ░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░ ░▒▓█▓▒░  ▒▓░    ░▒▓█▓▒░   ░▒▓█▓▒░  ░▒█▒░
   ░▒▓██████▓▒░    ░▒▓████████▓▒░    ░▒▓█▓▒░         ░▒▓█▓▒░      ░▒▓██████▓▒░   ░▒▓█▓▒░ ░▒▓█▓▒░  ░▒▓███████▓▒░    ░▒▓█▓▒░  ░▒█▒░
|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|
|                        				 Custom  PZ  Mod  Developer  for  Hire													  |
|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|
|                       	Portfolio:  https://steamcommunity.com/id/glytch3r/myworkshopfiles/							          |
|                       		                                    														 	  |
|                       	Discord:    glytch3r															      |
|                       		                                    														 	  |
|                       	Support:    https://ko-fi.com/glytch3r														    	  |
|_______________________________________________________________________________________________________________________________-]]


ParadiseZ = ParadiseZ or {}

-----------------------            ---------------------------

ParadiseZ.trait = "PvE"
function ParadiseZ.isPvE(pl)
    if pl == nil then pl = getPlayer() end
    return pl:HasTrait(ParadiseZ.trait)
end

-----------------------            ---------------------------

function ParadiseZ.hit(char, targ, wpn, dmg)
    local bool = ParadiseZ.isPvE(char) or ParadiseZ.isPvE(targ)
    if instanceof(char, 'IsoZombie') or instanceof(targ, 'IsoZombie') then
        bool = false
    end
    targ:setAvoidDamage(bool)
end

Events.OnWeaponHitCharacter.Remove(ParadiseZ.hit)
Events.OnWeaponHitCharacter.Add(ParadiseZ.hit)
-----------------------            ---------------------------
function ParadiseZ.disablePhun()
    if  PhunZones and isIngameState() then 
        function PhunZones:ISSafetyPrerender(player)
            return 
        end
    end


    function ISSafetyUI:prerender()

        local safetyEnabled = getServerOptions():getBoolean("SafetySystem");
        local toggleTimeMax = getServerOptions():getInteger("SafetyToggleTimer");
        local cooldownTimerMax = getServerOptions():getInteger("SafetyCooldownTimer");
        local isNonPvpZone = NonPvpZone.getNonPvpZone(self.character:getX(), self.character:getY())

        self.radialIcon:setVisible(false);
        self.drawLock = false

        if safetyEnabled then

            if self.safety:getToggle() > 0 or self.safety:getCooldown() > 0 then

                local x = self:getWidth() + 12;
                local y = -3;
                self.drawLock = true

                if self.safety:getToggle() > 0 then

                    self.radialIcon:setVisible(true);
                    self.radialIcon:setValue(self.safety:getToggle() / toggleTimeMax);

                    if self.safety:isEnabled() then
                        self.radialIcon:setTexture(self.offTexture);
                        self:drawTexture(self.onLockedTexture,0,0,1,self.backdropAlpha,self.backdropAlpha,self.backdropAlpha);
                    else
                        self.radialIcon:setTexture(self.onTexture);
                        self:drawTexture(self.offLockedTexture,0,0,1,self.backdropAlpha,self.backdropAlpha,self.backdropAlpha);
                    end

                    self:drawText(tostring(math.ceil(self.safety:getToggle())), x, y, 1,1,1,1, UIFont.Small);

                elseif self.safety:getCooldown() > 0 then

                    self.radialIcon:setVisible(true);
                    self.radialIcon:setValue(1 - self.safety:getCooldown() / cooldownTimerMax);

                    if self.safety:isEnabled() then
                        self.radialIcon:setTexture(self.onTexture);
                        self:drawTexture(self.onTexture,0,0,1,self.backdropAlpha,self.backdropAlpha,self.backdropAlpha);
                    else
                        self.radialIcon:setTexture(self.offTexture);
                        self:drawTexture(self.offTexture,0,0,1,self.backdropAlpha,self.backdropAlpha,self.backdropAlpha);
                    end

                    self:drawText(tostring(math.ceil(self.safety:getCooldown())), x, y, 1,1,1,1, UIFont.Small);

                end

            elseif not isNonPvpZone then
                if self.safety:isEnabled() then
                    self:drawTexture(self.onTexture,0,0,1,1,1,1);
                else
                    self:drawTexture(self.offTexture,0,0,1,1,1,1);
                end
            end

        end

        if isNonPvpZone then

            self:drawTexture(self.disableTexture, 0,0,1,1,1,1);
            self.radialIcon:setVisible(false);

            if self:isMouseOver() then
                self:drawText(getText("IGUI_PvpZone_NonPvpZone"), self.width + 10, self.height/2, 1, 0, 0, 1, self.Small);
            end
        end

    end
end
function ParadiseZ.doToggle()
    
end
function ParadiseZ.initPvP()
    timer:Simple(3, function() 
        if getActivatedMods():contains("phunzones") then
            if not PhunZones then return end

            getServerOptions():getOptionByName("ShowSafety"):setValue(true)
            getServerOptions():getOptionByName("SafetySystem"):setValue(true)
            getServerOptions():getOptionByName("SafetyToggleTimer"):setValue(1)
            getServerOptions():getOptionByName("SafetyCooldownTimer"):setValue(1)


            getCore():saveOptions();
            -----------------------            ---------------------------
            
            function PhunZones:portPlayer()
                local pl = getPlayer() 
                if string.lower(pl:getAccessLevel()) == "admin" then
                    return 
                end
                return ParadiseZ.doRebound(pl)
            end

            function PhunZones:portVehicle(player, vehicle, x, y, z)
                if string.lower(player:getAccessLevel()) == "admin" then
                    return 
                end
                return ParadiseZ.carTp(player, vehicle, x, y, z)
            end

            -----------------------            ---------------------------
            
        
            function PhunZones:updatePlayerUI(playerObj, info, existing)
                local zone = info or playerObj:getModData().PhunZones or {}
                local existing = existing or {}
                PhunZones.ui.welcome.OnOpenPanel(playerObj, zone)
                if self.settings.Widget then
                    local panel = PhunZones.ui.widget.OnOpenPanel(playerObj)
                    if panel then
                        local data = {
                            zone = {
                                title = zone.title or nil,
                                subtitle = zone.subtitle or nil
                            }
                        }
                        panel:setData(data)
                    end
                end
            end
            -----------------------            ---------------------------
            Events[PhunZones.events.OnPhunZonesPlayerLocationChanged].Add(function(pl, zone, oldZone)
                if not isIngameState() then return end
                local isRestrict = ParadiseZ.isPvE(pl)
                local isKoS = zone.pvp or ParadiseZ.isKos(pl)
                if getCore():getDebug() then 
                    local str = 'isKoS '..tostring(isKoS)..'\nisOutsideZone  '..tostring(ParadiseZ.isOutsideZone())
                    print(str)
                    pl:addLineChatElement(str)
                end
                if isKoS and isRestrict then
                    local adm = string.lower(pl:getAccessLevel()) == "admin" 
                    if not adm then
                        ParadiseZ.doRebound(pl)
                    end
                end
            end)

            ParadiseZ.disablePhun()
            Events.OnPlayerUpdate.Add(ParadiseZ.pvpMode)

            function ISSafetyUI:onMouseUp(x, y)
                local pl = getPlayer() 
                local safe = pl:getSafety()

                local isEnabled = safe:isEnabled()
                local isKos = ParadiseZ.isKos(pl)
                local isPvE = ParadiseZ.isPvE(pl)
                local isOutsideZone = ParadiseZ.isOutsideZone()
                if isPvE then
                    if not isEnabled then
                        self:toggleSafety()
                    end
                else
                    if not isOutsideZone then
                        if isKos and isEnabled then
                            --self:toggleSafety()
                        elseif (not isKos) and not isEnabled then
                            self:toggleSafety()
                        end
                    end
                end
            end


            Events.OnKeyPressed.Remove(ISSafetyUI.onKeyPressed);
            ISSafetyUI.onKeyPressed = function(key)
                if key == getCore():getKey("Toggle Safety") then
                    local pl = getPlayer() 
                    local safe = pl:getSafety()

                    local isEnabled = safe:isEnabled()
                    local isKos = ParadiseZ.isKos(pl)
                    local isPvE = ParadiseZ.isPvE(pl)
                    local isOutsideZone = ParadiseZ.isOutsideZone()
                    if isPvE then
                        if not isEnabled then
                            self:toggleSafety()
                        end
                    else
                        if not isOutsideZone then
                            if isKos and isEnabled then
                                --self:toggleSafety()
                            elseif (not isKos) and not isEnabled then
                                self:toggleSafety()
                            end
                        end
                    end
                end
            end
            Events.OnKeyPressed.Add(ISSafetyUI.onKeyPressed);
        end
    end)
end
Events.OnCreatePlayer.Add(ParadiseZ.initPvP)





--[[_____________________________________________________________________________________________________________________________
   ░▒▓██████▓▒░    ░▒▓████████▓▒░    ░▒▓█▓▒░         ░▒▓█▓▒░      ░▒▓██████▓▒░   ░▒▓█▓▒░ ░▒▓█▓▒░  ░▒▓███████▓▒░    ░▒▓█▓▒░  ░▒█▒░
  ░▒▓█▓▒░░▒▓█▓▒░   ░▒▓█▓▒░           ░▒▓█▓▒░         ░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░ ░▒▓█▓▒░  ▒▓░    ░▒▓█▓▒░   ░▒▓█▓▒░  ░▒█▒░
  ░▒▓█▓▒░░▒▓█▓▒░   ░▒▓█▓▒░           ░▒▓█▓▒░         ░▒▓█▓▒░     ░▒▓█▓▒░         ░▒▓█▓▒░ ░▒▓█▓▒░         ░▒▓█▓▒░   ░▒▓█▓▒░  ░▒▓▒░
  ░▒▓█▓▒▒▓███▓▒░   ░▒▓█▓▒░         ░▒▓██████▓▒░      ░▒▓█▓▒░     ░▒▓█▓▒░         ░▒▓█████████▓▒░     ░▒▓███▓▒░     ░▒▓███████▓▒░
  ░▒▓█▓▒░          ░▒▓█▓▒░        ░▒▓█▓▒░░▒▓█▓▒░     ░▒▓█▓▒░     ░▒▓█▓▒░         ░▒▓█▓▒░ ░▒▓█▓▒░         ░▒▓█▓▒░   ░▒▓█▒░  ░▒▓█▒░
  ░▒▓█▓▒░░▒▓█▓▒░   ░▒▓█▓▒░        ░▒▓█▓▒░░▒▓█▓▒░     ░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░ ░▒▓█▓▒░  ▒▓░    ░▒▓█▓▒░   ░▒▓█▒░  ░▒▓█▒░
   ░▒▓█████▓▒░     ░▒▓█▓▒░        ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓███████▓▒░   ░▒▓██████▓▒░   ░▒▓█▓▒░ ░▒▓█▓▒░  ░▒▓███████▓▒░    ░▒▓███████▓▒░
█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████--]]