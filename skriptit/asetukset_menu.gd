## Harri 30.7.2024
## Asetusruudun toimintaa
extends Control

@onready var asetukset = Globaali.asetuksetruutu ## Otetaan juuren asetusruudun käyttöliittymäscene

## Tähän jotain sit kun kinostaa
func _ready():
	pass # pass pass pass

## Kun painetaan back-nappia
func _on_takaisin_nappi_pressed():
	asetukset.visible = false # Tämä scene menee piiloon pauseruudun tieltä
