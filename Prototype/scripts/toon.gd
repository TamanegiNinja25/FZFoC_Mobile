class_name Toon
extends RefCounted
## Shared toon material (decision 2026-11-08): banded diffuse light, toon
## specular highlight and a rim light that keeps silhouettes readable from
## the top-down camera.


static func material(color: Color, rim := 0.6) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.specular_mode = BaseMaterial3D.SPECULAR_TOON
	m.roughness = 0.55
	if rim > 0.0:
		m.rim_enabled = true
		m.rim = rim
		m.rim_tint = 0.3
	return m
