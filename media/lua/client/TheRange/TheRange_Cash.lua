--client/TheRange_Cash.lua

TheRange = TheRange or {}
ParadiseZ = ParadiseZ or {}
function TheRange.getEarnings(obj)
    local pl = getPlayer() 
    if not pl then return end
    if not obj then return end
    if not TheRange.isStaff(pl) then return end
    local md = obj:getModData()
    if md['TheRangeEarnings'] == nil then 
        md['TheRangeEarnings'] = 0  
        obj:transmitModData()
    end
    return md['TheRangeEarnings']
end

function TheRange.withdraw(amt, obj)
    
    local pl = getPlayer() 
    local user = pl:getUsername() 
    if not pl then return end
    if not user then return end
    if not obj then return end
    if not TheRange.isStaff(pl) then return end
    if not amt then return end
    local earnings = TheRange.getEarnings(obj)
    
    
    local arg = {
        targetUsername = user,
        currency="cash_primary",
        amount = amt,
        accountCurrency = "primary",
        reason = "paycheck",
    }
    
    if sendClientCommand then  
        sendClientCommand("btse_economy", "sendPayment", arg)
    elseif PARP then
        PARP:sendClientCommand("btse_economy", "sendPayment", arg)
    end
    local newBalance = earnings-amt
    local md = obj:getModData()
    md['TheRangeEarnings'] = newBalance
    obj:transmitModData()
    
end

function TheRange.onQuantityPicked(target, button, value, obj)
    if button.internal ~= "OK" then return end
    if not value or value <= 0 then return end
    if not obj then return end
    TheRange.withdraw(value, obj)
end

function TheRange.withdrawPrompt(pl, obj)
    pl = pl or getPlayer()
    if not pl then return end
    if not obj then return end

    local earnings = TheRange.getEarnings(obj)
    if not earnings or earnings <= 0 then return end

    local modal = ISQuantityModal:new(
        0,
        0,
        300,
        150,
        "Withdraw Amount",
        earnings,
        TheRange,
        TheRange.onQuantityPicked,
        pl:getPlayerNum(),
        0,
        obj
    )

    modal:initialise()
    modal:instantiate()
    modal:addToUIManager()
end
-----------------------            ---------------------------
function TheRange.onPtsPicked(target, button, value, card)
    if button.internal ~= "OK" then return end
    if not value or value <= 0 then return end
    if not card then return end

    local pl = getPlayer()
    if not pl then return end
    local user = pl:getUsername()
    if not user then return end

    local currentPts = TheRange.getPoints(card)
    if currentPts < value then return end

    local price = SandboxVars.ParadiseZ.TheRangeCreditPrice
    price = tonumber(price) or 1

    local payout = value * price

    TheRange.reducePoints(card, value)

    local arg = {
        targetUsername = user,
        currency = "cash_primary",
        amount = payout,
        accountCurrency = "primary",
        reason = "points_exchange",
    }

    if sendClientCommand then
        sendClientCommand("btse_economy", "sendPayment", arg)
    elseif PARP then
        PARP:sendClientCommand("btse_economy", "sendPayment", arg)
    end
end

function TheRange.pointsExchangePrompt(pl)
    pl = pl or getPlayer()
    if not pl then return end

    local card = TheRange.getMembershipCard(pl)
    if not card then return end

    local pts = TheRange.getPoints(card)
    if not pts or pts <= 0 then return end

    local modal = ISQuantityModal:new(
        0,
        0,
        300,
        150,
        "Points Exchange",
        pts,
        TheRange,
        TheRange.onPtsPicked,
        pl:getPlayerNum(),
        0,
        card
    )

    modal:initialise()
    modal:instantiate()
    modal:addToUIManager()
end