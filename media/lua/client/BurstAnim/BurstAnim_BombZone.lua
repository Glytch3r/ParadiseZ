ParadiseZ = ParadiseZ or {}

function ParadiseZ.triggerTrapOnSquare(sq)
    if not sq then return end
    local objects = sq:getObjects()
    for i = 1, objects:size() do
        local obj = objects:get(i-1)
        if obj then
            local spr = obj:getSprite()
            if spr then
                local sprName = spr:getName()
                if sprName and ParadiseZ.isMineSq(sprName) then
                    doSledge(obj)
                    getSoundManager():PlayWorldSound('PipeBombExplode', sq, 0, 5, 5, false)
                    getSoundManager():PlayWorldSound('BurnedObjectExploded', sq, 0, 5, 5, false)
                    local dug
                    local dug2
                    if ParadiseZ.doRoll(5) then
                        dug = IsoObject.new(sq, "floors_burnt_01_" .. ZombRand(2,3), "", false)
                        sq:AddTileObject(dug)
                    end
                    if ParadiseZ.doRoll(10) then
                        dug2 = IsoObject.new(sq, "floors_burnt_01_" .. ZombRand(2,3), "", false)
                        sq:AddTileObject(dug2)
                    end
                    if isClient() then
                        timer:Simple(1, function()
                            local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ() }
                            sendClientCommand(nil, 'object', 'addExplosionOnSquare', args)
                            if dug then
                                dug:transmitCompleteItemToServer()
                            end
                            if dug2 then
                                dug2:transmitCompleteItemToServer()
                            end
                        end)
                    end
                    return true
                end
            end
        end
    end
    return false
end

local ticks = 0
function ParadiseZ.BombZoneHandler(pl)
    pl = pl or getPlayer()
    if not pl then return end
    ticks = ticks + 1
    if ticks % SandboxVars.ParadiseZ.BombZoneDelay == 0 then
        if BurstAnim.doRoll(SandboxVars.ParadiseZ.BombZoneChance) then
            local sq = getRandomFreeSquare()
            if sq then
                ParadiseZ.triggerTrapOnSquare(sq)
            end
        end
    end

end
Events.OnPlayerUpdate.Add(ParadiseZ.Remove)
Events.OnPlayerUpdate.Add(ParadiseZ.BombZoneHandler)
 