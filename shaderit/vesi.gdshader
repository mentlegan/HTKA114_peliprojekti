// Paavo, 27.08.2024
// Mallia otettu DevItWithCat:in esimerkistä:
// https://godotshaders.com/shader/2d-water-effect/
// Vakioarvoja voi halutessaan säätää

// TODO: Ota käyttöön gradient- tai noise-tekstuuri.

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

const float NOPEUS = 10.0;
const float TAAJUUS = 30.0;
const float LEVEYS = 0.001;

void fragment() {
	// Sijainti näytöllä
	vec2 uv = SCREEN_UV;
	
	// Siirros näytöllä, käytetään animaatioon pelkkää TIME-arvoa.
	vec2 offset = vec2(0.0);
	offset.x = cos(
		(TIME * NOPEUS) + uv.x + UV.y * TAAJUUS
	) * LEVEYS;
	
	// Asetetaan väri vieressä olevan alueen mukaan
    COLOR = texture(screen_texture, uv + offset);
	
	// Tehdään alueesta myös sinertävämpi
	COLOR.b += 0.1;
}