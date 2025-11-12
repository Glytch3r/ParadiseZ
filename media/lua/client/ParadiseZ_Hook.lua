ParadiseZ = ParadiseZ or {}

Events.OnGameStart.Add(function()
    ParadiseZ.ISServerSandboxOptionsUIonButtonApply = ISServerSandboxOptionsUI.onButtonApply
    function ISServerSandboxOptionsUI:onButtonApply()
        self:settingsFromUI(self.options)
        self.options:sendToServer()
        getSandboxOptions():toLua()
        self:destroy()
    end
end)
