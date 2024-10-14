local pickup, PickUpBlip, TreeCareBlip = nil, nil, nil
local jobExperience, jobLevel = nil, nil
local activeJob, isPlayerDriving, hasMowingVehicle = false, false, false 
local collectedPoints = 0

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then 
        CreateDepotBlip()
    end
end)

AddEventHandler('esx:playerLoaded', function()
    CreateDepotBlip()
end)

function CreateDepotBlip()
    DepotBlip = AddBlipForCoord(Config.Zones.ManageJob.Position)
	SetBlipSprite(DepotBlip, 357)
	SetBlipScale(DepotBlip, 1.0)
    SetBlipColour(DepotBlip, 2)
	SetBlipAsShortRange(DepotBlip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString('Gardener Depot')
	EndTextCommandSetBlipName(DepotBlip)
end

function CreatePickupBlip(pickup)
    PickUpBlip = AddBlipForCoord(pickup)
	SetBlipSprite(PickUpBlip, 1)
	SetBlipScale(PickUpBlip, 1.0)
    SetBlipColour(PickUpBlip, 2)
	SetBlipAsShortRange(PickUpBlip, true)
	SetBlipRoute(PickUpBlip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString('Weed')
	EndTextCommandSetBlipName(PickUpBlip)
end

function CreateTreeCareBlip(treecare)
    TreeCareBlip = AddBlipForCoord(treecare)
	SetBlipSprite(TreeCareBlip, 1)
	SetBlipScale(TreeCareBlip, 1.0)
    SetBlipColour(TreeCareBlip, 2)
	SetBlipAsShortRange(TreeCareBlip, true)
	SetBlipRoute(TreeCareBlip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString('Treecare')
	EndTextCommandSetBlipName(TreeCareBlip)
end

function StartPickupJob()
    ESX.UI.Menu.CloseAll()
    activeJob = true
    
    ESX.ShowNotification('Pull the ~g~weed~s~ out of the ground')

    pickup = Config.JobPickups[math.random(1, #Config.JobPickups)]
    CreatePickupBlip(pickup)

    -- Marker and Interaction
    CreateThread(function()
        while pickup do
            local sleep = 1500
            local coords = GetEntityCoords(PlayerPedId())
            local distance = #(coords - vector3(pickup))

            if distance < Config.DrawDistance then
                sleep = 0
                DrawMarker(21, pickup.x, pickup.y, pickup.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 1.0,
                0.5, 85, 255, 0, 100, true, false, 2, true, nil, nil, false)
            end

            if distance < 1.0 then
                ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to pull out the weed')
                if IsControlJustReleased(0, 38) then
                    local success = lib.skillCheck({'easy', 'easy', 'medium'})
                    if success then 
                        if lib.progressCircle({
                            duration = 10000,
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                            },
                            anim = {
                                scenario = 'WORLD_HUMAN_GARDENER_PLANT',
                            },
                        }) then 
                            collectedPoints = collectedPoints + 1 
                            ESX.ShowNotification('You recieved ~g~x'..collectedPoints..' Garden Points')

                            RemoveBlip(PickUpBlip)
                            pickup = Config.JobPickups[math.random(1, #Config.JobPickups)]
                            CreatePickupBlip(pickup)

                            ESX.ShowNotification('Go to the next point')
                        end
                    else
                        ESX.ShowNotification('You did not pass the skill-check')
                    end
                end
            end
    
            Wait(sleep)
        end
    end)
end

function StartTreeCareJob()
    ESX.UI.Menu.CloseAll()
    activeJob = true
    
    ESX.ShowNotification('Go and care about the trees.')

    treecare = Config.JobTrees[math.random(1, #Config.JobTrees)]
    CreateTreeCareBlip(treecare)

    -- Marker and Interaction
    CreateThread(function()
        while treecare do
            local sleep = 1500
            local coords = GetEntityCoords(PlayerPedId())
            local distance = #(coords - vector3(treecare))

            if distance < Config.DrawDistance then
                sleep = 0
                DrawMarker(21, treecare.x, treecare.y, treecare.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 1.0,
                0.5, 85, 255, 0, 100, true, false, 2, true, nil, nil, false)
            end

            if distance < 1.0 then
                ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to care about the tree')
                if IsControlJustReleased(0, 38) then
                    local success = lib.skillCheck({'easy', 'medium'})
                    if success then 
                        if lib.progressCircle({
                            duration = 5000,
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                            },
                            anim = {
                                dict = 'anim@move_m@trash',
                                clip = 'pickup'
                            },
                        }) then 
                            collectedPoints = collectedPoints + 1 
                            ESX.ShowNotification('You recieved ~g~x'..collectedPoints..' Garden Points')

                            RemoveBlip(TreeCareBlip)
                            treecare = Config.JobTrees[math.random(1, #Config.JobTrees)]
                            CreateTreeCareBlip(treecare)

                            ESX.ShowNotification('Go to the next point')
                        end
                    else
                        ESX.ShowNotification('You did not pass the skill-check')
                    end
                end
            end
    
            Wait(sleep)
        end
    end)
end

function StartMowingJob()
    ESX.UI.Menu.CloseAll()
    if activeJob then ESX.ShowNotification('You already have an active job') return end

    if not IsPositionOccupied(Config.VehicleSpawn.x, Config.VehicleSpawn.y, Config.VehicleSpawn.z, 10, false, true) then
        ESX.Game.SpawnVehicle(Config.Vehicle, Config.VehicleSpawn, Config.VehicleSpawn.w, function(spawnedVehicle)
            TaskWarpPedIntoVehicle(PlayerPedId(), spawnedVehicle, -1)
            activeJob, hasMowingVehicle = true, true
            ESX.ShowNotification('Have fun ~g~mowing~s~!')
        end)
    else 
        ESX.ShowNotification('You cant park out the mower. The point is blocked.')
    end

    CreateThread(function()
        while activeJob do 
            Wait(10000)
            if isPlayerDriving then 
                collectedPoints = collectedPoints + 1 
                ESX.ShowNotification('You recieved ~g~x'..collectedPoints..' Garden Points')
            end
        end
    end)

    CreateThread(function()
        while activeJob do 
            Wait(0)
            local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if IsVehicleModel(playerVehicle, GetHashKey(Config.Vehicle)) then
                local vehicleSpeed = (GetEntitySpeed(playerVehicle) * 3.6)
                if vehicleSpeed >= 5 then 
                    isPlayerDriving = true
                else
                    isPlayerDriving = false
                end
            end
        end
    end)
end

function ManageJob()
    ESX.UI.Menu.CloseAll()
    ESX.TriggerServerCallback('rlo_gardening:callback:checkJobStatistics', function(experience)
        if experience == nil then
            ESX.ShowNotification("Welcome to the ~g~Gardener Depot~s~, we've created a profile for you")
            CurrentAction = 'manageJob'
            return
        end

        jobExperience = experience
        jobLevel = math.floor(jobExperience / 1000)

        local menuElements = {
            {label = '❇️ Check Experience and Level', name = 'job_level'},
            {label = '🍃 Start Weeding (Lvl. 0)', name = 'start_pickup'},
            {label = '🌳 Start Tree Care (Lvl. 5)', name = 'start_trees'},
            {label = '🚜 Start Lawn Mowing (Lvl. 25)', name = 'start_mowing'},
            {label = '🪙 Redeem Garden Points (x'..collectedPoints..')', name = 'redeem_points'},
        }        
        
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gardening_manage_menu', {
            css = 'bossmenu',
            title = 'Gardener | Current Level: '..tostring(jobLevel),
            align = 'top-left',
            elements = menuElements
        }, function(data, menu)
            if data.current.name == 'job_level' then
                ESX.ShowNotification('You currently have ~g~' .. jobExperience .. ' Experience~s~, that means you are ~b~Level ' .. jobLevel .. '~s~.')

            elseif data.current.name == 'start_pickup' then
                StartPickupJob()

            elseif data.current.name == 'start_trees' then
                if jobLevel >= 5 then
                    StartTreeCareJob()
                else
                    ESX.ShowNotification('You need at least ~g~Level 5 ~s~to start this task')
                end

            elseif data.current.name == 'start_mowing' then
                if jobLevel >= 25 then
                    StartMowingJob()
                else
                    ESX.ShowNotification('You need at least ~g~Level 25 ~s~to start this task')
                end
                
            elseif data.current.name == 'redeem_points' then 
                if activeJob and not hasMowingVehicle then 
                    menu.close()
                    TriggerServerEvent('rlo_gardening:server:redeemPoints', collectedPoints)
                    RemoveBlip(PickUpBlip)
                    activeJob, pickup, collectedPoints = false, nil, 0
                else
                    ESX.ShowNotification('You do not have any Garden Points or you did not give back your mower.')
                end
            end
        end, function(data, menu)
            menu.close()
        end)
    end)
end

function DeleteVehicle(vehicle)
    ESX.UI.Menu.CloseAll()

    if IsVehicleModel(vehicle, GetHashKey(Config.Vehicle)) then
        ESX.Game.DeleteVehicle(vehicle)
        hasMowingVehicle = false
        ESX.ShowNotification('You can redeem your Garden Points at the Depot now')
    else
        ESX.ShowNotification('You need to give back your mower')
    end 
end

AddEventHandler('rlo_gardening:client:hasEnteredMarker', function(zone)
    if zone == 'ManageJob' then
        CurrentAction = 'manageJob'
        CurrentActionMsg = 'Press ~INPUT_CONTEXT~ to open Gardener Depot'
        CurrentActionData = {}

    elseif zone == 'VehicleDelete' then
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            CurrentAction = 'vehicleDelete'
            CurrentActionMsg = 'Press ~INPUT_CONTEXT~ to give mower back'
            CurrentActionData = { vehicle = vehicle }
        end
    end
end)

AddEventHandler('rlo_gardening:client:hasExitedMarker', function(zone)
    ESX.UI.Menu.CloseAll()
    CurrentAction = nil
end)

CreateThread(function()
    while true do
        local sleep = 1500
        local coords = GetEntityCoords(PlayerPedId())
        local isInMarker, currentZone = false

        for k, v in pairs(Config.Zones) do
            local distance = #(coords - vector3(v.Position))

            if v.Type ~= -1 and distance < Config.DrawDistance then
                sleep = 0
                DrawMarker(v.Type, v.Position.x, v.Position.y, v.Position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y,
                    v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, false, 2, v.Rotate, nil, nil, false)
            end

            if distance < v.Size.x then
                isInMarker, currentZone = true, k
            end
        end

        if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
            HasAlreadyEnteredMarker, LastZone = true, currentZone
            TriggerEvent('rlo_gardening:client:hasEnteredMarker', currentZone)
        end

        if not isInMarker and HasAlreadyEnteredMarker then
            HasAlreadyEnteredMarker = false
            TriggerEvent('rlo_gardening:client:hasExitedMarker', LastZone)
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1500
        if CurrentAction and not ESX.PlayerData.dead then
            sleep = 0
            ESX.ShowHelpNotification(CurrentActionMsg)

            if IsControlJustReleased(0, 38) then
                if CurrentAction == 'manageJob' then
                    ManageJob()

                elseif CurrentAction == 'vehicleDelete' then
                    DeleteVehicle(CurrentActionData.vehicle)
                    
                end
                CurrentAction = nil
            end
        end
        Wait(sleep)
    end
end)