## Juuso 13.3.2024
## Kukkien ominaisuudet luonnossa

extends Area2D

## Tällä hetkellä toteutettu pelaaja-skriptissä kukkien area2D nodejen sekä ryhmien avulla
"""
## Jos kukka ja pelaaja törmäävät, ts. pelaaja kerää kukan, joka muuttuu (nyt vielä maagisesti ja näkymättömästi) valopalloksi
func _on_body_entered(body):
	if body.is_in_group("Pelaaja"): # Otetaan pelaajan group
		Globaali.palloja = 2 # Tästä globaaliin muuttujaan muutos, että palloja on kaksi käytettävänä
		print("kukka kerätty")
"""
		
		# queue_free() # Poistetaan kukka luonnosta, kun se on kerätty
		# Ei poisteta ainakaan ensimmäisiä kukkia, jotta valopalloja voi ottaa loputtomasti
