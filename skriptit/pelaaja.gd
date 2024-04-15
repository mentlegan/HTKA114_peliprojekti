## Juuso 10.4.2024
## Harri, Paavo 17.3.2024
## Elias 17.3.2024 - Pelaajan äänet
## TODO: pelaajan hyppy- ja juoksuanimaatiot
## TODO: tallennuspisteet, joihin pelaaja siirretään respawn()-kutsun aikana
## TODO: pimeässä kuolemiselle animaatio / visuaalista palautetta ennen yhtäkkistä respawn()-kutsua
## TODO: valokukkien kerääminen signaaleilla get_overlapping_areas()-kutsun sijaan
extends CharacterBody2D
class_name Pelaaja

## Tästä signaalit, jotka lähtetään, kun jotain tapahtuu. Muut koodit osaavat ottaa nämä signaalit, ja käyttää niitä
signal kuollut

## Pelaajan hitbox
@onready var polygon = get_node("CollisionShape2D")
## Pelaajan animaatio
@onready var animaatio = get_node("Animaatio")
## Pelaajan alue ja valon tarkistus
@onready var valon_tarkistus = get_node("ValonTarkistus")
## Ohjaimen tähtäin
@onready var tahtain = get_node("Tahtain")
## Pelaajan labelit
@onready var elamat = get_node("Elamat")
@onready var palloja_label = get_node("Palloja")
@onready var apua_label = get_node("ApuaLabel")
## Pelaajan kamera
@onready var kamera = get_node("Camera2D")

## Totuusarvo valossa olemiselle
var valossa = false

## Ääniefektit
@onready var audio_kavely = $AudioKavely
@onready var audio_juoksu = $AudioJuoksu
@onready var audio_hyppy = $AudioHyppy
@onready var audio_seinahyppy = $AudioSeinahyppy
@onready var audio_pelaaja_kuolee = $AudioPelaajaKuolee
@onready var audio_pimeassa = $AudioPimeassa
@onready var audio_pimeyskuolema = $AudioPimeyskuolema
@onready var audio_valopallon_keraaminen = $AudioValopallonKeraaminen

## Näyttöä pimentävä valo
@onready var pimea_valo = $PimeaValo

## Huilu, äänen taajuuden sprite ja niiden ajastimet
@onready var huilu = $Huilu
@onready var huilun_collision = $Huilu/CollisionPolygon2D
@onready var huilun_cd_ajastin = $Huilu/CooldownAjastin
@onready var aanen_taajuus_sprite = $AanenTaajuus
@onready var aanen_taajuus_ajastin = $AanenTaajuus/Ajastin

# Huilun äänet
@onready var huilun_aanet = [
	$HuiluAaniA,
	$HuiluAaniC,
	$HuiluAaniE,
]

# Huilun partikkelit ja niiden säde
@onready var huilun_partikkelit = $Huilu/Partikkelit

# Äänen taajuus
var aanen_taajuus = 2
const AANEN_TAAJUUS_MIN = 1
const AANEN_TAAJUUS_MAX = 3
const AANEN_TAAJUUS_VARIT = [
	Color(1, 0, 0, 1),
	Color(1, 1, 0, 1),
	Color(0, 0, 1, 1)
]

## Ajastin pimeässä selviämiselle
var ajastin_pimeassa = Timer.new()
var ajastin_pimeassa_audio = Timer.new()
const SELVIAMISAIKA_PIMEASSA = 20 ## Kuinka kauan pimeässä selvitään ennen respawn()-kutsua, sekunneissa
const PIMEASSA_AUDION_VIIVE = 12 ## Kuinka monta sekuntia odotetaan pimeässä ennen pimeäkuoleman audion toistamista

## Valopallon kohde, jonne se heitetään, pelaajasta nähden.
## Joko hiiren global_position tai ohjaimen tatin suunta
var valon_kohde = Vector2(0, 0)
## Totuusarvo, käytetäänkö hiirtä vai tattia.
## Hiiri menee väliaikaisesti pois päältä, jos tattia liikutetaan
var hiiri_kaytossa = true
var hiiren_viime_sijainti = Vector2(0, 0)

## Ladataan valmiiksi valopallo
var valopallo = preload("res://scenet/valo_character.tscn")

## Asetetaan pelaajan nopeus ja hypyt
const MAX_NOPEUS = 180.0
const MAX_JUOKSU_NOPEUS = 260.0
const KIIHTYVYYS = 15.0
const JUOKSU_KIIHTYVYYS = 2
const KITKA = 15.0
const KAANTYSMIS_NOPEUS = 20
const HYPPY_VELOCITY = -520.0
const JUOKSU_HYPPY_KORKEUS = -460.0
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
# Oliko/onko pelaaja maassa tai seinällä (käytetään timerissa)
var oli_maassa = false
var oli_seinalla = false
# Toggle seinäkiipeämiselle
var kiipeamis_toggle = true

## Ajastin hyppyjen buffereille
var hyppy_ajastin_seinalla = Timer.new()
var hyppy_ajastin_maassa = Timer.new()
const SEINAHYPPY_BUFFER = 0.2 ## Kuinka kauan seinältä voi olla poissa, niin että pelaaja saa vielä hypätä (sekunteina)
const MAAHYPPY_BUFFER = 0.2 ## Kuinka kauan maalta voi olla poissa, niin että pelaaja saa vielä hypätä (sekunteina)

## Pelaajan elämäpisteet
const pelaajan_elamat_max = 6
var pelaajan_elamat = pelaajan_elamat_max
## Kuinka nopeasti pelaaja saa elämiä takaisin sekunteina
var elamat_regen_nopeus = 5
## Kuinka paljon elamia pelaaja saa takaisin
var elamat_regen_maara = 1

## Elämä regen ajastin
var elama_regen_ajastin = Timer.new()

## Miten pitkästi pelaaja voi tippua, kunnes siitä ottaa vahinkoa
var putoamis_raja_1 = 200
var putoamis_raja_2 = 300
var putoamis_raja_3 = 400
## Miten paljon vahinkoa kustakin korkeudesta ottaa
var putoamis_raja_1_dmg = 2
var putoamis_raja_2_dmg = 3
var putoamis_raja_3_dmg = 6
## Tarkistetaako maahan osuessa pudotuksen pituus, putoamis vahinkoa varten
var putoamis_vahinko = false
## Miltä korkeudelta pelaajan pudotus alkoi
var putoamis_huippu = get_global_position().y


func _ready():
	# Lisätään ajastimet pimeän tarkistukselle, hypyille ja elämä regeneraatiolle lapsiksi
	self.add_child(ajastin_pimeassa)
	self.add_child(ajastin_pimeassa_audio)
	self.add_child(hyppy_ajastin_seinalla)
	self.add_child(hyppy_ajastin_maassa)
	self.add_child(elama_regen_ajastin)
	
	# Lisätään pelaajan hp labeliin elamat
	elamat.text = "Health: " + str(pelaajan_elamat_max)
	
	# Hyppy mahdollisuus pois jos liian kauan pois seinältä
	hyppy_ajastin_seinalla.timeout.connect(hyppy_buffer_seinalla)
	# Hyppy mahdollisuus pois jos liian kauan pois maalta
	hyppy_ajastin_maassa.timeout.connect(hyppy_buffer_maassa)
	
	# Pelaaja kuolee, jos hän on pimeässä liian kauan
	ajastin_pimeassa.timeout.connect(kuolema)
	# Toistetaan lähestyvän pimeäkuoleman ääni, kun pelaaja on pimeässä
	ajastin_pimeassa_audio.timeout.connect(soitaPimeakuolemanAani)
	
	# Pelaajan elämä regeneraatio
	elama_regen_ajastin.timeout.connect(elama_regen)
	
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
	
	# Piilotetaan huilu, kun sen animaatio loppuu
	animaatio.animation_looped.connect(lopeta_huilu_animaatio)
	
	# Samoin piilotetaan äänen taajuuden sprite, kun sen ajastin päättyy
	aanen_taajuus_ajastin.timeout.connect(
		func(): aanen_taajuus_sprite.visible = false
	)
	
	# Asetetaan äänen taajuus yhdeksi
	vaihda_aanen_taajuutta(-1)
	aanen_taajuus_sprite.visible = false

	# Laitetaan huilun collision pois päältä
	huilun_collision.set_disabled(true)

	# Asetetaan idle-animaation pelin alussa
	animaatio.play("idle")


## Lopettaa huilu-animaation
func lopeta_huilu_animaatio():
	if animaatio.get_animation() == "huilu":
		animaatio.set_animation("idle")
		animaatio.stop()
		huilun_cd_ajastin.start()
		huilun_partikkelit.set_emitting(false)
		huilun_collision.set_disabled(true)


## Kun siirrytään valoon, lopetetaan ajastin
func siirrytty_valoon():
	valossa = true
	ajastin_pimeassa.stop()
	ajastin_pimeassa_audio.stop()
	audio_pimeyskuolema.stop()
	print("Valossa: " + str(valossa))


## Kun siirrytään varjoon, aloitetaan ajastin
func siirrytty_varjoon():
	valossa = false
	ajastin_pimeassa.start(SELVIAMISAIKA_PIMEASSA)
	ajastin_pimeassa_audio.start(PIMEASSA_AUDION_VIIVE)
	print("Valossa: " + str(valossa))
	await get_tree().create_timer(2.5).timeout
	audio_pimeassa.play()


## Tähän lisätty signaalin emit
func kuolema():
	audio_pelaaja_kuolee.play()
	pelaajan_elamat = pelaajan_elamat_max
	elamat_label_paivita()
	kuollut.emit()


## Toistaa pimeäkuoleman äänen kun oltu pimeässä vakion PIMEASSA_AUDION_VIIVE verran 
func soitaPimeakuolemanAani():
	audio_pimeyskuolema.play()


## Haetaan pelaajan elamat
func get_elamat():
	return pelaajan_elamat

func elamat_label_paivita():
	elamat.text = "Health: " + str(pelaajan_elamat)
	
func elama_regen():
	saa_elamia(elamat_regen_maara)
	if pelaajan_elamat < pelaajan_elamat_max:
		elama_regen_ajastin.start(elamat_regen_nopeus)

func saa_elamia(maara):
	if pelaajan_elamat + maara < pelaajan_elamat_max:
		pelaajan_elamat += maara
	else:
		pelaajan_elamat = pelaajan_elamat_max
	elamat_label_paivita()
	
func meneta_elamia(maara):
	if pelaajan_elamat - maara > 0:
		pelaajan_elamat -= maara
		elama_regen_ajastin.start(elamat_regen_nopeus)
	else:
		pelaajan_elamat = 0
		kuolema()
	elamat_label_paivita()


## Ei hyppyä kun liian kauan seinältä
func hyppy_buffer_seinalla():
	oli_seinalla = false
	
## Ei hyppyä kun liian kauan seinältä
func hyppy_buffer_maassa():
	oli_maassa = false


## Kun pelaaja on seinalla
func seinalla():
	oli_seinalla = true
	oli_maassa = false
	hyppy_ajastin_seinalla.stop()
	hyppyjen_maara = 0
	if is_on_wall():
		putoamis_vahinko = false

## Käännetään pelaajan animaatio jos väärin päin seinällä
func oikein_seinalla():
	if (animaatio.is_flipped_h() and get_wall_normal().x < 0):
		animaatio.set_flip_h(!animaatio.is_flipped_h())
	elif not animaatio.is_flipped_h() and get_wall_normal().x > 0:
		animaatio.set_flip_h(!animaatio.is_flipped_h())

## Palauttaa nykyisen äänen taajuuden värin
func aanen_taajuuden_vari():
	return AANEN_TAAJUUS_VARIT[(aanen_taajuus - 1) % AANEN_TAAJUUS_MAX]


## Vaihtaa äänen taajuutta delta-arvon verran.
func vaihda_aanen_taajuutta(delta):
	aanen_taajuus = aanen_taajuus + delta
	if aanen_taajuus > AANEN_TAAJUUS_MAX:
		aanen_taajuus = AANEN_TAAJUUS_MIN
	if aanen_taajuus < AANEN_TAAJUUS_MIN:
		aanen_taajuus = AANEN_TAAJUUS_MAX

	aanen_taajuus_sprite.visible = true
	aanen_taajuus_sprite.frame = aanen_taajuus - 1
	aanen_taajuus_ajastin.start()
	huilu.aanen_taajuus = aanen_taajuus
	aanen_taajuus_sprite.modulate = aanen_taajuuden_vari()


## Fysiikanhallintaa
func _physics_process(delta):
	var aiempi_hiiren_tila = hiiri_kaytossa
	
	# Seinäkiipeämiseen toggle
	# PC E
	if Input.is_action_just_pressed("kiipeamis_toggle"):
		# Oiva tapa muuttaa totuusarvo vastakkaiseksi
		kiipeamis_toggle = not kiipeamis_toggle
	
	# Tästä painovoima
	if not (is_on_floor() or is_on_wall()):
		if oli_seinalla and hyppy_ajastin_seinalla.is_stopped():
			hyppy_ajastin_seinalla.start(SEINAHYPPY_BUFFER)
		elif oli_maassa and hyppy_ajastin_maassa.is_stopped():
			hyppy_ajastin_maassa.start(MAAHYPPY_BUFFER)
		if velocity.y > -20 and velocity.y < 0:
			velocity.y += (gravity * delta) / 2
		elif velocity.y > 0 and velocity.y < 20:
			velocity.y += (gravity * delta) / 2
		elif velocity.y > 25:
			velocity.y += (gravity * delta) + velocity.y / 50
		else:
			velocity.y += gravity * delta
		if not putoamis_vahinko:
			putoamis_vahinko = true
			putoamis_huippu = get_global_position().y
		# Seinää vasten liikkuessa kiipeää tai tippuu
		# PC kiipeä: W, pudottaudu: S
	elif (oli_seinalla or is_on_wall()) and Input.is_action_pressed("kiipea") and kiipeamis_toggle:
		velocity.y = -gravity * delta * 6
		animaatio.play("seinakiipeaminen")
		oikein_seinalla()
		if animaatio.is_flipped_h() and not Input.is_action_pressed("liiku_oikea"):
			velocity.x = -300
		elif not Input.is_action_pressed("liiku_vasen"):
			velocity.x = 300
		seinalla()
	elif is_on_wall() and (Input.is_action_pressed("putoa") or not kiipeamis_toggle):
		animaatio.play("seinakiipeaminen")
		oikein_seinalla()
		velocity.y += gravity * delta
	# Ei tipu seinältä kun on paikallaan
	else:
		velocity.y = 0
		if is_on_wall():
			animaatio.play("seinakiipeaminen")
			animaatio.frame = 0
			oikein_seinalla()
		seinalla()

	# Hyppy takaisin kun maassa
	if is_on_floor():
		hyppyjen_maara = 0
		oli_maassa = true
		oli_seinalla = false
		if putoamis_vahinko:
			animaatio.scale = Vector2(1.1, 0.9)
			print(get_global_position().y - putoamis_huippu)
			if (get_global_position().y - putoamis_huippu) > putoamis_raja_3:
				meneta_elamia(putoamis_raja_3_dmg)
			elif (get_global_position().y - putoamis_huippu) > putoamis_raja_2:
				meneta_elamia(putoamis_raja_2_dmg)
			elif (get_global_position().y - putoamis_huippu) > putoamis_raja_1:
				meneta_elamia(putoamis_raja_1_dmg)
			putoamis_vahinko = false
	
	
	# Tehdään hyppy
	# PC SPACE_BAR
	if Input.is_action_just_pressed("hyppaa") and Input.is_action_pressed("juoksu") and oli_maassa and hyppyjen_maara < 1:
		hyppyjen_maara += 1
		velocity.y = JUOKSU_HYPPY_KORKEUS
		if is_on_floor():
			velocity.x = JUOKSU_HYPPY_NOPEUS * velocity.x
		animaatio.scale = Vector2(0.9, 1.1)
		audio_hyppy.play()
	elif Input.is_action_just_pressed("hyppaa") and oli_maassa and hyppyjen_maara < 1:
		hyppyjen_maara += 1
		velocity.y = HYPPY_VELOCITY
		animaatio.scale = Vector2(0.9, 1.1)
		audio_hyppy.play()
	elif oli_seinalla and Input.is_action_just_pressed("hyppaa"):
		hyppyjen_maara = 0
		velocity.y = SEINA_HYPPY_KORKEUS
		animaatio.scale = Vector2(0.9, 1.1)
		audio_seinahyppy.play()
		if velocity.x == 0:
			if animaatio.is_flipped_h():
				velocity.x = SEINA_HYPPY
			else:
				velocity.x = -SEINA_HYPPY
	
	animaatio.scale.x = move_toward(animaatio.scale.x, 1, 0.5 * delta)
	animaatio.scale.y = move_toward(animaatio.scale.y, 1, 0.5 * delta)
	
	# Otetaan pelaajan liikkeen haluttu suunta
	# PC vasen: A, oikea: D
	suunta = Input.get_axis("liiku_vasen", "liiku_oikea")
	## input-kontrollit
	var nopeus = 0
	if suunta != 0:
		# Juostessa eri nopeus
		# PC SHIFT
		if Input.is_action_pressed("juoksu"):
			nopeus = MAX_JUOKSU_NOPEUS
		else:
			nopeus = MAX_NOPEUS
		# Jos ei ole vielä vaihtanut suuntaa, kiihtyy haluttuun suuntaan nopeampaa (eli kääntyessä)
		if (suunta < 0 and velocity.x > 0) or (suunta > 0 and velocity.x < 0):
			velocity.x = move_toward(velocity.x, suunta * nopeus, KAANTYSMIS_NOPEUS)
		elif (velocity.x < -MAX_NOPEUS or velocity.x > MAX_NOPEUS) and not is_on_wall():
			velocity.x = move_toward(velocity.x, suunta * nopeus, JUOKSU_KIIHTYVYYS)
			if animaatio.is_flipped_h():
				animaatio.rotation = move_toward(animaatio.rotation, suunta+0.8, delta * velocity.x * suunta / 580)
			else:
				animaatio.rotation = move_toward(animaatio.rotation, suunta-0.8, delta * velocity.x * suunta / 580)
		else:
			velocity.x = move_toward(velocity.x, suunta * nopeus, KIIHTYVYYS)
			
	# Hidastetaan kun ei liikuta mihinkään suuntaan
	else:
		velocity.x = move_toward(velocity.x, 0, KITKA)
	
	if velocity.x > -MAX_NOPEUS and velocity.x < MAX_NOPEUS:
		animaatio.rotation = move_toward(animaatio.rotation, 0, delta)
	# Liikutetaan pelaajaa
	move_and_slide()
	
	# Käynnistetään / pysäytetään pelaajan animaatio vasta liikkumisen jälkeen.
	# Tällöin pelaajan kävely/juoksuanimaatio ei jatku jos pelaaja kulkee seinää
	# päin.
	
	if animaatio.get_animation() != "huilu":
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
			audio_kavely.stop()

			if not is_on_wall() and not is_on_floor():
				# Asetetaan hyppyanimaatio
				animaatio.set_animation("hyppy")
				animaatio.stop()
				if velocity.y < 0:
					animaatio.frame = 0
				else:
					animaatio.frame = 1
	
	# Flipataan animaatio suuntaa myöten
	if velocity.x != 0:
		animaatio.set_flip_h(velocity.x < 0)
	
	# polygon on PackedVector2Array
	# var vec = Vector2(player.position + abs(hitbox.polygon[1]))
	# print(vec)
	
	# Ohjaimen tatin arvot
	# CONTROLLER RIGHT STICK
	var ohjain_tahtays = Vector2(
		Input.get_axis("tahtaa_vasen", "tahtaa_oikea"),
		Input.get_axis("tahtaa_ylos", "tahtaa_alas")
	)
	
	# Vasemman tatin arvot
	# CONTROLLER LEFT STICK
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
		tahtain.visible = true
		tahtain.position = valon_kohde
		hiiren_viime_sijainti = hiiren_sijainti
		hiiri_kaytossa = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Asetetaan hiiri takaisin käyttöön, jos se on liikkunut viime paikaltaan.
	if hiiren_viime_sijainti.distance_to(hiiren_sijainti) > 20:
		hiiri_kaytossa = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		tahtain.visible = false
	
	# Jos liikutaan, piilotetaan tähtäin
	if velocity.length() > 1:
		tahtain.visible = false
	
	# Asetetaan valon suunnaksi hiiren sijainti, jos ei käytetä tattia.
	if hiiri_kaytossa:
		valon_kohde = hiiren_sijainti
	
	# PC LEFT_CLICK
	if Input.is_action_just_pressed("painike_vasen"):
		# Tällä hetkellä 2 maksimissaan
		if Globaali.nykyiset_pallot < 2 and Globaali.palloja > 0:
			# Valon synnyttäminen
			var l = valopallo.instantiate()
			# Liikkuminen valon scriptissä
			l.move(self.position, valon_kohde + global_position)
			# Lisääminen puuhun
			get_tree().root.add_child(l)
			
			# Muuttujiin muutokset
			Globaali.nykyiset_pallot += 1
			Globaali.palloja -= 1
	
	# Nostetaan ja lasketaan äänen taajuutta tarvittaessa
	# PC MOUSE_WHEEL
	if Input.is_action_just_pressed("laske_taajuutta"):
		vaihda_aanen_taajuutta(-1)
	if Input.is_action_just_pressed("nosta_taajuutta"):
		vaihda_aanen_taajuutta(1)
	
	# PC RIGHT_CLICK
	if Input.is_action_just_pressed("painike_oikea"):
		# Käynnistetään huilun animaatio
		if huilun_cd_ajastin.is_stopped():
			animaatio.play("huilu")
			huilu.rotation = valon_kohde.angle()
			#animaatio.set_flip_h(valon_kohde.x < 0)
			huilun_collision.set_disabled(false)
			huilun_cd_ajastin.start()
			huilun_partikkelit.set_emitting(true)
			huilun_partikkelit.set_gravity(Vector2.from_angle(huilu.rotation) * 40)
			huilun_partikkelit.modulate = aanen_taajuuden_vari()
			huilun_aanet[(aanen_taajuus - 1) % AANEN_TAAJUUS_MAX].play()
	
	# Kukkien kerääminen JA MINECARTIN KÄYTTÄMINEN
	# PC F
	if Input.is_action_just_pressed("keraa_kukka"):
		# TODO: tämä myöhemmin signaaleilla
		var kukat = valon_tarkistus.get_overlapping_areas()
		for kukka in kukat:
			if kukka.is_in_group("kukka"):
				Globaali.palloja = 2
				audio_valopallon_keraaminen.play()
			elif kukka.is_in_group("minecart"):
				# Tehty nyt täällä, myöhemmin kerkiää optimoida
				self.position = Globaali.taso1_loppu
				Globaali.minecartit.queue_free()
				Globaali.poista_minecart_tooltipit()

	# player.visible = ! (raycast.is_colliding())

	# light.KORKEUS nyt 60, texture_scale 12   = 60           = 12
	# sopiva etäisyys 360, joka tulee (light.KORKEUS * light.texture_scale) / 2
	# Pelkän pelaajan keskipisteen ja valon etäisyyden avulla tarkastelu tuntuisi toimivan hyvin
	if hiiri_kaytossa != aiempi_hiiren_tila:
		Globaali.vaihda_tooltip_ui(hiiri_kaytossa)


## Asettaa UI:n näkyvyyden
func aseta_ui_nakyvyys(nakyvissa):
	elamat.visible = nakyvissa
	palloja_label.visible = nakyvissa
	apua_label.visible = nakyvissa


## Palauttaa pelaajan oman kameran aktiiviseksi
func palauta_kamera():
	kamera.make_current()


## Kun huiluun osuu rigid/staticbody, tarkistetaan onko se ovi.
## Jos on, vaihdetaan kameraa ja näytetään tason ovet hetkeksi.
func _on_huilu_body_entered(body):
	if aanen_taajuus == 3:
		var nimi = body.get_name()
		if nimi == "Osuu" or nimi == "Kimpoaa":
			Globaali.nayta_tason_ovet(body.global_position)
