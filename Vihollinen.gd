## Harri 7.3.2024

extends CharacterBody2D

var SPEED = 50.0
var jahdissa = false ## Vakiona vihollinen ei ole jahtaamassa pelaajaa
var pelaaja = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta ## Painovoimaa vihollisellekin
	if jahdissa: ## Tässä "jahtimoodi" eli kun vihollinen tietää, että missä pelaaja on
		position += (pelaaja.position - position)/SPEED
	move_and_slide()

func _on_keho_body_entered(body): ## Kun pelaaja osuu viholliseen, käynnistetään scene uudestaan
	if body.is_in_group("Pelaaja"):
		pelaaja = body
		Globaali.respawn() ## Voidaan kutsua respawnia näinkin. Tätä samaa voi kutsua muissa game overin instansseissa

func _on_tarkkaavaisuus_body_entered(body): ## Jos pelaaja astuu vihollisen tietoisuusalueelle
	pelaaja = body
	jahdissa = true

func _on_tarkkaavaisuus_body_exited(body): ## Jos pelaaja poistuu vihollisen tietoisuusalueelta
	pelaaja = null
	jahdissa = false
