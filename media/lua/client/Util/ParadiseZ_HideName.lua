ParadiseZ = ParadiseZ or {}

function ParadiseZ.getHiderList()
    local strList = SandboxVars.ParadiseZ.HiderList or "Base.Hat_BalaclavaFull;Base.Hat_BalaclavaFace;Base.WeldingMask"
    local t = {}
    for item in string.gmatch(strList, "[^;]+") do
        table.insert(t, item)
    end
    return t
end

function ParadiseZ.isWearingHider()
    local pl = getPlayer()
    if not pl then return false end
    local items = pl:getWornItems()
    for i = 0, items:size() - 1 do
        local item = items:getItemByIndex(i)
        if item and item:getModData()['isNameHider'] ~= nil then
            local vis = item:getVisual()
            if vis and vis.getHolesNumber or item:getVisual():getHolesNumber() <= 0 then
                return true
            end
        end
    end
    return false
end

function ParadiseZ.setHideName(isHide)
    local pl = getPlayer() 
    if not pl then return end

    if pl:getModData()['HideName'] == nil then
        ParadiseZ.hideNameInit(pl:getPlayerNum(), pl)
    end

    if isHide then
        pl:getDescriptor():setForename('')
        pl:getDescriptor():setSurname('')
    else
        pl:getDescriptor():setForename(pl:getModData()['HideName']['Forename'])
        pl:getDescriptor():setSurname(pl:getModData()['HideName']['Surname'])
    end

    sendPlayerStatsChange(pl)
end

function ParadiseZ.hideNameInit(plNum, pl)
    local suit = ParadiseZ.getHiderList()
    local param = "isNameHider = TRUE"
    if suit then
        for i = 1, #suit do
            local item = ScriptManager.instance:getItem(suit[i])
            if item then
                item:DoParam(param)
            end
        end
    end
    if pl:getModData()['HideName'] == nil then
        pl:getModData()['HideName'] = {}
        pl:getModData()['HideName']['Forename'] = pl:getDescriptor():getForename()
        pl:getModData()['HideName']['Surname'] = pl:getDescriptor():getSurname()		
    end
    triggerEvent("OnClothingUpdated", pl)
end
Events.OnCreatePlayer.Add(ParadiseZ.hideNameInit)

function ParadiseZ.nameHideHandler(pl)
    local items = pl:getWornItems()
    for i = 0, items:size() - 1 do
        local item = items:getItemByIndex(i)
        if item and item:getScriptItem() and item:getScriptItem():getParam("isNameHider") then
            item:getModData()['isNameHider'] = true
        end
    end
    ParadiseZ.setHideName(ParadiseZ.isWearingHider())
end

Events.OnClothingUpdated.Add(ParadiseZ.nameHideHandler)