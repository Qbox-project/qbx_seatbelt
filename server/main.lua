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

RegisterNetEvent('qbx_seatbelt:DoHarnessDamage', function(hp, data)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    local harness = exports.ox_inventory:Search(src, 1, 'harness')

    if not player then return end

    if hp == 0 then
        exports.ox_inventory:RemoveItem(src, 'harness', 1, data.metadata, data.slot)
    else
        harness.metadata.harnessuses -= 1
        exports.ox_inventory:SetMetadata(src, harness.slot, harness.metadata)
        TriggerClientEvent("hud:client:UpdateHarness", source, harness.metadata.harnessuses)
    end
end)