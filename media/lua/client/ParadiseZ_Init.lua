ParadiseZ = ParadiseZ or {}


-----------------------            ---------------------------

function ParadiseZ.initOptions()
    local sOpt = getServerOptions()  
    sOpt:getOptionByName("ShowSafety"):setValue(true)
	sOpt:getOptionByName("SafetySystem"):setValue(true)  
    sOpt:getOptionByName("SafetyToggleTimer"):setValue(0)
	sOpt:getOptionByName("SafetyCooldownTimer"):setValue(0)
end

-----------------------            ---------------------------
Events.OnInitGlobalModData.Add(ParadiseZ.initOptions)

function ParadiseZ.isKosZoneByName(name)
    local z = ParadiseZ.ZoneData[name]
    if not z then return false end
    return z.isKos == true
end
function ParadiseZ.isPvEZoneByName(name)
    local z = ParadiseZ.ZoneData[name]
    if not z then return false end
    return z.isPvE == true
end
function ParadiseZ.isSafeZoneByName(name)
    local z = ParadiseZ.ZoneData[name]
    if not z then return false end
    return z.isSafe == true
end
function ParadiseZ.isBlockedZoneByName(name)
    local z = ParadiseZ.ZoneData[name]
    if not z then return false end
    return z.isBlocked == true
end
