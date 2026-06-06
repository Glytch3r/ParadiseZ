SquareString = SquareString or {}

SquareString._groups = SquareString._groups or {}
SquareString._activeGroup = SquareString._activeGroup or "default"

-- Notes-specific rendering constants. Sandbox values override these fallbacks.
SquareString.NotesWrapWidth = SquareString.NotesWrapWidth or 70
SquareString.NotesExtraAnchorLines = SquareString.NotesExtraAnchorLines or 3

local function xyzKey(x, y, z)
    return tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(z)
end

local function clampInt(value, fallback, minValue, maxValue)
    local n = tonumber(value)
    if not n then n = fallback end
    n = math.floor(n)
    if minValue and n < minValue then n = minValue end
    if maxValue and n > maxValue then n = maxValue end
    return n
end

local function getNotesWrapWidth()
    local sv = SandboxVars and SandboxVars.ParadiseZ
    return clampInt(sv and sv.NotesMaxLineWidth, SquareString.NotesWrapWidth or 70, 1, 1000)
end

local function getDrawObjectHeight(tagObj, font)
    if tagObj then
        pcall(function()
            tagObj:calculateDimensions()
        end)

        local ok, h = pcall(function()
            return tagObj:getHeight()
        end)

        if ok and h and h > 0 then
            return h
        end
    end

    local tm = getTextManager()
    if tm then
        local ok, h = pcall(function()
            return tm:getFontHeight(font)
        end)

        if ok and h and h > 0 then
            return h
        end
    end

    return 20
end

local function getOneLineHeight(font, wrapWidth)
    local tag = TextDrawObject.new()
    tag:setDefaultFont(font)
    tag:ReadString(font, "X", wrapWidth or -1)
    return getDrawObjectHeight(tag, font)
end

function SquareString.getGroup(group)
    group = group or SquareString._activeGroup
    SquareString._groups[group] = SquareString._groups[group] or {}
    return SquareString._groups[group]
end

function SquareString.setActiveGroup(group)
    SquareString._activeGroup = group or "default"
end

function SquareString.addSqStr(str, x, y, z, r, g, b, font, xOffset, yOffset, visibility, group)
    if not isIngameState() then return nil end
    if not str then return nil end

    local groupName = group or SquareString._activeGroup
    local gTable = SquareString.getGroup(groupName)

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

    local key = xyzKey(x, y, z)
    local text = tostring(str)
    local wrapWidth = -1
    if groupName == "Notes" then
        wrapWidth = getNotesWrapWidth()
    end

    local entry = gTable[key]
    local tag = entry and entry.tag or TextDrawObject.new()
    tag:setDefaultFont(font)

    if not entry or entry.text ~= text or entry.wrapWidth ~= wrapWidth or entry.font ~= font then
        pcall(function() tag:Clear() end)
        tag:ReadString(font, text, wrapWidth)
        pcall(function() tag:setAllowLineBreaks(true) end)
    end

    tag:setDefaultColors(r, g, b)
    tag:setVisibleRadius(visibility)

    local notePixelUp = nil
    if groupName == "Notes" then
        local singleH = getOneLineHeight(font, wrapWidth)
        local fullH = getDrawObjectHeight(tag, font)
        local bottomAnchorUp = math.max(0, fullH - singleH)
        local fixedUp = singleH * (SquareString.NotesExtraAnchorLines or 3)
        notePixelUp = bottomAnchorUp + fixedUp
    end

    entry = {
        tag = tag,
        x = x, y = y, z = z,
        r = r, g = g, b = b,
        xOffset = xOffset,
        yOffset = yOffset,
        text = text,
        font = font,
        wrapWidth = wrapWidth,
        notePixelUp = notePixelUp
    }

    gTable[key] = entry
    return tag, entry
end

function SquareString.delBySquare(sq, group)
    if not sq then return false end

    local key = xyzKey(sq:getX(), sq:getY(), sq:getZ())
    local gTable = SquareString.getGroup(group)

    if gTable[key] then
        gTable[key] = nil
        return true
    end

    return false
end

function SquareString.getSqStr(x, y, z, group)
    local entry = SquareString.getGroup(group)[xyzKey(x, y, z)]
    if entry then
        return entry.tag, entry
    end
    return nil, nil
end

function SquareString.renderAllTags()
    if not isIngameState() then return end

    local zoom = getCore():getZoom(0)

    for _, gTable in pairs(SquareString._groups) do
        for _, data in pairs(gTable) do
            local tag = data.tag
            if tag then
                local screenX = (IsoUtils.XToScreen(data.x + data.xOffset, data.y, data.z, 0) - IsoCamera.getOffX()) / zoom
                local screenY = (IsoUtils.YToScreen(data.x, data.y + data.yOffset, data.z, 0) - IsoCamera.getOffY()) / zoom

                if data.notePixelUp then
                    screenY = screenY - data.notePixelUp
                end

                tag:AddBatchedDraw(screenX, screenY, data.r, data.g, data.b, 1, false)
            end
        end
    end
end

Events.OnPostRender.Remove(SquareString.renderAllTags)
Events.OnPostRender.Add(SquareString.renderAllTags)
