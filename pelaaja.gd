## Harri, Paavo 17.3.2024
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
const SPEED = 200.0
const SPRINT = 300.0
const JUMP_VELOCITY = -450.0
const SPRINT_JUMP_HEIGHT = -350.0
const SPRINT_JUMP_SPEED = 1.4
const WALL_JUMP = 300.0

## Ohjaintähtäimen maksimietäisyys näytöllä
const MAX_TAHTAIN_ETAISYYS = 64

## Get the gravity from the project settings to be synced with RigidBody nodes.
## Eli napataan painovoima kimppaan rigidbodyjen kanssa.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*1.25
var current_jumps = 0
# Onko hypännyt juostessa
var has_sprint_jumped = false


func _ready():
	# Lisätään ajastin lapseksi
	self.add_child(ajastin_pimeassa)
	
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


## Tähän lisätty signaalin emit kokeilumielessä
func kuolema():
	kuollut.emit()


## Fysiikanhallintaa
func _physics_process(delta):
	
	# Tästä painovoima
	if not (is_on_floor() or is_on_wall()):
		velocity.y += gravity * delta
		# Seinää vasten liikkuessa kiipeää tai tippuu
	elif (is_on_wall()) and (Input.is_action_pressed("kiipea")):
		velocity.y = -gravity * delta * 6
	elif (is_on_wall()) and (Input.is_action_pressed("putoa")):
		velocity.y += gravity * delta
		# Ei tipu seinältä kun on paikallaan
	else:
		velocity.y = 0

	# Hyppy takaisin kun maassa
	if is_on_floor():
		current_jumps = 0
	
	
	## Tehdään hyppy
	if Input.is_action_just_pressed("hyppaa") and Input.is_action_pressed("juoksu") and is_on_floor():
		current_jumps += 1
		has_sprint_jumped = true
		velocity.y = SPRINT_JUMP_HEIGHT
	elif Input.is_action_just_released("hyppaa") and is_on_floor():
		current_jumps += 1
		velocity.y = JUMP_VELOCITY
		if animaatio.is_flipped_h():
			velocity.x += SPEED
		else:
			velocity.x -= SPEED
	elif current_jumps < 2 and is_on_wall() and Input.is_action_just_pressed("hyppaa"):
		current_jumps += 1
		has_sprint_jumped = false
		velocity.y = JUMP_VELOCITY
		if animaatio.is_flipped_h():
			velocity.x += WALL_JUMP
		else:
			velocity.x -= WALL_JUMP

	## input-kontrollit
	var direction = Input.get_axis("liiku_vasen", "liiku_oikea")
	if Input.is_action_pressed("hyppaa") and is_on_floor() and !Input.is_action_pressed("juoksu"):
		velocity.x = 0
		has_sprint_jumped = false
	else:
		if Input.is_action_pressed("juoksu"):
			if !is_on_floor() and has_sprint_jumped:
				velocity.x = direction * SPRINT * SPRINT_JUMP_SPEED
			else:
				velocity.x = direction * SPRINT
		else: 
			velocity.x = direction * SPEED
	
	# Liikutetaan pelaajaa
	move_and_slide()
	
	# Käynnistetään / pysäytetään pelaajan animaatio vasta liikkumisen jälkeen.
	# Tällöin pelaajan kävely/juoksuanimaatio ei jatku jos pelaaja kulkee seinää
	# päin.
	
	if is_on_floor():
		# Jos pelaaja on maassa eikä liiku, aloitetaan idle-animaatio
		if velocity.x == 0:
			animaatio.play("idle")
		else:
			# Muutoin aloitetaan kävelyanimaatio
			animaatio.play("kavely")
	else:
		# Tähän myöhemmin hyppyanimaatio
		animaatio.set_animation("idle")
		animaatio.stop()
	
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

	# light.height nyt 60, texture_scale 12   = 60           = 12
	# sopiva etäisyys 360, joka tulee (light.height * light.texture_scale) / 2
	# Pelkän pelaajan keskipisteen ja valon etäisyyden avulla tarkastelu tuntuisi toimivan hyvin
