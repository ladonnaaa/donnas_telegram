local RSGCore = exports['rsg-core']:GetCoreObject()
local isAnimating = false
local isOpen = false
local SpawnedNPCs = {}
local OfficeBlips = {}

function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(10) end
    end
end

function PlaySoundFrontend(soundName)
    SendNUIMessage({ action = "playSound", sound = soundName })
end

function StartWritingAnimation()
    if isAnimating then return end
    isAnimating = true
    local ped = PlayerPedId()
    LoadAnimDict(Config.Animations.WriteBook.dict)
    TaskPlayAnim(ped, Config.Animations.WriteBook.dict, Config.Animations.WriteBook.anim, 8.0, -8.0, -1, 1, 0, true, 0, false, 0, false)
end

function StopAnimations()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    isAnimating = false
end

function OpenTelegramUI(officeId)
    local hour = GetClockHours()
    if hour >= Config.NPCSchedules.BreakStart and hour < Config.NPCSchedules.BreakEnd then
        TriggerEvent('rsg-core:client:Notify', Config.Locales.notify_clerk_break, 'error')
        return
    end
    isOpen = true
    SetNuiFocus(true, true)
    StartWritingAnimation()
    RSGCore.Functions.TriggerCallback('ladonna_telegram:server:GetTelegrams', function(data)
        SendNUIMessage({
            action = "openUI", 
            telegrams = data.telegrams, 
            contacts = data.contacts,
            myCitizenId = data.citizenid,
            currentOffice = officeId, 
            offices = Config.Offices, 
            locales = Config.Locales
        })
    end)
end

function CloseTelegramUI()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeUI" })
    StopAnimations()
end

RegisterNUICallback('close', function(_, cb)
    CloseTelegramUI()
    cb('ok')
end)

RegisterNUICallback('refreshData', function(_, cb)
    RSGCore.Functions.TriggerCallback('ladonna_telegram:server:GetTelegrams', function(data)
        SendNUIMessage({
            action = "updateData",
            telegrams = data.telegrams,
            contacts = data.contacts
        })
        cb('ok')
    end)
end)

RegisterNUICallback('sendTelegramRequest', function(data, cb)
    RSGCore.Functions.TriggerCallback('ladonna_telegram:server:SendTelegramCb', function(success, cost, status)
        cb({ success = success, cost = cost, status = status })
    end, data)
end)

RegisterNUICallback('markRead', function(data, cb)
    TriggerServerEvent('ladonna_telegram:server:MarkRead', data.id)
    cb('ok')
end)

RegisterNUICallback('deleteTelegram', function(data, cb)
    TriggerServerEvent('ladonna_telegram:server:DeleteTelegram', data.id)
    cb('ok')
end)

RegisterNUICallback('addContact', function(data, cb)
    TriggerServerEvent('ladonna_telegram:server:AddContact', data.name, data.targetId)
    cb('ok')
end)

RegisterNUICallback('deleteContact', function(data, cb)
    TriggerServerEvent('ladonna_telegram:server:DeleteContact', data.id)
    cb('ok')
end)

RegisterNUICallback('playSound', function(data, cb)
    PlaySoundFrontend(data.sound)
    cb('ok')
end)

RegisterNUICallback('clientNotify', function(data, cb)
    TriggerEvent('rsg-core:client:Notify', data.message, data.type)
    cb('ok')
end)

RegisterNUICallback('npcAction', function(data, cb)
    if data.officeId and SpawnedNPCs[data.officeId] then
        local npc = SpawnedNPCs[data.officeId]
        if data.action == "stamp" then
            LoadAnimDict(Config.Animations.ClerkStamp.dict)
            TaskPlayAnim(npc, Config.Animations.ClerkStamp.dict, Config.Animations.ClerkStamp.anim, 8.0, -8.0, 3000, 1, 0, true, 0, false, 0, false)
        end
    end
    cb('ok')
end)

RegisterNetEvent('ladonna_telegram:client:NotifyDelivery', function()
    PlaySoundFrontend(Config.Sounds.Bell)
    TriggerEvent('rsg-core:client:Notify', Config.Locales.notify_received, 'success')
end)

RegisterNetEvent('rsg-core:client:OnPlayerLoaded', function()
    Wait(2000)
    for id, office in pairs(Config.Offices) do
        if office.active then
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, office.coords.x, office.coords.y, office.coords.z)
            SetBlipSprite(blip, joaat('blip_ambient_post_office'), true)
            SetBlipScale(blip, 0.2)
            local label = CreateVarString(10, "LITERAL_STRING", office.name)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, label)
            table.insert(OfficeBlips, blip)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for id, ped in pairs(SpawnedNPCs) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    for i = 1, #OfficeBlips do
        if Citizen.InvokeNative(0x9A3FF3DE163034E8, OfficeBlips[i]) then
            Citizen.InvokeNative(0x38719E09C2C47EA1, OfficeBlips[i])
        end
    end
end)

CreateThread(function()
    while true do
        Wait(5000) 
        local hour = GetClockHours()
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        for id, office in pairs(Config.Offices) do
            local officeCoords = vector3(office.coords.x, office.coords.y, office.coords.z)
            local dist = #(pos - officeCoords)
            if dist < 50.0 and office.active then
                local shouldBeWorking = (hour >= Config.NPCSchedules.WorkStart and hour < Config.NPCSchedules.WorkEnd)
                if shouldBeWorking and not SpawnedNPCs[id] then
                    SpawnOfficeNPC(id, office)
                elseif not shouldBeWorking and SpawnedNPCs[id] then
                    DespawnOfficeNPC(id)
                end
                if SpawnedNPCs[id] then
                    if hour >= Config.NPCSchedules.BreakStart and hour < Config.NPCSchedules.BreakEnd then
                        SetEntityInvincible(SpawnedNPCs[id], true)
                        FreezeEntityPosition(SpawnedNPCs[id], false)
                    else
                        HandleNPCIdleAnimations(SpawnedNPCs[id])
                    end
                end
            else
                if SpawnedNPCs[id] then DespawnOfficeNPC(id) end
            end
        end
    end
end)

function SpawnOfficeNPC(id, office)
    local hash = office.npcModel
    if not IsModelValid(hash) then return end
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 50 do Wait(100) timeout = timeout + 1 end
    
    local heading = office.coords.w
    local npc = CreatePed(hash, office.coords.x, office.coords.y, office.coords.z, heading, false, false, 0, 0)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true) 
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SpawnedNPCs[id] = npc
    SetModelAsNoLongerNeeded(hash)
    
    exports.ox_target:addLocalEntity(npc, {
        { 
            name = 'open_telegram_'..id, 
            icon = 'fas fa-book-open', 
            label = Config.Locales.target_telegram, 
            onSelect = function() OpenTelegramUI(id) end, 
            distance = office.zoneRadius or 2.0 
        }
    })
end

function DespawnOfficeNPC(id)
    if SpawnedNPCs[id] then
        DeleteEntity(SpawnedNPCs[id])
        SpawnedNPCs[id] = nil
    end
end

function HandleNPCIdleAnimations(npc)
    if not IsEntityPlayingAnim(npc, Config.Animations.ClerkIdle.dict, Config.Animations.ClerkIdle.anim, 3) then
        LoadAnimDict(Config.Animations.ClerkIdle.dict)
        TaskPlayAnim(npc, Config.Animations.ClerkIdle.dict, Config.Animations.ClerkIdle.anim, 8.0, -8.0, -1, 1, 0, true, 0, false, 0, false)
    end
    if math.random(1, 100) > 96 then
        TaskPlayAnim(npc, Config.Animations.ClerkStamp.dict, Config.Animations.ClerkStamp.anim, 8.0, -8.0, 3000, 1, 0, true, 0, false, 0, false)
        PlaySoundFrontend(Config.Sounds.Stamp)
    end
end