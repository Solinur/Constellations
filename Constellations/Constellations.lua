local em = GetEventManager()
local _
local db
local dx = 1/GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE) --Get UI Scale to draw thin lines correctly

-- Addon Namespace
Constellations = Constellations or {}
local CST = Constellations
CST.name 		= "Constellations"
CST.version 	= "0.3.9"
CST.debug = true

local function Print(message, ...)

	if CST.debug==false then return end
	df("[%s] %s", CST.name, message:format(...))
	
end

local spellcrit = GetCriticalStrikeChance(GetPlayerStat(STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP), true)
local weaponcrit = GetCriticalStrikeChance(GetPlayerStat(STAT_CRITICAL_STRIKE, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP), true)
local CPdefault = math.min(GetNumSpentChampionPoints(ATTRIBUTE_MAGICKA) + GetNumUnspentChampionPoints(ATTRIBUTE_MAGICKA), GetMaxSpendableChampionPointsInAttribute())

local sliderDefaults = {{CPdefault, 20, spellcrit, 50, 18200, weaponcrit, 50, 18200}, {100, 50, 40, 10, 100, 0, 0, 0, 0, 0, 0}, {18200}}
--local sliderDefaults = {{ratios, 0, 58, 50, 10144, 58, 50, 10144}, {100, 60, 40, 10, 100, 0, 0, 0, 0, 0, 0}, {18200}}

local CategoryStrings = {
	[1] = "SI_CONSTELLATIONS_INPUT_STATS_LABEL",
	[2] = "SI_CONSTELLATIONS_INPUT_RATIOS_LABEL",
	[3] = "SI_CONSTELLATIONS_INPUT_TARGET_LABEL",
}

local statControl
local ratioControl
local targetControl

function CST.InitializeInputSliders(control, category)
	
	local CategoryString = CategoryStrings[category]
	local CategoryTTString = CategoryString.."_TOOLTIP"
	
	local defaults = sliderDefaults[category]
	
	if category == 1 then 
		statControl = control
	elseif  category == 2 then 
		ratioControl = control
	elseif  category == 3 then 
		targetControl = control
	end
	
	for k = 1, control:GetNumChildren() do
		
		local child = control:GetChild(k)
		
		if child:GetType() == 0 then 
		
			local i = child.id
		
			local label = child:GetNamedChild("Label")
			child.label = label
			
			local text = GetString(CategoryString, i)
			local colors = ZO_ColorDef:New(GetString(child.color))
			
			label:SetText(text)
			label:SetColor(colors.r, colors.g, colors.b, colors.a)
			
			local tooltipText = GetString(CategoryTTString, i)
			
			if tooltipText ~= "" then 
				label.data = {tooltipText = tooltipText}
				label:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
				label:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
			end
			
			local slider = child:GetNamedChild("Slider")
			
			if child.minmax ~= nil then 
			
				local min, max, step = unpack(child.minmax)
				slider:SetMinMax(min, max)
				slider:SetValueStep(step)
			end
			
			slider:SetValue(defaults[i])
			
			local value = child:GetNamedChild("Value")
			value:SetColor(label:GetColor())		
		end
	end
end

local resultRows

function Constellations.InitializeStarRows(control)

	resultRows = control
	
	for i = 1, control:GetNumChildren() do
		
		local child = control:GetChild(i)
		local skillId = child.skillId
		local discipline = child.discipline
		local colors = ZO_ColorDef:New(GetString(child.color))
		
		if child:GetType() == 0 and discipline ~= nil and skillId ~= nil then 
			
			local label = child:GetNamedChild("Label")
			
			label:SetText(zo_strformat(SI_SKILLS_ENTRY_NAME_FORMAT, GetChampionSkillName(discipline, skillId)))
			label:SetColor(colors.r, colors.g, colors.b, colors.a)
			
			local value = child:GetNamedChild("Value")
			local points = GetNumPointsSpentOnChampionSkill(discipline, skillId)
			local abilityId = GetChampionAbilityId(discipline, skillId)
			
			child.points = points
			child.abilityId = abilityId
			
			value:SetText(string.format("%d", points))
			value:SetColor(colors.r, colors.g, colors.b, colors.a)
			
		elseif child:GetType() == 1 and discipline ~= nil then
		
			child:SetText(zo_strformat(SI_CHAMPION_CONSTELLATION_NAME_FORMAT, GetChampionDisciplineName(discipline)))
		
		end
	end
end

local controlTabs = {}

function Constellations.InitTab(control)

	local id = control.id
	
	if id then controlTabs[id] = control end
	
end

function Constellations.SetTab(control)

	control:SetState(BSTATE_PRESSED)
	
	local setid = control.id

	local titleControl = control:GetParent()
	
	for i = 1, titleControl:GetNumChildren() do
	
		local child = titleControl:GetChild(i)
		local id = child.id
		
		if id and setid == id then
		
			controlTabs[id]:SetHidden(false)

		elseif id then
		
			child:SetState(BSTATE_NORMAL)
			controlTabs[id]:SetHidden(true)
		end
	end
end

local function SetNewStarValues(CPValues)

	for i = 1, resultRows:GetNumChildren() do
		
		local child = resultRows:GetChild(i)
		local abilityId = child.abilityId
		
		if child:GetType() == 0 and abilityId ~= nil then 
			
			local newvalue = child:GetNamedChild("Value2")
			newvalue:SetText(tostring(CPValues[abilityId]))
		
		end
	end
end

function CST.SetSliderValue(self, value)
	
	local valueControl = self:GetParent():GetNamedChild("Value")
	
	local min, max = self:GetMinMax()
	local form = max > 150 and "%.0f " or "%.1f%%"
	
	valueControl:SetText(string.format(form, value))
	
end

function CST.ApplyCurrentStarsButton(control)

	PlaySound("Click") 

	CST.ApplyCurrentStars = not CST.ApplyCurrentStars
	
	local crossTexture = control:GetNamedChild("Checked")
	
	crossTexture:SetHidden(not CST.ApplyCurrentStars)
	
end

local function GetCurrentStats()

	local stats = {}

	for i = 1, statControl:GetNumChildren() do

		local child = statControl:GetChild(i)
		local slider = child:GetNamedChild("Slider")
		local id = child.id
		
		if child:GetType() == 0 and id then stats[id] = zo_roundToNearest(slider:GetValue(), 0.1) end
	end
	
	return stats
end

local function SetStats(stats)

	for i = 1, statControl:GetNumChildren() do

		local child = statControl:GetChild(i)
		local slider = child:GetNamedChild("Slider")
		local id = child.id
		
		if child:GetType() == 0 and id and stats[id] then slider:SetValue(zo_roundToNearest(stats[id], 0.1)) end
	end
end

local function GetCurrentRatios()

	local ratios = {}

	for i = 1, ratioControl:GetNumChildren() do

		local child = ratioControl:GetChild(i)
		local slider = child:GetNamedChild("Slider")
		local id = child.id
		
		if child:GetType() == 0 and id then ratios[id] = zo_roundToNearest(slider:GetValue(), 0.1) end
	end
	
	return ratios
end

local function SetRatios(ratios)

	for i = 1, ratioControl:GetNumChildren() do

		local child = ratioControl:GetChild(i)
		local slider = child:GetNamedChild("Slider")
		local id = child.id
		
		if child:GetType() == 0 and id and ratios[id] then slider:SetValue(zo_roundToNearest(ratios[id], 0.1)) end
	end

end

local function GetCurrentTargetStats()

	local targetStats = {}

	for i = 1, targetControl:GetNumChildren() do

		local child = targetControl:GetChild(i)
		local slider = child:GetNamedChild("Slider")
		local id = child.id
		
		if child:GetType() == 0 and id then targetStats[id] = zo_roundToNearest(slider:GetValue(), 0.1) end
	end
	
	return targetStats
end

local function UpdateCP(newCP)

	for i = 1, resultRows:GetNumChildren() do
		
		local child = resultRows:GetChild(i)
		local skillId = child.skillId
		local discipline = child.discipline
		
		if child:GetType() == 0 and discipline ~= nil and skillId ~= nil then 
			
			local label = child:GetNamedChild("Label")
			
			local currentCP = GetChampionSkillName(discipline, skillId)
			label:SetText(zo_strformat(SI_SKILLS_ENTRY_NAME_FORMAT, currentCP))
			
			local value = child:GetNamedChild("Value")
			local points = newCP and newCP[discipline][skillId] or GetNumPointsSpentOnChampionSkill(discipline, skillId)
			
			value:SetText(string.format("%d", points))
			
		end
	end
end

CST.UpdateCP = UpdateCP

local function GetCurrentCP()
	
	local currentCP = {}
	local minCP = {}
	local maxCP = {}

	for i = 1, resultRows:GetNumChildren() do
		
		local child = resultRows:GetChild(i)
		local abilityId = child.abilityId
		
		if child:GetType() == 0 and abilityId ~= nil then 
			
			local control = child:GetNamedChild("Value")
			local value = tonumber(control:GetText())
			
			local minControl = child:GetNamedChild("Min")
			local minvalue = tonumber(minControl:GetText())
			
			local maxControl = child:GetNamedChild("Max")
			local maxvalue = tonumber(maxControl:GetText())
			
			currentCP[abilityId] = value
			minCP[abilityId] =  minvalue
			maxCP[abilityId] = maxvalue
			
		end
	end
	
	return currentCP, minCP, maxCP
end

local STARTYPE_15 = 1
local STARTYPE_25 = 2
local STARTYPE_35 = 3
local STARTYPE_55 = 4
local STARTYPE_5280 = 5

local CPData = {
	[63848] = {type = STARTYPE_15, 		attribute=ATTRIBUTE_MAGICKA },	-- Elemental Expert
	[61555] = {type = STARTYPE_5280, 	attribute=ATTRIBUTE_MAGICKA },	-- Spell Erosion
	[61680] = {type = STARTYPE_25, 		attribute=ATTRIBUTE_MAGICKA }, 	-- Elfborn
	[92424] = {type = STARTYPE_35, 		attribute=ATTRIBUTE_STAMINA },	-- Physical Weapon Expert
	[92134] = {type = STARTYPE_25, 		attribute=ATTRIBUTE_NONE },		-- Master-at-Arms
	[60503] = {type = STARTYPE_35, 		attribute=ATTRIBUTE_MAGICKA },	-- Staff Expert
	[63847] = {type = STARTYPE_25, 		attribute=ATTRIBUTE_NONE },		-- Thaumaturge
	[59105] = {type = STARTYPE_25, 		attribute=ATTRIBUTE_STAMINA }, 	-- Precise Strikes
	[61546] = {type = STARTYPE_5280, 	attribute=ATTRIBUTE_STAMINA },	-- Piercing
	[63868] = {type = STARTYPE_15, 		attribute=ATTRIBUTE_STAMINA },	-- Mighty
}

local JumpPoints = {
	[STARTYPE_15]	= {0,4,7,11,15,19,23,27,32,37,43,49,64,75,100},
	[STARTYPE_25]	= {0,3,5,7,9,11,13,15,16,18,20,23,26,28,31,34,37,40,44,48,52,56,66,72,81,100},
	[STARTYPE_35]	= {0,2,3,5,6,8,9,11,13,14,16,18,19,21,23,25,27,29,31,33,35,37,39,42,44,47,50,53,56,59,63,67,72,77,84,100},
	--[STARTYPE_55]	= {0,2,3,5,6,8,9,11,13,14,16,18,19,21,23,25,27,29,31,33,35,37,39,42,44,47,50,53,56,59,63,67,72,77,84,100}, not needed for now
}

local function GetCPValue(abilityId, points, round)
	
	local cpType = CPData[abilityId].type
	local value = 0 
	points = points/100	
	
	if cpType == STARTYPE_15 then 
		
		value = 0.15*points*(2-points)+(points-1)*(points-0.5)*points*2/150
	
	elseif cpType == STARTYPE_25 then 
	
		value = 0.25*points*(2-points)+(points-1)*(points-0.5)*points*2/250
		
	elseif cpType == STARTYPE_35 then 
	
		value = 0.35*points*(2-points)+(points-1)*(points-0.5)*points*2/150
	
	elseif cpType == STARTYPE_55 then 
	
		value = 0.55*points*(2-points)+(points-1)*(points-0.5)*points*2/250
	
	elseif cpType == STARTYPE_5280 then 
	
		value = math.floor(5280*points*(2-points))
		round = false
	end
	
	if round == true then value = math.floor(value*100)/100	end
	
	return value
end

local function GetDamageFactor(stats, ratios, targetStats, CP, round)

	local cpfactors = {}

	for abilityId, value in pairs(CP) do
		
		cpfactors[abilityId] = GetCPValue(abilityId, value, round)
		
	end 

	local spellCPMod = ( 
		(ratios[2]/100 * (1 + cpfactors[63848] + cpfactors[92134] + stats[2]/100)) 							-- Direct Magical Damage (1 + Elemental Expert + Master-at-Arms + Damage Done)
		+ (ratios[3]/100 * (1 + cpfactors[63848] + cpfactors[63847] + stats[2]/100))						-- DoT Magical Damage (1 + Elemental Expert + Thaumaturge + Damage Done)
		+ (ratios[4]/100 * (1 + cpfactors[63848] + cpfactors[92134] + cpfactors[60503] + stats[2]/100))		-- Staff Direct Damage (1 + Elemental Expert + Master-at-Arms + Staff Expert + Damage Done)
		+ (ratios[11]/100 * (1 + cpfactors[63848] + cpfactors[63847] + cpfactors[60503] + stats[2]/100)))	-- Staff DoT Damage (1 + Elemental Expert + Thaumaturge + Staff Expert + Damage Done)
		
	local weaponCPMod = (
		(ratios[7]/100 * (1 + cpfactors[63868] + cpfactors[92134] + stats[2]/100)) 							-- Direct Physical Damage (1 + Mighty + Master-at-Arms + Damage Done)
		+ (ratios[8]/100 * (1 + cpfactors[63868] + cpfactors[63847] + stats[2]/100))						-- DoT Magical Damage (1 + Mighty + Thaumaturge + Damage Done)
		+ (ratios[9]/100 * (1 + cpfactors[63868] + cpfactors[92134] + cpfactors[92424] + stats[2]/100)))	-- Weapon Direct Damage (1 + Mighty + Master-at-Arms + Physical Weapon Expert + Damage Done)

	local spellCritMod = 1 + ratios[5]/100 * stats[3]/100 * (stats[4]/100 + cpfactors[61680])
	local weaponCritMod = 1 + ratios[10]/100 * stats[6]/100 * (stats[7]/100 + cpfactors[59105])
	
	local spellPenMod = (1 - math.max(targetStats[1] - stats[5] - cpfactors[61555],0) / 50000)
	local weaponPenMod = (1 - math.max(targetStats[1] - stats[8] - cpfactors[61546],0) / 50000)
	
	local totalspellmod = ratios[1]/100 * spellCPMod * spellCritMod * spellPenMod
	local totalweaponmod = ratios[6]/100 * weaponCPMod * weaponCritMod * weaponPenMod

	local totalmod = totalspellmod + totalweaponmod
	
	return totalmod, (ratios[1]/100 * spellCPMod + ratios[6]/100 * weaponCPMod), (ratios[1]/100 * spellCritMod + ratios[6]/100 * weaponCritMod), (ratios[1]/100 * spellPenMod + ratios[6]/100 * weaponPenMod)
end


-- Ability Data, sadly hardcoded

local AFFECTED_BY_INCREASEDDAMAGE = 1
local AFFECTED_BY_MASTEROFARMS = 2
local AFFECTED_BY_THAUMATURGE = 3
local AFFECTED_BY_WEAPONEXPERT = 4
local AFFECTED_BY_CRITS = 5

-- isAffectedby = {Master-at-Arms, Thaumaturge, Staff/Weapon Expert, Elfborn/Precise Strikes}  (only pet skills or skills that can't crit are not affected by elfborn)
-- list is at https://docs.google.com/spreadsheets/d/1k9aDTz-kv-zrnUmAkVnX3bHQbF-QTdAhDtsfbu8zJkA/edit?usp=sharing

local AbilityData = {
	[46431] = {false, true, false, true}, --Anti-Calvary Caltrops
	[63295] = {false, false, false, true}, --Inevitable Detonation
	[63304] = {false, false, false, true}, --Proximity Detonation
	[46465] = {false, false, false, true}, --Razor Caltrops
	[46478] = {false, false, false, true}, --Razor Caltrops
	[46464] = {false, true, false, true}, --Razor Caltrops dot
	[46477] = {false, true, false, true}, --Razor Caltrops dot
	[40791] = {true, false, false, true}, --Acid Spray
	[40790] = {false, true, false, true}, --Acid Spray (dot)
	[40945] = {false, true, false, true}, --Arrow Barrage
	[85462] = {true, false, false, true}, --Ballista
	[86621] = {true, false, false, true}, --Ballista
	[40780] = {true, false, false, true}, --Bombard
	[40883] = {true, false, false, true}, --Draining Shot
	[40933] = {false, true, false, true}, --Endless Hail
	[40907] = {true, false, false, true}, --Focused Aim
	[17174] = {true, false, true, true}, --Heavy Attack (Bow)
	[17173] = {true, false, true, true}, --Heavy Attack (Bow), full
	[40897] = {true, false, false, true}, --Lethal Arrow
	[16688] = {true, false, true, true}, --Light Attack (Bow)
	[40869] = {true, false, false, true}, --Magnum Shot
	[40842] = {true, false, false, true}, --Poison Injection
	[44552] = {false, true, false, true}, --Poison Injection (dot)
	[86604] = {false, true, false, true}, --Toxic Barrage
	[86605] = {false, true, false, true}, --Toxic Barrage (dot)
	[40823] = {true, false, false, true}, --Venom Arrow
	[44548] = {false, true, false, true}, --Venom Arrow (dot)
	[62924] = {false, true, false, true}, --Blockade of Fire
	[62966] = {false, true, false, true}, --Blockade of Frost
	[63005] = {false, true, false, true}, --Blockade of Storms
	[18084] = {false, true, false, true}, --Burning
	[21481] = {false, true, false, true}, --Chill
	[21487] = {false, true, false, true}, --Concussion
	[48971] = {true, false, false, true}, --Crushing Shock (Fire)
	[48972] = {true, false, false, true}, --Crushing Shock (Frost)
	[48973] = {true, false, false, true}, --Crushing Shock (Shock)
	[68458] = {false, true, false, true}, --Deep Freeze
	[86541] = {false, true, false, true}, --Eye of Flame
	[86547] = {false, true, false, true}, --Eye of Frost
	[86553] = {false, true, false, true}, --Eye of Lightning
	[86516] = {false, true, false, true}, --Fiery Rage
	[62668] = {false, true, false, true}, --Fire Clench
	[62671] = {false, true, false, true}, --Fire Clench
	[62679] = {false, true, false, true}, --Fire Clench
	[42977] = {true, false, false, true}, --Fire Ring
	[38985] = {true, false, false, true}, --Flame Clench
	[40984] = {true, false, false, true}, --Flame Clench
	[41009] = {true, false, false, true}, --Flame Clench
	[42997] = {true, false, false, true}, --Flame Pulsar
	[41048] = {true, false, false, true}, --Flame Reach
	[62691] = {false, true, false, true}, --Flame Reach dot
	[40948] = {true, false, false, true}, --Flame Touch
	[40957] = {true, false, false, true}, --Flame Touch
	[40965] = {true, false, false, true}, --Flame Touch
	[62659] = {false, true, false, true}, --Flame Touch dot
	[62662] = {false, true, false, true}, --Flame Touch dot
	[62665] = {false, true, false, true}, --Flame Touch dot
	[48991] = {true, false, false, true}, --Force Pulse (Fire)
	[48992] = {true, false, false, true}, --Force Pulse (Frost)
	[48994] = {true, false, false, true}, --Force Pulse (Shock)
	[38989] = {true, false, false, true}, --Frost Clench
	[40988] = {true, false, false, true}, --Frost Clench
	[41013] = {true, false, false, true}, --Frost Clench
	[62702] = {false, true, false, true}, --Frost Clench dot
	[62705] = {false, true, false, true}, --Frost Clench dot
	[62711] = {false, true, false, true}, --Frost Clench dot
	[42999] = {true, false, false, true}, --Frost Pulsar
	[41051] = {true, false, false, true}, --Frost Reach
	[62721] = {false, true, false, true}, --Frost Reach dot
	[42979] = {true, false, false, true}, --Frost Ring
	[40950] = {true, false, false, true}, --Frost Touch
	[40959] = {true, false, false, true}, --Frost Touch
	[40967] = {true, false, false, true}, --Frost Touch
	[62695] = {false, true, false, true}, --Frost Touch dot
	[62698] = {false, true, false, true}, --Frost Touch dot
	[62701] = {false, true, false, true}, --Frost Touch dot
	[15385] = {true, false, true, true}, --Heavy Attack (Fire)
	[16321] = {true, false, true, true}, --Heavy Attack (Fire), full
	[18405] = {true, false, true, true}, --Heavy Attack (Frost)
	[18406] = {true, false, true, true}, --Heavy Attack (Frost), full
	[18396] = {false, true, true, true}, --Heavy Attack (Shock)
	[86523] = {false, true, false, true}, --Icy Rage
	[16165] = {true, false, true, true}, --Light Attack (Fire)
	[16277] = {true, false, true, true}, --Light Attack (Frost)
	[18350] = {true, false, true, true}, --Light Attack (Shock)
	[38993] = {true, false, false, true}, --Shock Clench
	[40991] = {true, false, false, true}, --Shock Clench
	[41016] = {true, false, false, true}, --Shock Clench
	[62733] = {false, true, false, true}, --Shock Clench dot
	[62733] = {false, true, false, true}, --Shock Clench dot
	[62742] = {false, true, false, true}, --Shock Clench dot
	[62734] = {false, true, false, true}, --Shock Clench Explosion
	[62734] = {false, true, false, true}, --Shock Clench Explosion
	[62743] = {false, true, false, true}, --Shock Clench Explosion
	[19277] = {true, false, false, true}, --Shock Pulse
	[41054] = {true, false, false, true}, --Shock Reach
	[62768] = {false, true, false, true}, --Shock Reach dot
	[42981] = {true, false, false, true}, --Shock Ring
	[29089] = {true, false, false, true}, --Shock Touch
	[40962] = {true, false, false, true}, --Shock Touch
	[40970] = {true, false, false, true}, --Shock Touch
	[62722] = {false, true, false, true}, --Shock Touch dot
	[62729] = {false, true, false, true}, --Shock Touch dot
	[62731] = {false, true, false, true}, --Shock Touch dot
	[43001] = {true, false, false, true}, --Storm Pulsar
	[86529] = {false, true, false, true}, --Thunderous Rage
	[45505] = {true, false, false, true}, --Tri Focus (Shock)
	[62835] = {false, true, false, true}, --Unstable Wall of Fire
	[62831] = {true, false, false, true}, --Unstable Wall of Fire Explosion
	[62863] = {false, true, false, true}, --Unstable Wall of Frost
	[62857] = {true, false, false, true}, --Unstable Wall of Frost Explosion
	[62890] = {false, true, false, true}, --Unstable Wall of Storms
	[62889] = {true, false, false, true}, --Unstable Wall of Storms Explosion
	[23898] = {true, false, false, true}, --Burning Embers
	[44376] = {false, true, false, true}, --Burning Embers dot
	[32123] = {true, false, false, true}, --Burning Talons
	[32125] = {false, true, false, true}, --Burning Talons (dot)
	[32135] = {true, false, false, true}, --Choking Talons
	[34794] = {false, true, false, true}, --Cinder Storm
	[33853] = {false, true, false, true}, --Corrosive Armor
	[33715] = {true, false, false, true}, --Deep Breath (1st)
	[33717] = {true, false, false, true}, --Deep Breath (2nd)
	[33732] = {true, false, false, true}, --Draw Essence (1st)
	[33734] = {true, false, false, true}, --Draw Essence (2nd)
	[32229] = {true, false, false, true}, --Empowering Chains
	[34048] = {true, false, false, true}, --Engulfing Flames
	[34050] = {false, true, false, true}, --Engulfing Flames dot
	[33820] = {false, true, false, true}, --Eruption
	[33817] = {false, true, false, true}, --Eruption (dot)
	[32716] = {true, false, false, true}, --Ferocious Leap
	[23924] = {true, false, false, true}, --Flame Lash
	[61958] = {true, false, false, true}, --Flames of Oblivion
	[33882] = {true, false, false, true}, --Fragmented Shield
	[33842] = {false, true, false, true}, --Magma Shell
	[23819] = {true, false, false, true}, --Molten Whip
	[34039] = {true, false, false, true}, --Noxious Breath
	[34041] = {false, true, false, true}, --Noxious Breath (dot)
	[32199] = {true, false, false, true}, --Obsidian Shard
	[54937] = {true, false, false, true}, --Petrify
	[23919] = {true, false, false, true}, --Power Lash
	[23919] = {true, false, false, true}, --Power Lash
	[34341] = {true, false, false, true}, --Shattering Rocks
	[33988] = {false, true, false, true}, --Shifting Standard
	[33993] = {false, true, false, true}, --Shifting Standard
	[34022] = {false, true, false, true}, --Standard of Might
	[32205] = {true, false, false, true}, --Stone Giant
	[33669] = {true, false, false, true}, --Take Flight
	[23778] = {true, false, false, true}, --Unrelenting Grip
	[23915] = {true, false, false, true}, --Venomous Claw
	[44372] = {false, true, false, true}, --Venomous Claw
	[23844] = {false, true, false, true}, --Volatile Armor
	[62541] = {false, true, false, true}, --Blade Cloak
	[62569] = {false, true, false, true}, --Blade Cloak
	[40687] = {true, false, false, true}, --Blood Craze
	[40688] = {true, false, false, true}, --Blood Craze
	[40690] = {false, true, false, true}, --Blood Craze Bleed
	[40599] = {false, true, false, true}, --Bloodthirst
	[40628] = {true, false, false, true}, --Flying Blade
	[18622] = {true, false, true, true}, --Heavy Attack (DW main), full
	[17170] = {true, false, true, true}, --Heavy Attack (DW)
	[17169] = {true, false, true, true}, --Heavy Attack (DW), full
	[16499] = {true, false, true, true}, --Light Attack (DW)
	[40590] = {false, true, false, true}, --Rapid Strikes
	[86396] = {false, true, false, true}, --Rend
	[40675] = {true, false, false, true}, --Rending Slashes
	[40676] = {true, false, false, true}, --Rending Slashes
	[40678] = {false, true, false, true}, --Rending Slashes Bleed
	[40619] = {true, false, false, true}, --Shrouded Daggers
	[68840] = {true, false, false, true}, --Shrouded Daggers (2nd)
	[68841] = {true, false, false, true}, --Shrouded Daggers (3rd)
	[40744] = {true, false, false, true}, --Steel Tornado
	[86414] = {false, true, false, true}, --Thrive in Chaos
	[40731] = {true, false, false, true}, --Whirling Blades
	[42598] = {true, false, false, true}, --Dawnbreaker of Smiting
	[62317] = {false, true, false, true}, --Dawnbreaker of Smiting dot
	[42586] = {true, false, false, true}, --Flawless Dawnbreaker
	[62313] = {false, true, false, true}, --Flawless Dawnbreaker dot
	[42775] = {false, true, false, true}, --Lightweight Beast Trap
	[42774] = {false, true, false, true}, --Lightweight Beast Trap dot
	[42751] = {false, true, false, true}, --Rearming Trap
	[42756] = {false, true, false, true}, --Rearming Trap 2
	[42754] = {false, true, false, true}, --Rearming Trap dot
	[42696] = {true, false, false, true}, --Silver Leash
	[42671] = {true, false, false, true}, --Silver Shards
	[46743] = {true, false, false, true}, --Absorb Magicka
	[46746] = {true, false, false, true}, --Absorb Stamina
	[17904] = {true, false, false, true}, --Befouled Weapon
	[17899] = {true, false, false, true}, --Charged Weapon
	[46749] = {true, false, false, true}, --Damage Health
	[93307] = {false, false, false, false}, --Defiler
	[17895] = {true, false, false, true}, --Fiery Weapon
	[17897] = {true, false, false, true}, --Frozen Weapon
	[84502] = {false, true, false, false}, --Grothdarr
	[80561] = {false, true, false, false}, --Iceheart
	[80525] = {false, true, false, false}, --Illambris (fire)
	[80526] = {false, true, false, false}, --Illambris (lightning)
	[83409] = {true, false, false, false}, --Infernal Guardian
	[80565] = {false, true, false, false}, --Kra'gh
	[28919] = {true, false, false, true}, --Life Drain
	[59498] = {false, true, false, false}, --Mephala's Web
	[59593] = {true, false, false, false}, --Nerien'eth
	[17902] = {true, false, false, true}, --Poisoned Weapon
	[40337] = {true, false, false, true}, --Prismatic Weapon
	[80606] = {true, false, false, false}, --Selene
	[80544] = {true, false, false, false}, --Sellistrix
	[80980] = {false, false, false, false}, --Shadowrend (base attack)
	[80989] = {false, false, false, false}, --Shadowrend (tail sweep)
	[80522] = {false, true, false, false}, --Stormfist (lightning)
	[80521] = {true, false, false, false}, --Stormfist (physical)
	[80865] = {true, false, false, false}, --Tremorscale
	[61273] = {true, false, false, false}, --Valkyn Skoria (splash)
	[59596] = {true, false, false, false}, --Valkyn Skoria (target hit)
	[80490] = {true, false, false, false}, --Velidreth
	[43036] = {false, true, false, true}, --Degeneration
	[63469] = {true, false, false, true}, --Ice Comet
	[63466] = {false, true, false, true}, --Ice Comet dot
	[42355] = {true, false, false, true}, --Scalding Rune
	[42351] = {false, true, false, true}, --Scalding Rune dot
	[63487] = {true, false, false, true}, --Shooting Star
	[63484] = {false, true, false, true}, --Shooting Star (dot)
	[43041] = {false, true, false, true}, --Structured Entropy
	[42333] = {true, false, false, true}, --Volcanic Rune
	[35901] = {true, false, false, true}, --Ambush
	[62130] = {true, false, false, true}, --Assassins Scourge
	[62138] = {true, false, false, true}, --Assassins Will
	[36244] = {true, false, false, true}, --Concealed Weapon
	[33219] = {false, false, false, false}, --Corrode (pet)
	[51556] = {false, false, false, false}, --Corrode (pet)
	[37919] = {true, false, false, true}, --Crippling Grasp
	[37916] = {false, true, false, true}, --Crippling Grasp dot
	[37890] = {false, true, false, true}, --Debilitate
	[35941] = {true, false, false, true}, --Funnel Health
	[35596] = {true, false, false, true}, --Impale
	[37532] = {true, false, false, true}, --Incapacitating Strike
	[35590] = {true, false, false, true}, --Killers Blade
	[35884] = {true, false, false, true}, --Lotus Fan
	[35885] = {false, true, false, true}, --Lotus Fan dot
	[36145] = {true, false, false, true}, --Malefic Wreath
	[37937] = {true, false, false, true}, --Power Extraction
	[36130] = {false, true, false, true}, --Prolonged Suffering
	[64022] = {false, true, false, true}, --Refreshing Path
	[37950] = {true, false, false, true}, --Sap Essence
	[37545] = {true, false, false, true}, --Soul Harvest
	[36211] = {true, false, false, true}, --Soul Tether
	[36208] = {false, true, false, true}, --Soul Tether dot
	[35949] = {true, false, false, true}, --Swallow Soul
	[37798] = {true, false, false, true}, --Twisting Path
	[37717] = {false, true, false, true}, --Veil of Blades
	[21929] = {false, true, false, true}, --Poisoned
	[16212] = {false, true, true, true}, --Heavy Attack (Resto)
	[16145] = {true, false, true, true}, --Light Attack (Resto)
	[23428] = {false, false, false, false}, --Atronach Zap (pet)
	[62187] = {false, true, false, true}, --Boundless Storm
	[29528] = {false, false, false, false}, --Claw (pet)
	[47560] = {true, false, false, true}, --Crystal Blast
	[47569] = {true, false, false, true}, --Crystal Fragments
	[29983] = {false, true, false, true}, --Daedric Minefield
	[30512] = {true, false, false, true}, --Daedric Prey
	[44514] = {true, false, false, true}, --Daedric Prey (AoE)
	[29948] = {false, true, false, true}, --Daedric Tomb
	[30343] = {true, false, false, true}, --Endless Fury
	[77266] = {false, true, false, true}, --Familiar Damage Pulse
	[27850] = {false, false, false, false}, --Familiar Melee (pet)
	[30578] = {true, false, false, true}, --Greater Storm Atronach
	[30524] = {true, false, false, true}, --Haunting Curse
	[30245] = {false, true, false, true}, --Hurricane
	[45194] = {true, false, false, true}, --Implosion (lightning)
	[82806] = {true, false, false, true}, --Implosion (physical)
	[30303] = {false, true, false, true}, --Lightning Flood
	[30288] = {false, true, false, true}, --Liquid Lightning
	[30331] = {true, false, false, true}, --Mages Wrath
	[30334] = {true, false, false, true}, --Mages' Wrath Explosion
	[24798] = {false, true, false, true}, --Overload Heavy Attack
	[24792] = {true, false, false, true}, --Overload Light Attack
	[24811] = {false, true, false, true}, --Power Overload Heavy Attack
	[30096] = {true, false, false, true}, --Shattering Prison
	[30217] = {true, false, false, true}, --Streak
	[30556] = {true, false, false, true}, --Summon Charged Atronach
	[80438] = {false, true, false, true}, --Suppression Field
	[29529] = {false, false, false, false}, --Tail spike (pet)
	[24617] = {false, false, false, false}, --Zap (pet)
	[43083] = {false, true, false, true}, --Consuming Trap
	[43109] = {false, true, false, true}, --Shatter Soul
	[43099] = {false, true, false, true}, --Soul Assault
	[43067] = {false, true, false, true}, --Soul Splitting Trap
	[26983] = {true, false, false, true}, --Aurora Javelin
	[26992] = {true, false, false, true}, --Binding Javelin
	[27200] = {false, true, false, true}, --Biting Jabs
	[27168] = {true, false, false, true}, --Blazing Spear
	[27169] = {false, true, false, true}, --Blazing Spear Pulse
	[80170] = {true, false, false, true}, --Burning Light
	[80170] = {true, false, false, true}, --Burning Light
	[23788] = {true, false, false, true}, --Crescent Sweep
	[24147] = {true, false, false, true}, --Dark Flare
	[23794] = {true, false, false, true}, --Empowering Sweep
	[23727] = {true, false, false, true}, --Explosive Charge
	[27123] = {false, true, false, true}, --Luminous Shards
	[95965] = {false, true, false, true}, --Luninous Shards
	[89716] = {true, false, false, true}, --Power of the Light (1st)
	[27594] = {false, false, false, false}, --Power of the Light (2nd)
	[27209] = {false, true, false, true}, --Puncturing Sweep
	[44439] = {false, true, false, true}, --Puncturing Sweep (new in 3.3.)
	[89684] = {true, false, false, true}, --Purifying Light (1st)
	[27565] = {false, false, false, false}, --Purifying Light (2nd)
	[62604] = {false, true, false, true}, --Radial Sweep (dot)
	[62612] = {false, true, false, true}, --Radial Sweep (dot)
	[63960] = {false, true, false, true}, --Radiant Destruction
	[63964] = {false, true, false, true}, --Radiant Destruction
	[27514] = {true, false, false, true}, --Radiant Ward
	[27514] = {true, false, false, true}, --Radiant Ward
	[24195] = {true, false, false, true}, --Reflective Light
	[24197] = {false, true, false, true}, --Reflective Light (dot)
	[80176] = {false, true, false, true}, --Ritual of Retribution
	[24157] = {true, false, false, true}, --Solar Barrage
	[24323] = {false, true, false, true}, --Solar Disturbance
	[24304] = {false, true, false, true}, --Solar Prison
	[23872] = {true, false, false, true}, --Toppling Charge
	[68757] = {true, false, false, true}, --Total Dark
	[27312] = {true, false, false, true}, --Unstable Core
	[24180] = {true, false, false, true}, --Vampires Bane
	[24182] = {false, true, false, true}, --Vampires Bane (dot)
	[86295] = {true, false, false, true}, --Berserker Rage
	[39769] = {true, false, false, true}, --Brawler
	[39770] = {false, true, false, true}, --Brawler Bleed
	[39754] = {true, false, false, true}, --Carve
	[39755] = {false, true, false, true}, --Carve Bleed
	[39824] = {true, false, false, true}, --Critical Rush
	[39964] = {true, false, false, true}, --Dizzying Swing
	[39957] = {true, false, false, true}, --Executioner
	[45445] = {true, false, false, true}, --Forceful
	[17162] = {true, false, true, true}, --Heavy Attack (2H)
	[17163] = {true, false, true, true}, --Heavy Attack (2H), full
	[16037] = {true, false, true, true}, --Light Attack (2H)
	[86284] = {true, false, false, true}, --Onslaught
	[39942] = {true, false, false, true}, --Reverse Slice
	[39945] = {true, false, false, true}, --Reverse Slice (Splash)
	[39811] = {true, false, false, true}, --Stampede
	[40008] = {true, false, false, true}, --Wrecking Blow
	[38956] = {false, true, false, true}, --Accelerating Drain
	[38968] = {false, true, false, true}, --Baleful Mist
	[41923] = {false, true, false, true}, --Bat Swarm
	[41931] = {false, true, false, true}, --Clouding Swarm
	[41941] = {false, true, false, true}, --Devouring Swarm
	[41866] = {false, true, false, true}, --Drain Essence
	[41902] = {false, true, false, true}, --Invigorating Drain
	[94047] = {false, true, false, true}, --Arctic Blast
	[89128] = {true, false, false, true}, --Crushing Swipe (pet)
	[89220] = {true, false, false, true}, --Crushing Swipe (pet)
	[86002] = {true, false, false, true}, --Cutting Dive
	[94424] = {true, false, false, true}, --Deep Fissure
	[86030] = {true, false, false, true}, --Fetcher Infection
	[94090] = {false, true, false, true}, --Gripping Shards
	[86034] = {true, false, false, true}, --Growing Swarm
	[92160] = {true, false, false, true}, --Guardian Savagery
	[91974] = {true, false, false, true}, --Guardian's Wrath (pet)
	[94204] = {false, true, false, true}, --Northern Storm
	[94221] = {true, false, false, true}, --Permafrost
	[93619] = {true, false, false, true}, --Screaming Cliff Racer
	[93794] = {true, false, false, true}, --Subterranean Assault
	[89135] = {true, false, false, true}, --Swipe (pet)
	[89219] = {true, false, false, true}, --Swipe Wild Guardian (pet)
	[88802] = {false, true, false, true}, --Winters Revenge
	[79025] = {true, false, false, true}, --Creeping Ravage Health
	[79707] = {true, false, false, true}, --Ravage Health
	[21925] = {true, false, false, true}, --Diseased
}

local IsMagickaAbility = {
	[DAMAGE_TYPE_COLD] = true,
	[DAMAGE_TYPE_FIRE] = true,
	[DAMAGE_TYPE_SHOCK] = true,
	[DAMAGE_TYPE_MAGIC] = true,
	[DAMAGE_TYPE_PHYSICAL] = false,
	[DAMAGE_TYPE_POISON] = false,
	[DAMAGE_TYPE_DISEASE] = false,
}

local function ImportCMXData()

	if CMX == nil or CMX.GetAbilityStats == nil then 
	
		Print("To import data you need to install/update Combat Metrics!") 
		return 
		
	end

	local fightData = CMX.GetAbilityStats()
	
	if fightData == nil then return end 
	
	local fight = fightData[1]
	
	if fight == nil then return end
	
	local selection = fightData[2] or fight.calculated
	local ratios = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	local total = selection.damageOutTotal
	
	local calcstats = fight.calculated.stats.dmgavg
	
	local spellCritRatio = GetCriticalStrikeChance(calcstats.avgspellcrit, true) / 100
	local weaponCritRatio = GetCriticalStrikeChance(calcstats.avgweaponcrit, true) / 100
	local spellCritBonus = calcstats.avgspellcritbonus
	local weaponCritBonus = calcstats.avgweaponcritbonus
	
	local spellCrits = 0
	local spellCritDamage = 0
	local spellHits = 0
	local spellDamageTotal = 0
	
	local weaponCrits = 0
	local weaponCritDamage = 0
	local weaponHits = 0
	local weaponDamageTotal = 0
	
	for id, ability in pairs(selection.damageOut) do
		
		local abilityCPData = AbilityData[id]
		local abilityTotal = ability.damageOutTotal

		local ismagic = IsMagickaAbility[ability.damageType]
		local key = (ismagic and 1) or (ismagic == false and 6) or nil
		
		if key ~= nil then 
		
			ratios[key] = (ratios[key] or 0) + abilityTotal/total*100
			
			if abilityCPData ~= nil then
			
				if ismagic and abilityCPData[4] then
			
					spellCrits = spellCrits + ability.hitsOutCritical
					spellCritDamage = spellCritDamage + ability.damageOutCritical
					
					spellHits = spellHits + ability.hitsOutTotal
					spellDamageTotal = spellDamageTotal + ability.damageOutTotal
					
				elseif ismagic == false and abilityCPData[4] then 
				
					weaponCrits = weaponCrits + ability.hitsOutCritical
					weaponCritDamage = weaponCritDamage + ability.damageOutCritical
				
					weaponHits = weaponHits + ability.hitsOutTotal
					weaponDamageTotal = weaponDamageTotal + ability.damageOutTotal
					
				end
			
				if abilityCPData[1] and abilityCPData[3] then 
				
					ratios[3+key] = ratios[3+key] + abilityTotal/total*100
				
				elseif abilityCPData[1] then 
				
					ratios[1+key] = ratios[1+key] + abilityTotal/total*100
					
				elseif abilityCPData[2] and abilityCPData[3] and ismagic then 
				
					ratios[11] = ratios[11] + abilityTotal/total*100
				
				elseif abilityCPData[2] then 
					
					ratios[2+key] = ratios[2+key] + abilityTotal/total*100
				
				end
				
				if abilityCPData[4] then
				
					ratios[4+key] = ratios[4+key] + abilityTotal/total*100
				
				end

			else
		
				local name = GetAbilityName(id)
				Print("(%d) %s - No Data for this Ability!", id, name)
			end
		end
	end
	
	SetRatios(ratios)
	
	spellCritRatio = spellCritRatio or (spellCrits / math.max(spellHits, 1))
	local spellCritDamageRatio = spellCritDamage/math.max(spellDamageTotal, 1)
	spellCritBonus = spellCritBonus or (spellCritRatio > 0 and spellCritDamageRatio > 0 and 100 * spellCritDamageRatio * (1 - spellCritRatio) / ((1 - spellCritDamageRatio) * spellCritRatio) - 1 or 0) * 100
	
	weaponCritRatio = weaponCritRatio or (weaponCrits / math.max(weaponHits, 1))
	local weaponCritDamageRatio = weaponCritDamage / math.max(weaponDamageTotal,1)
	weaponCritBonus = weaponCritBonus or (weaponCritRatio > 0 and weaponCritDamageRatio > 0 and 100 * weaponCritDamageRatio * (1 - weaponCritRatio)/((1 - weaponCritDamageRatio) * weaponCritRatio) - 1 or 0) * 100
	
	local stats = {CPdefault, 20, spellCritRatio*100, spellCritBonus, nil, weaponCritRatio*100, weaponCritBonus, nil}
	
	SetStats(stats)
	
	UpdateCP(fight.CP)
	
	CST.ApplyCurrentStars = true
	CST.ApplyCurrentStarsCheckBox:SetHidden(false)
end

CST.Import = ImportCMXData

local function AccountForPreviousCP(stats, ratios, targetStats, oldCP)

	if not (stats and ratios and oldCP) then return end 

	local cpfactors = {}

	for abilityId, value in pairs(oldCP) do
		
		cpfactors[abilityId] = GetCPValue(abilityId, value, true)
		
	end 
	
	local oldSpellCritMod = 1 + ratios[5]/100 * stats[3]/100 * (stats[4]/100 + cpfactors[61680])
	local oldWeaponCritMod = 1 + ratios[10]/100 * stats[6]/100 * (stats[7]/100 + cpfactors[59105])
	
	local oldSpellPenMod = (1 - math.max(targetStats[1] - stats[5] - cpfactors[61555],0) / 50000)
	local oldWeaponPenMod = (1 - math.max(targetStats[1] - stats[8] - cpfactors[61546],0) / 50000)
	
	local oldSpellMod = oldSpellCritMod * oldSpellPenMod
	local oldWeaponMod = oldWeaponCritMod * oldWeaponPenMod
	
	stats[4] = stats[4] - cpfactors[61680]*100
	stats[5] = stats[5] - cpfactors[61555]
	stats[7] = stats[7] - cpfactors[59105]*100
	stats[8] = stats[8] - cpfactors[61546]
	
	local spellCritMod = 1 + ratios[5]/100 * stats[3]/100 * (stats[4]/100 + cpfactors[61680])
	local weaponCritMod = 1 + ratios[10]/100 * stats[6]/100 * (stats[7]/100 + cpfactors[59105])
	
	local spellPenMod = (1 - math.max(targetStats[1] - stats[5] - cpfactors[61555],0) / 50000)
	local weaponPenMod = (1 - math.max(targetStats[1] - stats[8] - cpfactors[61546],0) / 50000)
	
	local SpellMod = spellCritMod * spellPenMod
	local WeaponMod = weaponCritMod * weaponPenMod

	local oldMagicRatio = ratios[1]
	local oldWeaponRatio = ratios[6]
	
	-- ratios[1] is here temporarily used a
	
	ratios[1] = (ratios[1] - ratios[2] - ratios[3] - ratios[4] - ratios[11])/ (1 + cpfactors[63848]) * SpellMod / oldSpellMod 
	ratios[2] = ratios[2] / (1 + cpfactors[63848] + cpfactors[92134]) * SpellMod / oldSpellMod
	ratios[3] = ratios[3] / (1 + cpfactors[63848] + cpfactors[63847]) * SpellMod / oldSpellMod
	ratios[4] = ratios[4] / (1 + cpfactors[63848] + cpfactors[92134] + cpfactors[60503]) * SpellMod / oldSpellMod
	ratios[11] = ratios[11] / (1 + cpfactors[63848] + cpfactors[63847] + cpfactors[60503]) * SpellMod / oldSpellMod

	ratios[6] = (ratios[6] - ratios[7] - ratios[8] - ratios[9]) / (1 + cpfactors[63868]) * WeaponMod / oldWeaponMod 
	ratios[7] = ratios[7] / (1 + cpfactors[63868] + cpfactors[92134]) * WeaponMod / oldWeaponMod
	ratios[8] = ratios[8] / (1 + cpfactors[63868] + cpfactors[63847]) * WeaponMod / oldWeaponMod
	ratios[9] = ratios[9] / (1 + cpfactors[63868] + cpfactors[92134] + cpfactors[92424]) * WeaponMod / oldWeaponMod

	ratios[5] = oldMagicRatio == 0 and 0 or ratios[5] * (ratios[1] + ratios[2] + ratios[3] + ratios[4] + ratios[11]) / oldMagicRatio
	ratios[10] = oldWeaponRatio == 0 and 0 or ratios[10] * (ratios[6] + ratios[7] + ratios[8] + ratios[9]) / oldWeaponRatio
	
	local totalkeys = {1,2,3,4,6,7,8,9,11}
	
	local sumratios = 0
	
	for _,i in ipairs(totalkeys) do 
		
		sumratios = sumratios + ratios[i]
	
	end
	
	for i=1,11 do 
		
		ratios[i] = ratios[i]*100 / sumratios
		
	end
	
	ratios[1] = ratios[1] + ratios[2] + ratios[3] + ratios[4] + ratios[11]
	ratios[6] = ratios[6] + ratios[7] + ratios[8] + ratios[9]
	
end

function CST.Calculate()

	local stats = GetCurrentStats()
	local ratios = GetCurrentRatios()
	local targetStats = GetCurrentTargetStats()
	local currentCP, minCP, maxCP = GetCurrentCP()
	
	if CST.ApplyCurrentStars then AccountForPreviousCP(stats, ratios, targetStats, currentCP) end
	
	local totalMinCP = 1
	local totalMaxCP = 0

	local calcCP = {}
	ZO_DeepTableCopy(minCP, calcCP)
	
	for id, value in pairs(minCP) do 
	
		totalMinCP = totalMinCP + value
		totalMaxCP = totalMaxCP + maxCP[id]
		
	end
	
	ZO_DeepTableCopy(calcCP, minCP)
	
	local oldfactors = {GetDamageFactor(stats, ratios, targetStats, currentCP, true)}
	
	Print("Current factor: %.6f (CP: %.6f, Crit: %.6f, Pen: %.6f)", unpack(oldfactors))
	
	CST.Before:SetText(string.format("Before: f = %.5f", oldfactors[1]))
	
	local totalCP = stats[1]
	if totalMinCP > totalCP then return end
	
	local maxCPValue = math.min(totalMaxCP, totalCP)
	
	local grad = {}
	local maxinc = 0
	local totalmod
	local descfactors
	
	-- Gradient Descent
	
	for i=totalMinCP,maxCPValue do
	
		local oldmaxinc = maxinc
		local maxKey = 0
		
		for abilityId, value in pairs(calcCP) do
		
			local cptemp = {}
			
			ZO_DeepTableCopy(calcCP, cptemp)
			
			cptemp[abilityId] = value + 1
			
			local factors = {GetDamageFactor(stats, ratios, targetStats, cptemp, false)}
			totalmod = factors[1]
			
			if i == maxCP then grad[abilityId] = totalmod-oldmaxinc end
			
			if totalmod >= maxinc then
				maxinc = totalmod
				maxKey = abilityId
				descfactors = factors
			end		
		end
		
		if maxKey == 0 then 
		
			Print("Calculation Error!")
			return 
		end
		
		calcCP[maxKey] = calcCP[maxKey] + 1
	end
	
	Print("Descent raw factor: %.6f (CP: %.6f, Crit: %.6f, Pen: %.6f)", unpack(descfactors))
	
	-- Scan nearby JumpPoints
	
	local cpnear = {}	

	local JumpPointTable = {}
	local JPAbilityTable = {}
	local noJPAbilityTable = {}
	local IgnoredAbilityTable = {}
	
	for id, value in pairs(CPData) do

		JumpPointTable[id] = JumpPoints[value.type]
		
		if value.type == STARTYPE_5280 and ((value.attribute == ATTRIBUTE_MAGICKA and ratios[1]>0) or (value.attribute == ATTRIBUTE_STAMINA and ratios[6]>0) or value.attribute == ATTRIBUTE_NONE) then 
		
			noJPAbilityTable[#noJPAbilityTable+1] = id 
			
		elseif (value.attribute == ATTRIBUTE_MAGICKA and ratios[1]>0) or (value.attribute == ATTRIBUTE_STAMINA and ratios[6]>0) or value.attribute == ATTRIBUTE_NONE then
		
			JPAbilityTable[#JPAbilityTable+1] = id
			
		else
		
			IgnoredAbilityTable[#IgnoredAbilityTable+1] = id
			
		end
		
	end
	
	for id,jumpPoints in pairs(JumpPointTable) do

		local mindist = 100
		
		cpnear[id]={minCP[id], math.floor((minCP[id] + maxCP[id]) / 2), maxCP[id]} -- in case no jumppoint is between min and max
		
		for i,jp in ipairs(jumpPoints) do

			if math.abs(jp - calcCP[id]) < mindist and jp <= maxCP[id] and jp >= minCP[id] then
				mindist = math.abs(jp - calcCP[id])
				
				local cpminus = jumpPoints[i-1] or 0
				local cpnearest = jp
				local cpplus = jumpPoints[i+1] or 100
				
				local low = cpminus >= minCP[id] and cpminus or cpnearest
				local high = cpplus <= maxCP[id] and cpplus or cpnearest
				
				cpnear[id]={low, cpnearest, high}
			end			
		end
		
	end
	
	local descfactors = {GetDamageFactor(stats, ratios, targetStats, calcCP, true)}
	local maxincjp = 0
	
	Print("Descent lowered factor: %.6f (CP: %.6f, Crit: %.6f, Pen: %.6f)", unpack(descfactors))
	
	local iterations = math.pow(3,#JPAbilityTable) - 1
	
	local div = {}
	
	for i=1,#JPAbilityTable do 
	
		div[i] = math.pow(3,i-1)

	end
	
	-- Check all nearby JumpPoints
	
	for i = 0,iterations do

		local cptemp = {}
		
		local totalCP = 0
		
		for k, id in ipairs(JPAbilityTable) do
			
			local value = cpnear[id][math.floor(i/div[k])%3+1]
			cptemp[id] = value
			totalCP = totalCP + value
			
		end
			
		if totalCP <= maxCPValue then 
		
			for k, id in ipairs(IgnoredAbilityTable) do
				
				cptemp[id] = 0
			
			end
			
			for k, id in ipairs(noJPAbilityTable) do
				
				cptemp[id] = 0
			
			end
			
			local maxincjp2 = GetDamageFactor(stats, ratios, targetStats, cptemp, true)
			
			local CPremain = maxCPValue - totalCP
			
			for i=totalCP,maxCPValue-1 do

				local maxKey = noJPAbilityTable[1]
				
				for i, abilityId in pairs(noJPAbilityTable) do
				
					local cptemp2 = {}
					
					ZO_DeepTableCopy(cptemp, cptemp2)
					
					cptemp2[abilityId] = cptemp2[abilityId] + 1
					
					totalmod = GetDamageFactor(stats, ratios, targetStats, cptemp2, true)
					
					if totalmod >= maxincjp2 then
						maxincjp2 = totalmod
						maxKey = abilityId
					end		
				end

				cptemp[maxKey] = cptemp[maxKey] + 1
			end

			if maxincjp2 >= maxincjp then
			
				maxincjp = maxincjp2				
				calcCP = cptemp
			end	
		end
	end
	
	SetNewStarValues(calcCP)
	
	local newfactors = {GetDamageFactor(stats, ratios, targetStats, calcCP, true)}
	Print("Final factor: %.6f (CP: %.6f, Crit: %.6f, Pen: %.6f)", unpack(newfactors))
		
	
	CST.After:SetText(string.format("New: f = %.5f", newfactors[1]))
	
	local resultcolor = { 1,.5,.5,1}
	
	if newfactors[1]>oldfactors[1] then resultcolor = { .5,1,.5,1} end
	
	CST.After:SetColor(unpack(resultcolor))
end

local svdefaults = {
	["window"]={x=150*dx,y=150*dx,height=zo_round(25/dx)*dx,width=zo_round(300/dx)*dx},
}

function CST:Initialize(event, addon)

	if addon ~= self.name then return end --Only run if this addon has been loaded
 
	-- load saved variables
 
	db = ZO_SavedVars:NewAccountWide(self.name.."_Save", 7, nil, svdefaults) -- taken from Aynatirs guide at http://www.esoui.com/forums/showthread.php?t=6442
	
	if db.accountwide == false then
		db = ZO_SavedVars:NewCharacterIdSettings(self.name.."_Save", 7, nil, svdefaults)
		db.accountwide = false
	end
	
	local name = self.name
	
	em:UnregisterForEvent(name.."load", EVENT_ADD_ON_LOADED)
		
	local window = Constellations_TLW	
	
	if (db.window) then
		window:ClearAnchors()
		window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, db.window.x, db.window.y)
	end
	
	window:SetHandler("OnMoveStop", function(control)
		local x, y = control:GetScreenRect()
		x = zo_round(x/dx)*dx
		y = zo_round(y/dx)*dx
		db.window.x=x
		db.window.y=y
		window:ClearAnchors()
		window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, db.window.x, db.window.y)
	end)
	
	local fragment = ZO_HUDFadeSceneFragment:New(window)
	CHAMPION_PERKS_SCENE:AddFragment(fragment)
	
	if CMX then SCENE_MANAGER:GetScene("CMX_REPORT_SCENE"):AddFragment(fragment) end
	
	CST.ApplyCurrentStars = true

end

em:RegisterForEvent(CST.name.."load", EVENT_ADD_ON_LOADED, function(...) CST:Initialize(...) end)