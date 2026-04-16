--ParadiseZ_Rebound.lua
ParadiseZ = ParadiseZ or {}

function ParadiseZ.forceExitCar()
   
    ISVehicleMenu.onExit(getPlayer())
    
    local pl = getPlayer()
    if not pl then return end
    local car = pl:getVehicle()
    if not car then return end
    
    local seat = car:getSeat(pl)
    car:exit(pl)
    if seat then
        car:setCharacterPosition(pl, seat, tostring(SandboxVars.ParadiseZ.OutsideStr))
    end
    
    pl:PlayAnim("Idle")
    triggerEvent("OnExitVehicle", pl)
    car:updateHasExtendOffsetForExitEnd(pl)
end

ParadiseZ.teleporting = false
function ParadiseZ.doTp(pl, x, y, z)
    if not ParadiseZ.teleporting then        
        if luautils.stringStarts(getCore():getVersion(), "42") then
            pl:teleportTo(x, y, z)
        else
            pl:setX(x)
            pl:setY(y)
            pl:setZ(z)
            if isClient() then
                pl:setLx(x)
                pl:setLy(y)
                pl:setLz(z)
            end
        end
        ParadiseZ.teleporting = true
    end
    
    timer:Simple(0.5, function() 
        ParadiseZ.teleporting = false
    end)
end
