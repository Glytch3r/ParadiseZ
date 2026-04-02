ParadiseZ = ParadiseZ or {}
LuaEventManager.AddEvent("OnSandboxModified")

Events.OnGameStart.Add(function()
    ParadiseZ.ISServerSandboxOptionsUIonButtonApply = ISServerSandboxOptionsUI.onButtonApply
    function ISServerSandboxOptionsUI:onButtonApply()
        self:settingsFromUI(self.options)
        self.options:sendToServer()
        getSandboxOptions():toLua()
        triggerEvent("OnSandboxModified")
        sendClientCommand("ParadiseZ", "reParams", { })
        self:destroy()
    end
end)

Events.OnSandboxModified.Add(function()
    ParadiseZ.echo("SandboxOptions Updated")
end)

