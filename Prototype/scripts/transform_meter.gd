class_name TransformMeter
extends Node
## Charge meter that unlocks a hero's transformation when full.
## Replaces the reference map's level gates and cooldowns (decision 2026-11-08).

signal changed(value: float, max_value: float)
signal filled

enum Source { DEALT, TAKEN, KILL, PASSIVE }

@export var max_charge := 100.0

@export_group("Charge rule")
## Budget: about 90 s of fighting one dummy fills the meter. Measured by
## tests/meter_balance_test.gd. The dummy is dead ~25% of the time, so the
## hero averages ≈37.5 damage dealt/s and ≈12.5 taken/s, giving
## ≈64 dealt + ≈9 taken + ≈18 trickle + ≈10 kills.
## Damage dealt is the main source: aggression is rewarded.
@export var dealt_per_damage := 0.019
@export var dealt_cap_per_hit := 3.0
## Under half the dealt rate: being hit isn't a comeback lever.
@export var taken_per_damage := 0.008
@export var taken_cap_per_hit := 1.5
## Kills mainly pay gold and income (see Hero); this is a small meter bonus.
@export var per_kill := 2.0
## Small trickle while fighting, so a struggling player still gets a form.
@export var combat_trickle_per_second := 0.2
## Drain once out of combat, so staying in the fight pays.
@export var idle_drain_per_second := 0.5
@export var out_of_combat_after := 5.0

var charge := 0.0
## While the hero is transformed the meter neither fills nor drains.
var locked := false

var _since_combat := INF


func _process(delta: float) -> void:
	_since_combat += delta
	_add(_charge_for(delta, Source.PASSIVE))


func in_combat() -> bool:
	return _since_combat < out_of_combat_after


func on_damage_dealt(amount: float) -> void:
	if amount > 0.0:
		_since_combat = 0.0
	_add(_charge_for(amount, Source.DEALT))


func on_damage_taken(amount: float) -> void:
	if amount > 0.0:
		_since_combat = 0.0
	_add(_charge_for(amount, Source.TAKEN))


func on_kill() -> void:
	_add(_charge_for(1.0, Source.KILL))


func is_full() -> bool:
	return charge >= max_charge


func consume() -> void:
	charge = 0.0
	changed.emit(charge, max_charge)


func _add(points: float) -> void:
	if locked or points == 0.0:
		return
	var was_full := is_full()
	charge = clampf(charge + points, 0.0, max_charge)
	changed.emit(charge, max_charge)
	if is_full() and not was_full:
		filled.emit()


## How many charge points one event is worth.
## `amount` is damage for DEALT/TAKEN, 1.0 for KILL, and seconds elapsed for PASSIVE.
## Negative values drain the meter.
func _charge_for(amount: float, source: Source) -> float:
	match source:
		Source.DEALT:
			return minf(amount * dealt_per_damage, dealt_cap_per_hit)
		Source.TAKEN:
			return minf(amount * taken_per_damage, taken_cap_per_hit)
		Source.KILL:
			return per_kill * amount
		Source.PASSIVE:
			var rate := combat_trickle_per_second if in_combat() else -idle_drain_per_second
			return rate * amount
	return 0.0
