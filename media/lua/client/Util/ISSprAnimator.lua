ISSprAnimator = ISSprAnimator or {}

ISSprAnimator.LavaLamp = {
    ["ParadiseTiles_48"] = "ParadiseTiles_49",
    ["ParadiseTiles_49"] = "ParadiseTiles_50",
    ["ParadiseTiles_50"] = "ParadiseTiles_51",
    ["ParadiseTiles_51"] = "ParadiseTiles_48",
}
function ISSprAnimator.setSprAnim(interval, rad, tab)
    interval = interval or 3
    rad = rad or 30

    local order = {}
    for k,_ in pairs(tab) do
        table.insert(order, k)
    end
    table.sort(order)
    local function animHandler(ticks)
        if ticks % interval ~= 0 then return end

        local pl = getPlayer()
        if not pl then return end

        local cell = pl:getCell()
        local px = math.floor(pl:getX())
        local py = math.floor(pl:getY())
        local pz = pl:getZ()
        for x = px - rad, px + rad do
            for y = py - rad, py + rad do
                local sq = cell:getOrCreateGridSquare(x, y, pz)
                if sq then
                    local objs = sq:getObjects()
                    for i = 0, objs:size() - 1 do
                        local obj = objs:get(i)
                        if obj and obj.getSprite then
                            local md = obj:getModData()
                            local spr = obj:getSprite()

                            if spr then
                                local sprName = spr:getName()

                                if not md.animIndex then
                                    for idx,name in ipairs(order) do
                                        if name == sprName then
                                            md.animIndex = idx
                                            break
                                        end
                                    end
                                end

                                if md.animIndex then
                                    md.animIndex = md.animIndex + 1
                                    if md.animIndex > #order then
                                        md.animIndex = 1
                                    end
                                    obj:setSprite(order[md.animIndex])
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    Events.OnTick.Add(animHandler)
end
--[[ 
function ISSprAnimator.init(plNum, pl)
    ISSprAnimator.setSprAnim(4, 30, ISSprAnimator.LavaLamp)
end
Events.OnCreatePlayer.Add(ISSprAnimator.init)
 ]]