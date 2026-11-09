class_name NewHeroModels
extends RefCounted
## Models for the Phase 7 heroes, built from smooth primitives like the others.
## Each keeps its glow on top-facing surfaces (the top-down camera sees them)
## and hangs its weapon from the weapon pivot so HeroAnimator can swing it.


## Sable: hooded archer in ash-grey leathers with a long ember bow and quiver.
class SableModel extends PrimitiveModel:
	func _setup_colors() -> void:
		swing_axis = "x"
		weapon_pivot_at = Vector3(-0.45, 1.25, -0.1)
		body_color = Color(0.4, 0.36, 0.34)
		form_body_color = Color(0.3, 0.25, 0.24)
		glow_color = Color(1.0, 0.6, 0.25)
		particle_color = Color(1.0, 0.75, 0.45)

	func _build() -> void:
		var leather := Toon.material(Color(0.32, 0.22, 0.16))
		add_part(capsule(0.3, 1.4), Vector3(0, 0.8, 0), _body_material)                          # body
		add_part(torus(0.28, 0.36), Vector3(0, 0.72, 0), Toon.material(accent, 0.3))             # team belt
		add_part(sphere(0.24), Vector3(0, 1.68, 0), leather)                                     # head
		add_part(dome(0.3), Vector3(0, 1.74, 0.02), leather, Vector3(1, 1.2, 1.1))               # hood
		add_part(box(Vector3(0.28, 0.04, 0.05)), Vector3(0, 1.7, -0.22), glow())                 # eye band
		add_part(capsule(0.12, 0.8), Vector3(0.18, 1.2, 0.3), leather, Vector3.ONE, Vector3(20, 0, 0))   # quiver
		add_part(box(Vector3(0.06, 0.05, 0.3)), Vector3(0.18, 1.62, 0.36), glow())               # arrow fletchings (top)
		add_weapon_part(box(Vector3(0.06, 1.5, 0.08)), Vector3(-0.48, 1.2, -0.12), Toon.material(Color(0.35, 0.18, 0.1)))  # bow stave
		add_weapon_part(box(Vector3(0.02, 1.4, 0.02)), Vector3(-0.48, 1.2, 0.0), glow())         # ember bowstring


## Morrow: robed grave-keeper with a lantern staff and a ghostly green glow.
class MorrowModel extends PrimitiveModel:
	func _setup_colors() -> void:
		swing_axis = "x"
		weapon_pivot_at = Vector3(0.5, 1.3, -0.1)
		body_color = Color(0.22, 0.2, 0.3)
		form_body_color = Color(0.16, 0.14, 0.22)
		glow_color = Color(0.5, 1.0, 0.6)
		particle_color = Color(0.7, 1.0, 0.75)

	func _build() -> void:
		var bone := Toon.material(Color(0.85, 0.83, 0.75))
		add_part(cone(0.55, 1.6), Vector3(0, 0.8, 0), _body_material)                            # robe
		add_part(torus(0.3, 0.38), Vector3(0, 1.05, 0), Toon.material(accent, 0.3))              # team sash
		add_part(sphere(0.25), Vector3(0, 1.72, 0), bone)                                        # pale head
		add_part(dome(0.34), Vector3(0, 1.8, 0.02), _body_material, Vector3(1, 1.3, 1.1))        # cowl
		add_part(box(Vector3(0.26, 0.04, 0.05)), Vector3(0, 1.72, -0.23), glow())                # eye glow
		add_part(dome(0.12), Vector3(0, 2.1, 0.05), glow())                                      # cowl rune (top)
		add_weapon_part(capsule(0.04, 1.9), Vector3(0.5, 1.0, -0.1), Toon.material(Color(0.3, 0.24, 0.18)))  # staff
		add_weapon_part(sphere(0.16), Vector3(0.5, 2.0, -0.1), glow())                           # lantern


## Kael: lean swordsman in a dark coat; a long blade and a cracked white mask.
class KaelModel extends PrimitiveModel:
	func _setup_colors() -> void:
		swing_axis = "y"
		weapon_pivot_at = Vector3(0.0, 1.0, 0.0)
		body_color = Color(0.14, 0.14, 0.18)
		form_body_color = Color(0.08, 0.08, 0.1)
		glow_color = Color(0.85, 0.9, 1.0)
		particle_color = Color(0.9, 0.92, 1.0)

	func _build() -> void:
		var mask := Toon.material(Color(0.92, 0.92, 0.9))
		add_part(capsule(0.32, 1.5), Vector3(0, 0.84, 0), _body_material)                        # coat
		add_part(torus(0.3, 0.38), Vector3(0, 0.78, 0), Toon.material(accent, 0.3))              # team sash
		add_part(sphere(0.24), Vector3(0, 1.74, 0), Toon.material(Color(0.2, 0.18, 0.2)))        # hair
		add_part(sphere(0.2), Vector3(0, 1.72, -0.08), mask, Vector3(1, 1.1, 0.7))               # mask
		add_part(box(Vector3(0.04, 0.2, 0.04)), Vector3(0.06, 1.74, -0.22), glow())              # mask crack glow
		add_part(box(Vector3(0.5, 0.04, 0.1)), Vector3(0, 1.42, 0.12), glow())                   # shoulder seal (top)
		add_weapon_part(box(Vector3(0.06, 0.04, 1.3)), Vector3(0.45, 1.0, -0.6), Toon.material(Color(0.88, 0.9, 0.95)))  # long blade
		add_weapon_part(box(Vector3(0.1, 0.1, 0.22)), Vector3(0.45, 1.0, 0.12), Toon.material(Color(0.1, 0.1, 0.12)))     # hilt


## Tamsin: storm-witch with a wide-brimmed hat, a forked staff and blue sparks.
class TamsinModel extends PrimitiveModel:
	func _setup_colors() -> void:
		swing_axis = "x"
		weapon_pivot_at = Vector3(0.45, 1.3, -0.1)
		body_color = Color(0.18, 0.24, 0.42)
		form_body_color = Color(0.12, 0.16, 0.32)
		glow_color = Color(0.6, 0.8, 1.0)
		particle_color = Color(0.8, 0.9, 1.0)

	func _build() -> void:
		var hat := Toon.material(Color(0.12, 0.14, 0.24))
		add_part(cone(0.5, 1.5), Vector3(0, 0.75, 0), _body_material)                            # dress
		add_part(torus(0.28, 0.36), Vector3(0, 1.05, 0), Toon.material(accent, 0.3))             # team sash
		add_part(sphere(0.23), Vector3(0, 1.64, 0), Toon.material(Color(0.9, 0.8, 0.72)))        # head
		add_part(torus(0.2, 0.55), Vector3(0, 1.82, 0), hat, Vector3(1, 0.4, 1))                 # hat brim
		add_part(cone(0.3, 0.6), Vector3(0, 2.1, 0.05), hat, Vector3.ONE, Vector3(-15, 0, 0))    # hat crown
		add_part(torus(0.24, 0.3), Vector3(0, 1.9, 0), glow(), Vector3(1, 0.5, 1))               # hat band glow (top)
		add_weapon_part(capsule(0.04, 1.8), Vector3(0.45, 1.0, -0.1), Toon.material(Color(0.3, 0.3, 0.36)))  # staff
		add_weapon_part(box(Vector3(0.3, 0.05, 0.05)), Vector3(0.45, 1.92, -0.1), glow())        # forked head


## Hask: broad warden in heavy plate with a tower shield and a chain hook.
class HaskModel extends PrimitiveModel:
	func _setup_colors() -> void:
		swing_axis = "x"
		weapon_pivot_at = Vector3(-0.75, 1.3, 0.0)
		body_color = Color(0.5, 0.52, 0.56)
		form_body_color = Color(0.4, 0.42, 0.45)
		glow_color = Color(1.0, 0.8, 0.4)
		particle_color = Color(1.0, 0.9, 0.6)

	func _build() -> void:
		var dark := Toon.material(Color(0.3, 0.31, 0.34))
		add_part(capsule(0.55, 1.6), Vector3(0, 0.9, 0), _body_material)                         # plate body
		add_part(torus(0.5, 0.62), Vector3(0, 0.66, 0), Toon.material(accent, 0.3))              # team belt
		add_part(box(Vector3(0.5, 0.45, 0.5)), Vector3(0, 1.9, 0), dark)                         # great helm
		add_part(box(Vector3(0.38, 0.05, 0.05)), Vector3(0, 1.92, -0.26), glow())                # visor
		add_part(box(Vector3(0.1, 0.06, 0.5)), Vector3(0, 2.16, 0), glow())                      # helm ridge (top)
		for side in [-1.0, 1.0]:
			add_part(dome(0.36), Vector3(0.68 * side, 1.55, 0), dark, Vector3(1.1, 0.8, 1.1))   # pauldrons
		add_weapon_part(box(Vector3(0.12, 1.5, 0.95)), Vector3(-0.85, 1.05, -0.1), _body_material)  # tower shield
		add_weapon_part(box(Vector3(0.14, 0.5, 0.12)), Vector3(-0.92, 1.1, -0.1), Toon.material(accent, 0.3))  # team crest
		add_part(torus(0.1, 0.16), Vector3(0.8, 1.0, -0.1), dark, Vector3.ONE, Vector3(90, 0, 0))  # chain hook
