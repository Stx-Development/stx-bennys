QBCore = exports['qb-core']:GetCoreObject()

function getJobCount(JOB)
    local count = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
		if v.PlayerData.job.name == JOB and v.PlayerData.job.onduty then
			count = count + 1
		end
    end
    return count
end


lib.callback.register('srp-bennys:server:callback:getjobcount', function(source, JOB) 
    return getJobCount(JOB) 
end)




RegisterNetEvent('srp-bennys:server:removemoney', function(typee)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveMoney('bank', 1000) then
        TriggerClientEvent('srp-bennys:client:passevent:openmenu', src, typee)
    end
end)