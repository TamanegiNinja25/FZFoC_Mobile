class_name ItemDef
extends Resource
## One shop item. Stat keys (all additive across items):
##   hp (max HP), damage (attack damage), attack_speed (fraction, e.g. 0.2 = +20%),
##   move_speed (fraction), regen (HP/s), armor (damage reduction fraction),
##   meter_gain (fraction), cooldown (skill cooldown reduction fraction),
##   form_duration (seconds), str / agi / int (attribute points).
## Consumables have a `use` effect instead and are spent when tapped.
## Tomes (the stat shop) are used up the moment they're bought, like the
## reference map's power-ups: `tome` adds attribute points for good, `xp` grants XP.

@export var id := ""
@export var display_name := ""
@export var category := ""
@export var cost := 0
@export var description := ""
@export var stats := {}
@export var consumable := false
## Consumable effect: "heal" (amount over 5 s), "meter" (instant charge),
## "recall", "knife", "cloak", "capture" or "release".
@export var use := ""
@export var use_amount := 0.0
## Stat-shop tome: attribute points granted on purchase, e.g. {"str": 2}.
@export var tome := {}
## Stat-shop tome: experience granted on purchase.
@export var xp := 0.0
## Exclusive item: only the hero with this id can buy it.
@export var hero_only := ""
## Artifacts are made at the combining circle, never bought.
@export var buyable := true


static func make(id_: String, name_: String, category_: String, cost_: int, description_: String, stats_ := {}, use_ := "", amount := 0.0) -> ItemDef:
	var item := ItemDef.new()
	item.id = id_
	item.display_name = name_
	item.category = category_
	item.cost = cost_
	item.description = description_
	item.stats = stats_
	item.use = use_
	item.use_amount = amount
	item.consumable = use_ != ""
	return item


func is_tome() -> bool:
	return not tome.is_empty() or xp > 0.0


func icon() -> Texture2D:
	var path := "res://assets/icons/items/%s.png" % id
	return load(path) if ResourceLoader.exists(path) else null
