## Juuso 22.3.2024
## Paavo 7.4.2024
## Kukkien ominaisuudet luonnossa

extends Area2D

## Kukan valo ja valonlähteen oma CollisionShape2D valon tarkistusta varten.
@onready var valo_area2d = $Area2D
@onready var valo = $Area2D/PointLight2D
@onready var valo_collision = $Area2D/CollisionShape2D

## Tällä hetkellä toteutettu pelaaja-skriptissä kukkien area2D nodejen sekä ryhmien avulla
"""
## Jos kukka ja pelaaja törmäävät, ts. pelaaja kerää kukan, joka muuttuu (nyt vielä maagisesti ja näkymättömästi) valopalloksi
func _on_body_entered(body):
	if body.is_in_group("Pelaaja"): # Otetaan pelaajan group
		Globaali.palloja = 2 # Tästä globaaliin muuttujaan muutos, että palloja on kaksi käytettävänä
		print("kukka kerätty")
"""

## Valon lisääminen pallon osuttua
func _on_body_entered(body):
	if body.is_in_group("valopallo") and not valo_area2d.is_in_group("valonlahde"):
		valo.set_visible(true)
		valo_area2d.add_to_group("valonlahde")
		
		# queue_free() # Poistetaan kukka luonnosta, kun se on kerätty
		# Ei poisteta ainakaan ensimmäisiä kukkia, jotta valopalloja voi ottaa loputtomasti
