class_name MiraMetrics
extends RefCounted

var level_title: String = ""
var attempt_id: int = 0
var attempt_active: bool = false
var tuning: Dictionary = {}

var time_total: float = 0.0
var distance_planar: float = 0.0
var speed_sum: float = 0.0
var speed_sq_sum: float = 0.0
var sample_count: int = 0
var flow_time: float = 0.0
var air_time: float = 0.0
var slide_time: float = 0.0
var wall_touch_time: float = 0.0
var beam_risk_time: float = 0.0
var beam_panic_time: float = 0.0
var min_beam_gap: float = 9999.0
var max_speed: float = 0.0

var resets: int = 0
var relay_checkpoints: int = 0
var dashes: int = 0
var jumps: int = 0
var wall_jumps: int = 0
var slide_starts: int = 0
var reflect_attempts: int = 0
var reflect_hits: int = 0
var reflect_misses: int = 0

var completed: bool = false
var fail_reason: String = ""
var attempt_history: Array[Dictionary] = []


func begin_attempt(next_level_title: String, tuning_params: Dictionary) -> void:
	level_title = next_level_title
	attempt_id += 1
	attempt_active = true
	tuning = tuning_params.duplicate(true)
	_clear_attempt_counters()


func sample(delta: float, planar_speed: float, grounded: bool, sliding: bool, beam_gap: float, beam_live: bool, wall_touching: bool) -> void:
	if not attempt_active:
		return
	time_total += delta
	distance_planar += planar_speed * delta
	speed_sum += planar_speed
	speed_sq_sum += planar_speed * planar_speed
	sample_count += 1
	max_speed = maxf(max_speed, planar_speed)
	flow_time += delta if planar_speed >= float(tuning.get("flow_speed_threshold", 8.0)) else 0.0
	air_time += delta if not grounded else 0.0
	slide_time += delta if sliding else 0.0
	wall_touch_time += delta if wall_touching else 0.0
	if beam_live:
		min_beam_gap = minf(min_beam_gap, beam_gap)
		beam_risk_time += delta if beam_gap < float(tuning.get("beam_risk_gap", 5.0)) else 0.0
		beam_panic_time += delta if beam_gap < float(tuning.get("beam_panic_gap", 2.4)) else 0.0


func mark_dash() -> void:
	if attempt_active:
		dashes += 1


func mark_jump() -> void:
	if attempt_active:
		jumps += 1


func mark_wall_jump() -> void:
	if attempt_active:
		wall_jumps += 1


func mark_slide_start() -> void:
	if attempt_active:
		slide_starts += 1


func mark_reflect(success: bool) -> void:
	if not attempt_active:
		return
	reflect_attempts += 1
	if success:
		reflect_hits += 1
	else:
		reflect_misses += 1


func mark_reset() -> void:
	if attempt_active:
		resets += 1


func mark_relay_checkpoint() -> void:
	if attempt_active:
		relay_checkpoints += 1


func end_attempt_with_fail(reason: String) -> Dictionary:
	fail_reason = reason
	completed = false
	return _finalize_attempt()


func end_attempt_with_complete() -> Dictionary:
	fail_reason = ""
	completed = true
	return _finalize_attempt()


func save_last_report(path: String = "user://mira_metrics_latest.json") -> void:
	if attempt_history.is_empty():
		return
	var report: Dictionary = attempt_history[attempt_history.size() - 1]
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(report, "\t"))
	file.flush()
	file.close()


func latest_summary_line() -> String:
	if attempt_history.is_empty():
		return "No metrics report yet."
	var report: Dictionary = attempt_history[attempt_history.size() - 1]
	var eq: Dictionary = report.get("equations", {})
	return "Flow %.2f | Pressure %.2f | Recovery %.2f | Speed %.2f m/s | Beam min %.2f m" % [
		float(eq.get("flow_index", 0.0)),
		float(eq.get("pressure_index", 0.0)),
		float(eq.get("recovery_index", 0.0)),
		float(report.get("avg_speed", 0.0)),
		float(report.get("min_beam_gap", 0.0))
	]


func _finalize_attempt() -> Dictionary:
	if not attempt_active:
		return {}
	attempt_active = false
	var avg_speed: float = speed_sum / maxf(1.0, float(sample_count))
	var speed_std: float = sqrt(maxf(0.0, speed_sq_sum / maxf(1.0, float(sample_count)) - avg_speed * avg_speed))
	var flow_ratio: float = flow_time / maxf(0.001, time_total)
	var beam_risk_ratio: float = beam_risk_time / maxf(0.001, time_total)
	var beam_panic_ratio: float = beam_panic_time / maxf(0.001, time_total)
	var reflect_hit_rate: float = float(reflect_hits) / maxf(1.0, float(reflect_attempts))
	var reset_rate: float = float(resets) / maxf(1.0, time_total / 60.0)
	var target_speed: float = float(tuning.get("target_speed", 11.2))
	var target_panic_ratio: float = float(tuning.get("target_panic_ratio", 0.12))

	# Equation 1: Flow Index
	var speed_term: float = clampf(avg_speed / maxf(0.001, target_speed), 0.0, 1.15)
	var stability_term: float = clampf(1.0 - speed_std / maxf(0.001, target_speed * 0.82), 0.0, 1.0)
	var slide_term: float = clampf(slide_time / maxf(0.001, time_total * 0.3), 0.0, 1.0)
	var flow_index: float = clampf(0.42 * speed_term + 0.32 * flow_ratio + 0.14 * slide_term + 0.12 * stability_term, 0.0, 1.2)

	# Equation 2: Pressure Index (fair urgency band)
	var panic_alignment: float = 1.0 - clampf(absf(beam_panic_ratio - target_panic_ratio) / maxf(0.001, target_panic_ratio), 0.0, 1.0)
	var pressure_index: float = clampf(0.55 * panic_alignment + 0.3 * clampf(beam_risk_ratio / 0.34, 0.0, 1.0) + 0.15 * clampf(1.0 - reset_rate / 8.0, 0.0, 1.0), 0.0, 1.2)

	# Equation 3: Recovery Index (mistake survivability + execution)
	var recovery_index: float = clampf(0.5 * reflect_hit_rate + 0.25 * clampf(float(relay_checkpoints) / maxf(1.0, float(relay_checkpoints + resets)), 0.0, 1.0) + 0.25 * clampf(1.0 - reset_rate / 10.0, 0.0, 1.0), 0.0, 1.2)

	var report: Dictionary = {
		"level": level_title,
		"attempt_id": attempt_id,
		"completed": completed,
		"fail_reason": fail_reason,
		"time_total": time_total,
		"distance_planar": distance_planar,
		"avg_speed": avg_speed,
		"max_speed": max_speed,
		"speed_std": speed_std,
		"flow_ratio": flow_ratio,
		"air_ratio": air_time / maxf(0.001, time_total),
		"slide_ratio": slide_time / maxf(0.001, time_total),
		"wall_touch_ratio": wall_touch_time / maxf(0.001, time_total),
		"beam_risk_ratio": beam_risk_ratio,
		"beam_panic_ratio": beam_panic_ratio,
		"min_beam_gap": min_beam_gap if min_beam_gap < 9998.0 else 0.0,
		"dashes": dashes,
		"jumps": jumps,
		"wall_jumps": wall_jumps,
		"slide_starts": slide_starts,
		"reflect_attempts": reflect_attempts,
		"reflect_hits": reflect_hits,
		"reflect_misses": reflect_misses,
		"resets": resets,
		"relay_checkpoints": relay_checkpoints,
		"equations": {
			"flow_index": flow_index,
			"pressure_index": pressure_index,
			"recovery_index": recovery_index,
			"overall_index": (flow_index + pressure_index + recovery_index) / 3.0
		},
		"targets": tuning
	}
	attempt_history.append(report)
	return report


func _clear_attempt_counters() -> void:
	time_total = 0.0
	distance_planar = 0.0
	speed_sum = 0.0
	speed_sq_sum = 0.0
	sample_count = 0
	flow_time = 0.0
	air_time = 0.0
	slide_time = 0.0
	wall_touch_time = 0.0
	beam_risk_time = 0.0
	beam_panic_time = 0.0
	min_beam_gap = 9999.0
	max_speed = 0.0
	resets = 0
	relay_checkpoints = 0
	dashes = 0
	jumps = 0
	wall_jumps = 0
	slide_starts = 0
	reflect_attempts = 0
	reflect_hits = 0
	reflect_misses = 0
	completed = false
	fail_reason = ""
