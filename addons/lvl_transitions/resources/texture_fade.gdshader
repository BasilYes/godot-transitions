shader_type canvas_item;

uniform sampler2D fade_texture;
uniform float progress: hint_range(0.0, 1.0);
uniform bool invert = false;

void fragment() {
	COLOR.a = step(abs(float(invert) - texture(fade_texture, UV).r), progress)
		* ceil(progress);
}