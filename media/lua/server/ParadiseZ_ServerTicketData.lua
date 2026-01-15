--[[ 
--server/ParadiseZ_ServerTicketData.lua
if isClient() then return end

ParadiseZ = ParadiseZ or {}

function ParadiseZ.getServerDateTime()
    local t = os.date("*t")
    local months = { "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec" }
    return months[t.month] .. " " .. string.format("%02d", t.day) .. " " .. t.year .. " / " .. string.format("%02d:%02d", t.hour, t.min)
end

function ParadiseZ.getTicketMD()
    return ModData.getOrCreate("ParadiseZ_TicketTimestamps")
end

if not ParadiseZ.ticketHandler then
    ParadiseZ.ticketHandler = true

    local _addTicket = addTicket
    function addTicket(author, message, parentID)
        _addTicket(author, message, parentID)

        if parentID == -1 then
            Events.OnTick.Add(function()
                local tickets = getTickets(author)
                if tickets and tickets:size() > 0 then
                    local t = tickets:get(tickets:size() - 1)
                    local md = ParadiseZ.getTicketMD()
                    local id = t:getTicketID()
                    if not md[id] then
                        md[id] = ParadiseZ.getServerDateTime()
                        ModData.transmit("ParadiseZ_TicketTimestamps")
                    end
                end
                Events.OnTick.Remove(this)
            end)
        end
    end
end
 ]]