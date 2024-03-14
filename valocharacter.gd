## Juuso 7.3.2024
## TODO: pelaajan hyppy- ja juoksuanimaatiot
extends CharacterBody2D

## Valon nopeus
var SPEED = 110.0

## Kaikki scenen ovet
var ovet = Array()

## Ladataan ovet
@onready var ovi_vasen = preload("ovi_vasen.tscn")
@onready var ovi_oikea = preload("ovi_oikea.tscn")


## Alustetaan ovien taulukko scenen ovilla
## Siirretään luultavasti ovi.gd vai globaali.gd?
func _ready():
	# Kaikki nodet, joilla ryhmänä ovi_v tai ovi_o eli kaikki ovet
	# Yhdistää kaksi taulukkoa
	var nodes = (get_tree().get_nodes_in_group("ovi_v") 
		+ get_tree().get_nodes_in_group("ovi_o"))
	
	for node in nodes:
		ovet.append(node)


func move(_position, _mouse):
	# Aluksi pelaajan kohtaan
	position = _position
	
	# Normalisoidun suunnan laskeminen valopallon sijainnista klikattuun kohtaan
	var light_direction = Vector2(self.position.x, self.position.y).direction_to(_mouse)
	velocity = light_direction * SPEED
	
	
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
		if collision_collider.is_in_group("ovi_avaa"):
			# Tuhotaan ovi_oikea sen viitteen avulla
			# Säilytetään ylin node eli ovi, jotta voidaan luoda ovi tähän samaan paikkaa
			var parent = collision_collider.get_parent()
			parent.queue_free()
			
			# Tuhotaan pallo, se imeytyy oveen
			queue_free()
			
			# Vähennetään olemassa olevien valopallojen määrää
			Globaali.current_lights -= 1
		
		else: # Kimpoaminen
			velocity = velocity.bounce(collision.get_normal())
	
	
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
