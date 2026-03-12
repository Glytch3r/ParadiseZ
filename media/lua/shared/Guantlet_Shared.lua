Guantlet = Guantlet or {}

function Guantlet.serverInit()
    GuantletData = ModData.getOrCreate("GuantletData")
end
Events.OnInitGlobalModData.Add(Guantlet.serverInit)

function Guantlet.serverRecieve(mod, data)
    if mod == "GuantletData" then
        ModData.add("GuantletData", data)
    end
end
Events.OnReceiveGlobalModData.Add(Guantlet.serverRecieve)