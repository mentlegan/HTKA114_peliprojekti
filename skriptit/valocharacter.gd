## Juuso 10.4.2024
## Elias 17.2.2024 - valopallon äänet
## TODO: pelaajan hyppy- ja juoksuanimaatiot
## TODO: jostain syystä valopallon hajoamisääni ei soi
extends CharacterBody2D

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

@onready var valo = get_node("PointLight2D")

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
	# Pysäytetään valopallo
	velocity = Vector2(0, 0)

	# Vaihdetaan blend_mode, jotta ei "syö" muita valoja tuhoutuessa
	# BLEND_MODE_ADD = 0, sub on 1 ja mix 2
	valo.blend_mode = 0

	# Vähennetään valopallon energiaa ja kokoa. Tuhotaan valopallo animaation päätyttyä
	var tween_pallo = create_tween()
	tween_pallo.set_parallel(true)
	tween_pallo.set_trans(Tween.TRANS_CUBIC)
	tween_pallo.tween_property(valo, "energy", 0, 1)
	tween_pallo.tween_property(valo, "texture_scale", 0, 1)
	tween_pallo.tween_property(sprite, "modulate", Color.TRANSPARENT, 1)
	tween_pallo.finished.connect(
		func():
			queue_free()
			Globaali.nykyiset_pallot -= 1
	)


## Muuttaa ovet, jos valopallo osuu x tai z oveen
## Attribuuttina tulee ryhmän nimi (x tai z)
## _ovi_ylin on ylin node, joka sisältää kaikki tason ovet
## if_y kertoo osuuko pallo oveen y, tällöin käydään kaikki ovet aina läpi
func change_doorsXYZ(_kirjain, _ovi_ylin, if_y):
	# Alustetaan ovet vasta silmukassa tarvittaessa
	var ovi_v_x = null
	var ovi_o_x = null
	var ovi_v_y = null
	var ovi_o_y = null
	var ovi_v_z = null
	var ovi_o_z = null
	
	# Tallenetaan kirjain
	var kirjain = _kirjain
	# Talteen node, joka sisältää tason ovet. Käytetään vielä ristiovessa
	var ovi_ylin = _ovi_ylin
	# Varsinaiset muokattavat ovet
	var tason_ovet = ovi_ylin.get_children()
	
	for ovi in tason_ovet:
		# Ehto sille, mille oville tehdään operaatio   tämä vain, kun osuu y (kaikki ovet)
		if ovi.is_in_group(kirjain) or ovi.is_in_group("y") or if_y:
			# Otetaan ryhmät tarkastelua varten
			var ryhmat = ovi.get_groups()
			
			if ovi.get_child_count() == 0:
				# Listään ovi-nodeille lapseksi vasemmalta
				# tai oikealta aukeava ovi riippuen ryhmästä:
				# x
				if ryhmat.has("x"):
					if ryhmat.has("oviV"):
						ovi_v_x = ovi_vasen_x.instantiate()
						ovi.add_child(ovi_v_x)
					else:
						ovi_o_x = ovi_oikea_x.instantiate()
						ovi.add_child(ovi_o_x)
				
				# y
				elif ryhmat.has("y"):
					if ryhmat.has("oviV"):
						ovi_v_y = ovi_vasen_y.instantiate()
						ovi.add_child(ovi_v_y)
					else:
						ovi_o_y = ovi_oikea_y.instantiate()
						ovi.add_child(ovi_o_y)
				
				# z
				if ryhmat.has("z"):
					if ryhmat.has("oviV"):
						ovi_v_z = ovi_vasen_z.instantiate()
						ovi.add_child(ovi_v_z)
					else:
						ovi_o_z = ovi_oikea_z.instantiate()
						ovi.add_child(ovi_o_z)
			else: # Tuhotaan
				# Varsinaisessa ovipuzzlessa ovia, joita ei voi aukaista
				if not ryhmat.has("kuolematon"):
					var lapset = ovi.get_children()
					for lapsi in lapset:
						lapsi.queue_free()
	
	# Pelkkä ristiovi                         # vain tasossa 3
	if Globaali.ovi_risti != null and ovi_ylin.get_name() == "Ovet_3":
		var ovi_pysty = ovi_pysty_oikea.instantiate()
		var ovi_vaaka = ovi_vaaka_vasen.instantiate()
		
		# Tuhotaan kaikki lapset varmistukseksi
		var ristit = Globaali.ovi_risti.get_children()
		var aikaisempi = ristit[0].get_name()
		for risti in ristit:
			risti.queue_free()
		
		if aikaisempi == "Ovi_pysty_oikea":
			Globaali.ovi_risti.add_child(ovi_vaaka)
			Globaali.pystyssa = false
		else:
			Globaali.ovi_risti.add_child(ovi_pysty)
			Globaali.pystyssa = true


func _physics_process(delta):
	"""
	if Input.is_action_just_pressed("painike_oikea"):
		# Tuhotaan valopallo kokonaan
		audio_valopallo_hajoaa.play() # TODO: Jostain syystä ei soi
		queue_free()
		Globaali.nykyiset_pallot = 0
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
			audio_valopallo_hajoaa.play() # TODO: Jostain syystä ei soi
			await get_tree().create_timer(0.2).timeout
			start_destroy()
			
		else: # Kimpoaminen
			velocity = velocity.bounce(collision.get_normal())
			audio_valopallon_kimpoaminen.play()
			if tween:
				tween.kill()
			tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_BACK)
			tween.tween_property(valo, "energy", valo.energy * 0.8, 0.5)
			# Keskimäärin vähennetään nopeutta hiukan kimmotessa
			# Voi joskus myös nopeutua :)
			velocity *= randf_range(0.8, 1.1)
			# Lisätään kimmotusten määrää
			kimpoamiset += 1
			if kimpoamiset >= 5:
				start_destroy()
