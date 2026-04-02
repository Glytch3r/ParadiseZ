ParadiseZ = ParadiseZ or {}
LuaEventManager.AddEvent("OnSandboxModified")

Events.OnGameStart.Add(function()
    ParadiseZ.ISServerSandboxOptionsUIonButtonApply = ISServerSandboxOptionsUI.onButtonApply
    function ISServerSandboxOptionsUI:onButtonApply()
        self:settingsFromUI(self.options)
        ParadiseZ.echo("SandboxOptions Updated")
        self.options:sendToServer()
        getSandboxOptions():toLua()
        triggerEvent("OnSandboxModified")
        self:destroy()
    end
end)
