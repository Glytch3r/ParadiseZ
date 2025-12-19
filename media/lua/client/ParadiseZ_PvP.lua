ParadiseZ = ParadiseZ or {}
function ParadiseZ.pvpHit(char, targ, wpn, dmg)
    local isAvoid = false
    local isHasPveTrait = ParadiseZ.isPvE(char) or ParadiseZ.isPvE(targ)
    local isHasPveZone = ParadiseZ.isPveZone(char) or ParadiseZ.isPveZone(targ)
    local isHasZed = instanceof(char, 'IsoZombie') or instanceof(targ, 'IsoZombie')
    local pvpDmg = true

    if isHasPveTrait or isHasPveZone then
        isAvoid = true
        pvpDmg = false
    end

    if isHasZed then
        isAvoid = false
        pvpDmg = false
    end

    dmg = dmg * (SandboxVars.ParadiseZ.pvpDmgMult or 1.6)

    if not ParadiseZ.isUnarmed(char) then
        targ:setAvoidDamage(isAvoid)
    end

    local isLocalTarg = targ == getPlayer()

    if pvpDmg and isLocalTarg then
        local md = targ:getModData()
        md.LifePoints = math.max(0, (md.LifePoints or 100) - dmg)
        md.LifeBarFlash = (md.LifeBarFlash or 0) + dmg

        if md.LifePoints <= 0 then
            targ:Kill(char)
        else
            local recoverHP = dmg / 3
            for i = 2, 6, 2 do
                timer:Simple(i, function()
                    md.LifePoints = math.min(100, md.LifePoints + recoverHP)
                end)
            end
        end

        if getCore():getDebug() then 
            print(md.LifePoints)
            print(dmg)
        end
    end
    
    if not SandboxVars.ParadiseZ.pvpStagger  then return end   
    if targ.isCriticalHit and targ:isCriticalHit() then
        local isBackstab = targ:isHitFromBehind()
        local pushedDir = "pushedFront"
        if isBackstab then
            pushedDir = "pushedbehind"
        end
        targ:setBumpType(pushedDir)
        targ:setVariable("BumpDone", false);
        targ:setVariable("BumpFall", true)
        targ:setVariable("BumpFallType", pushedDir)
    end
end

Events.OnWeaponHitCharacter.Remove(ParadiseZ.pvpHit)
Events.OnWeaponHitCharacter.Add(ParadiseZ.pvpHit)



--[[ 
function ParadiseZ.AvoidDmg(char, targ, wpn, dmg)
    local isAvoid = false
    local isHasPveTrait = ParadiseZ.isPvE(char) or ParadiseZ.isPvE(targ)
    local isHasPveZone = ParadiseZ.isPveZone(char) or ParadiseZ.isPveZone(targ)
    local isHasZed = instanceof(char, 'IsoZombie') or instanceof(targ, 'IsoZombie')
    local pvpDmg = true
    
    if isHasPveTrait or isHasPveZone then
        isAvoid = true
        pvpDmg = false
    end

    if isHasZed then
        isAvoid = false
        pvpDmg = false
    end
    
    dmg = dmg * (SandboxVars.ParadiseZ.pvpDmgMult or 1.6)
	if not ParadiseZ.isUnarmed(char) then
        targ:setAvoidDamage(isAvoid)
    end
    if pvpDmg then
        
        local md = targ:getModData()
        md.LifePoints = math.max(0, md.LifePoints - dmg)
        md.LifeBarFlash = (md.LifeBarFlash or 0) + dmg
        
        if md.LifePoints <= 0 then
            targ:Kill(char)
        else
     
            local pvpStaggerChance = SandboxVars.ParadiseZ.pvpStaggerChance or 34
            if pvpStaggerChance and ParadiseZ.doRoll(pvpStaggerChance) then
                --local pos = targ:getPlayerAttackPosition()
                targ:setBumpType("pushedbehind")
                targ:setVariable("BumpFall", true)
                targ:setVariable("BumpFallType", "pushedbehind")
            else
                targ:setVariable("HitReaction", "Shot")
            end
            
            local recoverHP = dmg / 3
            for i = 2, 6, 2 do
                timer:Simple(i, function()
                    md.LifePoints = math.min(100, md.LifePoints + recoverHP)
                end)
            end
            if getCore():getDebug() and char == getPlayer() or targ == getPlayer()   then 
                print(md.LifePoints)
                print(dmg)
            end

        end
    end
end

Events.OnWeaponHitCharacter.Remove(ParadiseZ.AvoidDmg)
Events.OnWeaponHitCharacter.Add(ParadiseZ.AvoidDmg)
 ]]
function ParadiseZ.isUnarmed(pl)
	return tostring(WeaponType.getWeaponType(pl)) == 'barehand'
end
--[[ 

function testHit(char, targ, wpn, dmg)
    local isCharPl = instanceof(char, "IsoPlayer")
    local isCharZ  = instanceof(char, "IsoZombie")

    local isTargPl = instanceof(targ, "IsoPlayer")
    local isTargZ  = instanceof(targ, "IsoZombie")

    local charUser
    if isCharPl then
        charUser = char:getUsername()
    elseif isCharZ then
        charUser = char:getOutfitName()
    else
        charUser = tostring(char)
    end

    local targUser
    if isTargPl then
        targUser = targ:getUsername()
    elseif isTargZ then
        targUser = targ:getOutfitName()
    else
        targUser = tostring(targ)
    end

    local pos = ""
    if targ.getPlayerAttackPosition then
        pos = targ:getPlayerAttackPosition()
    end

    print("attacker: " .. tostring(charUser)
        .. "\ntarget: " .. tostring(targUser)
        .. "\ndamage: " .. tostring(dmg)
        .. "\nposition: " .. tostring(pos))
end

Events.OnWeaponHitCharacter.Remove(testHit)
Events.OnWeaponHitCharacter.Add(testHit)

]]