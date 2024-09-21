// Paavo, 27.08.2024
// Mallia otettu DevItWithCat:in esimerkistä:
// https://godotshaders.com/shader/2d-water-effect/
// Vakioarvoja voi halutessaan säätää

// TODO: Paremman näköiseksi valopallolla tms valaistuna
// TODO: Vedenpinta näkyviin shaderilla / partikkeleilla

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D noise : repeat_enable;

const float NOPEUS = 0.05;
const float VOIMAKKUUS_X = 0.006;
const float VOIMAKKUUS_Y = 0.008;

void fragment() {
	// Sijainti näytöllä
	vec2 uv = SCREEN_UV;
	
	// Siirros näytöllä, käytetään animaatioon pelkkää TIME-arvoa.
	vec2 offset = vec2(
		(0.5 - texture(noise, UV + TIME * NOPEUS).r) * VOIMAKKUUS_X,
		(0.5 - texture(noise, UV + TIME * NOPEUS).r) * VOIMAKKUUS_Y
	);
	
	// Asetetaan väri vieressä olevan alueen mukaan
	COLOR = texture(screen_texture, uv + offset);
}