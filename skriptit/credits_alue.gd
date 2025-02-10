## Patrik 30.5.2024
extends Area2D
signal credits_entered

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


## Kun pelaaja osuu alueeseen, lähetetään signaali Credits nodelle, jossa näytetään creditsit
func _on_body_entered(body) -> void:
	if body is Pelaaja:
		credits_entered.emit()
