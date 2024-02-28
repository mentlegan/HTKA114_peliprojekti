## Juuso 27.2.2024
## TODO: pelaajan hyppy- ja juoksuanimaatiot
extends CharacterBody2D

## Raycast valossa olemisen tarkistamiseen
var raycast = RayCast2D.new()

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

	# Raycastin tarkastelua
	raycast.target_position = Vector2(valoChar.position.x - self.position.x, valoChar.position.y - self.position.y)

	var space_state = get_world_2d().direct_space_state

	# use global coordinates, not local to node (ei toimi global)
	# Luo raycastin valosta pelaajaa kohti
	var query = PhysicsRayQueryParameters2D.create(Vector2(self.position.x, self.position.y), 
		Vector2(valoChar.position.x, valoChar.position.y))
	var result = space_state.intersect_ray(query)

	""" mitä result sisältää:
	position: Vector2 # point in world space for collision
	normal: Vector2 # normal in world space for collision
	collider: Object # Object collided or null (if unassociated)
	collider_id: ObjectID # Object it collided against
	rid: RID # RID it collided against
	shape: int # shape index of collider
	metadata: Variant() # metadata of collider
	"""

	# polygon on PackedVector2Array
	# var vec = Vector2(player.position + abs(hitbox.polygon[1]))
	# print(vec)

	# player.visible = ! (raycast.is_colliding())

	# light.height nyt 60, texture_scale 12   = 60           = 12
	# sopiva etäisyys 360, joka tulee (light.height * light.texture_scale) / 2
	# Pelkän pelaajan keskipisteen ja valon etäisyyden avulla tarkastelu tuntuisi toimivan hyvin

	# Jos osuu johonkin
	if result: 
		# Jos etäisyys tarpeeksi lyhyt
		if self.global_position.distance_to(valoChar.global_position) < valo.height * valo.texture_scale / 2: 
			print_rich("[color=yellow]Lighted[/color]")
			# Jos osuu valoon (eli valon characterbodyyn)
			if result.rid == valoChar.get_rid():
				print_rich("[color=red]Hit player[/color]")
		# Jos etäisyys liian pitkä
		else: print("-")
		
		""" valmis pohja area2D tarkasteluun
		overlapping_bodies_result = area.get_overlapping_bodies()
		for body in overlapping_bodies_result:
			if body.is_in_group("group"):
				# do something with it
		"""
