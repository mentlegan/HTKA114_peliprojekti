## Juuso 7.3.2024
## TODO: pelaajan hyppy- ja juoksuanimaatiot
extends CharacterBody2D

# Valon nopeus
var SPEED = 110.0


func move(_position, _mouse):
	# Aluksi pelaajan kohtaan
	position = _position
	
	# Normalisoidun suunnan laskeminen valopallon sijainnista klikattuun kohtaan
	var light_direction = Vector2(self.position.x, self.position.y).direction_to(_mouse)
	velocity = light_direction * SPEED
	
	
func _physics_process(delta):
	if Input.is_action_just_pressed("painike_oikea"):
		# Tuhotaan valopallo kokonaan
		queue_free()
	
	# Valon liikkuminen
	var collision = move_and_collide(velocity * delta)
	# Jos osuu johonkin
	if collision:
		# Kimpoaminen
		velocity = velocity.bounce(collision.get_normal())
