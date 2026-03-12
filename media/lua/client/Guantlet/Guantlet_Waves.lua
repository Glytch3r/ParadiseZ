-- Client

Guantlet = Guantlet or {}

GauntletWaves = GauntletWaves or {}

local WaveState = {}

function Guantlet.waveTick()
    for id, state in pairs(WaveState) do
        if not state.Running then break end

        state.Timer = state.Timer - 1

        if GuantletData[tostring(id)] then
            GuantletData[tostring(id)].Timer = state.Timer
        end

        if state.Timer <= 0 then
            Guantlet.endGuantlet(id)
            break
        end

        state.WaveTick = state.WaveTick - 1

        if state.WaveTick <= 0 then
            if state.InBreak then
                state.InBreak = false
                state.WaveTick = state.TimePerWave
                Guantlet.spawnWave(id)
            else
                Guantlet.despawnWaveZeds(id)
                if state.CurrentWave >= state.TotalWaves then
                    Guantlet.endGuantlet(id)
                else
                    state.InBreak = true
                    state.WaveTick = state.BreaktimeSeconds
                end
            end
        end
    end
end

function Guantlet.getRandSq(cx, cy, cz)
    local minRad = 10
    local maxRad = 20
    local cell = getCell()
    local nearbySquare = nil
    local attempts = 0
    repeat
        local offsetX = ZombRand(-maxRad, maxRad + 1)
        local offsetY = ZombRand(-maxRad, maxRad + 1)
        local distance = math.sqrt(offsetX ^ 2 + offsetY ^ 2)
        if distance >= minRad and distance <= maxRad then
            nearbySquare = cell:getOrCreateGridSquare(cx + offsetX, cy + offsetY, cz)
        end
        attempts = attempts + 1
    until nearbySquare or attempts > 50
    return nearbySquare
end

function Guantlet.startGuantlet(GuantletId, config)
    if not GuantletId then return end
    if not GuantletData then GuantletData = {} end

    config = config or {}
    local zedsPerWave      = config.zedsPerWave      or 2
    local timePerWave      = config.timePerWave      or 60
    local numWaves         = config.numWaves         or 3
    local breaktimeSeconds = config.breaktimeSeconds or 30
    local Level            = config.Level            or 1

    if GuantletData[tostring(GuantletId)] and GuantletData[tostring(GuantletId)].Active then return end

    local pl = getPlayer()
    local sq = pl:getSquare()
    local cx, cy, cz = sq:getX(), sq:getY(), sq:getZ()

    local totalTimer = (numWaves * timePerWave) + ((numWaves - 1) * breaktimeSeconds)

    Guantlet.setGuantletData(GuantletId, Level, cx, cy, cz, true)
    GuantletData[tostring(GuantletId)].Timer = totalTimer

    WaveState[tostring(GuantletId)] = {
        GuantletId       = GuantletId,
        CurrentWave      = 0,
        TotalWaves       = numWaves,
        ZedsPerWave      = zedsPerWave,
        TimePerWave      = timePerWave,
        BreaktimeSeconds = breaktimeSeconds,
        Timer            = totalTimer,
        WaveTick         = 1,
        InBreak          = false,
        CX = cx, CY = cy, CZ = cz,
        Running          = true,
    }

    Guantlet.spawnWave(GuantletId)
end

function Guantlet.spawnWave(GuantletId)
    local state = WaveState[tostring(GuantletId)]
    if not state or not state.Running then return end

    state.CurrentWave = state.CurrentWave + 1
    state.WaveTick = state.TimePerWave

    local cx, cy, cz = state.CX, state.CY, state.CZ

    for i = 1, state.ZedsPerWave do
        local sq = Guantlet.getRandSq(cx, cy, cz)
        if sq then
            local x, y, z = sq:getX(), sq:getY(), sq:getZ()
            local fit, fChance = Guantlet.getSpawnRandomZedInfo()
            if isClient() then
                sendClientCommand('Guantlet', 'doSpawn', {x = x, y = y, z = z, count = 1, fit = fit, fChance = fChance, isDown = false})
            else
                addZombiesInOutfit(x, y, z, 1, fit, fChance, false, false, false, false, 1.0)
            end
        end
    end
end

function Guantlet.despawnWaveZeds(GuantletId)
    local state = WaveState[tostring(GuantletId)]
    if not state then return end
    local cx, cy = state.CX, state.CY
    if not cx or not cy then return end
    local cell = getCell()
    for i = 0, cell:getObjectList():size() - 1 do
        local obj = cell:getObjectList():get(i)
        if instanceof(obj, "IsoZombie") then
            local dx = obj:getX() - cx
            local dy = obj:getY() - cy
            if math.sqrt(dx * dx + dy * dy) <= 25 then
                Guantlet.doDespawn(obj)
            end
        end
    end
end

function Guantlet.endGuantlet(GuantletId)
    local state = WaveState[tostring(GuantletId)]
    if state then
        state.Running = false
        Guantlet.despawnWaveZeds(GuantletId)
    end
    WaveState[tostring(GuantletId)] = nil
    Guantlet.delGuantletData(GuantletId)
end

function Guantlet.stopGuantlet(GuantletId)
    local state = WaveState[tostring(GuantletId)]
    if state then
        state.Running = false
    end
    Guantlet.endGuantlet(GuantletId)
end