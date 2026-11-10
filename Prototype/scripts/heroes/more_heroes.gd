class_name MoreHeroes
extends RefCounted
## Sixteen more heroes, bringing the roster to the reference map's 24 — six per
## realm, as the map has its taverns. Every hero is an original design: names,
## stories and kits are this game's own; only mechanic families echo the map
## (chained forms, a stat-threshold evolution, summoners, an innate blink on a
## 2 s cooldown, freezes, sand prisons, flash-step swordplay).
## Looks: KayKit characters (CC0, Kay Lousberg) and Quaternius RPG characters
## (CC0, Quaternius), recoloured and re-armed per hero.

const K := "res://assets/thirdparty/kaykit/characters/"
const SW := "res://assets/thirdparty/kaykit/characters/skeleton_weapons/"


static func all() -> Array[HeroDef]:
	return [pyre(), brannoc(), seraphine(), ashka(), isolde(), oren(), kestrel(), thane(),
		dunmar(), mire(), halvard(), wren(), corin(), velka(), nyx(), lys()]


## Sets a skill's fields from a dictionary: one line per skill.
static func _s(skill: Skill, fields: Dictionary) -> Skill:
	for key in fields:
		skill.set(key, fields[key])
	return skill


## Common hero setup; per-hero values follow.
static func _hero(id: String, name: String, title: String, role: String, realm: String, form: String, description: String) -> HeroDef:
	var d := HeroDef.new()
	d.id = id
	d.display_name = name
	d.title = title
	d.role = role
	d.realm = realm
	d.form_name = form
	d.description = description
	d.exclusive_item = ""
	return d


static func _stats(d: HeroDef, hp: float, regen: float, speed: float, damage: float, interval: float, reach: float, primary: String,
		attrs: Array, gains: Array) -> void:
	d.max_hp = hp
	d.hp_regen = regen
	d.move_speed = speed
	d.attack_damage = damage
	d.attack_interval = interval
	d.attack_range = reach
	d.ranged = reach > 3.0
	d.primary = primary
	d.strength = attrs[0]
	d.agility = attrs[1]
	d.intelligence = attrs[2]
	d.strength_gain = gains[0]
	d.agility_gain = gains[1]
	d.intelligence_gain = gains[2]


static func _form(d: HeroDef, duration: float, shield: float, damage: float, speed: float, scale: float, stages: Array[String] = []) -> void:
	d.form_duration = duration
	d.form_shield_ratio = shield
	d.form_damage_mult = damage
	d.form_speed_mult = speed
	d.form_scale = scale
	d.form_stages = stages


## The map's innate skills: a short blink on a 2 s cooldown, always ready.
static func _blink(name: String, color: Color, distance := 4.5) -> Skill:
	return _s(BlinkSkill.new(name, "Innate: blink %.1f units ahead (2 s)." % distance, 2.0), {"distance": distance, "color": color})


# =================================================================== Ember Forge
static func pyre() -> HeroDef:
	var d := _hero("pyre", "Pyre", "the Cinder Fist", "Speed", "Ember Forge", "Flare",
			"A forge-born brawler whose fists burn hotter the longer a fight lasts. His form climbs three stages, each brighter than the last.")
	_stats(d, 880.0, 4.5, 6.8, 30.0, 0.6, 2.2, "agi", [18.0, 28.0, 18.0], [2.0, 3.0, 1.6])
	_form(d, 12.0, 0.15, 1.25, 1.3, 1.25, ["Blaze", "Supernova"])
	d.exclusive_item = "cinderfist_wraps"
	d.voice = "male2"
	d.voice_pitch = 1.1
	d.model_builder = func(): return RiggedModel.dressed(K + "Rogue.glb", "Dualwield_Melee_Attack_Slice", "Spellcast_Shoot", ["Knife", "Knife_Offhand"], Color(1.0, 0.5, 0.2), Color(1.0, 0.62, 0.5))
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(ProjectileSkill.new("Cinder Jab", "Hurl a fist of flame: 100 (+35% per rank) to the first enemy hit.", 6.0), {"damage": 100.0, "speed": 28.0, "color": Color(1.0, 0.55, 0.2), "size": 0.3}),
			_s(StrikeSkill.new("Flame Rush", "Burst into the nearest enemy within 6: 90 and a 1 s stun.", 10.0), {"reach": 6.0, "damage": 90.0, "stun": 1.0, "color": Color(1.0, 0.6, 0.25)}),
			_s(AreaSkill.new("Heat Wave", "A ring of fire around you: 130 in radius 3.5 and a 30% slow.", 11.0), {"radius": 3.5, "damage": 130.0, "slow": 0.3, "color": Color(1.0, 0.5, 0.2)}),
			_s(ChainStrikeSkill.new("Hundred Burning Fists", "Seven blazing blows on enemies within 7: 160 each.", 90.0), {"radius": 7.0, "strikes": 7, "interval": 0.15, "damage": 160.0, "stun": 0.3, "color": Color(1.0, 0.55, 0.2)}),
		])
	d.innate_builder = func(): return _blink("Ember Step", Color(1.0, 0.55, 0.2))
	return d


static func brannoc() -> HeroDef:
	var d := _hero("brannoc", "Brannoc", "the Iron Gate", "Giant", "Ember Forge", "Bulwark of Embers",
			"A towering gatekeeper of the forge-city who has never once stepped back. Holds the line while allies strike.")
	_stats(d, 1500.0, 6.0, 5.0, 50.0, 1.25, 2.6, "str", [32.0, 14.0, 16.0], [3.2, 1.4, 1.6])
	_form(d, 15.0, 0.4, 1.2, 1.0, 1.6)
	d.exclusive_item = "gatekeepers_seal"
	d.voice = "male1"
	d.voice_pitch = 0.78
	d.model_builder = func(): return RiggedModel.dressed(K + "Knight.glb", "1H_Melee_Attack_Chop", "2H_Melee_Attack_Spin", ["1H_Sword", "Spike_Shield"], Color(1.0, 0.7, 0.35), Color(0.95, 0.78, 0.55), 2.6)
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(StrikeSkill.new("Gate Slam", "Smash the nearest enemy within 3: 120 and a 1.2 s stun.", 8.0), {"reach": 3.0, "damage": 120.0, "stun": 1.2, "beam": false, "color": Color(1.0, 0.75, 0.4)}),
			_s(BuffSkill.new("Iron Resolve", "For 5 s take 45% less damage and gain a shield of 15% max HP.", 14.0), {"duration": 5.0, "guard": 0.45, "shield": 0.15, "color": Color(1.0, 0.8, 0.45)}),
			_s(AreaSkill.new("Shockwall", "Stamp the ground 3 ahead: 110 in radius 3 and knock enemies back.", 12.0), {"ahead": 3.0, "radius": 3.0, "damage": 110.0, "knockback": 9.0, "color": Color(1.0, 0.7, 0.35), "effect": "rock"}),
			_s(AreaSkill.new("The Gate Holds", "Become untouchable for 2 s, then quake radius 5: 320 and a 1.5 s stun.", 95.0), {"radius": 5.0, "damage": 320.0, "channel": 2.0, "self_invulnerable": 2.0, "stun": 1.5, "color": Color(1.0, 0.75, 0.35), "effect": "rock"}),
		])
	d.innate_builder = func(): return _blink("Iron Stride", Color(1.0, 0.75, 0.4), 3.5)
	return d


static func seraphine() -> HeroDef:
	var d := _hero("seraphine", "Seraphine", "the Dawn Blade", "Bruiser", "Ember Forge", "Daybreak",
			"A sworn knight of the forge-temple's first light. Her blade heals as it cuts; her form rises from dawn to full noon.")
	_stats(d, 1050.0, 5.5, 6.0, 40.0, 0.85, 2.5, "str", [26.0, 20.0, 20.0], [2.8, 2.0, 2.0])
	_form(d, 14.0, 0.25, 1.25, 1.2, 1.35, ["High Noon"])
	d.exclusive_item = "dawnforged_sigil"
	d.voice = "female"
	d.voice_pitch = 0.88
	d.model_builder = func(): return RiggedModel.dressed(K + "Knight.glb", "2H_Melee_Attack_Chop", "2H_Melee_Attack_Spin", ["2H_Sword"], Color(1.0, 0.9, 0.55), Color(1.0, 0.95, 0.78))
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(StrikeSkill.new("Radiant Cut", "Slash the nearest enemy within 3: 110 and heal for a third of it.", 7.0), {"reach": 3.0, "damage": 110.0, "drain": 0.33, "beam": false, "color": Color(1.0, 0.92, 0.6)}),
			_s(AreaSkill.new("Sunburst", "Light flares around you: 120 in radius 3.5 and a 0.8 s stun.", 11.0), {"radius": 3.5, "damage": 120.0, "stun": 0.8, "color": Color(1.0, 0.9, 0.55), "effect": "column"}),
			_s(BuffSkill.new("Aegis of Dawn", "A shield of 22% max HP and 20% faster attacks for 5 s.", 15.0), {"duration": 5.0, "shield": 0.22, "haste": 1.2, "color": Color(1.0, 0.9, 0.6)}),
			_s(ProjectileSkill.new("Judgement of Light", "A wide beam of dawn pierces 18 units: 400 to all it touches.", 90.0), {"damage": 400.0, "reach": 18.0, "speed": 36.0, "pierce": true, "width": 2.0, "color": Color(1.0, 0.95, 0.7), "size": 0.45}),
		])
	d.innate_builder = func(): return _blink("Dawn Step", Color(1.0, 0.92, 0.6))
	return d


static func ashka() -> HeroDef:
	var d := _hero("ashka", "Ashka", "the Ember Sage", "Caster", "Ember Forge", "Living Pyre",
			"A scholar of the forge's oldest fires. Calls burning stars down from the smoke.")
	_stats(d, 1020.0, 4.5, 5.8, 42.0, 1.0, 6.5, "int", [18.0, 16.0, 30.0], [1.8, 1.6, 3.0])
	_form(d, 13.0, 0.2, 1.3, 1.1, 1.25)
	d.exclusive_item = "starfire_codex"
	d.voice = "female"
	d.voice_pitch = 0.92
	d.model_builder = func(): return RiggedModel.quaternius("Wizard", "Staff_Attack", "Spell1", Color(1.0, 0.55, 0.25), Color(1.0, 0.82, 0.7))
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(ProjectileSkill.new("Fire Bolt", "A bolt of fire: 140 (+35% per rank) to the first enemy hit.", 6.0), {"damage": 140.0, "speed": 24.0, "color": Color(1.0, 0.5, 0.2), "size": 0.32}),
			_s(AreaSkill.new("Smoulder", "Set the ground 5 ahead burning for 4 s: 45/s in radius 3.", 12.0), {"ahead": 5.0, "radius": 3.0, "zone_time": 4.0, "damage": 45.0, "color": Color(1.0, 0.45, 0.15)}),
			_s(StrikeSkill.new("Cinder Brand", "Brand the nearest enemy within 7: 100 and a 1.4 s root.", 10.0), {"reach": 7.0, "damage": 100.0, "root": 1.4, "color": Color(1.0, 0.55, 0.25)}),
			_s(ChainStrikeSkill.new("Starfall", "Six falling stars strike enemies within 10: 210 each and a short stun.", 95.0), {"radius": 10.0, "strikes": 6, "interval": 0.25, "damage": 210.0, "stun": 0.6, "color": Color(1.0, 0.6, 0.25)}),
		])
	d.innate_builder = func(): return _blink("Smoke Shift", Color(1.0, 0.6, 0.3))
	return d


# ==================================================================== Gale Peaks
static func isolde() -> HeroDef:
	var d := _hero("isolde", "Isolde", "the Frost Admiral", "Caster", "Gale Peaks", "Glacier Crown",
			"Admiral of the frozen sky-fleet. What she touches stops: first slowed, then frozen solid.")
	_stats(d, 1040.0, 4.5, 5.8, 40.0, 1.0, 6.0, "int", [20.0, 16.0, 29.0], [2.0, 1.6, 3.0])
	_form(d, 14.0, 0.2, 1.25, 1.1, 1.3, ["Absolute Zero"])
	d.exclusive_item = "rimeglass_compass"
	d.voice = "female"
	d.voice_pitch = 0.85
	d.model_builder = func(): return RiggedModel.dressed(K + "Mage.glb", "Spellcast_Shoot", "Spellcast_Raise", ["2H_Staff"], Color(0.6, 0.85, 1.0), Color(0.72, 0.86, 1.0))
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(ProjectileSkill.new("Ice Shard", "A shard of ice: 100 to the first enemy hit and a 0.6 s freeze.", 7.0), {"damage": 100.0, "speed": 26.0, "stun": 0.6, "color": Color(0.7, 0.9, 1.0), "size": 0.28}),
			_s(AreaSkill.new("Frost Field", "Freeze the ground 5 ahead for 4 s: 35/s in radius 3.2 and a 50% slow.", 12.0), {"ahead": 5.0, "radius": 3.2, "zone_time": 4.0, "damage": 35.0, "slow": 0.5, "color": Color(0.65, 0.88, 1.0)}),
			_s(StrikeSkill.new("Glacial Grip", "Encase the nearest enemy within 7 in ice: 90 and a 1.6 s stun.", 13.0), {"reach": 7.0, "damage": 90.0, "stun": 1.6, "color": Color(0.7, 0.9, 1.0)}),
			_s(AreaSkill.new("Endless Winter", "After 1 s, freeze radius 6 around you: 300 and a 2 s stun.", 95.0), {"radius": 6.0, "damage": 300.0, "channel": 1.0, "stun": 2.0, "color": Color(0.7, 0.9, 1.0), "effect": "column"}),
		])
	d.innate_builder = func(): return _blink("Frost Glide", Color(0.7, 0.9, 1.0))
	return d


static func oren() -> HeroDef:
	var d := _hero("oren", "Oren", "the Thousand Blades", "Speed", "Gale Peaks", "Hundred Edges",
			"A wandering swordsman of the high passes, gone before his blades land. His form splits his edge into a hundred, then a thousand.")
	_stats(d, 860.0, 4.5, 7.0, 32.0, 0.6, 2.3, "agi", [18.0, 30.0, 16.0], [1.8, 3.2, 1.5])
	_form(d, 12.0, 0.12, 1.3, 1.35, 1.2, ["Thousand Edges"])
	d.exclusive_item = "windcutter_tsuba"
	d.voice = "male2"
	d.voice_pitch = 1.0
	d.model_builder = func(): return RiggedModel.quaternius("Warrior", "Sword_AttackFast", "Sword_Attack", Color(0.85, 0.95, 1.0), Color(0.95, 0.97, 1.0))
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(BlinkSkill.new("Flash Cut", "Flash 6 ahead and cut everything at the landing: 110.", 7.0), {"distance": 6.0, "damage": 110.0, "radius": 2.4, "color": Color(0.85, 0.95, 1.0)}),
			_s(ProjectileSkill.new("Wind Edge", "Three wind blades in a fan: 80 each.", 9.0), {"damage": 80.0, "count": 3, "spread_deg": 20.0, "speed": 30.0, "color": Color(0.8, 0.95, 1.0), "size": 0.22}),
			_s(BuffSkill.new("Still Mind", "For 4 s attack 60% faster and take 20% less damage.", 13.0), {"duration": 4.0, "haste": 1.6, "guard": 0.2, "color": Color(0.85, 0.95, 1.0)}),
			_s(ChainStrikeSkill.new("Thousand Cut Storm", "Ten flashing cuts on enemies within 8: 140 each.", 90.0), {"radius": 8.0, "strikes": 10, "interval": 0.1, "damage": 140.0, "stun": 0.2, "color": Color(0.85, 0.95, 1.0)}),
		])
	d.innate_builder = func(): return _blink("Gale Step", Color(0.85, 0.95, 1.0), 5.0)
	return d


static func kestrel() -> HeroDef:
	var d := _hero("kestrel", "Kestrel", "the Sky Lancer", "Ranged", "Gale Peaks", "Skyhunter",
			"A rider of the peak winds who throws lances from impossible heights.")
	_stats(d, 1000.0, 4.5, 6.5, 48.0, 0.85, 7.0, "agi", [18.0, 28.0, 20.0], [1.8, 3.0, 2.0])
	_form(d, 13.0, 0.15, 1.3, 1.2, 1.2)
	d.exclusive_item = "galespire_lance"
	d.voice = "male3"
	d.voice_pitch = 1.12
	d.model_builder = func(): return RiggedModel.dressed(K + "Rogue.glb", "1H_Ranged_Shoot", "1H_Ranged_Shoot", ["1H_Crossbow"], Color(0.7, 0.9, 1.0), Color(0.75, 0.9, 1.0))
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(ProjectileSkill.new("Skylance", "A piercing lance down a 14-unit line: 140 to all it passes.", 8.0), {"damage": 140.0, "reach": 14.0, "speed": 34.0, "pierce": true, "width": 1.0, "color": Color(0.75, 0.92, 1.0), "size": 0.25}),
			_s(ProjectileSkill.new("Hook Lance", "A lance that drags the first enemy hit back to you: 90.", 12.0), {"damage": 90.0, "pull": true, "speed": 30.0, "color": Color(0.7, 0.85, 1.0), "size": 0.25}),
			_s(AreaSkill.new("Downdraft", "Slam the air 6 ahead: 100 in radius 3 and knock enemies away.", 12.0), {"ahead": 6.0, "radius": 3.0, "damage": 100.0, "knockback": 8.0, "color": Color(0.75, 0.92, 1.0)}),
			_s(ProjectileSkill.new("Stormspear", "Five lances in a wide fan: 260 each.", 90.0), {"damage": 260.0, "count": 5, "spread_deg": 14.0, "speed": 36.0, "reach": 16.0, "color": Color(0.8, 0.95, 1.0), "size": 0.35}),
		])
	d.innate_builder = func(): return _blink("Updraft", Color(0.75, 0.92, 1.0))
	return d


static func thane() -> HeroDef:
	var d := _hero("thane", "Thane", "the Storm Herald", "Giant", "Gale Peaks", "Stormborn",
			"A giant who walks inside the thunderheads. His form climbs three stages, until he is the storm.")
	_stats(d, 1420.0, 5.5, 5.2, 54.0, 1.25, 2.6, "str", [30.0, 15.0, 18.0], [3.1, 1.5, 1.8])
	_form(d, 14.0, 0.3, 1.2, 1.05, 1.45, ["Tempest Lord", "Sky Titan"])
	d.exclusive_item = "thunderheart_torc"
	d.voice = "male1"
	d.voice_pitch = 0.82
	d.model_builder = func(): return RiggedModel.dressed(K + "Barbarian.glb", "2H_Melee_Attack_Chop", "2H_Melee_Attack_Spin", ["2H_Axe"], Color(0.6, 0.8, 1.0), Color(0.72, 0.8, 1.0), 2.6)
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(AreaSkill.new("Thunderclap", "Clap thunder around you: 110 in radius 3.5 and a 35% slow.", 9.0), {"radius": 3.5, "damage": 110.0, "slow": 0.35, "color": Color(0.7, 0.85, 1.0)}),
			_s(StrikeSkill.new("Lightning Grasp", "Seize the nearest enemy within 6 with lightning: 100 and pull it in.", 12.0), {"reach": 6.0, "damage": 100.0, "pull": true, "color": Color(0.7, 0.85, 1.0)}),
			_s(BuffSkill.new("Storm Mantle", "A storm shield of 20% max HP and 25% less damage for 5 s.", 15.0), {"duration": 5.0, "shield": 0.2, "guard": 0.25, "color": Color(0.7, 0.85, 1.0)}),
			_s(ChainStrikeSkill.new("Heavenhammer", "Five lightning hammers strike enemies within 9: 240 each and a 1 s stun.", 95.0), {"radius": 9.0, "strikes": 5, "interval": 0.25, "damage": 240.0, "stun": 1.0, "color": Color(0.75, 0.88, 1.0)}),
		])
	d.innate_builder = func(): return _blink("Storm Leap", Color(0.7, 0.85, 1.0), 4.0)
	return d


# ================================================================= Stone Barrows
static func dunmar() -> HeroDef:
	var d := _hero("dunmar", "Dunmar", "the Sand Warden", "Giant", "Stone Barrows", "Dune Colossus",
			"Guardian of the buried barrow-roads. His sand rises as a shield for him and a prison for his foes.")
	_stats(d, 1480.0, 5.5, 5.0, 48.0, 1.2, 2.5, "str", [31.0, 14.0, 18.0], [3.1, 1.4, 1.8])
	_form(d, 15.0, 0.4, 1.2, 1.0, 1.55)
	d.exclusive_item = "dunestone_urn"
	d.voice = "male3"
	d.voice_pitch = 0.8
	d.model_builder = func(): return RiggedModel.dressed(K + "Barbarian.glb", "1H_Melee_Attack_Chop", "2H_Melee_Attack_Spin", ["1H_Axe", "Barbarian_Round_Shield"], Color(1.0, 0.85, 0.5), Color(1.0, 0.9, 0.68), 2.7)
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(StrikeSkill.new("Sand Coffin", "Bury the nearest enemy within 7 in sand: 90 and a 2 s root.", 10.0), {"reach": 7.0, "damage": 90.0, "root": 2.0, "color": Color(1.0, 0.85, 0.5)}),
			_s(BuffSkill.new("Sand Shield", "A shield of sand worth 25% max HP for 6 s.", 14.0), {"duration": 6.0, "shield": 0.25, "color": Color(1.0, 0.88, 0.55)}),
			_s(AreaSkill.new("Quicksand", "Turn the ground 4 ahead to quicksand for 4 s: 35/s in radius 3.5 and a 55% slow.", 13.0), {"ahead": 4.0, "radius": 3.5, "zone_time": 4.0, "damage": 35.0, "slow": 0.55, "color": Color(0.95, 0.8, 0.45), "effect": "rock"}),
			_s(AreaSkill.new("Desert Funeral", "After 1 s, crush radius 5.5 under the dunes: 340 and a 1.8 s stun.", 95.0), {"radius": 5.5, "damage": 340.0, "channel": 1.0, "stun": 1.8, "color": Color(1.0, 0.85, 0.5), "effect": "rock"}),
		])
	d.innate_builder = func(): return _blink("Sand Shift", Color(1.0, 0.85, 0.5), 3.5)
	return d


static func mire() -> HeroDef:
	var d := _hero("mire", "Mire", "the Bog Witch", "Caster", "Stone Barrows", "Swamp Queen",
			"She lives where the barrows sink into the marsh, and the marsh answers her call.")
	_stats(d, 1060.0, 4.5, 5.6, 42.0, 1.0, 5.5, "int", [19.0, 16.0, 30.0], [1.9, 1.5, 3.0])
	_form(d, 14.0, 0.2, 1.3, 1.1, 1.3)
	d.exclusive_item = "marshlight_lantern"
	d.voice = "female"
	d.voice_pitch = 0.78
	d.model_builder = func(): return RiggedModel.dressed(K + "Skeleton_Mage.glb", "Spellcast_Shoot", "Spellcast_Summon", [], Color(0.55, 0.9, 0.45), Color(0.62, 0.88, 0.55), 2.2, [["handslot_r", SW + "Skeleton_Staff.gltf"]])
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(SummonSkill.new("Bog Spawn", "Call three bog spawn for 16 s (520 HP, +30% per rank).", 14.0), {"kind": "bog", "count": 3, "lifetime": 16.0, "color": Color(0.5, 0.85, 0.4)}),
			_s(ProjectileSkill.new("Mire Bolt", "A bolt of swamp water: 130 and a 0.6 s stun to the first enemy hit.", 8.0), {"damage": 130.0, "stun": 0.6, "speed": 22.0, "color": Color(0.5, 0.85, 0.4), "size": 0.3}),
			_s(AreaSkill.new("Choking Fog", "Fog the ground 5 ahead for 5 s: 35/s in radius 3.5 and a 35% slow.", 13.0), {"ahead": 5.0, "radius": 3.5, "zone_time": 5.0, "damage": 35.0, "slow": 0.35, "color": Color(0.45, 0.75, 0.4)}),
			_s(SummonSkill.new("Drowned Host", "Raise five bog spawn for 22 s.", 100.0), {"kind": "bog", "count": 5, "lifetime": 22.0, "color": Color(0.5, 0.85, 0.4)}),
		])
	d.innate_builder = func(): return _blink("Marsh Step", Color(0.5, 0.85, 0.4))
	return d


static func halvard() -> HeroDef:
	var d := _hero("halvard", "Halvard", "the Runecarver", "Bruiser", "Stone Barrows", "Rune-Wrought",
			"A stonemason who carves runes into the barrow-stones until they stand up and fight.")
	_stats(d, 1100.0, 5.0, 5.8, 44.0, 0.95, 2.4, "str", [27.0, 18.0, 22.0], [2.8, 1.8, 2.2])
	_form(d, 15.0, 0.3, 1.25, 1.15, 1.35, ["Living Monument"])
	d.exclusive_item = "carvers_chisel"
	d.voice = "male3"
	d.voice_pitch = 0.92
	d.model_builder = func(): return RiggedModel.dressed(K + "Knight.glb", "1H_Melee_Attack_Chop", "2H_Melee_Attack_Spin", ["1H_Sword", "Rectangle_Shield"], Color(0.7, 0.8, 1.0), Color(0.8, 0.82, 0.86))
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(StrikeSkill.new("Rune Strike", "Strike the nearest enemy within 3 with a carved rune: 120 and a 0.8 s stun.", 8.0), {"reach": 3.0, "damage": 120.0, "stun": 0.8, "beam": false, "color": Color(0.7, 0.8, 1.0)}),
			_s(SummonSkill.new("Rune Guardian", "Raise one rune guardian for 20 s (850 HP, +30% per rank).", 16.0), {"kind": "rune", "count": 1, "lifetime": 20.0, "color": Color(0.7, 0.8, 1.0)}),
			_s(AreaSkill.new("Glyph of Warding", "A ward around you: 110 in radius 3.5 and you take no damage for 1 s.", 13.0), {"radius": 3.5, "damage": 110.0, "self_invulnerable": 1.0, "color": Color(0.7, 0.8, 1.0), "effect": "column"}),
			_s(SummonSkill.new("Circle of Stones", "Raise three rune guardians for 24 s.", 100.0), {"kind": "rune", "count": 3, "lifetime": 24.0, "color": Color(0.7, 0.8, 1.0)}),
		])
	d.innate_builder = func(): return _blink("Stone Step", Color(0.7, 0.8, 1.0), 3.5)
	return d


static func wren() -> HeroDef:
	var d := _hero("wren", "Wren", "the Cairn Archer", "Ranged", "Stone Barrows", "Barrow Sight",
			"A watcher of the barrow-cairns who never misses what she has marked.")
	_stats(d, 1000.0, 4.5, 6.3, 50.0, 0.9, 7.5, "agi", [18.0, 29.0, 20.0], [1.8, 3.0, 2.0])
	_form(d, 13.0, 0.15, 1.3, 1.15, 1.2)
	d.exclusive_item = "cairnwood_bow"
	d.voice = "female"
	d.voice_pitch = 1.12
	d.model_builder = func(): return RiggedModel.dressed(K + "Rogue_Hooded.glb", "2H_Ranged_Shoot", "2H_Ranged_Shoot", ["2H_Crossbow"], Color(0.7, 0.9, 0.55), Color(0.75, 0.88, 0.62))
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(ProjectileSkill.new("Marking Arrow", "An arrow that roots the first enemy hit for 1 s (stun) and deals 100.", 9.0), {"damage": 100.0, "stun": 1.0, "speed": 30.0, "color": Color(0.75, 0.95, 0.55), "size": 0.2}),
			_s(ProjectileSkill.new("Cairn Volley", "Four arrows in a fan: 90 each.", 9.0), {"damage": 90.0, "count": 4, "spread_deg": 14.0, "speed": 30.0, "color": Color(0.75, 0.95, 0.55), "size": 0.18}),
			_s(AreaSkill.new("Stone Rain", "Stones rain 6 ahead for 3 s: 45/s in radius 3.", 13.0), {"ahead": 6.0, "radius": 3.0, "zone_time": 3.0, "damage": 45.0, "color": Color(0.7, 0.7, 0.6), "effect": "rock"}),
			_s(ProjectileSkill.new("Barrowpiercer", "A shaft that pierces a 22-unit line: 440 to all it passes.", 90.0), {"damage": 440.0, "reach": 22.0, "speed": 42.0, "pierce": true, "width": 1.5, "color": Color(0.8, 1.0, 0.6), "size": 0.4}),
		])
	d.innate_builder = func(): return _blink("Cairn Hop", Color(0.75, 0.95, 0.55))
	return d


# =================================================================== Hollow Moon
static func corin() -> HeroDef:
	var d := _hero("corin", "Corin", "the Spirit Fist", "Bruiser", "Hollow Moon", "Spirit Surge",
			"A street fighter who channels his spirit through his fists. Reach 250 strength and 250 agility and he becomes something else for good.")
	_stats(d, 1000.0, 5.0, 6.3, 38.0, 0.75, 2.3, "agi", [24.0, 26.0, 16.0], [3.0, 3.0, 1.5])
	_form(d, 13.0, 0.2, 1.3, 1.25, 1.3, ["Spirit Overflow"])
	d.exclusive_item = "spiritbound_knuckles"
	d.voice = "male2"
	d.voice_pitch = 0.95
	d.evolve_at = {"str": 250.0, "agi": 250.0}
	d.evolve_into = MoreHeroes.corin_unbound
	d.model_builder = func(): return RiggedModel.quaternius("Monk", "Attack", "Attack2", Color(0.55, 0.75, 1.0))
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(ProjectileSkill.new("Spirit Shot", "Fire a bolt of spirit from your finger: 120 to the first enemy hit.", 7.0), {"damage": 120.0, "speed": 32.0, "color": Color(0.55, 0.8, 1.0), "size": 0.3}),
			_s(StrikeSkill.new("Spirit Fist", "Punch the nearest enemy within 3: 110 and knock the wind out (1 s stun).", 9.0), {"reach": 3.0, "damage": 110.0, "stun": 1.0, "beam": false, "color": Color(0.55, 0.8, 1.0)}),
			_s(BuffSkill.new("Fighting Spirit", "Attack 50% faster and take 15% less damage for 5 s.", 14.0), {"duration": 5.0, "haste": 1.5, "guard": 0.15, "color": Color(0.55, 0.8, 1.0)}),
			_s(ProjectileSkill.new("Spirit Cannon", "A huge spirit blast down a 16-unit line: 420 to all it passes.", 90.0), {"damage": 420.0, "reach": 16.0, "speed": 30.0, "pierce": true, "width": 2.2, "color": Color(0.6, 0.85, 1.0), "size": 0.6}),
		])
	d.innate_builder = func(): return _blink("Spirit Step", Color(0.55, 0.8, 1.0))
	return d


## Corin's evolution (250 STR and 250 AGI): a new kit and look, for good.
static func corin_unbound() -> HeroDef:
	var d := _hero("corin", "Corin Unbound", "the Demon Heart", "Bruiser", "Hollow Moon", "Demon Awakening",
			"The spirit inside Corin has woken. Stronger, faster and hungrier than before.")
	_stats(d, 1300.0, 7.0, 6.8, 52.0, 0.7, 2.4, "agi", [24.0, 26.0, 16.0], [3.0, 3.0, 1.5])
	_form(d, 15.0, 0.3, 1.4, 1.3, 1.35, ["Demon Unchained"])
	d.voice = "male1"
	d.voice_pitch = 0.75
	d.model_builder = func(): return RiggedModel.quaternius("Monk", "Attack2", "Attack", Color(1.0, 0.35, 0.3), Color(1.0, 0.55, 0.5), 2.5)
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(ProjectileSkill.new("Demon Shot", "Three demon bolts in a fan: 140 each.", 7.0), {"damage": 140.0, "count": 3, "spread_deg": 12.0, "speed": 34.0, "color": Color(1.0, 0.4, 0.35), "size": 0.32}),
			_s(StrikeSkill.new("Demon Fist", "Crush the nearest enemy within 3: 160, a 1.2 s stun, and heal for half.", 9.0), {"reach": 3.0, "damage": 160.0, "stun": 1.2, "drain": 0.5, "beam": false, "color": Color(1.0, 0.4, 0.35)}),
			_s(AreaSkill.new("Demon Roar", "A roar around you: 150 in radius 4 and knock enemies back.", 13.0), {"radius": 4.0, "damage": 150.0, "knockback": 9.0, "color": Color(1.0, 0.4, 0.35)}),
			_s(ChainStrikeSkill.new("Demon Barrage", "Ten demon blows on enemies within 8: 220 each.", 90.0), {"radius": 8.0, "strikes": 10, "interval": 0.12, "damage": 220.0, "stun": 0.3, "color": Color(1.0, 0.4, 0.35)}),
		])
	d.innate_builder = func(): return _blink("Demon Step", Color(1.0, 0.4, 0.35), 5.5)
	return d


static func velka() -> HeroDef:
	var d := _hero("velka", "Velka", "the Moon Huntress", "Ranged", "Hollow Moon", "Blood Moon",
			"She hunts by moonlight and her bolts find the wounded first.")
	_stats(d, 880.0, 4.0, 6.6, 42.0, 0.8, 7.0, "agi", [17.0, 30.0, 19.0], [1.7, 3.1, 1.9])
	_form(d, 13.0, 0.15, 1.35, 1.2, 1.2)
	d.exclusive_item = "moonsilver_quiver"
	d.voice = "female"
	d.voice_pitch = 0.95
	d.model_builder = func(): return RiggedModel.quaternius("Ranger", "Bow_Attack_Shoot", "Bow_Attack_Draw", Color(0.8, 0.6, 1.0), Color(0.88, 0.8, 1.0))
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(ProjectileSkill.new("Moonbolt", "A silver bolt: 110 to the first enemy hit.", 6.0), {"damage": 110.0, "speed": 32.0, "color": Color(0.85, 0.75, 1.0), "size": 0.22}),
			_s(StrikeSkill.new("Huntmark", "Wound the nearest enemy within 8: 95 and a 50% slow for 3 s.", 10.0), {"reach": 8.0, "damage": 95.0, "slow": 0.5, "slow_time": 3.0, "color": Color(0.8, 0.6, 1.0)}),
			_s(ProjectileSkill.new("Crescent Spread", "Five bolts in a crescent: 70 each.", 10.0), {"damage": 70.0, "count": 5, "spread_deg": 12.0, "speed": 30.0, "color": Color(0.85, 0.75, 1.0), "size": 0.2}),
			_s(ChainStrikeSkill.new("Moonfall Volley", "Eight bolts fall on enemies within 10: 190 each.", 90.0), {"radius": 10.0, "strikes": 8, "interval": 0.15, "damage": 190.0, "stun": 0.3, "color": Color(0.85, 0.75, 1.0)}),
		])
	d.innate_builder = func(): return _blink("Moon Step", Color(0.85, 0.75, 1.0))
	return d


static func nyx() -> HeroDef:
	var d := _hero("nyx", "Nyx", "the Shade Dancer", "Speed", "Hollow Moon", "Umbral Veil",
			"An assassin made of the moon's shadow. Strikes from nowhere and is gone again.")
	_stats(d, 840.0, 4.5, 7.0, 34.0, 0.6, 2.2, "agi", [17.0, 30.0, 17.0], [1.7, 3.2, 1.6])
	_form(d, 11.0, 0.1, 1.4, 1.3, 1.15)
	d.exclusive_item = "nightglass_dagger"
	d.voice = "male2"
	d.voice_pitch = 1.18
	d.model_builder = func(): return RiggedModel.quaternius("Rogue", "Dagger_Attack", "Dagger_Attack2", Color(0.6, 0.5, 0.9), Color(0.62, 0.55, 0.8), 2.1)
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(BlinkSkill.new("Shadow Strike", "Step 6 through the shadows and cut all at the landing: 115.", 7.0), {"distance": 6.0, "damage": 115.0, "radius": 2.2, "color": Color(0.6, 0.5, 0.9)}),
			_s(StrikeSkill.new("Nightblade", "Stab the nearest enemy within 3: 130 and bleed it 40% slower for 2 s.", 9.0), {"reach": 3.0, "damage": 130.0, "slow": 0.4, "beam": false, "color": Color(0.6, 0.5, 0.9)}),
			_s(BuffSkill.new("Shade Dance", "Become untouchable for 1.5 s and attack 40% faster for 4 s.", 15.0), {"duration": 4.0, "haste": 1.4, "invulnerable": 1.5, "color": Color(0.6, 0.5, 0.9)}),
			_s(ChainStrikeSkill.new("Eclipse", "Nine shadow cuts on enemies within 8: 170 each.", 90.0), {"radius": 8.0, "strikes": 9, "interval": 0.1, "damage": 170.0, "stun": 0.25, "color": Color(0.6, 0.5, 0.9)}),
		])
	d.innate_builder = func(): return _blink("Shadowstep", Color(0.6, 0.5, 0.9), 5.0)
	return d


static func lys() -> HeroDef:
	var d := _hero("lys", "Lys", "the Tidecaller", "Caster", "Hollow Moon", "Spring Tide",
			"Priestess of the moon's tides. Her waves heal her and drown her foes.")
	_stats(d, 1080.0, 5.5, 5.8, 40.0, 1.0, 6.0, "int", [20.0, 17.0, 29.0], [2.0, 1.7, 3.0])
	_form(d, 14.0, 0.25, 1.25, 1.1, 1.3, ["King Tide"])
	d.exclusive_item = "tidepearl_circlet"
	d.voice = "female"
	d.voice_pitch = 1.05
	d.model_builder = func(): return RiggedModel.quaternius("Cleric", "Staff_Attack", "Spell2", Color(0.5, 1.0, 0.95), Color(0.75, 1.0, 0.97))
	d.skills_builder = func() -> Array[Skill]:
		return HeroDef.arrange([
			_s(ProjectileSkill.new("Tide Wave", "A wave rolls 12 units: 125 to everything it passes.", 8.0), {"damage": 125.0, "reach": 12.0, "speed": 20.0, "pierce": true, "width": 2.0, "color": Color(0.5, 0.95, 1.0), "size": 0.4}),
			_s(StrikeSkill.new("Undertow", "Drag the nearest enemy within 7 to you: 90, and heal for all of it.", 11.0), {"reach": 7.0, "damage": 90.0, "pull": true, "drain": 1.0, "color": Color(0.5, 0.95, 1.0)}),
			_s(AreaSkill.new("Whirlpool", "A whirlpool 5 ahead for 4 s: 40/s in radius 3.2 and a 45% slow.", 13.0), {"ahead": 5.0, "radius": 3.2, "zone_time": 4.0, "damage": 40.0, "slow": 0.45, "color": Color(0.5, 0.9, 1.0)}),
			_s(AreaSkill.new("Moon Tide", "After 1 s, a flood around you: 320 in radius 6 and knock enemies far back.", 95.0), {"radius": 6.0, "damage": 320.0, "channel": 1.0, "knockback": 14.0, "color": Color(0.55, 0.95, 1.0), "effect": "column"}),
		])
	d.innate_builder = func(): return _blink("Tidal Drift", Color(0.5, 0.95, 1.0))
	return d
