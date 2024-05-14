## Harri 7.5.4.2024
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
## Sekunnissa päivittämiseen käytettävät muuttujat (kts. process delta)
var aika_vali = 1.0
var aika = 0
## UI-näkyvyyden ajastin
var ui_ajastin = Timer.new()

## Taulukko tooltipeille
@onready var tooltip_node = get_node("/root/Maailma/Tooltipit")
var tooltipit = Array()

## Pelaajan ja vihollisen aloitus koordinaatit
## Pelaajan aloituspaikka muuttuu pelin edetessä checkpointtien takia
var pelaaja_aloitus = null

## Pelaajan taso2 ja taso3 koordinaatit teleporttaamiseen
## Kentan 1 loppu mukaan minecart tp varten
@onready var pelaaja_taso2 = get_node("/root/Maailma/%Muuta/%Taso2Teleport").position
@onready var pelaaja_taso3 = get_node("/root/Maailma/%Muuta/%Taso3Teleport").position
@onready var pelaaja_taso45 = get_node("/root/Maailma/%Muuta/%Taso45Teleport").position
@onready var taso1_loppu = get_node("/root/Maailma/%Muuta/%Kentan1_loppu").position

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
@onready var journal = get_node("/root/Maailma/%KayttoLiittyma/Journal")
@onready var pauseruutu = get_node("/root/Maailma/%KayttoLiittyma/%pause_ruutu")
@onready var pimeyskuolema_animaatio = get_node("/root/Maailma/%KayttoLiittyma/%PimeysKuolema")
@onready var uudetViholliset = get_node("/root/Maailma/%uudetViholliset").get_children()
@onready var kukat = get_node("/root/Maailma/%Kukat").get_children()
@onready var piikit = get_node("/root/Maailma/%Piikit").get_children()
## Musiikit:
@onready var musiikki = get_node("/root/Maailma/%Musiikki")
## Minecartit tuhotaan, kun jompi kumpi käytetään
@onready var minecartit = get_node("/root/Maailma/%Minecartit")

## Lisätään sceneen tausta pelin alussa
var tausta = preload("res://scenet/tausta.tscn")


## Scenen vaihtamiseen, ei luultavasti tarvita
"""
@export var taso2 = preload("res://maailma2.tscn")
var t2 = preload("res://maailma2.tscn")
"""

## Yleinen ready
func _ready():
	# Signaalikäsittelyä mm. pelaajan kuolemisesta
	pelaaja = get_tree().get_first_node_in_group("Pelaaja") # Otetaan pelaaja groupistaan
	pelaaja.kuollut.connect(_game_over) # Yhdistetään signaali pelaajasta
	
	# Yhdistetään kuolema kaikkiin uusiin vihollisiin
	for uusiVihu in uudetViholliset:
		if uusiVihu != null:
			uusiVihu.pelaaja_kuollut.connect(_game_over)
	
	# piikki = get_tree().get_first_node_in_group("piikki") # Tehdään näissä
	for piikki in piikit:
		if piikki != null:
			piikki.pelaaja_kuollut.connect(_game_over) # samaa kuin pelaajan käsittelyssä
	
	# Otetaan aloitus koordinaatit talteen
	pelaaja_aloitus = pelaaja.position
	
	# Lisätään sceneen tausta
	self.add_child(tausta.instantiate())
	
	# Aloitetaan musiikki 
	musiikki.play()
	
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

	# Journal pois näkyvistä
	journal.visible = false


## Poistaa minecart-tooltipit
func poista_minecart_tooltipit():
	for tooltip in tooltipit:
		if tooltip.get_name().contains("Minecart"):
			tooltip.visible = false
			tooltip.process_mode = Node.PROCESS_MODE_DISABLED


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
			uudetViholliset[i].process_mode = Node.PROCESS_MODE_INHERIT # ..vihollinen on toiminnassa
		else: # Jos ei ole ..
			uudetViholliset[i].process_mode = Node.PROCESS_MODE_DISABLED # .. vihollinen ei ole toiminnassa


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
		pelaaja.putoamis_vahinko = false
		pelaaja.position = pelaaja_taso2
	
	# PC F3
	if Input.is_action_just_pressed("taso3"):
		pelaaja.putoamis_vahinko = false
		pelaaja.position = pelaaja_taso3
		# get_node("/root/@Node2D@65").queue_free() # Poistetaan duplikoitu maailma2
	
	# PC F4
	if Input.is_action_just_pressed("taso45"):
		pelaaja.putoamis_vahinko = false
		pelaaja.position = pelaaja_taso45
	
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
	pelaaja.putoamis_vahinko = false
	pelaaja.position = pelaaja_aloitus
	gameover_ruutu.visible = false
	
	# Aloittaa timerin alusta
	pelaaja.ajastin_pimeassa.start()
	pimeyskuolema_animaatio.stop()
	pelaaja.siirrytty_valoon()
	pelaaja.siirrytty_varjoon()


## Vaihtaa journalin näkyviin tai piiloon vuorotellen funktiota kutsuessa.
func toggle_journal():
	if not pelaaja.valossa && not journal.visible:
		return

	journal.visible = not journal.visible
	get_viewport().set_input_as_handled()
	get_tree().paused = journal.visible


## Lisää journaliin tekstipätkän annettuun sivunumeroon. Sivunumeron on oltava >= 1.
func lisaa_sivu(teksti: String, otsikko: String, sivunumero: int):
	journal.lisaa_sivu(teksti, otsikko, sivunumero)


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
	# Soitetaan pelaajan animaatioita täällä pausen takia
	pelaaja.animaatio.visible = false
	pelaaja.pauseAnimaatiot.visible = true
	pelaaja.pauseAnimaatiot.play("kuolema")
	get_tree().paused = true # Peli pauselle, kun se päättyy. Voi hienojen animaatioiden kanssa tietysti myös jättää pausettamatta,
	# tai pausettaa peli muuten, mutta hienot kuolema-animaatiot silti toimivat normaalisti
	await get_tree().create_timer(2,5).timeout # Pieni ajastin, että game over ei ihan heti tule
	gameover_ruutu.visible = true
