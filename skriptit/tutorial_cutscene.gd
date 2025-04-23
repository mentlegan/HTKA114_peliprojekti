## Harri 23.4.2025
## Hallitsee tutoriaalin cutscenen sceneä
extends Control

## Muuttujia
@onready var color_rect = get_node("%ColorRect")
@onready var animation_player = get_node("%AnimationPlayer")
var soitetaanko

## Ready tapahtuu, kun scene avautuu
func _ready():
	await Globaali.maailma.ready
	soitetaanko = Globaali.maailma.soitetaan_tutorial_cutscene ## Otetaan globaalilta varmistus
	if soitetaanko != null and soitetaanko == true:
		color_rect.visible = false
		animation_player.animation_finished.connect(_fade_reset)


## Kun painetaan continue-nappia
func _on_skip_nappi_pressed():
	skippaa() # Skipataan cutscene


## Karkeasti sulkee kaiken cutsceneen liittyvän
func skippaa():
	self.visible = false # Napit piiloon
	get_tree().paused = false # Peli pois pauselta
	Globaali.maailma.tutorial_cutscene_nahty = true


## Soittaa animaatiota, kun päästään cutsceneen
func soita_animaatio():
	color_rect.visible = true
	animation_player.play("fade_black")


## Animaation skriptiä, suoraan otettu transitiosta poislukien pelaajan teleporttaus
func _fade_reset(anim_name):
	if anim_name == "fade_black":
		await get_tree().create_timer(1, false).timeout
		animation_player.play("fade_reset")
		await get_tree().create_timer(0.3, false).timeout
	elif anim_name == "fade_reset":
		color_rect.visible = false
