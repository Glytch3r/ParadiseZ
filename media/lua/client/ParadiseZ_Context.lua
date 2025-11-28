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

function ParadiseZ.isOnOrOff(bool)
    return bool and "On" or "Off"
end



function ParadiseZ.context(plNum, context, worldobjects, test)
    local pl = getSpecificPlayer(plNum)
    if not pl or not pl:isAlive() then return end

    if string.lower(pl:getAccessLevel()) ~= "admin" then return end
    
	local mainMenu = "ParadiseZ:"
	local Main = context:addOptionOnTop(mainMenu)
	Main.iconTexture = getTexture("media/ui/Paradise/ContextIcon.png")
	local opt = ISContextMenu:getNew(context)
	context:addSubMenu(Main, opt)

    local sq = luautils.stringStarts(getCore():getVersion(), "42") and ISWorldObjectContextMenu.fetchVars.clickedSquare or clickedSquare
    if not sq then return end

    local csq = pl:getCurrentSquare() 
    if not csq then return end

    local dist = csq:DistTo(sq:getX(), sq:getY())
    if (dist and dist <= 3) or getCore():getDebug() then
        local optTip = opt:addOption("Zone Editor Panel", worldobjects, function()
            ParadiseZ.editor(true)
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/ZoneContextIcon.png")

        local isHideAdminTag = ParadiseZ.isHideAdminTag(pl)
        local optTip =  opt:addOption("Hide Admin Tag:  "..tostring(ParadiseZ.isOnOrOff(isHideAdminTag)), worldobjects, function()
            ParadiseZ.toggleHideAdminTag(pl, activate)
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/AdmTagContextIcon.png")

        local trailLightStatus = ParadiseZ.isTrailingLightMode(pl) or false
        local optTip = opt:addOption("TrailingLight:  "..tostring(ParadiseZ.isOnOrOff(trailLightStatus)), worldobjects, function()            
            ParadiseZ.toggleTrailingLightMode(pl)            
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/LightContextIcon.png")

        local optTip = opt:addOption("Force Rebound", worldobjects, function()            
            ParadiseZ.doRebound(pl)
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/ReboundContextIcon.png")

        local isNVG = pl:isWearingNightVisionGoggles() 
        local optTip = opt:addOption("NVG:  "..tostring(ParadiseZ.isOnOrOff(isNVG)), worldobjects, function()    
            pl:setWearingNightVisionGoggles(not isNVG)        
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/NVGContextIcon.png")

        local optTip = opt:addOption("Level Up", worldobjects, function()    
            ParadiseZ.lvlUp()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/LvlContextIcon.png")

        local isStopZed = pl:isZombiesDontAttack() 
        local optTip = opt:addOption("Prevent Zed Attacks:  "..tostring(ParadiseZ.isOnOrOff(isStopZed)), worldobjects, function()    
            pl:setZombiesDontAttack(not isStopZed)        
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/StopZedContextIcon.png")

        local optTip = opt:addOption("Suicide", worldobjects, function()    
            pl:Kill(pl)
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/RIPContextIcon.png")

        local optTip = opt:addOption("Explode Here", worldobjects, function()    
            local args = { x = pl:getX(), y = pl:getY(), z = pl:getZ() }
            sendClientCommand(pl, 'object', 'addExplosionOnSquare', args)
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/ExplodeContextIcon.png")
        -----------------------            ---------------------------
        local subMenu = "Clear: "
        local Sub = opt:addOptionOnTop(subMenu)
        Sub.iconTexture = getTexture("media/ui/Paradise/ClearContextIcon.png")
        local sbopt = ISContextMenu:getNew(context)
        context:addSubMenu(Sub, sbopt)
  
        local optTip =  sbopt:addOption("Clean Character", worldobjects, function()
            ParadiseZ.washChar()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/WashContextIcon.png")


        local optTip =  sbopt:addOption("Clear Trees", worldobjects, function()
            ParadiseZ.ClearTrees()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/TreesContextIcon.png")
        

        local optTip =  sbopt:addOption("Clear Plants", worldobjects, function()
            ParadiseZ.DespawnPlants()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/PlantsContextIcon.png")

        local optTip =  sbopt:addOption("Clear Cars", worldobjects, function()
            ParadiseZ.DespawnCars()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/CarsContextIcon.png")

        local optTip =  sbopt:addOption("Clear Fire", worldobjects, function()
            ParadiseZ.StopFire()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/NoFireContextIcon.png")
      


        local optTip =  sbopt:addOption("Clear Map Record", worldobjects, function()
            ParadiseZ.ClearMap()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/MapContextIcon.png")


        local optTip =  sbopt:addOption("Clear Floor Items", worldobjects, function()
            ParadiseZ.ClearFloorItems()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/NoItemsContextIcon.png")

        local optTip =  sbopt:addOption("Clear Weather", worldobjects, function()
            ParadiseZ.clearWeather()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/WeatherContextIcon.png")
      
        local optTip =  sbopt:addOption("Clear Corpse", worldobjects, function()
            ParadiseZ.DespawnBodies()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/CorpseContextIcon.png")

        local optTip =  sbopt:addOption("Clear Worn Items", worldobjects, function()
            ParadiseZ.ClearWornItems()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/WornItemsContextIcon.png")
      
        local optTip =  sbopt:addOption("Clear Perks", worldobjects, function()
            ParadiseZ.ClearPerks()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/MemoryContextIcon.png")

         local optTip =  sbopt:addOption("Clear Traits", worldobjects, function()
            ParadiseZ.ClearTraits()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/TraitsContextIcon.png")
      
        local optTip =  sbopt:addOption("Clear Learned Recipes", worldobjects, function()
            ParadiseZ.ClearLearned()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Paradise/LearnContextIcon.png")
      
        -----------------------            ---------------------------
        if clickedPlayer and clickedPlayer ~= pl then 
            if string.lower(pl:getAccessLevel()) == "admin" then
                local targUser = clickedPlayer:getUsername() 
                if targUser then         
                    print( targUser ) 
                    local optTip = context:addOptionOnTop("Spectate: "..tostring(targUser), worldobjects, function()            
                        ParadiseZ.setSpectate(targUser)
                        getSoundManager():playUISound("UIActivateMainMenuItem")
                        context:hideAndChildren()
                    end)
                    optTip.iconTexture = getTexture("media/ui/Paradise/SpectateContextIcon.png")
                end
            end 
        end 
    end
end
Events.OnFillWorldObjectContextMenu.Remove(ParadiseZ.context)
Events.OnFillWorldObjectContextMenu.Add(ParadiseZ.context)


function ParadiseZ.hideAdminTrade(plNum, context, worldobjects, test)
    if not clickedPlayer then return end    
    if string.lower(clickedPlayer:getAccessLevel()) == "admin" or clickedPlayer:isInvisible() then
        context:removeOptionByName(getText("ContextMenu_Trade"))        
    end 
end
Events.OnFillWorldObjectContextMenu.Remove(ParadiseZ.hideAdminTrade)
Events.OnFillWorldObjectContextMenu.Add(ParadiseZ.hideAdminTrade)
