local generatedCodes = {}

RegisterCommand('generate', function(source, args, rawCommand)

    local xPlayer = source
    if not IsPlayerAdmin(xPlayer) then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'You do not have permission to use this command!' } })
        return
    end

    local item = args[1]
    local amount = tonumber(args[2])

    if not item or not amount then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Usage: /generate [item] [amount]' } })
        return
    end

    local code = tostring(math.random(100000, 999999))
    generatedCodes[code] = { item = item, amount = amount }

    TriggerClientEvent('chat:addMessage', source, { args = { '^2SYSTEM', 'Redeem code generated: ' .. code } })
end, false)

RegisterCommand('redeem', function(source, args, rawCommand)
    local code = args[1]
    if not code then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Usage: /redeem [code]' } })
        return
    end

    if generatedCodes[code] then
        local item = generatedCodes[code].item
        local amount = generatedCodes[code].amount

        exports.ox_inventory:AddItem(source, item, amount)

        generatedCodes[code] = nil

        TriggerClientEvent('chat:addMessage', source, { args = { '^2SYSTEM', 'You have redeemed code ' .. code .. ' and received ' .. amount .. 'x ' .. item } })
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Invalid or already used code!' } })
    end
end, false)

function IsPlayerAdmin(playerId)
    return IsPlayerAceAllowed(playerId, 'command')
end
