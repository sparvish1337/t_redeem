local webhookUrl = 'https://discord.com/api/webhooks/your_webhook_url_here' -- Put your webhook here

-- SQL interaction function (use ghmattimysql or mysql-async depending on your setup)
local function executeSQL(query, params, cb)
    exports.ghmattimysql:execute(query, params, cb)
end

-- Function to send messages to Discord
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

-- Command to generate a redeem code
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

    -- Insert the generated code into the database
    executeSQL('INSERT INTO redeem_codes (code, item, amount, uses, created_by) VALUES (@code, @item, @amount, @uses, @created_by)', {
        ['@code'] = customCode,
        ['@item'] = item,
        ['@amount'] = amount,
        ['@uses'] = uses,
        ['@created_by'] = playerName
    }, function()
        TriggerClientEvent('chat:addMessage', source, { args = { '^2SYSTEM', 'Redeem code generated: ' .. customCode .. ' with ' .. uses .. ' uses.' } })
        sendToDiscord("Code Generated", playerName .. " generated a redeem code: `" .. customCode .. "` for " .. amount .. "x " .. item .. " with " .. uses .. " uses.", 3066993) -- Blue color
    end)
end, false)

-- Command to redeem a code
RegisterCommand('redeem', function(source, args, rawCommand)
    local code = args[1]
    local playerName = GetPlayerName(source)
    local identifiers = GetPlayerIdentifiers(source)
    local playerId = identifiers[1]

    if not code then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Usage: /redeem [code]' } })
        return
    end

    -- Check if the code exists in the database
    executeSQL('SELECT * FROM redeem_codes WHERE code = @code', {
        ['@code'] = code
    }, function(result)
        if result[1] then
            local redeemData = result[1]
            local item = redeemData.item
            local amount = redeemData.amount
            local remainingUses = redeemData.uses
            local redeemedBy = json.decode(redeemData.redeemed_by)

            if redeemedBy[playerId] then
                TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'You have already redeemed this code!' } })
                return
            end

            if remainingUses <= 0 then
                TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'This code has already been used the maximum number of times!' } })
                return
            end

            -- Give the player the item
            exports.ox_inventory:AddItem(source, item, amount)

            -- Update the code in the database
            redeemedBy[playerId] = true
            executeSQL('UPDATE redeem_codes SET uses = @uses, redeemed_by = @redeemed_by WHERE code = @code', {
                ['@uses'] = remainingUses - 1,
                ['@redeemed_by'] = json.encode(redeemedBy),
                ['@code'] = code
            })

            -- Notify the player
            TriggerClientEvent('chat:addMessage', source, { args = { '^2SYSTEM', 'You have redeemed code ' .. code .. ' and received ' .. amount .. 'x ' .. item } })
            exports.qbx_core:Notify(source, { text = 'Successfully redeemed ' .. amount .. 'x ' .. item, notifyType = 'success', duration = 5000 })

            -- Send a message to Discord
            local cfxId = identifiers[1]
            local discordId = identifiers[2] and identifiers[2]:match("%d+") or 'N/A'
            local steamId = identifiers[3] or 'N/A'

            sendToDiscord("Code Redeemed", playerName .. " redeemed the code: `" .. code .. "` and received " .. amount .. "x " .. item .. "\n\n**Identifiers:**\nCFX Username: " .. cfxId .. "\nDiscord ID: " .. discordId .. "\nSteam ID: " .. steamId, 15844367) -- Green color
        else
            TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Invalid or already used code!' } })
        end
    end)
end, false)

-- Admin check
function IsPlayerAdmin(playerId)
    return IsPlayerAceAllowed(playerId, 'command')
end
