## Juuso 27.2.2024
## TODO: pelaajan hyppy- ja juoksuanimaatiot
extends CharacterBody2D

## Raycast valossa olemisen tarkistamiseen
@onready var raycast = get_node("RayCast2D")
## Pelaajan hitbox
@onready var polygon = get_node("CollisionShape2D")
## Pelaajan animaatio
@onready var animaatio = get_node("Animaatio")
## Pelaajan alue
@onready var area = get_node("Area2D")

## Valocharacter
@onready var valoChar = get_node("../ValoCharacter")
## Itse pointlight2D valo
@onready var valo = get_node("../ValoCharacter/PointLight2D")

## Asetetaan pelaajan nopeus ja hypyt
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

## Get the gravity from the project settings to be synced with RigidBody nodes.
## Eli napataan painovoima kimppaan rigidbodyjen kanssa.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*1.25
var current_jumps = 0


## Fysiikanhallintaa
func _physics_process(delta):
	## Tästä painovoima
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		current_jumps = 0

	## Tehdään hyppy
	if Input.is_action_just_pressed("hyppaa") and is_on_floor():
		current_jumps += 1
		velocity.y = JUMP_VELOCITY

	## input-kontrollit
	var direction = Input.get_axis("liiku_vasen", "liiku_oikea")
	if direction:
		velocity.x = direction * SPEED
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
	
	print("Valossa: " + str(on_valossa()))
	print("=====")

	# polygon on PackedVector2Array
	# var vec = Vector2(player.position + abs(hitbox.polygon[1]))
	# print(vec)

	# player.visible = ! (raycast.is_colliding())

	# light.height nyt 60, texture_scale 12   = 60           = 12
	# sopiva etäisyys 360, joka tulee (light.height * light.texture_scale) / 2
	# Pelkän pelaajan keskipisteen ja valon etäisyyden avulla tarkastelu tuntuisi toimivan hyvin


## Tarkistaa, onko pelaaja valossa.
## Käy läpi pelaajaan osuvat Area2D-nodet, jotka kuuluvat "valonlahde"-ryhmään.
## Jos yksikään raycast pelaajan ja valonlähteen välillä ei osu maahan, palautetaan true.
## Muutoin palautetaan false. 
func on_valossa():
	var space_state = get_world_2d().direct_space_state
	var valonlahteet = Array() # Luodaan tyhjä taulukko valonlähteille, joihin pelaaja osuu
	var valossa = false # Muuttuja, joka asetetaan todeksi, jos ollaan yhdessäkään valonlähteessä
	
	# Käydään läpi pelaajaan osuvat rigidbodyt
	for node in area.get_overlapping_areas():
		# Lisätään rigidbody valonlahteet-taulukkoon, jos se kuuluu "valonlahde"-ryhmään
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
			return true

	# Pelaaja ei ole valossa, jos kaikkien valonlähteiden edessä on terrainia
	# tai jos valonlähteiden taulukko on tyhjä.
	return false
