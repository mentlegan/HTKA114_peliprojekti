## Juuso 7.3.2024
## TODO: pelaajan hyppy- ja juoksuanimaatiot
extends CharacterBody2D


@onready var player = get_node("../Pelaaja")
# @onready var hitbox: CollisionShape2D = get_node("../Pelaaja/CollisionShape2D")
# mallina staattinen tyypitys
# @onready var light: PointLight2D = get_node("PointLight2D")
var Light = preload("res://valo_character.tscn")

# Valon nopeus
var SPEED = 130.0

# Valon liikkumisen ja luomisen testaukseen
var MOVING = false
var EXISTS = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	print(EXISTS)
	# Onko edes tarpeelliset, toimii ilman näitäkin
	# raycast.collide_with_areas = true
	# raycast.collide_with_bodies = false
	# add_child(raycast)
	
	# Valon suunnan antaminen hiiren vasemmalla painikkeella
	# käytännössä samalla laitetaan liikkeelle
	if Input.is_action_just_pressed("painike_vasen"):
		# Hiiren suunta
		var mouse = get_global_mouse_position()
		
		if not EXISTS:
			# Valon synnyttäminen
			var l = Light.instantiate()
			# Lisääminen puuhun
			l.start(player.position)
			get_tree().root.add_child(l)
			# self.position = player.position
			EXISTS = true
		
		# Normalisoidun suunnan laskeminen valopallon sijainnista klikattuun kohtaan
		var direction = Vector2(self.position.x, self.position.y).direction_to(mouse)
		velocity = direction * SPEED
		MOVING = true
	
	if Input.is_action_just_pressed("painike_oikea"):
		if not MOVING:
			# self.position.x = player.position.x
			# self.position.y = player.position.y
			# Poistetaan valo
			EXISTS = false
			queue_free()
		else: 
			# Alustetaan suuntavektori eli pysäytetään
			velocity = Vector2(0, 0)
			MOVING = false
	
	# Liikkeessä
	if MOVING:
		# Valon liikkuminen
		var collision = move_and_collide(velocity * delta)
		# Jos osuu johonkin
		if collision:
			# Kimpoaminen
			velocity = velocity.bounce(collision.get_normal())
