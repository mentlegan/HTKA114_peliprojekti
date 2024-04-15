## Harri 9.4.2024
## Game over-ruudun koodi.
## Voisi myös tehdä signaaleilla.

extends Control

## Tähän voi lisäillä flavor-tekstiä game over-ruutuun, jos sellaisia keksii
var kuolemateksti = [
	"May you rest in peace",
	"The Dark has taken you",
	"Darkness has fallen"
]


## Readyssa otetaan satunnainen teksti taulukosta, ja asetetaan se ruutuun
func _ready():
	$Paneeli/MuuttuvaTeksti.text = kuolemateksti[randi() % kuolemateksti.size()]


## Process delta kutsutaan aina joka framella
func _process(_delta):
	if not visible:
		return
	
	# "Painetaan" nappeja ohjaimella
	# CONTROLLER DOWN
	# CONTROLLER RIGHT
	if Input.is_action_just_pressed("abxy_oikea"):
		_on_lopeta_nappi_pressed()
	if Input.is_action_just_pressed("abxy_alas"):
		_on_restart_nappi_pressed()


## Kun painaistaan quit-nappulaa
func _on_lopeta_nappi_pressed():
	get_tree().quit() # Napataan tree ja peli loppuu quitilla


## Kun painaistaan restart-nappulaa
func _on_restart_nappi_pressed():
	Globaali.respawn() # Kutsutaan Globaalin respawn-funktio
