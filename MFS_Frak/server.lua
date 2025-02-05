ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


local onlineTable = {}
local vehicleTable

						
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	MySQL.Async.fetchAll('SELECT fraksperre FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier,
	}, function(result)
		if result[1].fraksperre ~= nil then
			if tonumber(result[1].fraksperre) < os.time() then
				MySQL.Async.execute('UPDATE users SET fraksperre = @fraksperre WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier, ['@fraksperre'] = nil}, function (rowsChanged) end)
			end
		end
	end)
end)


RegisterServerEvent('MFS_Fraktionssystem:setDim')
AddEventHandler('MFS_Fraktionssystem:setDim', function(dim)
  SetPlayerRoutingBucket(source, dim)
end)

ESX.RegisterServerCallback('MFS_Fraktionssystem:getSocityDressing', function(source, cb, frak)
	local xPlayer  = ESX.GetPlayerFromId(source)
	local society = "society_"..frak
	TriggerEvent('esx_datastore:getSharedDataStore', society, function(store)
	  local count    = store.count('dressing')
	  local labels   = {}
	  for i=1, count, 1 do
		local entry = store.get('dressing', i)
		table.insert(labels, entry.label)
	  end
	  cb(labels)
	end)
end)

RegisterServerEvent('MFS_Fraktionssystem:saveOutfit')
AddEventHandler('MFS_Fraktionssystem:saveOutfit', function(token, frak, label, skin)
	local xPlayer = ESX.GetPlayerFromId(source)
	if token then
	local society = "society_"..frak
	TriggerEvent('esx_datastore:getSharedDataStore', society, function(store)
		local dressing = store.get('dressing')

		if dressing == nil then
			dressing = {}
		end

		table.insert(dressing, {
			label = label,
			skin  = skin
		})
		store.set('dressing', dressing)
	end)
end
end)

ESX.RegisterServerCallback('MFS_Fraktionssystem:getPlayerOutfit', function(source, cb, num, frak)
	local xPlayer = ESX.GetPlayerFromId(source)
	local society = "society_"..frak
	TriggerEvent('esx_datastore:getSharedDataStore', society, function(store)
	  local outfit = store.get('dressing', num)
	  cb(outfit.skin)
	end)
end)



RegisterServerEvent('MFS_Fraktionssystem:deleteOutfit')
AddEventHandler('MFS_Fraktionssystem:deleteOutfit', function(token, label, frak)
	local xPlayer = ESX.GetPlayerFromId(source)
	if token then
	local society = "society_"..frak
	TriggerEvent('esx_datastore:getSharedDataStore', society, function(store)
		local dressing = store.get('dressing')

		if dressing == nil then
			dressing = {}
		end

		label = label
		
		table.remove(dressing, label)

		store.set('dressing', dressing)
	end)
end
end)

loadOnlinePlayers = function()
	for job,data in pairs(Config.Gangs) do
		local xPlayers = ESX.GetExtendedPlayers('job',job)
		local count = 0
		for k,v in pairs(xPlayers) do
			local Player = ESX.GetPlayerFromId(v.source)
			if Player ~= nil then
				if Player.job.name == job then
					count = count + 1
				end
			end
		end
		table.insert(onlineTable, {frak = job, online = count, got = false})
	end
end
loadOnlinePlayers()
loadFrakPlayers = function(xPlayer)
	if not xPlayer.job.name == 'unemployed' then
	local xPlayers = ESX.GetExtendedPlayers('job',xPlayer.job.name)
	for k,v in pairs(xPlayers) do
		local count = 0
		local Player = ESX.GetPlayerFromId(v.source)
		if Player ~= nil then
			if xPlayer.job.name == Player.job.name then
				count = count + 1
			end
		end
	end
	for k,v in pairs(onlineTable) do
		if v.frak == xPlayer.job.name then
			v.online = count
		end
	end
end
end


AddEventHandler('esx:playerLoaded',function(playerId, xPlayer)
    local sourcePlayer = playerId
	loadFrakPlayers(xPlayer)
end)





ESX.RegisterServerCallback('MFS_Fraktionssystem:buyWeapon', function(source, cb,  weaponName, zone)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = getPrice( weaponName, zone)

	if price == 0 then
		cb(false)
	else
		if xPlayer.hasWeapon(weaponName) then
			TriggerClientEvent(Config.Notifytrigger, source, "error", 'Fraktion-System', 'Du hast diese Waffe bereits!')
			cb(false)
		else
			if zone == 'WeaponShop' then
				if xPlayer.getMoney() >= price then
					xPlayer.removeMoney(price)
					xPlayer.addWeapon(weaponName, 50)

					cb(true)
				else
					TriggerClientEvent(Config.Notifytrigger, source, "error", 'Fraktion-System', 'Du hast nicht genug Geld!')
					cb(false)
				end
			if zone == 'Weaponshop' then
					if xPlayer.getAccount('black_money').money >= price then
						xPlayer.removeAccountMoney('black_money', price)
						xPlayer.addWeapon(weaponName, 50)

						cb(true)
					else
						TriggerClientEvent(Config.Notifytrigger, source, "error", 'Fraktion-System', 'Du hast nicht genug Geld!')
						cb(false)
					end
				else
					if xPlayer.getMoney() >= price then
						xPlayer.removeMoney(price)
						xPlayer.addWeapon(weaponName, 50)

						cb(true)
					else
						TriggerClientEvent(Config.Notifytrigger, source, "error", 'Fraktion-System', 'Du hast nicht genug Geld!')
						cb(false)
					end
				end
			else
				cb(false)
			end
		end
	end
end)

function getPrice( weaponName, zone)
	
	
		local weapon = nil

		for k,v in pairs(Config.Weapons[zone].WeaponShop) do
			if v.name == weaponName then
				weapon = v
				break
			end
		end

		if weapon then
			return weapon.price
		else
			return 0
		end
end



