local generatedCodes = {}
local webhookUrl = 'https://discord.com/api/webhooks/your_webhook_url_here' -- Put your webhook here

function sendToDiscord(title, message, color)
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color,
            ["footer"] = {
                ["text"] = "QBox Redeem System",
            },
        }
    }

    PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
end

RegisterCommand('generate', function(source, args, rawCommand)
    local xPlayer = source
    local playerName = GetPlayerName(source)

    if not IsPlayerAdmin(xPlayer) then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'You do not have permission to use this command!' } })
        return
    end

    local item = args[1]
    local amount = tonumber(args[2])
    local uses = tonumber(args[3])
    local customCode = args[4] or tostring(math.random(100000, 999999))

    if not item or not amount or not uses then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Usage: /generate [item] [amount] [uses] [code]' } })
        return
    end

    generatedCodes[customCode] = { item = item, amount = amount, uses = uses, redeemedBy = {} }

    TriggerClientEvent('chat:addMessage', source, { args = { '^2SYSTEM', 'Redeem code generated: ' .. customCode .. ' with ' .. uses .. ' uses.' } })

    sendToDiscord("Code Generated", playerName .. " generated a redeem code: `" .. customCode .. "` for " .. amount .. "x " .. item .. " with " .. uses .. " uses.", 3066993) -- Blue color
end, false)

RegisterCommand('redeem', function(source, args, rawCommand)
    local code = args[1]
    local playerName = GetPlayerName(source)
    local identifiers = GetPlayerIdentifiers(source)
    local playerId = identifiers[1]

    if not code then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Usage: /redeem [code]' } })
        return
    end

    if generatedCodes[code] then
        local item = generatedCodes[code].item
        local amount = generatedCodes[code].amount
        local remainingUses = generatedCodes[code].uses
        local redeemedBy = generatedCodes[code].redeemedBy

        if redeemedBy[playerId] then
            TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'You have already redeemed this code!' } })
            return
        end

        if remainingUses <= 0 then
            TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'This code has already been used the maximum number of times!' } })
            return
        end

        exports.ox_inventory:AddItem(source, item, amount)

        generatedCodes[code].uses = remainingUses - 1

        generatedCodes[code].redeemedBy[playerId] = true

        TriggerClientEvent('chat:addMessage', source, { args = { '^2SYSTEM', 'You have redeemed code ' .. code .. ' and received ' .. amount .. 'x ' .. item } })

        exports.qbx_core:Notify(source, { text = 'Successfully redeemed ' .. amount .. 'x ' .. item, notifyType = 'success', duration = 5000 })

        local cfxId = identifiers[1]
        local discordId = identifiers[2] and identifiers[2]:match("%d+") or 'N/A'
        local steamId = identifiers[3] or 'N/A'

        sendToDiscord("Code Redeemed", playerName .. " redeemed the code: `" .. code .. "` and received " .. amount .. "x " .. item .. "\n\n**Identifiers:**\nCFX Username: " .. cfxId .. "\nDiscord ID: " .. discordId .. "\nSteam ID: " .. steamId, 15844367) -- Green color

        if generatedCodes[code].uses <= 0 then
            generatedCodes[code] = nil
        end
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Invalid or already used code!' } })
    end
end, false)


function IsPlayerAdmin(playerId)
    return IsPlayerAceAllowed(playerId, 'command')
end
