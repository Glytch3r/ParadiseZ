
ParadiseZ = ParadiseZ or {}

function ParadiseZ.AvoidDmg(char, targ, wpn, dmg)
    local zone1 = ParadiseZ.getCurrentZoneName(char)
    local zone2 = ParadiseZ.getCurrentZoneName(targ)
    local isAvoid = true

    if ParadiseZ.isPveZone(char) or ParadiseZ.isPveZone(targ) then
        isAvoid = false    
    end
    if instanceof(char, 'IsoZombie') or instanceof(targ, 'IsoZombie') then
        isAvoid = false
    end    
--[[     if zone1 ~= zone2 then 
        bool = false
    end    ]]
    local dmg= dmg * SandboxVars.ParadiseZ.pvpDmgMult or 1.6
    targ:setAvoidDamage(bool)
    if not isAvoid then
        if targ == getPlayer() then
            local md = targ:getModData()
            md.LifePoints = math.min(100, math.max(0, md.LifePoints - dmg))            
            if md.LifePoints <= 0 then
                targ:Kill(char)
            else
                local percent = SandboxVars.ParadiseZ.pvpStaggerChance or 34
                if ParadiseZ.doRoll(percent) then
                    targ:setBumpType("pushedbehind");  
                    targ:setVariable("BumpFall", true);
                    targ:setVariable("BumpFallType", "pushedbehind");  
                else
                    targ:setVariable("HitReaction", "Shot")                    
                end

                local recoverHP = dmg/3
                timer:Simple(2, function() 
                    math.min(100, math.max(0, md.LifePoints + recoverHP)) 
                end)
                timer:Simple(4, function() 
                    math.min(100, math.max(0, md.LifePoints + recoverHP)) 
                end)
                timer:Simple(6, function() 
                    math.min(100, math.max(0, md.LifePoints + recoverHP)) 
                end)
            end
        end
    end
    
end

Events.OnWeaponHitCharacter.Remove(ParadiseZ.AvoidDmg)
Events.OnWeaponHitCharacter.Add(ParadiseZ.AvoidDmg)
