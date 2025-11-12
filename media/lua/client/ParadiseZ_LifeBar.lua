ParadiseZ = ParadiseZ or {}
LifeBarUI = LifeBarUI or {}

LifeBarUI.panel = nil
LifeBarUI.visible = true
LifeBarUI.maxValue = 100
LifeBarUI.flashDecayRate = 1.8

LifeBarUI.UI = ISPanel:derive("LifeBarUI_UI")

function LifeBarUI.UI:initialise()
    ISPanel.initialise(self)
end

function LifeBarUI.UI:render()
    local pl = getPlayer()
    if not pl then return end
    local md = pl:getModData()
    md.LifePoints = md.LifePoints or 100
    md.LifeBarFlash = md.LifeBarFlash or 0

    local life = md.LifePoints
    local w = self.width - 4
    local h = self.height - 4
    local barW = (life / LifeBarUI.maxValue) * w

    local col = ParadiseZ.getConditionRGB(life)

    self:drawRect(2, 2, w, h, 1, 0, 0, 0)
    self:drawRect(2, 2, barW, h, 1, col.r, col.g, col.b)
    self:drawRectBorder(2, 2, w, h, 1, 1, 1, 1)


    if md.LifeBarFlash > 0 then
        local alpha = math.min(1, md.LifeBarFlash / 100)
        self:drawRect(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight(), alpha * 0.5, 1, 0, 0, 0)
        md.LifeBarFlash = math.max(0, md.LifeBarFlash - LifeBarUI.flashDecayRate)
    end
    md.LifePoints = math.min(100, md.LifePoints + 0.01)




end

function LifeBarUI.UI:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end

function LifeBarUI.create()
    local x, y, w, h = 68, 50, 150, 20
    local ui = LifeBarUI.UI:new(x, y, w, h)
    ui:initialise()
    ui:addToUIManager()
    LifeBarUI.panel = ui
end

function LifeBarUI.show()
    if not LifeBarUI.panel then LifeBarUI.create() end
    LifeBarUI.visible = true
    LifeBarUI.panel:setVisible(true)
end

function LifeBarUI.hide()
    if not LifeBarUI.panel then return end
    LifeBarUI.visible = false
    LifeBarUI.panel:setVisible(false)
end

Events.OnCreatePlayer.Add(function()
    LifeBarUI.create()
end)

function ParadiseZ.AvoidDmg(char, targ, wpn, dmg)
    local isAvoid = true
    if ParadiseZ.isPveZone(char) or ParadiseZ.isPveZone(targ) then
        isAvoid = false
    end
    if instanceof(char, 'IsoZombie') or instanceof(targ, 'IsoZombie') then
        isAvoid = false
    end

    dmg = dmg * (SandboxVars.ParadiseZ.pvpDmgMult or 1.6)
    targ:setAvoidDamage(isAvoid)

    if not isAvoid and targ == getPlayer() then
        local md = targ:getModData()
        md.LifePoints = math.max(0, md.LifePoints - dmg)
        md.LifeBarFlash = (md.LifeBarFlash or 0) + dmg
        
        if md.LifePoints <= 0 then
            targ:Kill(char)
        else
            local percent = SandboxVars.ParadiseZ.pvpStaggerChance or 34
            if ParadiseZ.doRoll(percent) then
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





Events.OnWeaponHitCharacter.Remove(ParadiseZ.AvoidDmg)
Events.OnWeaponHitCharacter.Add(ParadiseZ.AvoidDmg)

function ParadiseZ.getConditionRGB(condition)
    local t = condition / 100
    return {r = 1 - t, g = 0, b = t}
end

function ParadiseZ.testDmg(targ, dmg)
    dmg = dmg or 15
    dmg = math.min(100, dmg)
    targ = targ or getPlayer() 
    if not targ then return end
    local md = targ:getModData()
    md.LifePoints = math.max(0, md.LifePoints - dmg)
    md.LifeBarFlash = (md.LifeBarFlash or 0) + dmg

    local percent = SandboxVars.ParadiseZ.pvpStaggerChance or 34
    if ParadiseZ.doRoll(percent) then
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