class_name Platform
extends RefCounted
## Platform-specific rendering settings.
## Phones use 2 sun-shadow cascades (decision 2026-11-08); desktop keeps Godot's default 4.
## Pass `-- --phone` on the command line to simulate phone settings on a PC.


static func is_phone() -> bool:
	return OS.has_feature("mobile") or "--phone" in OS.get_cmdline_user_args()


static func shadow_cascades() -> int:
	return 2 if is_phone() else 4


## 0 turns shadows off; 1, 2 or 4 sets the number of cascades.
static func apply_sun_shadows(sun: DirectionalLight3D, cascades := shadow_cascades()) -> void:
	sun.shadow_enabled = cascades > 0
	match cascades:
		1:
			sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		2:
			sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
		_:
			sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
