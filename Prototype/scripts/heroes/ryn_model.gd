class_name RynModel
extends PrimitiveModel
## Ryn, the Gale Dancer: slim, hooded, a long scarf and twin curved blades.
## Wind-cyan glow on the hood ribbon and shoulder ribbons (visible from above).


func _setup_colors() -> void:
	swing_axis = "y"  # twin blades sweep
	weapon_pivot_at = Vector3(0, 0.85, 0)
	body_color = Color(0.22, 0.42, 0.45)
	form_body_color = Color(0.16, 0.3, 0.36)
	glow_color = Color(0.35, 1.0, 0.95)
	particle_color = Color(0.85, 1.0, 1.0)


func _build() -> void:
	var cloth := Toon.material(Color(0.12, 0.22, 0.25))
	var steel := Toon.material(Color(0.85, 0.88, 0.92))
	add_part(capsule(0.32, 1.45), Vector3(0, 0.82, 0), _body_material)                           # body
	add_part(torus(0.3, 0.38), Vector3(0, 0.75, 0), Toon.material(accent, 0.3))                   # team sash
	add_part(sphere(0.25), Vector3(0, 1.72, 0), cloth)                                            # head
	add_part(cone(0.3, 0.42), Vector3(0, 1.98, 0.05), cloth, Vector3.ONE, Vector3(-12, 0, 0))     # hood point
	add_part(box(Vector3(0.3, 0.05, 0.05)), Vector3(0, 1.74, -0.23), glow())                     # eye band
	add_part(box(Vector3(0.1, 0.05, 0.6)), Vector3(0, 1.92, 0.05), glow())                       # hood ribbon (top)
	add_part(box(Vector3(0.14, 0.04, 0.7)), Vector3(0.05, 1.3, 0.42), Toon.material(accent.lightened(0.2), 0.0), Vector3.ONE, Vector3(-25, 0, 0))  # scarf tail
	for side in [-1.0, 1.0]:
		add_part(dome(0.16), Vector3(0.36 * side, 1.38, 0), cloth)                               # shoulder wraps
		add_part(box(Vector3(0.05, 0.04, 0.32)), Vector3(0.36 * side, 1.47, 0), glow())          # shoulder ribbons (top)
		add_weapon_part(box(Vector3(0.05, 0.03, 0.8)), Vector3(0.5 * side, 0.85, -0.3), steel, Vector3.ONE, Vector3(0, 12 * side, 0))   # blades
		add_weapon_part(box(Vector3(0.08, 0.08, 0.16)), Vector3(0.5 * side, 0.85, 0.12), Toon.material(Color(0.3, 0.2, 0.12)))          # hilts
