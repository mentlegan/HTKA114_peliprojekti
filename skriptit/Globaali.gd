## Harri 11.3.2025
## Paavo 22.4.2024
## Elias 22.4.2024
## Tämä on yleinen, koko pelin kattava globaali scripti, johon voi lisätä funktioita käytettäväksi muissa scripteissä
## TODO: pelaajan kuolema-animaation voi kenties siirtää pelaajan scriptiin, jos sen saa toimimaan siellä:
## tehty tänne toistaiseksi Fall damage-kuoleman takia
extends Node2D

# Pelin tallennustiedosto
# Sijainti: %APPDATA%\Godot\app_userdata\Beneath the Mines\save_file_[maailma].json
const TALLENNUSTIEDOSTO = "user://save_file"

# Pelin maailma-scenejen kansio
const MAAILMASCENE_KANSIO = "res://scenet/maailmat"

## Maailma-node, sisältää aiemmin Globaali.gd:ssä olleet muuttujat.
## Aiemman Globaali.muuttujan_nimi formaatin sijaan käytetään nyt Globaali.maailma.muuttujan_nimi.
## Uudet globaalit muuttujat on siis laitettava maailma.gd-skriptiin Globaali.gd:n sijaan.
##
## Aiempi formaatti Globaali.muuttujan_nimi olisi ollut mahdollista pitää käytössä, mutta
## se olisi johtanut kahteen maailma.gd:n kokoiseen koodipätkään Globaalissa.
## Muuttujille olisi pitänyt kirjoittaa erillinen alustusfunktio scenen vaihtamista varten,
## nykyinen toteutus hoitaa tämän automaattisesti Maailma-noden luomisen yhteydessä.
## TODO: heittää erroria, voiko alustaa vasta myöhemmin?
@onready var maailma = get_node("/root/Maailma")

## Taulukko, joka sisältää tallennustiedoston sisällön Latausnapin painamisen jälkeen
var tallennetut_nodet = []
## Nykyisen maailma-scenen tiedostonimi ilman .tscn-tiedostopäätettä
var nykyinen_scene = "maailma"

## Alustusfunktio, jota Maailma-node kutsuu sceneen astuessa
## TODO: Lisää esimerkiksi tausta tekstuurit uudelleen aina sceneä vaihtaessa, näiden korjaus
func init():
	# Signaalikäsittelyä mm. pelaajan kuolemisesta
	maailma.pelaaja = get_tree().get_first_node_in_group("Pelaaja") # Otetaan pelaaja groupistaan
	maailma.pelaaja.kuollut.connect(_game_over) # Yhdistetään signaali pelaajasta
	
	# Signaali creditsien näyttämisestä
	maailma.credits = get_tree().get_first_node_in_group("Credits")
	maailma.credits.show_credits.connect(_show_credits)
	
	# Yhdistetään kuolema kaikkiin uusiin vihollisiin
	for uusiVihu in maailma.uudetViholliset:
		if uusiVihu != null:
			uusiVihu.pelaaja_kuollut.connect(_game_over)
	
	# Otetaan aloitus koordinaatit talteen
	maailma.pelaaja_aloitus = maailma.pelaaja.global_position
	
	# Lisätään sceneen tausta
	var tausta_n = maailma.tausta.instantiate()
	#tausta_node.z_index = -10
	# Tallennetaan muuttujaan
	maailma.tausta_node = tausta_n
	self.add_child(maailma.tausta_node)
	
	# Vesialueen tausta
	var tausta2_n = maailma.tausta2.instantiate()
	tausta2_n.hide()
	# Tallenetaan muuttujaan
	maailma.tausta2_node = tausta2_n
	self.add_child(tausta2_n)
	
	# Lisätään UI-ajastin
	self.add_child(maailma.ui_ajastin)
	maailma.ui_ajastin.set_one_shot(true)
	maailma.ui_ajastin.timeout.connect(aseta_ui_nakyvaksi)
	
	# Täytetään tasot- ja valot-taulukko
	lisaa_tasot()
	lisaa_valot_ja_indikaattorit()
	
	# Haetaan pelin kaikki tooltip-nodet.
	lisaa_tooltipit()
	vaihda_tooltip_ui(true)
	
	# Alustetaan köynnösovet
	alusta_koynnosovet()
	
	maailma.kuoltiinko_viholliseen = false # Tällä katsotaan, että kuoltiinko viholliseen tai pimeyteen
	
	# Journal pois näkyvistä
	maailma.journal.visible = false
	
	# Palautetaan tallennettujen nodejen muuttujat
	for tallennettu_node in tallennetut_nodet:
		var node = get_node(tallennettu_node["polku"])
		lataa_node(node, tallennettu_node)
	
	# Soitetaan alkuanimatic, jos peliä ei olla vielä tallennettu
	if not maailma.alkuanimatic_nahty:
		pass
		#soita_animatic() # Tästä saa animaticin takaisin
	else:
		get_tree().paused = false
		soita_musiikki()


## Kuunnellaan scenen vaihto ja kuolema
func _input(_event: InputEvent) -> void:
	## TODO: nämä voisi ehkä siirtää teleport menuun
	# 0
	if Input.is_action_just_pressed("vaihda_scene"):
		vaihda_scene("maailma_test")
	# ctrl + K
	elif Input.is_action_just_pressed("kuolema"):
		maailma.pelaaja.kuolema()
	
	# Pelin keskeytys
	# PC ESCAPE
	# PS4/PS5 OPTIONS
	elif Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			pausePeli()
			# Asetetaan inputti "syödyksi", sitä ei käsitellä enää missään muualla
			# Esim. pause-menun skriptissä, jossa pelin jatkuminen
			get_viewport().set_input_as_handled()


## Palauttaa noden muuttujat vastaamaan annettua dataa.
## Kutsuu samalla noden lataa-funktiota, jos sellainen on olemassa.
func lataa_node(node, data):
	print_debug(node.name, data)
	for key in data:
		if key == "polku":
			continue

		if node[key] is Vector2:
			node[key].x = data[key][0]
			node[key].y = data[key][1]
		else:
			node[key] = data[key]

	if node.has_method("lataa"):
		node.call("lataa")


## Antaa tiedon animaticin scriptille, että halutaanko alkuanimaticin soivan
func soita_animatic():
	maailma.soitetaan_animatic = true # Tämä bool sanoo Animaticin scriptille, että alkuanimatic todella soitetaan
	get_tree().paused = true # Peli pauselle
	maailma.animatic.visible = true # Animaticin interface ja kuvat näkyviin


func soita_tutorial_cutscene():
	maailma.soitetaan_tutorial_cutscene = true
	maailma.tutorial_cutscene.visible = true
	maailma.tutorial_cutscene.soita_animaatio()
	get_tree().paused = true # Peli pauselle


## Soittaa musiikkia
func soita_musiikki():
	maailma.musiikki.play()


## Poistaa minecart-tooltipit
func poista_minecart_tooltipit():
	for tooltip in maailma.tooltipit:
		if tooltip.get_name().contains("Minecart"):
			tooltip.visible = false
			tooltip.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)


## Hakee pelin kaikki tooltip-nodet ja lisää ne omaan taulukkoon
func lisaa_tooltipit():
	for lapsi in maailma.tooltip_node.get_children():
		if lapsi is Tooltip:
			maailma.tooltipit.append(lapsi)


## Vaihtaa pelin kaikkien tooltippien UI:t vastaamaan annettua ohjainta.
func vaihda_tooltip_ui(nappaimisto):
	for tooltip in maailma.tooltipit:
		tooltip.vaihda_ui(nappaimisto)


## Asettaa pelin jokaisen köynnösoven valon näkyvyyden
func aseta_valojen_vakyvyys(nakyvyys):
	for valo in maailma.ovien_valot:
		valo.visible = nakyvyys


## Lisää Koynnosovet-noden jokaiselle lapsenlapselle valot ja indikaattorit
func lisaa_valot_ja_indikaattorit():
	for lapsi in maailma.koynnosovet.get_children():
		for lapsenlapsi in lapsi.get_children():
			# Valot
			var valo = maailma.OVEN_VALO.instantiate()
			valo.global_position = lapsenlapsi.global_position
			valo.visible = false
			lapsi.add_child(valo)
			maailma.ovien_valot.append(valo)
	
			# Indikaattorit
			var indikaattori = maailma.OVEN_INDIKAATTORI.instantiate()
			indikaattori.global_position = lapsenlapsi.global_position
	
			if lapsenlapsi.is_in_group("x"):
				indikaattori.texture = maailma.OVEN_INDIKAATTORI_PUNAINEN
			elif lapsenlapsi.is_in_group("y"):
				indikaattori.texture = maailma.OVEN_INDIKAATTORI_LILA
			elif lapsenlapsi.is_in_group("z"):
				indikaattori.texture = maailma.OVEN_INDIKAATTORI_SININEN
	
			lapsi.add_child(indikaattori)
			maailma.ovien_indikaattorit.append(indikaattori)


## Asettaa pelaajan UI:n takaisin näkyväksi ja (TODO) piilottaa ovet
## Palauttaa samalla aktiivisen kameran pelaajalle
func aseta_ui_nakyvaksi():
	maailma.pelaaja.aseta_ui_nakyvyys(true)
	aseta_valojen_vakyvyys(false)


## Lisää Tasot-noden CollisionShape2D- ja Camera2D-nodet taulukkoon.
func lisaa_tasot():
	for lapsi in maailma.tasot_node.get_children():
		if lapsi is CollisionShape2D:
			# Etsitään kamera nykyisen lapsen lapsista
			var kamera = null
			for lapsenlapsi in lapsi.get_children():
				if lapsenlapsi is Camera2D:
					kamera = lapsenlapsi
	
			if kamera != null:
				maailma.tasot.append({
					"rect": Rect2(
						lapsi.global_position - lapsi.get_shape().get_rect().size * 0.5,
						lapsi.get_shape().get_rect().size
					),
					"kamera": kamera
				})


## Lisätään viholliset oikein
func lisaa_viholliset():
	for i in maailma.uudetViholliset.size(): # Otetaan viholliset niiden arrayn koon mukaan
		if samassa_tasossa_kuin_pelaaja(maailma.uudetViholliset[i]): # Jos pelaaja on samassa tasossa kuin vihollinen ..
			maailma.uudetViholliset[i].set_deferred("process_mode", Node.PROCESS_MODE_INHERIT) # ..vihollinen on toiminnassa
		else: # Jos ei ole ..
			maailma.uudetViholliset[i].set_deferred("process_mode", Node.PROCESS_MODE_DISABLED) # .. vihollinen ei ole toiminnassa


## Palauttaa totuusarvon siitä, onko pelaaja samassa tasossa kuin annettu node
func samassa_tasossa_kuin_pelaaja(node: Node):
	for taso in maailma.tasot:
		if (taso["rect"].has_point(node.global_position)
		and taso["rect"].has_point(maailma.pelaaja.global_position)):
			return true
	return false


## Palauttaa annetun noden nykyisen tason Rect2-noden.
## Jos annettu node ei ole minkään tason sisällä, palauttaa uuden Rect2-noden.
func nykyisen_tason_collision_shape(node: Node) -> Rect2:
	for taso in maailma.tasot:
		if taso["rect"].has_point(node.global_position):
			return taso["rect"]
	return Rect2()


## Näyttää ovet tasosta, johon annetut koordinaatit sijoittuvat
## Samalla tehdään resonointipartikkelit
func nayta_tason_ovet_ja_resonoi(_ovi_vaikutettu):
	var koordinaatit = _ovi_vaikutettu.global_position
	for taso in maailma.tasot:
		if taso["rect"].has_point(koordinaatit) and maailma.pelaaja.kamera.is_current():
			taso["kamera"].aktivoi(maailma.pelaaja)
			maailma.pelaaja.aseta_ui_nakyvyys(false)
			aseta_valojen_vakyvyys(true)
			aseta_indikaattorit_nakyviin(taso["rect"])
			maailma.audio_oven_resonanssi.play()
			return


## Asettaa ovien indikaattorit näkyviin annetusta tasosta
func aseta_indikaattorit_nakyviin(rect: Rect2):
	for indikaattori in maailma.ovien_indikaattorit:
		if rect.has_point(indikaattori.global_position):
			indikaattori.aloita()


func alusta_koynnosovet():
	# Resetoidaan köynnösovet kuolemisen jälkeen
	# Käytetään myös ennen pelin alkua kerran _ready()
	# Asetetaan animationspritejen framet oikeiksi
	for lapsi in maailma.koynnosovet.get_children():
		for lapsenlapsi in lapsi.get_children():
			# Katsotaan ettei ole indikaattoriin liittyvä
			if lapsenlapsi is not PointLight2D and lapsenlapsi is not CPUParticles2D:
				var ovi_todellinen = lapsenlapsi.get_child(0)
				var collisionit = Array()
				for oven_lapsi in ovi_todellinen.get_children():
					if oven_lapsi is StaticBody2D:
						collisionit.append(oven_lapsi.get_child(0))
				# Jos 0 eli kiinni
				if lapsenlapsi.is_in_group("0") and !lapsenlapsi.is_in_group("risti"):
					# Ei resetoida ennen ovipuzzlea olevia neljää ovea
					if lapsenlapsi.is_in_group("ei_resetoi"):
						continue
					# Kiinni
					lapsenlapsi.get_child(0).get_node("AnimatedSprite2D").play_backwards("change")
					for collision in collisionit:
						collision.disabled = false
				elif lapsenlapsi.is_in_group("risti"):
					for ristiovi in lapsenlapsi.get_children():
						ristiovi.queue_free()
					maailma.pystyssa = true
					var ovi_pysty = maailma.ovi_pysty_oikea.instantiate()
					lapsenlapsi.add_child(ovi_pysty)
				else:
					# Auki
					lapsenlapsi.get_child(0).get_node("AnimatedSprite2D").play("change")
					for collision in collisionit:
						collision.disabled = true


## Respawnaa pelaajan käynnistämällä nykyisen scenen uudestaan
func respawn():
	# Soitetaan pelaajan animaatioita täällä pausen takia
	maailma.pelaaja.animaatio.visible = true
	maailma.pelaaja.pauseAnimaatiot.stop()
	maailma.pelaaja.pauseAnimaatiot.visible = false
	
	maailma.palloja = 0 # Resetoidaan pallot, koska reload_current_scene ei sitä tee. Tämän voi koittaa laittaa johonkin järkevämpään paikkaan
	maailma.nykyiset_pallot = 0 # Nykyisten pallojen määrä laitetaan 0
	
	# Valopallojen tuhoaminen
	var valopallot = get_tree().get_nodes_in_group("valopallo")
	for pallo in valopallot:
		pallo.queue_free()
	
	alusta_koynnosovet()
	
	# Haetaan SceneTree ja käynnistetään se uudestaan
	# self.get_tree().call_deferred("reload_current_scene")
	maailma.gameover_ruutu.visible = false
	
	# Aloittaa timerin alusta
	#maailma.pelaaja.ajastin_pimeassa.start()
	maailma.pimeyskuolema_animaatio.stop()
	maailma.pelaaja.siirrytty_varjoon()
	#maailma.pelaaja.siirrytty_valoon()
	maailma.pelaaja.palloja_label_paivita()
	
	# 5.12.2024
	maailma.pelaaja.pelaajan_elamat = maailma.pelaaja.pelaajan_elamat_max
	maailma.pelaaja.elamat_label_paivita()
	
	maailma.kuoltiinko_viholliseen = false # resetoidaan viholliseen/pimeyteen kuolemisen tarkistava muuttuja
	
	# Tuhoa ansa, heal yms. timerit
	# TODO: korjattavaa on myrkkysienten timereissa
	# ne voisi muuttaa samanlaiseksi toteutukseksi kuin ansat ja heali perhoset, helpompi ylläpitää
	# Nyt tekevät vielä damagea respawnin jälkeen kait
	# TODO: TÄTÄ LOOPPIA EI EHKÄ TARVITSE
	for child in maailma.pelaaja.get_children():
		if child is Timer:
			if child.name.contains("Ansa") or child.name.contains("Heal"):
				child.stop()
	# Perhospesän perhosten ja ansojen ajoitusten korjaaminen
	# TODO: TÄTÄKÄÄN EI EHKÄ TARVITSE
	#korjaa_perhospesa_ajoitukset()
	
	get_tree().paused = false
	teleporttaa_pelaaja(maailma.pelaaja_aloitus)
	maailma.pelaaja.velocity = Vector2.ZERO


func korjaa_perhospesa_ajoitukset():
	# Siirretään kuljettavat perhoset aloittamaan aloituspisteestä
	# ja ansat aloittamaan syklin alusta
	# TODO: tämän voisi hoitaa myös Taso2 node
	# TODO: kun kuljettavat perhoset
	#for child in maailma.get_node("Taso2/PerhosetTaso2").get_children():
		#if child is PerhonenKuljettava:
			#child.global_position = child.aloituspiste
	# TODO: ehkä healaavat, jos ovat mukana ajoituspuzzleissa
	for child in maailma.get_node("Taso2/%AnsatTaso2").get_children():
		if child is Ansa:
			child.aloita_sykli()


## "Kerää" journalin, jotta pelaaja voisi sitä käyttää
func keraa_journal():
	maailma.journal_keratty = true
	maailma.pelaaja.apua_label.visible = true


## Vaihtaa journalin näkyviin tai piiloon vuorotellen funktiota kutsuessa.
func toggle_journal(avaa_valosta_riippumatta = false):
	if (not maailma.journal_keratty
		or maailma.pauseruutu.visible
		or maailma.gameover_ruutu.visible
		or maailma.tutoriaali_ruutu.visible):
		return

	if (not avaa_valosta_riippumatta
		and not maailma.pelaaja.valossa
		and not maailma.journal.visible):
		maailma.pelaaja.nayta_journal_info()
		return
	
	if maailma.pelaaja.sivu_info_tween:
		maailma.pelaaja.sivu_info_tween.kill()
		maailma.pelaaja.sivu_info_label.modulate.a = 0
		maailma.pelaaja.sivu_info_label.position.y = -180
	
	if maailma.pelaaja.journal_info_tween:
		maailma.pelaaja.journal_info_tween.kill()
		maailma.pelaaja.journal_info_label.modulate.a = 0
		maailma.pelaaja.journal_info_label.position.y = -80

	maailma.journal.visible = not maailma.journal.visible
	maailma.journal.journal_nakyviin()
	maailma.audio_journal.play()
	get_viewport().set_input_as_handled()
	get_tree().paused = maailma.journal.visible


## Lisää journaliin tekstipätkän annettuun sivunumeroon. Sivunumeron on oltava >= 1.
func lisaa_sivu(sivun_sisalto: SivunSisalto, otsikko: String, sivunumero: int):
	maailma.journal.lisaa_sivu(sivun_sisalto, otsikko, sivunumero)
	maailma.journal.nykyinen_sivu = sivunumero
	if sivunumero > 1:
		maailma.pelaaja.nayta_sivu_info()
	#toggle_journal(true)


## Yleinen funktio pelaajan teleporttaamiseen päämäärään, jossa poistetaan fall-damage ongelmat
func teleporttaa_pelaaja(paamaara: Vector2):
	maailma.pelaaja.position = paamaara
	maailma.pelaaja.putoamis_vahinko = false
	maailma.pelaaja.putoamis_huippu = maailma.pelaaja.get_global_position().y


## Pausettaa pelin
func pausePeli():
	if maailma.gameover_ruutu.visible:
		return
	#pelaaja.pimeyskuolema.pause()
	get_tree().paused = true
	maailma.pauseruutu.visible = true


## Jatkaa peliä pauseruudulta
func jatkaPelia():
	#maailma.pelaaja.pimeyskuolema.play()
	maailma.pauseruutu.visible = false


## Hallitaan, että mikä kuolema-animaatio soitetaan
func soita_kuolema_animaatio():
	if maailma.kuoltiinko_viholliseen == false: # normaalisti tämä on false.. (1)
		if maailma.pelaaja.vedessa == true:
			maailma.pelaaja.pauseAnimaatiot.play("hukkumis_kuolema") # hukkumis animaatio jos kuolee vedessä
		else:
			maailma.pelaaja.pauseAnimaatiot.play("kuolema") # ..että normaali kuolema-animaatio soitetaan (2)
	else: maailma.pelaaja.pauseAnimaatiot.play("vihollis_kuolema") # muutoin soitetaan viholliseen/pimeyteen kuolemisen animaatio


## Yleinen game over funktio signaaleista. Avaa game over ikkunan pelaajalle, josta sitten voi lopettaa pelin tai
## käynnistää peli uudelleen kutsumalla tämän skriptin respawn() funktiota
func _game_over():
	# Soitetaan pelaajan animaatioita täällä pausen takia
	maailma.pelaaja.animaatio.visible = false
	maailma.pelaaja.pauseAnimaatiot.visible = true
	soita_kuolema_animaatio()
	#if not pelaaja.kuolema_tween == null:
		#pelaaja.kuolema_tween.kill()
	maailma.pelaaja.lopeta_kuolema_tweenit()
	maailma.pelaaja.audio_pimeyskuolema.stop()
	maailma.pelaaja.pimeyskuolema.stop()
	maailma.pelaaja.pimeyskuolema.modulate.a = 0.0
	get_tree().paused = true # Peli pauselle, kun se päättyy. Voi hienojen animaatioiden kanssa tietysti myös jättää pausettamatta,
	# tai pausettaa peli muuten, mutta hienot kuolema-animaatiot silti toimivat normaalisti
	await get_tree().create_timer(2,5).timeout # Pieni ajastin, että game over ei ihan heti tule
	maailma.gameover_ruutu.visible = true


## Tämä pitäisi kommentoida
func _show_credits():
	## Lopetetaan kaikki taustalta, niin kuin game overissakin
	maailma.pelaaja.animaatio.visible = false
	maailma.pelaaja.pauseAnimaatiot.visible = true
	#if not pelaaja.kuolema_tween == null:
		#pelaaja.kuolema_tween.kill()
	maailma.pelaaja.lopeta_kuolema_tweenit()
	maailma.pelaaja.audio_pimeyskuolema.stop()
	maailma.pelaaja.pimeyskuolema.stop()
	maailma.pelaaja.pimeyskuolema.modulate.a = 0.0
	get_tree().paused = true


## Näyttää tutoriaalin
func nayta_tutorial():
	maailma.tutoriaali_ruutu.visible = true
	maailma.tutorial_paalla = true
	get_tree().paused = true
	maailma.tutoriaali_ruutu.poista_merkinta()


## Sulkee tutoriaalin
func sulje_tutorial():
	maailma.tutoriaali_ruutu.visible = false
	maailma.tutorial_paalla = false
	get_tree().paused = false


## Palauttaa nykyisen scenen tallennustiedoston polun
func tallennustiedoston_polku():
	return TALLENNUSTIEDOSTO + "_" + nykyinen_scene + ".json"


## Tallentaa pelin nykyisen tilan JSON-tiedostoon.
## Ottaa tallentaessa huomioon pelkästään 'tallenna'-ryhmään kuuluvat nodet,
## jotka on instanssoitu (scenet/*.tscn).
func tallenna():
	# Mallia otettu Godotin dokumentaatiosta:
	# https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
	# Godot tukee serialisointia myös binäärimuodossa. Käytetään kuitenkin
	# helpon luettavuuden takia JSON:ia.

	# Base64-enkoodaus voisi hiukan vaikeuttaa tallennustiedoston muokkaamista,
	# jos sitä kaivataan:
	# https://docs.godotengine.org/en/stable/classes/class_marshalls.html
	
	var tallennustiedosto = FileAccess.open(tallennustiedoston_polku(), FileAccess.WRITE_READ)
	
	# Tallennetaan pelkästään nodet, jotka kuuluvat ryhmään 'tallenna'
	var nodet = get_tree().get_nodes_in_group("tallenna")
	var data = []

	for node in nodet:
		# Tallennettavan noden on oltava instanssoitu (scenet/*.tscn), jotta
		# se voidaan luoda peliä ladattaessa.
		if node.scene_file_path.is_empty():
			print("Nodea '%s' ei ole instanssoitu scenet-kansioon, skipataan" % node.name)
			continue
		
		# Tallennetaan vain, jos nodella on tallenna-funktio.
		if not node.has_method("tallenna"):
			print("Nodella '%s' ei ole funktiota tallenna(), skipataan" % node.name)
			continue
		
		# Haetaan noden tiedot ja lisätään se data-taulukkoon
		var node_data = node.call("tallenna")
		node_data["polku"] = node.get_path()

		data.append(node_data)

	# Muunnetaan tiedot JSON-muotoon
	var json = JSON.stringify(data)
	
	# Lisätään JSON-rivi tallennustiedostoon
	tallennustiedosto.store_line(json)


## Lataa pelin aiemman tilan tallennustiedostosta
func lataa():
	var tallennustiedosto = FileAccess.open(tallennustiedoston_polku(), FileAccess.READ)
	tallennetut_nodet = JSON.parse_string(tallennustiedosto.get_as_text())
	vaihda_scene(nykyinen_scene)


## Avaa uuden tutoriaalin pelaajan tarkisteltavaksi
func unlock_tutorial(nimi):
	maailma.uusi_tutorial = true # Indikoi, että pelaaja on avannut uuden tutoriaalin
	maailma.pelaaja.paivita_tutorial_label() # Päivittää tutoriaalin labelin visuaaliseksi indikoimiseksi
	maailma.tutoriaali_ruutu.paivita_valikko(nimi) # Päivittää valikon tutoriaalissa
	print("Tutoriaali avattu: " + nimi)
	for alue in maailma.tutoriaali_alueet.get_children(): # Käväistään läpi tutoriaalien unlock-alueet
		if nimi == alue.name: # Tarkistetaan, että kyseessä on oikea alue
			#alue.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED) # Yrityksenä siis laittaa pois päältä jo napatut alueet, joka ratkaisisi monta ongelmaa
			alue.queue_free() # Tuhotaan alueen node, että sen kanssa ei voi enää toimia, ja tämähän ratkaisee ne monta ongelmaa


func avaa_seinaovi():
	for static_body in maailma.tiilet_taso_2.get_children():
		if static_body.is_in_group("avaaoviseina"):
			static_body.queue_free()
	maailma.ovi_seina_2.queue_free()


## Luo uuden CollisionPolygon2D:n annetun Polygon2D:n perusteella, joka lisätään Polygon2D:n sisarukseksi.
## Poistaa samalla annetun Polygon2D:n toisen parametrin perusteella.
## Palauttaa luodun CollisionPolygon2D:n.
func polygon2d_to_collisionpolygon2d(polygon2d: Polygon2D, poista_polygon2d = false) -> CollisionPolygon2D:
	# Haetaan Polygon2D:n PackedVector2Array
	var collisionpolygon = CollisionPolygon2D.new()

	# Lisätään CollisionPolygon2D Polygon2D:n sisarukseksi
	polygon2d.add_sibling.call_deferred(collisionpolygon)

	# Asetetaan sama sijainti, rotaatio, yms.
	collisionpolygon.global_position = polygon2d.global_position
	collisionpolygon.rotation = polygon2d.rotation
	collisionpolygon.transform = polygon2d.transform
	collisionpolygon.skew = polygon2d.skew

	# Asetetaan sama polygoni
	collisionpolygon.set_polygon(polygon2d.get_polygon())

	# Poistetaan tarvittaessa Polygon2D
	if poista_polygon2d:
		polygon2d.queue_free()

	return collisionpolygon


## Vaihtaa scenen
## TODO: Parametri scenelle, tällä hetkellä vaihdetaan aina testimaailmaan
func vaihda_scene(maailman_nimi):
	nykyinen_scene = maailman_nimi
	# Poistetaan nykyinen Maailma-node SceneTreestä
	#get_tree().root.remove_child(maailma)
	# TODO: 10.2.2025 Juuso
	# käytetään vain tätä? ei poistanut main menua, 
	# jos käytti ylempää sillä maailmaa ei ole vielä olemassa
	# Tällähän varmistaa, että aina nykyinen aktiivinen skene tuhotaan
	get_tree().root.remove_child(get_tree().current_scene)
	# Luodaan uusi Maailma-node
	var maailma_tscn = load(MAAILMASCENE_KANSIO + "/" + maailman_nimi + ".tscn")
	maailma = maailma_tscn.instantiate()
	# Lisätään uusi Maailma-node SceneTreehen
	get_tree().root.add_child.call_deferred(maailma)
	# (maailma.gd kutsuu Globaali.gd:n init()-funktiota, kun on valmis)


## Tähän funktioon voi lisätä vaikeusasteen puolesta asioita
func paivita_vaikeusaste():
	maailma.pelaaja.paivita_vaikeusaste()


## Päivittää grafiikoita, jos niitä halutaan kesken pelin muuttaa, esim. asetuksista
func paivita_grafiikat():
	if maailma.taustaelementit_paalla == true:
		maailma.taustaelementit.visible = true
	else: maailma.taustaelementit.visible = false
