#Harri ja Paavo. Viimeksi muokattu 15.2
extends CharacterBody2D


var raycast = RayCast2D.new()


## Pelaajan hitbox
@onready var polygon = get_node("CollisionPolygon2D")
## Pelaajan animaatio-node
@onready var animaatio = get_node("Animaatio")

# asetetaan pelaajan nopeus ja hypyt
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_JUMPS = 2

# Get the gravity from the project settings to be synced with RigidBody nodes.
# Eli napataan painovoima kimppaan rigidbodyjen kanssa.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_jumps = 0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		current_jumps = 0

	# Tehdään hyppy. Tähän versioon tehty tuplahyppy demonstraation vuoksi.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or current_jumps < MAX_JUMPS):
		current_jumps += 1
		velocity.y = JUMP_VELOCITY

	# input-kontrollit. nuolinäppäimillä liikutaan
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Käynnistetään idle-animaatio, jos pelaaja on paikoilaan
	if velocity.x == 0 && velocity.y == 0:
		animaatio.play("idle")
	else:
		# Tähän myöhemmin pelaajan hyppy-, juoksu- ja kävelyanimaatiot.
		# Nyt pelkästään pysäyttää idle-animaation.
		animaatio.stop()

	move_and_slide()

