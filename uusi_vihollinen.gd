## Harri 5.4.2024
## Vanhan vihollisen saa takaisin: noden Inspector - process - disabled -> inherit
## TODO: voisi koittaa kehittää eteenpäin vaikkapa vielä useammalle alueelle
## Osaa tällä hetkellä:
## tappaa pelaajan hänen istuessaan liian kauan vihollisen alueella
## vaihtaa paikkaa kahden alueen välillä saadessaan valopallosta
## äännähdellä, kun "jahtaa" pelaajaa, tappaa pelaajan, pakenee kaivautumalla alueelta, tai on toimettomana
extends Node2D

## Ajastimet, muuttujat ja signaalit
signal pelaaja_kuollut ## Pelaajan kuoleman signaali Globaalille
var pelaaja = null ## Pelaaja, on alussa null
var rng = RandomNumberGenerator.new() ## Randomgeneraattori, käytetään ainakin vihollisen "nopeuteen" ja "sijaintiin"
const IDLE_AUDIO_AJASTIN_MAX = 15.0 ## Ajastin asetetaan satunnaisesti 50-100%:iin tästä arvosta sen alkaessa
var idle_audio_ajastin = Timer.new() ## Ajastin idleäänelle
var kuolema_ajastin = Timer.new() ## Ajastin, että milloin vihollinen tappaa pelaajan
var nykyinen_alue = null ## Tällä hallitaan vihollisen nykyistä sijaintia
var light = preload("res://valo_character.tscn") ## Valon informaatio. Tarviiko tätä?

## Äänet, kopsattu toisesta vihollisesta
@onready var audio_paikoillaan = $AudioPaikoillaan
@onready var audio_jahtaus = $AudioJahtaus
@onready var audio_pakeneminen = $AudioPakeneminen
@onready var audio_pelaaja_kuolee = $AudioPelaajaKuolee
@onready var audio_kaivautuminen = $AudioKaivautuminen
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
	# Tällä tehdään alueiden vaihtelua
	nykyinen_alue = alue1
	# Signaalikäsittelyä
	idle_audio_ajastin.timeout.connect(_idle_audio_ajastimen_loppuessa)
	valon_tarkistus.connect("siirrytty_valoon", siirrytty_valoon)
	valon_tarkistus.connect("siirrytty_varjoon", siirrytty_varjoon)
	valon_tarkistus2.connect("siirrytty_valoon", siirrytty_valoon)
	valon_tarkistus2.connect("siirrytty_varjoon", siirrytty_varjoon)
	# Annetaan ajastimet lapsiksi
	self.add_child(kuolema_ajastin)
	self.add_child(idle_audio_ajastin)
	# Aloitetaan ajastin idle-ääniefektille
	aloita_idle_audio_ajastin()
	# Valon tarkistuksen käsittelyä
	if valon_tarkistus.on_valossa():
		siirrytty_valoon()
	else:
		siirrytty_varjoon()


## Delta kutsutaan joka framella, ei ehkä tarvita?
func _process(_delta):
	pass


## Kollektiivinen kuolema-funktio..
func kuolema():
	pelaaja_kuollut.emit() # ..joka lähettää signaalin Globaalille


## Kollektiivinen alueelle astumisen funktio, eli vihollinen huomaa pelaajan
func astuttu_alueelle(body):
	if body.is_in_group("Pelaaja"): # Otetaan pelaajan group
		# Pysäytetään mahdollinen idle-ääniefekti ja soitetaan vihollisen jahtaus-ääniefekti
		if audio_paikoillaan.is_playing():
			audio_paikoillaan.stop()
			idle_audio_ajastin.stop()
		# Jos jahtaus-ääniefekti on jo pyörimässä, ei tehdä mitään
		if not audio_jahtaus.is_playing():
			audio_jahtaus.play()
		var kuolema_aika = rng.randf_range(1.0, 5.0) # Tästä voi säätää ajan kantaman, missä pelaaja voi kuolla viholliseen
		kuolema_ajastin.start(kuolema_aika) # Aloitetaan jahti
		#audio_liikkuminen.play() # Kuuluu liikkumisen ääniä, voidaan laittaa myös eri kohtaan
		await kuolema_ajastin.timeout # Odotetaan, että vihu saa pelaajan kiinni
		#audio_liikkuminen.stop() # Ei kuulu enää liikkumisen ääniä
		audio_pelaaja_kuolee.play() # Tapetaan pelaaja erittäin raa'asti
		pelaaja = body # Varmistetaan vielä, että kyseessä on pelaaja
		kuolema() # Lopulta kuollaan


## Kollektiivinen alueelta poistumisen funktio
## TODO: tähän voisi lisäillä jotain hauskaa, jos tulee mieleen
func poistuttu_alueelta(_body):
	kuolema_ajastin.stop() # Pysäytetään ajastin, että pelaaja ei kuole, vaikka astuisi alueelta pois
	# Aloitetaan ajastin idle-ääniefektille, jos se on pois päältä
	if idle_audio_ajastin.is_stopped():
		aloita_idle_audio_ajastin()


## Idle audio ajastimen loppuessa soitetaan idle ääniefekti
func _idle_audio_ajastimen_loppuessa():
	if audio_paikoillaan.is_playing():
		# Jos samaa ääniefektiä soitetaan vielä, ei tehdä mitään
		return
	
	# Lopetetaan jahtausääniefektit, jos niitä soitetaan
	if audio_jahtaus.is_playing():
		audio_jahtaus.stop()
	
	audio_paikoillaan.play()


## Aloittaa ajastimen idle-ääniefektille
func aloita_idle_audio_ajastin():
	idle_audio_ajastin.start((1 - randf() * 0.5) * IDLE_AUDIO_AJASTIN_MAX)


## Alueelle astumisen funktio alueelle 1
func _on_alue_body_entered(body):
	# Tarkistetaan, että alue on nykyinen alue, tai ei ole, hirveästi ei ole väliä kummin päin
	# kunhan tarkistetaan siltä varalta, etteivät molemmat alueet katoa
	if nykyinen_alue.name != body.name:
		astuttu_alueelle(body)


## Alueelta poistumisen funktio alueelle 1
func _on_alue_body_exited(body):
	poistuttu_alueelta(body)


## Alueelle astumisen funktio alueelle 2
func _on_alue_2_body_entered(body):
	# Tarkistetaan, että alue on nykyinen alue, tai ei ole, hirveästi ei ole väliä kummin päin
	# kunhan tarkistetaan siltä varalta, etteivät molemmat alueet katoa
	if nykyinen_alue.name != body.name:
		astuttu_alueelle(body)


## Alueelta poistumisen funktio alueelle 2
func _on_alue_2_body_exited(body):
	poistuttu_alueelta(body)


## Jos vihollinen onkin valossa, vaikkapa valopallon heitosta
func siirrytty_valoon():
	vaihda_alue(nykyinen_alue) ## Vaihdetaan nykyinen alue toiseen


## Vaihdetaan aluetta, eli vihollinen liikkuu, jos päätyy valoon
func vaihda_alue(alue):
	audio_pakeneminen.play() # Pelästytään ja äännellään sen mukaisesti
	alue.process_mode = Node.PROCESS_MODE_DISABLED # Alue deaktivoituu..
	alue.visible = false # .. ja katoaa näkyvistä, eli vihollinen poistuu alueelta
	if alue == alue1: # Erotelmaa alueille
		nykyinen_alue = alue2 # Vaihdetaan aluetta
		alue2.process_mode = Node.PROCESS_MODE_INHERIT # Alue aktivoituu..
		alue2.visible = true # .. ja tulee näkyviin, eli vihollinen saapuu alueelle
	if alue == alue2: # Erotelmaa alueille
		nykyinen_alue = alue1 # Vaihdetaan aluetta
		alue1.process_mode = Node.PROCESS_MODE_INHERIT # Alue aktivoituu..
		alue1.visible = true # .. ja tulee näkyviin, eli vihollinen saapuu alueelle
	audio_kaivautuminen.play() # Kaivaudutaan pakoon ja maasta kuuluu hassu ääni


## Ei varmaan tarvita tätä ollenkaan
func siirrytty_varjoon():
	pass
