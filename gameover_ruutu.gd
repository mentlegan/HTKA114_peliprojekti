## Harri 13.3.2024

extends Control

## Tähän voi lisäillä flavor-tekstiä game over-ruutuun, jos sellaisia keksii
var kuolemateksti = [
	"May you rest in peace",
	"The Void has taken you",
	"Darkness has fallen"
]

## Readyssa otetaan satunnainen teksti taulukosta, ja asetetaan se ruutuun
func _ready():
	$Paneeli/MuuttuvaTeksti.text = kuolemateksti[randi() % kuolemateksti.size()]
	
## Kun painaistaan quit-nappulaa
func _on_lopeta_nappi_pressed():
	get_tree().quit() #Napataan tree ja peli loppuu quitilla

## Kun painaistaan restart-nappulaa
func _on_restart_nappi_pressed():
	Globaali.respawn() #Kutsutaan Globaalin respawn-funktio
