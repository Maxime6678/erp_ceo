isCeo = false
entreprise = nil
vault_id = nil

local ceo_blips = nil
local pos_player = nil

local pos = {
	x = 247.495300,
	y = 222.442963,
	z = 106.286827,
}

local debug = false

AddEventHandler("playerSpawned", function()
	debug = true
    TriggerServerEvent("erp:getCeo")
end)

Citizen.CreateThread(function()
	Citizen.Wait(2500)
	if not debug then
		TriggerServerEvent("erp:getCeo")
	end
end)

RegisterNetEvent('erp:setCeo')
AddEventHandler('erp:setCeo', function(r, e, v)
	isCeo = r
	entreprise = e
	vault_id = v
	removeBlip()
	setBlips()
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		pos_player = GetEntityCoords(GetPlayerPed(-1), false)
	end
end)

function isCeo()
	return isCeo
end

function removeBlip()
	Citizen.CreateThread(function()
		if ceo_blips ~= nil then
			RemoveBlip(ceo_blips)
			ceo_blips = nil
		end
	end)
end

function setBlips()
	Citizen.CreateThread(function()
		Citizen.Wait(100)
		if isCeo then
			ceo_blips = AddBlipForCoord(pos.x, pos.y, pos.z)
			SetBlipSprite(ceo_blips, 134)
			SetBlipAsShortRange(ceo_blips, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Coffre de l'entreprise")
			EndTextCommandSetBlipName(ceo_blips)
		end
	end)
end

RegisterNetEvent("fr:showNotify")
AddEventHandler("fr:showNotify", function(message)
	drawNotification(message)
end)

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

Citizen.CreateThread(function()
	Citizen.Wait(50)
	while true do
		Citizen.Wait(0)
		if isCeo then

			-- Draw marker
			if (Vdist(pos.x, pos.y, pos.z, pos_player.x, pos_player.y, pos_player.z) < 30.0) then
				DrawMarker(1, pos.x, pos.y, pos.z - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 0.6000, 0, 155, 255, 200, 0, 0, 0, 0)
			end

			-- Vault
			if (Vdist(pos.x, pos.y, pos.z, pos_player.x, pos_player.y, pos_player.z) < 2.0) then
				DisplayHelpText("Appuyer sur ~INPUT_CONTEXT~ pour ~g~accéder ~s~au coffre")
				if IsControlJustPressed(1, 38) then
					if not getMenuState() then
						TriggerServerEvent('erp:getVaultById', vault_id)
					else
						CloseCEOMenu()
					end
                end
			else
				CloseCEOMenu()
			end
		end
	end
end)