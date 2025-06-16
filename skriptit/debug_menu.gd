extends Control
class_name DebugMenu
## Debug menu helpottamaan testausta
## Juuso 24.2.2025

@onready var v_box_container: VBoxContainer = $PanelContainerTP/MarginContainer/ScrollContainer/VBoxContainer

## Poistetaan mallipainikkeet
func _ready() -> void:
	for button: Button in v_box_container.get_children():
		button.queue_free()


func _input(event: InputEvent) -> void:
	# PC Tab
	if event.is_action_pressed("tab"):
		if not visible:
			show()
			# Otetaan focus
			grab_focus()
		else:
			hide()
		get_viewport().set_input_as_handled()


## Luo teleport painikkeet maailman sisältämien teleporttien perusteella
func luo_teleport_painikkeet(teleportit: Array[Node2D]) -> void:
	for teleport: Node2D in teleportit:
		var button: Button = Button.new()
		v_box_container.add_child(button)
		button.focus_mode = Control.FOCUS_NONE
		# Otetaan noden nimestä TP-osa pois
		button.text = teleport.name.left(teleport.name.length() - 2)
		button.pressed.connect(_on_teleport_button_pressed.bind(teleport.global_position))


## Kun painetaan teleport painiketta
func _on_teleport_button_pressed(sijainti: Vector2) -> void:
	Globaali.teleporttaa_pelaaja(sijainti)


func _on_button_death_pressed() -> void:
	Globaali.maailma.pelaaja.kuolema()


## TODO: Tänne voisi laittaa scenen vaihdon, jos sen saa toimimaan
func _on_button_reload_scene_pressed() -> void:
	pass
	#Globaali.vaihda_scene("maailma")
