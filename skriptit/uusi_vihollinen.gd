## Harri 17.4.2024
## Vanhan vihollisen saa takaisin: noden Inspector - process - disabled -> inherit
## TÄRKEÄÄ: pidä nodejen järjestys aina samana kun instanssoit vihollisia, muuten koodi menee sekaisin
## Osaa:
## Tappaa pelaajan hänen ollessaan alueella liian kauan
## Vaihtaa alueesta toiseen, kun valonlähde osuu siihen
## Äännähdellä, kun siltä tuntuu
## TODO: voisi koittaa kehittää eteenpäin vaikkapa vielä useammalle alueelle, tai tehdä alueesta uusi scenensä
## TODO: alueen vaihto vähän kankea vielä, voisi viilata
## TODO: viholliset äännähtelevät liian kauas
## TODO: jotain pikku bugisuutta: vihollinen joskus ehkä huomaa valopallon seinän läpi,
## 		 kenties ohuet seinät tai liian läheiset oltavat toisen alueen kanssa on syynä
extends Node2D
class_name uusiVihollinen

## Ajastimet, muuttujat ja signaalit
signal pelaaja_kuollut ## Pelaajan kuoleman signaali Globaalille
var pelaaja = null ## Pelaaja, on alussa null
var rng = RandomNumberGenerator.new() ## Randomgeneraattori, käytetään ainakin vihollisen "nopeuteen" ja "sijaintiin"
const IDLE_AUDIO_AJASTIN_MAX = 15.0 ## Ajastin asetetaan satunnaisesti 50-100%:iin tästä arvosta sen alkaessa
var idle_audio_ajastin = Timer.new() ## Ajastin idleäänelle
var alueen_vaihto_ajastin = Timer.new() ## Ajastin vihollisen alueen vaihdolle
var kuolema_ajastin = Timer.new() ## Ajastin, että milloin vihollinen tappaa pelaajan
var light = preload("res://scenet/valo_character.tscn") ## Valon informaatio. Tarviiko tätä?

## Äänet, kopsattu toisesta vihollisesta
@onready var audio_paikoillaan = $AudioPaikoillaan
@onready var audio_jahtaus = $AudioJahtaus
@onready var audio_pakeneminen = $AudioPakeneminen
@onready var audio_pelaaja_kuolee = $AudioPelaajaKuolee
@onready var audio_kaivautuminen = $AudioKaivautuminen
## TODO: Soita ääni kun vihollinen liikkuu, mutta ei jahtaa tai pakene.
@onready var audio_liikkuminen = $AudioLiikkuminen

## Nodearrayt
@onready var uudetViholliset = Globaali.uudetViholliset


## Kun scene avataan, ready tapahtuu
func _ready():
	# Signaalikäsittelyä
	idle_audio_ajastin.timeout.connect(_idle_audio_ajastimen_loppuessa)
	alueen_vaihto_ajastin.timeout.connect(_alueen_vaihto_ajastimen_loppuessa)
	# Annetaan ajastimet lapsiksi
	self.add_child(kuolema_ajastin)
	self.add_child(idle_audio_ajastin)
	self.add_child(alueen_vaihto_ajastin)
	# Aloitetaan ajastin idle-ääniefektille
	aloita_idle_audio_ajastin()
	aloita_alueen_vaihto_ajastin()
	# Valon tarkistuksen käsittelyä
	# Iteroidaan koko tree läpi selfin kanssa
	# Tämä piti tehdä, että joka instanssi saa omat tarkistukset, muuten ne vaihtoivat paikkaa, jos toinen vihollinen vaihtoi paikkaa
	# TODO: Voisi tehdä siistimminkin, ja globaaliin voisi melkein tehdä oman funktion tekemään samaa
	for i in self.get_children():
		for j in i.get_children():
			for h in j.get_children():
				if h.is_in_group("newVihollinenValotarkistus"):
					h.connect("siirrytty_valoon", siirrytty_valoon)
					h.connect("siirrytty_varjoon", siirrytty_varjoon)
	# Asetetaan vakioalueeksi 1 (muokatkaa scenessä aina alue 1 (nodenimi "alue") siihen paikkaan, mistä vihollisen halutaan aloittavan
	aseta_alueet(self)


## Delta kutsutaan joka framella
func _process(_delta):
	# Kutsutaan globaalista uuden vihollisen aanen
	for vihollinen in uudetViholliset:
		Globaali.uuden_vihollisen_aanen_korkeus(vihollinen)


## Kollektiivinen kuolema-funktio ..
func kuolema():
	pelaaja_kuollut.emit() # ..joka lähettää signaalin Globaalille


## Kollektiivinen alueelle astumisen funktio, eli vihollinen huomaa pelaajan
func astuttu_alueelle(body):
	if body.is_in_group("Pelaaja"): # Otetaan pelaajan group
		# Pysäytetään mahdollinen idle-ääniefekti ja soitetaan vihollisen jahtaus-ääniefekti
		if audio_paikoillaan.is_playing():
			audio_paikoillaan.stop()
			idle_audio_ajastin.stop()
		if audio_kaivautuminen.is_playing():
			audio_kaivautuminen.stop()
		# Jos jahtaus-ääniefekti on jo pyörimässä, ei tehdä mitään
		if not audio_jahtaus.is_playing():
			audio_jahtaus.play()
		var kuolema_aika = rng.randf_range(1.0, 5.0) # Tästä voi säätää ajan kantaman, missä pelaaja voi kuolla viholliseen
		kuolema_ajastin.start(kuolema_aika) # Aloitetaan jahti
		print ("Kuolet viholliseen " + str(kuolema_aika) + " sekunnin jälkeen")
		#audio_liikkuminen.play() # Kuuluu liikkumisen ääniä, voidaan laittaa myös eri kohtaan
		await kuolema_ajastin.timeout # Odotetaan, että vihu saa pelaajan kiinni
		#audio_liikkuminen.stop() # Ei kuulu enää liikkumisen ääniä
		audio_pelaaja_kuolee.play() # Tapetaan pelaaja erittäin raa'asti
		pelaaja = body # Varmistetaan vielä, että kyseessä on pelaaja
		print ("Kuolit viholliseen")
		kuolema() # Lopulta kuollaan


## Kollektiivinen alueelta poistumisen funktio
## TODO: tähän voisi lisäillä jotain hauskaa, jos tulee mieleen
func poistuttu_alueelta(_body):
	print ("Turvassa viholliselta")
	kuolema_ajastin.stop() # Pysäytetään ajastin, että pelaaja ei kuole, vaikka astuisi alueelta pois
	# Aloitetaan ajastin idle-ääniefektille, jos se on pois päältä
	if idle_audio_ajastin.is_stopped():
		aloita_idle_audio_ajastin()
	if alueen_vaihto_ajastin.is_stopped():
		aloita_alueen_vaihto_ajastin()

func aloita_alueen_vaihto_ajastin():
	alueen_vaihto_ajastin.start(7)


## Kun ajastin sanoo, että vihollisen on aika vaihtaa aluetta
func _alueen_vaihto_ajastimen_loppuessa():
	if audio_kaivautuminen.is_playing():
		# Jos samaa ääniefektiä soitetaan vielä, ei tehdä mitään
		return
	audio_kaivautuminen.play()
	vaihda_alue(self)
	#await get_tree().create_timer(1.7).timeout # Annetaan animaation toistaa itseään jonkin aikaa


## Aloittaa ajastimen idle-ääniefektille
func aloita_idle_audio_ajastin():
	idle_audio_ajastin.start((1 - randf() * 0.5) * IDLE_AUDIO_AJASTIN_MAX)


## Idle audio ajastimen loppuessa soitetaan idle ääniefekti
func _idle_audio_ajastimen_loppuessa():
	if audio_paikoillaan.is_playing():
		# Jos samaa ääniefektiä soitetaan vielä, ei tehdä mitään
		return
	
	# Lopetetaan jahtausääniefektit, jos niitä soitetaan
	if audio_jahtaus.is_playing():
		audio_jahtaus.stop()
	
	audio_paikoillaan.play()
	#print_debug ("Vihollinen idlaa")


## Alueelle astumisen funktio alueelle 1
func _on_alue_body_entered(body):
	# Tarkistetaan, että alue on nykyinen alue, tai ei ole, hirveästi ei ole väliä kummin päin
	# kunhan tarkistetaan siltä varalta, etteivät molemmat alueet ole aktiivisia samaan aikaan
	if !body.is_in_group("nykyisetAlueet"):
		astuttu_alueelle(body)


## Alueelta poistumisen funktio alueelle 1
func _on_alue_body_exited(body):
	poistuttu_alueelta(body)


## Alueelle astumisen funktio alueelle 2
func _on_alue_2_body_entered(body):
	# Tarkistetaan, että alue on nykyinen alue, tai ei ole, hirveästi ei ole väliä kummin päin
	# kunhan tarkistetaan siltä varalta, etteivät molemmat alueet ole aktiivisia samaan aikaan
	if !body.is_in_group("nykyisetAlueet"):
		astuttu_alueelle(body)


## Alueelta poistumisen funktio alueelle 2
func _on_alue_2_body_exited(body):
	poistuttu_alueelta(body)


## Jos vihollinen onkin valossa, vaikkapa valopallon heitosta
func siirrytty_valoon():
	audio_pakeneminen.play() # Pelästytään ja äännellään sen mukaisesti
	vaihda_alue(self) # Vaihdetaan nykyinen alue toiseen
	audio_kaivautuminen.play() # Kaivaudutaan pakoon ja maasta kuuluu hassu ääni


## Asetetaan alueet niin, että alue 1 on aluksi visible, aktiivinen ja toiminnassa
func aseta_alueet(vihollinen):
	var alue1 = vihollinen.get_children()[0] # Otetaan aina alue 1 (nodena "alue") ensimmäiseksi vihollisen paikaksi
	alue1.add_to_group("nykyisetAlueet") # Tehdään siitä osa aktiivisten, eli vaarallisten alueiden ryhmää
	var alue2 = vihollinen.get_children()[2] # Ei-aktiivinen alue
	alue2.remove_from_group("nykyisetAlueet") # Varmistus
	alue2.visible = false # Alue 2 katoaa näkyvistä
	alue2.process_mode = Node.PROCESS_MODE_DISABLED # Alue 2 ei tee mitään


## Vaihdetaan aluetta, eli vihollinen liikkuu, jos päätyy valoon
func vaihda_alue(vihollinen):
	var alue1 = vihollinen.get_children()[0] # Otetaan alue 1
	var kuoppa1 = vihollinen.get_children()[1] # Otetaan alueen 1 kuoppa
	var alue2 = vihollinen.get_children()[2] # Otetaan alue 2
	var kuoppa2 = vihollinen.get_children()[3] # Otetaan alueen 1 kuoppa
	if alue1.is_in_group("nykyisetAlueet"): # Erotelmaa alueille
		print ("Vihollinen vaihtaa aluetta")
		aktivoiAlue(alue2)
		deaktivoiAlue(alue1)
		toistaAnimaatio(kuoppa1)
	else: # jos ei olekaan alue 1 kyseessä:
		if alue2.is_in_group("nykyisetAlueet"): # Erotelmaa alueille
			print ("Vihollinen vaihtaa aluetta")
			aktivoiAlue(alue1)
			deaktivoiAlue(alue2)
			toistaAnimaatio(kuoppa2)


## Toistetaan kuopan animaatio
func toistaAnimaatio(kuoppa):
	var animaatio = kuoppa.get_children()[0] # Otetaan kuopan animaatio
	animaatio.play("kaivautuminen") # Toistetaan animaatio
	await get_tree().create_timer(5).timeout # Annetaan animaation toistaa itseään jonkin aikaa
	animaatio.stop() # Pysäytetään animaatio


## Aktivoidaan saatu alue
func aktivoiAlue(alue):
	alue.process_mode = Node.PROCESS_MODE_INHERIT # Toinen alue tekee saa toiminnallisuuden ..
	alue.visible = true # .. ja tulee näkyviin testauksen havainnollistamiseksi ..
	alue.add_to_group("nykyisetAlueet") # .. ja tulee aktiiviseksi, eli on vaarallinen


## Deaktivoidaan saatu alue
func deaktivoiAlue(alue):
	alue.remove_from_group("nykyisetAlueet") # Valoon joutunut vihollinen ei ole aktiivinen ..
	alue.visible = false # .. ja katoaa näkyvistä testauksen havainnollistamiseksi..
	alue.process_mode = Node.PROCESS_MODE_DISABLED # .. ja alue menettää toiminnallisuutensa


## Haetaan parametrin noden vihollisen nykyinen, eli aktiivinen alue
## Ei tällä hetkellä varsinaisessa käytössä, mutta voi olla hyödyllinen jatkoa testauksessa ja jatkoa ajatellen
func haeNykyinenAlue(vihollinen):
	for i in vihollinen.get_children():
		if i.is_in_group("nykyisetAlueet"):
			return i


## Ei varmaan tarvita tätä ollenkaan
func siirrytty_varjoon():
	pass
