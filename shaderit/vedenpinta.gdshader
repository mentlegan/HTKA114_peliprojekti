shader_type canvas_item;

void fragment() {
	// Siirretään tekstuuria sini-funktiolla.
	vec2 uusi_uv = UV;
	uusi_uv.x += sin(TIME);
	vec4 c = texture(TEXTURE, uusi_uv);
	COLOR = c;
}