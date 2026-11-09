class_name NewHeroes
extends RefCounted
## Five heroes added in Phase 7, each modelled on a mechanic family from the
## reference map (an archer, a summoner, a low-health transformer, a storm
## caster, a guardian) with original names, looks and kits. Their skills are
## built from the configurable skill types (StrikeSkill, ProjectileSkill, …).


static func sable() -> HeroDef:
	var d := HeroDef.new()
	d.id = "sable"
	d.display_name = "Sable"
	d.title = "the Ashen Archer"
	d.form_name = "Ashfall"
	d.role = "Ranged"
	d.realm = "Ember Forge"
	d.ranged = true
	d.description = "A hunter from the forge-towns' ash fields. Strikes from range with ember-tipped arrows; fragile up close."
	d.max_hp = 920.0
	d.hp_regen = 4.0
	d.move_speed = 6.4
	d.attack_damage = 46.0
	d.attack_interval = 0.9
	d.attack_range = 7.5
	d.primary = "agi"
	d.strength = 18.0
	d.agility = 30.0
	d.intelligence = 22.0
	d.strength_gain = 1.8
	d.agility_gain = 3.0
	d.intelligence_gain = 2.0
	d.exclusive_item = "emberstring_bow"
	d.form_duration = 13.0
	d.form_shield_ratio = 0.15
	d.form_damage_mult = 1.3
	d.form_speed_mult = 1.15
	d.form_scale = 1.25
	d.model_builder = func(): return NewHeroModels.SableModel.new()
	d.skills_builder = NewHeroes.sable_skills
	return d


static func sable_skills() -> Array[Skill]:
	var volley := ProjectileSkill.new("Splinter Volley", "Loose three arrows in a fan: 95 each (+35% per rank).", 8.0)
	volley.damage = 95.0
	volley.count = 3
	volley.spread_deg = 16.0
	volley.color = Color(1.0, 0.82, 0.5)
	volley.size = 0.18
	var pin := ProjectileSkill.new("Pinning Shot", "An arrow that stuns the first enemy hit for 1.5 s and deals 110.", 11.0)
	pin.damage = 110.0
	pin.stun = 1.5
	pin.speed = 26.0
	pin.color = Color(1.0, 0.7, 0.3)
	pin.size = 0.2
	var rain := AreaSkill.new("Ember Rain", "Arrows rain for 3 s on a point 6 ahead: 40/s in radius 3.2 and a 30% slow.", 14.0)
	rain.ahead = 6.0
	rain.radius = 3.2
	rain.zone_time = 3.0
	rain.damage = 40.0
	rain.slow = 0.3
	rain.color = Color(1.0, 0.6, 0.25)
	var sun := ProjectileSkill.new("Sunpiercer", "A blazing shaft that pierces everything in a 20-unit line: 420 (+35% per rank).", 90.0)
	sun.damage = 420.0
	sun.reach = 20.0
	sun.speed = 40.0
	sun.pierce = true
	sun.width = 1.6
	sun.color = Color(1.0, 0.85, 0.45)
	sun.size = 0.4
	return HeroDef.arrange([volley, pin, rain, sun])


static func morrow() -> HeroDef:
	var d := HeroDef.new()
	d.id = "morrow"
	d.display_name = "Morrow"
	d.title = "the Grave Tender"
	d.form_name = "Lichbloom"
	d.role = "Caster"
	d.realm = "Stone Barrows"
	d.ranged = true
	d.description = "Keeper of the barrow-fields' restless dead. Fights through wisps and risen guardians, and drinks life from foes."
	d.max_hp = 950.0
	d.hp_regen = 4.0
	d.move_speed = 5.6
	d.attack_damage = 38.0
	d.attack_interval = 1.0
	d.attack_range = 5.5
	d.primary = "int"
	d.strength = 20.0
	d.agility = 16.0
	d.intelligence = 30.0
	d.strength_gain = 2.0
	d.agility_gain = 1.5
	d.intelligence_gain = 3.0
	d.exclusive_item = "gravebloom_censer"
	d.form_duration = 14.0
	d.form_shield_ratio = 0.2
	d.form_damage_mult = 1.3
	d.form_speed_mult = 1.1
	d.form_scale = 1.3
	d.model_builder = func(): return NewHeroModels.MorrowModel.new()
	d.skills_builder = NewHeroes.morrow_skills
	return d


static func morrow_skills() -> Array[Skill]:
	var wisps := SummonSkill.new("Wisp Swarm", "Call two grave wisps for 18 s (380 HP, ranged, +30% per rank).", 16.0)
	wisps.kind = "wisp"
	wisps.count = 2
	wisps.lifetime = 18.0
	var drain := StrikeSkill.new("Life Drain", "Tear 170 life (+35% per rank) from the nearest enemy within 7 and heal for all of it.", 9.0)
	drain.reach = 7.0
	drain.damage = 170.0
	drain.drain = 1.0
	drain.color = Color(0.7, 1.0, 0.75)
	drain.sound = "transform"
	var curse := AreaSkill.new("Withering Curse", "Curse the ground 5 ahead for 4 s: 40/s in radius 3 and a 40% slow.", 12.0)
	curse.ahead = 5.0
	curse.radius = 3.0
	curse.zone_time = 4.0
	curse.damage = 40.0
	curse.slow = 0.4
	curse.color = Color(0.55, 0.95, 0.6)
	var rise := SummonSkill.new("Barrow Rising", "Raise four barrow guardians for 22 s (650 HP each, +30% per rank).", 100.0)
	rise.kind = "skeleton"
	rise.count = 4
	rise.lifetime = 22.0
	rise.color = Color(0.85, 0.85, 0.75)
	return HeroDef.arrange([wisps, drain, curse, rise])


static func kael() -> HeroDef:
	var d := HeroDef.new()
	d.id = "kael"
	d.display_name = "Kael"
	d.title = "the Hollow Blade"
	d.form_name = "Hollowed"
	d.role = "Bruiser"
	d.realm = "Hollow Moon"
	d.description = "A swordsman with something hollow sleeping inside. Near death, it wakes on its own: below 10% health he transforms without a full meter."
	d.max_hp = 1020.0
	d.hp_regen = 5.0
	d.move_speed = 6.4
	d.attack_damage = 40.0
	d.attack_interval = 0.7
	d.attack_range = 2.3
	d.primary = "agi"
	d.strength = 22.0
	d.agility = 28.0
	d.intelligence = 18.0
	d.strength_gain = 2.2
	d.agility_gain = 3.0
	d.intelligence_gain = 1.6
	d.auto_form_below = 0.1
	d.exclusive_item = "moonless_hilt"
	d.form_duration = 12.0
	d.form_shield_ratio = 0.1
	d.form_damage_mult = 1.4
	d.form_speed_mult = 1.25
	d.form_scale = 1.25
	d.model_builder = func(): return NewHeroModels.KaelModel.new()
	d.skills_builder = NewHeroes.kael_skills
	return d


static func kael_skills() -> Array[Skill]:
	var crescent := ProjectileSkill.new("Crescent Slash", "A crescent of force that cuts through everything in a 9-unit line: 130 (+35% per rank).", 8.0)
	crescent.damage = 130.0
	crescent.reach = 9.0
	crescent.pierce = true
	crescent.width = 1.6
	crescent.speed = 26.0
	crescent.color = Color(0.85, 0.9, 1.0)
	var step := BlinkSkill.new("Flash Step", "Vanish and reappear 6 ahead, striking enemies around you for 60.", 6.0)
	step.distance = 6.0
	step.damage = 60.0
	var edge := StrikeSkill.new("Severing Edge", "A heavy cut on the nearest enemy within 3: 210 (+35% per rank) and a 50% slow for 2 s.", 10.0)
	edge.reach = 3.0
	edge.damage = 210.0
	edge.slow = 0.5
	edge.beam = false
	edge.color = Color(0.85, 0.9, 1.0)
	var rend := ProjectileSkill.new("Moonless Rend", "A wall of black moonlight 3.5 wide across 12 units: 320 (+35% per rank).", 85.0)
	rend.damage = 320.0
	rend.reach = 12.0
	rend.pierce = true
	rend.width = 3.5
	rend.speed = 22.0
	rend.color = Color(0.75, 0.75, 0.95)
	rend.size = 0.6
	return HeroDef.arrange([crescent, step, edge, rend])


static func tamsin() -> HeroDef:
	var d := HeroDef.new()
	d.id = "tamsin"
	d.display_name = "Tamsin"
	d.title = "the Storm Caller"
	d.form_name = "Stormcrown"
	d.role = "Caster"
	d.realm = "Gale Peaks"
	d.ranged = true
	d.description = "A weather-witch of the high peaks. Calls lightning to the ground and wraps her foes in static."
	d.max_hp = 930.0
	d.hp_regen = 4.0
	d.move_speed = 6.0
	d.attack_damage = 38.0
	d.attack_interval = 0.9
	d.attack_range = 6.0
	d.primary = "int"
	d.strength = 18.0
	d.agility = 20.0
	d.intelligence = 32.0
	d.strength_gain = 1.8
	d.agility_gain = 2.0
	d.intelligence_gain = 3.2
	d.exclusive_item = "thunderhead_crown"
	d.form_duration = 13.0
	d.form_shield_ratio = 0.15
	d.form_damage_mult = 1.3
	d.form_speed_mult = 1.2
	d.form_scale = 1.25
	d.model_builder = func(): return NewHeroModels.TamsinModel.new()
	d.skills_builder = NewHeroes.tamsin_skills
	return d


static func tamsin_skills() -> Array[Skill]:
	var arc := AreaSkill.new("Arc Discharge", "Lightning bursts around her: 140 (+35% per rank) within 3.5 and a 0.6 s stun.", 8.0)
	arc.radius = 3.5
	arc.damage = 140.0
	arc.stun = 0.6
	arc.color = Color(0.7, 0.85, 1.0)
	arc.effect = "column"
	var lance := ProjectileSkill.new("Thunder Lance", "A bolt that pierces a 14-unit line: 150 (+35% per rank).", 9.0)
	lance.damage = 150.0
	lance.reach = 14.0
	lance.pierce = true
	lance.speed = 34.0
	lance.color = Color(0.75, 0.85, 1.0)
	lance.size = 0.22
	var field := AreaSkill.new("Static Field", "Charge the ground 5 ahead for 4 s: 45/s in radius 3.5.", 14.0)
	field.ahead = 5.0
	field.radius = 3.5
	field.zone_time = 4.0
	field.damage = 45.0
	field.color = Color(0.65, 0.8, 1.0)
	var wrath := ChainStrikeSkill.new("Skyfall Wrath", "Five bolts fall on enemies within 10: 240 each (+35% per rank) and a 1 s stun.", 95.0)
	wrath.damage = 240.0
	return HeroDef.arrange([arc, lance, field, wrath])


static func hask() -> HeroDef:
	var d := HeroDef.new()
	d.id = "hask"
	d.display_name = "Hask"
	d.title = "the Iron Warden"
	d.form_name = "Unbreakable"
	d.role = "Giant"
	d.realm = "Hollow Moon"
	d.description = "A warden in tower-shield plate. Hooks enemies in, holds the line, and shrugs off what would kill others."
	d.max_hp = 1500.0
	d.hp_regen = 6.0
	d.move_speed = 5.0
	d.attack_damage = 58.0
	d.attack_interval = 1.2
	d.attack_range = 2.6
	d.primary = "str"
	d.strength = 34.0
	d.agility = 14.0
	d.intelligence = 16.0
	d.strength_gain = 3.4
	d.agility_gain = 1.4
	d.intelligence_gain = 1.6
	d.exclusive_item = "wardens_bulwark"
	d.form_duration = 15.0
	d.form_shield_ratio = 0.4
	d.form_damage_mult = 1.2
	d.form_speed_mult = 1.0
	d.form_scale = 1.5
	d.model_builder = func(): return NewHeroModels.HaskModel.new()
	d.skills_builder = NewHeroes.hask_skills
	return d


static func hask_skills() -> Array[Skill]:
	var bash := StrikeSkill.new("Shield Bash", "Slam the nearest enemy within 3 with the shield: 110 (+35% per rank) and a 1.2 s stun.", 9.0)
	bash.reach = 3.0
	bash.damage = 110.0
	bash.stun = 1.2
	bash.beam = false
	bash.color = Color(0.95, 0.8, 0.45)
	bash.sound = "slam"
	var bulwark := BuffSkill.new("Iron Bulwark", "Brace for 4 s: take 40% less damage and gain a shield of 20% max HP.", 14.0)
	bulwark.guard = 0.4
	bulwark.shield = 0.2
	var hook := ProjectileSkill.new("Chain Hook", "A hook that drags the first enemy hit to Hask and deals 80.", 12.0)
	hook.damage = 80.0
	hook.reach = 10.0
	hook.speed = 30.0
	hook.pull = true
	hook.color = Color(0.6, 0.62, 0.66)
	hook.size = 0.25
	var fortress := AreaSkill.new("Fortress", "Untouchable for 2 s, then a slam that hurls enemies within 5 back: 200 (+35% per rank).", 90.0)
	fortress.radius = 5.0
	fortress.damage = 200.0
	fortress.knockback = 5.0
	fortress.self_invulnerable = 2.0
	fortress.color = Color(0.95, 0.8, 0.45)
	fortress.effect = "rock"
	return HeroDef.arrange([bash, bulwark, hook, fortress])
