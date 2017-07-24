local ceo = {
	opened = false,
	title = "Coffre entreprise",
	currentmenu = "main",
	lastmenu = nil,
	currentpos = nil,
	currentmoney = nil,
	currententreprise = nil,
	selectedbutton = 0,
	marker = { r = 0, g = 155, b = 255, a = 200, type = 1 },
	menu = {
		x = 0.11,
		y = 0.25,
		width = 0.2,
		height = 0.04,
		buttons = 10,
		from = 1,
		to = 10,
		scale = 0.4,
		font = 0,
		["main"] = {
			title = "CATEGORIES",
			name = "main",
			buttons = {
				{name = "Chargement ...", description = ''},
			}
		},
		["interaction"] = {
			title = "INTERACTION",
			name = "interaction",
			buttons = {
				{name = "Déposer de l'argent", description = ''},
				{name = "Retirer de l'argent", description = ''},
			}
		}
	}
}
-------------------------------------------------
----------------CONFIG SELECTION----------------
-------------------------------------------------
function ButtonSelected(button)
	local ped = GetPlayerPed(-1)
	local this = ceo.currentmenu
	local btn = button.name
	if this == "main" then
		if button.amount ~= nil then
			OpenMenu('interaction')
		end
	elseif this == "interaction" then
		if btn == "Déposer de l'argent" then
			local amount = OpenTextInput()
			if amount ~= nil then
				TriggerServerEvent("erp:depositToVault", vault_id, amount)
				Citizen.Wait(30)
				TriggerServerEvent('erp:getVaultById', vault_id)
			end
		elseif btn == "Retirer de l'argent" then
			local amount = OpenTextInput()
			if amount ~= nil then
				TriggerServerEvent("erp:withdrawToVault", vault_id, amount)
				Citizen.Wait(30)
				TriggerServerEvent('erp:getVaultById', vault_id)
			end
		end
	end
end

function getMenuState()
	return ceo.opened
end

RegisterNetEvent("erp:showVault")
AddEventHandler("erp:showVault", function(name, amount)
	addButtonToMenu(name, amount)
	if name == "LSPD" then
		ceo.title = "Coffre administration"
	end
	OpenCEOMenu()
end)

function addButtonToMenu(name, amount)
	ceo.menu['main'].buttons = {}
	local t = {name = name, description = ""}
	local y = {name = "------------------------------------------", description = ""}
	local u = {name = comma_value(amount).." $", description = "", amount = tonumber(amount)}
	table.insert(ceo.menu['main'].buttons, t)
	table.insert(ceo.menu['main'].buttons, y)
	table.insert(ceo.menu['main'].buttons, u)
	ceo.currententreprise = name
	ceo.currentmoney = amount
end

function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function OpenTextInput()
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 64)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        return result
    end
end

-------------------------------------------------
----------------CONFIG OPEN MENU-----------------
-------------------------------------------------
function OpenMenu(menu)
	ceo.lastmenu = ceo.currentmenu
	ceo.menu.from = 1
	ceo.menu.to = 10
	ceo.selectedbutton = 0
	ceo.currentmenu = menu
end
-------------------------------------------------
------------------DRAW NOTIFY--------------------
-------------------------------------------------
function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end
--------------------------------------
-------------DISPLAY HELP TEXT--------
--------------------------------------
function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
-------------------------------------------------
------------------DRAW TITLE MENU----------------
-------------------------------------------------
function drawMenuTitle(txt,x,y)
local menu = ceo.menu
	SetTextFont(2)
	SetTextProportional(0)
	SetTextScale(0.5, 0.5)
	SetTextColour(255, 255, 255, 255)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	DrawRect(x,y,menu.width,menu.height,41,128,185,200)
	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)
end
-------------------------------------------------
------------------DRAW MENU BOUTON---------------
-------------------------------------------------
function drawMenuButton(button,x,y,selected)
	local menu = ceo.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(menu.scale, menu.scale)
	if selected then
		SetTextColour(0, 0, 0, 255)
	else
		SetTextColour(255, 255, 255, 255)
	end
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(button.name)
	if selected then
		DrawRect(x,y,menu.width,menu.height,255,255,255,255)
	else
		DrawRect(x,y,menu.width,menu.height,0,0,0,200)
	end
	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)
end
-------------------------------------------------
------------------DRAW MENU INFO-----------------
-------------------------------------------------
function drawMenuInfo(text)
	local menu = ceo.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(0.45, 0.45)
	SetTextColour(255, 255, 255, 255)
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawRect(0.675, 0.95,0.65,0.050,0,0,0,200)
	DrawText(0.365, 0.934)
end
-------------------------------------------------
----------------DRAW MENU DROIT------------------
-------------------------------------------------
function drawMenuRight(txt,x,y,selected)
	local menu = ceo.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(menu.scale, menu.scale)
	--SetTextRightJustify(1)
	if selected then
		SetTextColour(0, 0, 0, 255)
	else
		SetTextColour(255, 255, 255, 255)
	end
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	DrawText(x + menu.width/2 - 0.03, y - menu.height/2 + 0.0028)
end
-------------------------------------------------
-------------------DRAW TEXT---------------------
-------------------------------------------------
function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end
-------------------------------------------------
---------------------FUNCTIONS--------------------
-------------------------------------------------
function f(n)
return n + 0.0001
end

function LocalPed()
return GetPlayerPed(-1)
end

function try(f, catch_f)
local status, exception = pcall(f)
if not status then
catch_f(exception)
end
end
function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function stringstarts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end
-------------------------------------------------
----------------FONCTION OPEN-------------------
-------------------------------------------------
function OpenCEOMenu()
	ceo.currentmenu = "main"
	ceo.opened = true
	ceo.selectedbutton = 0
end
-------------------------------------------------
----------------CONFIG BACK MENU-----------------
-------------------------------------------------
function BackMenu()
	if backlock then
		return
	end
	backlock = true
	if ceo.currentmenu == "main" then
		CloseMenu()
	else
		OpenMenu(ceo.lastmenu)
	end
end
-------------------------------------------------
----------------FONCTION CLOSE-------------------
-------------------------------------------------
function CloseCEOMenu()
	ceo.opened = false
	ceo.menu.from = 1
	ceo.menu.to = 10
end
-------------------------------------------------
----------------FONCTION OPEN MENU---------------
-------------------------------------------------
local backlock = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(1,166) and ceo.opened == false then
				OpenMenu()
		elseif IsControlJustPressed(1,166) and ceo.opened == true then
				CloseMenu()
		end
		if ceo.opened then
			local ped = LocalPed()
			local menu = ceo.menu[ceo.currentmenu]
			drawTxt(ceo.title,1,1,ceo.menu.x,ceo.menu.y,1.0, 255,255,255,255)
			drawMenuTitle(menu.title, ceo.menu.x,ceo.menu.y + 0.08)
			drawTxt(ceo.selectedbutton.."/"..tablelength(menu.buttons),0,0,ceo.menu.x + ceo.menu.width/2 - 0.0385,ceo.menu.y + 0.067,0.4, 255,255,255,255)
			local y = ceo.menu.y + 0.12
			buttoncount = tablelength(menu.buttons)
			local selected = false

			for i,button in pairs(menu.buttons) do
				if i >= ceo.menu.from and i <= ceo.menu.to then

					if i == ceo.selectedbutton then
						selected = true
					else
						selected = false
					end
					drawMenuButton(button,ceo.menu.x,y,selected)
					if button.distance ~= nil then
						drawMenuRight(button.distance.."m",ceo.menu.x,y,selected)
					end
					y = y + 0.04
					if selected and IsControlJustPressed(1,201) then
						ButtonSelected(button)
					end
				end
			end
		end
		if ceo.opened then
			if IsControlJustPressed(1,202) then
				BackMenu()
			end
			if IsControlJustReleased(1,202) then
				backlock = false
			end
			if IsControlJustPressed(1,188) then
				if ceo.selectedbutton > 1 then
					ceo.selectedbutton = ceo.selectedbutton -1
					if buttoncount > 10 and ceo.selectedbutton < ceo.menu.from then
						ceo.menu.from = ceo.menu.from -1
						ceo.menu.to = ceo.menu.to - 1
					end
				end
			end
			if IsControlJustPressed(1,187)then
				if ceo.selectedbutton < buttoncount then
					ceo.selectedbutton = ceo.selectedbutton +1
					if buttoncount > 10 and ceo.selectedbutton > ceo.menu.to then
						ceo.menu.to = ceo.menu.to + 1
						ceo.menu.from = ceo.menu.from + 1
					end
				end
			end
		end

	end
end)
