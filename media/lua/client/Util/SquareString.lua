SquareString = SquareString or {}

SquareString._groups = SquareString._groups or {}
SquareString._activeGroup = SquareString._activeGroup or "default"

local function xyzStr(x,y,z)
    return tostring(x)..":"..tostring(y)..":"..tostring(z)
end

function SquareString.getGroup(group)
    group = group or SquareString._activeGroup
    SquareString._groups[group] = SquareString._groups[group] or {}
    return SquareString._groups[group]
end


function SquareString.setActiveGroup(group)
    SquareString._activeGroup = group
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

function SquareString.addSqStr(str, x, y, z, r, g, b, font, xOffset, yOffset, visibility, group)
    if not isIngameState() then return nil end
    if not str then return nil end
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

    local tag = TextDrawObject.new(r, g, b, true, true)
    tag:setDefaultFont(font)

    local NotesMaxLineWidth = SandboxVars.ParadiseZ.NotesMaxLineWidth or 90
    tag:ReadString(font, tostring(str), NotesMaxLineWidth)
    tag:setAllowLineBreaks(true)
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

function SquareString.set(group, str, x, y, z, opt)
    if not isIngameState() then return end
    if not str then return end

    local g = SquareString.getGroup(group)
    local key = xyzStr(x,y,z)

    opt = opt or {}
    local r,gc,b = opt.r or 1, opt.g or 1, opt.b or 1
    local font = opt.font or UIFont.NewLarge

    local entry = g[key]

    if not entry then
        local tag = TextDrawObject.new(r,gc,b,true,true)
        tag:setDefaultFont(font)
        tag:setAllowLineBreaks(true)

        entry = {
            tag = tag,
            x=x,y=y,z=z,
            text = "",
            r=r,g=gc,b=b,
            visible = true,
            anchor = opt.anchor or "bottom",
            xOffset = opt.xOffset or 0,
            yOffset = opt.yOffset or 0
        }

        g[key] = entry
    end

    if entry.text ~= str then
        entry.text = str
        entry.tag:Clear()

        local NotesMaxLineWidth = SandboxVars.ParadiseZ.NotesMaxLineWidth or 90
        entry.tag:ReadString(font, tostring(str), NotesMaxLineWidth)
    end

    if entry.r ~= r or entry.g ~= gc or entry.b ~= b then
        entry.r,entry.g,entry.b = r,gc,b
        entry.tag:setDefaultColors(r,gc,b)
    end

    entry.visible = true
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
function SquareString.hide(x,y,z,group)
    local g = SquareString.getGroup(group)
    local e = g[xyzStr(x,y,z)]
    if e then e.visible = false end
end

function SquareString.remove(x,y,z,group)
    local g = SquareString.getGroup(group)
    g[xyzStr(x,y,z)] = nil
end

function SquareString.renderAll()
    if not isIngameState() then return end

    local zoom = getCore():getZoom(0)

    for _,g in pairs(SquareString._groups) do
        for _,e in pairs(g) do
            if e.visible then
                local sx = (IsoUtils.XToScreen(e.x+e.xOffset, e.y, e.z, 0) - IsoCamera.getOffX()) / zoom
                local sy = (IsoUtils.YToScreen(e.x, e.y+e.yOffset, e.z, 0) - IsoCamera.getOffY()) / zoom

                if e.anchor == "bottom" then
                    sy = sy - e.tag:getHeight()
                elseif e.anchor == "middle" then
                    sy = sy - (e.tag:getHeight() / 2)
                end

                e.tag:AddBatchedDraw(sx, sy, e.r, e.g, e.b, 1, true)
            end
        end
    end
end

Events.OnPostRender.Remove(SquareString.renderAll)
Events.OnPostRender.Add(SquareString.renderAll)