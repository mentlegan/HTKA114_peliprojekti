extends IlluusionVaihtaja
## Illuusio-node, joka vaihtaa vanhemman visible-muuttujan veteen siirtyessä


func vaihda_illuusio(pelaaja_vedessa: bool):
	get_parent().visible = pelaaja_vedessa
