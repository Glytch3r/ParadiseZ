ParadiseZ = ParadiseZ or {}

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


ParadiseZ.contextOpen = false
function ParadiseZ.noteContext(plNum, context, worldobjects, test)
	local pl = getSpecificPlayer(plNum)
	--local targ = clickedPlayer
	local obj = nil

    local sq = luautils.stringStarts(getCore():getVersion(), "42") and ISWorldObjectContextMenu.fetchVars.clickedSquare or clickedSquare
    if not sq then return end
    local flr = sq:getFloor()
    if not flr then return end
    local isAdm = string.lower(pl:getAccessLevel()) == "admin"
    local note = flr:getModData()['FloorNote']

    if note ~= nil then
        local ReadOpt = context:addOptionOnTop("Read Note", worldobjects, function()
            if luautils.walkAdj(pl, sq) then
                pl:Say(tostring(note)) 
                pl:playSoundLocal("MapOpen")
            end
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        ReadOpt.iconTexture = getTexture("media/ui/Paradise/context_noteRead.png")

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
            WriteCaption = "Edit Note"
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



