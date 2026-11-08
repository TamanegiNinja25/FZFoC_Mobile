class_name Skill
extends RefCounted
## A hero skill with a cooldown. Subclasses implement _cast().

var skill_name := ""
var description := ""
var cooldown := 6.0
var time_left := 0.0


## Name shown on the button; skills can rename themselves while the hero is transformed.
func display_name(_hero: Hero) -> String:
	return skill_name


func is_ready() -> bool:
	return time_left <= 0.0


func tick(delta: float) -> void:
	time_left = maxf(time_left - delta, 0.0)


func try_cast(hero: Hero) -> bool:
	if not is_ready():
		return false
	_cast(hero)
	time_left = cooldown
	return true


func _cast(_hero: Hero) -> void:
	pass
