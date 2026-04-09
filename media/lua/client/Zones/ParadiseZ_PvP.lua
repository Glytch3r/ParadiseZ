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

    local isFirearm = ParadiseZ.isFirearm(wpn)

    if isHasPveTrait or isHasPveZone then
        pvpDmg = false
    end

    if isHasZed then
        isAvoid = false
        pvpDmg = false
    end
    targ:setAvoidDamage(isAvoid)   
    local bonus = 0
    local isCrit = targ:isCriticalHit() 
    if isCrit then
        bonus = ZombRand(0, SandboxVars.ParadiseZpvp.pvpDmgMult + 1)
    end
    
    if pvpDmg and targ == getPlayer() then
        local dmg = ParadiseZ.getPvpWpnDmg(wpn, char)
        local md = targ:getModData()
        
        md.LifePoints = math.max(0, (md.LifePoints or 100) - (dmg+bonus))
        md.LifeBarFlash = 0.4
        if ParadiseZ.doRoll(SandboxVars.ParadiseZpvp.PvPInjuryChance) and isFirearm then
            if not targ:HasTrait('InjuredPvP') then
                targ:getTraits():add('InjuredPvP')
                targ:addLineChatElement('PvP Injured')

            end
        end

        if md.LifePoints <= 0 then
            if not SandboxVars.ParadiseZpvp.teleportPvpDeath then   
                targ:Kill(char)
            end    
        end
    end
end
Events.OnWeaponHitCharacter.Remove(ParadiseZ.pvpHit)
Events.OnWeaponHitCharacter.Add(ParadiseZ.pvpHit)


function ParadiseZ.pvpHeal(player, context, items)
    local pl = getSpecificPlayer(player)
    if not pl then return end

    local item

    if instanceof(items, "InventoryItem") then
        if items:getFullType() == "ParadiseZ.MedkitPvP" then
            item = items
        end
    else
        for i=1,#items do
            local entry = items[i]
            local it = entry
            if type(entry) == "table" and entry.items then
                it = entry.items[1]
            end
            if it and it:getFullType() == "ParadiseZ.MedkitPvP" then
                item = it
                break
            end
        end
    end

    if not item then return end
    if not pl:getInventory():contains(item) then return end
    
    local opt = context:addOption("Apply PvP Medkit", item, function(it)
        ISTimedActionQueue.add(ISApplyMedkitPvP:new(pl, it))
    end)
    local md = pl:getModData()
    if not pl:HasTrait("InjuredPvP") and md.LifePoints >= 100 then
        opt.notAvailable = true
        local tt = ISToolTip:new()
        tt:initialise()
        tt:setVisible(false)
        tt.description = "You are not Injured"
        opt.toolTip = tt
    end
end

Events.OnFillInventoryObjectContextMenu.Add(ParadiseZ.pvpHeal)



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