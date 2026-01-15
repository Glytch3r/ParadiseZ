ParadiseZ = ParadiseZ or {}
function ParadiseZ.isPvpInvalid(char)
    char = char or getPlayer() 
    local isHasPveTrait = ParadiseZ.isPvE(char)
    local isHasPveZone = ParadiseZ.isPveZone(char)
    return isHasPveTrait or isHasPveZone
end
function ParadiseZ.isUnarmed(pl)
	return tostring(WeaponType.getWeaponType(pl)) == 'barehand'
end

function ParadiseZ.getPvpWpnDmg(wpn, char)
    char = char or getPlayer()
    local wpnDmg = 0

    if ParadiseZ.isUnarmed(char) then
        return 0
    end

    wpn = wpn or char:getPrimaryHandItem()
    if not wpn then
        return SandboxVars.ParadiseZ.MeleePvpDmg or 10
    end

    local item = ScriptManager.instance:getItem(wpn:getFullType())
    local isMeleeAttack = char:IsInMeleeAttack()
    if not item or not item:isRanged() or isMeleeAttack then
        return SandboxVars.ParadiseZ.MeleePvpDmg or 10
    end

    if item.getSwingAnim and item:getSwingAnim() == "Rifle" then
        local shotgunTable = ParadiseZ.getShotgunTable()
        if shotgunTable[wpn:getFullType()] then
            wpnDmg = SandboxVars.ParadiseZ.ShotgunPvpDmg or 25
        else
            wpnDmg = SandboxVars.ParadiseZ.RiflePvpDmg or 20
        end
    else
        wpnDmg = SandboxVars.ParadiseZ.PistolPvpDmg or 15
    end

    return wpnDmg
end





function ParadiseZ.pvpHit(char, targ, wpn, damage)
    local isAvoid = true
    local isHasPveTrait = ParadiseZ.isPvE(char) or ParadiseZ.isPvE(targ)
    local isHasPveZone = ParadiseZ.isPveZone(char) or ParadiseZ.isPveZone(targ)
    local isHasZed = instanceof(char, 'IsoZombie') or instanceof(targ, 'IsoZombie')
    local pvpDmg = true

    if isHasPveTrait or isHasPveZone then
        pvpDmg = false
    end

    if isHasZed then
        isAvoid = false
        pvpDmg = false
    end
    targ:setAvoidDamage(isAvoid)
    
    
    --dmg = dmg * ( or 1.6)
    local bonus = 0
    
    --print(targ == getPlayer())

    local isCrit = targ:isCriticalHit() 
    if isCrit then
        bonus = ZombRand(0, SandboxVars.ParadiseZ.pvpDmgMult + 1)
    end
    local isLocal = targ == getPlayer() 

    if pvpDmg then
        local dmg = ParadiseZ.getPvpWpnDmg(wpn, char)
        if isLocal then
            local md = targ:getModData()    
            md.LifePoints = math.max(0, (md.LifePoints or 100) - (dmg+bonus))
            md.LifeBarFlash = (md.LifeBarFlash or 0) + dmg
        
            if md.LifePoints <= 0 then
                if SandboxVars.ParadiseZ.teleportPvpDeath then
                    ParadiseZ.doRebound(targ)
                else               
                    targ:Kill(char)
                end
                targ:setPlayingDeathSound(true)
--[[ 
                if isCrit then
                    local roll = ParadiseZ.doRoll(SandboxVars.ParadiseZ.pvpStaggerChance)
        

                    if roll  then    
                        local isBackstab = targ:isHitFromBehind()
                        local pushedDir = "pushedFront"
                        if isBackstab then
                            pushedDir = "pushedbehind"
                        end
                        sendClientCommand("ParadiseZ", "knockDownPl", { targId = targ:getOnlineID(), pushedDir = pushedDir })
                    end
                end
 ]]
            end
        end
        
        if targ:isAlive() then
            targ:setHitReaction("Shot")
        end
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