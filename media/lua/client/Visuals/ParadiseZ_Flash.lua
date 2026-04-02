ParadiseZ = ParadiseZ or {}

function ParadiseZ.initFlashData(pl)
    local md = pl:getModData()
    if type(md.FlashAlpha) ~= "number" then md.FlashAlpha = 0 end
    if type(md.FlashDecayRate) ~= "number" then md.FlashDecayRate = 0 end
    if type(md.LifeBarFlash) ~= "number" then md.LifeBarFlash = 0 end
end

function ParadiseZ.doFlash(targPl)
    local pl = targPl or getPlayer()
    if not pl then return end
    ParadiseZ.initFlashData(pl)
    local md = pl:getModData()

    local decay = SandboxVars.ParadiseZ.ThunderFlashDecay or 0.4
    if type(decay) ~= "number" or decay <= 0 then decay = 0.4 end

    md.FlashAlpha = 1.0

    local frames = math.max(1, decay * 60)
    md.FlashDecayRate = 1.0 / frames

    if md.FlashDecayRate < 0.001 then
        md.FlashDecayRate = 0
    end
end

function ParadiseZ.drawFlash()
    local pl = getPlayer()
    if not pl then return end

    ParadiseZ.initFlashData(pl)
    local md = pl:getModData()

    local sw, sh = getCore():getScreenWidth(), getCore():getScreenHeight()

    if md.FlashAlpha > 0 then
        getRenderer():renderRect(0, 0, sw, sh, 0.5, 0.5, 0.5, md.FlashAlpha)
        md.FlashAlpha = md.FlashAlpha - md.FlashDecayRate
        if md.FlashAlpha <= 0.001 then md.FlashAlpha = 0 end
    end

    if md.LifeBarFlash > 0 then
        local decay = (LifeBarUI and LifeBarUI.flashDecayRate) or 0
        if type(decay) ~= "number" then decay = 0 end
        md.LifeBarFlash = math.max(0, md.LifeBarFlash - decay)
        getRenderer():renderRect(0, 0, sw, sh, 1.0, 0.0, 0.0, md.LifeBarFlash)
    end
end

Events.OnPostUIDraw.Remove(ParadiseZ.drawFlash)
Events.OnPostUIDraw.Add(ParadiseZ.drawFlash)