// Paavo, 26.09.2024

// TODO: Paremman näköiseksi valopallolla tms valaistuna
// TODO: Vedenpinta näkyviin shaderilla / partikkeleilla / heijastuksella
// TODO: Älä skaalaa kohinatekstuuria CollisionShape2D:n mukana

shader_type canvas_item;

// Tällä saa paremman näköisen hohdon, pehmentää tosin normaaleita tekstuureita liikaa.
// Pitäisi ehkä siirtää hohto erilliseen shaderiin.
//uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest_mipmap;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest_mipmap;

uniform sampler2D noise : repeat_enable;

uniform float nopeus = 0.05;
uniform float aaltojen_nopeus = 0.9;
uniform float aaltojen_leveys = 0.2;
uniform float aaltojen_etaisyys = 0.1;
uniform float aaltojen_kirkkaus = 0.2;
uniform float voimakkuus_x = 0.007;
uniform float voimakkuus_y = 0.010;

// "Hohtava" vesi, tosin pikselimössönä, mustien pikselien kera ja ilman vedenpinnan hohtoa.
// Surkea toteutus, värittää mustat pikselit uudelleen sumennetulla kuvalla.
uniform bool hohtava_vesi = false;

uniform bool epaselva_vesi = false;

uniform vec4 veden_vari = vec4(0.2, 0.2, 0.6, 0.2);

uniform bool vedenpinta = true;

void fragment() {
	// Ajan mukaan siirretty kohinatekstuuri
	vec4 noise_vari = texture(noise, UV + TIME * nopeus);

	// Siirros näytöllä, käytetään animaatioon pelkkää TIME-arvoa.
	vec2 offset = vec2(
		(0.5 - noise_vari.r) * voimakkuus_x,
		(0.5 - noise_vari.r) * voimakkuus_y
	);

	// Ajan ja kohinatekstuurin mukaan siirretty
	vec4 vari = texture(screen_texture, SCREEN_UV + offset);

	// "Hohtava" vesi
	if (hohtava_vesi) {
		if (vari.r < 0.03 && vari.g < 0.03 && vari.b < 0.03) {
			vari = textureLod(screen_texture, SCREEN_UV, 2.0);
		}
	}

	// Epäselvä vesi
	if (epaselva_vesi) {
		vec3 noise_screen_blur = textureLod(screen_texture, SCREEN_UV + offset, noise_vari.r * 1.0).rgb;
		vari.rgb = mix(vari.rgb, noise_screen_blur, float(noise_vari.r > 0.7));
	}

	// "Aallot"
	float i = 0.5 + sin(TIME * aaltojen_nopeus) * aaltojen_etaisyys;
	float j = (cos(TIME * aaltojen_nopeus)) * 0.1 + 0.2;
	if (noise_vari.r > i && noise_vari.r < i + j) {
		vari.rgb = mix(vari.rgb, vec3(1.0, 1.0, 1.0), aaltojen_kirkkaus * vari.r);
	}

	COLOR = vari;
}