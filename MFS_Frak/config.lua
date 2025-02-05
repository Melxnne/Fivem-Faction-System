Config = {}

Config.MarkerType = 1
Config.MarkerSize = { x = 1.0, y = 1.0, z = 1.0 }
Config.DrawDistance  = 100.0
Config.TeleportLocationIPL = vector3(1027.1135, -3101.5007, -39.9)
Config.FraklagerWaffenladen = vector3(1024.5909, -3109.7876, -39.9)
Config.FraklagerKleidung = vector3(1024.5532, -3094.2725, -39.9)

Config.Kleidungsladentrigger = 'esx_skin:openSaveableRestrictedMenu'
Config.Notifytrigger = 'notifications'

Config.Vehicles = {'jugular', 'schafter3', 'drafter', 'revolter', 'sultan3', 'bf400', 'elegy', 'elegy2', 'sultan2', 'primo2', 'dominator'}
Config.Weapons = {
	WeaponShop = {
		
		WeaponShop = {
			{ name = 'WEAPON_PISTOL', price = 100000},
            { name = 'WEAPON_REVOLVER', price = 1000000},
			{ name = 'WEAPON_BULLPUPRIFLE', price = 8000000},
			{ name = 'WEAPON_BULLPUPRIFLE_MK2', price = 30000000}
		},
	}
}

Config.Plates = {
    ['mg13'] = 'MG13',
    ['Bloods'] = 'Bloods',
}

Config.Gangs = {
    ["mg13"] = {
        id = 1,
        jobname = "mg13",
        societyname = "society_mg13",
        frakFarbe = { r = 1, g = 1, b = 255, hudc = 15 },
        vehiclespawner = { vector3(1159.24,-1643.75,36.96), },
        fraktionslager = { vector3(1166.6693, -1641.5338, 36.9535), },
        vehiclespawnpoint = vector3(1158.6438, -1664.0691, 36.1855), 
        vehicleheading = 209.6240, 
			     
    },
    ["Bloods"] = {
        id = 2,
        jobname = "bloods",
        societyname = "society_bloods",
        frakFarbe = { r = 255, g = 1, b = 1, hudc = 208 },
        fraktionslager = { vector3(519.38,-1734.2,29.79), },
        vehiclespawner = { vector3(512.7083, -1751.1969, 27.7923),},
        vehiclespawnpoint = vector3(510.9159, -1759.2206, 28.1018), 
        vehicleheading = 91.2139, 
    },

    --[[["Sample"] = {
        id = 3,
        jobname = "sample",
        societyname = "society_sample",
        frakFarbe = { r = 1, g = 1, b = 255, hudc = 208 },
        fraktionslager = { vector3(519.38,-1734.2,30.69), },
        vehiclespawner = { vector3(1159.24,-1643.75,36.96), },
        vehiclespawnpoint = vector3(1158.6438, -1664.0691, 36.1855), 
        vehicleheading = 209.6240, 
			     
    },]]--
	
}




















