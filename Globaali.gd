## Harri ja Juuso 15.3.2024
## Tämä on globaali scripti, johon voi lisätä muuttujia ja funktioita käytettäväksi muissa scripteissä
extends Node2D

## Käytössä olevat pallot
var palloja = 0
## Maailmassa olevat pallot
var nykyiset_pallot = 0
## Signaaleja varten
var pelaaja = null
var vihollinen = null

## Pelaajan ja vihollisen aloitus koordinaatit
var pelaaja_aloitus = null
var vihollinen_aloitus = null

## Kaikki scenen ovet
var ovet = Array()

## Tässä otetaan käyttöliittymän GameOverRuutu groupin avulla. Kaikki muut vaihtoehdot ovat heittäneet erroria
@onready var gameover_ruutu = get_tree().get_first_node_in_group("gameoverruutu")
@onready var pauseruutu = get_tree().get_first_node_in_group("pauseruutu")

## Lisätään sceneen tausta pelin alussa
var tausta = preload("res://tausta.tscn")

## Yleinen ready
func _ready():
	# Signaalikäsittelyä mm. pelaajan kuolemisesta
	pelaaja = get_tree().get_first_node_in_group("Pelaaja") # Otetaan pelaaja groupistaan
	pelaaja.kuollut.connect(_game_over) # Yhdistetään signaali pelaajasta
	
	vihollinen = get_tree().get_first_node_in_group("vihollinen") # Tehdään näissä
	vihollinen.pelaaja_kuollut.connect(_game_over) # samaa kuin pelaajan käsittelyssä
	
	# Otetaan aloitus koordinaatit talteen
	pelaaja_aloitus = pelaaja.position
	vihollinen_aloitus = vihollinen.position
	
	# Haetaan koynnosovet-noden kaikki lapset
	var koynnosovet_lapset = get_tree().get_first_node_in_group("koynnosovet").get_children()
	for koynnosovi in koynnosovet_lapset:
		if koynnosovi.is_in_group("oviV") or koynnosovi.is_in_group("oviO"):
			ovet.append(koynnosovi)
	
	# Lisätään sceneen tausta
	self.add_child(tausta.instantiate())


## Respawnaa pelaajan käynnistämällä nykyisen scenen uudestaan
func respawn():
	palloja = 0 # Resetoidaan pallot, koska reload_current_scene ei sitä tee. Tämän voi koittaa laittaa johonkin järkevämpään paikkaan
	nykyiset_pallot = 0 # Nykyisten pallojen määrä laitetaan 0
	
	# Valopallojen tuhoaminen
	var valopallot = get_tree().get_nodes_in_group("valopallo")
	for pallo in valopallot:
		pallo.queue_free()
	
	# Peli pois pauselta
	get_tree().paused = false
	# Haetaan SceneTree ja käynnistetään se uudestaan
	# self.get_tree().call_deferred("reload_current_scene")
	pelaaja.position = pelaaja_aloitus
	vihollinen.position = vihollinen_aloitus
	gameover_ruutu.visible = false


## Yleinen game over funktio signaaleista. Avaa game over ikkunan pelaajalle, josta sitten voi lopettaa pelin tai
## käynnistää peli uudelleen kutsumalla tämän skriptin respawn() funktiota
func _game_over():
	get_tree().paused = true # Peli pauselle, kun se päättyy. Voi hienojen animaatioiden kanssa tietysti myös jättää pausettamatta
	await get_tree().create_timer(2,5).timeout # Pieni ajastin, että game over ei ihan heti tule
	gameover_ruutu.visible = true
