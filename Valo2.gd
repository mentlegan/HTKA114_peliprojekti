extends StaticBody2D


@onready var player = get_node("../Pelaaja")
@onready var hitbox: CollisionPolygon2D = get_node("../Pelaaja/CollisionPolygon2D")
# mallina staattinen tyypitys
@onready var light: PointLight2D = get_node("PointLight2D")

var raycast = RayCast2D.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	raycast.collide_with_areas = true
	raycast.collide_with_bodies = false
	add_child(raycast)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse = get_global_mouse_position()
	position.x += (mouse.x - position.x) * 0.3
	position.y += (mouse.y - position.y) * 0.3


func _physics_process(delta):
	raycast.target_position = Vector2(player.position.x - position.x, player.position.y - position.y)
	
	var space_state = get_world_2d().direct_space_state
	
	# use global coordinates, not local to node (ei toimi global)
	# Luo raycastin valosta pelaajaa kohti
	var query = PhysicsRayQueryParameters2D.create(Vector2(self.position.x, self.position.y), 
		Vector2(player.position.x, player.position.y))
	var result = space_state.intersect_ray(query)
	
	""" mitä result sisältää:
	position: Vector2 # point in world space for collision
	normal: Vector2 # normal in world space for collision
	collider: Object # Object collided or null (if unassociated)
	collider_id: ObjectID # Object it collided against
	rid: RID # RID it collided against
	shape: int # shape index of collider
	metadata: Variant() # metadata of collider
	"""
	
	# player.visible = ! (raycast.is_colliding())
	
	# light.height nyt 60
	# sopiva etäisyys 360, joka tulee (light.height * light.texture_scale) / 2
	# Pelkän pelaajan keskipisteen ja valon etäisyyden avulla tarkastelu tuntuisi toimivan hyvin
	
	# Jos osuu johonkin
	if result: 
		# Jos etäisyys tarpeeksi lyhyt
		if self.global_position.distance_to(player.global_position) < light.height * light.texture_scale / 2: 
			print_rich("[color=yellow]Lighted[/color]")
			# Jos osuu vielä pelaajaan
			if result.rid == player.get_rid():
				print_rich("[color=red]Hit player[/color]")
		# Jos etäisyys liian pitkä
		else: print("-")
	
	#
	# polygon on PackedVector2Array
	# var vec = Vector2(player.position + abs(hitbox.polygon[1]))
	# print(vec)
