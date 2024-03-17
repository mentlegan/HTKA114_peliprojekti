## Harri 17.3.2024
## Hallitaan pallojen määrää indikoivaa tekstiä

extends Label

## Tähän _process(delta), eli päivittää itseään jatkuvasti, että pallomäärä pysyy globaalin muuttujan mukaisesti
## Ehkä voisi tehdä siistimmin, jos syö muistia liikaa
## Tehty näin nyt ainakin tällä kertaa, koska toisten scriptien funktioiden käyttö oli jotenkin hankalaa. Tätä pitää opiskella enemmän
func _process(_delta):
	self.text = "Light Balls: " + str(Globaali.palloja)
