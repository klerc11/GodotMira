class_name MiraAudio
extends Node

var _cached_streams: Dictionary = {}


func create_pulse_hum_player() -> AudioStreamPlayer3D:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.stream = _get_stream("hum")
	player.max_distance = 64.0
	player.unit_size = 2.2
	player.volume_db = -18.0
	player.attenuation_filter_cutoff_hz = 7800.0
	return player


func play_mirror_ping(position: Vector3) -> void:
	_play_one_shot_3d(_get_stream("mirror_ping"), position, -6.5)


func play_reflect_snap(position: Vector3) -> void:
	_play_one_shot_3d(_get_stream("reflect_snap"), position, -7.0)


func play_fail_drop(position: Vector3) -> void:
	_play_one_shot_3d(_get_stream("fail_drop"), position, -4.0)


func play_launch(position: Vector3) -> void:
	_play_one_shot_3d(_get_stream("launch"), position, -9.0)


func play_complete(position: Vector3) -> void:
	_play_one_shot_3d(_get_stream("complete"), position, -6.0)


func release_cached_streams() -> void:
	_cached_streams.clear()


func _play_one_shot_3d(stream: AudioStreamWAV, position: Vector3, volume_db: float) -> void:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.stream = stream
	player.global_position = position
	player.volume_db = volume_db
	player.max_distance = 56.0
	player.unit_size = 2.0
	add_child(player)
	player.play()
	var cleanup_timer: SceneTreeTimer = get_tree().create_timer(maxf(0.1, stream.get_length() + 0.1))
	cleanup_timer.timeout.connect(func() -> void:
		if is_instance_valid(player):
			player.queue_free()
	)


func _get_stream(key: String) -> AudioStreamWAV:
	if _cached_streams.has(key):
		return _cached_streams[key] as AudioStreamWAV

	var stream: AudioStreamWAV
	match key:
		"hum":
			stream = _build_hum_stream()
		"mirror_ping":
			stream = _build_bell_ping_stream(640.0, 0.18, 0.26)
		"reflect_snap":
			stream = _build_reflect_snap_stream()
		"fail_drop":
			stream = _build_fail_drop_stream()
		"launch":
			stream = _build_launch_stream()
		"complete":
			stream = _build_complete_stream()
		_:
			stream = _build_tone_stream(220.0, 0.15, 0.2, "sine")

	_cached_streams[key] = stream
	return stream


func _build_tone_stream(freq_hz: float, duration: float, amplitude: float, wave: String) -> AudioStreamWAV:
	return _build_sweep_stream(freq_hz, freq_hz, duration, amplitude, wave)


func _build_hum_stream() -> AudioStreamWAV:
	var sample_rate: int = 44100
	var duration: float = 2.4
	var sample_count: int = int(duration * float(sample_rate))
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)

	for sample_index in range(sample_count):
		var t: float = float(sample_index) / float(sample_rate)
		var progress: float = float(sample_index) / float(sample_count - 1)
		var wobble: float = sin(TAU * 0.35 * t) * 1.8
		var base: float = _sine_hz(108.0 + wobble, t)
		var second: float = _sine_hz(216.0 + wobble * 0.8, t) * 0.26
		var third: float = _sine_hz(324.0 + wobble * 0.6, t) * 0.11
		var breath: float = 0.86 + 0.14 * sin(TAU * 0.26 * t)
		var edge_fade: float = _edge_fade(progress, 0.08)
		var value: float = (base + second + third) * 0.2 * breath * edge_fade
		_write_pcm_sample(bytes, sample_index, value)

	var stream: AudioStreamWAV = _wav_from_pcm(bytes, sample_rate)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = int(0.10 * float(sample_rate))
	stream.loop_end = int((duration - 0.10) * float(sample_rate))
	return stream


func _build_bell_ping_stream(base_hz: float, duration: float, amplitude: float) -> AudioStreamWAV:
	var sample_rate: int = 44100
	var sample_count: int = int(duration * float(sample_rate))
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)

	for sample_index in range(sample_count):
		var t: float = float(sample_index) / float(sample_rate)
		var progress: float = float(sample_index) / float(sample_count - 1)
		var body: float = _sine_hz(base_hz, t)
		var harmonic: float = _sine_hz(base_hz * 2.02, t) * 0.35
		var shimmer: float = _sine_hz(base_hz * 3.75, t) * 0.17
		var decay: float = exp(-8.5 * progress)
		var transient: float = exp(-120.0 * progress) * 0.45
		var value: float = (body + harmonic + shimmer) * amplitude * decay + transient * amplitude * 0.3
		_write_pcm_sample(bytes, sample_index, value)

	return _wav_from_pcm(bytes, sample_rate)


func _build_reflect_snap_stream() -> AudioStreamWAV:
	var sample_rate: int = 44100
	var duration: float = 0.17
	var sample_count: int = int(duration * float(sample_rate))
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 94631

	for sample_index in range(sample_count):
		var t: float = float(sample_index) / float(sample_rate)
		var progress: float = float(sample_index) / float(sample_count - 1)
		var chirp_hz: float = lerpf(360.0, 1120.0, pow(progress, 0.78))
		var chirp: float = _sine_hz(chirp_hz, t)
		var ring: float = _sine_hz(chirp_hz * 1.92, t) * 0.28
		var click_noise: float = (rng.randf() * 2.0 - 1.0) * exp(-52.0 * progress) * 0.38
		var env: float = exp(-12.0 * progress)
		var value: float = (chirp + ring) * 0.22 * env + click_noise
		_write_pcm_sample(bytes, sample_index, value)

	return _wav_from_pcm(bytes, sample_rate)


func _build_launch_stream() -> AudioStreamWAV:
	var sample_rate: int = 44100
	var duration: float = 0.2
	var sample_count: int = int(duration * float(sample_rate))
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)

	for sample_index in range(sample_count):
		var t: float = float(sample_index) / float(sample_rate)
		var progress: float = float(sample_index) / float(sample_count - 1)
		var sweep_hz: float = lerpf(170.0, 430.0, pow(progress, 0.92))
		var body: float = _sine_hz(sweep_hz, t)
		var support: float = _sine_hz(sweep_hz * 0.5, t) * 0.32
		var air: float = _sine_hz(sweep_hz * 2.4, t) * 0.2
		var env: float = sin(minf(PI, progress * PI))
		var tail: float = exp(-3.0 * progress)
		var value: float = (body + support + air) * 0.24 * env * tail
		_write_pcm_sample(bytes, sample_index, value)

	return _wav_from_pcm(bytes, sample_rate)


func _build_fail_drop_stream() -> AudioStreamWAV:
	var sample_rate: int = 44100
	var duration: float = 0.34
	var sample_count: int = int(duration * float(sample_rate))
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 24719

	for sample_index in range(sample_count):
		var t: float = float(sample_index) / float(sample_rate)
		var progress: float = float(sample_index) / float(sample_count - 1)
		var hz: float = lerpf(180.0, 58.0, pow(progress, 0.74))
		var body: float = _sine_hz(hz, t)
		var saw_hint: float = _sine_hz(hz * 0.5, t) * 0.36 + _sine_hz(hz * 1.5, t) * 0.18
		var grit: float = (rng.randf() * 2.0 - 1.0) * exp(-7.0 * progress) * 0.24
		var env: float = exp(-4.8 * progress)
		var value: float = (body + saw_hint) * 0.24 * env + grit
		_write_pcm_sample(bytes, sample_index, value)

	return _wav_from_pcm(bytes, sample_rate)


func _build_complete_stream() -> AudioStreamWAV:
	var sample_rate: int = 44100
	var duration: float = 0.42
	var sample_count: int = int(duration * float(sample_rate))
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)

	for sample_index in range(sample_count):
		var t: float = float(sample_index) / float(sample_rate)
		var progress: float = float(sample_index) / float(sample_count - 1)
		var note_hz: float = 420.0
		if progress > 0.34:
			note_hz = 560.0
		if progress > 0.67:
			note_hz = 750.0
		var tone: float = _sine_hz(note_hz, t)
		var octave: float = _sine_hz(note_hz * 2.0, t) * 0.24
		var chime: float = _sine_hz(note_hz * 3.01, t) * 0.15
		var env: float = sin(minf(PI, progress * PI))
		var value: float = (tone + octave + chime) * 0.24 * env
		_write_pcm_sample(bytes, sample_index, value)

	return _wav_from_pcm(bytes, sample_rate)


func _build_sweep_stream(start_hz: float, end_hz: float, duration: float, amplitude: float, wave: String) -> AudioStreamWAV:
	var sample_rate: int = 44100
	var sample_count: int = int(maxf(1.0, duration) * float(sample_rate))
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)

	var phase: float = 0.0
	for sample_index in range(sample_count):
		var t: float = float(sample_index) / float(sample_count - 1)
		var freq: float = lerpf(start_hz, end_hz, t)
		var phase_step: float = TAU * freq / float(sample_rate)
		phase += phase_step
		var envelope: float = sin(minf(PI, t * PI))
		var value: float = _wave_value(phase, wave) * amplitude * envelope
		var pcm: int = int(clampf(value, -1.0, 1.0) * 32767.0)
		bytes[sample_index * 2] = pcm & 0xFF
		bytes[sample_index * 2 + 1] = (pcm >> 8) & 0xFF

	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _wav_from_pcm(bytes: PackedByteArray, sample_rate: int) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _write_pcm_sample(bytes: PackedByteArray, sample_index: int, value: float) -> void:
	var pcm: int = int(clampf(value, -1.0, 1.0) * 32767.0)
	bytes[sample_index * 2] = pcm & 0xFF
	bytes[sample_index * 2 + 1] = (pcm >> 8) & 0xFF


func _sine_hz(freq_hz: float, time_sec: float) -> float:
	return sin(TAU * freq_hz * time_sec)


func _edge_fade(progress: float, edge_fraction: float) -> float:
	var edge: float = clampf(edge_fraction, 0.001, 0.49)
	var in_ramp: float = clampf(progress / edge, 0.0, 1.0)
	var out_ramp: float = clampf((1.0 - progress) / edge, 0.0, 1.0)
	return minf(in_ramp, out_ramp)


func _wave_value(phase: float, wave: String) -> float:
	if wave == "triangle":
		return asin(sin(phase)) * (2.0 / PI)
	if wave == "saw":
		var wrapped: float = fmod(phase, TAU) / TAU
		return wrapped * 2.0 - 1.0
	return sin(phase)
