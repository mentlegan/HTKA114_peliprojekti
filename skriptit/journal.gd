extends Control


@onready var sivut = $Sivut


## Käsitellään input journalin ollessa aktiivinen
func _input(_event: InputEvent) -> void:
	# Peli jatkumaan J:llä
	if Input.is_action_just_pressed("journal"):
		Globaali.toggle_journal()
	
	if Input.is_action_just_pressed("liiku_vasen"):
		vaihda_sivua(-1)
	if Input.is_action_just_pressed("liiku_oikea"):
		vaihda_sivua(1)


## Vaihtaa sivua eteen- tai taaksepäin annetun kokonaisluvun verran.
## Vaihtaa samalla sivun spriteä.
func vaihda_sivua(delta):
	sivut.texture.set_current_frame(
		(sivut.texture.get_current_frame() + 1) % sivut.texture.get_frames()
	)
	print(delta)