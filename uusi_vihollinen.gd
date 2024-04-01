## Harri 29.3.2024
## Vanhan vihollisen saa takaisin: noden Inspector - process - disabled -> inherit
## TODO: valmiiksi ja paremmaksi, koska tosi work-in-progress
## Osaa tällä hetkellä:
## kadota, kun valopallon heittää viholliseen,
## tappaa pelaajan hänen istuessaan liian kauan vihollisen alueella
## ärähdellä, kun se on sillä tuulella
extends Node2D

## Ajastimet ja muuttujat
signal pelaaja_kuollut
var pelaaja = null
var idle_audio_ajastin = Timer.new()
var rng = RandomNumberGenerator.new() ## Randomgeneraattori, käytetään ainakin vihollisen "nopeuteen" ja "sijaintiin"
var kuolema_ajastin = Timer.new() ## Ajastin, että milloin vihollinen tappaa pelaajan
var nykyinen_alue = null ## TODO: Tällä voisi hallita vihollisen nykyistä sijaintia, mutta work in progress
var light = preload("res://valo_character.tscn")

## Äänet, kopsattu aiemmasta vihollisesta
@onready var audio_paikoillaan = $AudioPaikoillaan
@onready var audio_jahtaus = $AudioJahtaus
@onready var audio_pakeneminen = $AudioPakeneminen
@onready var audio_pelaaja_kuolee = $AudioPelaajaKuolee
## Liikkumisääni silloin kun ei jahdata pelaajaa.
## Tällä hetkellä vihollinen ei liiku jos se ei jahtaa tai pakene.
## TODO: Soita ääni kun vihollinen liikkuu, mutta ei jahtaa tai pakene.
@onready var audio_liikkuminen = $AudioLiikkuminen

## Nodet
## Käyttää uutta taktiikkaa nodejen saantiin. Aika idioottivarma tapa saada node heittämättä nullia
@onready var valon_tarkistus = get_node("%ValonTarkistus")
@onready var valon_tarkistus2 = get_node("%ValonTarkistus2")
@onready var alue1 = get_node("%alue")
@onready var alue2 = get_node("%alue2")

## Kun scene avataan, ready tapahtuu
func _ready():
	# TODO: tällä voisi tehdä alueiden vaihtelut
	nykyinen_alue = alue1
	# Annetaan ajastin
	self.add_child(kuolema_ajastin)
	# Signaalikäsittelyä
	valon_tarkistus.connect("siirrytty_valoon", siirrytty_valoon)
	valon_tarkistus.connect("siirrytty_varjoon", siirrytty_varjoon)
	valon_tarkistus2.connect("siirrytty_valoon", siirrytty_valoon)
	valon_tarkistus2.connect("siirrytty_varjoon", siirrytty_varjoon)
	# Valon tarkistuksen käsittelyä
	if valon_tarkistus.on_valossa():
		siirrytty_valoon()
	else:
		siirrytty_varjoon()

## Delta kutsutaan joka framella
func _process(_delta):
	pass

## Kollektiivinen kuolema-funktio..
func kuolema():
	pelaaja_kuollut.emit() # ..joka lähettää signaalin Globaalille

## Kollektiivinen alueelle astumisen funktio
func astuttu_alueelle(body):
	if body.is_in_group("Pelaaja"): # Otetaan pelaajan group
		audio_jahtaus.play() # Ärähdetään ilkeästi
		var kuolema_aika = rng.randf_range(1.0, 5.0) # Tästä voi säätää ajan kantaman, missä pelaaja voi kuolla viholliseen
		#print("Kuolema-aika: " + str(kuolema_aika))
		kuolema_ajastin.start(kuolema_aika) # Aloitetaan jahti
		await kuolema_ajastin.timeout # Odotetaan, että vihu saa pelaajan kiinni
		audio_pelaaja_kuolee.play() # Tapetaan pelaaja erittäin raa'asti
		pelaaja = body # Varmistetaan vielä, että kyseessä on pelaaja
		kuolema() # Lopulta kuollaan

## Kollektiivinen alueelta poistumisen funktio
## TODO: tähän voisi lisäillä jotain hauskaa, jos tulee mieleen. Ääniä vaikka?
func poistuttu_alueelta(_body):
	kuolema_ajastin.stop() # Pysäytetään ajastin, että pelaaja ei kuole, vaikka astuisi alueelta pois

## Funktio alueelle 1
func _on_alue_body_entered(body):
	if nykyinen_alue == body:
		astuttu_alueelle(body)

## Funktio alueelle 1
func _on_alue_body_exited(body):
	poistuttu_alueelta(body)

## Funktio alueelle 2
func _on_alue_2_body_entered(body):
	astuttu_alueelle(body)

## Funktio alueelle 2
func _on_alue_2_body_exited(body):
	poistuttu_alueelta(body)

## Jos vihollinen onkin valossa, vaikkapa valopallon heitosta
func siirrytty_valoon():
	audio_pakeneminen.play() # Jostain syystä ei soi
	self.process_mode = Node.PROCESS_MODE_DISABLED # Alue deaktivoituu..
	self.visible = false # .. ja katoaa näkyvistä
	#print ("vihollinen siirtyi")

## Ei varmaan tarvita tätä ollenkaan
func siirrytty_varjoon():
	pass
