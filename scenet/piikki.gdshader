// Juuso 16.8.2025
// Piikin aaltoileva highlight efekti
// Ideana on auttaa pelaajaa erottamaan piikit, kun ne eivät ole valossa
// Esim. perhospesa2 tp

shader_type canvas_item;
render_mode unshaded;

uniform float wave_speed : hint_range(0.1, 100.0) = 5.0;
uniform float wave_frequency : hint_range(0.1, 20.0) = 5.0;
uniform vec4 wave_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Aalto y-suunnassa
    float wave = sin(UV.y * wave_frequency - TIME * wave_speed) * 0.5 + 0.5;
    // Efekti alkuperäisen tekstuurin päälle
    COLOR.rgb += wave_color.rgb * wave * wave_color.a;
}