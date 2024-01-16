if GetConvar('game_enableFlyThroughWindscreen', 'false') ~= 'true' then
    lib.print.error('game_enableFlyThroughWindscreen is not enabled. Please add `setr game_enableFlyThroughWindscreen true` to your server.cfg for this resource to work.')
end

lib.locale()
local config = require 'config.client'
local seatbeltOn = false
local harnessOn = false
local speedMultiplier = config.useMPH and 2.237 or 3.6
local minSpeeds = {
    unbuckled = config.minSpeedUnbuckled * speedMultiplier,
    buckled = config.minSpeedBuckled * speedMultiplier,
    harness = config.harness.minSpeed * speedMultiplier
}

local function playBuckleSound(buckleState)
    qbx.loadAudioBank('audiodirectory/seatbelt_sounds')
    qbx.playAudio({
        audioName = buckleState and 'carbuckle' or 'carunbuckle',
        audioRef = 'seatbelt_soundset',
        source = cache.ped
    })
    ReleaseNamedScriptAudioBank('audiodirectory/seatbelt_sounds')
end

-- Functions
local function toggleSeatbelt()
    if harnessOn then return end
    seatbeltOn = not seatbeltOn
    LocalPlayer.state:set('seatbelt', seatbeltOn)

    SetFlyThroughWindscreenParams(seatbeltOn and minSpeeds.buckled or minSpeeds.unbuckled, 25.0, 17.0, 0.0)
    TriggerEvent('seatbelt:client:ToggleSeatbelt')
    playBuckleSound(seatbeltOn)
end

local function toggleHarness()
    harnessOn = not harnessOn
    LocalPlayer.state:set('harness', harnessOn)
    LocalPlayer.state:set('seatbelt', harnessOn) -- syncs the seatbelt icon with the harness status

    playBuckleSound(harnessOn)

    if config.harness.disableFlyingThroughWindscreen then
        if harnessOn then
            SetPedConfigFlag(cache.ped, 32, false) -- PED_FLAG_CAN_FLY_THRU_WINDSCREEN
        else
            SetPedConfigFlag(cache.ped, 32, true) -- PED_FLAG_CAN_FLY_THRU_WINDSCREEN
        end
    else
        if harnessOn then
            SetFlyThroughWindscreenParams(minSpeeds.harness, 25.0, 17.0, 0.0)
        else
            SetFlyThroughWindscreenParams(seatbeltOn and minSpeeds.buckled or minSpeeds.unbuckled, 25.0, 17.0, 0.0)
        end
    end
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
    LocalPlayer.state:set('seatbelt', seatbeltOn)
    LocalPlayer.state:set('harness', harnessOn)
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
    if seatbeltOn then return end
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
lib.addKeybind({
    name = 'toggleseatbelt',
    description = locale('toggleCommand'),
    defaultKey = config.keybind,
    onPressed = function()
        if not cache.vehicle or IsPauseMenuActive() then return end
        local class = GetVehicleClass(cache.vehicle)
        if class == 8 or class == 13 or class == 14 then return end
        toggleSeatbelt()
    end
})
