## Harri 15.8.2024
## Tässä säädetään pelin asetuksia pelaajan syötteistä
## Mutenapit toimivat suomeksi näin: 
##	nappi on pohjassa, jos jokin ääni halutaan peliin mukaan

extends Control

## Mutenapeille oman ryhmän toiminta, jos sattuu joskus tarvitsemaan
@onready var mutenapit = get_tree().get_nodes_in_group("mute_napit")


## Tähän jotain sit kun kinostaa
func _ready():
	pass # pass pass pass


##
## ÄÄNET
##

## Musiikin mykistys-napin toiminta
func _on_musiikki_mute_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Musiikki"), false) # Kun nappi on pohjassa, ääni kuuluu
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Musiikki"), true) # Kun nappi ei ole pohjassa, ääni ei kuulu


## Ääniefektien mykistys-napin toiminta
func _on_efektit_mute_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Vihollinen"), false)  # Kun nappi on pohjassa, ääni kuuluu
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Vihollinen"), true) # Kun nappi ei ole pohjassa, ääni ei kuulu


## Pelaajan liikkumisäänien mykistys-napin toiminta
func _on_pelaaja_mute_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Pelaaja"), false)  # Kun nappi on pohjassa, ääni kuuluu
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Pelaaja"), true) # Kun nappi ei ole pohjassa, ääni ei kuulu


## Taustaäänien mykistys-napin toiminta
func _on_tausta_mute_toggled(button_pressed):
	if button_pressed == true:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Kaiku"), false)  # Kun nappi on pohjassa, ääni kuuluu
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Kaiku"), true) # Kun nappi ei ole pohjassa, ääni ei kuulu


##
## GRAFIIKAT
##


##
## KONTROLLIT
##


##
## SAAVUTTETAVUUS
##
