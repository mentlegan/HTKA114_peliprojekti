extends Node2D


# Aloitetaan peli siirtymällää maailma.tscn:ään
func aloita_peli():
	Globaali.vaihda_scene("maailma")


# Poistutaan pelistä
func poistu_pelista():
	get_tree().quit()
