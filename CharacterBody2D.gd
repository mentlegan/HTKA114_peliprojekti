extends CharacterBody2D


var raycast = RayCast2D.new()


## Pelaajan hitbox
@onready var polygon = get_node("CollisionPolygon2D")


func _physics_process(delta):
	# Seuraa hiirtä
	var mouse = get_global_mouse_position()
	position.x += (mouse.x - position.x) * 0.3
	position.y += (mouse.y - position.y) * 0.3

	move_and_slide()
