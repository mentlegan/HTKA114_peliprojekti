## Patrik 30.5.2024
extends Control
@onready var kuvat = %Kuvat.get_children()
signal show_credits

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not visible:
		return
	
	## Pelin lopetus ohjaimella
	if Input.is_action_just_pressed("abxy_oikea"):
		_on_lopeta_nappi_pressed()

## Lopetetaan peli
func _on_lopeta_nappi_pressed():
	get_tree().quit()

## Näytetään ensin kuvat 2,5 sekunnin väleillä ja sitten credits screen	
func credits_animatic():
	kuvat[0].visible = true
	await get_tree().create_timer(2,5).timeout
	kuvat[0].visible = false
	kuvat[1].visible = true
	await get_tree().create_timer(2,5).timeout
	kuvat[1].visible = false
	self.visible = true
	

## Globaaliin signaali, joka sammuttaa kaikki animaatiot yms taustalta
func _on_credits_alue_credits_entered():
	show_credits.emit()
	credits_animatic()
