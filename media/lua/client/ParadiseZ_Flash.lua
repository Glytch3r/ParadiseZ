ParadiseZ = ParadiseZ or {}

function ParadiseZ.initFlashData(pl)
    local md = pl:getModData()
    if md.FlashAlpha == nil then md.FlashAlpha = 0 end
    if md.FlashDecayRate == nil then md.FlashDecayRate = 0 end
end

function ParadiseZ.doFlash(targPl)
    local pl = targPl or getPlayer()
    if not pl then return end
    ParadiseZ.initFlashData(pl)
    local md = pl:getModData()
    local decay = SandboxVars.ParadiseZ.ThunderFlashDecay or 0.4
    md.FlashAlpha = 1.0
    md.FlashDecayRate = 1.0 / (decay * 60)
end

function ParadiseZ.drawFlash()
    local pl = getPlayer()
    if not pl then return end
    ParadiseZ.initFlashData(pl)
    local md = pl:getModData()
    if md.FlashAlpha <= 0 then return end

    getRenderer():renderRect(
        0, 0,
        getCore():getScreenWidth(),
        getCore():getScreenHeight(),
        0.5, 0.5, 0.5, md.FlashAlpha
    )

    md.FlashAlpha = md.FlashAlpha - md.FlashDecayRate
    if md.FlashAlpha < 0 then
        md.FlashAlpha = 0
    end
end

Events.OnPostUIDraw.Remove(ParadiseZ.drawFlash)
Events.OnPostUIDraw.Add(ParadiseZ.drawFlash)
