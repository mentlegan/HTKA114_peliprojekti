## Harri 13.3.2024
## Tämä on globaali scripti, johon voi lisätä muuttujia ja funktioita käytettäväksi muissa scripteissä
extends Node

## Käytössä olevat pallot
var palloja = 0
## Maailmassa olevat pallot
var current_lights = 0

## Respawnaa pelaajan käynnistämällä nykyisen scenen uudestaan
func respawn():
	# Haetaan SceneTree ja käynnistetään se uudestaan
	self.get_tree().call_deferred("reload_current_scene")

## Yleinen game over. Avaa game over ikkunan pelaajalle, josta sitten voi lopettaa pelin tai
## käynnistää peli uudelleen kutsumalla tämän skriptin respawn() funktiota
func gameover():
	#await get_tree().create_timer(2,5).timeout
	get_tree().paused = true
	#pelaaja.gos.visible = true
