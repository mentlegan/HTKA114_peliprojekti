## Harri 13.3.2024

extends Control

## Tähän voi lisäillä flavor-tekstiä game over-ruutuun, jos sellaisia keksii
var kuolemateksti = [
	"May you rest in peace",
	"The Void has taken you",
	"Darkness has fallen"
]

var flavorteksti = kuolemateksti[randi() % kuolemateksti.size()]

func teksti(_value):
	$Paneeli/MuuttuvaTeksti.text = flavorteksti

## Kun painaistaan restart-nappulaa
func _on_lopeta_nappi_pressed():
	pass

func _on_restart_nappi_pressed():
	Globaali.respawn() #Kutsutaan Globaalin respawn-funktio
