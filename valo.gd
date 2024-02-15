extends Area2D


@onready var player = get_node("../Pelaaja")

var raycast = RayCast2D.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	raycast.collide_with_areas = true
	raycast.collide_with_bodies = false
	add_child(raycast)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	raycast.target_position = Vector2(player.position.x - position.x, player.position.y - position.y)
	
	player.visible = ! (raycast.is_colliding())
