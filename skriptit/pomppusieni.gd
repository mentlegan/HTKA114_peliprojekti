extends StaticBody2D
## Pomppusieni toiminnallisuus
## TODO: Velocityn muuttaminen, jos huilulla soittaa
## TODO: Saattaa mennä rikki, jos hyppää liian korkealta
## TODO: putoamisvahingon muuttaminen, jotta toimii pomppusienien kanssa
## Putoamishuippu pitäisi varmaan ottaa pelaajaskriptissä silloin, kun velocity.y > 0
# Juuso 23.9.2024

@onready var raycasts = $Raycasts
var raycast_offset = 12

## Hyppy voimat
@export var pomppu_voimat = [-650, -800]
var nykyinen_voima

## Ääniefektit
@onready var audio_pomppusieni = $AudioPomppusieni

@onready var label_voima = $LabelVoima

@onready var anim_sprite = $AnimatedSprite2D
## Viite pelaajaan
var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#collision_platform.disabled = true
	nykyinen_voima = pomppu_voimat[0]
	label_voima.text = str(nykyinen_voima)
	anim_sprite.play("pomppu_pieni")


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


func _on_huilu_area_entered(area) -> void:
	if area is Huilu and area.aanen_taajuus == 1:
		if not area.osuu_terrainiin(self):
			# Vaihtaa seuraavaan hyppy voimaan, jos ei löytynyt nykyistä -> asettaa ensimmäiseen
			nykyinen_voima = pomppu_voimat[(pomppu_voimat.find(nykyinen_voima) + 1) % pomppu_voimat.size()]
			if nykyinen_voima == pomppu_voimat[0]:
				anim_sprite.play("pomppu_pieni")
				raycasts.position.y += raycast_offset
			else:
				anim_sprite.play("pomppu_iso")
				raycasts.position.y = 0
			soitaAani()
			# Asetetaan labeliin nykyinen voima havainnollistamiseksi
			label_voima.text = str(nykyinen_voima)


func _on_animation_finished() -> void:
	anim_sprite.stop()
	anim_sprite.frame = 0


func _process(_delta):
	# Jos pelaaja alueella ja putoamassa ja ei ole vedessä
	if player and player.velocity.y > 0 and player.vedessa == false:
		# Jos jokin raycasti osuu
		for raycast in raycasts.get_children():
			if raycast.is_colliding():
				if nykyinen_voima == pomppu_voimat[0]:
					anim_sprite.play("pomppu_pieni")
				else:
					anim_sprite.play("pomppu_iso")
				soitaAani()
				player.velocity.y = nykyinen_voima
				# Resetoidaan putoamis_vahinko, jotta huippu lasketaan uudelleen
				player.putoamis_vahinko = false
				#print(player.velocity.y)
				break


func soitaAani():
	if not audio_pomppusieni.playing:
		audio_pomppusieni.play();
