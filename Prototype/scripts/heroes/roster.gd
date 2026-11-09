class_name Roster
extends RefCounted
## Every hero in the game, and the categories shown on the hero select screen:
## realms (the way the reference map's taverns group heroes by series) and roles.

const ROLES := ["Bruiser", "Speed", "Giant", "Ranged", "Caster"]
const REALMS := ["Ember Forge", "Gale Peaks", "Stone Barrows", "Hollow Moon"]

## Planned slots shown as "coming soon": [role, placeholder label].
const PLANNED := []


static func all() -> Array[HeroDef]:
	return [Vael.new(), Ryn.new(), Barrow.new(), NewHeroes.sable(), NewHeroes.morrow(), NewHeroes.kael(),
		NewHeroes.tamsin(), NewHeroes.hask()]


static func ids() -> Array[String]:
	var list: Array[String] = []
	for definition in all():
		list.append(definition.id)
	return list


## Bots get heroes by slot, so a match mixes the roster the same way on every device.
static func bot_hero(slot: int) -> String:
	var list := ids()
	return list[slot % list.size()]


## Unique picks, as in the reference map (each hero once per match): the k-th
## bot takes the k-th hero nobody has picked. Deterministic, so every device
## builds the same teams.
## Rotates which free heroes the bots take (the balance simulation varies it;
## matches leave it at 0 so every device agrees).
static var bot_order_seed := 0


static func unique_bot_heroes(taken: Array, bots: int) -> Array[String]:
	var free: Array[String] = []
	for hero_id in ids():
		if not taken.has(hero_id):
			free.append(hero_id)
	for i in bot_order_seed % maxi(free.size(), 1):
		free.push_back(free.pop_front())
	var picks: Array[String] = []
	for k in bots:
		picks.append(free[k % free.size()] if not free.is_empty() else bot_hero(k))
	return picks


static func create(hero_id: String) -> HeroDef:
	for definition in all():
		if definition.id == hero_id:
			return definition
	return Vael.new()
