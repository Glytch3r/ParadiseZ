ParadiseZ = ParadiseZ or {}

function ParadiseZ.isOnOrOff(bool)
    return bool and "On" or "Off"
end



function ParadiseZ.pause(seconds, callback)
    local start = getTimestampMs()
    local duration = seconds * 1000

    local function tick()
        local now = getTimestampMs()
        if now - start >= duration then
            Events.OnTick.Remove(tick)
            if callback then callback() end
        end
    end

    Events.OnTick.Add(tick)
end

function ParadiseZ.context(plNum, context, worldobjects)
    local pl = getSpecificPlayer(plNum)
    if not pl or not pl:isAlive() then return end
    if string.lower(pl:getAccessLevel()) ~= "admin" then return end

    local sq = luautils.stringStarts(getCore():getVersion(), "42") and ISWorldObjectContextMenu.fetchVars.clickedSquare or clickedSquare
    if not sq then return end

    local csq = pl:getCurrentSquare()
    if not csq then return end

    local dist = csq:DistTo(sq:getX(), sq:getY())
    if not (dist and dist <= 3) and not getCore():getDebug() then return end
    if not context then return end

    local mainMenu = "ParadiseZ:"
    local Main = context:addOptionOnTop(mainMenu)
    if not Main then return end
    Main.iconTexture = getTexture("media/ui/Paradise/ContextIcon.png")

    local opt = ISContextMenu:getNew(context)
    if not opt then return end
    context:addSubMenu(Main, opt)
    

    
    local function addSafeOption(menu, text, callback, icon)
        if not menu then return end
        local optTip = menu:addOption(text, worldobjects, function()
            if callback then callback() end
            if context and context.hideAndChildren then context:hideAndChildren() end
        end)
        if optTip and icon then
            optTip.iconTexture = getTexture(icon)
        end
    end
    addSafeOption(opt, "Zone Editor Panel", function() ParadiseZ.editor(true) getSoundManager():playUISound("UIActivateMainMenuItem") end, "media/ui/Paradise/ZoneContextIcon.png")
    
    addSafeOption(opt, "ReApply Gun Params", function() 
        --ParadiseZ.applyGunParams(getCore():getDebug())    
        if isClient() then 
            sendClientCommand("ParadiseZ", "gunParams", { })
        else
            ParadiseZ.applyGunParams(getCore():getDebug()) 
        end	
        local GunVersionKey = SandboxVars.ParadiseZ.GunVersionKey
        pl:setHaloNote(tostring("Gun Paramaters Applied: "..tostring(GunVersionKey)),150,250,150,900)     
		getSoundManager():playUISound("UIActivateMainMenuItem")
		context:hideAndChildren()
    end, "media/ui/Paradise/GunParams.png")
    
    addSafeOption(opt, "Hide Admin Tag: "..tostring(ParadiseZ.isOnOrOff(ParadiseZ.isHideAdminTag(pl))), function() ParadiseZ.toggleHideAdminTag(pl, activate) end, "media/ui/Paradise/AdmTagContextIcon.png")
    addSafeOption(opt, "TrailingLight: "..tostring(ParadiseZ.isOnOrOff(ParadiseZ.isTrailingLightMode(pl) or false)), function() ParadiseZ.toggleTrailingLightMode(pl) end, "media/ui/Paradise/LightContextIcon.png")
    
    if not pl:getVehicle() then
        addSafeOption(opt, "Force Rebound", function() ParadiseZ.doRebound(pl) end, "media/ui/Paradise/ReboundContextIcon.png")
    else
        local disabled = opt:addOption("Force Rebound")
        if disabled then
            disabled.notAvailable = true
            disabled.iconTexture = getTexture("media/ui/Paradise/ReboundContextIcon.png")
            local tooltip = ISToolTip:new()
            tooltip:initialise()
            tooltip.description = "Unavailable in Vehicle"
            disabled.toolTip = tooltip
        end
    end

    addSafeOption(opt, "NVG: "..tostring(ParadiseZ.isOnOrOff(pl:isWearingNightVisionGoggles())), function() pl:setWearingNightVisionGoggles(not pl:isWearingNightVisionGoggles()) end, "media/ui/Paradise/NVGContextIcon.png")
    addSafeOption(opt, "Level Up", function() ParadiseZ.lvlUp() end, "media/ui/Paradise/LvlContextIcon.png")
    addSafeOption(opt, "Prevent Zed Attacks: "..tostring(ParadiseZ.isOnOrOff(pl:isZombiesDontAttack())), function() pl:setZombiesDontAttack(not pl:isZombiesDontAttack()) end, "media/ui/Paradise/StopZedContextIcon.png")
    addSafeOption(opt, "Suicide", function() pl:Kill(pl) end, "media/ui/Paradise/RIPContextIcon.png")
    addSafeOption(opt, "Explode Here", function() sendClientCommand(pl, 'object', 'addExplosionOnSquare', { x = pl:getX(), y = pl:getY(), z = pl:getZ() }) end, "media/ui/Paradise/ExplodeContextIcon.png")
    
    addSafeOption(opt, "Thunder", function() sendClientCommand(pl, "ParadiseZ", "thunder", { })  end, "media/ui/LootableMaps/map_lightning.png")
    


    local subMenu = "Clear: "
    local Sub = opt:addOption(subMenu)
    if Sub then
        Sub.iconTexture = getTexture("media/ui/Paradise/ClearContextIcon.png")
        local sbopt = ISContextMenu:getNew(context)
        if sbopt then context:addSubMenu(Sub, sbopt) end

        addSafeOption(sbopt, "Clean Character", function() ParadiseZ.washChar() end, "media/ui/Paradise/WashContextIcon.png")
        addSafeOption(sbopt, "Clear Trees", function() ParadiseZ.ClearTrees() end, "media/ui/Paradise/TreesContextIcon.png")
        addSafeOption(sbopt, "Clear Plants", function() ParadiseZ.DespawnPlants() end, "media/ui/Paradise/PlantsContextIcon.png")
        addSafeOption(sbopt, "Clear Cars", function() ParadiseZ.DespawnCars() end, "media/ui/Paradise/CarsContextIcon.png")
        addSafeOption(sbopt, "Clear Fire", function() ParadiseZ.StopFire() end, "media/ui/Paradise/NoFireContextIcon.png")
        addSafeOption(sbopt, "Clear Map Record", function() ParadiseZ.ClearMap() end, "media/ui/Paradise/MapContextIcon.png")
        addSafeOption(sbopt, "Clear Floor Items", function() ParadiseZ.ClearFloorItems2() end, "media/ui/Paradise/NoItemsContextIcon.png")
        addSafeOption(sbopt, "Clear Weather", function() ParadiseZ.clearWeather() end, "media/ui/Paradise/WeatherContextIcon.png")
        --addSafeOption(sbopt, "Clear Corpse", function() ParadiseZ.DespawnBodies() end, "media/ui/Paradise/CorpseContextIcon.png")
        addSafeOption(sbopt, "Clear Worn Items", function() ParadiseZ.ClearWornItems() end, "media/ui/Paradise/WornItemsContextIcon.png")
        addSafeOption(sbopt, "Clear Perks", function() ParadiseZ.ClearPerks() end, "media/ui/Paradise/MemoryContextIcon.png")
        addSafeOption(sbopt, "Clear Traits", function() ParadiseZ.ClearTraits() end, "media/ui/Paradise/TraitsContextIcon.png")
        addSafeOption(sbopt, "Clear Learned Recipes", function() ParadiseZ.ClearLearned() end, "media/ui/Paradise/LearnContextIcon.png")
    end

    if clickedPlayer and clickedPlayer ~= pl and string.lower(pl:getAccessLevel()) == "admin" then
        local targUser = clickedPlayer:getUsername()
        if targUser then
            addSafeOption(context, "Spectate: "..tostring(targUser), function() ParadiseZ.setSpectate(targUser) end, "media/ui/Paradise/SpectateContextIcon.png")
        end
    end
end

Events.OnFillWorldObjectContextMenu.Remove(ParadiseZ.context)
Events.OnFillWorldObjectContextMenu.Add(ParadiseZ.context)



--[[ 
function ParadiseZ.removeContextOptions(plNum, context, worldobjects)
    local pl = getSpecificPlayer(plNum)
    if not pl then return end
    if clickedPlayer then 
        if  string.lower(clickedPlayer:getAccessLevel()) == "admin" or clickedPlayer:isInvisible() then
            context:removeOptionByName(getText("ContextMenu_Trade"))
        end 
    end

    if ParadiseZ.isSafeZone(pl) then   
        local tab = {
            "ContextMenu_Destroy",
            "ContextMenu_Disassemble",
            "ContextMenu_Unbarricade",
        }
        loop iterate tab

        context:removeOptionByName(getText("ContextMenu_Destroy"))

        local disabled = context:addOption(getText("ContextMenu_Destroy"))
        if disabled then
            disabled.notAvailable = true
            --disabled.iconTexture = getTexture("media/ui/Paradise/ReboundContextIcon.png")
            local tooltip = ISToolTip:new()
            tooltip:initialise()
            tooltip.description = "Protected Zone"
            disabled.toolTip = tooltip
        end

        context:removeOptionByName(getText("ContextMenu_Disassemble"))

        local disabled = context:addOption(getText("ContextMenu_Disassemble"))
        if disabled then
            disabled.notAvailable = true
            --disabled.iconTexture = getTexture("media/ui/Paradise/ReboundContextIcon.png")
            local tooltip = ISToolTip:new()
            tooltip:initialise()
            tooltip.description = "Protected Zone"
            disabled.toolTip = tooltip
        end

    end
end

Events.OnFillWorldObjectContextMenu.Remove(ParadiseZ.removeContextOptions)
Events.OnFillWorldObjectContextMenu.Add(ParadiseZ.removeContextOptions)
 ]]