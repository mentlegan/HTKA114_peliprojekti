## Harri 21.2024
## Kukkien ominaisuudet luonnossa

extends Area2D

## Jos kukka ja pelaaja törmäävät, ts. pelaaja kerää kukan, joka muuttuu (nyt vielä maagisesti ja näkymättömästi) valopalloksi
func _on_body_entered(body):
	if body.is_in_group("Pelaaja"): ## Otetaan pelaajan group
		Globaali.palloja += 1 ## Tästä globaaliin muuttujaan muutos, että pallo on kerätty
		print("kukka kerätty")
		queue_free() ## Poistetaan kukka luonnosta, kun se on kerätty
