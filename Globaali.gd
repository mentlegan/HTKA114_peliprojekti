## Harri 29.3.2024
## TODO: vihollisen äänenkorkeus paremmin jos vihollisia enemmän kuin 1
## TODO: tuki uusien vihollisten äänenkorkeudelle
## Tämä on yleinen, koko pelin kattava globaali scripti, johon voi lisätä muuttujia ja funktioita käytettäväksi muissa scripteissä
extends Node2D

## Käytössä olevat pallot
var palloja = 0
## Maailmassa olevat pallot
var nykyiset_pallot = 0
## Signaaleja varten
var pelaaja = null
var vihollinen = null
var piikki = null

## Pelaajan ja vihollisen aloitus koordinaatit
var pelaaja_aloitus = null
var vihollinen_aloitus = null

## Pelaajan taso2 koordinaatit teleporttaamiseen
@onready var pelaaja_taso2 = get_node("/root/Maailma/%Taso2Teleport").position
@onready var pelaaja_taso3 = get_node("/root/Maailma/%Taso3Teleport").position

## vihollisen äänenkorkeuden kerroin
var vihollisen_aanenkorkeuden_kerroin = 1
@onready var ikkunan_korkeus = get_viewport().get_visible_rect().size.y
@export var vihollisen_aanenkorkeuden_muutosnopeus = 0.6

## Kaikki scenen ovet
# var ovet = Array()
## Ristiovelle oma kohtelu vielä tässä vaiheessa
@onready var ovi_risti = get_tree().get_first_node_in_group("risti")
var pystyssa = true

## Tässä otetaan käyttöliittymän pauseruutu groupin avulla. Alla on toinen tapa ottaa
## @onready var pauseruutu = get_tree().get_first_node_in_group("pauseruutu")

## /root/Maailma/[uniquenimi] näyttäisi toimivan:
## pitää vaan muistaa kaikille käsiteltäville nodeille laittaa unique nimi nodepuusta:
## oikea näppäin ja % merkillä oleva valinta Access as unique name 
## ja kutsua sitä % merkillä scriptissä, kuten alla:
@onready var gameover_ruutu = get_node("/root/Maailma/%KayttoLiittyma/%GameOverRuutu")
@onready var pauseruutu = get_node("/root/Maailma/%KayttoLiittyma/%pause_ruutu")
@onready var uusiVihollinen = get_node("/root/Maailma/%uudetViholliset/%uusiVihollinen")


## Lisätään sceneen tausta pelin alussa
var tausta = preload("res://tausta.tscn")

@export var taso2 = preload("res://maailma2.tscn")
var t2 = preload("res://maailma2.tscn")

## Yleinen ready
func _ready():
	# Signaalikäsittelyä mm. pelaajan kuolemisesta
	pelaaja = get_tree().get_first_node_in_group("Pelaaja") # Otetaan pelaaja groupistaan
	pelaaja.kuollut.connect(_game_over) # Yhdistetään signaali pelaajasta
	
	vihollinen = get_tree().get_first_node_in_group("vihollinen") # Tehdään näissä
	vihollinen.pelaaja_kuollut.connect(_game_over) # samaa kuin pelaajan käsittelyssä
	
	if uusiVihollinen != null:
		uusiVihollinen.pelaaja_kuollut.connect(_game_over)
	
	piikki = get_tree().get_first_node_in_group("piikki") # Tehdään näissä
	if piikki != null:
		piikki.pelaaja_kuollut.connect(_game_over) # samaa kuin pelaajan käsittelyssä
	
	# Otetaan aloitus koordinaatit talteen
	pelaaja_aloitus = pelaaja.position
	vihollinen_aloitus = vihollinen.position
	
	"""
	# Haetaan koynnosovet-noden kaikki lapset eli ovet tasoittain
	var koynnosovet_tasot = get_tree().get_first_node_in_group("koynnosovet").get_children()
	for koynnosovi_vanhempi in koynnosovet_tasot:
		# Koynnosovien todelliset muutettavat nodet
		var koynnosovi_lapset = koynnosovi_vanhempi.get_children()
		for koynnosovi_lapsi in koynnosovi_lapset:
			if koynnosovi_lapsi.is_in_group("oviV") or koynnosovi_lapsi.is_in_group("oviO"):
				ovet.append(koynnosovi_lapsi)
	"""
	
	# Lisätään sceneen tausta
	self.add_child(tausta.instantiate())


## Kutsutaan joka frame
## Käytetään ohjaamaan vihollisen äänenkorkeutta vertaamalla vihollisen ja pelaajan y-koordinaatteja
func _process(_delta):
	var vihollisen_korkeus = vihollinen.get_global_position().y
	var pelaajan_korkeus = pelaaja.get_global_position().y
	var korkeuksien_erotus = vihollisen_korkeus - pelaajan_korkeus
	if korkeuksien_erotus < 0: # Vihollinen on pelaajan yläpuolella, joten halutaan arvo väliltä [1, 2]
		# Tässä ei vielä ongelmaa nykyisissä kentissä
		vihollisen_aanenkorkeuden_kerroin = abs(korkeuksien_erotus / ikkunan_korkeus) * vihollisen_aanenkorkeuden_muutosnopeus + 1
	elif korkeuksien_erotus > 0: # Vihollinen on pelaajan alapuolella, joten halutaan kerroin väliltä [0, 1]
		# Bugi, jos menee liian korkealle. Arvoksi tulee negatiivinen. nopea korjaus alla
		vihollisen_aanenkorkeuden_kerroin = 1 - (korkeuksien_erotus / ikkunan_korkeus) * vihollisen_aanenkorkeuden_muutosnopeus
		if vihollisen_aanenkorkeuden_kerroin > 1:
			vihollisen_aanenkorkeuden_kerroin = 1
	else:
		vihollisen_aanenkorkeuden_kerroin = 1
	# "Vihollinen" audiokanavan pitch shift -efekti
	var vihollinen_pitch_shift = AudioServer.get_bus_effect(1, 0)
	# TODO: korjaa bugi, saa virheellisiä arvoja
	vihollinen_pitch_shift.pitch_scale = vihollisen_aanenkorkeuden_kerroin
	
	# F2
	if Input.is_action_just_pressed("taso2"):
		"""
		ovet = Array()
		# Hyvin scuffed tapa, mutta toimii (kait?)
		get_tree().change_scene_to_packed(taso2)
		get_tree().root.add_child(t2.instantiate())
		_ready()
		# get_node("/root/Maailma2").free()
		"""
		pelaaja.position = pelaaja_taso2
	
	# F3
	if Input.is_action_just_pressed("taso3"):
		pelaaja.position = pelaaja_taso3
		# get_node("/root/@Node2D@65").queue_free() # Poistetaan duplikoitu maailma2


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


## Pausettaa pelin
func pausePeli():
	get_tree().paused = true
	pauseruutu.visible = true


## Jatkaa peliä pauseruudulta
func jatkaPelia():
	pauseruutu.visible = false


## Yleinen game over funktio signaaleista. Avaa game over ikkunan pelaajalle, josta sitten voi lopettaa pelin tai
## käynnistää peli uudelleen kutsumalla tämän skriptin respawn() funktiota
func _game_over():
	get_tree().paused = true # Peli pauselle, kun se päättyy. Voi hienojen animaatioiden kanssa tietysti myös jättää pausettamatta
	# Tai pausettaa peli muuten, mutta hienot kuolema-animaatiot silti toimivat normaalisti
	await get_tree().create_timer(2,5).timeout # Pieni ajastin, että game over ei ihan heti tule
	gameover_ruutu.visible = true
