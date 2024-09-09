RegisterNetEvent('redeem:giveItem')
AddEventHandler('redeem:giveItem', function(item, amount)
    if qbx.PlayerData then
        TriggerServerEvent('ox_inventory:AddItem', item, amount) 
        TriggerEvent('chat:addMessage', { args = { '^2SYSTEM', 'You received ' .. amount .. 'x ' .. item } })
    else
        TriggerEvent('chat:addMessage', { args = { '^1SYSTEM', 'Player data not loaded!' } })
    end
end)
