function ParadiseZ.getHiderList()
    local strList = SandboxVars.ParadiseZ.HiderList or "Base.Hat_BalaclavaFull;Base.Hat_BalaclavaFace;Base.WeldingMask"
    local t = {}
    for item in string.gmatch(strList, "[^;]+") do
        table.insert(t, item)
    end
    return t
end



function ParadiseZ.doHiderParams()
    local hiders = ParadiseZ.getHiderList()
    local param = "isNameHider = TRUE"

    for i = 1, #hiders do
        local item = ScriptManager.instance:getItem(hiders[i])
        if item then
            item:DoParam(param)
        end
    end
end
Events.OnCreatePlayer.Add(ParadiseZ.doHiderParams)
Events.OnSandboxModified.Add(ParadiseZ.doHiderParams)


function ParadiseZ.isWearingNameHider()
    local pl = getPlayer()
    if not pl then return false end
    local items = pl:getWornItems()
    for i = 0, items:size() - 1 do
        local item = items:getItemByIndex(i)
        if item and item:getModData()['isNameHider'] ~= nil then
            local vis = item:getVisual()
            if vis and vis:getHolesNumber() <= 0 then
                return true
            end
        end
    end
    return false
end

function ParadiseZ.setHideName(isHide)
    local pl = getPlayer()
    if not pl then return end
    local md = pl:getModData()
    if isHide then
        if not md['HideNameCache'] then
            md['HideNameCache'] = {
                Forename = pl:getDescriptor():getForename(),
                Surname = pl:getDescriptor():getSurname()
            }
        end
        pl:getDescriptor():setForename('')
        pl:getDescriptor():setSurname('')
    else
        if md['HideNameCache'] then
            pl:getDescriptor():setForename(md['HideNameCache']['Forename'])
            pl:getDescriptor():setSurname(md['HideNameCache']['Surname'])
            md['HideNameCache'] = nil
        end
    end
    sendPlayerStatsChange(pl)
end

local prevHiding = false

function ParadiseZ.NameHiderHandler(pl)
    local hiding = ParadiseZ.isWearingNameHider()
    if hiding ~= prevHiding then
        prevHiding = hiding
        ParadiseZ.setHideName(hiding)
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.NameHiderHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.NameHiderHandler)