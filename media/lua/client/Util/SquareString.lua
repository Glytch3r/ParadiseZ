SquareString = SquareString or {}

SquareString._groups = SquareString._groups or {}
SquareString._activeGroup = SquareString._activeGroup or "default"

function SquareString.getGroup(group)
    group = group or SquareString._activeGroup
    SquareString._groups[group] = SquareString._groups[group] or {}
    return SquareString._groups[group]
end

function SquareString.setActiveGroup(group)
    SquareString._activeGroup = group
end

function SquareString.addSqStr(str, x, y, z, r, g, b, font, xOffset, yOffset, visibility, group)
    if not isIngameState() then return nil end

    local gTable = SquareString.getGroup(group)

    if x == nil or y == nil or z == nil then
        local pl = getPlayer()
        if not pl then return nil end
        local sq = pl:getSquare()
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

    gTable[tag] = {
        x = x, y = y, z = z,
        r = r, g = g, b = b,
        xOffset = xOffset,
        yOffset = yOffset,
        text = tostring(str)
    }

    return tag
end

function SquareString.delTagObj(tagObj, group)
    local gTable = SquareString.getGroup(group)
    if gTable[tagObj] then
        gTable[tagObj] = nil
        return true
    end
    return false
end

function SquareString.delBySquare(sq, group)
    if not sq then return false end

    local x, y, z = sq:getX(), sq:getY(), sq:getZ()
    local gTable = SquareString.getGroup(group)

    for tag, data in pairs(gTable) do
        if data.x == x and data.y == y and data.z == z then
            gTable[tag] = nil
            return true
        end
    end

    return false
end

function SquareString.getSqStr(x, y, z, group)
    local gTable = SquareString.getGroup(group)
    for tag, data in pairs(gTable) do
        if data.x == x and data.y == y and data.z == z then
            return tag, data
        end
    end
    return nil
end

function SquareString.hasTagAtSquare(sq, group)
    if not sq then return false end
    local x, y, z = sq:getX(), sq:getY(), sq:getZ()
    local gTable = SquareString.getGroup(group)

    for _, data in pairs(gTable) do
        if data.x == x and data.y == y and data.z == z then
            return true
        end
    end

    return false
end

function SquareString.clearAllTags(group)
    local gTable = SquareString.getGroup(group)
    for tag in pairs(gTable) do
        gTable[tag] = nil
    end
end

function SquareString.renderAllTags()
    if not isIngameState() then return end

    local zoom = getCore():getZoom(0)

    for _, gTable in pairs(SquareString._groups) do
        for tag, data in pairs(gTable) do
            local screenX = (IsoUtils.XToScreen(data.x + data.xOffset, data.y, data.z, 0) - IsoCamera.getOffX()) / zoom
            local screenY = (IsoUtils.YToScreen(data.x, data.y + data.yOffset, data.z, 0) - IsoCamera.getOffY()) / zoom
            tag:AddBatchedDraw(screenX, screenY, data.r, data.g, data.b, 1, false)
        end
    end
end

Events.OnPostRender.Remove(SquareString.renderAllTags)
Events.OnPostRender.Add(SquareString.renderAllTags)