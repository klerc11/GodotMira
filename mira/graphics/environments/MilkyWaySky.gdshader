shader_type sky;

uniform vec3 top_color : source_color = vec3(0.016, 0.018, 0.028);
uniform vec3 mid_color : source_color = vec3(0.07, 0.08, 0.11);
uniform vec3 horizon_color : source_color = vec3(0.1922, 0.1686, 0.2588);
uniform vec3 band_color : source_color = vec3(0.2902, 0.2627, 0.3765);
uniform float band_width : hint_range(0.05, 0.8) = 0.24;
uniform float band_strength : hint_range(0.0, 2.0) = 0.52;
uniform float star_density : hint_range(0.0, 0.2) = 0.00055;
uniform float star_scale : hint_range(50.0, 1200.0) = 760.0;
uniform float star_brightness : hint_range(0.0, 2.5) = 0.44;

float hash3(vec3 p) {
	return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

void sky() {
	vec3 dir = normalize(EYEDIR);
	float h = clamp(dir.y * 0.5 + 0.5, 0.0, 1.0);

	vec3 lower_grad = mix(horizon_color, mid_color, smoothstep(0.0, 0.58, h));
	vec3 upper_grad = mix(mid_color, top_color, smoothstep(0.34, 1.0, h));
	vec3 col = mix(lower_grad, upper_grad, smoothstep(0.2, 0.84, h));

	float horizon_glow = exp(-pow(abs(dir.y) / 0.22, 2.0));
	col += vec3(0.09, 0.07, 0.13) * horizon_glow * 0.26;

	float az = atan(dir.x, dir.z);
	float hue_wave = 0.5 + 0.5 * sin(az * 2.0 + dir.y * 3.6);
	col += mix(vec3(0.03, 0.03, 0.05), vec3(0.07, 0.05, 0.1), hue_wave) * 0.05 * (1.0 - h);

	vec3 band_normal = normalize(vec3(-0.28, 0.93, 0.21));
	float band = exp(-pow(abs(dot(dir, band_normal)) / band_width, 2.0));
	col += band_color * band * band_strength;

	vec3 cell = floor(dir * star_scale);
	float n = hash3(cell);
	float twinkle_seed = hash3(cell + vec3(19.1, 73.7, 41.3));
	float star = step(1.0 - star_density, n) * (0.65 + twinkle_seed * 0.35);
	col += vec3(star) * star_brightness;

	COLOR = col;
}
