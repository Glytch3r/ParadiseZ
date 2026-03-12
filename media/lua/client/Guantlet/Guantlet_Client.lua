-- Client
local Commands = {}
Commands.Guantlet = {}

Guantlet = Guantlet or {}

function Guantlet.tMark(sq)
    local m = getWorldMarkers():addGridSquareMarker("circle_center", "circle_only_highlight", sq, 1, 1, 3, true, 0.75)
    timer:Simple(4, function() m:remove() end)
end

function Guantlet.getLevel(GuantletId)
    local data = GuantletData[tostring(GuantletId)]
    if data then return tonumber(data.Level) end
end

function Guantlet.getTimer(GuantletId)
    local data = GuantletData[tostring(GuantletId)]
    if data then return data.Timer end
end

function Guantlet.getCooldown(GuantletId)
    local data = GuantletData[tostring(GuantletId)]
    if data then return data.Cooldown end
end

function Guantlet.isActive(GuantletId)
    local data = GuantletData[tostring(GuantletId)]
    if data then return data.Active end
end

function Guantlet.setCooldown(Level)
    local CooldownDays = (SandboxVars.Guantlet and SandboxVars.Guantlet.CooldownDays) or 20
    return Level * CooldownDays
end

function Guantlet.setTimer(Level)
    local SecondsTimer = (SandboxVars.Guantlet and SandboxVars.Guantlet.SecondsTimer) or 60
    return Level * SecondsTimer
end

function Guantlet.setGuantletData(GuantletId, Level, EntranceX, EntranceY, EntranceZ, Active)
    local Timer = Guantlet.setTimer(Level)
    local Cooldown = Guantlet.setCooldown(Level)
    if Active == nil then Active = false end
    local data = {
        GuantletId = GuantletId,
        Level = Level,
        EntranceX = EntranceX,
        EntranceY = EntranceY,
        EntranceZ = EntranceZ,
        Cooldown = Cooldown,
        Timer = Timer,
        Active = Active,
    }
    GuantletData[tostring(GuantletId)] = data
    Guantlet.SendToServer(GuantletId, data)
end

function Guantlet.delGuantletData(GuantletId)
    if not GuantletId then return end
    GuantletData[tostring(GuantletId)] = nil
    Guantlet.SendToServer(GuantletId, nil)
end

function Guantlet.storeData(data)
    if not data then return end
    for id, entry in pairs(data) do
        GuantletData[tostring(id)] = entry
    end
end

function Guantlet.GuantletDataInit()
    GuantletData = ModData.getOrCreate("GuantletData")
end
Events.OnInitGlobalModData.Add(Guantlet.GuantletDataInit)

function Guantlet.RecieveData(mod, data)
    if mod == "GuantletData" and data then
        if not GuantletData then
            GuantletData = ModData.getOrCreate("GuantletData")
        else
            ModData.add("GuantletData", data)
            GuantletData = ModData.get("GuantletData")
        end
    end
end
Events.OnReceiveGlobalModData.Add(Guantlet.RecieveData)

function Guantlet.SendToServer(GuantletId, data)
    if not isClient() then return end
    if data == nil then
        sendClientCommand("Guantlet", "sSync", {GuantletId = GuantletId})
    else
        sendClientCommand("Guantlet", "sSync", {GuantletId = GuantletId, data = GuantletData})
    end
end

Commands.Guantlet.cSync = function(args)
    local source = getPlayer()
    local player = getPlayerByOnlineID(args.id)
    if source ~= player then
        local GuantletId = tostring(args.GuantletId)
        if GuantletId then
            local data = args.data
            if data then
                Guantlet.storeData(data)
            else
                GuantletData[GuantletId] = nil
            end
        end
    end
end

Events.OnServerCommand.Add(function(module, command, args)
    if Commands[module] and Commands[module][command] then
        Commands[module][command](args)
    end
end)