require "resources/mysql-async/lib/MySQL"

local ArrayName = {
	["taxi"] = "LSTCC",
	["lspd"] = "LSPD",
	["depanneur"] = "RSGM",
}

local ArrayId = {
	["taxi"] = 3,
	["lspd"] = {5, 8, 9, 10, 11, 12, 13},
	["depanneur"] = 7,
}

RegisterServerEvent("erp:getCeo")
AddEventHandler("erp:getCeo", function()
	local user_id = getPlayerID(source)
	MySQL.Async.fetchAll("SELECT * FROM ceo WHERE identifier = @user_id", {['@user_id'] = user_id}, function(result)
		if result[1] ~= nil then
			TriggerClientEvent("erp:setCeo", source, true, result[1].entreprise, result[1].vault)
		else
			TriggerClientEvent("erp:setCeo", source, false, nil, nil)
		end
	end)
end)

RegisterServerEvent("erp:getVaultById")
AddEventHandler("erp:getVaultById", function(id)
	MySQL.Async.fetchAll("SELECT * FROM vault WHERE id = @id", {["@id"] = id}, function(result)
		if result[1] ~= nil then
			TriggerClientEvent("erp:showVault", source, ArrayName[result[1].entreprise], result[1].amount)
		end
	end)
end)

RegisterServerEvent("erp:depositToVault")
AddEventHandler("erp:depositToVault", function(id, amount)
	TriggerEvent('es:getPlayerFromId', source, function(user)
		local rounded = round(tonumber(amount), 0)
		if(tonumber(rounded) <= tonumber(user:money)) then
			user:removeMoney((rounded))
			MySQL.Sync.execute("UPDATE vault SET amount = amount + @amount WHERE id = @id", {['@amount'] = rounded, ['@id'] = id})
			if id ~= 2 then
				TriggerClientEvent('fr:showNotify', source, "Vous avez deposé ~g~"..rounded.."$ ~s~dans le compte de l'entreprise")
			else
				TriggerClientEvent('fr:showNotify', source, "Vous avez deposé ~g~"..rounded.."$ ~s~dans le compte de l'administration")
			end
		else
			TriggerClientEvent('fr:showNotify', source, "Vous n'avez pas assez d'argent sur vous")
		end
	end)
end)

RegisterServerEvent("erp:withdrawToVault")
AddEventHandler("erp:withdrawToVault", function(id, amount)
	TriggerEvent('es:getPlayerFromId', source, function(user)
		local rounded = round(tonumber(amount), 0)
		local balance = MySQL.Sync.fetchScalar("SELECT amount FROM vault WHERE id = @id",{['@id'] = id})
		if(tonumber(rounded) <= tonumber(balance) and tonumber(balance) > 0) then
			MySQL.Sync.execute("UPDATE vault SET amount = amount - @amount WHERE id = @id", {['@amount'] = rounded, ['@id'] = id})
			user:addMoney((rounded))
			if id ~= 2 then
				TriggerClientEvent('fr:showNotify', source, "Vous avez retiré ~g~"..rounded.."$ ~s~du compte de l'entreprise")
			else
				TriggerClientEvent('fr:showNotify', source, "Vous avez retiré ~g~"..rounded.."$ ~s~du compte de l'administration")
			end
		else
			TriggerClientEvent('fr:showNotify', source, "Vous n'avez pas assez d'argent dans le compte de l'entreprise")
		end
	end)
end)

RegisterServerEvent("erp:addToVault")
AddEventHandler("erp:addToVault", function(id, amount)
	local rounded = round(tonumber(amount), 0)
	MySQL.Sync.execute("UPDATE vault SET amount = amount + @amount WHERE id = @id", {['@amount'] = rounded, ['@id'] = id})
end)

RegisterServerEvent("erp:getEmployer")
AddEventHandler("erp:getEmployer", function(job)
	if job ~= "lspd" then
		MySQL.Async.fetchAll("SELECT Nom as player_name, isOnline as player_online FROM users WHERE job = @job", {["@job"] = ArrayId[job]}, function(result)
			local players = {}
			for _,v in ipairs(result) do
				local i = {name = v.player_name, description = ""}
				table.insert(players, i)
			end
		end)
	else
		request = "SELECT Nom as player_name, isOnline as player_online FROM users WHERE job = "
		local i = false
		for _,v in pairs(ArrayId[job]) do
			if not i then
				request = request..""..v.." "
				i = true
			else
				request = request.."OR job = "..v.." "
			end
		end
	end
	local result = MySQL.Sync.fetchAll(request, {})
	TriggerClientEvent('erp:setEmployer', source, result)
end)

function getPlayerID(source)
    local identifiers = GetPlayerIdentifiers(source)
    local player = getIdentifiant(identifiers)
    return player
end

function getIdentifiant(id)
    for _, v in ipairs(id) do
        return v
    end
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.abs(math.floor(num * mult + 0.5) / mult)
end