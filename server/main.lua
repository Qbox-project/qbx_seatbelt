SetConvarReplicated('game_enableFlyThroughWindscreen', 'true')

exports.qbx_core:CreateUseableItem('harness', function(source, item)
    TriggerClientEvent('qbx_seatbelt:client:UseHarness', source, item)
end)

RegisterNetEvent('qbx_seatbelt:server:equip', function(slotid)
    local item = exports.ox_inventory:GetSlot(source, slotid)
    if not item then return end
    local itemData = item.metadata
    local newDura = (itemData.durability or 100) - 5
    if newDura <= 0 then
        exports.ox_inventory:RemoveItem(source, item.name, 1, itemData, slotid)
    else
        itemData.durability = newDura
        exports.ox_inventory:SetMetadata(source, slotid, itemData)
    end
end)