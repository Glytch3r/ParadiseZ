
ParadiseZ = ParadiseZ or {}

function ParadiseZ.dead(plZed)
    local pl = getPlayer() 
    if plZed == pl then        
        if pl:getVariableBoolean('isScareCrow') == true or pl:getModData()['isScareCrow'] == true then                
            if instanceof(pl, "IsoDeadBody") then    
                local inv = pl:getInventory() 
                pl:clearWornItems()
                inv:clear()
                pl:setSkeleton(true)
            end
        end
    end
end
Events.OnPlayerDeath.Remove(ParadiseZ.dead)
Events.OnPlayerDeath.Add(ParadiseZ.dead)
