class_name ItemCatalog
extends RefCounted
## Every item, by shop category. Names and icons are original.
## Gold is on the reference map's scale (a hero kill pays 500): shop items cost
## 1,000–9,000, exclusive items 10,000, and the stat shop keeps the map's prices.

const CATEGORIES := ["Weapons", "Armor", "Mobility", "Relics", "Consumables", "Stats", "Exclusive", "Artifacts"]
const INVENTORY_SIZE := 6
## The reference map pawns items for 75%.
const SELL_RATE := 0.75
## Combining circle recipes, checked in this order (as the map's triggers are):
## carry every part into the circle and they fuse into the result.
const RECIPES := [
	["pyreheart_brand", ["forgebreaker_maul", "kindling_rune"]],
	["bastion_aegis", ["riveted_mail", "bulwark_plate"]],
	["titans_cleaver", ["riveted_mail", "forgebreaker_maul"]],
	["galestride_boots", ["wayfarers_treads", "quickening_gauntlets"]],
	["champions_medallion", ["riveted_mail", "wayfarers_treads", "kindling_rune"]],
	["wellspring_stone", ["emberheart_amulet", "sages_hourglass"]],
	["sovereign_blade", ["forgebreaker_maul", "bulwark_plate"]],
]
## Bots buy in this order when they're at their fountain with enough gold
## ("exclusive" means the bot hero's own exclusive item). Two recipe pairs
## (Bastion Aegis, Sovereign Blade) are in the build so bots use the circle.
const BOT_BUILD := ["tempered_blade", "riveted_mail", "bulwark_plate", "wayfarers_treads", "forgebreaker_maul", "exclusive", "kindling_rune"]


static var _all: Array[ItemDef] = []


## Every item, built once and shared (items are read-only definitions).
static func all() -> Array[ItemDef]:
	if _all.is_empty():
		_all = _build()
	return _all


static func _build() -> Array[ItemDef]:
	var items: Array[ItemDef] = [
		ItemDef.make("tempered_blade", "Tempered Blade", "Weapons", 3000, "+12 attack damage.", {"damage": 12.0}),
		ItemDef.make("quickening_gauntlets", "Quickening Gauntlets", "Weapons", 3500, "+20% attack speed.", {"attack_speed": 0.2}),
		ItemDef.make("forgebreaker_maul", "Forgebreaker Maul", "Weapons", 9000, "+30 attack damage, +10% attack speed.", {"damage": 30.0, "attack_speed": 0.1}),
		ItemDef.make("riveted_mail", "Riveted Mail", "Armor", 3000, "+200 max HP.", {"hp": 200.0}),
		ItemDef.make("bulwark_plate", "Bulwark Plate", "Armor", 5000, "Take 15% less damage.", {"armor": 0.15}),
		ItemDef.make("emberheart_amulet", "Emberheart Amulet", "Armor", 3500, "+4 HP per second.", {"regen": 4.0}),
		ItemDef.make("wayfarers_treads", "Wayfarer's Treads", "Mobility", 2500, "+15% move speed.", {"move_speed": 0.15}),
		ItemDef.make("windstep_greaves", "Windstep Greaves", "Mobility", 6000, "+25% move speed.", {"move_speed": 0.25}),
		ItemDef.make("kindling_rune", "Kindling Rune", "Relics", 4500, "Transformation meter charges 25% faster.", {"meter_gain": 0.25}),
		ItemDef.make("everflame_sigil", "Everflame Sigil", "Relics", 6000, "Transformation lasts 4 s longer.", {"form_duration": 4.0}),
		ItemDef.make("sages_hourglass", "Sage's Hourglass", "Relics", 5000, "Skills recharge 20% faster.", {"cooldown": 0.2}),
		ItemDef.make("ember_draught", "Ember Draught", "Consumables", 1000, "Tap to heal 400 HP over 5 s.", {}, "heal", 400.0),
		ItemDef.make("spark_flask", "Spark Flask", "Consumables", 2000, "Tap to charge the meter by 25.", {}, "meter", 25.0),
	]
	# Stat shop — the reference map's tomes and prices, used up on purchase.
	for spec in [["tome_str_2", "Tome of Might +2", 250, {"str": 2}], ["tome_agi_2", "Tome of Grace +2", 200, {"agi": 2}],
			["tome_str_5", "Tome of Might +5", 600, {"str": 5}], ["tome_agi_5", "Tome of Grace +5", 500, {"agi": 5}],
			["tome_all_100", "Codex of Ascension", 19000, {"str": 100, "agi": 100, "int": 100}]]:
		var tome := ItemDef.make(spec[0], spec[1], "Stats", spec[2], "Permanently +%s." % _attribute_text(spec[3]))
		tome.tome = spec[3]
		items.append(tome)
	for spec in [["tome_xp_minor", "Minor Tome of Lore", 150, 100.0], ["tome_xp_greater", "Greater Tome of Lore", 450, 500.0]]:
		var lore := ItemDef.make(spec[0], spec[1], "Stats", spec[2], "Gain %d experience." % spec[3])
		lore.xp = spec[3]
		items.append(lore)
	# Exclusive items — one signature item per hero, 10,000 gold like the map's.
	for spec in [["kilnheart_core", "Kilnheart Core", "vael", "+10 strength, +6 agility, +20 attack damage, +10% skill recharge.",
				{"str": 10.0, "agi": 6.0, "damage": 20.0, "cooldown": 0.1}],
			["galeheart_ribbon", "Galeheart Ribbon", "ryn", "+12 agility, +25% attack speed, +10% move speed.",
				{"agi": 12.0, "attack_speed": 0.25, "move_speed": 0.1}],
			["cairnstone_heart", "Cairnstone Heart", "barrow", "+15 strength, +400 max HP, take 10% less damage.",
				{"str": 15.0, "hp": 400.0, "armor": 0.1}]]:
		var item := ItemDef.make(spec[0], spec[1], "Exclusive", 10000, "%s only. %s" % [spec[2].capitalize(), spec[3]], spec[4])
		item.hero_only = spec[2]
		items.append(item)
	# Artifacts — made at the combining circle; sell value is the parts' total.
	for spec in [["pyreheart_brand", "Pyreheart Brand", "+45 attack damage, +15% attack speed, meter charges 35% faster.", {"damage": 45.0, "attack_speed": 0.15, "meter_gain": 0.35}],
			["bastion_aegis", "Bastion Aegis", "+450 max HP, take 22% less damage.", {"hp": 450.0, "armor": 0.22}],
			["titans_cleaver", "Titan's Cleaver", "+300 max HP, +45 attack damage.", {"hp": 300.0, "damage": 45.0}],
			["galestride_boots", "Galestride Boots", "+25% move speed, +30% attack speed.", {"move_speed": 0.25, "attack_speed": 0.3}],
			["champions_medallion", "Champion's Medallion", "+8 to every attribute, +15% move speed, meter charges 30% faster.", {"str": 8.0, "agi": 8.0, "int": 8.0, "move_speed": 0.15, "meter_gain": 0.3}],
			["wellspring_stone", "Wellspring Stone", "+9 HP per second, skills recharge 30% faster.", {"regen": 9.0, "cooldown": 0.3}],
			["sovereign_blade", "Sovereign Blade", "+45 attack damage, take 20% less damage.", {"damage": 45.0, "armor": 0.2}]]:
		var artifact := ItemDef.make(spec[0], spec[1], "Artifacts", 0, spec[2], spec[3])
		artifact.buyable = false
		items.append(artifact)
	for artifact in items:
		if not artifact.buyable:
			for part_id in parts_of(artifact.id):
				for part in items:
					if part.id == part_id:
						artifact.cost += part.cost
	return items


static func _attribute_text(points: Dictionary) -> String:
	var names := {"str": "strength", "agi": "agility", "int": "intelligence"}
	var parts: Array[String] = []
	for key in points:
		parts.append("%d %s" % [points[key], names[key]])
	return ", ".join(parts) if points.size() < 3 else "%d to every attribute" % points.values()[0]


static func parts_of(artifact_id: String) -> Array:
	for recipe in RECIPES:
		if recipe[0] == artifact_id:
			return recipe[1]
	return []


## Recipe text for the shop, e.g. "Riveted Mail + Bulwark Plate".
static func recipe_text(artifact_id: String) -> String:
	var names: Array[String] = []
	for part_id in parts_of(artifact_id):
		var part := find(part_id)
		names.append(part.display_name if part else part_id)
	return " + ".join(names)


static func find(item_id: String) -> ItemDef:
	for item in all():
		if item.id == item_id:
			return item
	return null


static func in_category(category: String) -> Array[ItemDef]:
	var result: Array[ItemDef] = []
	for item in all():
		if category == "All" or item.category == category:
			result.append(item)
	return result
