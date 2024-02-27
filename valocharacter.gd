## Juuso 27.2.2024

extends CharacterBody2D


# @onready var player = get_node("../Pelaaja")
# @onready var hitbox: CollisionShape2D = get_node("../Pelaaja/CollisionShape2D")
# mallina staattinen tyypitys
# @onready var light: PointLight2D = get_node("PointLight2D")

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
