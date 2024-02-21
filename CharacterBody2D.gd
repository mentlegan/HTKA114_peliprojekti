## Harri 21.2.2024
## TODO: pelaajan hyppy-, juoksu- ja kävelyanimaatiot
## TODO: spriten flippaus suuntaa myöten
extends CharacterBody2D


var raycast = RayCast2D.new()


## Pelaajan hitbox
@onready var polygon = get_node("CollisionShape2D")
## Pelaajan animaatio-node
@onready var animaatio = get_node("Animaatio")

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
	if (Input.is_action_just_pressed("hyppaa")) and (is_on_floor()):
		current_jumps += 1
		velocity.y = JUMP_VELOCITY

	## input-kontrollit
	var direction = Input.get_axis("liiku_vasen", "liiku_oikea")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	## Käynnistetään idle-animaatio, jos pelaaja on paikoilaan
	if velocity.x == 0 && velocity.y == 0:
		animaatio.play("idle")
	else:
		## Tähän myöhemmin pelaajan hyppy-, juoksu- ja kävelyanimaatiot.
		## Nyt pelkästään pysäyttää idle-animaation.
		animaatio.stop()

	move_and_slide()
