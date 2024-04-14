## Harri 9.4.2024
## Paavo 10.4.2024
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

## UI-näkyvyyden ajastin
var ui_ajastin = Timer.new()

## Taulukko tooltipeille
@onready var tooltip_node = get_node("/root/Maailma/Tooltipit")
var tooltipit = Array()

## Pelaajan ja vihollisen aloitus koordinaatit
## Pelaajan aloituspaikka muuttuu pelin edetessä checkpointtien takia
var pelaaja_aloitus = null
var vihollinen_aloitus = null

## Pelaajan taso2 ja taso3 koordinaatit teleporttaamiseen
## Kentan 1 loppu mukaan minecart tp varten
@onready var pelaaja_taso2 = get_node("/root/Maailma/%Muuta/%Taso2Teleport").position
@onready var pelaaja_taso3 = get_node("/root/Maailma/%Muuta/%Taso3Teleport").position
@onready var pelaaja_taso45 = get_node("/root/Maailma/%Muuta/%Taso45Teleport").position
@onready var taso1_loppu = get_node("/root/Maailma/%Muuta/%Kentan1_loppu").position

## Valo köynnösoville ja niiden taulukko
var oven_valo = preload("res://scenet/oven_valo.tscn")
var ovien_valot = Array()
@onready var koynnosovet = get_node("/root/Maailma/Koynnosovet")

## Taulukko Tasot-nodelle
var tasot = Array()
@onready var tasot_node = get_node("/root/Maailma/Tasot")

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
@onready var uudetViholliset = get_node("/root/Maailma/%uudetViholliset").get_children()
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
	
	vihollinen = get_tree().get_first_node_in_group("vihollinen") # Tehdään näissä
	vihollinen.pelaaja_kuollut.connect(_game_over) # samaa kuin pelaajan käsittelyssä
	
	# Yhdistetään kuolema kaikkiin uusiin vihollisiin
	# TODO: tällä lailla voisi laittaa kaikki signaaliyhdistämiset jatkossa?
	for uusiVihu in uudetViholliset:
		if uusiVihu != null:
			uusiVihu.pelaaja_kuollut.connect(_game_over)
	
	# piikki = get_tree().get_first_node_in_group("piikki") # Tehdään näissä
	for piikki in piikit:
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

	# Aloitetaan musiikki 
	musiikki.play()

	# Lisätään UI-ajastin
	self.add_child(ui_ajastin)
	ui_ajastin.set_one_shot(true)
	ui_ajastin.timeout.connect(aseta_ui_nakyvaksi)

	# Täytetään tasot- ja valot-taulukko
	lisaa_tasot()
	lisaa_valot()

	# Haetaan pelin kaikki tooltip-nodet.
	lisaa_tooltipit()
	vaihda_tooltip_ui(true)


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


## Lisää Koynnosovet-noden jokaiselle lapsenlapselle valot
func lisaa_valot():
	for lapsi in koynnosovet.get_children():
		for lapsenlapsi in lapsi.get_children():
			var valo = oven_valo.instantiate()
			valo.global_position = lapsenlapsi.global_position
			valo.visible = false
			self.add_child(valo)
			ovien_valot.append(valo)


## Asettaa pelaajan UI:n takaisin näkyväksi ja (TODO) piilottaa ovet
## Palauttaa samalla aktiivisen kameran pelaajalle
func aseta_ui_nakyvaksi():
	pelaaja.aseta_ui_nakyvyys(true)
	pelaaja.palauta_kamera()
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


## Näyttää ovet tasosta, johon annetut koordinaatit sijoittuvat.
func nayta_tason_ovet(koordinaatit):
	for taso in tasot:
		if taso["rect"].has_point(koordinaatit):
			taso["kamera"].make_current()
			pelaaja.aseta_ui_nakyvyys(false)
			ui_ajastin.start(5)
			aseta_valojen_vakyvyys(true)
			return


## Tämä taitaa olla oikea tapa tarkistaa inputteja, toisin kuin process tai physics_process
## Kutsutaan vain kun painetaan jotain
func _input(_event: InputEvent) -> void:
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
	
	# F4
	if Input.is_action_just_pressed("taso45"):
		pelaaja.position = pelaaja_taso45
	
	
	# Pelin keskeytys
	# PC Escape
	# PS4/PS5 Options
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			pausePeli()
			# Asetetaan inputti "syödyksi", sitä ei käsitellä enää missään muualla
			# Esim. pause-menun skriptissä, jossa pelin jatkuminen
			get_viewport().set_input_as_handled()


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
		vihollisen_aanenkorkeuden_kerroin = abs(1 - (korkeuksien_erotus / ikkunan_korkeus) * vihollisen_aanenkorkeuden_muutosnopeus)
		if vihollisen_aanenkorkeuden_kerroin > 1:
			vihollisen_aanenkorkeuden_kerroin = 1
	else:
		vihollisen_aanenkorkeuden_kerroin = 1
	# "Vihollinen" audiokanavan pitch shift -efekti
	var vihollinen_pitch_shift = AudioServer.get_bus_effect(1, 0)
	# TODO: korjaa bugi, saa virheellisiä arvoja
	vihollinen_pitch_shift.pitch_scale = vihollisen_aanenkorkeuden_kerroin


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
	# Jos kuolee ilmassa ja respawnaa nii kuolee fall damageen
	pelaaja.putoamis_vahinko = false
	vihollinen.position = vihollinen_aloitus
	gameover_ruutu.visible = false
	
	# Aloittaa timerin alusta
	pelaaja.ajastin_pimeassa.start()


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
