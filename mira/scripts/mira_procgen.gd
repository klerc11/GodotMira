class_name MiraProcGen
extends RefCounted


static func build_level(seed_value: int) -> Dictionary:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value

	var source: Vector3 = Vector3(0.0, 1.58, 18.0)
	var spawn: Vector3 = Vector3(0.0, 0.0, 18.0)
	var reflector_count: int = rng.randi_range(4, 7)
	var route_points: Array[Vector3] = [source]

	var z_cursor: float = source.z - rng.randf_range(8.0, 10.0)
	var lane_sign: float = -1.0 if rng.randf() < 0.5 else 1.0
	for index in range(reflector_count):
		var lane_x: float = lane_sign * rng.randf_range(4.2, 10.8) + rng.randf_range(-1.2, 1.2)
		var lane_y: float = 1.52 + rng.randf_range(-0.08, 0.22)
		route_points.append(Vector3(clampf(lane_x, -13.0, 13.0), lane_y, z_cursor))
		z_cursor -= rng.randf_range(10.5, 15.6)
		lane_sign *= -1.0

	var target_x: float = rng.randf_range(-5.2, 5.2)
	var target: Vector3 = Vector3(target_x, 1.58, z_cursor - rng.randf_range(11.0, 16.0))
	route_points.append(target)

	var reflectors: Array = []
	var channels: Array = []
	var appointments: Array = []
	var platforms: Array = []

	for idx in range(1, route_points.size() - 1):
		var center: Vector3 = route_points[idx]
		var from_point: Vector3 = route_points[idx - 1]
		var to_point: Vector3 = route_points[idx + 1]
		var span_hint: float = maxf((center - from_point).length(), (to_point - center).length())
		reflectors.append(
			{
				"center": center,
				"from": from_point,
				"to": to_point,
				"label": "main",
				"width": clampf(3.8 + span_hint * 0.06, 3.9, 5.8),
				"height": clampf(3.5 + span_hint * 0.04, 3.6, 4.8)
			}
		)

		channels.append({"from": from_point, "to": center})
		if idx % 2 == 1:
			appointments.append({"center": center, "variant": "ring"})

		var pad_height: float = 0.06 + float(idx % 3) * 0.16
		platforms.append(
			{
				"center": Vector3(center.x, pad_height, center.z),
				"size": Vector3(4.8, 0.34, 5.4)
			}
		)

	if route_points.size() > 5:
		var split_index: int = rng.randi_range(2, route_points.size() - 3)
		reflectors.append(
			{
				"center": route_points[split_index],
				"from": route_points[split_index - 1],
				"to": route_points[split_index + 2],
				"label": "optional",
				"width": 4.2,
				"height": 3.8
			}
		)
		channels.append({"from": route_points[split_index], "to": route_points[split_index + 2], "label": "optional"})

	var min_x: float = -18.0
	var max_x: float = 18.0
	var min_z: float = target.z - 24.0
	var max_z: float = source.z + 8.0
	for point in route_points:
		min_x = minf(min_x, point.x - 7.5)
		max_x = maxf(max_x, point.x + 7.5)
		min_z = minf(min_z, point.z - 7.0)
		max_z = maxf(max_z, point.z + 7.0)

	var world_bounds_min: Vector3 = Vector3(min_x - 2.0, -2.0, min_z - 2.0)
	var world_bounds_max: Vector3 = Vector3(max_x + 2.0, 14.0, max_z + 2.0)
	var main_floor_center: Vector3 = Vector3((min_x + max_x) * 0.5, -0.15, (min_z + max_z) * 0.5)
	var main_floor_size: Vector3 = Vector3(maxf(22.0, max_x - min_x + 4.0), 0.3, maxf(46.0, max_z - min_z + 4.0))
	platforms.insert(
		0,
		{
			"center": main_floor_center,
			"size": main_floor_size
		}
	)

	var absorbers: Array = [
		{
			"center": Vector3(min_x - 0.8, 1.6, (min_z + max_z) * 0.5),
			"size": Vector3(0.8, 3.2, maxf(20.0, max_z - min_z + 8.0))
		},
		{
			"center": Vector3(max_x + 0.8, 1.6, (min_z + max_z) * 0.5),
			"size": Vector3(0.8, 3.2, maxf(20.0, max_z - min_z + 8.0))
		}
	]
	for gate_idx in range(2, route_points.size() - 2, 2):
		var gate_center: Vector3 = route_points[gate_idx]
		var gate_width: float = rng.randf_range(2.8, 4.4)
		absorbers.append(
			{
				"center": Vector3(gate_center.x + gate_width * 0.85, 1.55, gate_center.z - 2.2),
				"size": Vector3(0.55, 3.0, 4.8)
			}
		)

	var env_choices: Array[String] = ["default", "clear", "high_fog"]
	var env_pick: String = env_choices[rng.randi_range(0, env_choices.size() - 1)]
	var pulse_speed: float = rng.randf_range(10.4, 12.2)
	var pressure_speed: float = pulse_speed * rng.randf_range(0.82, 0.9)
	var title_suffix: int = int(seed_value % 1000)
	return {
		"title": "Proc Lab %03d" % title_suffix,
		"objective": "Procedural relay seed %d. Fire, route through mirrors, and finish clean." % seed_value,
		"spawn": spawn,
		"source": source,
		"fire_zone_radius": 2.4,
		"yaw": PI,
		"target": target,
		"target_radius": 2.45,
		"target_visual_radius": 0.92,
		"pulse_speed": pulse_speed,
		"pulse_ttl": rng.randf_range(12.0, 16.0),
		"player_reflect_stability_ratio": 0.5,
		"max_pulse_speed_multiplier": 2.1,
		"pressure_beam_enabled": true,
		"pressure_start_offset": -9.5,
		"pressure_speed": pressure_speed,
		"pressure_max_speed": pressure_speed + rng.randf_range(5.4, 7.8),
		"pressure_accel": rng.randf_range(1.7, 2.6),
		"pressure_catch_tolerance": 0.78,
		"world_bounds_min": world_bounds_min,
		"world_bounds_max": world_bounds_max,
		"platforms": platforms,
		"absorbers": absorbers,
		"channels": channels,
		"appointments": appointments,
		"reflectors": reflectors,
		"env_preset": env_pick,
		"fog_near": 32.0,
		"fog_far": 124.0
	}
