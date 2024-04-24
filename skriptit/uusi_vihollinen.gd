## Harri 24.4.2024
## Elias 22.4.2024 äänenkorkeuden muutos
## Vanhan vihollisen saa takaisin: noden Inspector - process - disabled -> inherit
## TÄRKEÄÄ: pidä nodejen järjestys aina samana kun instanssoit vihollisia, muuten koodi menee sekaisin
## Osaa:
## Tappaa pelaajan hänen ollessaan alueella liian kauan
## Vaihtaa alueesta toiseen, kun valonlähde osuu siihen, tai spontaanisti patrollata
## Äännähdellä, kun siltä tuntuu
## TODO: voisi koittaa kehittää eteenpäin vaikkapa vielä useammalle alueelle, tai tehdä alueesta uusi scenensä
## TODO: alueen vaihto valossa vähän kankea vielä, voisi koittaa viilata
## TODO: jotain pikku bugisuutta: vihollinen joskus ehkä huomaa valopallon seinän läpi,
## 		 kenties ohuet seinät tai liian läheiset oltavat toisten alueiden kanssa on syynä
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
@onready var audio_pelaaja_kuolee_viholliselle = $AudioPelaajaKuoleeViholliselle
@onready var audio_kaivautuminen = $AudioKaivautuminen
## TODO: Soita ääni kun vihollinen liikkuu, mutta ei jahtaa tai pakene.
@onready var audio_liikkuminen = $AudioLiikkuminen

## Kerroin jolla voi muuttaa kuinka nopeasti vihollisen äänenkorkeus muuttuu
## VAROITUS: Voi hajota jos arvo on suurempi kuin 1. Tällöin toteutusta täytyy vähän muuttaa.
var aanenkorkeuden_muutosnopeus = 0.8

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
			if j.is_in_group("newVihollinenValotarkistus"):
				j.connect("siirrytty_valoon", siirrytty_valoon)
				j.connect("siirrytty_varjoon", siirrytty_varjoon)
				#for h in j.get_children():
					#h.connect("siirrytty_valoon", siirrytty_valoon)
					#h.connect("siirrytty_varjoon", siirrytty_varjoon)
	# Asetetaan vakioalueeksi 1 (muokatkaa scenessä aina alue 1 (nodenimi "alue") siihen paikkaan, mistä vihollisen halutaan aloittavan
	aseta_alueet(self)


## Delta kutsutaan joka framella
func _process(_delta):
	# Tarkistetaan ja muutetaan vihollisen äänenkorkeutta sen mukaan onko vihollinen
	# pelaajan ylä- vai alapuolella
	muuta_aanenkorkeutta()
	for i in self.get_children():
		for j in i.get_children():
			if j.is_in_group("newVihollinenValotarkistus"):
				if j.on_valossa():
					siirrytty_valoon()
				else:
					siirrytty_varjoon()


## Kollektiivinen kuolema-funktio ..
func kuolema():
	pelaaja_kuollut.emit() # ..joka lähettää signaalin Globaalille


## Kollektiivinen alueelle astumisen funktio, eli vihollinen huomaa pelaajan
func astuttu_alueelle(body):
	if body.is_in_group("Pelaaja"): # Otetaan pelaajan group
		alueen_vaihto_ajastin.stop() # Pysäytetään ajastin, ettei vihollinen vaihda aluetta pelaajan ollessa siellä ..
		idle_audio_ajastin.stop() # .. tai ääntele idlenä
		# Äänten säätöä
		if audio_paikoillaan.is_playing():
			audio_paikoillaan.stop()
		if audio_kaivautuminen.is_playing():
			audio_kaivautuminen.stop()
		if not audio_jahtaus.is_playing():
			audio_jahtaus.play()
			audio_liikkuminen.play()
		var kuolema_aika = rng.randf_range(1.0, 4.0) # Tästä voi säätää ajan kantaman, missä pelaaja voi kuolla viholliseen
		kuolema_ajastin.start(kuolema_aika) # Aloitetaan jahti
		print ("Kuolet viholliseen " + str(kuolema_aika) + " sekunnin jalkeen")
		await kuolema_ajastin.timeout # Odotetaan, että vihu saa pelaajan kiinni
		audio_pelaaja_kuolee_viholliselle.play() # Tapetaan pelaaja erittäin raa'asti
		pelaaja = body # Varmistetaan vielä, että kyseessä on pelaaja
		print ("Kuolit viholliseen") # Dokumentaatio kuolemasta, olisi hyvä, että muillakin kuolintavoilla olisi moinen
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
	if audio_liikkuminen.is_playing():
		audio_liikkuminen.stop()


## Aloittaa alueen vaihtavan ajastimen
func aloita_alueen_vaihto_ajastin():
	#var vaihto_aika = 1 # Testiä varten
	var vaihto_aika = rng.randf_range(15, 30) # Otetaan random-numero näiden kahden väliltä
	alueen_vaihto_ajastin.start(vaihto_aika)


## Kun ajastin sanoo, että vihollisen on aika vaihtaa aluetta
func _alueen_vaihto_ajastimen_loppuessa():
	if audio_kaivautuminen.is_playing():
		# Jos samaa ääniefektiä soitetaan vielä, ei tehdä mitään
		return
	audio_kaivautuminen.play()
	vaihda_alue(self)


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
		aktivoi_alue(alue2)
		deaktivoi_alue(alue1)
		toista_animaatio(kuoppa1)
	else: # jos ei olekaan alue 1 kyseessä:
		if alue2.is_in_group("nykyisetAlueet"): # Erotelmaa alueille
			print ("Vihollinen vaihtaa aluetta")
			aktivoi_alue(alue1)
			deaktivoi_alue(alue2)
			toista_animaatio(kuoppa2)


## Toistetaan kuopan animaatio
func toista_animaatio(kuoppa):
	var animaatio = kuoppa.get_children()[0] # Otetaan kuopan animaatio
	animaatio.play("kaivautuminen") # Toistetaan animaatio
	await get_tree().create_timer(5).timeout # Annetaan animaation toistaa itseään jonkin aikaa
	animaatio.stop() # Pysäytetään animaatio


## Aktivoidaan saatu alue
func aktivoi_alue(alue):
	alue.process_mode = Node.PROCESS_MODE_INHERIT # Toinen alue saa toiminnallisuuden ..
	alue.visible = true # .. ja tulee näkyviin testauksen havainnollistamiseksi ..
	alue.add_to_group("nykyisetAlueet") # .. ja tulee aktiiviseksi, eli on vaarallinen


## Deaktivoidaan saatu alue
func deaktivoi_alue(alue):
	alue.remove_from_group("nykyisetAlueet") # Valoon joutunut vihollinen ei ole aktiivinen ..
	alue.visible = false # .. ja katoaa näkyvistä testauksen havainnollistamiseksi..
	alue.process_mode = Node.PROCESS_MODE_DISABLED # .. ja alue menettää toiminnallisuutensa


## Haetaan parametrin noden vihollisen nykyinen, eli aktiivinen alue
## Ei tällä hetkellä varsinaisessa käytössä, mutta voi olla hyödyllinen jatkoa testauksessa ja jatkoa ajatellen
func haeNykyinenAlue(vihollinen):
	for i in vihollinen.get_children():
		if i.is_in_group("nykyisetAlueet"):
			return i


## Tarkistaa pelaajan ja vihollisen y-koordinaatit ja muuttaa vihollisen äänenkorkeutta.
## Jos vihollinen on pelaajan yläpuolella, ääni on korkeampi ja jos alapuolella ääni on matalampi.
func muuta_aanenkorkeutta():
	var aanenkorkeuden_kerroin = 1
	var pelaaja_y = Globaali.pelaaja.get_global_position().y
	var vihollinen_y = self.get_global_position().y
	# Tason collision shapen korkeus:
	var y_vaihteluvali = Globaali.nykyisen_tason_collision_shape(self).size.y
	var korkeuksien_erotus = pelaaja_y - vihollinen_y
	# Skaalataan y-koordinaattien erotus välille [0, 2] niin että 1 on sama korkeus
	aanenkorkeuden_kerroin = (korkeuksien_erotus / y_vaihteluvali) + 1
	# Vihollinen -äänikanavan pitch shift efekti
	# VAROITUS: Hajoaa jos äänikanavien tai efektien järjestystä muuttaa!!!
	var vihollinen_pitch_shift = AudioServer.get_bus_effect(1, 0)
	vihollinen_pitch_shift.pitch_scale = aanenkorkeuden_kerroin * aanenkorkeuden_muutosnopeus


## Ei varmaan tarvita tätä ollenkaan, mutta pidetään täällä, jos löytyy käyttöä
func siirrytty_varjoon():
	pass


func _on_valon_tarkistus_area_entered(body):
	if body.is_in_group("valonlahde"):
		siirrytty_valoon()


func _on_valon_tarkistus_2_area_entered(body):
	if body.is_in_group("valonlahde"):
		siirrytty_valoon()
