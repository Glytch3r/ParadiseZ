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
        return SandboxVars.ParadiseZpvp.MeleePvpDmg or 10
    end

    local item = ScriptManager.instance:getItem(wpn:getFullType())
    local isMeleeAttack = char:IsInMeleeAttack()
    if not item or not item:isRanged() or isMeleeAttack then
        return SandboxVars.ParadiseZpvp.MeleePvpDmg or 10
    end

    if item.getSwingAnim and item:getSwingAnim() == "Rifle" then
        local shotgunTable = ParadiseZ.getShotgunTable()
        if shotgunTable[wpn:getFullType()] then
            wpnDmg = SandboxVars.ParadiseZpvp.ShotgunPvpDmg or 25
        else
            wpnDmg = SandboxVars.ParadiseZpvp.RiflePvpDmg or 20
        end
    else
        wpnDmg = SandboxVars.ParadiseZpvp.PistolPvpDmg or 15
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
        bonus = ZombRand(0, SandboxVars.ParadiseZpvp.pvpDmgMult + 1)
    end
    
    if pvpDmg and targ == getPlayer() then
        local dmg = ParadiseZ.getPvpWpnDmg(wpn, char)
        local md = targ:getModData()
        
        md.LifePoints = math.max(0, (md.LifePoints or 100) - (dmg+bonus))
        md.LifeBarFlash = 0.4
        
        if md.LifePoints <= 0 then
            if not SandboxVars.ParadiseZpvp.teleportPvpDeath then   
                targ:Kill(char)
            end
            --targ:setPlayingDeathSound(true)
        end

    end
end
Events.OnWeaponHitCharacter.Remove(ParadiseZ.pvpHit)
Events.OnWeaponHitCharacter.Add(ParadiseZ.pvpHit)
function ParadiseZ.exileHandler(pl)
    pl = pl or getPlayer()
    if not pl then return end
    if not pl:isAlive() then return end
    local md = pl:getModData()
    if md.LifePoints <= 0  and SandboxVars.ParadiseZpvp.teleportPvpDeath then
        ParadiseZ.doPvPExile(pl)
    end
end
Events.OnPlayerUpdate.Add(ParadiseZ.exileHandler)

function ParadiseZ.doPvPExile(pl)
    --if not SandboxVars.ParadiseZ.ReboundSystem then return end
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    
    local x, y, z = ParadiseZ.parseExileCoords() 
    if not x or not y or not z then return end
    
    local car = pl:getVehicle()
    if car then
        ParadiseZ.forceExitCar()
    end
    timer:Simple(1, function() 
        ParadiseZ.tp(pl, x, y, z)
        local sq = getCell():getOrCreateGridSquare(x, y, z)
        if sq then ParadiseZ.addTempMarker(sq) end
    end)
end


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
    
    dmg = dmg * (SandboxVars.ParadiseZpvp.pvpDmgMult or 1.6)
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
     
            local pvpStaggerChance = SandboxVars.ParadiseZpvp.pvpStaggerChance or 34
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