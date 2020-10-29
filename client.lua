local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
emP = Tunnel.getInterface("emp_motorista")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local emservico = false
local CoordenadaX = 453.48
local CoordenadaY = -607.74
local CoordenadaZ = 28.57
local timers = 0
local payment = 0
local nveh = nil

local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(ped)

-----------------------------------------------------------------------------------------------------------------------------------------
-- BLIPS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	local blips = AddBlipForCoord(418.59, -639.90, 28.50)
	SetBlipSprite(blips,513)
	SetBlipColour(blips,4) 
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,true)
	SetBlipRoute(blips,false)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Trabalho de Motorista")
	EndTextCommandSetBlipName(blips)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GERANDO LOCAL DE ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------
local entregas = {
	[1] = { 308.59,-766.42,28.66 },
	[2] = { 206.21,-1219.73,28.53 },
	[3] = { -107.80,-1688.88,28.63 },
	[4] = { -386.51,-1722.46,19.12 },
	[5] = { -267.24,-1284.43,30.27 },
	[6] = { -214.79,-999.27,28.63 },
	[7] = { -148.47,-819.45,30.74 },
	[8] = { -71.16,-606.53,35.60 },
	[9] = { 257.66,-376.19,43.95 },
	[10] = { 599.09,-79.97,70.64 },
	[11] = { 939.96,-274.40,66.46 },
	[12] = { 961.43,-478.69,60.95 },
	[13] = { 1100.74,-762.23,57.11 },
	[14] = { 1265.63,-562.07,68.35 },
	[15] = { 948.82,-144.06,73.86 },
	[16] = { 550.47,80.98,95.29 },
	[17] = { 499.14,271.05,102.39 },
	[18] = { 36.11,279.60,108.91 },
	[19] = { -457.15,255.10,82.36 },
	[20] = { -1064.98,274.64,63.23 },
	[21] = { -1548.01,-155.19,54.32 },
	[22] = { -1985.29,-479.98,11.02 },
	[23] = { -1386.62,-828.71,18.42 },
	[24] = { -1210.53,-1218.54,7.05 },
	[25] = { -1169.93, -1468.75, 4.28 },
	[26] = { -1072.00,-1607.17,3.74 },
	[27] = { -1041.33,-1528.59,4.45 },
	[28] = { -960.84,-1241.13,4.70 },
	[29] = { -630.27,-976.03,20.69 },
	[30] = { -508.64, -667.24, 33.06 },
	[31] = { 143.16,-819.09,30.48 },
	[32] = { 408.65,-704.50,28.62 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRABALHAR
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if not emservico then
			local ped = PlayerPedId()
			if not IsPedInAnyVehicle(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				local distance = Vdist(x,y,z,CoordenadaX,CoordenadaY,CoordenadaZ)

				if distance <= 30.0 then
					DrawMarker(23,CoordenadaX,CoordenadaY,CoordenadaZ-0.97,0,0,0,0,0,0,1.0,1.0,0.5,251,141,100,90,0,0,0,0)
					if distance <= 1.2 then
						drawTxt("PRESSIONE  ~b~E~w~  PARA INICIAR ROTA",4,0.5,0.93,0.50,255,255,255,180)
						if IsControlJustPressed(1,38) then
							emservico = true
							destino = 1
							payment = 10
							ColocarRoupa()
							spawnBus()
							CriandoBlip(entregas,destino)
							TriggerEvent("Notify","warning","Voce <b>entrou</b> em serviço, entre no onibus e siga a rota!")
						end
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GERANDO ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if emservico then
			local ped = PlayerPedId()
			if IsPedInAnyVehicle(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				local vehicle = GetVehiclePedIsUsing(ped)
				local distance = Vdist(x,y,z,entregas[destino][1],entregas[destino][2],entregas[destino][3])
				if distance <= 100.0 and (IsVehicleModel(vehicle,GetHashKey("coach")) or IsVehicleModel(vehicle,GetHashKey("bus")) or IsVehicleModel(vehicle,GetHashKey("airbus"))) then
					DrawMarker(3,entregas[destino][1],entregas[destino][2],entregas[destino][3]+0.60,0,0,0,0,100.0,100.0,2.0,2.0,0.7,251,141,100,90,1,0,0,1)
					if distance <= 7.1 then
						drawTxt("PRESSIONE  ~b~ENTER~w~ PARA CONTINUAR A ROTA",4,0.5,0.93,0.50,255,255,255,180)
						if IsControlJustPressed(1,18) then
							SetVehicleIndicatorLights(vehicle, 1, true)
							SetVehicleIndicatorLights(vehicle, 0, true)
							SetVehicleDoorOpen(vehicle, 0, false, false)
							SetVehicleDoorOpen(vehicle, 1, false, false)
							SetVehicleDoorOpen(vehicle, 2, false, false)
							SetVehicleDoorOpen(vehicle, 3, false, false)
							FreezeEntityPosition(vehicle,true)
							RemoveBlip(blip)
							if destino == 32 then
								emP.checkPayment(payment,350)
								destino = 1
								payment = 10
								
								Citizen.Wait(10000)
								SetVehicleIndicatorLights(vehicle, 1, false)
								SetVehicleIndicatorLights(vehicle, 0, false)
								SetVehicleDoorShut(vehicle, 0, false)
								SetVehicleDoorShut(vehicle, 1, false)
								SetVehicleDoorShut(vehicle, 2, false)
								SetVehicleDoorShut(vehicle, 3, false)
								FreezeEntityPosition(vehicle,false)
							else
								Citizen.Wait(10000)
								SetVehicleIndicatorLights(vehicle, 1, false)
								SetVehicleIndicatorLights(vehicle, 0, false)
								SetVehicleDoorShut(vehicle, 0, false)
								SetVehicleDoorShut(vehicle, 1, false)
								SetVehicleDoorShut(vehicle, 2, false)
								SetVehicleDoorShut(vehicle, 3, false)
								FreezeEntityPosition(vehicle,false)
								emP.checkPayment(payment,0)
								destino = destino + 1
							end
							CriandoBlip(entregas,destino)
						end
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMERS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		if emservico then
			if timers > 0 then
				timers = timers - 5
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELANDO ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if emservico then
			if IsControlJustPressed(1,168) then
				emservico = false
				MainRoupa()
				RemoveBlip(blip)
				if nveh then
					DeleteVehicle(nveh)
					nveh = nil
				end
				TriggerEvent("Notify","warning","Voce <b>saiu</b> de serviço!")
			end
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUPAS
-----------------------------------------------------------------------------------------------------------------------------------------

local RoupaMotorista = {
    ["Motorista"] = {
		[1885233650] = {
			[1] = { -1,0 }, -- máscara
			[3] = { 0,0 }, -- maos
			[4] = { 10,0 }, -- calça
			[5] = { -1,0 }, -- mochila
			[6] = { 21,0 }, -- sapato
			[7] = { -1,0 }, -- acessorios		
			[8] = { 15,0 }, -- blusa
			[9] = { -1,0 }, -- colete
			[10] = { -1,0 }, -- adesivo
			[11] = { 242,1 }, -- jaqueta		
			["p0"] = { -1,0 }, -- chapeu
			["p1"] = { 7,0 }, -- oculos
			["p2"] = { -1,0 },
			["p6"] = { -1,0 },
			["p7"] = { -1,0 }
		},
		[-1667301416] = {
			[1] = { -1,0 }, -- máscara
			[3] = { 14,0 }, -- maos
			[4] = { 37,0 }, -- calça
			[5] = { -1,0 }, -- mochila
			[6] = { 27,0 }, -- sapato
			[7] = { -1,0 },  -- acessorios		
			[8] = { 6,0 }, -- blusa
			[9] = { -1,0 }, -- colete
			[10] = { -1,0 }, -- adesivo
			[11] = { 250,1 }, -- jaqueta
			["p0"] = { -1,0 }, -- chapeu
			["p1"] = { -1,0 }, -- oculos
			["p2"] = { -1,0 },
			["p6"] = { -1,0 },
			["p7"] = { -1,0 }
		}
    }
}

function FadeRoupa(time,tipo,idle_copy)
	DoScreenFadeOut(800)
	Wait(time)
	if tipo == 1 then 
		vRP.setCustomization(idle_copy)
	else
		TriggerServerEvent("emp_motorista:roupa")
	end
	DoScreenFadeIn(800)
end

function ColocarRoupa()
	if vRP.getHealth() > 101 then
		if not vRP.isHandcuffed() then
			local custom = RoupaMotorista["Motorista"]
			if custom then
				local old_custom = vRP.getCustomization()
				local idle_copy = {}

				idle_copy = emP.SaveIdleCustom(old_custom)
				idle_copy.modelhash = nil

				for l,w in pairs(custom[old_custom.modelhash]) do
						idle_copy[l] = w
				end
				FadeRoupa(1200,1,idle_copy)
			end
		end
	end
end

function MainRoupa()
	if vRP.getHealth() > 101 then
		if not vRP.isHandcuffed() then
	        FadeRoupa(1200,2)
	    end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWN BUS
-----------------------------------------------------------------------------------------------------------------------------------------

function spawnBus()
	local mhash = "bus"
	if not nveh then
		while not HasModelLoaded(mhash) do
	    RequestModel(mhash)
	    Citizen.Wait(10)
	end
		local ped = PlayerPedId()
		local x,y,z = vRP.getPosition()
		nveh = CreateVehicle(mhash,462.74, -605.06, 28.49, 212.45+0.5,313.70,true,false)
		SetVehicleIsStolen(nveh,false)
		SetVehicleOnGroundProperly(nveh)
		SetEntityInvincible(nveh,false)
		SetVehicleNumberPlateText(nveh,vRP.getRegistrationNumber())
		Citizen.InvokeNative(0xAD738C3085FE7E11,nveh,true,true)
		SetVehicleHasBeenOwnedByPlayer(nveh,true)
		SetVehicleDirtLevel(nveh,0.0)
		SetVehRadioStation(nveh,"OFF")
		SetVehicleEngineOn(GetVehiclePedIsIn(ped,false),true)
		SetModelAsNoLongerNeeded(mhash)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCOES
-----------------------------------------------------------------------------------------------------------------------------------------
function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function CriandoBlip(entregas,destino)
	blip = AddBlipForCoord(entregas[destino][1],entregas[destino][2],entregas[destino][3])
	SetBlipSprite(blip,280)
	SetBlipColour(blip,9)
	SetBlipScale(blip,0.6)
	SetBlipAsShortRange(blip,false)
	SetBlipRoute(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Rota de Motorista")
	EndTextCommandSetBlipName(blip)
end