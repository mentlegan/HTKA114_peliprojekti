## Harri 30.5.2024
## Elias 22.4.2024 äänenkorkeuden muutos
## Elias 6.5.2024 äänilähteen vaihtuminen aktiivisen alueen mukaan
## Vanhan vihollisen saa takaisin: noden Inspector - process - disabled -> inherit
## TÄRKEÄÄ: pidä nodejen järjestys aina samana kun instanssoit vihollisia, muuten koodi menee sekaisin
## Osaa:
## Tappaa pelaajan hänen ollessaan alueella liian kauan
## Vaihtaa alueesta toiseen, kun valonlähde osuu siihen, tai spontaanisti patrollata
## Äännähdellä, kun siltä tuntuu
## TODO: alueen vaihto valossa vähän kankea vielä, voisi koittaa viilata
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
@onready var audio_paikoillaan = $AudioStreamPlayerContainer/AudioPaikoillaan
@onready var audio_jahtaus = $AudioStreamPlayerContainer/AudioJahtaus
@onready var audio_pakeneminen = $AudioStreamPlayerContainer/AudioPakeneminen
@onready var audio_pelaaja_kuolee_viholliselle = $AudioStreamPlayerContainer/AudioPelaajaKuoleeViholliselle
@onready var audio_kaivautuminen = $AudioStreamPlayerContainer/AudioKaivautuminen
## TODO: Soita ääni kun vihollinen liikkuu, mutta ei jahtaa tai pakene.
@onready var audio_liikkuminen = $AudioStreamPlayerContainer/AudioLiikkuminen
## Node2D, joka määrittää mistä äänet toistetaan ja alueet, joista toinen on aktiivinen
var audio_stream_player_container
var alue1
var alue2
var alue3

## Kerroin jolla voi muuttaa kuinka nopeasti vihollisen äänenkorkeus muuttuu
## VAROITUS: Voi hajota jos arvo on suurempi kuin 1. Tällöin toteutusta täytyy vähän muuttaa.
var aanenkorkeuden_muutosnopeus = 0.6

## Nodearrayt
var uudetViholliset


## Kun scene avataan, ready tapahtuu
func _ready():
	await Globaali.maailma.ready
	uudetViholliset = Globaali.maailma.uudetViholliset

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
	# Asetetaan vakioalueeksi 1 (muokatkaa scenessä aina alue 1 (nodenimi "alue") siihen paikkaan, mistä vihollisen halutaan aloittavan
	audio_stream_player_container = $AudioStreamPlayerContainer
	alue1 = $alue
	alue2 = $alue2
	alue3 = $alue3
	aseta_alueet(self)
	audio_stream_player_container.global_position = alue1.global_position


## Delta kutsutaan joka framella
func _process(_delta):
	await Globaali.maailma.ready
	# Tarkistetaan ja muutetaan vihollisen äänenkorkeutta sen mukaan onko vihollinen
	# pelaajan ylä- vai alapuolella
	muuta_aanenkorkeutta()


## Kollektiivinen kuolema-funktio ..
func kuolema():
	Globaali.maailma.kuoltiinko_viholliseen = true
	pelaaja_kuollut.emit() # ..joka lähettää signaalin Globaalille


## Kollektiivinen alueelle astumisen funktio, eli vihollinen huomaa pelaajan
func astuttu_alueelle(body):
	if body.is_in_group("Pelaaja"): # Otetaan pelaajan group
		if Globaali.maailma.vaikeusaste == 3: # Ultra Hardilla kuollaan saman tien
			kuolema()
			return
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
		if Globaali.maailma.vaikeusaste == 0: # Jos peli on easy-vaikeusasteessa
			kuolema_aika = rng.randf_range(1.5, 8.0)
		if Globaali.maailma.vaikeusaste == 2: # Jos peli on hard- vaikeusasteella
			kuolema_aika = rng.randf_range(0.75, 3.0)
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


## Alueelle astumisen funktio alueelle 3
func _on_alue_3_body_entered(body):
	# Tarkistetaan, että alue on nykyinen alue, tai ei ole, hirveästi ei ole väliä kummin päin
	# kunhan tarkistetaan siltä varalta, etteivät molemmat alueet ole aktiivisia samaan aikaan
	if !body.is_in_group("nykyisetAlueet"):
		astuttu_alueelle(body)


## Alueelta poistumisen funktio alueelle 3
func _on_alue_3_body_exited(body):
	poistuttu_alueelta(body)


## Jos vihollinen onkin valossa, vaikkapa valopallon heitosta
func siirrytty_valoon():
	audio_pakeneminen.play() # Pelästytään ja äännellään sen mukaisesti
	vaihda_alue(self) # Vaihdetaan nykyinen alue toiseen
	audio_kaivautuminen.play() # Kaivaudutaan pakoon ja maasta kuuluu hassu ääni


## Asetetaan alueet niin, että alue 1 on aluksi visible, aktiivinen ja toiminnassa
func aseta_alueet(_vihollinen):
	# Otetaan aina alue 1 (nodena "alue") ensimmäiseksi vihollisen paikaksi
	alue1.add_to_group("nykyisetAlueet") # Tehdään siitä osa aktiivisten, eli vaarallisten alueiden ryhmää
	#etsi_lahin_kukka(alue1) # Etsitään alueen lähin kukka
	# Alue2 on Ei-aktiivinen alue
	alue2.remove_from_group("nykyisetAlueet") # Varmistus
	alue2.visible = false # Alue 2 katoaa näkyvistä
	alue2.process_mode = Node.PROCESS_MODE_DISABLED # Alue 2 ei tee mitään
	alue3.remove_from_group("nykyisetAlueet") # Tehdään samat toimenpiteet alueelle 3
	alue3.visible = false
	alue3.process_mode = Node.PROCESS_MODE_DISABLED


## Vaihdetaan aluetta, eli vihollinen liikkuu, jos päätyy valoon, tai haluaa muuten liikkua
func vaihda_alue(vihollinen):
	var kuoppa1 = vihollinen.get_children()[1] # Otetaan alueen 1 kuoppa
	var kuoppa2 = vihollinen.get_children()[3] # Otetaan alueen 2 kuoppa
	var kuoppa3 = vihollinen.get_children()[5] # Otetaan alueen 3 kuoppa
	var alueet = [alue1,alue2,alue3] # Otetaan vihollisen alueet
	
	# Iteroidaan alueet läpi käsittelyä varten
	for i in alueet:
		if i.is_in_group("nykyisetAlueet"): # Jos havaitaan nykyinen aktiivinen alue
			deaktivoi_alue(i) # Se deaktivoidaan..
			alueet.erase(i) # .. ja poistetaan hetkeksi
			aktivoi_alue(alueet.pick_random()) # Koska haluamme randomin kahdesta alueesta, emme kolmesta
			alueet.append(i) # Alue takaisin muiden joukkoon
			# Kuoppien käsittelyä. TODO: Voisi tehdä vaikka silmukalla, tai laittamalla kuopat alueiden lapsiksi
			if i == alue1:
				toista_animaatio(kuoppa1)
			if i == alue2:
				toista_animaatio(kuoppa2)
			if i == alue3:
				toista_animaatio(kuoppa3)
			break
	
	# Pidetään seuraavat rivit, jos jotain menee pahasti rikki
	#if alue1.is_in_group("nykyisetAlueet"): # Erotelmaa alueille
	#	print ("Vihollinen vaihtaa alueelle " + str(alue2))
	#	aktivoi_alue(alue2)
	#	#etsi_lahin_kukka(alue2)
	#	deaktivoi_alue(alue1)
	#	toista_animaatio(kuoppa1)
	#else: # jos ei olekaan alue 1 kyseessä:
	#	if alue2.is_in_group("nykyisetAlueet"): # Erotelmaa alueille
	#		print ("Vihollinen vaihtaa alueelle " + str(alue1.name))
	#		aktivoi_alue(alue1)
	#		#etsi_lahin_kukka(alue1)
	#		deaktivoi_alue(alue2)
	#		toista_animaatio(kuoppa2)


## Toistetaan kuopan animaatio
func toista_animaatio(kuoppa):
	var animaatio = kuoppa.get_children()[0] # Otetaan kuopan animaatio
	animaatio.play("kaivautuminen") # Toistetaan animaatio
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 4.0
	timer.timeout.connect(func(): 
		timer.queue_free()
		animaatio.stop())
	timer.start()
	# await get_tree().create_timer(5).timeout # Annetaan animaation toistaa itseään jonkin aikaa


## Aktivoidaan saatu alue
func aktivoi_alue(alue):
	print ("Vihollinen vaihtaa alueelle " + str(alue.name))
	alue.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT) # Toinen alue saa toiminnallisuuden ..
	alue.visible = true # .. ja tulee näkyviin testauksen havainnollistamiseksi ..
	alue.add_to_group("nykyisetAlueet") # .. ja tulee aktiiviseksi, eli on vaarallinen
	audio_stream_player_container.global_position = alue.global_position


## Deaktivoidaan saatu alue
func deaktivoi_alue(alue):
	alue.remove_from_group("nykyisetAlueet") # Valoon joutunut vihollinen ei ole aktiivinen ..
	alue.visible = false # .. ja katoaa näkyvistä testauksen havainnollistamiseksi..
	alue.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED) # .. ja alue menettää toiminnallisuutensa


## Haetaan parametrin noden vihollisen nykyinen, eli aktiivinen alue
## Ei tällä hetkellä varsinaisessa käytössä, mutta voi olla hyödyllinen jatkoa testauksessa ja jatkoa ajatellen
func haeNykyinenAlue(vihollinen):
	for i in vihollinen.get_children():
		if i.is_in_group("nykyisetAlueet"):
			return i


## Haetaan alueen lähin kukka
func etsi_lahin_kukka(alue) -> Node2D:
	var lahinKukka
	var minimi = Globaali.maailma.kukat[0].position - alue.position
	for i in Globaali.maailma.kukat:
		var etaisyys = i.position - alue.position
		if etaisyys < minimi:
			minimi = etaisyys
			lahinKukka = i
	#print("Alueen " + str(alue.name) + "lahin kukka on " + str(lahinKukka))
	return lahinKukka


## Tarkistaa pelaajan ja vihollisen y-koordinaatit ja muuttaa vihollisen äänenkorkeutta.
## Jos vihollinen on pelaajan yläpuolella, ääni on korkeampi ja jos alapuolella ääni on matalampi.
func muuta_aanenkorkeutta():
	var aanenkorkeuden_kerroin = 1
	var pelaaja_y = Globaali.maailma.pelaaja.get_global_position().y
	var vihollinen_y = self.get_global_position().y
	# Tason collision shapen korkeus:
	var y_vaihteluvali = Globaali.nykyisen_tason_collision_shape(self).size.y
	var korkeuksien_erotus = pelaaja_y - vihollinen_y
	# Skaalataan y-koordinaattien erotus välille [0, 2] niin että 1 on sama korkeus
	aanenkorkeuden_kerroin = (korkeuksien_erotus / y_vaihteluvali) + 1
	# Vihollinen -äänikanavan pitch shift efekti
	# Nyt toimii vaikka audioväylien järjestystä muuttaisi.
	# Efektien järjestyksen muuttaminen rikkoo tämän.
	var bus_index = AudioServer.get_bus_index("Vihollinen")
	var vihollinen_pitch_shift = AudioServer.get_bus_effect(bus_index, 0)
	var aanenkorkeuden_kerroin_final = aanenkorkeuden_kerroin * aanenkorkeuden_muutosnopeus
	# Varmistetaan että pitch_scale > 0
	if (aanenkorkeuden_kerroin_final < 0.1):
		aanenkorkeuden_kerroin_final = 0.1
	vihollinen_pitch_shift.pitch_scale = aanenkorkeuden_kerroin_final


## Ei varmaan tarvita tätä ollenkaan, mutta pidetään täällä, jos löytyy käyttöä
func siirrytty_varjoon():
	pass


## Valon tarkistuksen signaalien käsittelijät

func _on_valon_tarkistus_area_entered(body):
	if body.is_in_group("valonlahde"):
		siirrytty_valoon()


func _on_valon_tarkistus_2_area_entered(body):
	if body.is_in_group("valonlahde"):
		siirrytty_valoon()


func _on_valon_tarkistus_3_area_entered(body):
	if body.is_in_group("valonlahde"):
		siirrytty_valoon()
