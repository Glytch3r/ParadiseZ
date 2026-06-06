-- ParadiseZ_paintBulb.lua
-- B41 shared recipe callback.
-- Carries light bulb condition through paint/clean recipes.
-- Prevents repainting/cleaning damaged bulbs into full-condition bulbs.

local ParadiseZ_PAINT_BULB_TYPES = {
    ["Base.LightBulb"] = true,
    ["Base.LightBulbRed"] = true,
    ["Base.LightBulbGreen"] = true,
    ["Base.LightBulbBlue"] = true,
    ["Base.LightBulbYellow"] = true,
    ["Base.LightBulbCyan"] = true,
    ["Base.LightBulbOrange"] = true,
    ["Base.LightBulbPurple"] = true,
    ["Base.LightBulbPink"] = true,
    ["Base.LightBulbMagenta"] = true,
}

local function ParadiseZ_paintBulb_findSourceBulb(items)
    if not items then return nil end

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item and item.getFullType and ParadiseZ_PAINT_BULB_TYPES[item:getFullType()] then
            return item
        end
    end

    return nil
end

function ParadiseZ_paintBulb_OnCreate(items, result, player)
    if not result then return end

    local sourceBulb = ParadiseZ_paintBulb_findSourceBulb(items)
    if not sourceBulb then return end

    if sourceBulb.getCondition and result.setCondition then
        local condition = sourceBulb:getCondition() or 0

        if result.getConditionMax then
            local maxCondition = result:getConditionMax() or condition
            if condition > maxCondition then
                condition = maxCondition
            end
        end

        if condition < 0 then
            condition = 0
        end

        result:setCondition(condition)
    end
end

--[[ 
    local itemFullType = "Base.LightBulbRed"
    local param = "ConditionMax = 100"
    local item = ScriptManager.instance:getItem(itemFullType)
    if item then
        item:DoParam(param)
    end
    getPlayer():getSquare():AddWorldInventoryItem(tostring(itemFullType), 0.5, 0.5, 0);
 ]]