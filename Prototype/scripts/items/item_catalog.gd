class_name ItemCatalog
extends RefCounted
## Every item in the shop, by category. Names and icons are original.
## Prices assume ~2 gold/s passive income plus kill gold over an 8-minute match.

const CATEGORIES := ["Weapons", "Armor", "Mobility", "Relics", "Consumables"]
const INVENTORY_SIZE := 6
const SELL_RATE := 0.5
## Bots buy in this order when they're at their fountain with enough gold.
const BOT_BUILD := ["tempered_blade", "riveted_mail", "wayfarers_treads", "kindling_rune", "bulwark_plate", "forgebreaker_maul"]


static func all() -> Array[ItemDef]:
	return [
		ItemDef.make("tempered_blade", "Tempered Blade", "Weapons", 300, "+12 attack damage.", {"damage": 12.0}),
		ItemDef.make("quickening_gauntlets", "Quickening Gauntlets", "Weapons", 350, "+20% attack speed.", {"attack_speed": 0.2}),
		ItemDef.make("forgebreaker_maul", "Forgebreaker Maul", "Weapons", 900, "+30 attack damage, +10% attack speed.", {"damage": 30.0, "attack_speed": 0.1}),
		ItemDef.make("riveted_mail", "Riveted Mail", "Armor", 300, "+200 max HP.", {"hp": 200.0}),
		ItemDef.make("bulwark_plate", "Bulwark Plate", "Armor", 500, "Take 15% less damage.", {"armor": 0.15}),
		ItemDef.make("emberheart_amulet", "Emberheart Amulet", "Armor", 350, "+4 HP per second.", {"regen": 4.0}),
		ItemDef.make("wayfarers_treads", "Wayfarer's Treads", "Mobility", 250, "+15% move speed.", {"move_speed": 0.15}),
		ItemDef.make("windstep_greaves", "Windstep Greaves", "Mobility", 600, "+25% move speed.", {"move_speed": 0.25}),
		ItemDef.make("kindling_rune", "Kindling Rune", "Relics", 450, "Transformation meter charges 25% faster.", {"meter_gain": 0.25}),
		ItemDef.make("everflame_sigil", "Everflame Sigil", "Relics", 600, "Transformation lasts 4 s longer.", {"form_duration": 4.0}),
		ItemDef.make("sages_hourglass", "Sage's Hourglass", "Relics", 500, "Skills recharge 20% faster.", {"cooldown": 0.2}),
		ItemDef.make("ember_draught", "Ember Draught", "Consumables", 100, "Tap to heal 400 HP over 5 s.", {}, "heal", 400.0),
		ItemDef.make("spark_flask", "Spark Flask", "Consumables", 200, "Tap to charge the meter by 25.", {}, "meter", 25.0),
	]


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
