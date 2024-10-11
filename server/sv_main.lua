ESX.RegisterServerCallback('rlo_gardening:callback:checkJobStatistics', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = MySQL.single.await('SELECT `experience` FROM `skills_gardening` WHERE `identifier` = ? LIMIT 1', { xPlayer.getIdentifier() })
    
    if not data then 
        MySQL.insert.await('INSERT INTO `skills_gardening` (identifier) VALUES (?)', { xPlayer.getIdentifier() })
        if Config.Debug then print('Successfully registered gardening skill for:', xPlayer.getIdentifier()) end
        cb(nil)
        return
    end

    cb(data.experience)
end)

RegisterNetEvent('rlo_gardening:server:redeemPoints', function(collectedPoints)
    local xPlayer = ESX.GetPlayerFromId(source)
    local recievedExperience = (collectedPoints * Config.ExperiencePerPoint)
    local recievedMoney = (collectedPoints * Config.MoneyPerPoint)

    local result = MySQL.single.await('SELECT experience FROM skills_gardening WHERE identifier = ?', { xPlayer.getIdentifier() })
    if result then
        local currentExperience = result.experience
        local newExperience = currentExperience + recievedExperience

        MySQL.update.await('UPDATE skills_gardening SET experience = ? WHERE identifier = ?', {
            newExperience, xPlayer.getIdentifier()
        })

        xPlayer.addMoney(recievedMoney)
        xPlayer.showNotification('You recieved ~g~'..recievedExperience..' Experience~s~ and ~y~'..recievedMoney..' Dollar~s~ for ~b~'..collectedPoints..' Garden Points~s~!')
    end
end)

