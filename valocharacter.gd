## Juuso 7.3.2024
## TODO: pelaajan hyppy- ja juoksuanimaatiot
extends CharacterBody2D


@onready var player = get_node("../Pelaaja")
# @onready var hitbox: CollisionShape2D = get_node("../Pelaaja/CollisionShape2D")
# mallina staattinen tyypitys
# @onready var light: PointLight2D = get_node("PointLight2D")

# Valon nopeus
var SPEED = 110.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func move(_position, _mouse):
	# Aluksi pelaajan kohtaan
	position = _position
	
	# Normalisoidun suunnan laskeminen valopallon sijainnista klikattuun kohtaan
	var light_direction = Vector2(self.position.x, self.position.y).direction_to(_mouse)
	velocity = light_direction * SPEED
	
	
func _physics_process(delta):
	# Onko edes tarpeelliset, toimii ilman näitäkin
	# raycast.collide_with_areas = true
	# raycast.collide_with_bodies = false
	# add_child(raycast)
	
	if Input.is_action_just_pressed("painike_oikea"):
		# Tuhotaan valopallo kokonaan
		queue_free()
	
	# Valon liikkuminen
	var collision = move_and_collide(velocity * delta)
	# Jos osuu johonkin
	if collision:
		# Kimpoaminen
		velocity = velocity.bounce(collision.get_normal())
