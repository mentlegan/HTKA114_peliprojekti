## Harri 4.9.2024
## Paavo 22.4.2024
## Elias 22.4.2024
## Tämä on yleinen, koko pelin kattava globaali scripti, johon voi lisätä muuttujia ja funktioita käytettäväksi muissa scripteissä
## TODO: pelaajan kuolema-animaation voi kenties siirtää pelaajan scriptiin, jos sen saa toimimaan siellä:
##		 tehty tänne toistaiseksi Fall damage-kuoleman takia
extends Node2D

## Käytössä olevat pallot
var palloja = 0
## Maailmassa olevat pallot
var nykyiset_pallot = 0
## Signaaleja varten
var pelaaja = null
var uusi_vihollinen = null
var tutoriaali = null
## Sekunnissa päivittämiseen käytettävät muuttujat (kts. process delta)
var aika_vali = 1.0
var aika = 0
## UI-näkyvyyden ajastin
var ui_ajastin = Timer.new()
var kuoltiinko_viholliseen
## Taulukko tooltipeille
@onready var tooltip_node = get_node("/root/Maailma/Tooltipit")
var tooltipit = Array()

## Pelaajan ja vihollisen aloitus koordinaatit
## Pelaajan aloituspaikka muuttuu pelin edetessä checkpointtien takia
var pelaaja_aloitus = null
var soitetaan_animatic

## Pelaajan taso2 ja taso3 koordinaatit teleporttaamiseen
## Kentan 1 loppu mukaan minecart tp varten
@onready var pelaaja_taso2 = get_node("/root/Maailma/%Muuta/%Taso2Teleport").position
@onready var pelaaja_taso3 = get_node("/root/Maailma/%Muuta/%Taso3Teleport").position
@onready var pelaaja_taso45 = get_node("/root/Maailma/%Muuta/%Taso45Teleport").position
@onready var taso1_loppu = get_node("/root/Maailma/%Muuta/%Kentan1_loppu").position
@onready var vesiputous_tp = get_node("/root/Maailma/%Muuta/%VesiputousTeleport").position

@onready var pelaaja_vesitutoriaali = get_node("/root/Maailma/Taso2/%VesitutoriaaliTP").position
@onready var pelaaja_vesitutoriaali_ennen = get_node("/root/Maailma/Taso2/%VesitutoriaaliEnnenTP").position
@onready var pelaaja_vesitutoriaalilapi = get_node("/root/Maailma/Taso2/%VesitutoriaaliLapiTP").position

@onready var tiilet_taso_2 = get_node("/root/Maailma/Taso2/%TiiletTaso2")
@onready var ovi_seina_2 = get_node("/root/Maailma/Taso2/%OviSeina2")

## Valot ja indikaattorit köynnösoville ja niiden taulukko
var oven_valo = preload("res://scenet/oven_valo.tscn")
var oven_indikaattori = preload("res://scenet/oven_indikaattori.tscn")
var oven_indikaattori_punainen = preload("res://tres-tiedostot/oven_indikaattori_punainen.tres")
var oven_indikaattori_sininen = preload("res://tres-tiedostot/oven_indikaattori_sininen.tres")
var oven_indikaattori_lila = preload("res://tres-tiedostot/oven_indikaattori_lila.tres")
var ovien_valot = Array()
var ovien_indikaattorit = Array()
@onready var koynnosovet = get_node("/root/Maailma/Koynnosovet")

## Köynnösovien scenet
@onready var ovi_vasen_x = preload("res://scenet/ovet/ovi_vasen_x.tscn")
@onready var ovi_oikea_x = preload("res://scenet/ovet/ovi_oikea_x.tscn")
@onready var ovi_vasen_y = preload("res://scenet/ovet/ovi_vasen_y.tscn")
@onready var ovi_oikea_y = preload("res://scenet/ovet/ovi_oikea_y.tscn")
@onready var ovi_vasen_z = preload("res://scenet/ovet/ovi_vasen_z.tscn")
@onready var ovi_oikea_z = preload("res://scenet/ovet/ovi_oikea_z.tscn")

@onready var ovi_pysty_oikea = preload("res://scenet/ovet/ovi_pysty_oikea.tscn")
@onready var ovi_vaaka_vasen = preload("res://scenet/ovet/ovi_vaaka_vasen.tscn")

## Taulukko Tasot-nodelle
var tasot = Array()
@onready var tasot_node = get_node("/root/Maailma/Tasot")

## Ristiovelle oma kohtelu vielä tässä vaiheessa
@onready var ovi_risti = get_tree().get_first_node_in_group("risti")
var pystyssa = true

## Tässä otetaan käyttöliittymän pauseruutu groupin avulla. Alla on toinen tapa ottaa
## @onready var pauseruutu = get_tree().get_first_node_in_group("pauseruutu")

## /root/Maailma/[uniquenimi] näyttäisi toimivan:
## huom. uniikki nimi toimii vain, jos ei ole aikomusta tehdä useaa instanssia
## pitää vaan muistaa kaikille käsiteltäville nodeille laittaa unique nimi nodepuusta:
## oikea näppäin ja % merkillä oleva valinta Access as unique name 
## ja kutsua sitä % merkillä scriptissä, kuten alla:
@onready var gameover_ruutu = get_node("/root/Maailma/%KayttoLiittyma/%GameOverRuutu")
@onready var credits = get_node("/root/Maailma/%KayttoLiittyma/%Credits")
@onready var journal = get_node("/root/Maailma/%KayttoLiittyma/Journal")
@onready var pauseruutu = get_node("/root/Maailma/%KayttoLiittyma/%pause_ruutu")
@onready var asetuksetruutu = get_node("/root/Maailma/%KayttoLiittyma/%asetukset_ruutu")
@onready var pimeyskuolema_animaatio = get_node("/root/Maailma/%KayttoLiittyma/%PimeysKuolema")
@onready var uudetViholliset = get_node("/root/Maailma/%uudetViholliset").get_children()
@onready var kukat = get_node("/root/Maailma/%Kukat").get_children()
@onready var piikit = get_node("/root/Maailma/%Piikit").get_children()
@onready var tutoriaali_ruutu = get_node("/root/Maailma/%KayttoLiittyma/%Tutoriaali")
@onready var tutoriaali_alueet = get_node("/root/Maailma/%TutoriaaliUnlock")
var tutorial_paalla = false
var uusi_tutorial = false
## Musiikit:
@onready var musiikki = get_node("/root/Maailma/%Musiikki")
@onready var audio_journal = get_node("/root/Maailma/%KayttoLiittyma/Journal/%AudioJournal")
@onready var audio_oven_resonanssi = get_node("/root/Maailma/Koynnosovet/%AudioOvenResonanssi")
## Minecartit tuhotaan, kun jompi kumpi käytetään
@onready var minecartit = get_node("/root/Maailma/%Minecartit")

## Lisätään sceneen tausta pelin alussa
var tausta = preload("res://scenet/tausta.tscn")
var tausta2 = preload("res://scenet/tausta2.tscn")
var tausta_node
var tausta2_node
## Totuusarvo journalin aktivoimiselle ja minecartin käytölle
var journal_keratty = false
var minecart_kaytetty = false

# Pelin tallennustiedosto
# Sijainti: %APPDATA%\Godot\app_userdata\Beneath the Mines\save_file.json
const TALLENNUSTIEDOSTO = "user://save_file.json"

@onready var animatic = get_node("/root/Maailma/%KayttoLiittyma/%Animatic")

## Yleinen ready
func _ready():
	# Soitetaan alkuanimatic. Seuraavan rivin voi dokumentoida pois, jos haluaa testata peliä ilman sitä
	#soita_animatic()
	
	# Signaalikäsittelyä mm. pelaajan kuolemisesta
	pelaaja = get_tree().get_first_node_in_group("Pelaaja") # Otetaan pelaaja groupistaan
	pelaaja.kuollut.connect(_game_over) # Yhdistetään signaali pelaajasta
	
	# Signaali creditsien näyttämisestä
	credits = get_tree().get_first_node_in_group("Credits")
	credits.show_credits.connect(_show_credits)
	
	# Yhdistetään kuolema kaikkiin uusiin vihollisiin
	for uusiVihu in uudetViholliset:
		if uusiVihu != null:
			uusiVihu.pelaaja_kuollut.connect(_game_over)
	
	
	# Otetaan aloitus koordinaatit talteen
	pelaaja_aloitus = pelaaja.position
	
	# Lisätään sceneen tausta
	var tausta_n = tausta.instantiate()
	#tausta_node.z_index = -10
	# Tallennetaan muuttujaan
	tausta_node = tausta_n
	self.add_child(tausta_node)
	
	# Vesialueen tausta
	var tausta2_n = tausta2.instantiate()
	tausta2_n.hide()
	# Tallenetaan muuttujaan
	tausta2_node = tausta2_n
	self.add_child(tausta2_n)
	
	
	# Lisätään UI-ajastin
	self.add_child(ui_ajastin)
	ui_ajastin.set_one_shot(true)
	ui_ajastin.timeout.connect(aseta_ui_nakyvaksi)
	
	# Täytetään tasot- ja valot-taulukko
	lisaa_tasot()
	lisaa_valot_ja_indikaattorit()
	
	# Haetaan pelin kaikki tooltip-nodet.
	lisaa_tooltipit()
	vaihda_tooltip_ui(true)
	
	# Alustetaan köynnösovet
	alusta_koynnosovet()
	
	kuoltiinko_viholliseen = false # Tällä katsotaan, että kuoltiinko viholliseen tai pimeyteen
	
	# Journal pois näkyvistä
	journal.visible = false


## Antaa tiedon animaticin scriptille, että halutaanko alkuanimaticin soivan
func soita_animatic():
	soitetaan_animatic = true # Tämä bool sanoo Animaticin scriptille, että alkuanimatic todella soitetaan
	get_tree().paused = true # Peli pauselle
	animatic.visible = true # Animaticin interface ja kuvat näkyviin
	


## Soittaa musiikkia
func soita_musiikki():
	musiikki.play()


## Poistaa minecart-tooltipit
func poista_minecart_tooltipit():
	for tooltip in tooltipit:
		if tooltip.get_name().contains("Minecart"):
			tooltip.visible = false
			tooltip.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)


## Hakee pelin kaikki tooltip-nodet ja lisää ne omaan taulukkoon
func lisaa_tooltipit():
	for lapsi in tooltip_node.get_children():
		if lapsi is Tooltip:
			tooltipit.append(lapsi)


## Vaihtaa pelin kaikkien tooltippien UI:t vastaamaan annettua ohjainta.
func vaihda_tooltip_ui(nappaimisto):
	for tooltip in tooltipit:
		tooltip.vaihda_ui(nappaimisto)


## Asettaa pelin jokaisen köynnösoven valon näkyvyyden
func aseta_valojen_vakyvyys(nakyvyys):
	for valo in ovien_valot:
		valo.visible = nakyvyys


## Lisää Koynnosovet-noden jokaiselle lapsenlapselle valot ja indikaattorit
func lisaa_valot_ja_indikaattorit():
	for lapsi in koynnosovet.get_children():
		for lapsenlapsi in lapsi.get_children():
			# Valot
			var valo = oven_valo.instantiate()
			valo.global_position = lapsenlapsi.global_position
			valo.visible = false
			lapsi.add_child(valo)
			ovien_valot.append(valo)
	
			# Indikaattorit
			var indikaattori = oven_indikaattori.instantiate()
			indikaattori.global_position = lapsenlapsi.global_position
	
			if lapsenlapsi.is_in_group("x"):
				indikaattori.texture = oven_indikaattori_punainen
			elif lapsenlapsi.is_in_group("y"):
				indikaattori.texture = oven_indikaattori_lila
			elif lapsenlapsi.is_in_group("z"):
				indikaattori.texture = oven_indikaattori_sininen
	
			lapsi.add_child(indikaattori)
			ovien_indikaattorit.append(indikaattori)


## Asettaa pelaajan UI:n takaisin näkyväksi ja (TODO) piilottaa ovet
## Palauttaa samalla aktiivisen kameran pelaajalle
func aseta_ui_nakyvaksi():
	pelaaja.aseta_ui_nakyvyys(true)
	aseta_valojen_vakyvyys(false)


## Lisää Tasot-noden CollisionShape2D- ja Camera2D-nodet taulukkoon.
func lisaa_tasot():
	for lapsi in tasot_node.get_children():
		if lapsi is CollisionShape2D:
			# Etsitään kamera nykyisen lapsen lapsista
			var kamera = null
			for lapsenlapsi in lapsi.get_children():
				if lapsenlapsi is Camera2D:
					kamera = lapsenlapsi
	
			if kamera != null:
				tasot.append({
					"rect": Rect2(
						lapsi.global_position - lapsi.get_shape().get_rect().size * 0.5,
						lapsi.get_shape().get_rect().size
					),
					"kamera": kamera
				})


## Lisätään viholliset oikein
func lisaa_viholliset():
	for i in uudetViholliset.size(): # Otetaan viholliset niiden arrayn koon mukaan
		if samassa_tasossa_kuin_pelaaja(uudetViholliset[i]): # Jos pelaaja on samassa tasossa kuin vihollinen ..
			uudetViholliset[i].set_deferred("process_mode", Node.PROCESS_MODE_INHERIT) # ..vihollinen on toiminnassa
		else: # Jos ei ole ..
			uudetViholliset[i].set_deferred("process_mode", Node.PROCESS_MODE_DISABLED) # .. vihollinen ei ole toiminnassa


## Palauttaa totuusarvon siitä, onko pelaaja samassa tasossa kuin annettu node
func samassa_tasossa_kuin_pelaaja(node: Node):
	for taso in tasot:
		if (taso["rect"].has_point(node.global_position)
		and taso["rect"].has_point(pelaaja.global_position)):
			return true
	return false


## Palauttaa annetun noden nykyisen tason Rect2-noden.
## Jos annettu node ei ole minkään tason sisällä, palauttaa uuden Rect2-noden.
func nykyisen_tason_collision_shape(node: Node) -> Rect2:
	for taso in tasot:
		if taso["rect"].has_point(node.global_position):
			return taso["rect"]
	return Rect2()


## Näyttää ovet tasosta, johon annetut koordinaatit sijoittuvat
## Samalla tehdään resonointipartikkelit
func nayta_tason_ovet_ja_resonoi(_ovi_vaikutettu):
	var koordinaatit = _ovi_vaikutettu.global_position
	for taso in tasot:
		if taso["rect"].has_point(koordinaatit) and pelaaja.kamera.is_current():
			taso["kamera"].aktivoi(pelaaja)
			pelaaja.aseta_ui_nakyvyys(false)
			aseta_valojen_vakyvyys(true)
			aseta_indikaattorit_nakyviin(taso["rect"])
			audio_oven_resonanssi.play()
			return


## Asettaa ovien indikaattorit näkyviin annetusta tasosta
func aseta_indikaattorit_nakyviin(rect: Rect2):
	for indikaattori in ovien_indikaattorit:
		if rect.has_point(indikaattori.global_position):
			indikaattori.aloita()


## Tämä taitaa olla oikea tapa tarkistaa inputteja, toisin kuin process tai physics_process
## Kutsutaan vain kun painetaan jotain
func _input(_event: InputEvent) -> void:
	# PC F2
	if Input.is_action_just_pressed("taso2"):
		"""
		ovet = Array()
		# Hyvin scuffed tapa, mutta toimii (kait?)
		get_tree().change_scene_to_packed(taso2)
		get_tree().root.add_child(t2.instantiate())
		_ready()
		# get_node("/root/Maailma2").free()
		"""
		teleporttaa_pelaaja(pelaaja_taso2)
	
	# PC F3
	if Input.is_action_just_pressed("taso3"):
		teleporttaa_pelaaja(pelaaja_taso3)
		# get_node("/root/@Node2D@65").queue_free() # Poistetaan duplikoitu maailma2
	
	# PC F4
	if Input.is_action_just_pressed("taso45"):
		teleporttaa_pelaaja(pelaaja_taso45)
	
	# PC F6
	if Input.is_action_just_pressed("vesitutoriaaliennen"):
		teleporttaa_pelaaja(pelaaja_vesitutoriaali_ennen)
	
	# PC F7
	if Input.is_action_just_pressed("vesitutoriaali"):
		teleporttaa_pelaaja(pelaaja_vesitutoriaali)
	
	# PC F9, koska F8 on quit
	if Input.is_action_just_pressed("vesitutoriaalilapi"):
		teleporttaa_pelaaja(pelaaja_vesitutoriaalilapi)
	
	# Pelin keskeytys
	# PC ESCAPE
	# PS4/PS5 OPTIONS
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			pausePeli()
			# Asetetaan inputti "syödyksi", sitä ei käsitellä enää missään muualla
			# Esim. pause-menun skriptissä, jossa pelin jatkuminen
			get_viewport().set_input_as_handled()


## Kutsutaan joka framella
func _process(_delta):
	# Päivitetään peliä joka sekuntti
	aika += _delta
	if aika > aika_vali:
		# Tähän lisätään joka sekuntti tapahtuva asia
		lisaa_viholliset() # Viholliset päivittyvät pois ja päälle riippuen pelaajan positiosta
		aika = 0


func alusta_koynnosovet():
	# Resetoidaan köynnösovet kuolemisen jälkeen
	# Käytetään myös ennen pelin alkua kerran _ready()
	# Asetetaan animationspritejen framet oikeiksi
	for lapsi in koynnosovet.get_children():
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
					pystyssa = true
					var ovi_pysty = ovi_pysty_oikea.instantiate()
					lapsenlapsi.add_child(ovi_pysty)
				else:
					# Auki
					lapsenlapsi.get_child(0).get_node("AnimatedSprite2D").play("change")
					for collision in collisionit:
						collision.disabled = true


## Respawnaa pelaajan käynnistämällä nykyisen scenen uudestaan
func respawn():
	# Soitetaan pelaajan animaatioita täällä pausen takia
	pelaaja.animaatio.visible = true
	pelaaja.pauseAnimaatiot.stop()
	pelaaja.pauseAnimaatiot.visible = false
	palloja = 0 # Resetoidaan pallot, koska reload_current_scene ei sitä tee. Tämän voi koittaa laittaa johonkin järkevämpään paikkaan
	nykyiset_pallot = 0 # Nykyisten pallojen määrä laitetaan 0
	
	# Valopallojen tuhoaminen
	var valopallot = get_tree().get_nodes_in_group("valopallo")
	for pallo in valopallot:
		pallo.queue_free()
	
	alusta_koynnosovet()
	
	# Peli pois pauselta
	get_tree().paused = false
	# Haetaan SceneTree ja käynnistetään se uudestaan
	# self.get_tree().call_deferred("reload_current_scene")
	teleporttaa_pelaaja(pelaaja_aloitus)
	gameover_ruutu.visible = false
	
	# Aloittaa timerin alusta
	pelaaja.ajastin_pimeassa.start()
	pimeyskuolema_animaatio.stop()
	pelaaja.siirrytty_varjoon()
	pelaaja.palloja_label_paivita()
	
	kuoltiinko_viholliseen = false # resetoidaan viholliseen/pimeyteen kuolemisen tarkistava muuttuja


## "Kerää" journalin, jotta pelaaja voisi sitä käyttää
func keraa_journal():
	journal_keratty = true
	pelaaja.apua_label.visible = true


## Vaihtaa journalin näkyviin tai piiloon vuorotellen funktiota kutsuessa.
func toggle_journal(avaa_valosta_riippumatta = false):
	if not journal_keratty or pauseruutu.visible or gameover_ruutu.visible or tutoriaali_ruutu.visible:
		return

	if not avaa_valosta_riippumatta and not pelaaja.valossa and not journal.visible:
		pelaaja.nayta_journal_info()
		return
	
	if pelaaja.sivu_info_tween:
		pelaaja.sivu_info_tween.kill()
		pelaaja.sivu_info_label.modulate.a = 0
		pelaaja.sivu_info_label.position.y = -180
	
	if pelaaja.journal_info_tween:
		pelaaja.journal_info_tween.kill()
		pelaaja.journal_info_label.modulate.a = 0
		pelaaja.journal_info_label.position.y = -80

	journal.visible = not journal.visible
	journal.journal_nakyviin()
	audio_journal.play()
	get_viewport().set_input_as_handled()
	get_tree().paused = journal.visible


## Lisää journaliin tekstipätkän annettuun sivunumeroon. Sivunumeron on oltava >= 1.
func lisaa_sivu(sivun_sisalto: SivunSisalto, otsikko: String, sivunumero: int):
	journal.lisaa_sivu(sivun_sisalto, otsikko, sivunumero)
	journal.nykyinen_sivu = sivunumero
	if sivunumero > 1:
		pelaaja.nayta_sivu_info()
	#toggle_journal(true)


## Yleinen funktio pelaajan teleporttaamiseen päämäärään, jossa poistetaan fall-damage ongelmat
func teleporttaa_pelaaja(paamaara):
	pelaaja.position = paamaara
	pelaaja.putoamis_vahinko = false
	pelaaja.putoamis_huippu = pelaaja.get_global_position().y


## Pausettaa pelin
func pausePeli():
	if gameover_ruutu.visible:
		return
	
	#pelaaja.pimeyskuolema.pause()
	get_tree().paused = true
	pauseruutu.visible = true


## Jatkaa peliä pauseruudulta
func jatkaPelia():
	#pelaaja.pimeyskuolema.play()
	pauseruutu.visible = false


## Hallitaan, että mikä kuolema-animaatio soitetaan
func soita_kuolema_animaatio():
	if kuoltiinko_viholliseen == false: # normaalisti tämä on false.. (1)
		if pelaaja.vedessa == true:
			pelaaja.pauseAnimaatiot.play("hukkumis_kuolema") # hukkumis animaatio jos kuolee vedessä
		else:
			pelaaja.pauseAnimaatiot.play("kuolema") # ..että normaali kuolema-animaatio soitetaan (2)
	else: pelaaja.pauseAnimaatiot.play("vihollis_kuolema") # muutoin soitetaan viholliseen/pimeyteen kuolemisen animaatio


## Yleinen game over funktio signaaleista. Avaa game over ikkunan pelaajalle, josta sitten voi lopettaa pelin tai
## käynnistää peli uudelleen kutsumalla tämän skriptin respawn() funktiota
func _game_over():
	# Soitetaan pelaajan animaatioita täällä pausen takia
	pelaaja.animaatio.visible = false
	pelaaja.pauseAnimaatiot.visible = true
	soita_kuolema_animaatio()
	#if not pelaaja.kuolema_tween == null:
		#pelaaja.kuolema_tween.kill()
	pelaaja.lopeta_kuolema_tweenit()
	pelaaja.audio_pimeyskuolema.stop()
	pelaaja.pimeyskuolema.stop()
	pelaaja.pimeyskuolema.modulate.a = 0.0
	get_tree().paused = true # Peli pauselle, kun se päättyy. Voi hienojen animaatioiden kanssa tietysti myös jättää pausettamatta,
	# tai pausettaa peli muuten, mutta hienot kuolema-animaatiot silti toimivat normaalisti
	await get_tree().create_timer(2,5).timeout # Pieni ajastin, että game over ei ihan heti tule
	gameover_ruutu.visible = true


## Tämä pitäisi kommentoida
func _show_credits():
	## Lopetetaan kaikki taustalta, niin kuin game overissakin
	pelaaja.animaatio.visible = false
	pelaaja.pauseAnimaatiot.visible = true
	#if not pelaaja.kuolema_tween == null:
		#pelaaja.kuolema_tween.kill()
	pelaaja.lopeta_kuolema_tweenit()
	pelaaja.audio_pimeyskuolema.stop()
	pelaaja.pimeyskuolema.stop()
	pelaaja.pimeyskuolema.modulate.a = 0.0
	get_tree().paused = true


## Näyttää tutoriaalin
func nayta_tutorial():
	tutoriaali_ruutu.visible = true
	tutorial_paalla = true
	get_tree().paused = true
	tutoriaali_ruutu.poista_merkinta()


## Sulkee tutoriaalin
func sulje_tutorial():
	tutoriaali_ruutu.visible = false
	tutorial_paalla = false
	get_tree().paused = false


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
	
	var tallennustiedosto = FileAccess.open(TALLENNUSTIEDOSTO, FileAccess.WRITE_READ)
	
	# Tallennetaan pelkästään nodet, jotka kuuluvat ryhmään 'tallenna'
	var nodet = get_tree().get_nodes_in_group("tallenna")

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
		var data = node.call("tallenna")

		# Muunnetaan tiedot JSON-muotoon
		var json = JSON.stringify(data)
		
		# Lisätään JSON-rivi tallennustiedostoon
		tallennustiedosto.store_line(json)


## Lataa pelin aiemman tilan tallennustiedostosta
func lataa():
	pass


## Avaa uuden tutoriaalin pelaajan tarkisteltavaksi
func unlock_tutorial(nimi):
	uusi_tutorial = true # Indikoi, että pelaaja on avannut uuden tutoriaalin
	pelaaja.paivita_tutorial_label() # Päivittää tutoriaalin labelin visuaaliseksi indikoimiseksi
	tutoriaali_ruutu.paivita_valikko(nimi) # Päivittää valikon tutoriaalissa
	print("Tutoriaali avattu: " + nimi)
	for alue in tutoriaali_alueet.get_children(): # Käväistään läpi tutoriaalien unlock-alueet
		if nimi == alue.name: # Tarkistetaan, että kyseessä on oikea alue
			#alue.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED) # Yrityksenä siis laittaa pois päältä jo napatut alueet, joka ratkaisisi monta ongelmaa
			alue.queue_free() # Tuhotaan alueen node, että sen kanssa ei voi enää toimia, ja tämähän ratkaisee ne monta ongelmaa


func avaa_seinaovi():
	for static_body in tiilet_taso_2.get_children():
		if static_body.is_in_group("avaaoviseina"):
			static_body.queue_free()
	ovi_seina_2.queue_free()
