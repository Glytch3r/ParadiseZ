
ParadiseZ = ParadiseZ or {}

function ParadiseZ.addMapSymbol(x, y, tex)
    if not ISWorldMap_instance then
        ISWorldMap.ShowWorldMap(0)
        ISWorldMap_instance:close()
    end
    local sq = getCell():getOrCreateGridSquare(x, y, 0)
    local isConquered = DrawMapSymbol.isConquered(sq)
	local mapAPI = ISWorldMap_instance.javaObject:getAPIv1()
	local symAPI = mapAPI:getSymbolsAPI()
	local sym = symAPI:addTexture(tex, x, y)
    sym:setAnchor(0.5, 0.5)
    sym:setRGBA(1,1,0.8,1)
end
--[[ 
function ParadiseZ.addMapNote(x, y, text)
    if not ISWorldMap_instance then
        ISWorldMap.ShowWorldMap(0)
        ISWorldMap_instance:close()
    end

    local mapAPI = ISWorldMap_instance.javaObject:getAPIv1()
    local noteAPI = mapAPI:getAnnotationsAPI()
    local note = noteAPI:addText(x, y, text)

    note:setFont(UIFont.Small)
    note:setRGBA(1, 1, 0.8, 1)
end
 ]]
--[[ 

function ParadiseZ.addMapNote(x, y, text)
    if not ISWorldMap_instance then
        ISWorldMap.ShowWorldMap(0)
        ISWorldMap_instance:close()
    end

    local mapAPI = ISWorldMap_instance.javaObject:getAPIv1()
    local noteAPI = mapAPI:getAnnotationsAPI()
    local note = noteAPI:addText(x, y, text)

    note:setFont(UIFont.Small)
    note:setRGBA(1, 1, 0.8, 1)
end

local pl = getPlayer()
local x, y = pl:getX(), pl:getY()
ParadiseZ.addMapNote(x, y, "PARADISE")

 ]]