## Harri, Paavo 17.3.2024
## Elias 17.3.2024 - Pelaajan äänet
## TODO: pelaajan hyppy- ja juoksuanimaatiot
## TODO: tallennuspisteet, joihin pelaaja siirretään respawn()-kutsun aikana
## TODO: pimeässä kuolemiselle animaatio / visuaalista palautetta ennen yhtäkkistä respawn()-kutsua
## TODO: valokukkien kerääminen signaaleilla get_overlapping_areas()-kutsun sijaan
## TODO: input controlsien funktioiden dokumentaatioon aina nykyinen controlli
extends CharacterBody2D
class_name Pelaaja

## Koitetaan signaalia
signal kuollut
signal pause

## Pelaajan hitbox
@onready var polygon = get_node("CollisionShape2D")
## Pelaajan animaatio
@onready var animaatio = get_node("Animaatio")
## Pelaajan alue ja valon tarkistus
@onready var valon_tarkistus = get_node("ValonTarkistus")
## Ohjaimen tähtäin
@onready var tahtain = get_node("Tahtain")
## Totuusarvo valossa olemiselle
var valossa = false

## Ääniefektit
@onready var audio_kavely = $AudioKavely
@onready var audio_juoksu = $AudioJuoksu
@onready var audio_hyppy = $AudioHyppy
@onready var audio_seinahyppy = $AudioSeinahyppy
@onready var audio_pelaaja_kuolee = $AudioPelaajaKuolee
@onready var audio_pimeassa = $AudioPimeassa

## Näyttöä pimentävä valo
@onready var pimea_valo = $PimeaValo

## Ajastin pimeässä selviämiselle
var ajastin_pimeassa = Timer.new()
const SELVIAMISAIKA_PIMEASSA = 20 ## Kuinka kauan pimeässä selvitään ennen respawn()-kutsua, sekunneissa

## Valopallon kohde, jonne se heitetään, pelaajasta nähden.
## Joko hiiren global_position tai ohjaimen tatin suunta
var valon_kohde = Vector2(0, 0)
## Totuusarvo, käytetäänkö hiirtä vai tattia.
## Hiiri menee väliaikaisesti pois päältä, jos tattia liikutetaan
var hiiri_kaytossa = true
var hiiren_viime_sijainti = Vector2(0, 0)

## Ladataan valmiiksi valopallo
var light = preload("res://valo_character.tscn")

## Asetetaan pelaajan nopeus ja hypyt
const MAX_NOPEUS = 200.0
const MAX_JUOKSU_NOPEUS = 300.0
const KIIHTYVYYS = 25.0
const KITKA = 15.0
const KAANTYSMIS_NOPEUS = 1.5
const HYPPY_VELOCITY = -500.0
const JUOKSU_HYPPY_KORKEUS = -400.0
const JUOKSU_HYPPY_NOPEUS = 1.4
const SEINA_HYPPY = 50.0
const SEINA_HYPPY_KORKEUS = -400.0
var suunta = Vector2.ZERO

## Ohjaintähtäimen maksimietäisyys näytöllä
const MAX_TAHTAIN_ETAISYYS = 64

## Get the gravity from the project settings to be synced with RigidBody nodes.
## Eli napataan painovoima kimppaan rigidbodyjen kanssa.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*1.25
var hyppyjen_maara = 0
# Onko pelaaja seinällä (käytetään timerissa)
var onko_seinalla = false
# Toggle seinäkiipeämiselle
var kiipeamis_toggle = false

## Ajastin seinähypyn bufferille
var hyppy_ajastin = Timer.new()
const SEINAHYPPY_BUFFER = 0.1 ## Kuinka kauan seinältä voi olla poissa, niin että pelaaja saa vielä hypätä (sekunteina)

func _ready():
	# Lisätään ajastimet pimeän tarkistukselle ja seinähypylle lapsiksi
	self.add_child(ajastin_pimeassa)
	self.add_child(hyppy_ajastin)
	
	# Hyppy mahdollisuus pois jos liian kauan pois seinältä
	hyppy_ajastin.timeout.connect(hyppy_buffer)
	
	# Pelaaja kuolee, jos hän on pimeässä liian kauan
	ajastin_pimeassa.timeout.connect(kuolema)
	
	# Yhdistetään valon signaalit pelaajan omiin funktioihin
	valon_tarkistus.connect("siirrytty_valoon", siirrytty_valoon)
	valon_tarkistus.connect("siirrytty_varjoon", siirrytty_varjoon)
	
	# Tarkistetaan pelin alussa, ollaanko valossa
	if valon_tarkistus.on_valossa():
		siirrytty_valoon()
	else:
		siirrytty_varjoon()
	
	# Asetetaan pimeä-valo näkyviin pelin alussa
	pimea_valo.visible = true



## Kun siirrytään valoon, lopetetaan ajastin
func siirrytty_valoon():
	valossa = true
	ajastin_pimeassa.stop()
	print("Valossa: " + str(valossa))


## Kun siirrytään varjoon, aloitetaan ajastin
func siirrytty_varjoon():
	valossa = false
	ajastin_pimeassa.start(SELVIAMISAIKA_PIMEASSA)
	print("Valossa: " + str(valossa))
	await get_tree().create_timer(2.5).timeout
	audio_pimeassa.play()


## Tähän lisätty signaalin emit kokeilumielessä
func kuolema():
	audio_pelaaja_kuolee.play() # TODO: Korjaa toimivaksi. Ei kuulu, koska kaikki pausetetaan
	kuollut.emit()

## Ei hyppyä kun liian kauan seinältä
func hyppy_buffer():
	onko_seinalla = false

## Kun pelaaja on seinalla
func seinalla():
	onko_seinalla = true
	hyppy_ajastin.stop()
	if hyppyjen_maara < 1:
		hyppyjen_maara += 1

## Fysiikanhallintaa
func _physics_process(delta):
	
	# Seinäkiipeämiseen toggle
	if Input.is_action_just_pressed("kiipeamis_toggle"):
		if kiipeamis_toggle:
			kiipeamis_toggle = false
		else:
			kiipeamis_toggle = true
	
	# Tästä painovoima
	if not (is_on_floor() or is_on_wall()):
		if onko_seinalla and hyppy_ajastin.is_stopped():
			hyppy_ajastin.start(SEINAHYPPY_BUFFER)
		velocity.y += gravity * delta
		# Seinää vasten liikkuessa kiipeää tai tippuu
	elif is_on_wall() and Input.is_action_pressed("kiipea") and kiipeamis_toggle:
		velocity.y = -gravity * delta * 6
		seinalla()
	elif is_on_wall() and (Input.is_action_pressed("putoa") or not kiipeamis_toggle):
		velocity.y += gravity * delta
		seinalla()
		# Ei tipu seinältä kun on paikallaan
	else:
		velocity.y = 0
		if is_on_wall():
			seinalla()
		
	# Hyppy takaisin kun maassa
	if is_on_floor():
		hyppyjen_maara = 0
		onko_seinalla = false
	
	
	## Tehdään hyppy
	if Input.is_action_just_pressed("hyppaa") and Input.is_action_pressed("juoksu") and is_on_floor() and hyppyjen_maara < 1:
		hyppyjen_maara += 1
		velocity.y = JUOKSU_HYPPY_KORKEUS
		audio_hyppy.play()
	elif Input.is_action_just_pressed("hyppaa") and is_on_floor() and hyppyjen_maara < 1:
		hyppyjen_maara += 1
		velocity.y = HYPPY_VELOCITY
		audio_hyppy.play()
	elif hyppyjen_maara < 2 and onko_seinalla and Input.is_action_just_pressed("hyppaa"):
		hyppyjen_maara += 1
		velocity.y = SEINA_HYPPY_KORKEUS
		audio_seinahyppy.play()
		if velocity.x == 0:
			if animaatio.is_flipped_h():
				velocity.x = SEINA_HYPPY
			else:
				velocity.x = -SEINA_HYPPY
	
	# Otetaan pelaajan liikkeen haluttu suunta
	suunta = Input.get_axis("liiku_vasen", "liiku_oikea")
	## input-kontrollit
	var nopeus = 0
	if suunta != 0:
		# Juostessa eri nopeus
		if Input.is_action_pressed("juoksu"):
			nopeus = MAX_JUOKSU_NOPEUS
		else:
			nopeus = MAX_NOPEUS
		# Jos ei ole vielä vaihtanut suuntaa, kiihtyy haluttuun suuntaan nopeampaa (eli kääntyessä)
		if (suunta < 0 and velocity.x > 0) or (suunta > 0 and velocity.x < 0):
			velocity.x = move_toward(velocity.x, suunta * nopeus, KIIHTYVYYS * KAANTYSMIS_NOPEUS)
		else:
			velocity.x = move_toward(velocity.x, suunta * nopeus, KIIHTYVYYS)
	# Hidastetaan kun ei liikuta mihinkään suuntaan
	else:
		velocity.x = move_toward(velocity.x, 0, KITKA)
	
	# Liikutetaan pelaajaa
	move_and_slide()
	
	# Käynnistetään / pysäytetään pelaajan animaatio vasta liikkumisen jälkeen.
	# Tällöin pelaajan kävely/juoksuanimaatio ei jatku jos pelaaja kulkee seinää
	# päin.
	
	if is_on_floor():
		# Jos pelaaja on maassa eikä liiku, aloitetaan idle-animaatio
		if velocity.x == 0:
			animaatio.play("idle")
			audio_kavely.stop()
			audio_juoksu.stop()
		elif Input.is_action_pressed("juoksu"):
			animaatio.play("kavely")
			if not audio_juoksu.playing:
				audio_juoksu.play()
		else:
			# Muutoin aloitetaan kävelyanimaatio
			animaatio.play("kavely")
			if not audio_kavely.playing:
				audio_kavely.play()
	else:
		# Tähän myöhemmin hyppyanimaatio
		animaatio.set_animation("idle")
		animaatio.stop()
		audio_kavely.stop()
	
	# Flipataan animaatio suuntaa myöten
	if velocity.x != 0:
		animaatio.set_flip_h(velocity.x < 0)
	
	# polygon on PackedVector2Array
	# var vec = Vector2(player.position + abs(hitbox.polygon[1]))
	# print(vec)
	
	# Ohjaimen tatin arvot
	var ohjain_tahtays = Vector2(
		Input.get_axis("tahtaa_vasen", "tahtaa_oikea"),
		Input.get_axis("tahtaa_ylos", "tahtaa_alas")
	)
	
	# Vasemman tatin arvot
	var ohjain_tahtays_alt = Vector2(
		Input.get_axis("tahtaa_vasen_alt", "tahtaa_oikea_alt"),
		Input.get_axis("tahtaa_ylos_alt", "tahtaa_alas_alt")
	)
	
	# Käytetään vasenta tattia tähtäykseen, jos oikeaa tattia ei käytetä
	if ohjain_tahtays == Vector2.ZERO:
		ohjain_tahtays = ohjain_tahtays_alt
	
	# Hiiren sijainti, otetaan tässä niin on varmasti oikein
	var hiiren_sijainti = get_global_mouse_position() - global_position
	
	# Ohjainta käytettäessä asetetaan valon suunnaksi ohjaimen tatti hiiren sijaan
	# Asetetaan samalla hiiri pois käytöstä kunnes sitä liikutetaan
	if ohjain_tahtays != Vector2.ZERO:
		valon_kohde = ohjain_tahtays.normalized() * MAX_TAHTAIN_ETAISYYS
		#tahtain.visible = true
		tahtain.position = valon_kohde
		hiiren_viime_sijainti = hiiren_sijainti
		hiiri_kaytossa = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Asetetaan hiiri takaisin käyttöön, jos se on liikkunut viime paikaltaan.
	if hiiren_viime_sijainti.distance_to(hiiren_sijainti) > 20:
		hiiri_kaytossa = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#tahtain.visible = false
	
	# Asetetaan valon suunnaksi hiiren sijainti, jos ei käytetä tattia.
	if hiiri_kaytossa:
		valon_kohde = hiiren_sijainti
	
	if Input.is_action_just_pressed("painike_vasen"):
		# Tällä hetkellä 2 maksimissaan
		if Globaali.nykyiset_pallot < 2 and Globaali.palloja > 0:
			# Valon synnyttäminen
			var l = light.instantiate()
			# Liikkuminen valon scriptissä
			l.move(self.position, valon_kohde + global_position)
			# Lisääminen puuhun
			get_tree().root.add_child(l)
			
			# Muuttujiin muutokset
			Globaali.nykyiset_pallot += 1
			Globaali.palloja -= 1
	
	if Input.is_action_just_pressed("painike_oikea"):
		# Valopallo scriptissä tuhotaan kaikki valopallot, varmaan muutettava
		Globaali.nykyiset_pallot = 0
	
	# Kukkien kerääminen
	# PC F
	if Input.is_action_just_pressed("keraa_kukka"):
		# TODO: tämä myöhemmin signaaleilla
		var kukat = valon_tarkistus.get_overlapping_areas()
		for kukka in kukat:
			if kukka.is_in_group("kukka"):
				Globaali.palloja = 2
		
	# Pelin keskeytys
	# PC Escape
	# PS4/PS5 Options
	if Input.is_action_just_pressed("pause"):
		Globaali.pausePeli()
	
	# player.visible = ! (raycast.is_colliding())

	# light.KORKEUS nyt 60, texture_scale 12   = 60           = 12
	# sopiva etäisyys 360, joka tulee (light.KORKEUS * light.texture_scale) / 2
	# Pelkän pelaajan keskipisteen ja valon etäisyyden avulla tarkastelu tuntuisi toimivan hyvin
