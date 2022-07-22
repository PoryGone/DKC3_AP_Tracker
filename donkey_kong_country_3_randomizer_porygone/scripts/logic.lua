
function IsThreeBonusLevel(world_index, level_index)
	local global_level_index = ((tonumber(world_index) - 1) * 5) + tonumber(level_index)
    local triple_bonus_1 = Tracker:ProviderCountForCode("triple_bonus_1")
    local triple_bonus_2 = Tracker:ProviderCountForCode("triple_bonus_2")
    local triple_bonus_3 = Tracker:ProviderCountForCode("triple_bonus_3")
	return (global_level_index == triple_bonus_1) or (global_level_index == triple_bonus_2) or (global_level_index == triple_bonus_3)
end
	
function KrematoaLevelCost(level_index)
	local boomerCost = Tracker:ProviderCountForCode("boomer_costs")
	local bonusCoins = Tracker:ProviderCountForCode("bonus_coins")
	return (bonusCoins >= (boomerCost * tonumber(level_index)))
end
