ParadiseZ = ParadiseZ or {}

Events.OnGameStart.Add(function()
    ParadiseZ.ISServerSandboxOptionsUIonButtonApply = ISServerSandboxOptionsUI.onButtonApply
    function ISServerSandboxOptionsUI:onButtonApply()
        self:settingsFromUI(self.options)
--[[ 
        local strList = SandboxVars.ParadiseZ.BlockedList
        ParadiseZ.parseZone(strList)
        if isClient() then
            sendClientCommand("ParadiseZ", "SyncBlockedZones", {strList = strList})
        else 
            ParadiseZ.parseZone(strList)

        end
 ]]

        ParadiseZ.echo("SandboxOptions Updated")
        self.options:sendToServer()
        getSandboxOptions():toLua()
        self:destroy()
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
