extends CharacterBody2D

var SPEED = 50.0
var jahdissa = false
var pelaaja = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if jahdissa:
		position += (pelaaja.position - position)/SPEED

func _on_keho_area_entered(body):
	if body.is_in_group("Pelaaja"):
		pelaaja = body
		self.get_tree().reload_current_scene()
		print("kuolit")

func _on_tarkkaavaisuus_body_entered(body):
	pelaaja = body
	jahdissa = true

func _on_tarkkaavaisuus_body_exited(body):
	pelaaja = null
	jahdissa = false

	move_and_slide()
