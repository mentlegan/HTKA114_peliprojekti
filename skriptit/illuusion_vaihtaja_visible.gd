extends IlluusionVaihtaja
## Illuusio-node, joka vaihtaa vanhemman visible-muuttujan veteen siirtyessä
## Juuso 26.9.2024 Vaihdettu tweenaamaan
var tween: Tween

func vaihda_illuusio(pelaaja_vedessa: bool):
	# Jos kutsutaan aina _ready() -> vaihda_illuusio(invert)
	# pelaaja_vedessa == invert AINA, jolloin kaikki piilossa aluksi
	#get_parent().visible = (pelaaja_vedessa != invert)
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	if pelaaja_vedessa != invert:
		tween.tween_property(get_parent(), "modulate:a", 1, 0.5)
	else:
		tween.tween_property(get_parent(), "modulate:a", 0, 0.5)
