class_name FieldSfxBus
extends Node

const MIX_RATE: int = 22050

var enabled: bool = true


func play_collect(combo: int) -> void:
	var pitch: float = 610.0 + float(mini(combo, 12)) * 24.0
	_play_tone(pitch, 0.075, 0.18, 0)


func play_hit() -> void:
	_play_tone(150.0, 0.16, 0.24, 2)


func play_upgrade() -> void:
	_play_tone(470.0, 0.12, 0.17, 1)
	_play_tone(720.0, 0.18, 0.14, 0)


func play_start() -> void:
	_play_tone(340.0, 0.10, 0.14, 0)
	_play_tone(510.0, 0.14, 0.12, 0)


func play_pause() -> void:
	_play_tone(260.0, 0.10, 0.12, 1)


func play_game_over() -> void:
	_play_tone(260.0, 0.18, 0.16, 2)
	_play_tone(170.0, 0.24, 0.13, 2)


func _play_tone(frequency: float, duration: float, volume: float, shape: int) -> void:
	if not enabled:
		return

	var stream: AudioStreamWAV = _make_tone(frequency, duration, shape)
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = linear_to_db(volume)
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()

	var cleanup_timer: SceneTreeTimer = get_tree().create_timer(duration + 0.16)
	cleanup_timer.timeout.connect(Callable(player, "queue_free"))


func _make_tone(frequency: float, duration: float, shape: int) -> AudioStreamWAV:
	var frame_count: int = maxi(1, int(duration * float(MIX_RATE)))
	var data: PackedByteArray = PackedByteArray()
	data.resize(frame_count * 2)

	for frame_index in range(frame_count):
		var t: float = float(frame_index) / float(MIX_RATE)
		var progress: float = float(frame_index) / float(frame_count)
		var envelope: float = sin(progress * PI)
		var wave: float = _sample_wave(frequency, t, shape)
		var sample: int = int(clampf(wave * envelope, -1.0, 1.0) * 32767.0)

		if sample < 0:
			sample += 65536

		data[frame_index * 2] = sample & 255
		data[frame_index * 2 + 1] = (sample >> 8) & 255

	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream


func _sample_wave(frequency: float, t: float, shape: int) -> float:
	var sine: float = sin(TAU * frequency * t)
	if shape == 1:
		return (sine + sin(TAU * frequency * 2.0 * t) * 0.35) * 0.7
	if shape == 2:
		return sin(TAU * frequency * t) * 0.75 + sin(TAU * frequency * 0.5 * t) * 0.25
	return sine
