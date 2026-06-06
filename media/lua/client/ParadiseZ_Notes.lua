ParadiseZ = ParadiseZ or {}
SquareString = SquareString or {}
SquareString._groups = SquareString._groups or {}
SquareString._groups["Notes"] = SquareString._groups["Notes"] or {}

local NOTES_GROUP = "Notes"

local function _pzNoteInt(value, fallback, minValue, maxValue)
    local n = tonumber(value)
    if not n then n = fallback end
    n = math.floor(n)
    if minValue and n < minValue then n = minValue end
    if maxValue and n > maxValue then n = maxValue end
    return n
end

local function _pzNoteSquareKey(x, y, z)
    return tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(z)
end

local function _pzNoteUpdateTicks()
    local sv = SandboxVars and SandboxVars.ParadiseZ
    return _pzNoteInt(sv and sv.NotesUpdateTicks, 5, 1, 25)
end

local function _pzNoteVisibilityDistance()
    local sv = SandboxVars and SandboxVars.ParadiseZ
    return _pzNoteInt(sv and sv.NotesVisibilityDistance, 5, 0, 500)
end

local function _pzRefreshNoteSquare(sq)
    if not sq then return false end

    local flr = sq:getFloor()
    if not flr then return false end

    local x, y, z = sq:getX(), sq:getY(), sq:getZ()
    local md = flr:getModData()
    local note = md and md["FloorNote"]

    if not note or note == "" or note == " " then
        return SquareString.delBySquare(sq, NOTES_GROUP)
    end

    local col = md["FloorNoteColor"] or {r=1, g=1, b=1}
    SquareString.addSqStr(
        tostring(note),
        x, y, z,
        col.r or 1, col.g or 1, col.b or 1,
        UIFont.NewLarge,
        0, 0,
        360,
        NOTES_GROUP
    )

    return true
end

-----------------------            ---------------------------
function ParadiseZ.textModal(text, callback, target, player, param1, param2)
    local entry = nil

    local function onClick(self, button, p1, p2)
        if button.internal == "OK" and entry then
            local val = entry:getText()
            if callback then
                callback(target, val, p1, p2)
            end
        end
    end

    local modal = ISModalDialog:new(0, 0, 300, 150, text or "", false, target, onClick, player, param1, param2)
    modal:initialise()
    modal:addToUIManager()

    entry = ISTextEntryBox:new("", 20, 60, modal.width - 40, 25)
    entry:initialise()
    entry:instantiate()
    modal:addChild(entry)

    return modal
end

-----------------------            ---------------------------
function ParadiseZ.isHasNote(sq)
    if not sq then return false end
    local flr = sq:getFloor()
    if not flr then return false end
    local md = flr:getModData()
    return md and md['FloorNote'] ~= nil
end

function ParadiseZ.getNote(sq)
    if not ParadiseZ.isHasNote(sq) then return nil end
    return sq:getFloor():getModData()['FloorNote']
end

function ParadiseZ.getNoteColor(sq)
    if not ParadiseZ.isHasNote(sq) then return nil end
    return sq:getFloor():getModData()['FloorNoteColor'] or {r=1,g=1,b=1}
end

-----------------------            ---------------------------
function ParadiseZ.noteContext(plNum, context, worldobjects, test)
    local pl = getSpecificPlayer(plNum)
    local sq = luautils.stringStarts(getCore():getVersion(), "42") and ISWorldObjectContextMenu.fetchVars.clickedSquare or clickedSquare
    if not sq then return end
    local flr = sq:getFloor()
    if not flr then return end
    local isAdm = string.lower(pl:getAccessLevel()) == "admin"
    local note
    local isHasNote = ParadiseZ.isHasNote(sq)
    local noteHighlightRemove = nil
    local noteHighlightRemovePress = nil

    if isHasNote then
        note = ParadiseZ.getNote(sq)

        flr:setHighlighted(true, false)
        noteHighlightRemove = function()
            flr:setHighlighted(false)
            if noteHighlightRemovePress then
                Events.OnKeyPressed.Remove(noteHighlightRemovePress)
            end
            Events.OnMouseDown.Remove(noteHighlightRemove)
        end
        noteHighlightRemovePress = function(key)
            if key == getCore():getKey("CancelAction") or key == Keyboard.KEY_ESCAPE then
                noteHighlightRemove()
            end
        end
        Events.OnKeyPressed.Add(noteHighlightRemovePress)
        Events.OnMouseDown.Add(noteHighlightRemove)
    end

    local canWrite = isAdm or SandboxVars.ParadiseZ.EveryoneCanWriteNotes
    if canWrite then
        local WriteCaption = "Write Note"

        if note ~= nil then
            local DelOpt = context:addOptionOnTop("Delete Note", worldobjects, function()
                if luautils.walkAdj(pl, sq) then
                    local md = flr:getModData()
                    md['FloorNote'] = nil
                    md['FloorNoteColor'] = nil
                    flr:transmitModData()
                    SquareString.delBySquare(sq, NOTES_GROUP)
                    pl:playSoundLocal("MapRemoveMarking")
                    if noteHighlightRemove then noteHighlightRemove() end
                end
                getSoundManager():playUISound("UIActivateMainMenuItem")
                context:hideAndChildren()
            end)
            DelOpt.iconTexture = getTexture("media/ui/Paradise/context_noteDel.png")

            WriteCaption = "Edit Note"

            local RGBOpt = context:addOptionOnTop("Color Note", worldobjects, function()
                if luautils.walkAdj(pl, sq) then
                    ParadiseZ.promptColor(function(r, g, b)
                        local md = flr:getModData()
                        md['FloorNoteColor'] = {r=r,g=g,b=b}
                        flr:transmitModData()
                        _pzRefreshNoteSquare(sq)
                        pl:playSoundLocal("MapAddSymbol")
                    end)
                end
                getSoundManager():playUISound("UIActivateMainMenuItem")
                context:hideAndChildren()
            end)
            RGBOpt.iconTexture = getTexture("media/ui/Paradise/context_noteRGB.png")
        end

        local WriteOpt = context:addOptionOnTop(WriteCaption, worldobjects, function()
            if luautils.walkAdj(pl, sq) then
                ParadiseZ.textModal("Enter value:", function(target, value)
                    if value ~= nil and value ~= "" and value ~= " " then
                        flr:getModData()['FloorNote'] = tostring(value)
                        flr:transmitModData()
                        _pzRefreshNoteSquare(sq)
                        pl:playSoundLocal("MapAddNote")
                    end
                end)
            end
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        WriteOpt.iconTexture = getTexture("media/ui/Paradise/context_noteWrite.png")

        if note ~= nil and note ~= "" and note ~= " " then
            local tooltip = ISToolTip:new()
            tooltip:initialise()
            tooltip.description = tostring(note)
            WriteOpt.toolTip = tooltip
        end
    end
end
Events.OnFillWorldObjectContextMenu.Remove(ParadiseZ.noteContext)
Events.OnFillWorldObjectContextMenu.Add(ParadiseZ.noteContext)

-----------------------            ---------------------------
function ParadiseZ.syncNotes(pl)
    if not pl then return end

    local updateTicks = _pzNoteUpdateTicks()
    ParadiseZ._noteUpdateTick = (ParadiseZ._noteUpdateTick or 0) + 1
    if updateTicks > 1 and (ParadiseZ._noteUpdateTick % updateTicks) ~= 0 then
        return
    end

    local gTable = SquareString.getGroup(NOTES_GROUP)

    local px = math.floor(pl:getX())
    local py = math.floor(pl:getY())
    local pz = pl:getZ()

    local rad = _pzNoteVisibilityDistance()
    local radSq = rad * rad

    local hoverSq = ParadiseZ.getPointer()
    local hx, hy, hz = nil, nil, nil
    if hoverSq then
        hx = hoverSq:getX()
        hy = hoverSq:getY()
        hz = hoverSq:getZ()
    end

    local visible = {}

    local function processSquare(x, y, z, force)
        local sq2 = pl:getCell():getGridSquare(x, y, z)
        if not sq2 then return end

        local flr = sq2:getFloor()
        if not flr then return end

        local md = flr:getModData()
        local note = md and md["FloorNote"]
        if not note then return end

        local dx = x - px
        local dy = y - py
        local distSq = dx*dx + dy*dy

        local inRadius = distSq <= radSq
        local isHover = (hx and x == hx and y == hy and z == hz)

        if not (force or inRadius or isHover) then return end

        local key = _pzNoteSquareKey(x, y, z)
        visible[key] = true
        _pzRefreshNoteSquare(sq2)
    end

    for x = px - rad, px + rad do
        for y = py - rad, py + rad do
            processSquare(x, y, pz, false)
        end
    end

    if hx and hy and hz then
        processSquare(hx, hy, hz, true)
    end

    for key in pairs(gTable) do
        if not visible[key] then
            gTable[key] = nil
        end
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.syncNotes)
Events.OnPlayerUpdate.Add(ParadiseZ.syncNotes)
