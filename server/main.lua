exports.qbx_core:CreateUseableItem('harness', function(source, item)
    TriggerClientEvent('seatbelt:client:UseHarness', source, item)
end)

RegisterNetEvent('equip:harness', function(item)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    if not player then return end

    if item.metadata.harnessuses == nil then
        item.metadata.harnessuses = 19
        exports.ox_inventory:SetMetadata(src, item.slot, item.metadata)
    elseif item.metadata.harnessuses == 1 then
        exports.ox_inventory:RemoveItem(src, 'harness', 1)
    else
        item.metadata.harnessuses -= 1
        exports.ox_inventory:SetMetadata(src, item.slot, item.metadata)
    end
end)

RegisterNetEvent('seatbelt:DoHarnessDamage', function(source, hp, data)
    if not source then return end
    local player = exports.qbx_core:GetPlayer(src)

    local harness = exports.ox_inventory:Search(src, 1, 'harness')

    if not player then return end

    if hp == 0 then
        exports.ox_inventory:RemoveItem(source, 'harness', 1, data.metadata, data.slot)
    else
        harness.metadata.harnessuses -= 1
        exports.ox_inventory:SetMetadata(source, harness.slot, harness.metadata)
        TriggerClientEvent("hud:client:UpdateHarness", source, harness.metadata.harnessuses)
    end
end)