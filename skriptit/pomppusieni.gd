extends StaticBody2D
## Pomppusieni toiminnallisuus
## TODO: Velocityn muuttaminen, jos huilulla soittaa
## TODO: Saattaa mennä rikki, jos hyppää liian korkealta
## TODO: putoamisvahingon muuttaminen, jotta toimii pomppusienien kanssa
## Putoamishuippu pitäisi varmaan ottaa pelaajaskriptissä silloin, kun velocity.y > 0
# Juuso 17.8.2024

@onready var raycasts = $Raycasts

## Hyppy voima
var bounce_velocity_y = -800

## Viite pelaajaan
var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#collision_platform.disabled = true
	pass


func _on_area_2d_body_entered(body):
	if body is Pelaaja:
		enable_raycasts(true)
		player = body
		#collision_platform.set_deferred("disabled", false)


func _on_area_2d_body_exited(body):
	if body is Pelaaja:
		enable_raycasts(false)
		player = null
		#collision_platform.set_deferred("disabled", true)


func enable_raycasts(enabled):
	for raycast in raycasts.get_children():
		raycast.enabled = enabled


func _process(_delta):
	# Jos pelaaja alueella ja putoamassa
	if player and player.velocity.y > 0:
		# Jos jokin raycasti osuu
		for raycast in raycasts.get_children():
			if raycast.is_colliding():
				player.velocity.y = bounce_velocity_y
				# Resetoidaan putoamis_vahinko, jotta huippu lasketaan uudelleen
				player.putoamis_vahinko = false
				#print(player.velocity.y)
				break
