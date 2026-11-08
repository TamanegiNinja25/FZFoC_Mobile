class_name Roster
extends RefCounted
## Every hero in the game, and the categories shown on the hero select screen.
## A planned hero is listed as a locked slot until its definition exists.

const ROLES := ["Bruiser", "Speed", "Giant"]

## Planned slots shown as "coming soon": [role, placeholder label].
const PLANNED := [["Speed", "Speed hero"], ["Giant", "Giant hero"]]


static func all() -> Array[HeroDef]:
	return [Vael.new()]


static func create(hero_id: String) -> HeroDef:
	for definition in all():
		if definition.id == hero_id:
			return definition
	return Vael.new()
