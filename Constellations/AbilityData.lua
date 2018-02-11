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
	[102136] = {false, true, false, false}, --Zaan	
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
	[37907] = {false, true, false, true}, --Crippling Grasp dot
	[37910] = {true, false, false, true}, --Crippling Grasp
	[37916] = {false, true, false, true}, --Crippling Grasp dot
	[37919] = {true, false, false, true}, --Crippling Grasp
	[37890] = {false, true, false, true}, --Debilitate
	[35941] = {true, false, false, true}, --Funnel Health
	[35596] = {true, false, false, true}, --Impale
	[37527] = {true, false, false, true}, --Incapacitating Strike
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
	[44435] = {false, true, false, true}, --Biting Jabs (new in 3.3.)
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

function GetConstellationData()

	return AbilityData

end