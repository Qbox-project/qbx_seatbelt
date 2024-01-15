if GetConvar('game_enableFlyThroughWindscreen', 'false') ~= 'true' then
    lib.print.error('game_enableFlyThroughWindscreen is not enabled. Please add `setr game_enableFlyThroughWindscreen true` to your server.cfg for this resource to work.')
end

lib.locale()
local config = require 'config.client'
local seatbeltOn = false
local harnessOn = false
local speedMultiplier = config.useMPH and 2.237 or 3.6
local minSpeeds = {
    unbuckled = config.minSpeedUnbuckled / speedMultiplier,
    buckled = config.minSpeedBuckled / speedMultiplier,
    harness = config.harness.minSpeed  / speedMultiplier
}

-- Functions
local function toggleSeatbelt()
    if harnessOn then return end
    seatbeltOn = not seatbeltOn
    LocalPlayer.state:set('seatbelt', seatbeltOn, true)

    SetFlyThroughWindscreenParams(seatbeltOn and minSpeeds.buckled or minSpeeds.unbuckled, 25.0, 17.0, 0.0)
    TriggerEvent('seatbelt:client:ToggleSeatbelt')
    TriggerServerEvent('InteractSound_SV:PlayOnSource', seatbeltOn and 'carbuckle' or 'carunbuckle', 0.25)
end

local function toggleHarness()
    harnessOn = not harnessOn
    LocalPlayer.state:set('harness', harnessOn, true)
    if harnessOn and not seatbeltOn then
        toggleSeatbelt()
    end

    qbx.playAudio({
        audioName = harnessOn and 'Clothes_On' or 'Clothes_Off',
        audioRef = 'GTAO_Hot_Tub_Sounds'
    })

    if config.harness.disableFlyingThroughWindscreen then
        SetFlyThroughWindscreenParams(harnessOn and minSpeeds.harness or seatbeltOn and minSpeeds.buckled or minSpeeds.unbuckled, 25.0, 17.0, 0.0)
    end
    SetPedConfigFlag(cache.ped, 32, not harnessOn) -- PED_FLAG_CAN_FLY_THRU_WINDSCREEN
end

local function seatbelt()
    while cache.vehicle do
        local sleep = 1000
        if seatbeltOn or harnessOn then
            sleep = 0
            DisableControlAction(0, 75, true)
            DisableControlAction(27, 75, true)
        end
        Wait(sleep)
    end
    seatbeltOn = false
    harnessOn = false
end

-- Export
function HasHarness()
    return harnessOn
end

--- @deprecated Use `state.seatbelt` instead
exports('HasHarness', HasHarness)

-- Main Thread
CreateThread(function()
    SetFlyThroughWindscreenParams(minSpeeds.unbuckled, 25.0, 17.0, 0.0)
end)

lib.onCache('vehicle', function()
    Wait(500)
    seatbelt()
end)

-- Events
RegisterNetEvent('qbx_seatbelt:client:UseHarness', function(ItemData)
    local class = GetVehicleClass(cache.vehicle)
    if not cache.vehicle or class == 8 or class == 13 or class == 14 then
        exports.qbx_core:Notify(locale('notify.notInCar'), 'error')
        return
    end
    if not harnessOn then
        LocalPlayer.state:set('invBusy', true, true)
        if lib.progressCircle({
            duration = 5000,
            label = locale('progress.attachHarness'),
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                combat = true
            }
        }) then
            LocalPlayer.state:set('invBusy', false, true)
            toggleHarness()
            TriggerServerEvent('qbx_seatbelt:server:equip', ItemData.slot)
        end
    else
        LocalPlayer.state:set('invBusy', true, true)
        if lib.progressCircle({
            duration = 5000,
            label = locale('progress.removeHarness'),
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                combat = true
            }
        }) then
            LocalPlayer.state:set('invBusy', false, true)
            toggleHarness()
        end
    end
end)

-- Register Key
RegisterCommand('toggleseatbelt', function()
    if not cache.vehicle or IsPauseMenuActive() then return end
    local class = GetVehicleClass(cache.vehicle)
    if class == 8 or class == 13 or class == 14 then return end
    toggleSeatbelt()
end, false)

RegisterKeyMapping('toggleseatbelt', locale('toggleCommand'), 'keyboard', config.keybind)
