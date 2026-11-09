class_name BarrowModel
extends PrimitiveModel
## Barrow, the Living Cairn: a giant of stacked boulders with moss on the
## shoulders and amber runes that blaze in Avalanche (visible from above).


func _setup_colors() -> void:
	weapon_pivot_at = Vector3(0, 1.5, 0)  # fists slam down from the shoulders
	body_color = Color(0.48, 0.46, 0.42)
	form_body_color = Color(0.38, 0.34, 0.3)
	glow_color = Color(1.0, 0.7, 0.25)
	particle_color = Color(0.7, 0.6, 0.45)


func _build() -> void:
	var dark := Toon.material(Color(0.36, 0.34, 0.31))
	var moss := Toon.material(Color(0.3, 0.5, 0.25))
	add_part(sphere(0.62, 1.1), Vector3(0, 1.1, 0), _body_material)                             # boulder torso
	add_part(torus(0.5, 0.62), Vector3(0, 0.62, 0), Toon.material(accent, 0.3))                 # team stone band
	add_part(sphere(0.26), Vector3(0, 1.9, -0.18), dark)                                        # small head, sunk forward
	add_part(box(Vector3(0.24, 0.05, 0.05)), Vector3(0, 1.92, -0.42), glow())                   # eye slit
	add_part(box(Vector3(0.18, 0.18, 0.05)), Vector3(0, 1.2, -0.62), glow(), Vector3.ONE, Vector3(0, 0, 45))  # chest rune
	add_part(box(Vector3(0.36, 0.05, 0.12)), Vector3(0, 1.78, 0.25), glow())                    # back rune (top)
	for side in [-1.0, 1.0]:
		add_part(sphere(0.38), Vector3(0.72 * side, 1.5, 0), dark)                             # shoulder boulders
		add_part(dome(0.28), Vector3(0.72 * side, 1.78, 0), moss)                              # moss caps (top)
		add_weapon_part(sphere(0.24), Vector3(0.86 * side, 1.08, -0.05), dark)                 # upper arm stone
		add_weapon_part(sphere(0.3), Vector3(0.9 * side, 0.6, -0.1), _body_material)           # fist
		add_part(sphere(0.26), Vector3(0.28 * side, 0.32, 0), dark)                            # legs
