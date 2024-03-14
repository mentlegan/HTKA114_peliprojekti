## Harri 14.3.2024
## Alustavaa työtä. Täydennellään myöhemmin, kun kunnon menut ja pauset halutaan.
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_jatka_nappi_pressed():
	get_tree().paused = false
