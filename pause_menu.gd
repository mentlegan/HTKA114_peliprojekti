## Harri 17.3.2024
## Pelin pauseruudun nappien toiminta
## TODO: jostain syystä scenen puolella ohjaimen kontrolliavut (spritet) eivät näy. Tämä pitäisi korjata
extends Control

func _process(_delta):
	if not visible:
		return
	
	# "Painetaan" nappeja ohjaimella
	if Input.is_action_just_pressed("abxy_oikea"):
		_on_lopeta_nappi_pressed()
	if Input.is_action_just_pressed("abxy_alas"):
		_on_jatka_nappi_pressed()

## Kun painetaan jatka-nappulaa, eli Continue
func _on_jatka_nappi_pressed():
	Globaali.jatkaPelia()
	get_tree().paused = false

## Kun painetaan Quit-nappulaa, peli päättyy
func _on_lopeta_nappi_pressed():
	get_tree().quit() #Napataan tree ja peli loppuu quitilla
