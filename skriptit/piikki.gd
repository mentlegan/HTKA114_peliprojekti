extends Area2D
## Juuso 16.8.2025
## Piikeistä helpommin huomattavia?
## Tuli mieleen tehdessä perhospesän kohtaa, jossa esiintyy piikkejä
## Voisi olla esimerkiksi sellainen, että väri vaihtelee vähäsen jatkuvasti
## Tai highlightaava, aaltoileva valkoinen glow, tai outline yms.
## Pieni värähtelevä liikekin voisi auttaa

@onready var sprite_2d_highlight: Sprite2D = $Sprite2DHighlight

var sprite_highlight_alpha: float
var tween: Tween

func _ready() -> void:
	sprite_highlight_alpha = sprite_2d_highlight.modulate.a
	sprite_2d_highlight.modulate.a = 0.0
	tween_nakyvyys()


## Tweenauksen jatkuva sykli
func tween_nakyvyys() -> void:
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops(0)
	tween.tween_property(sprite_2d_highlight, "modulate:a", sprite_highlight_alpha, 1.0)
	tween.tween_property(sprite_2d_highlight, "modulate:a", 0.0, 0.7).set_delay(0.5)
	tween.tween_interval(3.5)


## Pelaajan alkaa ottamaan myrkkyä osuessaan sieneen
func _on_body_entered(body):
	if body is Pelaaja:
		print_debug("Kuolit PIIKKIIN")
		body.meneta_elamia(body.pelaajan_elamat_max, "normaali")
