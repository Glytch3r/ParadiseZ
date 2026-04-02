ParadiseZ = ParadiseZ or {}

function ParadiseZ.initFlashData(pl)
    local md = pl:getModData()
    if type(md.FlashAlpha) ~= "number" then md.FlashAlpha = 0 end
    if type(md.LifeBarFlash) ~= "number" then md.LifeBarFlash = 0 end
end

function ParadiseZ.doFlash(targPl)
    local pl = targPl or getPlayer()
    if not pl then return end
    ParadiseZ.initFlashData(pl)
    local md = pl:getModData()

    if md.FlashAlpha <= 0.4 then
        md.FlashAlpha = 0.8
    end
end

function ParadiseZ.drawFlash()
    local pl = getPlayer()
    if not pl then return end

    ParadiseZ.initFlashData(pl)
    local md = pl:getModData()

    local sw, sh = getCore():getScreenWidth(), getCore():getScreenHeight()

    local decay = SandboxVars.ParadiseZ.ThunderFlashDecay or 0.04
    md.FlashAlpha = math.max(0, md.FlashAlpha - decay)
    md.LifeBarFlash = math.max(0, md.LifeBarFlash - decay)
    
    if md.FlashAlpha > 0 then
        getRenderer():renderRect(0, 0, sw, sh, 0.5, 0.5, 0.5, md.FlashAlpha)
    end

    if md.LifeBarFlash > 0 then
        getRenderer():renderRect(0, 0, sw, sh, 1.0, 0.0, 0.0, md.LifeBarFlash)
    end
end

Events.OnPostUIDraw.Remove(ParadiseZ.drawFlash)
Events.OnPostUIDraw.Add(ParadiseZ.drawFlash)