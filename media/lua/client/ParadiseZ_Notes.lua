
ParadiseZ = ParadiseZ or {}
SquareString = SquareString or {}
SquareString._groups = SquareString._groups or {}
SquareString._groups["Notes"] = SquareString._groups["Notes"] or {}
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

function ParadiseZ.showNote(sq)
    local x, y, z = round(sq:getX()), round(sq:getY()), sq:getZ()
    if x and y and z then
        local note = ParadiseZ.getNote(sq)
        local group = SquareString._groups["Notes"]
        SquareString.addSqStr(tostring(note), x, y, z, r, g, b, font, xOffset, yOffset, visibility, group)
    end
end

local ticks = 0
function ParadiseZ.noteHover(pl)
    ticks = ticks + 1
    if ticks % 3 == 0 then
        SquareString._groups["Notes"] = SquareString._groups["Notes"] or {}
        local group = SquareString._groups["Notes"]
        if not pl then return end
        local sq = ParadiseZ.getPointer()
        if not sq then return end
        
        if ParadiseZ.isHasNote(sq) then
            ParadiseZ.showNote(sq)
        else
            --SquareString.clearAllTags(group)
        end

        local rad = 5
        local x, y, z = pl:getX(), pl:getY(), pl:getZ()
        for xDelta = -rad, rad do
            for yDelta = -rad, rad do
                local sq2 = pl:getCell():getOrCreateGridSquare(x + xDelta, y + yDelta, z)    
                if ParadiseZ.isHasNote(sq2) then
                    ParadiseZ.showNote(sq2)
                end
            end
        end
    end
end

Events.OnPlayerUpdate.Remove(ParadiseZ.noteHover)
Events.OnPlayerUpdate.Add(ParadiseZ.noteHover)
-----------------------            ---------------------------
ParadiseZ.contextOpen = false
function ParadiseZ.noteContext(plNum, context, worldobjects, test)
    local pl = getSpecificPlayer(plNum)
    local sq = luautils.stringStarts(getCore():getVersion(), "42") and ISWorldObjectContextMenu.fetchVars.clickedSquare or clickedSquare
    if not sq then return end
    local flr = sq:getFloor()
    if not flr then return end
    local isAdm = string.lower(pl:getAccessLevel()) == "admin"
    local note
    local isHasNote = ParadiseZ.isHasNote(sq)

    if isHasNote then
        note = ParadiseZ.getNote(sq)
        
        flr:setHighlighted(true, false)
        local function noteHighlightRemove()
            flr:setHighlighted(false)
            Events.OnKeyPressed.Remove(noteHighlightRemovePress)
            Events.OnMouseDown.Remove(noteHighlightRemove)
        end
        local function noteHighlightRemovePress(key)
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
                    flr:getModData()['FloorNote'] = nil
                    flr:transmitModData()
                    pl:playSoundLocal("MapRemoveMarking")
                end
                getSoundManager():playUISound("UIActivateMainMenuItem")
                context:hideAndChildren()
            end)
            DelOpt.iconTexture = getTexture("media/ui/Paradise/context_noteDel.png")  


            WriteCaption = "Edit Note"

        end
        
        local WriteOpt = context:addOptionOnTop(WriteCaption, worldobjects, function()
            if luautils.walkAdj(pl, sq) then
                ParadiseZ.textModal("Enter value:", function(target, value)
                    if value ~= nil and value ~= "" and value ~= " " then
                        flr:getModData()['FloorNote'] = tostring(value)
                        flr:transmitModData()
                        pl:playSoundLocal("MapAddNote")
                    end
                end)
            end
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        WriteOpt.iconTexture = getTexture("media/ui/Paradise/context_noteWrite.png")    

        if note ~= nil and note ~= "" and note ~= " " then
            local tooltip = ISToolTip:new();
            tooltip:initialise();
            tooltip.description = tostring(note)
            WriteOpt.toolTip = tooltip    
        end
	end
end
Events.OnFillWorldObjectContextMenu.Remove(ParadiseZ.noteContext)
Events.OnFillWorldObjectContextMenu.Add(ParadiseZ.noteContext)
-----------------------            ---------------------------
--[[ 
ParadiseZ.NotePanel = ISCollapsableWindow:derive("ParadiseZ.NotePanel")

function ParadiseZ.NotePanel:new(x, y, w, h, onDone, sq)
    local o = ISCollapsableWindow.new(self, x, y, w, h)
    o.onDone = onDone
    o.r, o.g, o.b = 1, 1, 1
    o.sq = sq
    o.note = ""
    if ParadiseZ.isHasNote(sq) then
        o.note = ParadiseZ.getNote(sq)
        local color = ParadiseZ.getNoteColor(sq)
        o.r = color.r or 1
        o.g = color.g or 1
        o.b = color.b or 1
    end
    return o
end

function ParadiseZ.NotePanel:initialise()
    ISCollapsableWindow.initialise(self)

    self.textEntry = ISTextEntryBox:new(self.note or "", 10, 30, self.width - 20, 25)
    self.textEntry:initialise()
    self.textEntry:addToUIManager()
    self:addChild(self.textEntry)

    self.colorBtn = ISButton:new(10, 65, self.width - 20, 25, "Pick Color", self, ParadiseZ.NotePanel.onPickColor)
    self.colorBtn:initialise()
    self.colorBtn:addToUIManager()
    self:addChild(self.colorBtn)

    self.okBtn = ISButton:new(10, 100, (self.width - 30) / 2, 25, "OK", self, ParadiseZ.NotePanel.onConfirm)
    self.okBtn:initialise()
    self.okBtn:addToUIManager()
    self:addChild(self.okBtn)

    self.cancelBtn = ISButton:new(20 + (self.width - 30) / 2, 100, (self.width - 30) / 2, 25, "Cancel", self, ParadiseZ.NotePanel.onCancel)
    self.cancelBtn:initialise()
    self.cancelBtn:addToUIManager()
    self:addChild(self.cancelBtn)
end

function ParadiseZ.NotePanel:onPickColor()
    local x = getMouseX()
    local y = getMouseY()
    local picker = ISColorPicker:new(x, y)
    picker:initialise()
    picker:addToUIManager()
    picker:setPickedFunc(function(_, color)
        if not color then return end
        self.r, self.g, self.b = color.r, color.g, color.b
    end)
end

function ParadiseZ.NotePanel:onConfirm()
    local sq = self.sq
    if sq then
        local flr = sq:getFloor()
        if flr then
            local val = self.textEntry:getText()
            if val ~= nil and val ~= "" and val ~= " " then
                flr:getModData()['FloorNote'] = tostring(val)
                flr:getModData()['FloorNoteColor'] = {r=self.r, g=self.g, b=self.b}
                flr:transmitModData()
                local pl = getPlayer()
                if pl then
                    pl:playSoundLocal("MapAddNote")
                end
            end
        end
    end

    if self.onDone then
        self.onDone(self.textEntry:getText(), self.r, self.g, self.b)
    end

    self:removeFromUIManager()
end

function ParadiseZ.NotePanel:onCancel()
    self:removeFromUIManager()
end

function ParadiseZ.openNotePanel(onDone, sq)
    if not sq then return end
    local sW = getCore():getScreenWidth()
    local sH = getCore():getScreenHeight()
    local panel = ParadiseZ.NotePanel:new(sW/2 - 110, sH/2 - 70, 220, 140, onDone, sq)
    panel:initialise()
    panel:addToUIManager()
end
 ]]