## Harri 30.7.2024 - Asetus-ruudulle nappitoiminnallisuus. Skaalaus muutettu scenessä
## Pelin pauseruudun nappien toiminta
extends Control

@onready var asetukset = Globaali.asetuksetruutu

## Tämä taitaa olla oikea tapa tarkistaa inputteja, toisin kuin process tai physics_process
## Kutsutaan vain kun painetaan jotain
## PC ESCAPE
func _input(_event: InputEvent) -> void:
	# Annetaan poistua pelistä vasta jos pause menu on päällä...
	if visible:
		# Peli jatkumaan myös escapella
		if Input.is_action_just_pressed("pause"):
			# Varmistetaan vielä, että peli on pausella
			if get_tree().paused == true:
				_on_jatka_nappi_pressed()
				# Asetetaan inputti "syödyksi", sitä ei käsitellä enää missään muualla
				# Näin ei kuitenkaan pitäisi käydä, koska kaikki muu pausella
				get_viewport().set_input_as_handled()
		# "Painetaan" nappeja ohjaimella
		if Input.is_action_just_pressed("abxy_ylos"):
			_on_lopeta_nappi_pressed()
		if Input.is_action_just_pressed("abxy_oikea"):
			_on_jatka_nappi_pressed()


## Kun painetaan jatka-nappulaa, eli Continue
## CONTROLLER DOWN
func _on_jatka_nappi_pressed():
	Globaali.jatkaPelia()
	get_tree().paused = false


## Kun painetaan Quit-nappulaa, peli päättyy
## CONTROLLER RIGHT
func _on_lopeta_nappi_pressed():
	get_tree().quit() # Napataan tree ja peli loppuu quitilla


## Kun painetaan Options-nappulaa, avataan asetuksien käyttöliittymä
func _on_asetukset_nappi_pressed():
	asetukset.visible = true


## Ladataan peli
func _on_lataa_nappi_pressed():
	Globaali.lataa()


## Tallennetaan peli
func _on_tallenna_nappi_pressed():
	Globaali.tallenna()