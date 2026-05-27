class_name MovementMetrics
extends RefCounted


static func jump_air_time(jump_velocity: float, gravity_force: float, launch_to_landing_height_delta: float = 0.0) -> float:
	# Solve: -0.5*g*t^2 + v*t - h = 0
	# where h is landing_height - launch_height.
	if gravity_force <= 0.0:
		return 0.0
	var discriminant: float = jump_velocity * jump_velocity - 2.0 * gravity_force * launch_to_landing_height_delta
	if discriminant < 0.0:
		return 0.0
	return (jump_velocity + sqrt(discriminant)) / gravity_force


static func flat_gap_distance_constant_speed(horizontal_speed: float, air_time: float) -> float:
	return maxf(0.0, horizontal_speed) * maxf(0.0, air_time)


static func flat_gap_distance_with_accel(v_initial: float, v_target: float, accel_rate: float, air_time: float) -> float:
	# Continuous approximation of the controller's exp blend:
	# v(t) = v_target + (v_initial - v_target) * exp(-a*t)
	# x(t) = integral(v(t)dt)
	if air_time <= 0.0:
		return 0.0
	if accel_rate <= 0.0:
		return v_initial * air_time
	return v_target * air_time + (v_initial - v_target) * (1.0 - exp(-accel_rate * air_time)) / accel_rate


static func dash_extra_distance(dash_velocity_at_jump: float, dash_decay: float, air_time: float, alignment: float = 1.0) -> float:
	# Dash decay model from controller:
	# v_dash(t) = v0 * exp(-k*t)
	# x_dash = integral(v_dash dt) = v0/k * (1 - exp(-k*t))
	if air_time <= 0.0:
		return 0.0
	var axis_align: float = clampf(alignment, -1.0, 1.0)
	if dash_decay <= 0.0:
		return dash_velocity_at_jump * air_time * axis_align
	return (dash_velocity_at_jump / dash_decay) * (1.0 - exp(-dash_decay * air_time)) * axis_align


static func slide_extra_distance(slide_velocity_at_jump: float, slide_drag_factor: float, air_time: float, alignment: float = 1.0) -> float:
	# Controller decay form:
	# slide_velocity *= pow(slide_drag_factor, delta)
	# Continuous: v_slide(t) = v0 * exp(-lambda*t), lambda = -ln(slide_drag_factor)
	if air_time <= 0.0:
		return 0.0
	var axis_align: float = clampf(alignment, -1.0, 1.0)
	if slide_drag_factor <= 0.0:
		return 0.0
	if is_equal_approx(slide_drag_factor, 1.0):
		return slide_velocity_at_jump * air_time * axis_align
	var lambda: float = -log(slide_drag_factor)
	return (slide_velocity_at_jump / lambda) * (1.0 - exp(-lambda * air_time)) * axis_align


static func profile_summary(
	jump_velocity: float,
	gravity_force: float,
	walk_speed: float,
	sprint_speed: float,
	launch_to_landing_height_delta: float = 0.0
) -> Dictionary:
	var air_time: float = jump_air_time(jump_velocity, gravity_force, launch_to_landing_height_delta)
	return {
		"air_time": air_time,
		"walk_jump_distance": flat_gap_distance_constant_speed(walk_speed, air_time),
		"sprint_jump_distance": flat_gap_distance_constant_speed(sprint_speed, air_time)
	}
