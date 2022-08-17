ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

LEVEL_UNLOCKS = {}



CUR_INDEX = -1
SLOT_DATA = nil


function onClear(slot_data)
    SLOT_DATA = slot_data
    CUR_INDEX = -1

    for _, v in pairs(ITEM_MAPPING) do
        if v[1] then
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    if obj.Active then
                        obj.CurrentStage = 0
                    --else
                    --    obj.Active = true
                    end
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                end
            end
        end
    end
    for _, v in pairs(SETTINGS_MAPPING) do
        if v[1] then
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                obj.AcquiredCount = 0
            end
        end
    end

    for k, v in pairs(LOCATION_MAPPING) do
        local loc_list = LOCATION_MAPPING[k]
        for i, loc in ipairs(loc_list) do
            if loc:sub(1, 1) == "@" then
                local obj = Tracker:FindObjectForCode(loc)
                if obj then
                        obj.AvailableChestCount = obj.ChestCount
                end
            end
        end
    end

    local loc_type_list = {"Flag", "Bonus 1", "Bonus 2", "Bonus 3", "DK Coin", "KONG"}
    for world_index=1,8 do
        for level_index=1,5 do
            for i, level_type in ipairs(loc_type_list) do
                local level_str = "@W" .. tostring(world_index) .. "-" .. tostring(level_index) .. "/" .. level_type
                local obj = Tracker:FindObjectForCode(level_str)
                if obj then
                    obj.AvailableChestCount = obj.ChestCount
                end
            end
        end
    end

    local obj = Tracker:FindObjectForCode("gyrocopter")
    if obj then
        obj.Active = false
    end

    if SLOT_DATA == nil then
        return
    end

    if slot_data['dk_coins_for_gyrocopter'] then
        local dk_coins_for_gyrocopter = Tracker:FindObjectForCode("dk_coins_for_gyrocopter")
        if dk_coins_for_gyrocopter then
            dk_coins_for_gyrocopter.AcquiredCount = (slot_data['dk_coins_for_gyrocopter'])
        end
    end

    if slot_data['krematoa_bonus_coin_cost'] then
        local boomer_costs = Tracker:FindObjectForCode("boomer_costs")
        if boomer_costs then
            boomer_costs.AcquiredCount = (slot_data['krematoa_bonus_coin_cost'])
        end
    end

    if slot_data['number_of_banana_birds'] and slot_data['percentage_of_banana_birds'] then
        local banana_birds_required = Tracker:FindObjectForCode("banana_birds_required")
        if banana_birds_required then
            banana_birds_required.AcquiredCount = math.floor((slot_data['number_of_banana_birds'] * slot_data['percentage_of_banana_birds']) / 100)
        end
    end

    if slot_data['goal'] then
        local goal = Tracker:FindObjectForCode("goal")
        goal.Active = (slot_data['goal'] ~= 0)
    end

    if slot_data['kongsanity'] then
        local kongsanity = Tracker:FindObjectForCode("kongsanity")
        kongsanity.Active = (slot_data['kongsanity'] ~= 0)
    end

    if slot_data['active_levels'] then
        local triple_bonus_1 = Tracker:FindObjectForCode("triple_bonus_1")
        local triple_bonus_2 = Tracker:FindObjectForCode("triple_bonus_2")
        local triple_bonus_3 = Tracker:FindObjectForCode("triple_bonus_3")
        
        for i, level in ipairs(slot_data['active_levels']) do
            if "Stampede Sprint" == level then
                triple_bonus_1.AcquiredCount = i
            elseif "Tyrant Twin Tussle" == level then
                triple_bonus_2.AcquiredCount = i
            elseif "Swoopy Salvo" == level then
                triple_bonus_3.AcquiredCount = i
            end
        end
    end
end

function onItem(index, item_id, item_name, player_number)
    if index <= CUR_INDEX then return end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    
    local v = ITEM_MAPPING[item_id]
    if not v then
        return
    end

    if not v[1] then
        return
    end

    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        end
    end
end

function onLocation(location_id, location_name)
    if SLOT_DATA == nil  or SLOT_DATA['active_levels'] == nil then
        return
    end

    local loc_data = LOCATION_MAPPING[location_id]
    if location_id > 0xDC309E and location_id < 0xDC3100 then
        for i, loc in ipairs(loc_data) do
            if not loc then
                return
            end
            local obj = Tracker:FindObjectForCode(loc)
            if obj then
                if loc:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.AvailableChestCount - 1
                else
                    obj.Active = true
                end
            end
        end
    else
        local active_levels = SLOT_DATA['active_levels']
        local level_name = loc_data[1]
        local level_type = loc_data[2]
        for i, level in ipairs(active_levels) do
            if level_name == level then
                local world_index = ((i-1) // 5) + 1
                local level_index = ((i-1) % 5) + 1
                local loc_str = "@W" .. tostring(world_index) .. "-" .. tostring(level_index) .. "/" .. level_type
                local obj = Tracker:FindObjectForCode(loc_str)
                if obj then
                    obj.AvailableChestCount = obj.AvailableChestCount - 1
                end
                break
            end
        end
    end
end


Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
