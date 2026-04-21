
SquareString = SquareString or {}
SquareString._tags = {}
function SquareString.addSqStr(str, x, y, z, r, g, b, font, xOffset, yOffset, visibility, group)
    if not isIngameState() then return nil end
    group = group or SquareString._tags

    if x == nil or y == nil or z == nil then
        local player = getPlayer()
        if not player then return nil end
        local sq = player:getSquare()
        if not sq then return nil end
        x, y, z = sq:getX(), sq:getY(), sq:getZ()
    end

    r, g, b = r or 1, g or 1, b or 1
    font = font or UIFont.NewLarge
    xOffset = xOffset or 0
    yOffset = yOffset or 0
    visibility = visibility or 360
    
    local tag = TextDrawObject.new()
    tag:setDefaultFont(font)
    tag:ReadString(font, tostring(str), -1)
    tag:setDefaultColors(r, g, b)
    tag:setVisibleRadius(visibility)
    group[tag] = {
        x = x, y = y, z = z,
        r = r, g = g, b = b,
        xOffset = xOffset, yOffset = yOffset
    }
    return tag
end



function SquareString.delTagObj(tagObj, group)
    group = group or SquareString._tags
    if group[tagObj] then
        group[tagObj] = nil
        return true
    end
    return false
end

function SquareString.delSqStr(x, y, z, group)
    group = group or SquareString._tags
    for tag, data in pairs(group) do
        if data.x == x and data.y == y and data.z == z then
            group[tag] = nil
            return true
        end
    end
    return false
end

function SquareString.getSqStr(x, y, z, group)
    group = group or SquareString._tags
    for tag, data in pairs(group) do
        if data.x == x and data.y == y and data.z == z then
            return tag
        end
    end
    return nil
end

function SquareString.clearAllTags(group)
    group = group or SquareString._tags
    for tag in pairs(group) do
        group[tag] = nil
    end
end

function SquareString.renderAllTags(group)
    group = group or SquareString._tags
    if not isIngameState() then return end
    local zoom = getCore():getZoom(0)
    for tag, data in pairs(group) do
        local screenX = (IsoUtils.XToScreen(data.x + data.xOffset, data.y, data.z, 0) - IsoCamera.getOffX()) / zoom 
        local screenY = (IsoUtils.YToScreen(data.x + data.yOffset, data.y, data.z, 0) - IsoCamera.getOffY()) / zoom
        tag:AddBatchedDraw(screenX, screenY, data.r, data.g, data.b, 1, false)
    end
end
Events.OnPostRender.Remove(SquareString.renderAllTags)
Events.OnPostRender.Add(SquareString.renderAllTags)

-----------------------            ---------------------------
