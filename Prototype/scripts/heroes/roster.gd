class_name Roster
extends RefCounted
## Every hero in the game, and the categories shown on the hero select screen.
## A planned hero is listed as a locked slot until its definition exists.

const ROLES := ["Bruiser", "Speed", "Giant"]

## Planned slots shown as "coming soon": [role, placeholder label].
const PLANNED := []


static func all() -> Array[HeroDef]:
	return [Vael.new(), Ryn.new(), Barrow.new()]


## Bots get heroes by slot, so a match mixes the roster the same way on every device.
static func bot_hero(slot: int) -> String:
	var ids := ["vael", "ryn", "barrow"]
	return ids[slot % ids.size()]


static func create(hero_id: String) -> HeroDef:
	for definition in all():
		if definition.id == hero_id:
			return definition
	return Vael.new()
