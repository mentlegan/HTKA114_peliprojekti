## Harri 7.3.2024
## Tämä on globaali scripti, johon voi lisätä muuttujia ja funktioita käytettäväksi muissa scripteissä
extends Node

## Pallomäärä
var palloja = 0

## Respawnaa pelaajan käynnistämällä nykyisen scenen uudestaan
func respawn():
	# Haetaan SceneTree ja käynnistetään se uudestaan
	self.get_tree().call_deferred("reload_current_scene")
	print("kuolit") ## game over
