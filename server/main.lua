exports.qbx_core:CreateUseableItem('harness', function(source, item)
    if not source then return end
    TriggerClientEvent('seatbelt:client:UseHarness', source, item)
end)

RegisterNetEvent('equip:harness', function(source, item)
    local player = exports.qbx_core:GetPlayer(source)

    if not source or not player then return end

    if item.metadata.harnessuses == nil then
        item.metadata.harnessuses = 19
        exports.ox_inventory:SetMetadata(source, item.slot, item.metadata)
    elseif item.metadata.harnessuses == 1 then
        exports.ox_inventory:RemoveItem(source, 'harness', 1)
    else
        item.metadata.harnessuses -= 1
        exports.ox_inventory:SetMetadata(source, item.slot, item.metadata)
    end
end)

RegisterNetEvent('seatbelt:DoHarnessDamage', function(source, hp, data)
    if not source then return end
    local player = exports.qbx_core:GetPlayer(source)

    local harness = exports.ox_inventory:Search(source, 1, 'harness')

    if not player then return end

    if hp == 0 then
        exports.ox_inventory:RemoveItem(source, 'harness', 1, data.metadata, data.slot)
    else
        harness.metadata.harnessuses -= 1
        exports.ox_inventory:SetMetadata(source, harness.slot, harness.metadata)
        TriggerClientEvent("hud:client:UpdateHarness", source, harness.metadata.harnessuses)
    end
end)