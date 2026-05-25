class_name MiraGameRoot
extends Node

enum GameState { TITLE, RUNNING, COMPLETE }

@onready var world_root: Node3D = $World
@onready var level = $World/GoldenRouteLevel
@onready var player = $World/MiraPlayer
@onready var pulse_controller = $World/PulseController
@onready var audio_bus = $World/MiraAudio

var game_state: GameState = GameState.TITLE
var run_time: float = 0.0
var reset_count: int = 0
var prompt_text: String = ""

var timer_label: Label
var reset_label: Label
var stability_label: Label
var speed_label: Label
var prompt_label: Label
var title_overlay: Control
var title_body: Label


func _ready() -> void:
	_configure_input()
	_build_ui()
	player.set_audio_bus(audio_bus)
	pulse_controller.configure(level, player, audio_bus)
	pulse_controller.pulse_failed.connect(_on_pulse_failed)
	pulse_controller.pulse_completed.connect(_on_pulse_completed)
	pulse_controller.prompt_changed.connect(_on_prompt_changed)

	var reset_zone = level.get_reset_zone()
	if reset_zone != null:
		reset_zone.body_entered.connect(_on_reset_zone_entered)

	_reset_attempt()
	_show_title(false)


func _process(_delta: float) -> void:
	if game_state == GameState.TITLE:
		if _pressed_start():
			_start_run()
	elif game_state == GameState.COMPLETE:
		if _pressed_start():
			_start_run()

	_update_ui()


func _physics_process(delta: float) -> void:
	if game_state == GameState.RUNNING:
		run_time += delta
		var in_start_zone: bool = level.get_start_zone().contains_point(player.global_position)
		pulse_controller.tick(delta, in_start_zone)
		player.physics_step(delta)

	if Input.is_action_just_pressed("restart") and game_state == GameState.RUNNING:
		_manual_reset()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif game_state == GameState.RUNNING:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	if event is InputEventMouseButton and event.pressed and game_state == GameState.RUNNING and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	if game_state == GameState.RUNNING and Input.is_action_just_pressed("launch_reflect"):
		var in_start_zone: bool = level.get_start_zone().contains_point(player.global_position)
		pulse_controller.request_action(in_start_zone)


func _start_run() -> void:
	game_state = GameState.RUNNING
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.set_input_active(true)
	_reset_attempt()
	title_overlay.visible = false


func _manual_reset() -> void:
	reset_count += 1
	_reset_attempt()


func _reset_attempt() -> void:
	run_time = 0.0
	player.reset_to_transform(level.get_spawn_transform())
	pulse_controller.reset_to_idle()
	prompt_text = ""
	_on_prompt_changed("LMB / X TO LAUNCH")


func _show_title(completed: bool) -> void:
	game_state = GameState.COMPLETE if completed else GameState.TITLE
	player.set_input_active(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	title_overlay.visible = true
	title_body.text = "Become the missing mirror.\n\nLMB / X starts Golden Route.\nWASD + Mouse or Controller move and aim.\nShift dash. C / Alt or B slide. Space / A jump.\nR resets the attempt." if not completed else "Route complete.\n\nTime %s   Resets %d\n\nPress LMB / X to run it again." % [_format_time(run_time), reset_count]


func _on_pulse_failed() -> void:
	if game_state != GameState.RUNNING:
		return
	reset_count += 1
	_reset_attempt()


func _on_pulse_completed() -> void:
	if game_state != GameState.RUNNING:
		return
	_show_title(true)


func _on_prompt_changed(next_prompt: String) -> void:
	prompt_text = next_prompt


func _on_reset_zone_entered(body: Node) -> void:
	if body == player and game_state == GameState.RUNNING:
		reset_count += 1
		_reset_attempt()


func _pressed_start() -> bool:
	return Input.is_action_just_pressed("launch_reflect") or Input.is_action_just_pressed("start_game") or Input.is_action_just_pressed("jump")


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)

	var root: Control = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	timer_label = _make_label(Vector2(24.0, 18.0), Vector2(180.0, 32.0), 26, HORIZONTAL_ALIGNMENT_LEFT)
	root.add_child(timer_label)

	reset_label = _make_label(Vector2(220.0, 18.0), Vector2(180.0, 32.0), 22, HORIZONTAL_ALIGNMENT_LEFT)
	root.add_child(reset_label)

	stability_label = _make_label(Vector2(760.0, 18.0), Vector2(176.0, 28.0), 19, HORIZONTAL_ALIGNMENT_RIGHT)
	root.add_child(stability_label)

	speed_label = _make_label(Vector2(760.0, 44.0), Vector2(176.0, 28.0), 19, HORIZONTAL_ALIGNMENT_RIGHT)
	root.add_child(speed_label)

	prompt_label = _make_label(Vector2(0.0, 490.0), Vector2(960.0, 30.0), 18, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(prompt_label)

	title_overlay = Control.new()
	title_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(title_overlay)

	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.03, 0.04, 0.82)
	title_overlay.add_child(dim)

	var panel: ColorRect = ColorRect.new()
	panel.position = Vector2(208.0, 122.0)
	panel.size = Vector2(544.0, 272.0)
	panel.color = Color(0.07, 0.1, 0.12, 0.92)
	title_overlay.add_child(panel)

	var title_label: Label = _make_label(Vector2(0.0, 26.0), Vector2(panel.size.x, 44.0), 34, HORIZONTAL_ALIGNMENT_CENTER)
	title_label.text = "MIRA"
	panel.add_child(title_label)

	title_body = _make_label(Vector2(36.0, 92.0), Vector2(panel.size.x - 72.0, 136.0), 18, HORIZONTAL_ALIGNMENT_CENTER)
	title_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(title_body)


func _make_label(pos: Vector2, label_size: Vector2, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.93, 0.98, 1.0, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label


func _configure_input() -> void:
	_bind_key("move_left", KEY_A)
	_bind_key("move_left", KEY_LEFT)
	_bind_key("move_right", KEY_D)
	_bind_key("move_right", KEY_RIGHT)
	_bind_key("move_up", KEY_W)
	_bind_key("move_up", KEY_UP)
	_bind_key("move_down", KEY_S)
	_bind_key("move_down", KEY_DOWN)
	_bind_key("jump", KEY_SPACE)
	_bind_key("dash", KEY_SHIFT)
	_bind_key("slide", KEY_C)
	_bind_key("slide", KEY_ALT)
	_bind_key("restart", KEY_R)
	_bind_key("start_game", KEY_ENTER)
	_bind_key("start_game", KEY_KP_ENTER)
	_bind_mouse("launch_reflect", MOUSE_BUTTON_LEFT)
	_bind_joy_button("jump", JOY_BUTTON_A)
	_bind_joy_button("dash", JOY_BUTTON_RIGHT_SHOULDER)
	_bind_joy_button("slide", JOY_BUTTON_B)
	_bind_joy_button("launch_reflect", JOY_BUTTON_X)
	_bind_joy_button("restart", JOY_BUTTON_Y)
	_bind_joy_button("start_game", JOY_BUTTON_START)
	_bind_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_bind_joy_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	_bind_joy_axis("move_up", JOY_AXIS_LEFT_Y, -1.0)
	_bind_joy_axis("move_down", JOY_AXIS_LEFT_Y, 1.0)
	_bind_joy_axis("look_left", JOY_AXIS_RIGHT_X, -1.0)
	_bind_joy_axis("look_right", JOY_AXIS_RIGHT_X, 1.0)
	_bind_joy_axis("look_up", JOY_AXIS_RIGHT_Y, -1.0)
	_bind_joy_axis("look_down", JOY_AXIS_RIGHT_Y, 1.0)


func _bind_key(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.physical_keycode == keycode:
			return
	var key_event: InputEventKey = InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, key_event)


func _bind_mouse(action_name: String, button: MouseButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event in InputMap.action_get_events(action_name):
		if event is InputEventMouseButton and event.button_index == button:
			return
	var mouse_event: InputEventMouseButton = InputEventMouseButton.new()
	mouse_event.button_index = button
	InputMap.action_add_event(action_name, mouse_event)


func _bind_joy_button(action_name: String, button: JoyButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadButton and event.button_index == button:
			return
	var joy_event: InputEventJoypadButton = InputEventJoypadButton.new()
	joy_event.button_index = button
	InputMap.action_add_event(action_name, joy_event)


func _bind_joy_axis(action_name: String, axis: JoyAxis, axis_value: float) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event in InputMap.action_get_events(action_name):
		if event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, axis_value):
			return
	var joy_event: InputEventJoypadMotion = InputEventJoypadMotion.new()
	joy_event.axis = axis
	joy_event.axis_value = axis_value
	InputMap.action_add_event(action_name, joy_event)


func _update_ui() -> void:
	timer_label.text = _format_time(run_time)
	reset_label.text = "RESETS %d" % reset_count
	stability_label.text = "STABILITY %.1f" % pulse_controller.stability
	speed_label.text = "SPEED x%.2f" % (pulse_controller.pulse_speed / maxf(0.001, pulse_controller.base_speed))
	prompt_label.text = prompt_text


func _format_time(seconds: float) -> String:
	var whole: int = int(floor(seconds))
	var tenths: int = int(floor((seconds - whole) * 10.0))
	return "%02d.%01d" % [whole, tenths]
