extends IlluusionVaihtaja
## Illuusio-node, joka vaihtaa vanhemman visible-muuttujan veteen siirtyessä


func vaihda_illuusio(pelaaja_vedessa: bool):
	# Jos kutsutaan aina _ready() -> vaihda_illuusio(invert)
	# pelaaja_vedessa == invert AINA, jolloin kaikki piilossa aluksi
	get_parent().visible = (pelaaja_vedessa != invert)
