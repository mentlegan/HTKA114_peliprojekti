extends IlluusionVaihtaja
## Illuusio-node, joka vaihtaa vanhemman spriten flip_h-muuttujan veteen siirtyessä
## Toimii pelkästään, jos vanhempi on Sprite2D.


func vaihda_illuusio(pelaaja_vedessa: bool):
	get_parent().flip_h = pelaaja_vedessa
