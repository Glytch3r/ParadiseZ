ParadiseZ = ParadiseZ or {}

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
	if not ParadiseZ.isUnarmed(char, wpn) then
        targ:setAvoidDamage(isAvoid)
    end
    if pvpDmg then
        if targ == getPlayer() then
            local md = targ:getModData()
            md.LifePoints = math.max(0, md.LifePoints - dmg)
            md.LifeBarFlash = (md.LifeBarFlash or 0) + dmg
            
            if md.LifePoints <= 0 then
                targ:Kill(char)
            else

                local pvpStaggerChance = SandboxVars.ParadiseZ.pvpStaggerChance or 34
                if pvpStaggerChance and ParadiseZ.doRoll(pvpStaggerChance) then
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
            end
        end
    end
end

Events.OnWeaponHitCharacter.Remove(ParadiseZ.AvoidDmg)
Events.OnWeaponHitCharacter.Add(ParadiseZ.AvoidDmg)

function ParadiseZ.isUnarmed(pl, wpn)
    wpn = wpn or pl:getPrimaryHandItem() 
	return (tostring(WeaponType.getWeaponType(pl)) == 'barehand' or (wpn and wpn:getCategories():contains("Unarmed"))) or wpn == nil
end
