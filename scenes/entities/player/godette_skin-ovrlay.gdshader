shader_type spatial;
render_mode unshaded;

uniform vec3 color : source_color;
uniform float energy = 1.0;
uniform float alpha : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	ALBEDO = color * energy;
	ALPHA = alpha;
}


