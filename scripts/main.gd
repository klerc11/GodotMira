extends Node2D

enum GameState { MENU, RUNNING, PAUSED, GAME_OVER }

const SFX_BUS_SCRIPT: Script = preload("res://scripts/sfx_bus.gd")
const CHASER_DRONE_SCRIPT: Script = preload("res://scripts/chaser_drone.gd")

const ARENA_SIZE: Vector2 = Vector2(960.0, 540.0)
const PLAY_BOUNDS: Rect2 = Rect2(Vector2(28.0, 72.0), Vector2(904.0, 404.0))
const ROUND_SECONDS: float = 60.0
const MAX_SPARKS: int = 9
const MAX_HAZARDS: int = 10
const MAX_DRONES: int = 7
const SPARKS_PER_UPGRADE: int = 6
const HIT_INVULNERABILITY: float = 0.9

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player: FieldPlayerShip
var sfx: Variant
var sparks: Array[FieldSpark] = []
var hazards: Array[FieldHazardRing] = []
var drones: Array = []

var score: int = 0
var combo: int = 1
var combo_timer: float = 0.0
var time_left: float = ROUND_SECONDS
var heat: float = 0.0
var heat_flash: float = 0.0
var shake_time: float = 0.0
var hazard_spawn_timer: float = 4.0
var drone_spawn_timer: float = 5.5
var collected_count: int = 0
var game_state: GameState = GameState.MENU

var max_health: int = 5
var health: int = 5
var invulnerability_time: float = 0.0
var upgrade_level: int = 0
var magnet_bonus: float = 0.0
var drone_slow_factor: float = 1.0

var score_label: Label
var timer_label: Label
var combo_label: Label
var status_label: Label
var health_label: Label
var upgrade_label: Label
var audio_label: Label
var dash_fill: ColorRect
var heat_fill: ColorRect
var health_fill: ColorRect
var overlay: Control
var overlay_title: Label
var overlay_body: Label


func _ready() -> void:
	rng.randomize()
	_configure_input()
	_build_world()
	_build_ui()
	reset_game(false)


func _process(delta: float) -> void:
	heat_flash = maxf(0.0, heat_flash - delta * 2.6)

	if Input.is_action_just_pressed("toggle_sound"):
		_toggle_sound()

	if game_state == GameState.MENU:
		if Input.is_action_just_pressed("start") or Input.is_action_just_pressed("restart"):
			reset_game(true)
		_update_screen_shake(delta)
		_update_ui()
		queue_redraw()
		return

	if game_state == GameState.PAUSED:
		if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("start"):
			_resume_game()
		elif Input.is_action_just_pressed("restart"):
			reset_game(true)
		_update_ui()
		queue_redraw()
		return

	if game_state == GameState.GAME_OVER:
		if Input.is_action_just_pressed("restart") or Input.is_action_just_pressed("start"):
			reset_game(true)
		_update_screen_shake(delta)
		_update_ui()
		queue_redraw()
		return

	if Input.is_action_just_pressed("pause"):
		_pause_game()
		queue_redraw()
		return

	_run_gameplay(delta)


func reset_game(start_running: bool = true) -> void:
	_clear_round_nodes()

	score = 0
	combo = 1
	combo_timer = 0.0
	time_left = ROUND_SECONDS
	heat = 0.0
	heat_flash = 0.0
	shake_time = 0.0
	hazard_spawn_timer = 4.0
	drone_spawn_timer = 5.5
	collected_count = 0
	max_health = 5
	health = max_health
	invulnerability_time = 0.0
	upgrade_level = 0
	magnet_bonus = 0.0
	drone_slow_factor = 1.0

	player.position = PLAY_BOUNDS.get_center()
	player.velocity = Vector2.ZERO
	player.facing = Vector2.RIGHT
	player.speed = 245.0
	player.dash_speed = 760.0
	player.dash_cooldown_duration = 0.82
	player.modulate = Color.WHITE
	player.clear_trail()

	for index in range(MAX_SPARKS):
		_spawn_spark()
	for index in range(4):
		_spawn_hazard()
	for index in range(2):
		_spawn_drone()

	if start_running:
		game_state = GameState.RUNNING
		_hide_overlay()
		status_label.text = "FIELD STABLE"
		sfx.play_start()
	else:
		game_state = GameState.MENU
		_show_overlay("FIELD RUNNER", "ENTER starts the run\nWASD or arrows move   SPACE dashes\nP or ESC pauses   M toggles sound")
		status_label.text = "READY"

	_update_ui()
	queue_redraw()


func _run_gameplay(delta: float) -> void:
	invulnerability_time = maxf(0.0, invulnerability_time - delta)

	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_just_pressed("dash") and player.can_dash():
		if input_vector.length_squared() > 0.001:
			player.facing = input_vector.normalized()
		player.start_dash()

	time_left = maxf(0.0, time_left - delta)
	heat = 1.0 - time_left / ROUND_SECONDS

	player.drive(input_vector, delta, PLAY_BOUNDS)
	player.modulate = _player_tint()

	_update_combo(delta)
	_magnetize_sparks(delta)
	_update_drones(delta)
	_check_spark_collection()
	_apply_hazard_pressure(delta)
	_check_drone_contacts()
	_update_hazard_spawns(delta)
	_update_drone_spawns(delta)

	if time_left <= 0.0:
		_end_game("TIME COMPLETE")

	_update_ui()
	_update_screen_shake(delta)
	queue_redraw()


func _clear_round_nodes() -> void:
	for spark in sparks:
		spark.queue_free()
	for hazard in hazards:
		hazard.queue_free()
	for drone in drones:
		drone.queue_free()
	for child in get_children():
		if child is FieldFloatingText:
			child.queue_free()

	sparks.clear()
	hazards.clear()
	drones.clear()


func _build_world() -> void:
	sfx = SFX_BUS_SCRIPT.new()
	add_child(sfx)

	player = FieldPlayerShip.new()
	player.z_index = 20
	add_child(player)


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)

	var root: Control = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	score_label = _make_label(Vector2(24.0, 18.0), Vector2(220.0, 34.0), 28, HORIZONTAL_ALIGNMENT_LEFT)
	root.add_child(score_label)

	timer_label = _make_label(Vector2(736.0, 18.0), Vector2(200.0, 34.0), 28, HORIZONTAL_ALIGNMENT_RIGHT)
	root.add_child(timer_label)

	combo_label = _make_label(Vector2(340.0, 18.0), Vector2(280.0, 30.0), 22, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(combo_label)

	var dash_back: ColorRect = _make_meter_back(Vector2(24.0, 58.0), Color(0.4, 0.58, 0.66, 0.22))
	root.add_child(dash_back)
	dash_fill = _make_meter_fill(Color(0.25, 0.83, 0.95, 0.92))
	dash_back.add_child(dash_fill)

	var health_back: ColorRect = _make_meter_back(Vector2(24.0, 76.0), Color(0.18, 0.55, 0.22, 0.22))
	root.add_child(health_back)
	health_fill = _make_meter_fill(Color(0.4, 0.95, 0.42, 0.9))
	health_back.add_child(health_fill)

	health_label = _make_label(Vector2(204.0, 65.0), Vector2(146.0, 28.0), 16, HORIZONTAL_ALIGNMENT_LEFT)
	root.add_child(health_label)

	var heat_back: ColorRect = _make_meter_back(Vector2(764.0, 58.0), Color(0.72, 0.19, 0.13, 0.18))
	root.add_child(heat_back)
	heat_fill = _make_meter_fill(Color(1.0, 0.28, 0.14, 0.86))
	heat_back.add_child(heat_fill)

	upgrade_label = _make_label(Vector2(330.0, 58.0), Vector2(300.0, 28.0), 16, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(upgrade_label)

	audio_label = _make_label(Vector2(760.0, 76.0), Vector2(176.0, 24.0), 15, HORIZONTAL_ALIGNMENT_RIGHT)
	root.add_child(audio_label)

	status_label = _make_label(Vector2(0.0, 492.0), Vector2(ARENA_SIZE.x, 30.0), 20, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(status_label)

	_build_overlay(root)


func _build_overlay(root: Control) -> void:
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)

	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.01, 0.016, 0.02, 0.66)
	overlay.add_child(dim)

	var panel: ColorRect = ColorRect.new()
	panel.position = Vector2(256.0, 156.0)
	panel.size = Vector2(448.0, 220.0)
	panel.color = Color(0.035, 0.07, 0.078, 0.94)
	overlay.add_child(panel)

	overlay_title = _make_label(Vector2(0.0, 32.0), Vector2(panel.size.x, 48.0), 34, HORIZONTAL_ALIGNMENT_CENTER)
	panel.add_child(overlay_title)

	overlay_body = _make_label(Vector2(34.0, 94.0), Vector2(panel.size.x - 68.0, 92.0), 18, HORIZONTAL_ALIGNMENT_CENTER)
	overlay_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(overlay_body)


func _make_label(pos: Vector2, label_size: Vector2, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label


func _make_meter_back(pos: Vector2, color: Color) -> ColorRect:
	var meter: ColorRect = ColorRect.new()
	meter.position = pos
	meter.size = Vector2(172.0, 7.0)
	meter.color = color
	return meter


func _make_meter_fill(color: Color) -> ColorRect:
	var fill: ColorRect = ColorRect.new()
	fill.position = Vector2.ZERO
	fill.size = Vector2(172.0, 7.0)
	fill.color = color
	return fill


func _configure_input() -> void:
	_bind_key("move_left", KEY_A)
	_bind_key("move_left", KEY_LEFT)
	_bind_key("move_right", KEY_D)
	_bind_key("move_right", KEY_RIGHT)
	_bind_key("move_up", KEY_W)
	_bind_key("move_up", KEY_UP)
	_bind_key("move_down", KEY_S)
	_bind_key("move_down", KEY_DOWN)
	_bind_key("dash", KEY_SPACE)
	_bind_key("restart", KEY_R)
	_bind_key("start", KEY_ENTER)
	_bind_key("start", KEY_KP_ENTER)
	_bind_key("pause", KEY_P)
	_bind_key("pause", KEY_ESCAPE)
	_bind_key("toggle_sound", KEY_M)


func _bind_key(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.physical_keycode == keycode:
			return

	var key_event: InputEventKey = InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, key_event)


func _pause_game() -> void:
	game_state = GameState.PAUSED
	_show_overlay("PAUSED", "ENTER or P resumes\nR restarts the run\nM toggles generated sound effects")
	status_label.text = "PAUSED"
	sfx.play_pause()


func _resume_game() -> void:
	game_state = GameState.RUNNING
	_hide_overlay()
	status_label.text = "FIELD STABLE"
	sfx.play_start()


func _toggle_sound() -> void:
	sfx.enabled = not sfx.enabled
	if sfx.enabled:
		sfx.play_start()
	_spawn_floating_text("SOUND " + ("ON" if sfx.enabled else "OFF"), PLAY_BOUNDS.position + Vector2(18.0, 48.0), Color(0.78, 0.95, 1.0, 1.0))
	_update_ui()


func _show_overlay(title: String, body: String) -> void:
	overlay.visible = true
	overlay_title.text = title
	overlay_body.text = body


func _hide_overlay() -> void:
	overlay.visible = false


func _update_combo(delta: float) -> void:
	combo_timer = maxf(0.0, combo_timer - delta)
	if combo_timer <= 0.0:
		combo = 1


func _magnetize_sparks(delta: float) -> void:
	if magnet_bonus <= 0.0:
		return

	var pull_range: float = 88.0 + magnet_bonus
	for spark in sparks:
		var offset: Vector2 = player.position - spark.position
		var distance: float = offset.length()
		if distance <= 1.0 or distance > pull_range:
			continue

		var pull_strength: float = (1.0 - distance / pull_range) * (92.0 + magnet_bonus * 1.15)
		spark.position += offset.normalized() * pull_strength * delta


func _update_drones(delta: float) -> void:
	for drone in drones:
		drone.update_ai(player.position, delta, PLAY_BOUNDS, heat, drone_slow_factor)


func _check_spark_collection() -> void:
	var collected_sparks: Array[FieldSpark] = []
	for spark in sparks:
		var collection_range: float = player.radius + spark.collection_radius() + magnet_bonus * 0.22
		if player.position.distance_to(spark.position) <= collection_range:
			collected_sparks.append(spark)

	for spark in collected_sparks:
		_collect_spark(spark)


func _collect_spark(spark: FieldSpark) -> void:
	var points: int = combo * spark.value
	score += points
	collected_count += 1
	combo = mini(combo + 1, 12)
	combo_timer = 2.35
	shake_time = maxf(shake_time, 0.045)

	_spawn_floating_text("+" + str(points), spark.position + Vector2(-12.0, -36.0), Color(1.0, 0.88, 0.28, 1.0))
	sfx.play_collect(combo)
	sparks.erase(spark)
	spark.queue_free()
	call_deferred("_spawn_spark")
	_maybe_grant_upgrade()

	if collected_count % 7 == 0 and hazards.size() < MAX_HAZARDS:
		call_deferred("_spawn_hazard")


func _maybe_grant_upgrade() -> void:
	var earned_level: int = floori(float(collected_count) / float(SPARKS_PER_UPGRADE))
	while upgrade_level < earned_level:
		upgrade_level += 1
		_apply_upgrade(upgrade_level)


func _apply_upgrade(level: int) -> void:
	var upgrade_name: String = ""
	var upgrade_index: int = (level - 1) % 4

	if upgrade_index == 0:
		upgrade_name = "ENGINE TUNE"
		player.speed += 20.0
		player.dash_cooldown_duration = maxf(0.48, player.dash_cooldown_duration - 0.055)
	elif upgrade_index == 1:
		upgrade_name = "MAGNET CORE"
		magnet_bonus += 28.0
	elif upgrade_index == 2:
		upgrade_name = "SHIELD PLATE"
		max_health += 1
		health = mini(max_health, health + 2)
	else:
		upgrade_name = "DRONE JAMMER"
		drone_slow_factor = maxf(0.66, drone_slow_factor - 0.07)

	_spawn_floating_text(upgrade_name, player.position + Vector2(-58.0, -48.0), Color(0.58, 0.96, 1.0, 1.0))
	status_label.text = upgrade_name
	sfx.play_upgrade()


func _apply_hazard_pressure(delta: float) -> void:
	for hazard in hazards:
		var offset: Vector2 = player.position - hazard.position
		var distance: float = maxf(offset.length(), 0.001)
		var overlap: float = player.radius + hazard.active_radius() - distance
		if overlap <= 0.0:
			continue

		var normal: Vector2 = offset / distance
		player.position += normal * (overlap + 60.0 * delta)
		player.velocity = player.velocity.bounce(normal) * 0.28
		player.position.x = clampf(player.position.x, PLAY_BOUNDS.position.x + player.radius, PLAY_BOUNDS.end.x - player.radius)
		player.position.y = clampf(player.position.y, PLAY_BOUNDS.position.y + player.radius, PLAY_BOUNDS.end.y - player.radius)

		time_left = maxf(0.0, time_left - delta * 3.5)
		_damage_player(1, hazard.position, "FIELD SURGE")


func _check_drone_contacts() -> void:
	for drone in drones:
		var distance: float = player.position.distance_to(drone.position)
		if distance > player.radius + drone.radius:
			continue

		_damage_player(1, drone.position, "DRONE HIT")
		drone.knock_back(player.position)


func _damage_player(amount: int, source_position: Vector2, reason: String) -> void:
	if invulnerability_time > 0.0 or game_state != GameState.RUNNING:
		return

	health = maxi(0, health - amount)
	invulnerability_time = HIT_INVULNERABILITY
	combo = 1
	combo_timer = 0.0
	heat_flash = 0.72
	shake_time = maxf(shake_time, 0.18)
	status_label.text = reason
	sfx.play_hit()

	var knockback: Vector2 = player.position - source_position
	if knockback.length_squared() < 0.001:
		knockback = Vector2.RIGHT
	player.velocity += knockback.normalized() * 260.0
	_spawn_floating_text("-" + str(amount), player.position + Vector2(-10.0, -42.0), Color(1.0, 0.32, 0.22, 1.0))

	if health <= 0:
		_end_game("SHIP LOST")


func _update_hazard_spawns(delta: float) -> void:
	hazard_spawn_timer -= delta
	var next_delay: float = lerpf(7.0, 3.2, heat)

	if hazard_spawn_timer <= 0.0 and hazards.size() < MAX_HAZARDS:
		_spawn_hazard()
		hazard_spawn_timer = next_delay


func _update_drone_spawns(delta: float) -> void:
	drone_spawn_timer -= delta
	var next_delay: float = lerpf(8.0, 4.0, heat)

	if drone_spawn_timer <= 0.0 and drones.size() < MAX_DRONES:
		_spawn_drone()
		drone_spawn_timer = next_delay


func _spawn_spark() -> void:
	var spark: FieldSpark = FieldSpark.new()
	spark.setup(rng.randf_range(0.0, TAU), 1)
	spark.position = _find_open_point(38.0, 44.0)
	spark.z_index = 8
	add_child(spark)
	sparks.append(spark)


func _spawn_hazard() -> void:
	var hazard: FieldHazardRing = FieldHazardRing.new()
	var size: float = rng.randf_range(28.0, 46.0) + heat * 10.0
	hazard.setup(size, rng.randf_range(0.0, TAU), rng.randf_range(-1.3, 1.3))
	hazard.position = _find_open_point(size + 34.0, size + 58.0)
	hazard.z_index = 4
	add_child(hazard)
	hazards.append(hazard)


func _spawn_drone() -> void:
	var drone: Variant = CHASER_DRONE_SCRIPT.new()
	var speed_scale: float = rng.randf_range(0.9, 1.16) + heat * 0.16
	drone.setup(rng.randf_range(0.0, TAU), speed_scale)
	drone.position = _find_open_point(46.0, 92.0)
	drone.z_index = 12
	add_child(drone)
	drones.append(drone)


func _find_open_point(edge_margin: float, clearance: float) -> Vector2:
	for attempt in range(80):
		var point: Vector2 = Vector2(
			rng.randf_range(PLAY_BOUNDS.position.x + edge_margin, PLAY_BOUNDS.end.x - edge_margin),
			rng.randf_range(PLAY_BOUNDS.position.y + edge_margin, PLAY_BOUNDS.end.y - edge_margin)
		)
		if _is_point_clear(point, clearance):
			return point

	return PLAY_BOUNDS.get_center()


func _is_point_clear(point: Vector2, clearance: float) -> bool:
	if player != null and point.distance_to(player.position) < clearance + 76.0:
		return false

	for spark in sparks:
		if point.distance_to(spark.position) < clearance + 36.0:
			return false

	for hazard in hazards:
		if point.distance_to(hazard.position) < clearance + hazard.active_radius():
			return false

	for drone in drones:
		if point.distance_to(drone.position) < clearance + 52.0:
			return false

	return true


func _spawn_floating_text(message: String, start_position: Vector2, tint: Color) -> void:
	var pop: FieldFloatingText = FieldFloatingText.new()
	pop.setup(message, start_position, tint)
	add_child(pop)


func _end_game(reason: String) -> void:
	if game_state == GameState.GAME_OVER:
		return

	game_state = GameState.GAME_OVER
	time_left = maxf(0.0, time_left)
	status_label.text = reason
	player.modulate = Color.WHITE
	_show_overlay(reason, "SCORE " + str(score) + "   SPARKS " + str(collected_count) + "\nENTER or R starts another run\nM toggles generated sound")
	_spawn_floating_text("SCORE " + str(score), PLAY_BOUNDS.get_center() + Vector2(-52.0, -28.0), Color(0.9, 0.96, 1.0, 1.0))
	sfx.play_game_over()


func _update_ui() -> void:
	score_label.text = "SCORE " + str(score).pad_zeros(3)
	timer_label.text = _format_timer(time_left)
	combo_label.text = "CHAIN x" + str(combo) if combo > 1 else ""
	health_label.text = "HULL " + str(health) + "/" + str(max_health)
	upgrade_label.text = "UPGRADE L" + str(upgrade_level) + "   MAG " + str(roundi(magnet_bonus))
	audio_label.text = "SOUND " + ("ON" if sfx.enabled else "OFF")

	dash_fill.size = Vector2(172.0 * player.dash_charge(), 7.0)
	heat_fill.size = Vector2(172.0 * heat, 7.0)
	health_fill.size = Vector2(172.0 * float(health) / float(max_health), 7.0)

	if game_state != GameState.RUNNING:
		return

	if invulnerability_time > 0.0:
		status_label.text = "RECOVERING"
	elif combo > 1:
		status_label.text = "CHAIN WINDOW"
	elif heat > 0.72:
		status_label.text = "FIELD UNSTABLE"
	elif heat_flash <= 0.0:
		status_label.text = "FIELD STABLE"


func _player_tint() -> Color:
	if invulnerability_time <= 0.0:
		return Color.WHITE

	var blink: float = 0.55 + sin(invulnerability_time * 34.0) * 0.25
	return Color(1.0, blink, blink, 1.0)


func _format_timer(seconds: float) -> String:
	var whole: int = int(floor(seconds))
	var tenths: int = int(floor((seconds - whole) * 10.0))
	return "%02d.%01d" % [whole, tenths]


func _update_screen_shake(delta: float) -> void:
	if shake_time > 0.0:
		shake_time = maxf(0.0, shake_time - delta)
		var amount: float = 6.0 * shake_time / 0.18
		position = Vector2(rng.randf_range(-amount, amount), rng.randf_range(-amount, amount))
	else:
		position = Vector2.ZERO


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, ARENA_SIZE), Color(0.035, 0.055, 0.068, 1.0))
	draw_rect(PLAY_BOUNDS, Color(0.045, 0.083, 0.092, 1.0))

	var grid_color: Color = Color(0.33, 0.75, 0.86, 0.105)
	for x in range(int(PLAY_BOUNDS.position.x), int(PLAY_BOUNDS.end.x) + 1, 48):
		draw_line(Vector2(x, PLAY_BOUNDS.position.y), Vector2(x, PLAY_BOUNDS.end.y), grid_color, 1.0)
	for y in range(int(PLAY_BOUNDS.position.y), int(PLAY_BOUNDS.end.y) + 1, 48):
		draw_line(Vector2(PLAY_BOUNDS.position.x, y), Vector2(PLAY_BOUNDS.end.x, y), grid_color, 1.0)

	draw_rect(PLAY_BOUNDS, Color(0.32, 0.78, 0.9, 0.55), false, 2.0)
	draw_rect(PLAY_BOUNDS, Color(1.0, 0.16, 0.07, heat * 0.08 + heat_flash * 0.14))

	var corner_color: Color = Color(1.0, 0.88, 0.28, 0.85)
	var corner_length: float = 22.0
	var corners: Array[Vector2] = [
		PLAY_BOUNDS.position,
		Vector2(PLAY_BOUNDS.end.x, PLAY_BOUNDS.position.y),
		PLAY_BOUNDS.end,
		Vector2(PLAY_BOUNDS.position.x, PLAY_BOUNDS.end.y),
	]
	for corner in corners:
		var x_dir: float = 1.0 if corner.x == PLAY_BOUNDS.position.x else -1.0
		var y_dir: float = 1.0 if corner.y == PLAY_BOUNDS.position.y else -1.0
		draw_line(corner, corner + Vector2(corner_length * x_dir, 0.0), corner_color, 3.0)
		draw_line(corner, corner + Vector2(0.0, corner_length * y_dir), corner_color, 3.0)
