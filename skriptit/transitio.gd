## Juuso 16.5.2024
## Vesiputouksen ja minecartin transitio

extends Control

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_fade_reset)


func _on_vesiputous_transitio():
	color_rect.visible = true
	animation_player.play("fade_black")
	Globaali.pelaaja.process_mode = Node.PROCESS_MODE_DISABLED


func _fade_reset(anim_name):
	if anim_name == "fade_black":
		await get_tree().create_timer(1).timeout
		Globaali.pelaaja.position = Globaali.vesiputous_tp
		animation_player.play("fade_reset")
		await get_tree().create_timer(0.5).timeout
		Globaali.pelaaja.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		color_rect.visible = false
