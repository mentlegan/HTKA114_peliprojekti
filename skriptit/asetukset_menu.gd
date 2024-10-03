## Harri 30.7.2024
## Asetusruudun toimintaa
extends Control

## Tähän jotain sit kun kinostaa
func _ready():
	pass # pass pass pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if visible:
			if event.is_action_pressed("pause"):
				_on_takaisin_nappi_pressed()
				get_viewport().set_input_as_handled()


## Kun painetaan back-nappia
func _on_takaisin_nappi_pressed():
	self.visible = false # Tämä scene menee piiloon pauseruudun tieltä
