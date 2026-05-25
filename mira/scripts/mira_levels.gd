class_name MiraLevels
extends RefCounted


static func get_levels() -> Array[Dictionary]:
	return [
		{
			"title": "Authoring Template",
			"objective": "Editable starter layout. Build platforms, reflectors, and routes directly in the scene.",
			"spawn": Vector3(0.0, 1.2, 18.0),
			"source": Vector3(0.0, 1.58, 18.0),
			"fire_zone_radius": 2.4,
			"yaw": 3.1416,
			"target": Vector3(0.0, 1.58, -94.0),
			"target_radius": 2.3,
			"target_visual_radius": 0.9,
			"pulse_speed": 10.2,
			"pulse_ttl": 12.0,
			"player_reflect_stability_ratio": 0.5,
			"max_pulse_speed_multiplier": 1.85,
			"pressure_beam_enabled": false,
			"scene_override_path": "res://mira/scenes/levels/authoring_template.tscn",
			"world_bounds_min": Vector3(-32.0, -8.0, -120.0),
			"world_bounds_max": Vector3(32.0, 20.0, 28.0),
			"platforms": [],
			"absorbers": [],
			"channels": [],
			"appointments": [],
			"reflectors": [],
			"fog_near": 34.0,
			"fog_far": 132.0,
			"env_preset": "clear"
		},
		{
			"title": "Lab: 3-Course Platforming",
			"objective": "Run one grounded tower lane, tune movement chains, and reset fast when you miss.",
			"spawn": Vector3(0.0, 0.35, 12.0),
			"source": Vector3(0.0, 1.58, 12.0),
			"fire_zone_radius": 2.2,
			"yaw": 3.1416,
			"target": Vector3(0.0, 1.58, -108.0),
			"target_radius": 2.0,
			"target_visual_radius": 0.8,
			"pulse_speed": 9.8,
			"pulse_ttl": 10.0,
			"player_reflect_stability_ratio": 0.45,
			"max_pulse_speed_multiplier": 1.75,
			"pressure_beam_enabled": false,
			"scene_override_path": "res://mira/scenes/levels/lab_three_course.tscn",
			"platform_support_towers": true,
			"platform_support_ground_y": -1.0,
			"world_bounds_min": Vector3(-24.0, -8.0, -132.0),
			"world_bounds_max": Vector3(24.0, 16.0, 24.0),
			"platforms": [
				{
					"center": Vector3(0.0, -1.25, -48.0),
					"size": Vector3(52.0, 0.5, 162.0)
				},
				{
					"center": Vector3(0.0, 0.12, 12.2),
					"size": Vector3(18.0, 0.35, 8.0)
				},
				{
					"center": Vector3(0.0, 0.12, 5.8),
					"size": Vector3(10.0, 0.35, 5.2)
				},
				# Course A: left precision rectangles (lateral adjustments + timing)
				{
					"center": Vector3(-10.8, 0.55, 6.5),
					"size": Vector3(5.4, 0.35, 7.0)
				},
				{
					"center": Vector3(-13.2, 1.0, -4.0),
					"size": Vector3(4.8, 0.35, 6.8)
				},
				{
					"center": Vector3(-9.2, 1.45, -15.5),
					"size": Vector3(4.4, 0.35, 6.6)
				},
				{
					"center": Vector3(-13.6, 1.95, -28.0),
					"size": Vector3(4.2, 0.35, 7.0)
				},
				{
					"center": Vector3(-9.4, 2.5, -41.5),
					"size": Vector3(4.0, 0.35, 7.4)
				},
				{
					"center": Vector3(-13.4, 3.1, -56.0),
					"size": Vector3(4.0, 0.35, 7.2)
				},
				{
					"center": Vector3(-10.2, 3.7, -71.0),
					"size": Vector3(3.8, 0.35, 7.2)
				},
				{
					"center": Vector3(-13.0, 4.3, -86.0),
					"size": Vector3(4.2, 0.35, 7.4)
				},
				{
					"center": Vector3(-10.8, 4.9, -101.0),
					"size": Vector3(4.8, 0.35, 7.8)
				},
				{
					"center": Vector3(-12.2, 5.4, -112.0),
					"size": Vector3(5.2, 0.35, 6.8)
				},
				# Course B: center vertical rhythm (longer reads + climb/drop)
				{
					"center": Vector3(0.0, 0.6, 6.2),
					"size": Vector3(6.0, 0.35, 8.0)
				},
				{
					"center": Vector3(0.0, 1.3, -5.0),
					"size": Vector3(5.6, 0.35, 7.6)
				},
				{
					"center": Vector3(0.0, 2.1, -17.0),
					"size": Vector3(5.2, 0.35, 7.4)
				},
				{
					"center": Vector3(0.0, 3.0, -30.0),
					"size": Vector3(4.8, 0.35, 7.2)
				},
				{
					"center": Vector3(0.0, 4.0, -44.0),
					"size": Vector3(4.4, 0.35, 7.0)
				},
				{
					"center": Vector3(0.0, 4.9, -58.5),
					"size": Vector3(4.2, 0.35, 6.8)
				},
				{
					"center": Vector3(0.0, 5.7, -73.5),
					"size": Vector3(4.0, 0.35, 6.8)
				},
				{
					"center": Vector3(0.0, 4.8, -89.0),
					"size": Vector3(4.6, 0.35, 7.2)
				},
				{
					"center": Vector3(0.0, 5.8, -104.5),
					"size": Vector3(5.0, 0.35, 7.8)
				},
				{
					"center": Vector3(0.0, 6.4, -114.0),
					"size": Vector3(5.4, 0.35, 6.8)
				},
				# Course C: right commitment lane (dash + slide setup windows)
				{
					"center": Vector3(10.8, 0.5, 6.5),
					"size": Vector3(6.8, 0.35, 8.0)
				},
				{
					"center": Vector3(13.4, 0.95, -6.5),
					"size": Vector3(6.0, 0.35, 7.6)
				},
				{
					"center": Vector3(9.0, 1.5, -21.0),
					"size": Vector3(5.4, 0.35, 7.2)
				},
				{
					"center": Vector3(14.0, 2.2, -37.0),
					"size": Vector3(5.0, 0.35, 7.0)
				},
				{
					"center": Vector3(9.6, 3.0, -54.0),
					"size": Vector3(4.8, 0.35, 7.0)
				},
				{
					"center": Vector3(14.6, 3.9, -72.0),
					"size": Vector3(4.6, 0.35, 6.8)
				},
				{
					"center": Vector3(10.4, 4.7, -90.5),
					"size": Vector3(4.6, 0.35, 6.8)
				},
				{
					"center": Vector3(14.2, 5.5, -109.0),
					"size": Vector3(5.0, 0.35, 7.2)
				},
				{
					"center": Vector3(11.2, 5.9, -118.0),
					"size": Vector3(5.8, 0.35, 6.2)
				}
			],
			"absorbers": [],
			"channels": [],
			"appointments": [],
			"reflectors": [],
			"fog_near": 28.0,
			"fog_far": 96.0,
			"env_preset": "clear"
		},
		{
			"title": "Level 1: Relay Run",
			"objective": "Fire from behind the start line, dash the right lane, volley the pulse forward, and finish the route.",
			"spawn": Vector3(0.0, 0.0, 13.0),
			"source": Vector3(0.0, 1.5800, 13.0),
			"fire_zone_radius": 2.3500,
			"yaw": 3.1416,
			"target": Vector3(0.0, 1.5800, -29.5000),
			"target_radius": 2.1500,
			"target_visual_radius": 0.8800,
			"pulse_speed": 10.5000,
			"pulse_ttl": 10.5000,
			"player_reflect_stability_ratio": 0.4500,
			"max_pulse_speed_multiplier": 1.7500,
			"world_bounds_min": Vector3(-20.0, -2.0, -158.0),
			"world_bounds_max": Vector3(20.0, 14.0, 22.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, -8.0),
					"size": Vector3(18.0, 0.3000, 46.0)
				},
				{
					"center": Vector3(5.8000, 0.1000, -7.0),
					"size": Vector3(4.6000, 0.3500, 9.0)
				},
				{
					"center": Vector3(5.8000, 0.3500, -16.5000),
					"size": Vector3(4.6000, 0.3500, 8.0)
				},
				{
					"center": Vector3(0.0, 0.1000, -29.0),
					"size": Vector3(5.0, 0.3500, 4.5000)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-8.4000, 1.6000, -8.0),
					"size": Vector3(0.8000, 3.1000, 35.0)
				},
				{
					"center": Vector3(9.7000, 1.6000, -15.0),
					"size": Vector3(0.8000, 3.1000, 26.0)
				},
				{
					"center": Vector3(-5.2000, 1.4500, -23.5000),
					"size": Vector3(3.4000, 2.9000, 0.7000)
				},
				{
					"center": Vector3(7.6000, 1.4500, -23.5000),
					"size": Vector3(2.2000, 2.9000, 0.7000)
				}
			],
			"channels": [],
			"appointments": [],
			"reflectors": [
				{
					"center": Vector3(0.0, 1.5800, 4.3000),
					"from": Vector3(0.0, 1.5800, 13.0),
					"to": Vector3(5.9000, 1.5800, -7.2000),
					"label": "main",
					"width": 5.0,
					"height": 4.4000
				},
				{
					"center": Vector3(5.9000, 1.5800, -18.6000),
					"from": Vector3(5.9000, 1.5800, -7.2000),
					"to": Vector3(0.0, 1.5800, -29.5000),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-5.5000, 1.5800, -13.5000),
					"from": Vector3(5.9000, 1.5800, -7.2000),
					"to": Vector3(5.9000, 1.5800, -18.6000),
					"label": "optional",
					"width": 4.2000,
					"height": 3.8000
				}
			]
		},
		{
			"title": "Level 2: Chain Angle",
			"objective": "Fire down the center, read the two mirror chain, and commit to the finish angle.",
			"spawn": Vector3(-4.5000, 0.0, 8.5000),
			"source": Vector3(-4.5000, 1.6500, 8.5000),
			"fire_zone_radius": 2.2500,
			"yaw": 3.1416,
			"target": Vector3(-6.8000, 1.6500, -7.0),
			"target_radius": 2.6000,
			"target_visual_radius": 0.8800,
			"pulse_speed": 10.0,
			"pulse_ttl": 8.0,
			"player_reflect_stability_ratio": 0.4500,
			"max_pulse_speed_multiplier": 1.7500,
			"env_preset": "clear",
			"world_bounds_min": Vector3(-20.0, -2.0, -158.0),
			"world_bounds_max": Vector3(20.0, 14.0, 22.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, 0.0),
					"size": Vector3(24.0, 0.3000, 24.0)
				},
				{
					"center": Vector3(-4.5000, -0.0500, 3.8000),
					"size": Vector3(5.2000, 0.3000, 9.4000)
				},
				{
					"center": Vector3(4.8000, 0.0500, -2.2000),
					"size": Vector3(4.2000, 0.3000, 4.2000)
				},
				{
					"center": Vector3(-6.8000, 0.2000, -7.0),
					"size": Vector3(3.4000, 0.3500, 3.4000)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-0.2000, 1.5000, 4.1000),
					"size": Vector3(0.6500, 3.0, 6.0000)
				},
				{
					"center": Vector3(8.2000, 1.5000, -5.8000),
					"size": Vector3(0.6500, 3.0, 6.4000)
				}
			],
			"channels": [
				{
					"from": Vector3(-4.5000, 1.6500, 8.5000),
					"to": Vector3(-4.5000, 1.6500, 0.5000)
				},
				{
					"from": Vector3(-4.5000, 1.6500, 0.5000),
					"to": Vector3(4.8000, 1.6500, -2.2000)
				},
				{
					"from": Vector3(4.8000, 1.6500, -2.2000),
					"to": Vector3(-6.8000, 1.6500, -7.0)
				}
			],
			"appointments": [
				{
					"center": Vector3(-4.5000, 1.6500, 0.5000),
					"variant": "ring"
				},
				{
					"center": Vector3(4.8000, 1.6500, -2.2000),
					"variant": "chevron"
				}
			],
			"reflectors": [
				{
					"center": Vector3(-4.5000, 1.6500, 0.5000),
					"from": Vector3(-4.5000, 1.6500, 8.5000),
					"to": Vector3(4.8000, 1.6500, -2.2000),
					"label": "main",
					"width": 4.2000,
					"height": 3.9000
				},
				{
					"center": Vector3(4.8000, 1.6500, -2.2000),
					"from": Vector3(-4.5000, 1.6500, 0.5000),
					"to": Vector3(-6.8000, 1.6500, -7.0),
					"label": "main",
					"width": 4.2000,
					"height": 3.9000
				}
			],
			"fog_near": 34.0,
			"fog_far": 86.0
		},
		{
			"title": "Level 3: Moving Mirror",
			"objective": "Let the pulse cross the lane, intercept it, then aim at the receptor.",
			"spawn": Vector3(0.0, 0.0, 8.5000),
			"source": Vector3(0.0, 1.6500, 8.5000),
			"fire_zone_radius": 2.2500,
			"yaw": 3.1416,
			"target": Vector3(7.6000, 1.7000, -6.5000),
			"target_radius": 2.6000,
			"target_visual_radius": 0.8800,
			"pulse_speed": 8.0,
			"pulse_ttl": 10.0,
			"player_reflect_stability_ratio": 0.4500,
			"max_pulse_speed_multiplier": 1.7500,
			"world_bounds_min": Vector3(-20.0, -2.0, -158.0),
			"world_bounds_max": Vector3(20.0, 14.0, 22.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, 0.0),
					"size": Vector3(24.0, 0.3000, 24.0)
				},
				{
					"center": Vector3(2.3000, 0.1800, -0.2000),
					"size": Vector3(4.0, 0.3500, 4.0)
				},
				{
					"center": Vector3(7.3000, 0.2000, -6.5000),
					"size": Vector3(3.4000, 0.3500, 3.4000)
				}
			],
			"absorbers": [
				{
					"center": Vector3(8.3000, 1.8000, 1.8000),
					"size": Vector3(2.5000, 3.5000, 8.0)
				}
			],
			"channels": [],
			"appointments": [],
			"reflectors": [
				{
					"center": Vector3(-5.8000, 1.6500, -0.5000),
					"from": Vector3(0.0, 1.6500, 8.5000),
					"to": Vector3(2.6000, 1.6500, -0.2000),
					"width": 4.1000,
					"height": 3.8000
				}
			]
		},
		{
			"title": "Level 5: Prism Run",
			"objective": "Read the chain, meet the pulse late, and finish with one clean redirect.",
			"spawn": Vector3(0.0, 0.0, 9.3000),
			"source": Vector3(0.0, 1.6500, 9.3000),
			"fire_zone_radius": 2.2500,
			"yaw": 3.1416,
			"target": Vector3(8.5000, 2.0500, -8.2000),
			"target_radius": 2.6000,
			"target_visual_radius": 0.8800,
			"pulse_speed": 9.4000,
			"pulse_ttl": 12.0,
			"player_reflect_stability_ratio": 0.4500,
			"max_pulse_speed_multiplier": 1.7500,
			"world_bounds_min": Vector3(-20.0, -2.0, -158.0),
			"world_bounds_max": Vector3(20.0, 14.0, 22.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, 0.0),
					"size": Vector3(26.0, 0.3000, 26.0)
				},
				{
					"center": Vector3(-4.0, 0.2500, -1.8000),
					"size": Vector3(4.0, 0.3500, 4.0)
				},
				{
					"center": Vector3(2.8000, 0.8000, -4.8000),
					"size": Vector3(4.2000, 0.3500, 4.2000)
				},
				{
					"center": Vector3(8.4000, 0.4500, -8.2000),
					"size": Vector3(3.8000, 0.3500, 3.8000)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-0.8000, 1.6000, -7.2000),
					"size": Vector3(7.0, 3.2000, 0.7000)
				},
				{
					"center": Vector3(6.2000, 1.5000, 3.8000),
					"size": Vector3(0.8000, 3.0, 6.0)
				}
			],
			"channels": [],
			"appointments": [],
			"reflectors": [
				{
					"center": Vector3(-4.7000, 1.7500, 1.3000),
					"from": Vector3(0.0, 1.6500, 9.3000),
					"to": Vector3(5.2000, 2.1000, -1.4000),
					"width": 4.2000,
					"height": 4.0
				},
				{
					"center": Vector3(5.2000, 2.1000, -1.4000),
					"from": Vector3(-4.7000, 1.7500, 1.3000),
					"to": Vector3(2.4000, 2.5500, -5.2000),
					"width": 4.1000,
					"height": 3.7000
				}
			],
			"pitch": 0.0300
		},
		{
			"title": "Lab: Appointment Run",
			"objective": "Cut off the pulse at three different meeting points; if you only watch, the route breaks.",
			"spawn": Vector3(0.0, 0.0, 18.0),
			"source": Vector3(0.0, 1.5800, 18.0),
			"fire_zone_radius": 2.4500,
			"yaw": 3.1416,
			"target": Vector3(0.0, 1.5800, -76.0),
			"target_radius": 2.4500,
			"target_visual_radius": 0.9500,
			"pulse_speed": 11.5000,
			"pulse_ttl": 13.5000,
			"player_reflect_stability_ratio": 0.4500,
			"max_pulse_speed_multiplier": 1.7500,
			"world_bounds_min": Vector3(-20.0, -2.0, -158.0),
			"world_bounds_max": Vector3(20.0, 14.0, 22.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, -29.0),
					"size": Vector3(24.0, 0.3000, 102.0)
				},
				{
					"center": Vector3(-5.0, 0.0800, -8.0),
					"size": Vector3(5.0, 0.3500, 6.0)
				},
				{
					"center": Vector3(5.0, 0.4600, -20.0),
					"size": Vector3(5.3000, 0.3500, 6.5000)
				},
				{
					"center": Vector3(9.0, 0.4600, -31.0),
					"size": Vector3(4.5000, 0.3500, 6.0)
				},
				{
					"center": Vector3(-6.0, 0.7800, -37.0),
					"size": Vector3(5.2000, 0.3500, 6.5000)
				},
				{
					"center": Vector3(6.0, 0.5600, -50.0),
					"size": Vector3(5.2000, 0.3500, 6.5000)
				},
				{
					"center": Vector3(-8.0, 0.3500, -59.0),
					"size": Vector3(4.8000, 0.3500, 6.0)
				},
				{
					"center": Vector3(4.5000, 0.2800, -66.0),
					"size": Vector3(3.4000, 0.3500, 8.0)
				},
				{
					"center": Vector3(0.0, 0.4000, -76.0),
					"size": Vector3(5.5000, 0.3500, 5.0)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-12.3000, 1.7000, -28.0),
					"size": Vector3(0.8000, 3.4000, 92.0)
				},
				{
					"center": Vector3(12.3000, 1.7000, -28.0),
					"size": Vector3(0.8000, 3.4000, 92.0)
				},
				{
					"center": Vector3(-7.1000, 1.6000, -9.2000),
					"size": Vector3(2.2000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(-8.8000, 1.6000, -38.1000),
					"size": Vector3(2.4000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(7.3000, 1.6000, -67.5000),
					"size": Vector3(2.4000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(0.0, 1.6000, -84.0),
					"size": Vector3(18.0, 3.2000, 0.8000)
				}
			],
			"channels": [
				{
					"from": Vector3(-5.0, 1.5800, -8.0),
					"to": Vector3(5.0, 1.5800, -20.0)
				},
				{
					"from": Vector3(-6.0, 1.5800, -37.0),
					"to": Vector3(6.0, 1.5800, -50.0)
				},
				{
					"from": Vector3(4.5000, 1.5800, -66.0),
					"to": Vector3(0.0, 1.5800, -76.0)
				}
			],
			"appointments": [
				{
					"center": Vector3(-5.0, 1.5800, -8.0),
					"variant": "ring"
				},
				{
					"center": Vector3(-6.0, 1.5800, -37.0),
					"variant": "chevron"
				},
				{
					"center": Vector3(4.5000, 1.5800, -66.0),
					"variant": "bridge"
				}
			],
			"reflectors": [
				{
					"center": Vector3(0.0, 1.5800, 9.0),
					"from": Vector3(0.0, 1.5800, 18.0),
					"to": Vector3(9.0, 1.5800, 0.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(9.0, 1.5800, 0.0),
					"from": Vector3(0.0, 1.5800, 9.0),
					"to": Vector3(-5.0, 1.5800, -8.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(5.0, 1.5800, -20.0),
					"from": Vector3(-5.0, 1.5800, -8.0),
					"to": Vector3(9.0, 1.5800, -31.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(9.0, 1.5800, -31.0),
					"from": Vector3(5.0, 1.5800, -20.0),
					"to": Vector3(-6.0, 1.5800, -37.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(6.0, 1.5800, -50.0),
					"from": Vector3(-6.0, 1.5800, -37.0),
					"to": Vector3(-8.0, 1.5800, -59.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-8.0, 1.5800, -59.0),
					"from": Vector3(6.0, 1.5800, -50.0),
					"to": Vector3(4.5000, 1.5800, -66.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-10.0, 1.5800, -48.0),
					"from": Vector3(9.0, 1.5800, -31.0),
					"to": Vector3(0.0, 1.5800, -76.0),
					"label": "optional",
					"width": 4.2000,
					"height": 3.8000
				}
			]
		},
		{
			"title": "Lab: Return Lanes",
			"objective": "Let the pulse travel away, cut across the course, and meet it on the return lane.",
			"spawn": Vector3(0.0, 0.0, 18.0),
			"source": Vector3(0.0, 1.5800, 18.0),
			"fire_zone_radius": 2.4500,
			"yaw": 3.1416,
			"target": Vector3(0.0, 1.5800, -80.0),
			"target_radius": 2.4500,
			"target_visual_radius": 0.9500,
			"pulse_speed": 11.8000,
			"pulse_ttl": 13.5000,
			"player_reflect_stability_ratio": 0.4500,
			"max_pulse_speed_multiplier": 1.7500,
			"world_bounds_min": Vector3(-20.0, -2.0, -158.0),
			"world_bounds_max": Vector3(20.0, 14.0, 22.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, -30.0),
					"size": Vector3(26.0, 0.3000, 106.0)
				},
				{
					"center": Vector3(-7.0, 0.1600, -12.0),
					"size": Vector3(5.2000, 0.3500, 6.0)
				},
				{
					"center": Vector3(6.0, 0.3200, -27.0),
					"size": Vector3(5.0, 0.3500, 6.5000)
				},
				{
					"center": Vector3(-10.0, 0.6200, -38.0),
					"size": Vector3(4.8000, 0.3500, 6.5000)
				},
				{
					"center": Vector3(8.0, 0.9200, -48.0),
					"size": Vector3(5.1000, 0.3500, 6.2000)
				},
				{
					"center": Vector3(-5.0, 0.6800, -62.0),
					"size": Vector3(5.0, 0.3500, 6.5000)
				},
				{
					"center": Vector3(3.0, 0.3800, -70.0),
					"size": Vector3(3.3000, 0.3500, 7.8000)
				},
				{
					"center": Vector3(0.0, 0.4000, -80.0),
					"size": Vector3(5.5000, 0.3500, 5.0)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-12.7000, 1.7000, -30.0),
					"size": Vector3(0.8000, 3.4000, 96.0)
				},
				{
					"center": Vector3(12.7000, 1.7000, -30.0),
					"size": Vector3(0.8000, 3.4000, 96.0)
				},
				{
					"center": Vector3(-9.0, 1.6000, -13.2000),
					"size": Vector3(2.4000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(10.2000, 1.6000, -49.2000),
					"size": Vector3(2.4000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(4.7000, 1.6000, -71.4000),
					"size": Vector3(2.2000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(0.0, 1.6000, -88.0),
					"size": Vector3(18.0, 3.2000, 0.8000)
				}
			],
			"channels": [
				{
					"from": Vector3(-7.0, 1.5800, -12.0),
					"to": Vector3(6.0, 1.5800, -27.0)
				},
				{
					"from": Vector3(8.0, 1.5800, -48.0),
					"to": Vector3(-5.0, 1.5800, -62.0)
				},
				{
					"from": Vector3(3.0, 1.5800, -70.0),
					"to": Vector3(0.0, 1.5800, -80.0)
				},
				{
					"from": Vector3(8.0, 1.5800, -48.0),
					"to": Vector3(9.8000, 1.5800, -66.0),
					"label": "optional"
				}
			],
			"appointments": [
				{
					"center": Vector3(-7.0, 1.5800, -12.0),
					"variant": "chevron"
				},
				{
					"center": Vector3(8.0, 1.5800, -48.0),
					"variant": "ring"
				},
				{
					"center": Vector3(3.0, 1.5800, -70.0),
					"variant": "bridge"
				}
			],
			"reflectors": [
				{
					"center": Vector3(0.0, 1.5800, 9.0),
					"from": Vector3(0.0, 1.5800, 18.0),
					"to": Vector3(10.0, 1.5800, 2.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(10.0, 1.5800, 2.0),
					"from": Vector3(0.0, 1.5800, 9.0),
					"to": Vector3(-7.0, 1.5800, -12.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(6.0, 1.5800, -27.0),
					"from": Vector3(-7.0, 1.5800, -12.0),
					"to": Vector3(-10.0, 1.5800, -38.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-10.0, 1.5800, -38.0),
					"from": Vector3(6.0, 1.5800, -27.0),
					"to": Vector3(8.0, 1.5800, -48.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-5.0, 1.5800, -62.0),
					"from": Vector3(8.0, 1.5800, -48.0),
					"to": Vector3(3.0, 1.5800, -70.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(9.8000, 1.5800, -66.0),
					"from": Vector3(8.0, 1.5800, -48.0),
					"to": Vector3(0.0, 1.5800, -80.0),
					"label": "optional",
					"width": 4.2000,
					"height": 3.8000
				}
			]
		},
		{
			"title": "Level 4: Vertical Catch",
			"objective": "Climb into the high lane, catch the pulse, and send it downrange.",
			"spawn": Vector3(-6.5000, 0.0, 8.0),
			"source": Vector3(-6.5000, 1.6500, 8.0),
			"fire_zone_radius": 2.2500,
			"yaw": 2.8903,
			"target": Vector3(7.4000, 1.7000, -7.0),
			"target_radius": 2.6000,
			"target_visual_radius": 0.8800,
			"pulse_speed": 8.6000,
			"pulse_ttl": 11.0,
			"player_reflect_stability_ratio": 0.4500,
			"max_pulse_speed_multiplier": 1.7500,
			"world_bounds_min": Vector3(-20.0, -2.0, -158.0),
			"world_bounds_max": Vector3(20.0, 14.0, 22.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, 0.0),
					"size": Vector3(24.0, 0.3000, 24.0)
				},
				{
					"center": Vector3(-2.3000, 0.4500, 2.8000),
					"size": Vector3(3.6000, 0.3500, 3.4000)
				},
				{
					"center": Vector3(0.2000, 1.3000, -0.4000),
					"size": Vector3(4.2000, 0.3500, 4.2000)
				},
				{
					"center": Vector3(7.2000, 0.2000, -7.0),
					"size": Vector3(3.6000, 0.3500, 3.6000)
				}
			],
			"absorbers": [
				{
					"center": Vector3(0.6000, 1.7000, -5.3000),
					"size": Vector3(5.4000, 3.2000, 0.7000)
				},
				{
					"center": Vector3(-8.8000, 1.4000, -4.0),
					"size": Vector3(1.0, 2.8000, 9.0)
				}
			],
			"channels": [],
			"appointments": [],
			"reflectors": [
				{
					"center": Vector3(-6.2000, 1.7500, -1.2000),
					"from": Vector3(-6.5000, 1.6500, 8.0),
					"to": Vector3(0.4000, 3.1500, -0.4000),
					"width": 4.2000,
					"height": 3.8000
				}
			],
			"pitch": 0.0800
		},
		{
			"title": "Lab: Vertical Switchback",
			"objective": "Climb and drop through raised lanes while the pulse returns on offset heights.",
			"spawn": Vector3(0.0, 0.0, 18.0),
			"source": Vector3(0.0, 2.0500, 18.0),
			"fire_zone_radius": 2.4500,
			"yaw": 3.1416,
			"target": Vector3(0.0, 2.0500, -78.0),
			"target_radius": 2.5500,
			"target_visual_radius": 0.9500,
			"pulse_speed": 11.3000,
			"pulse_ttl": 13.5000,
			"player_reflect_stability_ratio": 0.4500,
			"max_pulse_speed_multiplier": 1.7500,
			"world_bounds_min": Vector3(-20.0, -2.0, -158.0),
			"world_bounds_max": Vector3(20.0, 14.0, 22.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, -29.0),
					"size": Vector3(24.0, 0.3000, 108.0)
				},
				{
					"center": Vector3(-6.0, 0.2800, -11.0),
					"size": Vector3(5.2000, 0.3500, 6.0)
				},
				{
					"center": Vector3(6.5000, 0.7400, -24.0),
					"size": Vector3(5.2000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(-8.0, 1.0500, -36.0),
					"size": Vector3(5.2000, 0.3500, 6.5000)
				},
				{
					"center": Vector3(8.5000, 0.7000, -48.0),
					"size": Vector3(5.2000, 0.3500, 6.5000)
				},
				{
					"center": Vector3(-5.5000, 0.3400, -61.0),
					"size": Vector3(5.2000, 0.3500, 6.2000)
				},
				{
					"center": Vector3(4.5000, 0.8200, -69.0),
					"size": Vector3(4.8000, 0.3500, 6.0)
				},
				{
					"center": Vector3(0.0, 0.7000, -78.0),
					"size": Vector3(5.5000, 0.3500, 5.0)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-12.3000, 1.8500, -29.0),
					"size": Vector3(0.8000, 3.7000, 98.0)
				},
				{
					"center": Vector3(12.3000, 1.8500, -29.0),
					"size": Vector3(0.8000, 3.7000, 98.0)
				},
				{
					"center": Vector3(-8.3000, 1.9500, -12.5000),
					"size": Vector3(2.3000, 3.3000, 0.6500)
				},
				{
					"center": Vector3(10.6000, 2.0, -49.8000),
					"size": Vector3(2.3000, 3.3000, 0.6500)
				},
				{
					"center": Vector3(6.7000, 2.0, -70.7000),
					"size": Vector3(2.3000, 3.3000, 0.6500)
				},
				{
					"center": Vector3(0.0, 2.0, -86.0),
					"size": Vector3(18.0, 3.2000, 0.8000)
				}
			],
			"channels": [
				{
					"from": Vector3(-6.0, 2.0500, -11.0),
					"to": Vector3(6.5000, 2.0500, -24.0)
				},
				{
					"from": Vector3(8.5000, 2.0500, -48.0),
					"to": Vector3(-5.5000, 2.0500, -61.0)
				},
				{
					"from": Vector3(4.5000, 2.0500, -69.0),
					"to": Vector3(0.0, 2.0500, -78.0)
				},
				{
					"from": Vector3(-8.0, 2.0500, -36.0),
					"to": Vector3(8.5000, 2.0500, -48.0),
					"label": "optional"
				}
			],
			"appointments": [
				{
					"center": Vector3(-6.0, 2.0500, -11.0),
					"variant": "bridge"
				},
				{
					"center": Vector3(8.5000, 2.0500, -48.0),
					"variant": "ring"
				},
				{
					"center": Vector3(4.5000, 2.0500, -69.0),
					"variant": "chevron"
				}
			],
			"reflectors": [
				{
					"center": Vector3(0.0, 2.0500, 9.0),
					"from": Vector3(0.0, 2.0500, 18.0),
					"to": Vector3(9.5000, 2.0500, 0.0),
					"label": "main",
					"width": 5.4000,
					"height": 4.8000
				},
				{
					"center": Vector3(9.5000, 2.0500, 0.0),
					"from": Vector3(0.0, 2.0500, 9.0),
					"to": Vector3(-6.0, 2.0500, -11.0),
					"label": "main",
					"width": 5.4000,
					"height": 4.8000
				},
				{
					"center": Vector3(6.5000, 2.0500, -24.0),
					"from": Vector3(-6.0, 2.0500, -11.0),
					"to": Vector3(-8.0, 2.0500, -36.0),
					"label": "main",
					"width": 5.4000,
					"height": 4.8000
				},
				{
					"center": Vector3(-8.0, 2.0500, -36.0),
					"from": Vector3(6.5000, 2.0500, -24.0),
					"to": Vector3(8.5000, 2.0500, -48.0),
					"label": "main",
					"width": 5.4000,
					"height": 4.8000
				},
				{
					"center": Vector3(-5.5000, 2.0500, -61.0),
					"from": Vector3(8.5000, 2.0500, -48.0),
					"to": Vector3(4.5000, 2.0500, -69.0),
					"label": "main",
					"width": 5.4000,
					"height": 4.8000
				},
				{
					"center": Vector3(-10.0, 2.0500, -49.0),
					"from": Vector3(-8.0, 2.0500, -36.0),
					"to": Vector3(0.0, 2.0500, -78.0),
					"label": "optional",
					"width": 4.2000,
					"height": 4.2000
				}
			]
		},
		{
			"title": "Lab: Relay Arena",
			"objective": "Work a compact figure-eight route where the pulse crosses the same arena from different angles.",
			"spawn": Vector3(0.0, 0.0, 18.0),
			"source": Vector3(0.0, 1.5800, 18.0),
			"fire_zone_radius": 2.4500,
			"yaw": 3.1416,
			"target": Vector3(0.0, 1.5800, -76.0),
			"target_radius": 2.5500,
			"target_visual_radius": 0.9500,
			"pulse_speed": 11.7000,
			"pulse_ttl": 13.5000,
			"player_reflect_stability_ratio": 0.4500,
			"max_pulse_speed_multiplier": 1.7500,
			"world_bounds_min": Vector3(-20.0, -2.0, -158.0),
			"world_bounds_max": Vector3(20.0, 14.0, 22.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, -29.0),
					"size": Vector3(28.0, 0.3000, 108.0)
				},
				{
					"center": Vector3(0.0, 0.1000, -9.0),
					"size": Vector3(6.2000, 0.3500, 6.2000)
				},
				{
					"center": Vector3(7.5000, 0.1800, -19.0),
					"size": Vector3(5.0, 0.3500, 6.0)
				},
				{
					"center": Vector3(-7.5000, 0.3200, -28.0),
					"size": Vector3(5.0, 0.3500, 6.5000)
				},
				{
					"center": Vector3(8.0, 0.4600, -40.0),
					"size": Vector3(5.2000, 0.3500, 6.5000)
				},
				{
					"center": Vector3(-8.0, 0.3800, -51.0),
					"size": Vector3(5.2000, 0.3500, 6.0)
				},
				{
					"center": Vector3(5.0, 0.3000, -64.0),
					"size": Vector3(4.8000, 0.3500, 6.2000)
				},
				{
					"center": Vector3(0.0, 0.4000, -76.0),
					"size": Vector3(5.5000, 0.3500, 5.0)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-13.7000, 1.7000, -29.0),
					"size": Vector3(0.8000, 3.4000, 98.0)
				},
				{
					"center": Vector3(13.7000, 1.7000, -29.0),
					"size": Vector3(0.8000, 3.4000, 98.0)
				},
				{
					"center": Vector3(-2.3000, 1.6000, -10.7000),
					"size": Vector3(2.4000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(10.4000, 1.6000, -41.7000),
					"size": Vector3(2.4000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(7.4000, 1.6000, -65.8000),
					"size": Vector3(2.4000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(0.0, 1.6000, -84.0),
					"size": Vector3(18.0, 3.2000, 0.8000)
				}
			],
			"channels": [
				{
					"from": Vector3(0.0, 1.5800, -9.0),
					"to": Vector3(7.5000, 1.5800, -19.0)
				},
				{
					"from": Vector3(8.0, 1.5800, -40.0),
					"to": Vector3(-8.0, 1.5800, -51.0)
				},
				{
					"from": Vector3(5.0, 1.5800, -64.0),
					"to": Vector3(0.0, 1.5800, -76.0)
				},
				{
					"from": Vector3(-7.5000, 1.5800, -28.0),
					"to": Vector3(8.0, 1.5800, -40.0),
					"label": "optional"
				}
			],
			"appointments": [
				{
					"center": Vector3(0.0, 1.5800, -9.0),
					"variant": "ring"
				},
				{
					"center": Vector3(8.0, 1.5800, -40.0),
					"variant": "chevron"
				},
				{
					"center": Vector3(5.0, 1.5800, -64.0),
					"variant": "bridge"
				}
			],
			"reflectors": [
				{
					"center": Vector3(0.0, 1.5800, 9.0),
					"from": Vector3(0.0, 1.5800, 18.0),
					"to": Vector3(10.0, 1.5800, 0.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(10.0, 1.5800, 0.0),
					"from": Vector3(0.0, 1.5800, 9.0),
					"to": Vector3(0.0, 1.5800, -9.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(7.5000, 1.5800, -19.0),
					"from": Vector3(0.0, 1.5800, -9.0),
					"to": Vector3(-7.5000, 1.5800, -28.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-7.5000, 1.5800, -28.0),
					"from": Vector3(7.5000, 1.5800, -19.0),
					"to": Vector3(8.0, 1.5800, -40.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-8.0, 1.5800, -51.0),
					"from": Vector3(8.0, 1.5800, -40.0),
					"to": Vector3(5.0, 1.5800, -64.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-10.5000, 1.5800, -39.0),
					"from": Vector3(-7.5000, 1.5800, -28.0),
					"to": Vector3(0.0, 1.5800, -76.0),
					"label": "optional",
					"width": 4.2000,
					"height": 3.8000
				}
			]
		},
		{
			"title": "Lab: Overdrive Chain",
			"objective": "Ride a longer mirror chain where each clean bounce refreshes stability and pushes the pulse faster.",
			"spawn": Vector3(0.0, 0.0, 18.0),
			"source": Vector3(0.0, 1.5800, 18.0),
			"fire_zone_radius": 2.4500,
			"yaw": 3.1416,
			"target": Vector3(0.0, 1.5800, -82.0),
			"target_radius": 2.6500,
			"target_visual_radius": 1.0,
			"pulse_speed": 10.6000,
			"pulse_ttl": 13.5000,
			"player_reflect_stability_ratio": 0.4500,
			"max_pulse_speed_multiplier": 1.7500,
			"world_bounds_min": Vector3(-20.0, -2.0, -158.0),
			"world_bounds_max": Vector3(20.0, 14.0, 22.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, -31.0),
					"size": Vector3(28.0, 0.3000, 112.0)
				},
				{
					"center": Vector3(-8.0, 0.0800, -14.0),
					"size": Vector3(5.1000, 0.3500, 6.0)
				},
				{
					"center": Vector3(4.0, 0.2400, -30.0),
					"size": Vector3(5.2000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(9.0, 0.4800, -41.0),
					"size": Vector3(4.8000, 0.3500, 6.0)
				},
				{
					"center": Vector3(-9.0, 0.6200, -51.0),
					"size": Vector3(5.2000, 0.3500, 6.5000)
				},
				{
					"center": Vector3(7.0, 0.5800, -63.0),
					"size": Vector3(5.2000, 0.3500, 6.0)
				},
				{
					"center": Vector3(-3.5000, 0.3600, -73.0),
					"size": Vector3(5.0, 0.3500, 6.0)
				},
				{
					"center": Vector3(0.0, 0.4000, -82.0),
					"size": Vector3(5.5000, 0.3500, 5.0)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-13.7000, 1.7000, -31.0),
					"size": Vector3(0.8000, 3.4000, 102.0)
				},
				{
					"center": Vector3(13.7000, 1.7000, -31.0),
					"size": Vector3(0.8000, 3.4000, 102.0)
				},
				{
					"center": Vector3(-10.1000, 1.6000, -15.2000),
					"size": Vector3(2.4000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(11.1000, 1.6000, -42.2000),
					"size": Vector3(2.4000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(9.1000, 1.6000, -64.2000),
					"size": Vector3(2.4000, 3.2000, 0.6500)
				},
				{
					"center": Vector3(0.0, 1.6000, -89.0),
					"size": Vector3(18.0, 3.2000, 0.8000)
				}
			],
			"channels": [
				{
					"from": Vector3(-8.0, 1.5800, -14.0),
					"to": Vector3(4.0, 1.5800, -30.0)
				},
				{
					"from": Vector3(9.0, 1.5800, -41.0),
					"to": Vector3(-9.0, 1.5800, -51.0)
				},
				{
					"from": Vector3(7.0, 1.5800, -63.0),
					"to": Vector3(-3.5000, 1.5800, -73.0)
				},
				{
					"from": Vector3(-3.5000, 1.5800, -73.0),
					"to": Vector3(0.0, 1.5800, -82.0)
				}
			],
			"appointments": [
				{
					"center": Vector3(-8.0, 1.5800, -14.0),
					"variant": "chevron"
				},
				{
					"center": Vector3(9.0, 1.5800, -41.0),
					"variant": "bridge"
				},
				{
					"center": Vector3(7.0, 1.5800, -63.0),
					"variant": "ring"
				}
			],
			"reflectors": [
				{
					"center": Vector3(0.0, 1.5800, 9.0),
					"from": Vector3(0.0, 1.5800, 18.0),
					"to": Vector3(8.5000, 1.5800, 1.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(8.5000, 1.5800, 1.0),
					"from": Vector3(0.0, 1.5800, 9.0),
					"to": Vector3(-9.5000, 1.5800, -5.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-9.5000, 1.5800, -5.0),
					"from": Vector3(8.5000, 1.5800, 1.0),
					"to": Vector3(-8.0, 1.5800, -14.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(4.0, 1.5800, -30.0),
					"from": Vector3(-8.0, 1.5800, -14.0),
					"to": Vector3(-6.0, 1.5800, -36.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-6.0, 1.5800, -36.0),
					"from": Vector3(4.0, 1.5800, -30.0),
					"to": Vector3(9.0, 1.5800, -41.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-9.0, 1.5800, -51.0),
					"from": Vector3(9.0, 1.5800, -41.0),
					"to": Vector3(1.0, 1.5800, -57.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(1.0, 1.5800, -57.0),
					"from": Vector3(-9.0, 1.5800, -51.0),
					"to": Vector3(7.0, 1.5800, -63.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				},
				{
					"center": Vector3(-3.5000, 1.5800, -73.0),
					"from": Vector3(7.0, 1.5800, -63.0),
					"to": Vector3(0.0, 1.5800, -82.0),
					"label": "main",
					"width": 5.2000,
					"height": 4.4000
				}
			]
		},
		{
			"title": "Lab: Long Reach",
			"objective": "Catch the dead-end chain, charge through the side loop, then send the full-speed pulse over the empty reach.",
			"spawn": Vector3(0.0, 0.0, 18.0),
			"source": Vector3(0.0, 1.5800, 18.0),
			"fire_zone_radius": 2.4500,
			"yaw": 3.1416,
			"target": Vector3(8.5000, 1.5800, -148.0),
			"target_radius": 2.7500,
			"target_visual_radius": 1.0,
			"pulse_speed": 9.2000,
			"pulse_ttl": 14.5000,
			"player_reflect_stability_ratio": 0.4500,
			"max_pulse_speed_multiplier": 1.7500,
			"world_bounds_min": Vector3(-20.0, -2.0, -158.0),
			"world_bounds_max": Vector3(20.0, 14.0, 22.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, -16.0),
					"size": Vector3(34.0, 0.3000, 76.0)
				},
				{
					"center": Vector3(0.0, 0.0400, 9.0),
					"size": Vector3(7.5000, 0.3500, 7.0)
				},
				{
					"center": Vector3(11.0, 0.2000, 2.0),
					"size": Vector3(5.6000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(-10.0, 0.2400, -9.0),
					"size": Vector3(5.8000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(-2.0, 0.1800, -20.0),
					"size": Vector3(6.4000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(9.0, 0.4400, -30.0),
					"size": Vector3(5.6000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(-10.0, 0.4800, -41.0),
					"size": Vector3(5.8000, 0.3500, 6.6000)
				},
				{
					"center": Vector3(5.0, 0.3200, -50.0),
					"size": Vector3(7.0, 0.3500, 7.0)
				},
				{
					"center": Vector3(13.0, 0.4200, -45.0),
					"size": Vector3(4.8000, 0.3500, 5.6000)
				},
				{
					"center": Vector3(-6.0, 0.4000, -35.0),
					"size": Vector3(5.0, 0.3500, 5.6000)
				},
				{
					"center": Vector3(-11.5000, 0.5000, -132.0),
					"size": Vector3(5.8000, 0.3500, 7.0)
				},
				{
					"center": Vector3(8.5000, 0.3800, -148.0),
					"size": Vector3(6.6000, 0.3500, 6.4000)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-17.2000, 1.7000, -64.0),
					"size": Vector3(0.8000, 3.4000, 168.0)
				},
				{
					"center": Vector3(17.2000, 1.7000, -64.0),
					"size": Vector3(0.8000, 3.4000, 168.0)
				},
				{
					"center": Vector3(0.0, 1.6000, -153.0),
					"size": Vector3(30.0, 3.2000, 0.8000)
				},
				{
					"center": Vector3(2.2000, 1.5500, -6.5000),
					"size": Vector3(2.8000, 3.1000, 0.6500)
				},
				{
					"center": Vector3(-4.3000, 1.5500, -31.0),
					"size": Vector3(3.3000, 3.1000, 0.6500)
				},
				{
					"center": Vector3(10.0, 1.5500, -53.0),
					"size": Vector3(3.4000, 3.1000, 0.7000)
				}
			],
			"channels": [
				{
					"from": Vector3(-2.0, 1.5800, -20.0),
					"to": Vector3(9.0, 1.5800, -30.0)
				},
				{
					"from": Vector3(5.0, 1.5800, -50.0),
					"to": Vector3(-11.5000, 1.5800, -132.0)
				},
				{
					"from": Vector3(5.0, 1.5800, -50.0),
					"to": Vector3(13.0, 1.5800, -45.0),
					"label": "optional"
				}
			],
			"appointments": [
				{
					"center": Vector3(-2.0, 1.5800, -20.0),
					"variant": "ring"
				},
				{
					"center": Vector3(5.0, 1.5800, -50.0),
					"variant": "bridge"
				}
			],
			"reflectors": [
				{
					"center": Vector3(0.0, 1.5800, 9.0),
					"from": Vector3(0.0, 1.5800, 18.0),
					"to": Vector3(11.0, 1.5800, 2.0),
					"label": "main",
					"width": 5.4000,
					"height": 4.4000
				},
				{
					"center": Vector3(11.0, 1.5800, 2.0),
					"from": Vector3(0.0, 1.5800, 9.0),
					"to": Vector3(-10.0, 1.5800, -9.0),
					"label": "main",
					"width": 5.4000,
					"height": 4.4000
				},
				{
					"center": Vector3(-10.0, 1.5800, -9.0),
					"from": Vector3(11.0, 1.5800, 2.0),
					"to": Vector3(-2.0, 1.5800, -20.0),
					"label": "main",
					"width": 5.4000,
					"height": 4.4000
				},
				{
					"center": Vector3(9.0, 1.5800, -30.0),
					"from": Vector3(-2.0, 1.5800, -20.0),
					"to": Vector3(-10.0, 1.5800, -41.0),
					"label": "main",
					"width": 5.4000,
					"height": 4.4000
				},
				{
					"center": Vector3(-10.0, 1.5800, -41.0),
					"from": Vector3(9.0, 1.5800, -30.0),
					"to": Vector3(5.0, 1.5800, -50.0),
					"label": "main",
					"width": 5.4000,
					"height": 4.4000
				},
				{
					"center": Vector3(13.0, 1.5800, -45.0),
					"from": Vector3(5.0, 1.5800, -50.0),
					"to": Vector3(-6.0, 1.5800, -35.0),
					"label": "optional",
					"width": 4.6000,
					"height": 4.0
				},
				{
					"center": Vector3(-6.0, 1.5800, -35.0),
					"from": Vector3(13.0, 1.5800, -45.0),
					"to": Vector3(5.0, 1.5800, -50.0),
					"label": "optional",
					"width": 4.6000,
					"height": 4.0
				},
				{
					"center": Vector3(-11.5000, 1.5800, -132.0),
					"from": Vector3(5.0, 1.5800, -50.0),
					"to": Vector3(8.5000, 1.5800, -148.0),
					"label": "main",
					"width": 6.2000,
					"height": 4.8000
				}
			]
		},
		{
			"title": "Lab: Golden Route",
			"objective": "A focused ruined-city route: read the bright channel, replace six broken mirrors, charge speed, cross the long reach, and finish clean.",
			"spawn": Vector3(0.0, 0.0, 18.0),
			"source": Vector3(0.0, 1.5800, 18.0),
			"fire_zone_radius": 2.8000,
			"yaw": 3.1416,
			"target": Vector3(0.0, 1.5800, -176.0),
			"target_radius": 3.0,
			"target_visual_radius": 1.0500,
			"pulse_speed": 12.2000,
			"pulse_ttl": 18.0,
			"player_reflect_stability_ratio": 0.5500,
			"max_pulse_speed_multiplier": 2.5000,
			"world_bounds_min": Vector3(-34.0, -2.0, -188.0),
			"world_bounds_max": Vector3(34.0, 18.0, 24.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, -78.0),
					"size": Vector3(42.0, 0.3000, 206.0)
				},
				{
					"center": Vector3(0.0, 0.0800, 12.0),
					"size": Vector3(7.8000, 0.3500, 8.0)
				},
				{
					"center": Vector3(-6.0, 0.2000, -14.0),
					"size": Vector3(6.2000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(7.0, 0.2200, -48.0),
					"size": Vector3(6.2000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(-8.0, 0.6800, -82.0),
					"size": Vector3(6.4000, 0.3500, 6.6000)
				},
				{
					"center": Vector3(0.0, 0.9200, -128.0),
					"size": Vector3(7.2000, 0.3500, 7.2000)
				},
				{
					"center": Vector3(6.0, 0.5000, -162.0),
					"size": Vector3(6.2000, 0.3500, 6.2000)
				},
				{
					"center": Vector3(0.0, 0.4200, -176.0),
					"size": Vector3(8.0, 0.3500, 7.4000)
				},
				{
					"center": Vector3(8.0, 0.1600, -30.0),
					"size": Vector3(5.4000, 0.3500, 6.0)
				},
				{
					"center": Vector3(8.0, 0.2000, -40.0),
					"size": Vector3(5.4000, 0.3500, 6.0)
				},
				{
					"center": Vector3(-12.0, 0.4200, -64.0),
					"size": Vector3(5.2000, 0.3500, 6.0)
				},
				{
					"center": Vector3(12.0, 0.5800, -76.0),
					"size": Vector3(5.2000, 0.3500, 6.0)
				},
				{
					"center": Vector3(8.0, 0.7400, -96.0),
					"size": Vector3(5.2000, 0.3500, 6.0)
				},
				{
					"center": Vector3(-8.0, 0.9000, -106.0),
					"size": Vector3(5.2000, 0.3500, 6.0)
				},
				{
					"center": Vector3(8.0, 1.0400, -116.0),
					"size": Vector3(5.2000, 0.3500, 6.0)
				},
				{
					"center": Vector3(-18.0, 0.5200, -154.0),
					"size": Vector3(5.6000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(-18.0, 0.3000, -52.0),
					"size": Vector3(4.8000, 0.3500, 5.4000)
				},
				{
					"center": Vector3(18.0, 0.7800, -102.0),
					"size": Vector3(4.8000, 0.3500, 5.4000)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-22.0, 1.7000, -78.0),
					"size": Vector3(0.8000, 3.4000, 196.0)
				},
				{
					"center": Vector3(22.0, 1.7000, -78.0),
					"size": Vector3(0.8000, 3.4000, 196.0)
				},
				{
					"center": Vector3(0.0, 1.7000, -184.0),
					"size": Vector3(42.0, 3.4000, 0.8000)
				},
				{
					"center": Vector3(-9.0, 1.5500, -16.5000),
					"size": Vector3(3.2000, 3.1000, 0.6500)
				},
				{
					"center": Vector3(8.4000, 1.5500, -51.5000),
					"size": Vector3(3.2000, 3.1000, 0.6500)
				},
				{
					"center": Vector3(-10.5000, 1.5500, -84.5000),
					"size": Vector3(3.2000, 3.1000, 0.6500)
				},
				{
					"center": Vector3(1.8000, 1.5500, -131.0),
					"size": Vector3(3.4000, 3.1000, 0.6500)
				},
				{
					"center": Vector3(8.6000, 1.5500, -164.5000),
					"size": Vector3(3.2000, 3.1000, 0.6500)
				}
			],
			"channels": [
				{
					"from": Vector3(-6.0, 1.5800, -14.0),
					"to": Vector3(8.0, 1.5800, -30.0)
				},
				{
					"from": Vector3(7.0, 1.5800, -48.0),
					"to": Vector3(-12.0, 1.5800, -64.0)
				},
				{
					"from": Vector3(-8.0, 1.5800, -82.0),
					"to": Vector3(8.0, 1.5800, -96.0)
				},
				{
					"from": Vector3(0.0, 1.5800, -128.0),
					"to": Vector3(-18.0, 1.5800, -154.0)
				},
				{
					"from": Vector3(6.0, 1.5800, -162.0),
					"to": Vector3(0.0, 1.5800, -176.0)
				},
				{
					"from": Vector3(7.0, 1.5800, -48.0),
					"to": Vector3(-18.0, 1.5800, -52.0),
					"label": "optional"
				},
				{
					"from": Vector3(-8.0, 1.5800, -82.0),
					"to": Vector3(18.0, 1.5800, -102.0),
					"label": "optional"
				}
			],
			"appointments": [
				{
					"center": Vector3(-6.0, 1.5800, -14.0),
					"variant": "ring"
				},
				{
					"center": Vector3(7.0, 1.5800, -48.0),
					"variant": "bridge"
				},
				{
					"center": Vector3(-8.0, 1.5800, -82.0),
					"variant": "chevron"
				},
				{
					"center": Vector3(0.0, 1.5800, -128.0),
					"variant": "ring"
				},
				{
					"center": Vector3(6.0, 1.5800, -162.0),
					"variant": "bridge"
				}
			],
			"reflectors": [
				{
					"center": Vector3(0.0, 1.5800, 8.0),
					"from": Vector3(0.0, 1.5800, 18.0),
					"to": Vector3(10.0, 1.5800, -2.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.6000
				},
				{
					"center": Vector3(10.0, 1.5800, -2.0),
					"from": Vector3(0.0, 1.5800, 8.0),
					"to": Vector3(-6.0, 1.5800, -14.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.6000
				},
				{
					"center": Vector3(8.0, 1.5800, -30.0),
					"from": Vector3(-6.0, 1.5800, -14.0),
					"to": Vector3(8.0, 1.5800, -40.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.6000
				},
				{
					"center": Vector3(8.0, 1.5800, -40.0),
					"from": Vector3(8.0, 1.5800, -30.0),
					"to": Vector3(7.0, 1.5800, -48.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.6000
				},
				{
					"center": Vector3(-12.0, 1.5800, -64.0),
					"from": Vector3(7.0, 1.5800, -48.0),
					"to": Vector3(12.0, 1.5800, -76.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.6000
				},
				{
					"center": Vector3(12.0, 1.5800, -76.0),
					"from": Vector3(-12.0, 1.5800, -64.0),
					"to": Vector3(-8.0, 1.5800, -82.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.6000
				},
				{
					"center": Vector3(8.0, 1.5800, -96.0),
					"from": Vector3(-8.0, 1.5800, -82.0),
					"to": Vector3(-8.0, 1.5800, -106.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.6000
				},
				{
					"center": Vector3(-8.0, 1.5800, -106.0),
					"from": Vector3(8.0, 1.5800, -96.0),
					"to": Vector3(8.0, 1.5800, -116.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.6000
				},
				{
					"center": Vector3(8.0, 1.5800, -116.0),
					"from": Vector3(-8.0, 1.5800, -106.0),
					"to": Vector3(0.0, 1.5800, -128.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.6000
				},
				{
					"center": Vector3(-18.0, 1.5800, -154.0),
					"from": Vector3(0.0, 1.5800, -128.0),
					"to": Vector3(6.0, 1.5800, -162.0),
					"label": "main",
					"width": 6.2000,
					"height": 4.8000
				},
				{
					"center": Vector3(-18.0, 1.5800, -52.0),
					"from": Vector3(7.0, 1.5800, -48.0),
					"to": Vector3(-8.0, 1.5800, -82.0),
					"label": "optional",
					"width": 4.2000,
					"height": 4.0
				},
				{
					"center": Vector3(18.0, 1.5800, -102.0),
					"from": Vector3(-8.0, 1.5800, -82.0),
					"to": Vector3(0.0, 1.5800, -128.0),
					"label": "optional",
					"width": 4.2000,
					"height": 4.0
				}
			],
			"fog_near": 34.0,
			"fog_far": 158.0
		},
		{
			"title": "Lab: Paddle Wall",
			"objective": "Paddle the pulse back across a six-mirror wall; each broken mirror beat gets tighter until the final send around the corner.",
			"spawn": Vector3(0.0, 0.0, 18.0),
			"source": Vector3(0.0, 1.5800, 18.0),
			"fire_zone_radius": 2.7000,
			"yaw": 2.1900,
			"target": Vector3(0.0, 1.5800, -144.0),
			"target_radius": 2.8500,
			"target_visual_radius": 1.0,
			"pulse_speed": 10.8000,
			"pulse_ttl": 18.0,
			"player_reflect_stability_ratio": 0.6200,
			"max_pulse_speed_multiplier": 2.7000,
			"world_bounds_min": Vector3(-28.0, -2.0, -154.0),
			"world_bounds_max": Vector3(28.0, 16.0, 24.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, -62.0),
					"size": Vector3(46.0, 0.3000, 172.0)
				},
				{
					"center": Vector3(0.0, 0.0600, 14.0),
					"size": Vector3(7.5000, 0.3500, 7.0)
				},
				{
					"center": Vector3(-10.0, 0.1800, -2.0),
					"size": Vector3(5.6000, 0.3500, 5.6000)
				},
				{
					"center": Vector3(-10.0, 0.2400, -20.0),
					"size": Vector3(5.6000, 0.3500, 5.6000)
				},
				{
					"center": Vector3(-10.0, 0.3200, -39.0),
					"size": Vector3(5.6000, 0.3500, 5.6000)
				},
				{
					"center": Vector3(-10.0, 0.4200, -59.0),
					"size": Vector3(5.6000, 0.3500, 5.6000)
				},
				{
					"center": Vector3(-10.0, 0.5200, -80.0),
					"size": Vector3(5.6000, 0.3500, 5.6000)
				},
				{
					"center": Vector3(-10.0, 0.6200, -102.0),
					"size": Vector3(5.6000, 0.3500, 5.6000)
				},
				{
					"center": Vector3(14.0, 0.2000, 8.0),
					"size": Vector3(5.2000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(14.0, 0.2400, -11.0),
					"size": Vector3(5.2000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(14.0, 0.3200, -31.0),
					"size": Vector3(5.2000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(14.0, 0.4200, -52.0),
					"size": Vector3(5.2000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(14.0, 0.5200, -74.0),
					"size": Vector3(5.2000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(14.0, 0.6200, -97.0),
					"size": Vector3(5.2000, 0.3500, 6.4000)
				},
				{
					"center": Vector3(14.0, 0.5200, -126.0),
					"size": Vector3(5.4000, 0.3500, 6.8000)
				},
				{
					"center": Vector3(0.0, 0.3800, -144.0),
					"size": Vector3(7.2000, 0.3500, 6.2000)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-22.5000, 1.7000, -62.0),
					"size": Vector3(0.8000, 3.4000, 166.0)
				},
				{
					"center": Vector3(22.5000, 1.7000, -62.0),
					"size": Vector3(0.8000, 3.4000, 166.0)
				},
				{
					"center": Vector3(0.0, 1.7000, -151.0),
					"size": Vector3(45.0, 3.4000, 0.8000)
				},
				{
					"center": Vector3(4.0, 1.5500, -129.0),
					"size": Vector3(17.0, 3.1000, 0.7500)
				},
				{
					"center": Vector3(16.0, 1.5500, -139.0),
					"size": Vector3(0.7500, 3.1000, 17.0)
				}
			],
			"channels": [
				{
					"from": Vector3(-10.0, 1.5800, -102.0),
					"to": Vector3(14.0, 1.5800, -126.0)
				},
				{
					"from": Vector3(14.0, 1.5800, -126.0),
					"to": Vector3(0.0, 1.5800, -144.0)
				}
			],
			"appointments": [
				{
					"center": Vector3(-10.0, 1.5800, -2.0),
					"variant": "ring"
				},
				{
					"center": Vector3(-10.0, 1.5800, -20.0),
					"variant": "bridge"
				},
				{
					"center": Vector3(-10.0, 1.5800, -39.0),
					"variant": "chevron"
				},
				{
					"center": Vector3(-10.0, 1.5800, -59.0),
					"variant": "ring"
				},
				{
					"center": Vector3(-10.0, 1.5800, -80.0),
					"variant": "bridge"
				},
				{
					"center": Vector3(-10.0, 1.5800, -102.0),
					"variant": "chevron"
				}
			],
			"reflectors": [
				{
					"center": Vector3(14.0, 1.5800, 8.0),
					"from": Vector3(0.0, 1.5800, 18.0),
					"to": Vector3(-10.0, 1.5800, -2.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.8000
				},
				{
					"center": Vector3(14.0, 1.5800, -11.0),
					"from": Vector3(-10.0, 1.5800, -2.0),
					"to": Vector3(-10.0, 1.5800, -20.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.8000
				},
				{
					"center": Vector3(14.0, 1.5800, -31.0),
					"from": Vector3(-10.0, 1.5800, -20.0),
					"to": Vector3(-10.0, 1.5800, -39.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.8000
				},
				{
					"center": Vector3(14.0, 1.5800, -52.0),
					"from": Vector3(-10.0, 1.5800, -39.0),
					"to": Vector3(-10.0, 1.5800, -59.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.8000
				},
				{
					"center": Vector3(14.0, 1.5800, -74.0),
					"from": Vector3(-10.0, 1.5800, -59.0),
					"to": Vector3(-10.0, 1.5800, -80.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.8000
				},
				{
					"center": Vector3(14.0, 1.5800, -97.0),
					"from": Vector3(-10.0, 1.5800, -80.0),
					"to": Vector3(-10.0, 1.5800, -102.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.8000
				},
				{
					"center": Vector3(14.0, 1.5800, -126.0),
					"from": Vector3(-10.0, 1.5800, -102.0),
					"to": Vector3(0.0, 1.5800, -144.0),
					"label": "main",
					"width": 5.8000,
					"height": 4.8000
				}
			],
			"fog_near": 32.0,
			"fog_far": 142.0
		},
		{
			"title": "Lab: Lost City Expanse",
			"objective": "Start at the dead city center, explore too many broken mirror routes, and find the hidden receptacle somewhere beyond the ruins.",
			"spawn": Vector3(0.0, 0.0, 0.0),
			"source": Vector3(0.0, 1.5800, 0.0),
			"fire_zone_radius": 3.4000,
			"yaw": 3.1416,
			"target": Vector3(64.0, 1.5800, -326.0),
			"target_radius": 3.4000,
			"target_visual_radius": 1.1500,
			"pulse_speed": 13.0,
			"pulse_ttl": 24.0,
			"player_reflect_stability_ratio": 0.7000,
			"max_pulse_speed_multiplier": 3.0,
			"world_bounds_min": Vector3(-84.0, -2.0, -360.0),
			"world_bounds_max": Vector3(84.0, 22.0, 300.0),
			"platforms": [
				{
					"center": Vector3(0.0, -0.1500, -30.0),
					"size": Vector3(150.0, 0.3000, 660.0)
				},
				{
					"center": Vector3(0.0, 0.0600, 0.0),
					"size": Vector3(16.0, 0.3500, 16.0)
				},
				{
					"center": Vector3(0.0, 0.2400, -28.0),
					"size": Vector3(12.0, 0.3500, 10.0)
				},
				{
					"center": Vector3(32.0, 0.3800, -56.0),
					"size": Vector3(11.0, 0.3500, 10.0)
				},
				{
					"center": Vector3(-30.0, 0.3400, -86.0),
					"size": Vector3(11.0, 0.3500, 10.0)
				},
				{
					"center": Vector3(-42.0, 0.5200, -128.0),
					"size": Vector3(12.0, 0.3500, 11.0)
				},
				{
					"center": Vector3(18.0, 0.6200, -154.0),
					"size": Vector3(14.0, 0.3500, 12.0)
				},
				{
					"center": Vector3(-28.0, 0.4600, -196.0),
					"size": Vector3(14.0, 0.3500, 12.0)
				},
				{
					"center": Vector3(42.0, 0.7200, -232.0),
					"size": Vector3(12.0, 0.3500, 11.0)
				},
				{
					"center": Vector3(-34.0, 0.7400, -266.0),
					"size": Vector3(13.0, 0.3500, 12.0)
				},
				{
					"center": Vector3(10.0, 0.5800, -304.0),
					"size": Vector3(14.0, 0.3500, 12.0)
				},
				{
					"center": Vector3(64.0, 0.4200, -326.0),
					"size": Vector3(13.0, 0.3500, 13.0)
				},
				{
					"center": Vector3(-58.0, 0.3600, -38.0),
					"size": Vector3(9.0, 0.3500, 9.0)
				},
				{
					"center": Vector3(56.0, 0.4200, -94.0),
					"size": Vector3(10.0, 0.3500, 9.0)
				},
				{
					"center": Vector3(-62.0, 0.6800, -174.0),
					"size": Vector3(10.0, 0.3500, 10.0)
				},
				{
					"center": Vector3(62.0, 0.7000, -178.0),
					"size": Vector3(10.0, 0.3500, 10.0)
				},
				{
					"center": Vector3(-54.0, 0.6200, -238.0),
					"size": Vector3(9.0, 0.3500, 9.0)
				},
				{
					"center": Vector3(56.0, 0.8000, -278.0),
					"size": Vector3(10.0, 0.3500, 10.0)
				},
				{
					"center": Vector3(0.0, 0.8400, 82.0),
					"size": Vector3(13.0, 0.3500, 12.0)
				},
				{
					"center": Vector3(-40.0, 0.7200, 54.0),
					"size": Vector3(11.0, 0.3500, 10.0)
				},
				{
					"center": Vector3(44.0, 0.6400, 58.0),
					"size": Vector3(11.0, 0.3500, 10.0)
				},
				{
					"center": Vector3(-18.0, 0.9000, 132.0),
					"size": Vector3(12.0, 0.3500, 12.0)
				},
				{
					"center": Vector3(28.0, 1.0500, 154.0),
					"size": Vector3(12.0, 0.3500, 12.0)
				}
			],
			"absorbers": [
				{
					"center": Vector3(-76.0, 1.7000, -30.0),
					"size": Vector3(0.9000, 3.4000, 640.0)
				},
				{
					"center": Vector3(76.0, 1.7000, -30.0),
					"size": Vector3(0.9000, 3.4000, 640.0)
				},
				{
					"center": Vector3(0.0, 1.7000, -350.0),
					"size": Vector3(150.0, 3.4000, 0.9000)
				},
				{
					"center": Vector3(0.0, 1.7000, 292.0),
					"size": Vector3(150.0, 3.4000, 0.9000)
				},
				{
					"center": Vector3(-14.0, 1.8000, -118.0),
					"size": Vector3(9.0, 3.6000, 34.0)
				},
				{
					"center": Vector3(22.0, 1.8000, -202.0),
					"size": Vector3(10.0, 3.6000, 38.0)
				},
				{
					"center": Vector3(44.0, 1.8000, -296.0),
					"size": Vector3(8.0, 3.6000, 36.0)
				},
				{
					"center": Vector3(34.0, 1.8000, -318.0),
					"size": Vector3(28.0, 3.6000, 0.8000)
				},
				{
					"center": Vector3(70.0, 1.8000, -306.0),
					"size": Vector3(0.8000, 3.6000, 34.0)
				},
				{
					"center": Vector3(-22.0, 1.7000, 24.0),
					"size": Vector3(8.0, 3.4000, 28.0)
				},
				{
					"center": Vector3(24.0, 1.7000, 34.0),
					"size": Vector3(8.0, 3.4000, 28.0)
				}
			],
			"channels": [
				{
					"from": Vector3(0.0, 1.5800, 0.0),
					"to": Vector3(0.0, 1.5800, -28.0)
				},
				{
					"from": Vector3(18.0, 1.5800, -154.0),
					"to": Vector3(-28.0, 1.5800, -196.0)
				},
				{
					"from": Vector3(-28.0, 1.5800, -196.0),
					"to": Vector3(42.0, 1.5800, -232.0)
				},
				{
					"from": Vector3(10.0, 1.5800, -304.0),
					"to": Vector3(64.0, 1.5800, -326.0)
				},
				{
					"from": Vector3(0.0, 1.5800, 0.0),
					"to": Vector3(0.0, 1.5800, 82.0),
					"label": "optional"
				},
				{
					"from": Vector3(0.0, 1.5800, 0.0),
					"to": Vector3(-58.0, 1.5800, -38.0),
					"label": "optional"
				},
				{
					"from": Vector3(0.0, 1.5800, 0.0),
					"to": Vector3(56.0, 1.5800, -94.0),
					"label": "optional"
				},
				{
					"from": Vector3(56.0, 1.5800, -278.0),
					"to": Vector3(10.0, 1.5800, -304.0),
					"label": "optional"
				}
			],
			"appointments": [
				{
					"center": Vector3(18.0, 1.5800, -154.0),
					"variant": "ring"
				},
				{
					"center": Vector3(-28.0, 1.5800, -196.0),
					"variant": "chevron"
				},
				{
					"center": Vector3(10.0, 1.5800, -304.0),
					"variant": "bridge"
				},
				{
					"center": Vector3(0.0, 1.5800, 82.0),
					"variant": "ring",
					"label": "optional"
				},
				{
					"center": Vector3(56.0, 1.5800, -278.0),
					"variant": "chevron",
					"label": "optional"
				}
			],
			"reflectors": [
				{
					"center": Vector3(0.0, 1.5800, -28.0),
					"from": Vector3(0.0, 1.5800, 0.0),
					"to": Vector3(32.0, 1.5800, -56.0),
					"label": "main",
					"width": 6.2000,
					"height": 4.8000
				},
				{
					"center": Vector3(32.0, 1.5800, -56.0),
					"from": Vector3(0.0, 1.5800, -28.0),
					"to": Vector3(-30.0, 1.5800, -86.0),
					"label": "main",
					"width": 6.2000,
					"height": 4.8000
				},
				{
					"center": Vector3(-30.0, 1.5800, -86.0),
					"from": Vector3(32.0, 1.5800, -56.0),
					"to": Vector3(-42.0, 1.5800, -128.0),
					"label": "main",
					"width": 6.2000,
					"height": 4.8000
				},
				{
					"center": Vector3(-42.0, 1.5800, -128.0),
					"from": Vector3(-30.0, 1.5800, -86.0),
					"to": Vector3(18.0, 1.5800, -154.0),
					"label": "main",
					"width": 6.2000,
					"height": 4.8000
				},
				{
					"center": Vector3(-28.0, 1.5800, -196.0),
					"from": Vector3(18.0, 1.5800, -154.0),
					"to": Vector3(42.0, 1.5800, -232.0),
					"label": "main",
					"width": 6.4000,
					"height": 4.8000
				},
				{
					"center": Vector3(42.0, 1.5800, -232.0),
					"from": Vector3(-28.0, 1.5800, -196.0),
					"to": Vector3(-34.0, 1.5800, -266.0),
					"label": "main",
					"width": 6.4000,
					"height": 4.8000
				},
				{
					"center": Vector3(-34.0, 1.5800, -266.0),
					"from": Vector3(42.0, 1.5800, -232.0),
					"to": Vector3(10.0, 1.5800, -304.0),
					"label": "main",
					"width": 6.4000,
					"height": 4.8000
				},
				{
					"center": Vector3(10.0, 1.5800, -304.0),
					"from": Vector3(-34.0, 1.5800, -266.0),
					"to": Vector3(64.0, 1.5800, -326.0),
					"label": "main",
					"width": 6.4000,
					"height": 4.8000
				},
				{
					"center": Vector3(-58.0, 1.5800, -38.0),
					"from": Vector3(0.0, 1.5800, 0.0),
					"to": Vector3(-30.0, 1.5800, -86.0),
					"label": "optional",
					"width": 4.8000,
					"height": 4.2000
				},
				{
					"center": Vector3(56.0, 1.5800, -94.0),
					"from": Vector3(0.0, 1.5800, 0.0),
					"to": Vector3(-42.0, 1.5800, -128.0),
					"label": "optional",
					"width": 4.8000,
					"height": 4.2000
				},
				{
					"center": Vector3(-62.0, 1.5800, -174.0),
					"from": Vector3(-42.0, 1.5800, -128.0),
					"to": Vector3(-28.0, 1.5800, -196.0),
					"label": "optional",
					"width": 4.8000,
					"height": 4.2000
				},
				{
					"center": Vector3(62.0, 1.5800, -178.0),
					"from": Vector3(18.0, 1.5800, -154.0),
					"to": Vector3(-28.0, 1.5800, -196.0),
					"label": "optional",
					"width": 4.8000,
					"height": 4.2000
				},
				{
					"center": Vector3(-54.0, 1.5800, -238.0),
					"from": Vector3(-28.0, 1.5800, -196.0),
					"to": Vector3(-34.0, 1.5800, -266.0),
					"label": "optional",
					"width": 4.8000,
					"height": 4.2000
				},
				{
					"center": Vector3(56.0, 1.5800, -278.0),
					"from": Vector3(42.0, 1.5800, -232.0),
					"to": Vector3(10.0, 1.5800, -304.0),
					"label": "optional",
					"width": 4.8000,
					"height": 4.2000
				},
				{
					"center": Vector3(0.0, 1.5800, 82.0),
					"from": Vector3(0.0, 1.5800, 0.0),
					"to": Vector3(-40.0, 1.5800, 54.0),
					"label": "optional",
					"width": 5.4000,
					"height": 4.4000
				},
				{
					"center": Vector3(-40.0, 1.5800, 54.0),
					"from": Vector3(0.0, 1.5800, 82.0),
					"to": Vector3(44.0, 1.5800, 58.0),
					"label": "optional",
					"width": 5.4000,
					"height": 4.4000
				},
				{
					"center": Vector3(44.0, 1.5800, 58.0),
					"from": Vector3(-40.0, 1.5800, 54.0),
					"to": Vector3(-18.0, 1.5800, 132.0),
					"label": "optional",
					"width": 5.4000,
					"height": 4.4000
				},
				{
					"center": Vector3(-18.0, 1.5800, 132.0),
					"from": Vector3(44.0, 1.5800, 58.0),
					"to": Vector3(28.0, 1.5800, 154.0),
					"label": "optional",
					"width": 5.4000,
					"height": 4.4000
				},
				{
					"center": Vector3(28.0, 1.5800, 154.0),
					"from": Vector3(-18.0, 1.5800, 132.0),
					"to": Vector3(0.0, 1.5800, 0.0),
					"label": "optional",
					"width": 5.4000,
					"height": 4.4000
				},
				{
					"center": Vector3(-18.0, 1.5800, -54.0),
					"from": Vector3(0.0, 1.5800, -28.0),
					"to": Vector3(-58.0, 1.5800, -38.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(18.0, 1.5800, -70.0),
					"from": Vector3(32.0, 1.5800, -56.0),
					"to": Vector3(56.0, 1.5800, -94.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(-6.0, 1.5800, -112.0),
					"from": Vector3(-30.0, 1.5800, -86.0),
					"to": Vector3(56.0, 1.5800, -94.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(34.0, 1.5800, -122.0),
					"from": Vector3(56.0, 1.5800, -94.0),
					"to": Vector3(18.0, 1.5800, -154.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(-66.0, 1.5800, -118.0),
					"from": Vector3(-58.0, 1.5800, -38.0),
					"to": Vector3(-62.0, 1.5800, -174.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(66.0, 1.5800, -140.0),
					"from": Vector3(56.0, 1.5800, -94.0),
					"to": Vector3(62.0, 1.5800, -178.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(-4.0, 1.5800, -176.0),
					"from": Vector3(18.0, 1.5800, -154.0),
					"to": Vector3(-62.0, 1.5800, -174.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(4.0, 1.5800, -214.0),
					"from": Vector3(-28.0, 1.5800, -196.0),
					"to": Vector3(62.0, 1.5800, -178.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(-68.0, 1.5800, -210.0),
					"from": Vector3(-62.0, 1.5800, -174.0),
					"to": Vector3(-54.0, 1.5800, -238.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(68.0, 1.5800, -220.0),
					"from": Vector3(62.0, 1.5800, -178.0),
					"to": Vector3(56.0, 1.5800, -278.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(-10.0, 1.5800, -246.0),
					"from": Vector3(-54.0, 1.5800, -238.0),
					"to": Vector3(42.0, 1.5800, -232.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(18.0, 1.5800, -262.0),
					"from": Vector3(56.0, 1.5800, -278.0),
					"to": Vector3(-34.0, 1.5800, -266.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(-60.0, 1.5800, -304.0),
					"from": Vector3(-34.0, 1.5800, -266.0),
					"to": Vector3(10.0, 1.5800, -304.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(72.0, 1.5800, -300.0),
					"from": Vector3(56.0, 1.5800, -278.0),
					"to": Vector3(64.0, 1.5800, -326.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(-32.0, 1.5800, 8.0),
					"from": Vector3(0.0, 1.5800, 0.0),
					"to": Vector3(-40.0, 1.5800, 54.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(34.0, 1.5800, 6.0),
					"from": Vector3(0.0, 1.5800, 0.0),
					"to": Vector3(44.0, 1.5800, 58.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(-64.0, 1.5800, 92.0),
					"from": Vector3(-40.0, 1.5800, 54.0),
					"to": Vector3(-18.0, 1.5800, 132.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				},
				{
					"center": Vector3(62.0, 1.5800, 104.0),
					"from": Vector3(44.0, 1.5800, 58.0),
					"to": Vector3(28.0, 1.5800, 154.0),
					"label": "optional",
					"width": 4.4000,
					"height": 4.0
				}
			],
			"fog_near": 42.0,
			"fog_far": 230.0
		}
	]
