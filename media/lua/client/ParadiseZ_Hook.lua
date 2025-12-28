ParadiseZ = ParadiseZ or {}


function ParadiseZ.isAdm()
    return string.lower(getPlayer():getAccessLevel()) == "admin"
end

Events.OnGameStart.Add(function()

    ParadiseZ.ISServerSandboxOptionsUIonButtonApply = ISServerSandboxOptionsUI.onButtonApply
    function ISServerSandboxOptionsUI:onButtonApply()
        self:settingsFromUI(self.options)
        ParadiseZ.echo("SandboxOptions Updated")
        self.options:sendToServer()
        getSandboxOptions():toLua()
        self:destroy()
    end

    ParadiseZ.ISUnbarricadeAction_isValid = ISUnbarricadeAction.isValid
    function ISUnbarricadeAction:isValid()
        if ParadiseZ.isSafeZone() then 
            return false
        end
        return ParadiseZ.ISUnbarricadeAction_isValid(self)
    end
    

    ParadiseZ.ISDestroyCursor_canDestroy = ISDestroyCursor.canDestroy
    function ISDestroyCursor:canDestroy(obj)
        if ParadiseZ.isAdm() then return ParadiseZ.ISDestroyCursor_canDestroy(self, obj) end         
        if ParadiseZ.isSafeZone() then 
            return false
        end	
        return ParadiseZ.ISDestroyCursor_canDestroy(self, obj)
    end

    ParadiseZ.ISMoveablesAction_isValid = ISMoveablesAction.isValid
    function ISMoveablesAction:isValid()
        if ParadiseZ.isAdm() or not self.moveProps or (self.mode and not (self.mode == "scrap" or self.mode == "pickup")) then
            return ParadiseZ.ISMoveablesAction_isValid(self)
        end
        return ParadiseZ.ISMoveablesAction_isValid(self)
    end
end)

function ParadiseZ.hookSafety()
    function ISSafetyUI:onMouseUp(x, y)
        ParadiseZ.doToggle()
    end
    Events.OnKeyPressed.Remove(ISSafetyUI.onKeyPressed);
    function ISSafetyUI.onKeyPressed(key)
        if key == getCore():getKey("Toggle Safety") then
            ParadiseZ.doToggle()                
        end
    end
    Events.OnKeyPressed.Add(ISSafetyUI.onKeyPressed);
    ParadiseZ.CheckSafetyHook = true
end

Events.OnInitGlobalModData.Add(ParadiseZ.hookSafety)

