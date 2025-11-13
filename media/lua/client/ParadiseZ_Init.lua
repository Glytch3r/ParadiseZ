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

