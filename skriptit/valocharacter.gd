## Juuso 10.4.2024
## Elias 17.2.2024 - valopallon äänet
## TODO: pelaajan hyppy- ja juoksuanimaatiot
## TODO: jostain syystä valopallon hajoamisääni ei soi
extends CharacterBody2D

const PARTIKKELIT_VALOPALLO = preload("res://scenet/partikkelit_valopallo.tscn")

## Valon nopeus
var SPEED = 110.0

## Ladataan ovet valmiiksi
## Tehty nyt näin manuaalisesti eri assetteina, jotta esimerkiksi ovia voi venyttää
## Jos tehtäisiin kaikki koodin puolell1a (esim. tekstuurien laittaminen), ei voisi näin tehdä
@onready var ovi_vasen_x = preload("res://scenet/ovet/ovi_vasen_x.tscn")
@onready var ovi_oikea_x = preload("res://scenet/ovet/ovi_oikea_x.tscn")
@onready var ovi_vasen_y = preload("res://scenet/ovet/ovi_vasen_y.tscn")
@onready var ovi_oikea_y = preload("res://scenet/ovet/ovi_oikea_y.tscn")
@onready var ovi_vasen_z = preload("res://scenet/ovet/ovi_vasen_z.tscn")
@onready var ovi_oikea_z = preload("res://scenet/ovet/ovi_oikea_z.tscn")

@onready var ovi_pysty_oikea = preload("res://scenet/ovet/ovi_pysty_oikea.tscn")
@onready var ovi_vaaka_vasen = preload("res://scenet/ovet/ovi_vaaka_vasen.tscn")

@onready var valo: PointLight2D = $PointLight2D
@onready var valo_2: PointLight2D = $PointLight2D2

## Audiot
@onready var audio_valopallon_heitto = $AudioValopallonHeitto
@onready var audio_valopallon_kimpoaminen = $AudioValopallonKimpoaminen
@onready var audio_valopallo_hajoaa = $AudioValopalloHajoaa
@onready var audio_koynnos_ovi = $AudioKoynnosOvi

## Valopallon sprite, käytetään tuhoamisanimaation aikana
@onready var sprite = $Sprite2D

## Kimpoamiset ja ajastin valopallon tuhoamiselle
var kimpoamiset = 0
## Tällä hetkellä 7.0 sekuntia elossa
@onready var elo_aika = get_node("Timer")
var tween: Tween


## Kytketään ajastimen loppuminen valopallon tuhoamiseen
func _ready():
	elo_aika.timeout.connect(start_destroy)
	audio_valopallon_heitto.play()


func move(_position, _mouse):
	# Aluksi pelaajan kohtaan
	position = _position
	
	# Normalisoidun suunnan laskeminen valopallon sijainnista klikattuun kohtaan
	var light_direction = Vector2(self.position.x, self.position.y).direction_to(_mouse)
	velocity = light_direction * SPEED


## Valopallojen tuhoamiseen liittyvä käsittely
func start_destroy():
	if not audio_valopallo_hajoaa.playing:
		audio_valopallo_hajoaa.play()
	# Pysäytetään valopallo
	velocity = Vector2(0, 0)
	
	# Vaihdetaan blend_mode, jotta ei "syö" muita valoja tuhoutuessa
	# BLEND_MODE_ADD = 0, sub on 1 ja mix 2
	valo.blend_mode = PointLight2D.BLEND_MODE_ADD
	
	# Vähennetään valopallon energiaa ja kokoa. Tuhotaan valopallo animaation päätyttyä
	var tween_pallo = create_tween()
	tween_pallo.set_parallel(true)
	tween_pallo.set_trans(Tween.TRANS_CUBIC)
	tween_pallo.tween_property(valo, "energy", 0, 1)
	tween_pallo.tween_property(valo, "texture_scale", 0, 1)
	tween_pallo.tween_property(valo_2, "energy", 0, 1.2)
	tween_pallo.tween_property(valo_2, "texture_scale", 0, 1.2)
	tween_pallo.tween_property(sprite, "modulate", Color.TRANSPARENT, 1)
	tween_pallo.finished.connect(
		func():
			queue_free()
			Globaali.maailma.nykyiset_pallot -= 1
	)


## Muuttaa ovet, jos valopallo osuu x tai z oveen
## Attribuuttina tulee ryhmän nimi (x tai z)
## _ovi_ylin on ylin node, joka sisältää kaikki tason ovet
## if_y kertoo osuuko pallo oveen y, tällöin käydään kaikki ovet aina läpi
func change_doorsXYZ(_kirjain, _ovi_ylin, if_y):
	# Alustetaan ovet vasta silmukassa tarvittaessa
	""""
	var ovi_v_x = null
	var ovi_o_x = null
	var ovi_v_y = null
	var ovi_o_y = null
	var ovi_v_z = null
	var ovi_o_z = null
	"""
	
	# Tallenetaan kirjain
	var kirjain = _kirjain
	# Talteen node, joka sisältää tason ovet. Käytetään vielä ristiovessa
	var ovi_ylin = _ovi_ylin
	# Varsinaiset muokattavat ovet
	var tason_ovet = ovi_ylin.get_children()
	
	for ovi in tason_ovet:
		# Ehto sille, mille oville tehdään operaatio   tämä vain, kun osuu y (kaikki ovet)
		if ovi.is_in_group(kirjain) or ovi.is_in_group("y") or if_y and ovi is not PointLight2D and ovi is not CPUParticles2D:
			# Otetaan ryhmät tarkastelua varten
			var ryhmat = ovi.get_groups()
			# Käsitellään kuolematon ja ristiovi ekana
			if ryhmat.has("kuolematon") or ryhmat.has("risti"):
				continue
			
			var ovi_todellinen = ovi.get_child(0)
			var collisionit = Array()
			for lapsi in ovi_todellinen.get_children():
				if lapsi is StaticBody2D:
					collisionit.append(lapsi.get_child(0))
			var animaatio = ovi_todellinen.get_node_or_null("AnimatedSprite2D")
			if animaatio.is_playing():
				return
			# Jos kiinni tai playing
			if animaatio.frame != 5:
				animaatio.play("change")
				for collision in collisionit:
					collision.disabled = true
			else: # Auki
				animaatio.play_backwards("change")
				for collision in collisionit:
					collision.disabled = false
	
	# Pelkkä ristiovi                         # vain tasossa 3
	if Globaali.maailma.ovi_risti != null and ovi_ylin.get_name() == "Ovet_3":
		var ovi_pysty = ovi_pysty_oikea.instantiate()
		var ovi_vaaka = ovi_vaaka_vasen.instantiate()
		
		# Tuhotaan kaikki lapset varmistukseksi
		var ristit = Globaali.maailma.ovi_risti.get_children()
		for risti in ristit:
			risti.queue_free()
		
		if Globaali.maailma.pystyssa:
			Globaali.maailma.ovi_risti.add_child(ovi_vaaka)
			Globaali.maailma.pystyssa = false
		else:
			Globaali.maailma.ovi_risti.add_child(ovi_pysty)
			Globaali.maailma.pystyssa = true


func _on_vesi_tarkistus_area_entered(area) -> void:
	if area is Vesi2D or area.is_in_group("perhonen_hitbox"):
		start_destroy()


func _physics_process(delta):
	"""
	if Input.is_action_just_pressed("painike_oikea"):
		# Tuhotaan valopallo kokonaan
		audio_valopallo_hajoaa.play() # TODO: Jostain syystä ei soi
		queue_free()
		Globaali.maailma.nykyiset_pallot = 0
	"""
	
	# Valon liikkuminen
	var collision = move_and_collide(velocity * delta)
	# Jos osuu johonkin
	if collision:
		# Otetaan talteen törmäyksen kohde
		var collision_collider = collision.get_collider()
		# Jos osuu köynnösoveen
		if collision_collider.is_in_group("oviAVAA"):
			# Otetaan ovi, joka tuhotaan
			var parent = collision_collider.get_parent()
			# Otetaan ylin ovi-node
			var ovi_muokattava = parent.get_parent()
			# Ylimmän noden ryhmät eli x, y tai z
			var groups = ovi_muokattava.get_groups()
			
			# Minkä tason ovet kyseessä (ovet_1 tai ovet_2 jne...)
			var ovi_ylin = ovi_muokattava.get_parent()
			
			# Ryhmien kanssa tuli onglemia, joten muutettu ilman alaviivaa oleviksi
			# Välillä ei toiminut esim. kaikilla ovilla, joilla ryhmänä x
			# Ovien järjestys hierarkiassa muutti myös tuloksia, outoa
			# Ovien duplikointi saattoi myös vaikuttaa ongelmiin, kannattaa välttää
			# Tekee vain uuden node2D ja sille ryhmät
			
			## HUOM. RYHMIEN LAITTAMINEN GLOBAALIKSI TAISI KORJATA KAIKEN
			## SIIRRETTÄVÄ MUUALLE LUULTAVASTI
			## PELISUUNNITELMASSA ON AVATTU OVIEN TOIMINNALLISUUS, TÄSSÄ VAIN TOTEUTUS
			
			# Kirjain ovien muokkauksille
			# Ei voi ottaa suoraan ryhmistä, koska taulukon järjestys ei pysy aina samana,
			# voisi ottaa jos karsisi pois oviV tai oviO
			var kirjain
			
			# Ovien muokkaus
			# X ja y
			if groups.has("x"):
				kirjain = "x"
				change_doorsXYZ(kirjain, ovi_ylin, false)
			
			# Kaikki ovet x, y, z
			elif groups.has("y"):
				kirjain = "" # Ei väliä
				change_doorsXYZ(kirjain, ovi_ylin, true)
			
			# Y ja z
			elif groups.has("z"):
				kirjain = "z"
				change_doorsXYZ(kirjain, ovi_ylin, false)
			
			# Ristiovi
			elif groups.has("risti"):
				kirjain = ""
				change_doorsXYZ(kirjain, ovi_ylin, false)
			
			# Voisiko olla parempi tapa?
			"""
			for group in groups:
				# Karsitaan kaikki muut ryhmät pois paitsi x, y tai z
				if not (group.begins_with("x") or group.begins_with("y") or group.begins_with("z")):
					groups.remove_from_group(group)
			"""
			
			# Poistetaan collision, etenkin ristioven kohdalla positionin tweenaus tuotti ongelmia
			$CollisionShape2D.disabled = true
			# Pallo imeytyy oveen
			var pallon_siirto_tween = create_tween().set_trans(Tween.TRANS_QUAD)
			pallon_siirto_tween.set_ease(Tween.EASE_IN_OUT)
			pallon_siirto_tween.tween_property(self, "position", parent.global_position, 1)
			audio_koynnos_ovi.play()
			await get_tree().create_timer(0.2, false).timeout
			start_destroy()
		else: # Kimpoaminen
			velocity = velocity.bounce(collision.get_normal())
			if tween:
				tween.kill()
			tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_BACK)
			tween.tween_property(valo, "energy", valo.energy * 0.8, 0.5)
			tween.tween_property(valo_2, "energy", valo.energy * 0.8, 0.5)
			# Keskimäärin vähennetään nopeutta hiukan kimmotessa
			# Voi joskus myös nopeutua :)
			velocity *= randf_range(0.8, 1.1)
			# Lisätään kimmotusten määrää
			kimpoamiset += 1
			var partikkelit = PARTIKKELIT_VALOPALLO.instantiate()
			partikkelit.global_position = self.global_position
			get_tree().root.add_child(partikkelit)
			if kimpoamiset >= 5:
				start_destroy()
			else:
				audio_valopallon_kimpoaminen.play()
