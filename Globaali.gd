## Harri 21.2.2024
## Tämä on globaali scripti, johon voi lisätä ainakin muuttujia käytettäväksi muissa scripteissä

extends Node

## Pallomäärä
var palloja = 0

## Respawnaa pelaajan käynnistämällä nykyisen scenen uudestaan.
func respawn():
	# Haetaan SceneTree ja käynnistetään se uudestaan.
	self.get_tree().reload_current_scene()
