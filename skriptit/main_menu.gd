extends Node2D
# TODO: Load-nappi, joka lataa pelin tilan maailma.tscn:ään siirryttyään


## Näytetäänkö main menu pelin alussa, vai skipataanko se
@export var nayta_main_menu = false


## Soitetaan musiikki main menun auetessa
func _ready():
	print("nayta_main_menu: %s" % nayta_main_menu)
	$"%Musiikki".play()
	
	# Skipataan main menu tarvittaessa
	if not nayta_main_menu:
		await get_tree().process_frame
		aloita_peli()


## Aloitetaan peli siirtymällää maailma.tscn:ään
func aloita_peli():
	Globaali.vaihda_scene("maailma")


## Poistutaan pelistä
func poistu_pelista():
	get_tree().quit()
