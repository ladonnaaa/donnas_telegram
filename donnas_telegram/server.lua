local RSGCore = exports['rsg-core']:GetCoreObject()
local SpamCheck = {}

function GetPlayerCitizenId(src)
    local Player = RSGCore.Functions.GetPlayer(src)
    if Player then return Player.PlayerData.citizenid end
    return nil
end

function GetPlayerNameEx(src)
    local Player = RSGCore.Functions.GetPlayer(src)
    if Player then return Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname end
    return "Unknown"
end

function ChargePlayer(src, amount)
    local Player = RSGCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveMoney('cash', amount, "telegram-sent") then return true end
    return false
end

RSGCore.Functions.CreateCallback('ladonna_telegram:server:GetTelegrams', function(source, cb)
    local src = source
    local citizenid = GetPlayerCitizenId(src)
    
    MySQL.query('SELECT * FROM telegrams WHERE receiver_citizenid = ? OR sender_citizenid = ? ORDER BY sent_time DESC', {citizenid, citizenid}, function(telegrams)
        MySQL.query('SELECT * FROM telegram_contacts WHERE citizenid = ?', {citizenid}, function(contacts)
            cb({ telegrams = telegrams or {}, contacts = contacts or {}, citizenid = citizenid })
        end)
    end)
end)

RSGCore.Functions.CreateCallback('ladonna_telegram:server:SendTelegramCb', function(source, cb, data)
    local src = source
    local citizenid = GetPlayerCitizenId(src)
    local senderName = GetPlayerNameEx(src)

    local currentTime = os.time()
    if SpamCheck[citizenid] and (currentTime - SpamCheck[citizenid]) < 15 then
        cb(false, 0, "spam")
        return
    end
    
    MySQL.query('SELECT citizenid FROM players WHERE citizenid = ?', {data.receiver_citizenid}, function(result)
        if not result or #result == 0 then
            cb(false, 0, "not_found")
            return
        end
        
        local cost = Config.Economy.BaseCost
        
        if ChargePlayer(src, cost) then
            SpamCheck[citizenid] = currentTime
            local dbDeliveryTime = os.date('%Y-%m-%d %H:%M:%S', os.time())
            
            MySQL.insert('INSERT INTO telegrams (sender_citizenid, sender_name, receiver_citizenid, message, priority, status, delivery_time, office_origin, office_destination) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', 
            {
                citizenid, 
                senderName, 
                data.receiver_citizenid, 
                data.message,
                0, 
                "Delivered", 
                dbDeliveryTime, 
                data.origin or "Unknown", 
                "Global"
            }, function(id)
                local target = RSGCore.Functions.GetPlayerByCitizenId(data.receiver_citizenid)
                if target then
                    TriggerClientEvent('ladonna_telegram:client:NotifyDelivery', target.PlayerData.source)
                end
                cb(true, cost, "success")
            end)
        else
            cb(false, cost, "funds")
        end
    end)
end)

RegisterNetEvent('ladonna_telegram:server:MarkRead', function(id)
    MySQL.update('UPDATE telegrams SET is_read = 1 WHERE id = ?', {id})
end)

RegisterNetEvent('ladonna_telegram:server:DeleteTelegram', function(id)
    MySQL.query('DELETE FROM telegrams WHERE id = ?', {id})
end)

RegisterNetEvent('ladonna_telegram:server:AddContact', function(name, targetId)
    local src = source
    local citizenid = GetPlayerCitizenId(src)
    MySQL.insert('INSERT INTO telegram_contacts (citizenid, contact_name, contact_citizenid) VALUES (?, ?, ?)', {citizenid, name, targetId})
end)

RegisterNetEvent('ladonna_telegram:server:DeleteContact', function(id)
    MySQL.query('DELETE FROM telegram_contacts WHERE id = ?', {id})
end)