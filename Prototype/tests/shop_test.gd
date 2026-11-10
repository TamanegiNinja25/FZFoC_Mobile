extends SceneTree
## Headless check of the item shop:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/shop_test.gd
## Catalogue and categories, buying rules, stat effects, selling, consumables,
## and bots shopping on their own in the arena. (Matches typed as Node: naming
## their classes here would compile them before autoloads exist.)

var _scene: Node
var _hero: Hero
var _frames := 0
var _phase := "boot"
var _sim := 0.0
var _failures: Array[String] = []


func _initialize() -> void:
	_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(_scene)
	current_scene = _scene


func _process(delta: float) -> bool:
	_frames += 1
	_sim += delta
	match _phase:
		"boot":
			if _frames < 5:
				return false
			_hero = _scene.hero
			_catalogue()
			_buying()
			_effects()
			_consumables()
			_phase = "heal"
			_frames = 0
		"heal":
			if _frames == 1:
				_hero.hp = 300.0
				_hero.gold = 1000.0
				_hero.buy("ember_draught")
				_hero.use_item(_hero.items.size() - 1)
			if _sim > 0.0 and _frames > 2:
				pass
			if _frames > 400:  # ~6.7 s at 60 fps: the full 5 s heal-over-time
				_check(_hero.hp >= 690.0, "Ember Draught heals ~400 over 5 s (300 → %d)" % _hero.hp)
				_start_arena()
		"arena":
			var bots: Array = _scene.bots
			var shopped := bots.filter(func(b): return b.hero.items.size() > 0).size()
			if shopped >= 2:
				_check(true, "bots shop on their own (%d of 5 bought items by %.0f s)" % [shopped, _sim])
				_finish()
			elif _sim > 300.0:
				_check(false, "bots bought items within 300 s (only %d did)" % shopped)
				_finish()
	return false


func _catalogue() -> void:
	var items := ItemCatalog.all()
	var categories := {}
	for item in items:
		categories[item.category] = categories.get(item.category, 0) + 1
		_check(item.icon() != null, "icon exists for %s" % item.id) if item.icon() == null else null
	_check(categories.keys().size() == 8 and categories.values().all(func(n): return n >= 2),
			"8 categories, each with ≥2 items: %s" % str(categories))
	_check(categories.Stats == 7 and categories.Exclusive == 24 and categories.Artifacts == 7, "7 tomes, 24 exclusive items (one per hero), 7 artifacts")
	_check(ItemCatalog.in_category("Relics").size() == 4, "category filter works (4 relics, with the satchel)")


func _buying() -> void:
	_hero.gold = 0.0
	_check(_hero.buy("tempered_blade") == "Not enough gold", "can't buy without gold")
	_hero.gold = 10000.0
	_hero.in_shop_range = false
	_check(_hero.buy("tempered_blade") == "Return to your fountain to shop", "can't buy away from the fountain")
	_hero.in_shop_range = true
	var base_damage := _hero.attack_damage
	_check(_hero.buy("tempered_blade") == "" and is_equal_approx(_hero.gold, 7000.0), "buying spends gold (10000 → 7000)")
	_check(is_equal_approx(_hero.attack_damage, base_damage + 12.0), "Tempered Blade adds 12 damage")
	_check(_hero.sell(0) and is_equal_approx(_hero.gold, 9250.0) and is_equal_approx(_hero.attack_damage, base_damage),
			"selling refunds 75% (7000 → 9250) and removes the bonus")
	_hero.gold = 99999.0
	for i in 6:
		_hero.buy("wayfarers_treads")
	_check(_hero.buy("riveted_mail") == "Inventory full", "inventory caps at 6")
	while _hero.items.size() > 0:
		_hero.sell(0)


func _effects() -> void:
	_hero.gold = 99999.0
	var base_hp := _hero.max_hp
	var base_interval := _hero.attack_interval
	_hero.buy("riveted_mail")
	_hero.buy("quickening_gauntlets")
	_hero.buy("bulwark_plate")
	_hero.buy("kindling_rune")
	_hero.buy("sages_hourglass")
	_check(is_equal_approx(_hero.max_hp, base_hp + 200.0), "Riveted Mail: +200 max HP")
	_check(is_equal_approx(_hero.attack_interval, base_interval / 1.2), "Quickening Gauntlets: 20% faster attacks")
	var before := _hero.hp
	_hero._invulnerable_time = 0.0
	_hero.take_damage(100.0)
	_check(is_equal_approx(before - _hero.hp, 85.0), "Bulwark Plate: 100 damage → 85 taken")
	_hero.meter.charge = 0.0
	_hero.meter._add(10.0)
	_check(is_equal_approx(_hero.meter.charge, 12.5), "Kindling Rune: meter gains ×1.25")
	_hero.meter.charge = 0.0
	_hero.skills[0].time_left = 0.0
	_hero.skills[0].rank = 1
	_hero.try_skill(0)
	_check(is_equal_approx(_hero.skills[0].time_left, 6.0 * 0.8), "Sage's Hourglass: slam cooldown 6 → 4.8 s")
	while _hero.items.size() > 0:
		_hero.sell(0)


func _consumables() -> void:
	_hero.gold = 10000.0
	_hero.buy("spark_flask")
	_hero.meter.charge = 0.0
	_check(_hero.use_item(0) and is_equal_approx(_hero.meter.charge, 25.0) and _hero.items.is_empty(),
			"Spark Flask: +25 meter, then it's gone")
	_hero.buy("tempered_blade")
	_check(not _hero.use_item(0), "non-consumables can't be 'used'")
	_hero.sell(0)


func _start_arena() -> void:
	_scene.queue_free()
	_scene = load("res://scenes/arena.tscn").instantiate()
	root.add_child(_scene)
	current_scene = _scene
	Engine.max_physics_steps_per_frame = 64
	Engine.time_scale = 8.0
	_sim = 0.0
	_phase = "arena"
	# Items now cost thousands; give the bots a purse so the test sees them shop.
	for brain in _scene.bots:
		brain.hero.gold = 12000.0


func _finish() -> void:
	for failure in _failures:
		printerr("FAIL: " + failure)
	print("SHOP TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
	Engine.time_scale = 1.0
	paused = false
	quit(1 if _failures.size() else 0)


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
