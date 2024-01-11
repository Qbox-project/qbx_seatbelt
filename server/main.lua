exports.qbx_core:CreateUseableItem('harness', function(source, item)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    TriggerClientEvent('seatbelt:client:UseHarness', source, item)
end)

RegisterNetEvent('equip:harness', function(source, item)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    if item.metadata.harnessuses == nil then
        item.metadata.harnessuses = 19
    elseif item.metadata.harnessuses == 1 then
        exports.ox_inventory:RemoveItem(source, 'harness', 1)
        return
    end

    item.metadata.harnessuses -= 1
    exports.ox_inventory:SetMetadata(source, item.slot, item.metadata)
end)

RegisterNetEvent('seatbelt:DoHarnessDamage', function(source, hp, data)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local harness = exports.ox_inventory:Search(source, 1, 'harness')

    if hp == 0 then
        exports.ox_inventory:RemoveItem(source, 'harness', 1, data.metadata, data.slot)
        return
    end

    harness.metadata.harnessuses -= 1
    exports.ox_inventory:SetMetadata(source, harness.slot, harness.metadata)
    TriggerClientEvent("hud:client:UpdateHarness", source, harness.metadata.harnessuses)
end)
