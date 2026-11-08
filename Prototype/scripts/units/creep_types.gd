class_name CreepTypes
extends RefCounted
## Every non-hero unit: the 15 creep types of the reference map's waves (its
## HP, gold and levels, under original names and looks), the two boss chains,
## the win boss and summons. A unit is rebuilt from its key on network clients.
##
## Fields: name, level, hp, damage, interval, range, bounty, size, color, shape
## ("brute", "caster", "beast", "golem").

const TYPES := {
	# 30 s wave (map: gnoll, gnoll poacher, spider, spitting spider)
	"ngno": {"name": "Mire Scavenger", "level": 1, "hp": 250, "damage": 14, "interval": 1.4, "range": 1.8, "bounty": 25, "size": 0.8, "color": Color(0.55, 0.45, 0.3), "shape": "brute"},
	"ngna": {"name": "Mire Slinger", "level": 1, "hp": 200, "damage": 11, "interval": 1.6, "range": 6.0, "bounty": 20, "size": 0.75, "color": Color(0.5, 0.5, 0.32), "shape": "caster"},
	"nspr": {"name": "Ash Crawler", "level": 1, "hp": 100, "damage": 8, "interval": 1.2, "range": 1.6, "bounty": 10, "size": 0.6, "color": Color(0.35, 0.33, 0.35), "shape": "beast"},
	"nssp": {"name": "Spitting Crawler", "level": 2, "hp": 200, "damage": 14, "interval": 1.5, "range": 5.5, "bounty": 20, "size": 0.75, "color": Color(0.4, 0.5, 0.35), "shape": "beast"},
	# 60 s wave (map: bandit, bandit lord, priest, rogue wizard, mud golem, footman, knight)
	"nban": {"name": "Road Brigand", "level": 2, "hp": 500, "damage": 18, "interval": 1.4, "range": 1.8, "bounty": 50, "size": 0.85, "color": Color(0.45, 0.35, 0.28), "shape": "brute"},
	"nbld": {"name": "Brigand Chief", "level": 4, "hp": 1500, "damage": 40, "interval": 1.4, "range": 2.0, "bounty": 100, "size": 1.1, "color": Color(0.6, 0.3, 0.22), "shape": "brute"},
	"hmpr": {"name": "Hedge Mystic", "level": 2, "hp": 400, "damage": 10, "interval": 1.8, "range": 6.0, "bounty": 50, "size": 0.8, "color": Color(0.75, 0.72, 0.6), "shape": "caster"},
	"nwzr": {"name": "Rogue Conjurer", "level": 4, "hp": 1000, "damage": 30, "interval": 1.8, "range": 6.5, "bounty": 100, "size": 0.9, "color": Color(0.45, 0.3, 0.6), "shape": "caster"},
	"ngrk": {"name": "Silt Golem", "level": 3, "hp": 500, "damage": 20, "interval": 1.6, "range": 1.8, "bounty": 75, "size": 0.95, "color": Color(0.45, 0.4, 0.32), "shape": "golem"},
	"hfoo": {"name": "Deserter", "level": 2, "hp": 400, "damage": 16, "interval": 1.4, "range": 1.8, "bounty": 50, "size": 0.85, "color": Color(0.5, 0.52, 0.56), "shape": "brute"},
	"hkni": {"name": "Fallen Knight", "level": 4, "hp": 1000, "damage": 38, "interval": 1.5, "range": 2.0, "bounty": 100, "size": 1.05, "color": Color(0.35, 0.38, 0.45), "shape": "brute"},
	# 90 s wave (map: tauren, necromancer, rock golem, druid of the claw)
	"otau": {"name": "Horned Brute", "level": 8, "hp": 2500, "damage": 70, "interval": 1.7, "range": 2.2, "bounty": 200, "size": 1.35, "color": Color(0.5, 0.36, 0.25), "shape": "brute"},
	"unec": {"name": "Bone Caller", "level": 6, "hp": 2000, "damage": 40, "interval": 1.8, "range": 6.5, "bounty": 200, "size": 0.95, "color": Color(0.7, 0.7, 0.62), "shape": "caster"},
	"ngst": {"name": "Crag Golem", "level": 5, "hp": 1000, "damage": 45, "interval": 1.8, "range": 2.0, "bounty": 150, "size": 1.2, "color": Color(0.5, 0.48, 0.45), "shape": "golem"},
	"edoc": {"name": "Wildclaw Shaman", "level": 7, "hp": 3000, "damage": 60, "interval": 1.5, "range": 2.0, "bounty": 200, "size": 1.25, "color": Color(0.32, 0.45, 0.3), "shape": "beast"},
}

## Boss chains: the reference map's HP per stage; the next boss appears 10 s
## after the last one falls. Names are original.
const CHAINS := {
	"a": {"hp": [500, 2000, 3500, 5000, 6500, 8000, 9500, 11000, 12500],
		"names": ["Gravel Hound", "Cinder Imp", "Thorn Matron", "Rust Colossus", "Murk Stalker", "Ember Drake", "Frost Revenant", "Storm Herald", "The Iron Tyrant"]},
	"b": {"hp": [500, 3500, 4500, 6000, 7500, 10000, 12500],
		"names": ["Bog Lurker", "Barrow Wight", "Briar Witch", "Dune Reaver", "Ash Titan", "Night Weaver", "The Pale Sovereign"]},
}

## The win boss: 100,000 HP, as in the reference map; killing it wins the match.
const COLOSSUS := {"name": "The Undying Colossus", "level": 20, "hp": 100000, "damage": 160, "interval": 2.0, "range": 3.2,
	"bounty": 0, "size": 2.6, "color": Color(0.42, 0.36, 0.5), "shape": "golem", "slam": [6.0, 220.0, 7.0, 1.5]}

const SUMMONS := {
	"golem": {"name": "Forge Golem", "level": 4, "hp": 900, "damage": 45, "interval": 1.2, "range": 2.0, "bounty": 50, "size": 1.0, "color": Color(0.9, 0.45, 0.15), "shape": "golem"},
}


## Stats for a key: a creep id, "boss:a:3", "colossus" or "summon:golem".
static func lookup(key: String) -> Dictionary:
	if TYPES.has(key):
		return TYPES[key]
	if key == "colossus":
		return COLOSSUS
	if key.begins_with("summon:"):
		return SUMMONS.get(key.get_slice(":", 1), SUMMONS.golem)
	if key.begins_with("boss:"):
		var chain: Dictionary = CHAINS[key.get_slice(":", 1)]
		var stage := int(key.get_slice(":", 2))
		var hp: int = chain.hp[stage]
		# Bosses hit harder each stage and slam the ground around them.
		return {"name": chain.names[stage], "level": 3 + stage * 2, "hp": hp, "damage": 30 + stage * 14, "interval": 1.6,
			"range": 2.4, "bounty": 500 + stage * 300, "size": 1.3 + stage * 0.08,
			"color": Color.from_hsv(fmod(0.08 + stage * 0.11, 1.0), 0.55, 0.6), "shape": ["brute", "beast", "golem", "caster"][stage % 4],
			"slam": [3.5 + stage * 0.15, 40.0 + stage * 25.0, 8.0, 1.0]}
	return TYPES.ngno
