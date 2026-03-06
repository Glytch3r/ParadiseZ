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
    if not pl or not obj then return end
    if not TheRange.isStaff(pl) then return end

    local user = pl:getUsername()
    if not user then return end

    amt = tonumber(amt)
    if not amt or amt <= 0 then return end

    local earnings = tonumber(TheRange.getEarnings(obj)) or 0
    if earnings <= 0 then return end
    if amt > earnings then amt = earnings end

    local arg = {
        targetUsername = user,
        currency = "cash_primary",
        amount = math.floor(amt),
        accountCurrency = "primary",
        reason = "paycheck",
    }

    if sendClientCommand then
        sendClientCommand("btse_economy", "sendPayment", arg)
    elseif PARP then
        PARP:sendClientCommand("btse_economy", "sendPayment", arg)
    end

    local md = obj:getModData()
    md['TheRangeEarnings'] = earnings - amt
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
function TheRange.onPtsPicked(target, button, value, card, obj)
    if button.internal ~= "OK" then return end
    if not value or value <= 0 then return end
    if not card or not obj then return end

    local pl = getPlayer()
    if not pl then return end
    local user = pl:getUsername()
    if not user then return end

    local currentPts = TheRange.getPoints(card)
    if currentPts < value then return end

    local price = tonumber(SandboxVars.ParadiseZ.TheRangeCreditPrice) or 1
    local percent = tonumber(SandboxVars.ParadiseZ.TheRangeExchangePercent) or 0
    
    percent = math.max(0, math.min(1, percent))

    local gross = value * price
    local tax = gross * percent
    local payout = gross - tax

    payout = math.floor(payout)
    tax = math.floor(tax)

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

    local md = obj:getModData()
    md['TheRangeEarnings'] = tonumber(md['TheRangeEarnings']) or 0
    md['TheRangeEarnings'] = md['TheRangeEarnings'] + tax
    obj:transmitModData()
end
function TheRange.pointsExchangePrompt(pl, obj)
    pl = pl or getPlayer()
    if not pl then return end
    if not obj then return end

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
        card,
        obj
    )

    modal:initialise()
    modal:instantiate()
    modal:addToUIManager()
end