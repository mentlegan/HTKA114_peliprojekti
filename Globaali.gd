## Harri 13.3.2024
## Tämä on globaali scripti, johon voi lisätä muuttujia ja funktioita käytettäväksi muissa scripteissä
## TODO: toimiva tapa napata nodeja tällä, ei taida muuten hommat onnistua (kts. rivi 14)
extends Node2D

## Käytössä olevat pallot
var palloja = 0
## Maailmassa olevat pallot
var current_lights = 0
## Signaalia varten
var pelaaja = null

## Tässä pitäisi ottaa käyttöliittymän GameOverRuutu
@onready var gos = get_node("KayttoLiittyma/GameOverRuutu") ## en ymmärrä, miksi tämä ei toimi

## Koetin myös signaaleilla tehdä, mutta ongelma on aika varmasti noden otossa
func _ready():
	pelaaja = get_tree().get_first_node_in_group("Pelaaja") # Otetaan pelaaja groupistaan
	pelaaja.kuollut.connect(_pelaaja_kuolee) # Yhdistetään signaali pelaajasta

## tehdään signaalista funktio
func _pelaaja_kuolee():
	gos.visible = true

## Respawnaa pelaajan käynnistämällä nykyisen scenen uudestaan
func respawn():
	# Haetaan SceneTree ja käynnistetään se uudestaan
	get_tree().paused = false
	self.get_tree().call_deferred("reload_current_scene")

## Yleinen game over. Avaa game over ikkunan pelaajalle, josta sitten voi lopettaa pelin tai
## käynnistää peli uudelleen kutsumalla tämän skriptin respawn() funktiota
func gameover():
	pass
	#get_tree().paused = true # Peli pauselle, kun se päättyy. Voi hienojen animaatioiden kanssa tietysti myös jättää pausettamatta
	#await get_tree().create_timer(2,5).timeout # Pieni ajastin, että game over ei ihan heti tule
	gos.visible = true
