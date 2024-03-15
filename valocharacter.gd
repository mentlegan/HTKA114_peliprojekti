## Juuso 14.3.2024
## TODO: pelaajan hyppy- ja juoksuanimaatiot
extends CharacterBody2D

## Valon nopeus
var SPEED = 110.0

## Ladataan ovet valmiiksi
@onready var ovi_vasen = preload("res://ovi_vasen.tscn")
@onready var ovi_oikea = preload("res://ovi_oikea.tscn")

@onready var valo = get_node("PointLight2D")

var kimpoamiset = 0

func move(_position, _mouse):
	# Aluksi pelaajan kohtaan
	position = _position
	
	# Normalisoidun suunnan laskeminen valopallon sijainnista klikattuun kohtaan
	var light_direction = Vector2(self.position.x, self.position.y).direction_to(_mouse)
	velocity = light_direction * SPEED


## Muuttaa ovet, jos valopallo osuu x tai z oveen
## Attribuuttina tulee ryhmän nimi (x tai z)
## if_y kertoo osuuko pallo oveen y, tällöin käydään kaikki ovet aina läpi
func change_doorsXYZ(_letter, if_y):
	# Alustetaan ovet valmiiksi käytettäväksi
	var ovi_v = ovi_vasen.instantiate()
	var ovi_o = ovi_oikea.instantiate()
	
	# Tallenetaan kirjain
	var letter = _letter
	
	for ovi in Globaali.ovet:                           # Tämä vain, kun osuu y
		if ovi.is_in_group(letter) or ovi.is_in_group("y") or if_y:
			if ovi.get_child_count() == 0:
				# Listään ovi-nodeille lapseksi vasemmalta
				# tai oikealta aukeava ovi riippuen ryhmästä
				if ovi.is_in_group("oviV"):
					ovi.add_child(ovi_v)
				elif ovi.is_in_group("oviO"):
					ovi.add_child(ovi_o)
			else: # Tuhotaan
				var lapset = ovi.get_children()
				for lapsi in lapset:
					lapsi.queue_free()


func _physics_process(delta):
	if Input.is_action_just_pressed("painike_oikea"):
		# Tuhotaan valopallo kokonaan
		queue_free()
	
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
			var ovi_ylin = parent.get_parent()
			# Ylimmän noden ryhmät
			var groups = ovi_ylin.get_groups()
			
			# Ryhmien kanssa tuli onglemia, joten muutettu ilman alaviivaa oleviksi
			# Välillä ei toiminut esim. kaikilla ovilla, joilla ryhmänä x
			# Ovien järjestys hierarkiassa muutti myös tuloksia, outoa
			# Ovien duplikointi saattoi myös vaikuttaa ongelmiin, kannattaa välttää
			# Tekee vain uuden node2D ja sille ryhmät
			
			## HUOM. RYHMIEN LAITTAMINEN GLOBAALIKSI TAISI KORJATA KAIKEN
			## SIIRRETTÄVÄ MUUALLE LUULTAVASTI
			## PELISUUNNITELMASSA ON AVATTU OVIEN TOIMINNALLISUUS, TÄSSÄ VAIN TOTEUTUS
			
			# Kirjain ovien muokkauksille
			var letter
			
			# Ovien muokkaus
			# X ja y
			if groups.has("x"):
				letter = "x"
				change_doorsXYZ(letter, false)
			
			# Kaikki ovet x, y, z
			elif groups.has("y"):
				letter = "xyz" # Ei väliä
				change_doorsXYZ(letter, true)
			
			# Y ja z
			elif groups.has("z"):
				letter = "z"
				change_doorsXYZ(letter, false)
			
			# Voisiko olla parempi tapa?
			"""
			for group in groups:
				# Karsitaan kaikki muut ryhmät pois paitsi x, y tai z
				if not (group.begins_with("x") or group.begins_with("y") or group.begins_with("z")):
					groups.remove_from_group(group)
			"""
			
			# Tuhotaan pallo, se imeytyy oveen
			queue_free()
			
			# Vähennetään olemassa olevien valopallojen määrää
			Globaali.current_lights -= 1
			
			
		else: # Kimpoaminen
			velocity = velocity.bounce(collision.get_normal())
			# Pienennetään valon energiaa
			valo.energy *= 0.8
			# Lisätään kimmotusten määrää
			kimpoamiset += 1
			if kimpoamiset >= 5:
				queue_free()
				Globaali.current_lights -= 1
	
	
	"""
	## (TESTAUKSEEN)
	## Luodaan ovet uudelleen, silloin kun valopallo on olemassa
	if Input.is_action_just_pressed("q"):
		# Alustetaan ovet valmiiksi käytettäväksi
		var ovi_v = ovi_vasen.instantiate()
		var ovi_o = ovi_oikea.instantiate()
		
		# Käydään läpi kaikki ovet
		for ovi in ovet:
			# Eli jos ei ole ovea
			if ovi.get_child_count() == 0:
				# Listään ovi-nodeille lapseksi vasemmalta
				# tai oikealta aukeava ovi riippuen ryhmästä
				if ovi.is_in_group("ovi_v"):
					ovi.add_child(ovi_v)
				elif ovi.is_in_group("ovi_o"):
					ovi.add_child(ovi_o)
	"""
	
