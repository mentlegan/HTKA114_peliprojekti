## Harri 14.3.2024
## TODO: pelaajan hyppy- ja juoksuanimaatiot
## TODO: tallennuspisteet, joihin pelaaja siirretään respawn()-kutsun aikana
## TODO: pimeässä kuolemiselle animaatio / visuaalista palautetta ennen yhtäkkistä respawn()-kutsua
extends CharacterBody2D

## Koitetaan signaalia
signal kuollut

## Raycast valossa olemisen tarkistamiseen
@onready var raycast = get_node("RayCast2D")
## Pelaajan hitbox
@onready var polygon = get_node("CollisionShape2D")
## Pelaajan animaatio
@onready var animaatio = get_node("Animaatio")
## Pelaajan alue
@onready var area = get_node("Area2D")


## Ajastin pimeässä selviämiselle
var ajastin_pimeassa = Timer.new()
const SELVIAMISAIKA_PIMEASSA = 20 ## Kuinka kauan pimeässä selvitään ennen respawn()-kutsua, sekunneissa

## Ladataan valmiiksi valopallo
var light = preload("res://valo_character.tscn")

## Asetetaan pelaajan nopeus ja hypyt
const SPEED = 200.0
const SPRINT = 350.0
const JUMP_VELOCITY = -400.0

## Get the gravity from the project settings to be synced with RigidBody nodes.
## Eli napataan painovoima kimppaan rigidbodyjen kanssa.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*1.25
var current_jumps = 0


func _ready():
	# Lisätään ajastin lapseksi
	self.add_child(ajastin_pimeassa)
	
	# Pelaaja kuolee, jos hän on pimeässä liian kauan
	ajastin_pimeassa.timeout.connect(kuolema)

## Tähän lisätty signaalin emit kokeilumielessä
func kuolema():
	kuollut.emit()


## Fysiikanhallintaa
func _physics_process(delta):
	# Tästä painovoima
	if not (is_on_floor() or is_on_wall()):
		velocity.y += gravity * delta
		# Seinää vasten liikkuessa kiipeää
	elif (is_on_wall()) and (Input.is_action_pressed("liiku_oikea")):
		velocity.y = -gravity * delta * 6
	elif (is_on_wall()) and (Input.is_action_pressed("liiku_vasen")):
		velocity.y = -gravity * delta * 6
		# Ei tipu jos seinässä kiinni
	else:
		velocity.y = 0

	# Hyppy takaisin kun maassa
	if is_on_floor():
		current_jumps = 0
	
	## Tehdään hyppy
	if Input.is_action_just_pressed("hyppaa") and (current_jumps < 1 or (current_jumps < 2 and is_on_wall())):
		current_jumps += 1
		velocity.y = JUMP_VELOCITY

	## input-kontrollit
	var direction = Input.get_axis("liiku_vasen", "liiku_oikea")
	if direction:
		if Input.is_action_pressed("juoksu"):
			velocity.x = direction * SPRINT
		else: 
			velocity.x = direction * SPEED
	else:
		if Input.is_action_pressed("juoksu"):
			velocity.x = move_toward(velocity.x, 0, SPRINT)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
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
	
	
	## Usean valonlähteen tarkistus
	## Käy läpi kaikki pelaajaan osuvat Area2D nodet
	## Lähetetään jokaiseen raycast ja tarkistetaan osuuko se johonkin
	# var space_state = get_world_2d().direct_space_state # Tarvitseeko, ei käytetä mihinkään?
	var valonlahteet = Array() # Luodaan tyhjä taulukko valonlähteille, joihin pelaaja osuu
	var valossa = false # Totuusarvo pelaajan olemiselle valossa
	
	# Käydään läpi pelaajaan osuvat area2D
	for node in area.get_overlapping_areas():
		# Lisätään area2D node valonlahteet-taulukkoon, jos se kuuluu "valonlahde"-ryhmään
		if node.is_in_group("valonlahde"):
			valonlahteet.append(node)
	
	print("Valonlähteitä: " + str(len(valonlahteet)))
	
	# Käydään läpi taulukkoon lisätyt valonlähteet ja tarkistetaan raycast niiden
	# ja pelaajan välillä
	for valonlahde in valonlahteet:
		# Suunnataan raycast valonlähteeseen
		raycast.target_position = Vector2(
			valonlahde.global_position.x - self.position.x,
			valonlahde.global_position.y - self.position.y
		)
		
		# Jos reitti pelaajasta valonlähteeseen on tyhjä, pelaaja on valossa.
		if not raycast.is_colliding():
			valossa = true

	# Pelaaja ei ole valossa, jos kaikkien valonlähteiden edessä on terrainia
	# tai jos valonlähteiden taulukko on tyhjä.
	# tällöin totuusarvo valossa jää falseksi
	print("Valossa: " + str(valossa))
	print("=====")
	
	# Aloitetaan / pysäytetään ajastin pimeässä kuolemiselle
	if ajastin_pimeassa.is_stopped() and not valossa:
		ajastin_pimeassa.start(SELVIAMISAIKA_PIMEASSA)
	elif valossa:
		ajastin_pimeassa.stop()
	
	# polygon on PackedVector2Array
	# var vec = Vector2(player.position + abs(hitbox.polygon[1]))
	# print(vec)
	
	if Input.is_action_just_pressed("painike_vasen"):
		# Tällä hetkellä 2 maksimissaan
		if Globaali.current_lights < 2 and Globaali.palloja > 0:
			# Hiiren sijainti, otetaan tässä niin on varmasti oikein
			var mouse = get_global_mouse_position()
			
			# Valon synnyttäminen
			var l = light.instantiate()
			# Liikkuminen valon scriptissä
			l.move(self.position, mouse)
			# Lisääminen puuhun
			get_tree().root.add_child(l)
			
			# Muuttujiin muutokset
			Globaali.current_lights += 1
			Globaali.palloja -= 1
	
	if Input.is_action_just_pressed("painike_oikea"):
		# Valopallo scriptissä tuhotaan kaikki valopallot, varmaan muutettava
		Globaali.current_lights = 0
	
	## Kukkien kerääminen
	if Input.is_action_just_pressed("keraa_kukka"):
		var kukat = area.get_overlapping_areas()
		for kukka in kukat:
			if kukka.is_in_group("kukka"):
				Globaali.palloja = 2
		
	# player.visible = ! (raycast.is_colliding())

	# light.height nyt 60, texture_scale 12   = 60           = 12
	# sopiva etäisyys 360, joka tulee (light.height * light.texture_scale) / 2
	# Pelkän pelaajan keskipisteen ja valon etäisyyden avulla tarkastelu tuntuisi toimivan hyvin
