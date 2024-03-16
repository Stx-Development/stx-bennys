QBCore = exports['qb-core']:GetCoreObject()
local inBenny = false



local function openbennys()
    CreateThread(function()
        while true do
            Wait(0)
            if inBenny then
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('srp-bennys:client:openrepairmenu')
                    
                    break
                end
            else
                break
            end
        end
    end)
end


local function Repair(typee)

    if IsPedInAnyVehicle(PlayerPedId()) then
        local vehicle = GetVehiclePedIsIn(PlayerPedId())
        local getFuel = GetVehicleFuelLevel(vehicle)
        local currentEngine = GetVehicleEngineHealth(vehicle)
        if tostring(typee) == 'engine' then
            SetVehicleEngineHealth(vehicle, 1000.0)
        elseif tostring(typee) == 'body' then
            SetVehicleBodyHealth(vehicle, 1000.0)
            SetVehicleFixed(vehicle)
            SetVehicleEngineHealth(vehicle, currentEngine)
        end
        exports[Config.Fuel]:SetFuel(vehicle, getFuel)
    else
        lib.notify({
            title = 'Bennys',
            description = 'You Are Not In A Vehicle',
            type = 'error'
        })
    end

end

function VehicleHealthColor(PROGRESS)
    if PROGRESS >= 75 then
        return 'green'
    elseif PROGRESS < 75 and PROGRESS >= 50 then
        return 'yellow'
    elseif PROGRESS < 50 and PROGRESS >= 25 then
        return 'orange'
    elseif PROGRESS < 25 and PROGRESS >= 0 then
        return 'red'
    end
end


local function RepairVehicleFunction(typee)
    if lib.progressCircle({
        duration = 10000,
        label = 'Repairing Vehicle...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
        anim = {},
        prop = {},
    }) then 
        Repair(typee)
    else 
        lib.notify({
            title = 'Bennys',
            description = 'Cancelled',
            type = 'error'
        })
    end

end

RegisterNetEvent('srp-bennys:client:passevent:openmenu', function(typee)
    if typee == 'engine' then
        RepairVehicleFunction('engine')
    elseif typee == 'body' then
        RepairVehicleFunction('engine')
    end

end)
RegisterNetEvent('srp-bennys:client:openrepairmenu', function()
    if not IsPedInAnyVehicle(PlayerPedId()) then return end
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    local checkmechanic = 0
    local getmechaniccount = 0
    for k, v in pairs(Config.Jobs) do
        lib.callback('srp-bennys:server:callback:getjobcount', source, function(result)
            print(''..v..' Received : '..result)
            if result > 0 then
                checkmechanic = checkmechanic + 1
            end
        end, v)
    end
    lib.notify({
        title = 'Bennys',
        description = 'Checking Available Mechanics',
        type = 'inform'
    })
    
    Wait(1000)
    if checkmechanic > 0 then 
        lib.notify({
            title = 'Bennys',
            description = 'Mechanics Available In City',
            type = 'inform'
        })
        return
    end

    lib.registerContext({
        id = 'repair_menu',
        title = 'Vehicle Repair',
        options = {
            {
                title = 'Engine Health: '..tostring(math.ceil(GetVehicleEngineHealth(vehicle) / 10))..'%',
                progress = (GetVehicleEngineHealth(vehicle) / 10),
                colorScheme = VehicleHealthColor(math.ceil(GetVehicleEngineHealth(vehicle) / 10)),
                icon = 'fas fa-car-battery',
                onSelect = function()
                   TriggerServerEvent('srp-bennys:server:removemoney', 'engine')
                end
            },
            {
                title = 'Body Health: '..tostring(math.ceil(GetVehicleBodyHealth(vehicle) / 10))..'%',
                progress = (GetVehicleBodyHealth(vehicle) / 10),
                colorScheme = VehicleHealthColor(math.ceil(GetVehicleBodyHealth(vehicle) / 10)),
                icon = 'fas fa-car-burst',
                onSelect = function()
                    TriggerServerEvent('srp-bennys:server:removemoney', 'body')
                end
            },
        }
    })
    lib.showContext('repair_menu')

end)






-------------------------- ZONE SETTINGS
--- Add Options
local benny = PolyZone:Create({
    vector2(-34.7861, -1049.7408),
    vector2(-37.7696, -1057.1890),
    vector2(-25.7364, -1061.4871),
    vector2(-23.0048, -1054.0563),
}, {
    name="benny",
    minZ = 28.4042 - 2,
    maxZ = 28.4042 + 3
})



benny:onPlayerInOut(function(isPointInside)
    if isPointInside then
        inBenny = true 
        openbennys()
        lib.showTextUI('[E] - Bennys', {position = 'left-center'})
    else
        inBenny = false
        lib.hideTextUI()
    end
end)
