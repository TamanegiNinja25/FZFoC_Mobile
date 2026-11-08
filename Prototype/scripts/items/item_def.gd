class_name ItemDef
extends Resource
## One shop item. Stat keys (all additive across items):
##   hp (max HP), damage (attack damage), attack_speed (fraction, e.g. 0.2 = +20%),
##   move_speed (fraction), regen (HP/s), armor (damage reduction fraction),
##   meter_gain (fraction), cooldown (skill cooldown reduction fraction),
##   form_duration (seconds).
## Consumables have a `use` effect instead and are spent when tapped.

@export var id := ""
@export var display_name := ""
@export var category := ""
@export var cost := 0
@export var description := ""
@export var stats := {}
@export var consumable := false
## Consumable effect: "heal" (amount over 5 s) or "meter" (instant charge).
@export var use := ""
@export var use_amount := 0.0


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


func icon() -> Texture2D:
	var path := "res://assets/icons/items/%s.png" % id
	return load(path) if ResourceLoader.exists(path) else null
