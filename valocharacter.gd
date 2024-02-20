extends CharacterBody2D


@onready var player = get_node("../Pelaaja")
@onready var hitbox: CollisionShape2D = get_node("../Pelaaja/CollisionShape2D")
# mallina staattinen tyypitys
@onready var light: PointLight2D = get_node("PointLight2D")

var raycast = RayCast2D.new()

# Ei tietoa miten hyödyntää valon liikuttamisessa
var SPEED = 10.0

# Valon liikkumisen testaukseen
var MOVING = false
# Voi luultavasti jättää pois ja käyttää CharacterBody2D omaa velocity attribuuttia
# alussa pysähdyksissä
var move_vec = Vector2(0, 0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Onko edes tarpeelliset, toimii ilman näitäkin
	# raycast.collide_with_areas = true
	# raycast.collide_with_bodies = false
	# add_child(raycast)
	
	"""hiirellä liikuttaminen
	var mouse = get_global_mouse_position()
	self.position.x += (mouse.x - self.position.x) * 0.3
	self.position.y += (mouse.y - self.position.y) * 0.3
	"""
	
	# Valon suunnan antaminen hiiren vasemmalla painikkeella
	# käytännössä samalla laitetaan liikkeelle
	# enum MouseButton lukee MOUSE_BUTTON_LEFT = 1 eli voisi olla vain numero 1
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Hiiren suunta
		var mouse = get_global_mouse_position()
		# Suuntavektorin muodostus, antaa automaattisesti nopeuden etäisyyden perusteella
		move_vec = Vector2(mouse.x - self.position.x, mouse.y - self.position.y)
		MOVING = true
	
	#                                  tai pelkkä 2
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		# Alustetaan suuntavektori eli pysäytetään
		move_vec = Vector2(0, 0)
		MOVING = false
	
	# Liikkeessä
	if MOVING:
		# Valon liikkuminen
		var collision = move_and_collide(move_vec * delta)
		# Jos osuu johonkin
		if collision:
			# Kimpoaminen
			move_vec = move_vec.bounce(collision.get_normal())
	
	raycast.target_position = Vector2(player.position.x - self.position.x, player.position.y - self.position.y)
	
	var space_state = get_world_2d().direct_space_state
	
	# use global coordinates, not local to node (ei toimi global)
	# Luo raycastin valosta pelaajaa kohti
	var query = PhysicsRayQueryParameters2D.create(Vector2(self.position.x, self.position.y), 
		Vector2(player.position.x, player.position.y))
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
	
	# player.visible = ! (raycast.is_colliding())
	
	# light.height nyt 60
	# sopiva etäisyys 360, joka tulee (light.height * light.texture_scale) / 2
	# Pelkän pelaajan keskipisteen ja valon etäisyyden avulla tarkastelu tuntuisi toimivan hyvin
	
	# Jos osuu johonkin
	if result: 
		# Jos etäisyys tarpeeksi lyhyt
		if self.global_position.distance_to(player.global_position) < light.height * light.texture_scale / 2: 
			print_rich("[color=yellow]Lighted[/color]")
			# Jos osuu vielä pelaajaan
			if result.rid == player.get_rid():
				print_rich("[color=red]Hit player[/color]")
		# Jos etäisyys liian pitkä
		else: print("-")
	
	#
	# polygon on PackedVector2Array
	# var vec = Vector2(player.position + abs(hitbox.polygon[1]))
	# print(vec)
