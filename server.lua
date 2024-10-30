local webhookUrl = 'https://discord.com/api/webhooks/your_webhook_url_here' -- Put your webhook here

local function executeSQL(query, params, cb)
    exports.ghmattimysql:execute(query, params, cb)
end

function sendToDiscord(title, message, color)
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color,
            ["footer"] = {
                ["text"] = "Redeem System",
            },
        }
    }

    PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
end

RegisterCommand('generate', function(source, args, rawCommand)
    local xPlayer = source
    local playerName = GetPlayerName(source)

    if not IsPlayerAdmin(xPlayer) then
            TriggerClientEvent("t-redeem:notifyUser", source, "Whoops!", "You do not have permission to use this command!", "error")
        return
    end

    local items = args[1]
    local uses = tonumber(args[2])
    local expiryDays = tonumber(args[3])
    local customCode = args[4] or tostring(math.random(100000, 999999))

    local expiryDate = os.date("%Y-%m-%d %H:%M:%S", os.time() + (expiryDays * 86400))

    executeSQL('INSERT INTO redeem_codes (code, items, uses, created_by, expiry) VALUES (@code, @items, @uses, @created_by, @expiry)', {
        ['@code'] = customCode,
        ['@items'] = items,
        ['@uses'] = uses,
        ['@created_by'] = playerName,
        ['@expiry'] = expiryDate
    }, function()
        TriggerClientEvent("t-redeem:notifyUser", source, "Generated", "generated a redeem code", "info")
        sendToDiscord("Code Generated", playerName .. " generated a redeem code: `" .. customCode .. "` with " .. uses .. " uses and expiry in " .. expiryDays .. " days.", 3066993)
    end)
end, false)

RegisterCommand('redeem', function(source, args, rawCommand)
    local code = args[1]
    local playerName = GetPlayerName(source)
    local identifiers = GetPlayerIdentifiers(source)
    local playerId = identifiers[1]

    executeSQL('SELECT * FROM redeem_codes WHERE code = @code AND (expiry IS NULL OR expiry > NOW())', {
        ['@code'] = code
    }, function(result)
        if result[1] then
            local redeemData = result[1]
            local items = json.decode(redeemData.items)
            local remainingUses = redeemData.uses
            local redeemedBy = json.decode(redeemData.redeemed_by) or {}

            if redeemedBy[playerId] then
                TriggerClientEvent("t-redeem:notifyUser", source, "Sorry!", "You have already redeemed this code!", "error")
                return
            end

            if remainingUses <= 0 then
                TriggerClientEvent("t-redeem:notifyUser", source, "Sorry!", "This code has already been used the maximum number of times!", "error")
                return
            end

            for _, itemData in ipairs(items) do
                local item = itemData.item
                local amount = itemData.amount
                exports.ox_inventory:AddItem(source, item, amount)
                TriggerClientEvent("t-redeem:notifyUser", source, "Redeemed", "Code Redeemed", "success")
            end

            redeemedBy[playerId] = true
            executeSQL('UPDATE redeem_codes SET uses = @uses, redeemed_by = @redeemed_by WHERE code = @code', {
                ['@uses'] = remainingUses - 1,
                ['@redeemed_by'] = json.encode(redeemedBy),
                ['@code'] = code
            })

            local cfxId = identifiers[1]
            local discordId = identifiers[2] and identifiers[2]:match("%d+") or 'N/A'
            local steamId = identifiers[3] or 'N/A'

            sendToDiscord("Code Redeemed", playerName .. " redeemed the code: `" .. code .. "` and received reward.\n\n**Identifiers:**\nCFX License: " .. cfxId .. "\nDiscord ID: " .. discordId .. "\nSteam ID: " .. steamId, 15844367)
        else
            TriggerClientEvent("t-redeem:notifyUser", source, "Whoops!", "Invalid or expired code!", "error")
        end
    end)
end, false)

function IsPlayerAdmin(playerId)
    return IsPlayerAceAllowed(playerId, 'command')
end