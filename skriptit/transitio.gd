## Juuso 30.8.2024
## Minkä tahansa minecartin ja vesiputouksen transitio
extends Control

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

var mihin_tp = null

# Called when the node enters the scene tree for the first time.
func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_fade_reset)


func _on_transitio(tp):
	if tp == null:
		printerr("EI KERROTTU MIHIN TP")
	else:
		mihin_tp = tp
	color_rect.visible = true
	animation_player.play("fade_black")
	Globaali.maailma.pelaaja.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)


func _fade_reset(anim_name):
	if anim_name == "fade_black":
		await get_tree().create_timer(1, false).timeout
		#if Globaali.maailma.minecart_kaytetty == true:
			#Globaali.teleporttaa_pelaaja(Globaali.maailma.taso1_loppu)
		Globaali.teleporttaa_pelaaja(mihin_tp)
			#Globaali.maailma.minecart_kaytetty = false
		#else:
			#Globaali.teleporttaa_pelaaja(Globaali.maailma.vesiputous_tp)
			#Globaali.teleporttaa_pelaaja(mihin_tp)
		animation_player.play("fade_reset")
		await get_tree().create_timer(0.3, false).timeout
		Globaali.maailma.pelaaja.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	elif anim_name == "fade_reset":
		color_rect.visible = false
