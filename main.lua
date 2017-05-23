--------------------------------------------------------------------------------
--
--								VARIABLES
--
--------------------------------------------------------------------------------
enable_phone = true
showPhone = false
inCall = false
inputBlocked = false
currentApp = "menu"


--------------------------------------------------------------------------------
--
--									Threads
--
--------------------------------------------------------------------------------
Citizen.CreateThread(function()
	local blip1 = AddBlipForCoord(-7.100, -0.300, 73.077)
	SetBlipSprite(blip1, 442)
	SetBlipDisplay(blip1, 3)
	SetBlipColour(blip1, 26)
	SetBlipScale(blip1, 1.0)
	while true do
		Wait(500)
		SetBlipFade(blip1, 100, 255)
		Wait(500)
		SetBlipFade(blip1, 255, 100)
	end
end)

Citizen.CreateThread(function() -- Clock Thread
	while true do
		Citizen.Wait(100)
		updateDate()
	end
end)

Citizen.CreateThread(function()
	while true do Citizen.Wait(100)
		if GetCurrentPedWeapon(GetPlayerPed(-1)) then
			ePhoneHide()
		end
	end
end)

Citizen.CreateThread(function()
	NetworkOverrideClockTime(8,  8,  8)
	while true do Citizen.Wait(1)
		if IsPlayerPlayingAnimation() and showPhone then
			ePhoneHide()
			SetPedCanRagdoll(GetPlayerPed(-1), false)
		else
			SetPedCanRagdoll(GetPlayerPed(-1), true)
		end

		if IsPlayerDead(PlayerId()) then
			ePhoneHide()
		end
		if showPhone then
			SetPedCanPlayGestureAnims(GetPlayerPed(-1), false)
			SetPedCanPlayVisemeAnims(GetPlayerPed(-1), false)
		else
			SetPedCanPlayGestureAnims(GetPlayerPed(-1), true)
		end
		if IsPedInAnyVehicle(GetPlayerPed(-1), false) and not IsPedOnAnyBike(GetPlayerPed(-1)) then
			TriggerEvent("ephone:battery_in_charge")
		else
			TriggerEvent("ephone:battery_not_in_charge")
		end
		if enable_phone then
			if IsControlJustPressed(3, 27) then
				ePhoneShow()
			elseif IsControlJustPressed(0, 322) then
				ePhoneHide()
			end
			if not inputBlocked then
				if IsControlJustPressed(3, 172) then
					ePhoneUp()
				elseif IsControlJustPressed(3, 173) then
					ePhoneDown()
				elseif IsControlJustPressed(3, 174) then
					ePhoneLeft()
				elseif IsControlJustPressed(3, 175) then
					ePhoneRight()
				elseif IsControlJustPressed(3, 176) then
					ePhoneSelect()
				elseif IsControlJustPressed(3, 177) then
					ePhoneCancel()
				elseif IsControlJustPressed(3, 178) then
					ePhoneOption()
				elseif IsControlJustPressed(3, 179) then
					ePhoneExtraOption()
				end
			end
		end
	end
end)


--------------------------------------------------------------------------------
--
--									CALLBACKS
--
--------------------------------------------------------------------------------
RegisterNUICallback("playSound", function(data, cb)
	PlaySoundFrontend(-1, data.name, data.set,  true)
end)

RegisterNUICallback("phoneClose", function(data, cb)
	ePhoneHide()
end)

RegisterNUICallback("app-contacts", function(data, cb)
	SendNUIMessage({
		showApp = "contacts"
	})
	--inCall = true
	--ePhoneCallAnim()
end)

RegisterNUICallback("message", function(data, cb)
	TriggerEvent('chatMessage', '', {0,0,0}, data.message)
end)



--------------------------------------------------------------------------------
--
--								FUNCTIONS
--
--------------------------------------------------------------------------------
function IsPlayerPlayingAnimation()
	if IsPlayerClimbing(PlayerId()) or IsPlayerDead(PlayerId()) or
	IsPedCuffed(GetPlayerPed(-1)) or IsPedJumpingOutOfVehicle(GetPlayerPed(-1))
	or IsPedTryingToEnterALockedVehicle(GetPlayerPed(-1)) or
	GetCurrentPedWeapon(GetPlayerPed(-1)) then
		return true
	else
		return false
	end
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function updateDate()
	SendNUIMessage({
		date = {
			hours = GetClockHours(),
			minutes = GetClockMinutes()
		}
	})
end

function ePhoneShow()
	if not showPhone then
		SetCurrentPedWeapon(GetPlayerPed(-1), 0xA2719263)
		ePhoneInAnim()
		showPhone = true
		SendNUIMessage({
			show = true
		})
	end
end

function ePhoneHide()
	if showPhone then
		SendNUIMessage({
			hide = true
		})
		ePhoneOutAnim()
		showPhone = false
	end
end

function ePhoneUp()
	if showPhone and battery > 0 then
		SendNUIMessage({
			up = true
		})
	end
end

function ePhoneDown()
	if showPhone and battery > 0 then
		SendNUIMessage({
			down = true
		})
	end
end

function ePhoneLeft()
	if showPhone and battery > 0 then
		SendNUIMessage({
			left = true
		})
	end
end

function ePhoneRight()
	if showPhone and battery > 0 then
		SendNUIMessage({
			right = true
		})
	end
end

function ePhoneSelect()
	if showPhone and battery > 0 then
		SendNUIMessage({
			select = true
		})
	end
end

function ePhoneCancel()
	if showPhone and battery > 0 then
		SendNUIMessage({
			cancel = true
		})
	elseif showPhone then
		ePhoneHide()
	end
end

function ePhoneOption()
	if showPhone and battery > 0 then
		SendNUIMessage({
			option = true
		})
	end
end

function ePhoneExtraOption()
	if showPhone and battery > 0 then
		SendNUIMessage({
			extra_option = true
		})
	end
end

function IsPlayerInCall()
	if inCall then
		return true
	else
		return false
	end
end

function IsPlayerUsingPhone()
	if showPhone then
		return true
	else
		return false
	end
end

--------------------------------------------------------------------------------
--
--									EVENTS
--
--------------------------------------------------------------------------------
RegisterNetEvent("ephone:enable")
AddEventHandler("ephone:enable", function ()
	enable_phone = true
end)

RegisterNetEvent("ephone:disable")
AddEventHandler("ephone:disable", function ()
	enable_phone = false
	ePhoneHide()
end)

RegisterNetEvent("ephone:show")
AddEventHandler("ephone:show", function ()
	ePhoneShow()
end)

RegisterNetEvent("ephone:hide")
AddEventHandler("ephone:hide", function ()
	ePhoneHide()
end)

RegisterNetEvent("ephone:up")
AddEventHandler("ephone:up", function ()
	ePhoneUp()
end)

RegisterNetEvent("ephone:down")
AddEventHandler("ephone:down", function ()
	ePhoneDown()
end)

RegisterNetEvent("ephone:left")
AddEventHandler("ephone:left", function ()
	ePhoneLeft()
end)

RegisterNetEvent("ephone:right")
AddEventHandler("ephone:right", function ()
	ePhoneRight()
end)

RegisterNetEvent("ephone:cancel")
AddEventHandler("ephone:cancel", function ()
	ePhoneCancel()
end)

RegisterNetEvent("ephone:select")
AddEventHandler("ephone:select", function ()
	ePhoneSelect()
end)

RegisterNetEvent("ephone:option")
AddEventHandler("ephone:option", function ()
	ePhoneOption()
end)

RegisterNetEvent("ephone:extra_option")
AddEventHandler("ephone:extra_option", function ()
	ePhoneExtraOption()
end)
