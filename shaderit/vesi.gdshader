// Paavo, 06.11.2024

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest_mipmap;

uniform sampler2D noise : repeat_enable;

const float NOPEUS = 0.05;
const float AALTOJEN_NOPEUS = 0.9;
const float AALTOJEN_LEVEYS = 0.2;
const float AALTOJEN_ETAISYYS = 0.1;
const float AALTOJEN_KIRKKAUS = 0.2;
const float VOIMAKKUUS_X = 0.010;
const float VOIMAKKUUS_Y = 0.010;
const vec4 VEDEN_VARI = vec4(0.2, 0.2, 0.6, 0.2);
const float HEIJASTUKSEN_KOKO = 64.0;

void fragment() {
	// Ajan mukaan siirretty kohinatekstuuri
	vec4 noise_vari = texture(noise, SCREEN_UV + TIME * NOPEUS);

	// Siirros näytöllä, käytetään animaatioon pelkkää TIME-arvoa.
	vec2 offset = vec2(
		(0.5 - noise_vari.r) * VOIMAKKUUS_X,
		(0.5 - noise_vari.r) * VOIMAKKUUS_Y
	);

	// Ajan ja kohinatekstuurin mukaan siirretty
	vec4 vari = texture(screen_texture, SCREEN_UV + offset);

	// "Aallot"
	float i = 0.5 + sin(TIME * AALTOJEN_NOPEUS) * AALTOJEN_ETAISYYS;
	float j = (cos(TIME * AALTOJEN_NOPEUS)) * 0.1 + 0.2;
	if (noise_vari.r > i && noise_vari.r < i + j) {
		vari.rgb = mix(vari.rgb, vec3(1.0, 1.0, 1.0), AALTOJEN_KIRKKAUS * vari.r);
	}

	COLOR = vari;
}