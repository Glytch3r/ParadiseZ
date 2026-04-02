ParadiseZ = ParadiseZ or {} 

local ticks = 0
function ParadiseZ.noFireHandler(pl)
    local interval = SandboxVars.ParadiseZ.NoFireZoneInterval or 50
    ticks = ticks + 1
    if ticks % interval ~= 0 then return end    
    ParadiseZ.StopFire(pl, true)
end
Events.OnPlayerUpdate.Remove(ParadiseZ.noFireHandler)
Events.OnPlayerUpdate.Add(ParadiseZ.noFireHandler)

