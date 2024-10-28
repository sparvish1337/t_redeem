RegisterNetEvent('redeem:giveItem')
AddEventHandler('redeem:giveItem', function(item, amount)
        TriggerServerEvent('ox_inventory:AddItem', item, amount)
end)

function NotificationUser(title, description, type)
    lib.notify({
        title = title,
        description = description,
        type = type
    })
end
RegisterNetEvent("t-redeem:notifyUser")
AddEventHandler("t-redeem:notifyUser", function(title, description, type)
    NotificationUser(title, description, type)
end)