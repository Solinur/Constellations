local em = GetEventManager()
local _
local db
local dx = 1 / GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE) --Get UI Scale to draw thin lines correctly
local pendata = {}

-- Addon Namespace
Constellations = Constellations or {}
local CST = Constellations
CST.name 		= "Constellations"
CST.version 	= "0.4.17"
CST.debug = false or GetDisplayName() == "@Solinur"

local function Print(message, ...)

	if CST.debug == false then return end
	df("[%s] %s", CST.name, message:format(...))

end

local spellcrit = GetCriticalStrikeChance(GetPlayerStat(STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP), true)
local weaponcrit = GetCriticalStrikeChance(GetPlayerStat(STAT_CRITICAL_STRIKE, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP), true)
local CPdefault = math.min(GetNumSpentChampionPoints(ATTRIBUTE_MAGICKA) + GetNumUnspentChampionPoints(ATTRIBUTE_MAGICKA), GetMaxSpendableChampionPointsInAttribute())

local CST_DEFAULT_RESIST = 18200

local sliderDefaults = {{CPdefault, 20, spellcrit, 50, CST_DEFAULT_RESIST, weaponcrit, 50, CST_DEFAULT_RESIST}, {100, 50, 40, 10, 100, 0, 0, 0, 0, 0, 0}, {CST_DEFAULT_RESIST}}
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

		if child:GetType() == CT_CONTROL then

			local id = child.id

			local label = child:GetNamedChild("Label")
			child.label = label

			local text = GetString(CategoryString, id)
			local colors = ZO_ColorDef:New(GetString(child.color))

			label:SetText(text)
			label:SetColor(colors.r, colors.g, colors.b, colors.a)

			local tooltipText = GetString(CategoryTTString, id)

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

			slider:SetValue(defaults[id])

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

		if child:GetType() == CT_CONTROL and discipline ~= nil and skillId ~= nil then

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

		elseif child:GetType() == CT_LABEL and discipline ~= nil then

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

		if child:GetType() == CT_CONTROL and abilityId ~= nil then

			local newvalue = child:GetNamedChild("Value2")
			newvalue:SetText(tostring(CPValues[abilityId]))

		end
	end
end

function CST.SetBoxValue(self)

	local text = self:GetText()

	local i, j = text:find("%d+[,%.]?%d*")

	local slider = self:GetParent():GetNamedChild("Slider")

	local cleantext = slider:GetValue()

	if i and j then

		cleantext = text:sub(i, j):gsub(",", "%.")	-- make sure number conversion works

	end

	local value = tonumber(cleantext)

	local min, max = slider:GetMinMax()
	local form = max > 150 and "%.0f" or "%.1f%%"

	self:SetText(string.format(form, value))
	slider:SetValue(value)

end

function CST.SetSliderValue(self, value)

	local valueControl = self:GetParent():GetNamedChild("Value")

	local min, max = self:GetMinMax()
	local form = max > 150 and "%.0f" or "%.1f%%"

	valueControl:SetText(string.format(form, value))

end



function CST.ApplyCurrentStarsButton(control)

	PlaySound("Click")

	CST.ApplyCurrentStars = not CST.ApplyCurrentStars

	local crossTexture = control:GetNamedChild("Checked")

	crossTexture:SetHidden(not CST.ApplyCurrentStars)

end

-- Stat constants

local STATS_TOTAL_MAGE_CP = 1
local STATS_DAMAGE_DONE = 2
local STATS_SPELL_CRIT_CHANCE = 3
local STATS_SPELL_CRIT_DAMAGE = 4
local STATS_SPELL_PEN = 5
local STATS_WEAPON_CRIT_CHANCE = 6
local STATS_WEAPON_CRIT_DAMAGE = 7
local STATS_WEAPON_PEN = 8

local function GetCurrentStats()

	local stats = {}

	for i = 1, statControl:GetNumChildren() do

		local child = statControl:GetChild(i)
		local slider = child:GetNamedChild("Slider")
		local id = child.id

		if child:GetType() == CT_CONTROL and id then stats[id] = zo_roundToNearest(slider:GetValue(), 0.1) end
	end

	return stats
end

local function SetStats(stats)

	for i = 1, statControl:GetNumChildren() do

		local child = statControl:GetChild(i)
		local slider = child:GetNamedChild("Slider")
		local id = child.id

		if child:GetType() == CT_CONTROL and id and stats[id] then slider:SetValue(zo_roundToNearest(stats[id], 0.1)) end
	end
end

local function SetPenData(spellPenData, weaponPenData, avgPen)

	if spellPenData ~= nil and weaponPenData ~= nil then

		pendata = {spellPenData, weaponPenData, avgPen}

	else

		pendata = {}

	end
end

function CST.Reset(button)

	SetPenData()

	button:SetState(BSTATE_DISABLED)

	local spenctl = CST.SPenBox
	local spenvalue = spenctl:GetNamedChild("Value")
	local wpenctl = CST.WPenBox
	local wpenvalue = wpenctl:GetNamedChild("Value")

	spenvalue.data.tooltipText = nil
	spenvalue.data.tooltipText = nil
	wpenvalue.data.tooltipText = nil

	local colors = ZO_ColorDef:New(GetString(spenctl.color))
	local colorw = ZO_ColorDef:New(GetString(wpenctl.color))

	spenvalue:SetColor(colors.r, colors.g, colors.b, colors.a)
	wpenvalue:SetColor(colorw.r, colorw.g, colorw.b, colorw.a)

end

-- Ratio constants

local RATIOS_MAGICAL_DAMAGE = 1
local RATIOS_MAGICAL_DAMAGE_DIRECT = 2
local RATIOS_MAGICAL_DAMAGE_DOT = 3
local RATIOS_MAGICAL_DAMAGE_WEAPON_DIRECT = 4
local RATIOS_MAGICAL_DAMAGE_WEAPON_DOT = 11
local RATIOS_MAGICAL_DAMAGE_CRITABLE = 5

local RATIOS_PHYSICAL_DAMAGE = 6
local RATIOS_PHYSICAL_DAMAGE_DIRECT = 7
local RATIOS_PHYSICAL_DAMAGE_DOT = 8
local RATIOS_PHYSICAL_DAMAGE_WEAPON_DIRECT = 9
local RATIOS_PHYSICAL_DAMAGE_WEAPON_DOT = 12
local RATIOS_PHYSICAL_DAMAGE_CRITABLE = 10

local function GetCurrentRatios()

	local ratios = {}

	for i = 1, ratioControl:GetNumChildren() do

		local child = ratioControl:GetChild(i)
		local slider = child:GetNamedChild("Slider")
		local id = child.id

		if child:GetType() == CT_CONTROL and id then ratios[id] = zo_roundToNearest(slider:GetValue(), 0.1) end
	end

	return ratios
end

local function SetRatios(ratios)

	for i = 1, ratioControl:GetNumChildren() do

		local child = ratioControl:GetChild(i)
		local slider = child:GetNamedChild("Slider")
		local id = child.id

		if child:GetType() == CT_CONTROL and id and ratios[id] then slider:SetValue(zo_roundToNearest(ratios[id], 0.1)) end
	end

end

local function GetCurrentTargetStats()

	local targetStats = {}

	for i = 1, targetControl:GetNumChildren() do

		local child = targetControl:GetChild(i)
		local slider = child:GetNamedChild("Slider")
		local id = child.id

		if child:GetType() == CT_CONTROL and id then targetStats[id] = zo_roundToNearest(slider:GetValue(), 0.1) end
	end

	return targetStats
end

local function UpdateCP(newCP)

	for i = 1, resultRows:GetNumChildren() do

		local child = resultRows:GetChild(i)
		local skillId = child.skillId
		local discipline = child.discipline

		if child:GetType() == CT_CONTROL and discipline ~= nil and skillId ~= nil then

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

		if child:GetType() == CT_CONTROL and abilityId ~= nil then

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

local ELEMENTAL_EXPERT 		 = 63848
local SPELL_EROSION          = 61555
local ELFBORN                = 61680
local PHYSICAL_WEAPON_EXPERT = 92424
local MASTER_AT_ARMS         = 92134
local STAFF_EXPERT           = 60503
local THAUMATURGE            = 63847
local PRECISE_STRIKES        = 59105
local PIERCING               = 61546
local MIGHTY                 = 63868


local CPData = {
	[ELEMENTAL_EXPERT] 			= {type = STARTYPE_15, 		attribute = ATTRIBUTE_MAGICKA },	-- Elemental Expert
	[SPELL_EROSION] 			= {type = STARTYPE_5280, 	attribute = ATTRIBUTE_MAGICKA },	-- Spell Erosion
	[ELFBORN] 					= {type = STARTYPE_25, 		attribute = ATTRIBUTE_MAGICKA }, 	-- Elfborn
	[PHYSICAL_WEAPON_EXPERT] 	= {type = STARTYPE_35, 		attribute = ATTRIBUTE_STAMINA },	-- Physical Weapon Expert
	[MASTER_AT_ARMS] 			= {type = STARTYPE_25, 		attribute = ATTRIBUTE_NONE },		-- Master-at-Arms
	[STAFF_EXPERT] 				= {type = STARTYPE_35, 		attribute = ATTRIBUTE_MAGICKA },	-- Staff Expert
	[THAUMATURGE] 				= {type = STARTYPE_25, 		attribute = ATTRIBUTE_NONE },		-- Thaumaturge
	[PRECISE_STRIKES] 			= {type = STARTYPE_25, 		attribute = ATTRIBUTE_STAMINA }, 	-- Precise Strikes
	[PIERCING] 					= {type = STARTYPE_5280, 	attribute = ATTRIBUTE_STAMINA },	-- Piercing
	[MIGHTY] 					= {type = STARTYPE_15, 		attribute = ATTRIBUTE_STAMINA },	-- Mighty
}

local JumpPoints = {
	[STARTYPE_15]	= {0, 4, 7, 11, 15, 19, 23, 27, 32, 37, 43, 49, 64, 75, 100},
	[STARTYPE_25]	= {0, 3, 5, 7, 9, 11, 13, 15, 16, 18, 20, 23, 26, 28, 31, 34, 37, 40, 44, 48, 52, 56, 66, 72, 81, 100},
	[STARTYPE_35]	= {0, 2, 3, 5, 6, 8, 9, 11, 13, 14, 16, 18, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 42, 44, 47, 50, 53, 56, 59, 63, 67, 72, 77, 84, 100},
	--[STARTYPE_55]	= {0, 2, 3, 5, 6, 8, 9, 11, 13, 14, 16, 18, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 42, 44, 47, 50, 53, 56, 59, 63, 67, 72, 77, 84, 100}, not needed for now
}

local function GetCPValue(abilityId, points, round)

	local cpType = CPData[abilityId].type
	local value = 0
	points = points / 100

	if cpType == STARTYPE_15 then

		value = 0.15 * points * (2 - points) + (points - 1) * (points - 0.5) * points * 2 / 150

	elseif cpType == STARTYPE_25 then

		value = 0.25 * points * (2 - points) + (points - 1) * (points - 0.5) * points * 2 / 250

	elseif cpType == STARTYPE_35 then

		value = 0.35 * points * (2 - points) + (points - 1) * (points - 0.5) * points * 2 / 150

	elseif cpType == STARTYPE_55 then

		value = 0.55 * points * (2 - points) + (points - 1) * (points - 0.5) * points * 2 / 250

	elseif cpType == STARTYPE_5280 then

		value = math.floor(5280 * points * (2 - points))
		round = false
	end

	if round == true then value = math.floor(value * 100) / 100	end

	return value
end

local function GetDamageFactor(stats, ratios, targetStats, CP, round)

	local cpfactors = {}

	for abilityId, value in pairs(CP) do

		cpfactors[abilityId] = GetCPValue(abilityId, value, round)

	end

	local spellCPMod = (
		(ratios[RATIOS_MAGICAL_DAMAGE_DIRECT] / 100 * (1 + cpfactors[ELEMENTAL_EXPERT] + cpfactors[MASTER_AT_ARMS] + stats[STATS_DAMAGE_DONE] / 100)) 							-- Direct Magical Damage (1 + Elemental Expert + Master-at-Arms + Damage Done)
		+ (ratios[RATIOS_MAGICAL_DAMAGE_DOT] / 100 * (1 + cpfactors[ELEMENTAL_EXPERT] + cpfactors[THAUMATURGE] + stats[STATS_DAMAGE_DONE] / 100))						-- DoT Magical Damage (1 + Elemental Expert + Thaumaturge + Damage Done)
		+ (ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DIRECT] / 100 * (1 + cpfactors[ELEMENTAL_EXPERT] + cpfactors[MASTER_AT_ARMS] + cpfactors[STAFF_EXPERT] + stats[STATS_DAMAGE_DONE] / 100))		-- Staff Direct Damage (1 + Elemental Expert + Master-at-Arms + Staff Expert + Damage Done)
		+ (ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DOT] / 100 * (1 + cpfactors[ELEMENTAL_EXPERT] + cpfactors[THAUMATURGE] + cpfactors[STAFF_EXPERT] + stats[STATS_DAMAGE_DONE] / 100)))	-- Staff DoT Damage (1 + Elemental Expert + Thaumaturge + Staff Expert + Damage Done)

	local weaponCPMod = (
		(ratios[RATIOS_PHYSICAL_DAMAGE_DIRECT] / 100 * (1 + cpfactors[MIGHTY] + cpfactors[MASTER_AT_ARMS] + stats[STATS_DAMAGE_DONE] / 100)) 							-- Direct Physical Damage (1 + Mighty + Master-at-Arms + Damage Done)
		+ (ratios[RATIOS_PHYSICAL_DAMAGE_DOT] / 100 * (1 + cpfactors[MIGHTY] + cpfactors[THAUMATURGE] + stats[STATS_DAMAGE_DONE] / 100))						-- DoT Magical Damage (1 + Mighty + Thaumaturge + Damage Done)
		+ (ratios[RATIOS_PHYSICAL_DAMAGE_WEAPON_DIRECT] / 100 * (1 + cpfactors[MIGHTY] + cpfactors[MASTER_AT_ARMS] + cpfactors[PHYSICAL_WEAPON_EXPERT] + stats[STATS_DAMAGE_DONE] / 100)))	-- Weapon Direct Damage (1 + Mighty + Master-at-Arms + Physical Weapon Expert + Damage Done)

	local spellCritMod = 1 + ratios[RATIOS_MAGICAL_DAMAGE_CRITABLE] / 100 * stats[STATS_SPELL_CRIT_CHANCE] / 100 * (stats[STATS_SPELL_CRIT_DAMAGE] / 100 + cpfactors[ELFBORN])
	local weaponCritMod = 1 + ratios[RATIOS_PHYSICAL_DAMAGE_CRITABLE] / 100 * stats[STATS_WEAPON_CRIT_CHANCE] / 100 * (stats[STATS_WEAPON_CRIT_DAMAGE] / 100 + cpfactors[PRECISE_STRIKES])

	local spellPenMod = 0
	local weaponPenMod = 0

	if #pendata > 0 then

		local spellPenData, weaponPenData, avgPen = unpack(pendata)

		local spellPenAvgDiff = avgPen[1] - (stats[STATS_SPELL_PEN] + cpfactors[SPELL_EROSION])
		local weaponPenAvgDiff = avgPen[2] - (stats[STATS_WEAPON_PEN] + cpfactors[PIERCING])

		for spellPen, damageFrac in pairs(spellPenData) do

			spellPenMod = spellPenMod + (1 - math.max(targetStats[1] - (spellPen - spellPenAvgDiff), 0) / 50000) * damageFrac

		end

		for weaponPen, damageFrac in pairs(weaponPenData) do

			weaponPenMod = weaponPenMod + (1 - math.max(targetStats[1] - (weaponPen - weaponPenAvgDiff), 0) / 50000) * damageFrac

		end

	else

		spellPenMod = (1 - math.max(targetStats[1] - stats[STATS_SPELL_PEN] - cpfactors[SPELL_EROSION], 0) / 50000)
		weaponPenMod = (1 - math.max(targetStats[1] - stats[STATS_WEAPON_PEN] - cpfactors[PIERCING], 0) / 50000)

	end

	local totalspellmod = ratios[RATIOS_MAGICAL_DAMAGE] / 100 * spellCPMod * spellCritMod * spellPenMod
	local totalweaponmod = ratios[RATIOS_PHYSICAL_DAMAGE] / 100 * weaponCPMod * weaponCritMod * weaponPenMod

	local totalmod = totalspellmod + totalweaponmod

	return totalmod, (ratios[RATIOS_MAGICAL_DAMAGE] / 100 * spellCPMod + ratios[RATIOS_PHYSICAL_DAMAGE] / 100 * weaponCPMod), (ratios[RATIOS_MAGICAL_DAMAGE] / 100 * spellCritMod + ratios[RATIOS_PHYSICAL_DAMAGE] / 100 * weaponCritMod), (ratios[RATIOS_MAGICAL_DAMAGE] / 100 * spellPenMod + ratios[RATIOS_PHYSICAL_DAMAGE] / 100 * weaponPenMod)
end

local AFFECTED_BY_EXPERTORMIGHTY = 1
local AFFECTED_BY_MASTEROFARMS = 2
local AFFECTED_BY_THAUMATURGE = 3
local AFFECTED_BY_WEAPONEXPERT = 4
local AFFECTED_BY_CRITS = 5
local AFFECTED_BY_PENETRATION = 6

local AbilityData = GetConstellationAbilityData() -- see AbilityData.lua

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

	local fightData, version

	if CMX == nil or CMX.GetAbilityStats == nil then

		df("To import data you need to install/update Combat Metrics!")
		return

	else

		fightData, version = CMX.GetAbilityStats()

		if version == nil or version < 2 then

			df("To import data you need to update Combat Metrics!")
			return

		elseif fightData == nil then

			return

		end

	end

	local fight = fightData[1]

	if fight == nil then return end

	local selection = fightData[2] or fight.calculated
	local ratios = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	local total = selection.damageOutTotal

	local calcstats = fight.calculated.stats.dmgavg

	local spellCritRatio = GetCriticalStrikeChance(calcstats.avgspellcrit, true) / 100
	local spellCritBonus = calcstats.avgspellcritbonus
	local spellPenetration = calcstats.avgspellpen
	local spellPenData = selection.spellResistance

	local weaponCritRatio = GetCriticalStrikeChance(calcstats.avgweaponcrit, true) / 100
	local weaponCritBonus = calcstats.avgweaponcritbonus
	local weaponPenetration = calcstats.avgweaponpen
	local weaponPenData = selection.physicalResistance

	local totalSpellDamage = 0
	local totalWeaponDamage = 0
	local avgSpellPen = 0
	local avgWeaponPen = 0

	-- Calculate Average Spell

	if spellPenData then

		for _, damage in pairs(spellPenData) do

			totalSpellDamage = totalSpellDamage + damage

		end

		if totalSpellDamage > 0 then

			for spellPenetration, damage in pairs(spellPenData) do

				avgSpellPen = avgSpellPen + (spellPenetration * damage / totalSpellDamage)
				spellPenData[spellPenetration] = damage / totalSpellDamage

			end

		else

			avgSpellPen = spellPenetration
			spellPenData = { [avgSpellPen] = 1 }

		end

	else

		avgSpellPen = CST_DEFAULT_RESIST

	end

	if weaponPenData then

		for _, damage in pairs(weaponPenData) do

			totalWeaponDamage = totalWeaponDamage + damage

		end

		if totalWeaponDamage > 0 then

			for weaponPenetration, damage in pairs(weaponPenData) do

				avgWeaponPen = avgWeaponPen + (weaponPenetration * damage / totalWeaponDamage)
				weaponPenData[weaponPenetration] = damage / totalWeaponDamage

			end

		else

			avgWeaponPen = weaponPenetration
			weaponPenData = { [avgWeaponPen] = 1 }

		end

	else

		avgWeaponPen = CST_DEFAULT_RESIST

	end

	local avgPen = {avgSpellPen, avgWeaponPen}

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

			ratios[key] = (ratios[key] or 0) + abilityTotal / total * 100

			if abilityCPData ~= nil then

				if ismagic and abilityCPData[AFFECTED_BY_CRITS] then

					spellCrits = spellCrits + ability.hitsOutCritical
					spellCritDamage = spellCritDamage + ability.damageOutCritical

					spellHits = spellHits + ability.hitsOutTotal
					spellDamageTotal = spellDamageTotal + ability.damageOutTotal

				elseif ismagic == false and abilityCPData[AFFECTED_BY_CRITS] then

					weaponCrits = weaponCrits + ability.hitsOutCritical
					weaponCritDamage = weaponCritDamage + ability.damageOutCritical

					weaponHits = weaponHits + ability.hitsOutTotal
					weaponDamageTotal = weaponDamageTotal + ability.damageOutTotal

				end

				if abilityCPData[AFFECTED_BY_MASTEROFARMS] and abilityCPData[AFFECTED_BY_WEAPONEXPERT] then

					ratios[3 + key] = ratios[3 + key] + abilityTotal / total * 100

				elseif abilityCPData[AFFECTED_BY_MASTEROFARMS] then

					ratios[1 + key] = ratios[1 + key] + abilityTotal / total * 100

				elseif abilityCPData[AFFECTED_BY_THAUMATURGE] and abilityCPData[AFFECTED_BY_WEAPONEXPERT] and ismagic then

					ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DOT] = ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DOT] + abilityTotal / total * 100

				elseif abilityCPData[AFFECTED_BY_THAUMATURGE] then

					ratios[2 + key] = ratios[2 + key] + abilityTotal / total * 100

				end

				if abilityCPData[AFFECTED_BY_CRITS] then

					ratios[4 + key] = ratios[4 + key] + abilityTotal / total * 100

				end

			else

				local name = GetAbilityName(id)
				df("(%d) %s - No Data for this Ability!", id, name)
			end
		end
	end

	SetRatios(ratios)

	spellCritRatio = spellCritRatio or (spellCrits / math.max(spellHits, 1))
	local spellCritDamageRatio = spellCritDamage / math.max(spellDamageTotal, 1)
	spellCritBonus = spellCritBonus or (spellCritRatio > 0 and spellCritDamageRatio > 0 and 100 * spellCritDamageRatio * (1 - spellCritRatio) / ((1 - spellCritDamageRatio) * spellCritRatio) - 1 or 0) * 100

	weaponCritRatio = weaponCritRatio or (weaponCrits / math.max(weaponHits, 1))
	local weaponCritDamageRatio = weaponCritDamage / math.max(weaponDamageTotal, 1)
	weaponCritBonus = weaponCritBonus or (weaponCritRatio > 0 and weaponCritDamageRatio > 0 and 100 * weaponCritDamageRatio * (1 - weaponCritRatio) / ((1 - weaponCritDamageRatio) * weaponCritRatio) - 1 or 0) * 100

	local stats = {CPdefault, 20, spellCritRatio * 100, spellCritBonus, avgSpellPen, weaponCritRatio * 100, weaponCritBonus, avgWeaponPen}

	SetStats(stats)
	SetPenData(spellPenData, weaponPenData, avgPen)

	UpdateCP(fight.CP)

	CST.ApplyCurrentStars = true
	CST.ApplyCurrentStarsCheckBox:SetHidden(false)

	-- Indicate special penetration data

	CST.ResetButton:SetState(BSTATE_ENABLED)

	local spenvalue = CST.SPenBox:GetNamedChild("Value")
	local wpenvalue = CST.WPenBox:GetNamedChild("Value")

	spenvalue.data = {tooltipText = GetString(SI_CONSTELLATIONS_INPUT_LABEL_SPELLPEN_TOOLTIP)}
	wpenvalue.data = {tooltipText = GetString(SI_CONSTELLATIONS_INPUT_LABEL_WEAPONPEN_TOOLTIP)}

	if spenvalue:GetHandler("OnMouseEnter") == nil then

		spenvalue:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		spenvalue:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

		wpenvalue:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		wpenvalue:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	end

	spenvalue:SetColor(1, .5, 0, 1)
	wpenvalue:SetColor(1, .5, 0, 1)

end

CST.Import = ImportCMXData

local function AccountForPreviousCP(stats, ratios, targetStats, oldCP)

	if not (stats and ratios and oldCP) then return end

	local cpfactors = {}

	for abilityId, value in pairs(oldCP) do

		cpfactors[abilityId] = GetCPValue(abilityId, value, true)

	end

	local oldSpellCritMod = 1 + ratios[RATIOS_MAGICAL_DAMAGE_CRITABLE] / 100 * stats[STATS_SPELL_CRIT_CHANCE] / 100 * (stats[STATS_SPELL_CRIT_DAMAGE] / 100 + cpfactors[ELFBORN])
	local oldWeaponCritMod = 1 + ratios[RATIOS_PHYSICAL_DAMAGE_CRITABLE] / 100 * stats[STATS_WEAPON_CRIT_CHANCE] / 100 * (stats[STATS_WEAPON_CRIT_DAMAGE] / 100 + cpfactors[PRECISE_STRIKES])

	local oldSpellPenMod = (1 - math.max(targetStats[1] - stats[STATS_SPELL_PEN] - cpfactors[SPELL_EROSION], 0) / 50000)
	local oldWeaponPenMod = (1 - math.max(targetStats[1] - stats[STATS_WEAPON_PEN] - cpfactors[PIERCING], 0) / 50000)

	local oldSpellMod = oldSpellCritMod * oldSpellPenMod
	local oldWeaponMod = oldWeaponCritMod * oldWeaponPenMod

	stats[STATS_SPELL_CRIT_DAMAGE] = stats[STATS_SPELL_CRIT_DAMAGE] - cpfactors[ELFBORN] * 100
	stats[STATS_SPELL_PEN] = stats[STATS_SPELL_PEN] - cpfactors[SPELL_EROSION]
	stats[STATS_WEAPON_CRIT_DAMAGE] = stats[STATS_WEAPON_CRIT_DAMAGE] - cpfactors[PRECISE_STRIKES] * 100
	stats[STATS_WEAPON_PEN] = stats[STATS_WEAPON_PEN] - cpfactors[PIERCING]

	local spellCritMod = 1 + ratios[RATIOS_MAGICAL_DAMAGE_CRITABLE] / 100 * stats[STATS_SPELL_CRIT_CHANCE] / 100 * (stats[STATS_SPELL_CRIT_DAMAGE] / 100 + cpfactors[ELFBORN])
	local weaponCritMod = 1 + ratios[RATIOS_PHYSICAL_DAMAGE_CRITABLE] / 100 * stats[STATS_WEAPON_CRIT_CHANCE] / 100 * (stats[STATS_WEAPON_CRIT_DAMAGE] / 100 + cpfactors[PRECISE_STRIKES])

	local spellPenMod = (1 - math.max(targetStats[1] - stats[STATS_SPELL_PEN] - cpfactors[SPELL_EROSION], 0) / 50000)
	local weaponPenMod = (1 - math.max(targetStats[1] - stats[STATS_WEAPON_PEN] - cpfactors[PIERCING], 0) / 50000)

	local SpellMod = spellCritMod * spellPenMod
	local WeaponMod = weaponCritMod * weaponPenMod

	local oldMagicRatio = ratios[RATIOS_MAGICAL_DAMAGE]
	local oldWeaponRatio = ratios[RATIOS_PHYSICAL_DAMAGE]

	-- ratios[RATIOS_MAGICAL_DAMAGE] is here temporarily used a

	ratios[RATIOS_MAGICAL_DAMAGE] = (ratios[RATIOS_MAGICAL_DAMAGE] - ratios[RATIOS_MAGICAL_DAMAGE_DIRECT] - ratios[RATIOS_MAGICAL_DAMAGE_DOT] - ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DIRECT] - ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DOT])/ (1 + cpfactors[ELEMENTAL_EXPERT]) * SpellMod / oldSpellMod
	ratios[RATIOS_MAGICAL_DAMAGE_DIRECT] = ratios[RATIOS_MAGICAL_DAMAGE_DIRECT] / (1 + cpfactors[ELEMENTAL_EXPERT] + cpfactors[MASTER_AT_ARMS]) * SpellMod / oldSpellMod
	ratios[RATIOS_MAGICAL_DAMAGE_DOT] = ratios[RATIOS_MAGICAL_DAMAGE_DOT] / (1 + cpfactors[ELEMENTAL_EXPERT] + cpfactors[THAUMATURGE]) * SpellMod / oldSpellMod
	ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DIRECT] = ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DIRECT] / (1 + cpfactors[ELEMENTAL_EXPERT] + cpfactors[MASTER_AT_ARMS] + cpfactors[STAFF_EXPERT]) * SpellMod / oldSpellMod
	ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DOT] = ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DOT] / (1 + cpfactors[ELEMENTAL_EXPERT] + cpfactors[THAUMATURGE] + cpfactors[STAFF_EXPERT]) * SpellMod / oldSpellMod

	ratios[RATIOS_PHYSICAL_DAMAGE] = (ratios[RATIOS_PHYSICAL_DAMAGE] - ratios[RATIOS_PHYSICAL_DAMAGE_DIRECT] - ratios[RATIOS_PHYSICAL_DAMAGE_DOT] - ratios[RATIOS_PHYSICAL_DAMAGE_WEAPON_DIRECT]) / (1 + cpfactors[MIGHTY]) * WeaponMod / oldWeaponMod
	ratios[RATIOS_PHYSICAL_DAMAGE_DIRECT] = ratios[RATIOS_PHYSICAL_DAMAGE_DIRECT] / (1 + cpfactors[MIGHTY] + cpfactors[MASTER_AT_ARMS]) * WeaponMod / oldWeaponMod
	ratios[RATIOS_PHYSICAL_DAMAGE_DOT] = ratios[RATIOS_PHYSICAL_DAMAGE_DOT] / (1 + cpfactors[MIGHTY] + cpfactors[THAUMATURGE]) * WeaponMod / oldWeaponMod
	ratios[RATIOS_PHYSICAL_DAMAGE_WEAPON_DIRECT] = ratios[RATIOS_PHYSICAL_DAMAGE_WEAPON_DIRECT] / (1 + cpfactors[MIGHTY] + cpfactors[MASTER_AT_ARMS] + cpfactors[PHYSICAL_WEAPON_EXPERT]) * WeaponMod / oldWeaponMod

	ratios[RATIOS_MAGICAL_DAMAGE_CRITABLE] = oldMagicRatio == 0 and 0 or ratios[RATIOS_MAGICAL_DAMAGE_CRITABLE] * (ratios[RATIOS_MAGICAL_DAMAGE] + ratios[RATIOS_MAGICAL_DAMAGE_DIRECT] + ratios[RATIOS_MAGICAL_DAMAGE_DOT] + ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DIRECT] + ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DOT]) / oldMagicRatio
	ratios[RATIOS_PHYSICAL_DAMAGE_CRITABLE] = oldWeaponRatio == 0 and 0 or ratios[RATIOS_PHYSICAL_DAMAGE_CRITABLE] * (ratios[RATIOS_PHYSICAL_DAMAGE] + ratios[RATIOS_PHYSICAL_DAMAGE_DIRECT] + ratios[RATIOS_PHYSICAL_DAMAGE_DOT] + ratios[RATIOS_PHYSICAL_DAMAGE_WEAPON_DIRECT]) / oldWeaponRatio

	local totalkeys = {1, 2, 3, 4, 6, 7, 8, 9, 11}

	local sumratios = 0

	for _, i in ipairs(totalkeys) do

		sumratios = sumratios + ratios[i]

	end

	for i = 1, 11 do

		ratios[i] = ratios[i] * 100 / sumratios

	end

	ratios[RATIOS_MAGICAL_DAMAGE] = ratios[RATIOS_MAGICAL_DAMAGE] + ratios[RATIOS_MAGICAL_DAMAGE_DIRECT] + ratios[RATIOS_MAGICAL_DAMAGE_DOT] + ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DIRECT] + ratios[RATIOS_MAGICAL_DAMAGE_WEAPON_DOT]
	ratios[RATIOS_PHYSICAL_DAMAGE] = ratios[RATIOS_PHYSICAL_DAMAGE] + ratios[RATIOS_PHYSICAL_DAMAGE_DIRECT] + ratios[RATIOS_PHYSICAL_DAMAGE_DOT] + ratios[RATIOS_PHYSICAL_DAMAGE_WEAPON_DIRECT]

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

	local totalCP = stats[STATS_TOTAL_MAGE_CP]
	if totalMinCP > totalCP then return end

	local maxCPValue = math.min(totalMaxCP, totalCP)

	local grad = {}
	local maxinc = 0
	local totalmod
	local descfactors

	-- Gradient Descent

	for i = totalMinCP, maxCPValue do

		local oldmaxinc = maxinc
		local maxKey = 0

		for abilityId, value in pairs(calcCP) do

			local cptemp = {}

			ZO_DeepTableCopy(calcCP, cptemp)

			cptemp[abilityId] = value + 1

			local factors = {GetDamageFactor(stats, ratios, targetStats, cptemp, false)}
			totalmod = factors[1]

			if i == maxCP then grad[abilityId] = totalmod - oldmaxinc end

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

		if value.type == STARTYPE_5280 and ((value.attribute == ATTRIBUTE_MAGICKA and ratios[RATIOS_MAGICAL_DAMAGE] > 0) or (value.attribute == ATTRIBUTE_STAMINA and ratios[RATIOS_PHYSICAL_DAMAGE] > 0) or value.attribute == ATTRIBUTE_NONE) then

			noJPAbilityTable[#noJPAbilityTable + 1] = id

		elseif (value.attribute == ATTRIBUTE_MAGICKA and ratios[RATIOS_MAGICAL_DAMAGE] > 0) or (value.attribute == ATTRIBUTE_STAMINA and ratios[RATIOS_PHYSICAL_DAMAGE] > 0) or value.attribute == ATTRIBUTE_NONE then

			JPAbilityTable[#JPAbilityTable + 1] = id

		else

			IgnoredAbilityTable[#IgnoredAbilityTable + 1] = id

		end

	end

	for id, jumpPoints in pairs(JumpPointTable) do

		local mindist = 100

		cpnear[id] = {minCP[id], math.floor((minCP[id] + maxCP[id]) / 2), maxCP[id]} -- in case no jumppoint is between min and max

		for i, jp in ipairs(jumpPoints) do

			if math.abs(jp - calcCP[id]) < mindist and jp <= maxCP[id] and jp >= minCP[id] then
				mindist = math.abs(jp - calcCP[id])

				local cpminus = jumpPoints[i - 1] or 0
				local cpnearest = jp
				local cpplus = jumpPoints[i + 1] or 100

				local low = cpminus >= minCP[id] and cpminus or cpnearest
				local high = cpplus <= maxCP[id] and cpplus or cpnearest

				cpnear[id] = {low, cpnearest, high}
			end
		end

	end

	local descfactors = {GetDamageFactor(stats, ratios, targetStats, calcCP, true)}
	local maxincjp = 0

	Print("Descent lowered factor: %.6f (CP: %.6f, Crit: %.6f, Pen: %.6f)", unpack(descfactors))

	local iterations = math.pow(3, #JPAbilityTable) - 1

	local div = {}

	for i = 1, #JPAbilityTable do

		div[i] = math.pow(3, i - 1)

	end

	-- Check all nearby JumpPoints

	for i = 0, iterations do

		local cptemp = {}

		local totalCP = 0

		for k, id in ipairs(JPAbilityTable) do

			local value = cpnear[id][math.floor(i / div[k])%3 + 1]
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

			for i = totalCP, maxCPValue - 1 do

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

	local resultcolor = { 1, .5, .5, 1}

	if newfactors[1] > oldfactors[1] then resultcolor = { .5, 1, .5, 1} end

	CST.After:SetColor(unpack(resultcolor))
end

local svdefaults = {
	["window"] = {x = 150 * dx, y = 150 * dx, height = zo_round(25 / dx) * dx, width = zo_round(300 / dx) * dx},
}

function CST:Initialize(event, addon)

	if addon ~= self.name then return end --Only run if this addon has been loaded

	-- load saved variables

	db = ZO_SavedVars:NewAccountWide(self.name.."_Save", 7, nil, svdefaults) -- taken from Aynatirs guide at http://www.esoui.com123456789forums123456789showthread.php?t=6442

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
		x = zo_round(x / dx) * dx
		y = zo_round(y / dx) * dx
		db.window.x = x
		db.window.y = y
		window:ClearAnchors()
		window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, db.window.x, db.window.y)
	end)

	local fragment = ZO_HUDFadeSceneFragment:New(window)
	CHAMPION_PERKS_SCENE:AddFragment(fragment)

	if CMX then SCENE_MANAGER:GetScene("CMX_REPORT_SCENE"):AddFragment(fragment) end

	CST.ApplyCurrentStars = true

end

em:RegisterForEvent(CST.name.."load", EVENT_ADD_ON_LOADED, function(...) CST:Initialize(...) end)