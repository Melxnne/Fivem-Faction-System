

Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}




local inArmory = false

local GUI = {}
local PlayerData = {}
local HasAlreadyEnteredMarker = {}
local lastStation, lastPart, lastPartNum, lastEntity
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}
local CurrentTask = {}
local model = nil
local playerLoaded = true
local isDead = false
local status = true
GUI.Time = 0
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj)ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	playerLoaded = true
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
	PlayerData.job = job
end)

AddEventHandler('esx:onPlayerSpawn', function()
	isDead = false
end)

AddEventHandler('esx:onPlayerDeath', function()
	isDead = true
end)




function OpenArmoryMenu(station)
	inArmory = true
	local elements = {
		{label = 'Waffen Kaufen', value = 'buy_weapon'}
	}
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory', {
		title = 'Fraktions-Invenar',
		align = "top-right",
		elements = elements 
	}, function(data, menu)
		if data.current.value == 'buy_weapon' then
			OpenShopMenu('frak_weapons', 'WeaponShop')
		end
	end, function(data, menu)
		menu.close()
		inArmory = false
		CurrentAction = 'menu_armory'
		CurrentActionMsg = 'Drücke ~g~E~w~, um die ~g~Waffenkammer~w~ zu öffnen.'
		CurrentActionData = {station = station}
	end)
end


function OpenClotheStore()
	elements = {}
	ESX.UI.Menu.CloseAll()
	table.insert(elements, {label = "Kleidungsladen", value = "kleidungsladen"})
	if PlayerData.job.grade_name == "boss" then
		table.insert(elements, {label = "Neues Outfit Speichern", value = "storenew"})
		table.insert(elements, {label = "Outfit löschen", value = "delete"})
	end
	ESX.TriggerServerCallback("MFS_Fraktionssystem:getSocityDressing", function(dressing)
		for i=1, #dressing, 1 do
			table.insert(elements, {label = dressing[i], value = i})
		end
		

		ESX.UI.Menu.Open("default", GetCurrentResourceName(), "player_dressing", {
			title    = "Outfit Sammlung",
			align    = "top-left",
			elements = elements,
			}, function(data, menu)

			if data.current.value == "storenew" then
				ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "outfit_name", {
					title = "Gebe deinem Outfit einen Namen",
				}, function(data3, menu3)

					menu3.close()

					TriggerEvent("skinchanger:getSkin", function(skin)
						local token = exports.MFS_Frak.saveEvent()
						TriggerServerEvent("MFS_Fraktionssystem:saveOutfit", token, currentFrak, data3.value, skin)
						token = nil
					end)

					TriggerEvent(Config.Notifytrigger, "success", "Frak-Kleidung", "Das Outfit wurde für deine Fraktion: "..currentFrak.." freigegeben!")

				end, function(data3, menu3)
					menu3.close()
				end)
			elseif data.current.value == "delete" then
				ESX.TriggerServerCallback("MFS_Fraktionssystem:getSocityDressing", function(dressing)
					local elements = {}
		
					for i=1, #dressing, 1 do
						table.insert(elements, {label = dressing[i], value = i})
					end
					
					ESX.UI.Menu.Open("default", GetCurrentResourceName(), "supprime_cloth", {
						title    = "Fraktions Kleidungs löschen",
						align    = "top-right",
						elements = elements,
					}, function(data, menu)
					menu.close()
						local token = exports.MFS_Frak.saveEvent()
						TriggerServerEvent("MFS_Fraktionssystem:deleteOutfit", token, data.current.value, currentFrak)
						token = nil
						TriggerEvent(Config.Notifytrigger, "success", "Frak-Kleidung", "Das Outfit wurde erfolgreich gelöscht!")
		
					end, function(data, menu)
						menu.close()
						
						CurrentAction     = "menu_uniforms"
						CurrentActionMsg  = "Drücke ~g~E~g~w~, um das Kleidungsmenu zu öffnen."
						CurrentActionData = {}
					end)
				end, currentFrak)
			else
				TriggerEvent("skinchanger:getSkin", function(skin)

					ESX.TriggerServerCallback("MFS_Fraktionssystem:getPlayerOutfit", function(clothes)
	
						TriggerEvent("skinchanger:loadClothes", skin, clothes)
						TriggerEvent("esx_skin:setLastSkin", skin)
	
						TriggerEvent("skinchanger:getSkin", function(skin)
						TriggerServerEvent("esx_skin:save", skin)
						end)
						
						TriggerEvent(Config.Notifytrigger, "success", "Kleidung-System", "Ihr Outfit wurde erfolgreich geladen!")
						HasLoadCloth = true
					end, data.current.value, currentFrak)
					end)
				end
				if data.current.value == "kleidungsladen" then
					TriggerEvent(Config.Kleidungsladentrigger)
				end

			end, function(data, menu)
			menu.close()
			
			CurrentAction     = "menu_uniforms"
			CurrentActionMsg  = "Drücke ~INPUT_CONTEXT~, um das Kleidungsmenu zu öffnen."
			CurrentActionData = {}
		end)
	end, currentFrak)
end






function DeleteSpawnedVehicles()
	while #spawnedVehicles > 0 do
		local vehicle = spawnedVehicles[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVehicles, 1)
	end
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)
		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
			DisableControlAction(0, Keys['TOP'], true)
			DisableControlAction(0, Keys['DOWN'], true)
			DisableControlAction(0, Keys['LEFT'], true)
			DisableControlAction(0, Keys['RIGHT'], true)
			DisableControlAction(0, 176, true) -- ENTER key
			DisableControlAction(0, Keys['BACKSPACE'], true)
		end
	end
end

AddEventHandler('MFS_Fraktionssystem:hasEnteredMarker', function(station, part, partNum)
	if part == 'Armory' then
		CurrentAction = 'menu_armory'
		CurrentActionMsg = 'Drücke ~g~E~w~, um die ~g~Waffenkammer~w~ zu öffnen.'
		CurrentActionData = {}
	elseif part == 'BuyWeapon' then
		CurrentAction = 'buy_weapon'
		CurrentActionMsg = 'Drücke ~g~E~w~, um das ~g~Fraktionswaffenmenü~w~ zu öffnen.'
		CurrentActionData = {}
	elseif part == 'Vehicles' then
		CurrentAction = 'menu_vehicle_spawner'
		CurrentActionMsg = 'Drücke ~g~E~w~, um auf die ~g~Fraktionsgarage ~w~zuzugreifen.'
		CurrentActionData = {station = station, part = part, partNum = partNum}
		CurrentActionData = {}
	elseif part == 'Flager' then
		CurrentAction = 'tp_to_flager'
		CurrentActionMsg = 'Drücke ~g~E~w~, um in das ~g~Fraktionslager~w~ zu gelangen.'
		CurrentActionData = {}
	elseif part == 'outFlager' then
		CurrentAction = 'tp_out_flager'
		CurrentActionMsg = 'Drücke ~g~E~w~, um das ~g~Fraktionslager~w~ zu verlassen.'
		CurrentActionData = {}
	elseif part == 'uniforms' then
		CurrentAction = 'menu_uniforms'
		CurrentActionMsg = 'Drücke ~g~E~w~, um das ~g~Kleidungsmenu~w~ zu öffnen.'
		CurrentActionData = {}
	end
end)

AddEventHandler('MFS_Fraktionssystem:hasExitedMarker', function(station, part, partNum)
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end
	CurrentAction = nil
end) 



Citizen.CreateThread(function()
	Wait(5000)
	while true do
		Citizen.Wait(0)
		if playerLoaded then
			if PlayerData.job.name == 'unemployed' or PlayerData.job.name == 'police' or PlayerData.job.name == 'sheriff' or PlayerData.job.name == 'fib' or PlayerData.job.name == 'fahrschule' or PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'mechanic' or PlayerData.job.name == 'marshal' or PlayerData.job.name == 'autohaus' or PlayerData.job.name == 'army' then
			
			else
				if PlayerData.job ~= nil and PlayerData.job.name == Config.Gangs[PlayerData.job.name]['jobname'] then
					local playerPed = PlayerPedId()
					local coords = GetEntityCoords(playerPed)
					local isInMarker, hasExited, letSleep = false, false, true
					local currentStation, currentPart, currentPartNum
					for i, k in pairs(Config.Gangs) do
						frak = i
						if i == PlayerData.job.name then
							
								for i = 1, #k.fraktionslager, 1 do
									local distance = #(coords - Config.FraklagerWaffenladen)
										
									if distance < Config.DrawDistance then
										DrawMarker(Config.MarkerType, Config.FraklagerWaffenladen, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.Gangs[PlayerData.job.name]["frakFarbe"]["r"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["g"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["b"], 100, false, true, 2, true, false, false, false)
										letSleep = false
									end
										
									if distance < Config.MarkerSize.x then
										isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Armory', i
									end
							
							end
		
	
		
							for i = 1, #k.vehiclespawner, 1 do
								local formattedcoords = vector3(k.vehiclespawner[i].x, k.vehiclespawner[i].y, k.vehiclespawner[i].z)
								local distance = #(coords - formattedcoords)
								
								if distance < Config.DrawDistance then
									DrawMarker(Config.MarkerType, k.vehiclespawner[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.Gangs[PlayerData.job.name]["frakFarbe"]["r"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["g"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["b"], 100, false, true, 2, true, false, false, false)
									-- local ped = CreatePed(4, GetHashKey("cs_movpremmale"), k.spawner[i], false, true)
									-- FreezeEntityPosition(ped, true)
									-- SetEntityInvincible(ped, true)
									-- SetBlockingOfNonTemporaryEvents(ped, true)
									letSleep = false
									-- spawnednpcgarage = true
								end
				
								if distance < Config.MarkerSize.x then
									isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Vehicles', i
								end
							end

							for i = 1, #k.fraktionslager, 1 do
								local distance = #(coords - k.fraktionslager[i])
	
								if distance < Config.DrawDistance then
									DrawMarker(Config.MarkerType, k.fraktionslager[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.Gangs[PlayerData.job.name]["frakFarbe"]["r"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["g"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["b"], 100, false, true, 2, true, false, false, false)
									letSleep = false
								end
				
								if distance < Config.MarkerSize.x then
									isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Flager', i
								end
							end
							for i = 1, #k.fraktionslager, 1 do
								DrawMarker(Config.MarkerType, Config.TeleportLocationIPL.x, Config.TeleportLocationIPL.y, Config.TeleportLocationIPL.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.Gangs[PlayerData.job.name]["frakFarbe"]["r"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["g"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["b"], 100, false, true, 2, true, false, false, false)
								local distance = #(coords - Config.TeleportLocationIPL)
	
								if distance < Config.DrawDistance then
									DrawMarker(Config.MarkerType, Config.TeleportLocationIPL.x, Config.TeleportLocationIPL.y, Config.TeleportLocationIPL.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.Gangs[PlayerData.job.name]["frakFarbe"]["r"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["g"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["b"], 100, false, true, 2, true, false, false, false)
									letSleep = false
								end
				
								if distance < Config.MarkerSize.x then
									DrawMarker(Config.MarkerType, Config.TeleportLocationIPL.x, Config.TeleportLocationIPL.y, Config.TeleportLocationIPL.z,  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.Gangs[PlayerData.job.name]["frakFarbe"]["r"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["g"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["b"], 100, false, true, 2, true, false, false, false)
									isInMarker, currentStation, currentPart, currentPartNum, currentFLcoords = true, k, 'outFlager', i, k.fraktionslager[i]
								end
							end
							for i = 1, #k.fraktionslager, 1 do
								local distance = #(coords - Config.FraklagerKleidung)
	
								if distance < Config.DrawDistance then
									DrawMarker(Config.MarkerType, Config.FraklagerKleidung, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.Gangs[PlayerData.job.name]["frakFarbe"]["r"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["g"], Config.Gangs[PlayerData.job.name]["frakFarbe"]["b"], 100, false, true, 2, true, false, false, false)
									letSleep = false
								end
				
								if distance < Config.MarkerSize.x then
									isInMarker, currentStation, currentPart, currentPartNum, currentFrak = true, k, 'uniforms', i, frak
								end
							end
						end
					end
		
					if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
						if (LastStation ~= nil and LastPart ~= nil and LastPartNum ~= nil) and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum) then
							TriggerEvent('MFS_Fraktionssystem:hasExitedMarker', LastStation, LastPart, LastPartNum)
							hasExited = true
						end
								
						HasAlreadyEnteredMarker = true
						LastStation = currentStation
						LastPart = currentPart
						LastPartNum = currentPartNum
						TriggerEvent('MFS_Fraktionssystem:hasEnteredMarker', currentStation, currentPart, currentPartNum)
					end
					if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
						HasAlreadyEnteredMarker = false
						TriggerEvent('MFS_Fraktionssystem:hasExitedMarker', LastStation, LastPart, LastPartNum)
					end
					if letSleep then
						Citizen.Wait(500)
					end
				else
					Citizen.Wait(500)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if isInShopMenu then
			DisableControlAction(0, 75, true)-- Disable exit vehicle
			DisableControlAction(27, 75, true)-- Disable exit vehicle
		else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if CurrentAction == 'menu_armory' or inArmory then
		DisableControlAction(0, Keys['F2'], true) 
		else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	Wait(5000)
	while true do
		Citizen.Wait(0)
		if playerLoaded then
			if PlayerData.job.name == 'unemployed' or PlayerData.job.name == 'police' or PlayerData.job.name == 'sheriff' or PlayerData.job.name == 'fib' or PlayerData.job.name == 'fahrschule' or PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'mechanic' or PlayerData.job.name == 'marshal' or PlayerData.job.name == 'autohaus' or PlayerData.job.name == 'army' then
			
			else
				if CurrentAction then
					ESX.ShowHelpNotification(CurrentActionMsg)

					if Config.Gangs[PlayerData.job.name]['jobname'] then
						if IsControlJustReleased(0, Keys['E']) and PlayerData.job ~= nil and PlayerData.job.name == Config.Gangs[PlayerData.job.name]['jobname'] then
							DisableControlAction(0, Keys['F2'], true) 
							local otherPlayers = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 3.0)
							
							if CurrentAction == 'menu_armory' then
								if #otherPlayers > 0 then
									TriggerEvent(Config.Notifytrigger, "error", 'Fraktion-System', 'Jeweils eine Person kann immer nur auf den Waffenschrank zugreifen!')
								else
									OpenShopMenu('frak_weapons', 'WeaponShop') ---Markerfürwaffenladen
								end
							elseif CurrentAction == 'menu_vehicle_spawner' then
								openGarageMenu()
							elseif CurrentAction == 'tp_to_flager' then
								SetEntityCoords(PlayerPedId(), Config.TeleportLocationIPL.x, Config.TeleportLocationIPL.y, Config.TeleportLocationIPL.z)
								TriggerServerEvent("MFS_Fraktionssystem:setDim", 27 + Config.Gangs[PlayerData.job.name]["id"])
							elseif CurrentAction == 'tp_out_flager' then
								SetEntityCoords(PlayerPedId(), currentFLcoords.x, currentFLcoords.y, currentFLcoords.z)
								TriggerServerEvent("MFS_Fraktionssystem:setDim", 100)
							elseif CurrentAction == 'menu_uniforms' then
								OpenClotheStore(currentFrak)
							end
							CurrentAction = nil
						end
					end
				end
			end		

		end
	end
end)

	


function openGarageMenu()
	local elements = {}
	local Vehicles = {}
	local r,g,b = nil, nil, nil

	for fraktion,data in pairs(Config.Gangs) do
		if fraktion == PlayerData.job.name then
			r = Config.Gangs[PlayerData.job.name]["frakFarbe"]["r"]
			g = Config.Gangs[PlayerData.job.name]["frakFarbe"]["g"]
			b = Config.Gangs[PlayerData.job.name]["frakFarbe"]["b"]
			Vehicles = data.vehicles
		end
	end

	for _,vehicle in pairs(Config.Vehicles) do
		local label = vehicle:sub(1,1):upper()..vehicle:sub(2)
		table.insert(elements, {model = vehicle, label = label})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Fraktionsfahrzeuge',
	{
		title =  'Fahrzeuge',
		align = "top-right",
		elements = elements
	}, function(data, menu)
		if data ~= nil and data.current ~= nil and data.current.model ~= nil then
			
			coordsauto = Config.Gangs[PlayerData.job.name]['vehiclespawnpoint']
			headingauto = Config.Gangs[PlayerData.job.name]['vehicleheading']

			ESX.Game.SpawnVehicle(data.current.model, coordsauto, headingauto, function(vehicleauto)
				ESX.UI.Menu.CloseAll()

				SetVehicleCustomPrimaryColour(vehicleauto, r, g, b)
				SetVehicleCustomSecondaryColour(vehicleauto, r, g, b)
				TaskWarpPedIntoVehicle(PlayerPedId(), vehicleauto, -1)

				SetVehicleEngineOn(vehicleauto, true, true)
				
				SetVehicleModKit(vehicleauto, 0)
				SetVehicleMod(vehicleauto, 0, GetNumVehicleMods(vehicleauto, 0) - 1, false)
				SetVehicleMod(vehicleauto, 1, GetNumVehicleMods(vehicleauto, 1) - 1, false)
				SetVehicleMod(vehicleauto, 2, GetNumVehicleMods(vehicleauto, 2) - 1, false)
				SetVehicleMod(vehicleauto, 3, GetNumVehicleMods(vehicleauto, 3) - 1, false)
				SetVehicleMod(vehicleauto, 4, GetNumVehicleMods(vehicleauto, 4) - 1, false)
				SetVehicleMod(vehicleauto, 5, GetNumVehicleMods(vehicleauto, 5) - 1, false)
				SetVehicleMod(vehicleauto, 6, GetNumVehicleMods(vehicleauto, 6) - 1, false)
				SetVehicleMod(vehicleauto, 7, GetNumVehicleMods(vehicleauto, 7) - 1, false)
				SetVehicleMod(vehicleauto, 8, GetNumVehicleMods(vehicleauto, 8) - 1, false)
				SetVehicleMod(vehicleauto, 9, GetNumVehicleMods(vehicleauto, 9) - 1, false)
				SetVehicleMod(vehicleauto, 11, GetNumVehicleMods(vehicleauto, 11) - 1, false)
				SetVehicleMod(vehicleauto, 12, GetNumVehicleMods(vehicleauto, 12) - 1, false)
				SetVehicleMod(vehicleauto, 13, GetNumVehicleMods(vehicleauto, 13) - 1, false)
				SetVehicleMod(vehicleauto, 14, 16, false)
				SetVehicleMod(vehicleauto, 15, GetNumVehicleMods(vehicleauto, 15) - 2, false)
				SetVehicleMod(vehicleauto, 16, GetNumVehicleMods(vehicleauto, 16) - 1, false)
				ToggleVehicleMod(vehicleauto, 17, true)
				ToggleVehicleMod(vehicleauto, 18, true)
				ToggleVehicleMod(vehicleauto, 19, true)
				ToggleVehicleMod(vehicleauto, 20, true)
				ToggleVehicleMod(vehicleauto, 21, true)
				ToggleVehicleMod(vehicleauto, 22, true)
				SetVehicleMod(vehicleauto, 24, 1, false)
				SetVehicleMod(vehicleauto, 25, GetNumVehicleMods(vehicleauto, 25) - 1, false)
				SetVehicleMod(vehicleauto, 27, GetNumVehicleMods(vehicleauto, 27) - 1, false)
				SetVehicleMod(vehicleauto, 28, GetNumVehicleMods(vehicleauto, 28) - 1, false)
				SetVehicleMod(vehicleauto, 30, GetNumVehicleMods(vehicleauto, 30) - 1, false)
				SetVehicleMod(vehicleauto, 33, GetNumVehicleMods(vehicleauto, 33) - 1, false)
				SetVehicleMod(vehicleauto, 34, GetNumVehicleMods(vehicleauto, 34) - 1, false)
				SetVehicleMod(vehicleauto, 35, GetNumVehicleMods(vehicleauto, 35) - 1, false)
				SetVehicleMod(vehicleauto, 38, GetNumVehicleMods(vehicleauto, 38) - 1, true)
				SetVehicleMod(vehicleauto, 45, GetNumVehicleMods(vehicleauto, 45) - 1, true)
				SetVehicleMod(vehicleauto, 43, GetNumVehicleMods(vehicleauto, 43) - 1, true)
				SetVehicleMod(vehicleauto, 40, GetNumVehicleMods(vehicleauto, 40) - 1, true)
				SetVehicleMod(vehicleauto, 41, GetNumVehicleMods(vehicle, 41) - 1, true)
				SetVehicleMod(vehicle, 42, GetNumVehicleMods(vehicle, 42) - 1, true)
				SetVehicleWindowTint(vehicleauto, 1)
				SetVehicleNumberPlateTextIndex(vehicleauto, 5)

				SetVehicleNumberPlateText(vehicleauto, PlayerData.job.name)
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end



local HasAlreadyEnteredMarker, IsInShopMenu = false, false
local CurrentAction, CurrentActionMsg, LastZone
local CurrentActionData = {}


function OpenMainMenu(zone)
	local elements = {}

	if zone == 'WeaponShop' then
		

		
	    table.insert(elements, {label = 'frak_weapons', value = 'frak_weapons'})
	end
	Wait(500)

	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'weapon_cat', {
		title = 'weapon_cat',
		align = "top-right",
		elements = elements
	}, function(data, menu)
		local action = data.current.value

		
		if action == 'frak_weapons' then 
			if Config.Weapons[zone].Legal then
				ESX.TriggerServerCallback('esx_license:checkLicense', function(hasLicense)
					if hasLicense then
						ESX.UI.Menu.CloseAll()
					else
						ESX.ShowNotification('go_to')
					end
				end, GetPlayerServerId(PlayerId()), 'weapon_handgun')
			else
				ESX.UI.Menu.CloseAll()
			end
		end
	end, function(data, menu)
		ESX.UI.Menu.CloseAll()
	end)
end

-- Open Shop Menu
function OpenShopMenu(wvalue, zone)
	local elements = {}
	IsInShopMenu = true

	
	if wvalue == 'frak_weapons' then
		for i=1, #Config.Weapons[zone].WeaponShop, 1 do
			local item = Config.Weapons[zone].WeaponShop[i]
			item.label = ESX.GetWeaponLabel(item.name)

			table.insert(elements, {label = ('%s - <span style="color: green;">%s</span>'):format(item.label, (item.price), "$", ESX.Math.GroupDigits(item.price)), price = item.price, weaponName = item.name})
		end
	end
	Wait(500)


	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
		title = ('Waffenladen'),
		align = "top-right",
		elements = elements
	}, function(data, menu)
		ESX.TriggerServerCallback('MFS_Fraktionssystem:buyWeapon', function(bought)
		end, data.current.weaponName, zone)
	end, function(data, menu)
		IsInShopMenu = false
		menu.close()


		CurrentAction = 'shop_menu'
		CurrentActionData = {zone = zone}
	end, function(data, menu)
	end)
end





AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if IsInShopMenu then
			ESX.UI.Menu.CloseAll()
		end
	end
end)


  -----------------------------------------------------------------------------------------------------------------------
--HUD
-----------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    ReplaceHudColour(116, Config.Gangs[PlayerData.job.name]['frakfarbe']['hudc'])
  end)




