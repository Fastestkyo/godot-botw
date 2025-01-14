shader_type spatial;
render_mode cull_disabled;	

uniform sampler2D noise : filter_linear_mipmap, repeat_enable;
uniform sampler2D gradient : filter_linear, source_color;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}
void fragment() {
	float noise_tex = texture(noise, UV - vec2(0.0, TIME)).x;
	ALPHA = step(-0.15, noise_tex - UV.y);
	vec3 gradient_tex = texture(gradient, vec2(UV.y, 0.0)).rgb;
	EMISSION = gradient_tex + step(0.15, fresnel(1.0, NORMAL, VIEW)) * gradient_tex;
	ALBEDO = gradient_tex;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}


