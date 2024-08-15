## Harri 15.8.2024
## Tässä säädetään pelin asetuksia pelaajan syötteistä
## Mutenapit toimivat suomeksi näin: 
##	nappi on pohjassa, jos jokin ääni halutaan peliin mukaan
## TODO: Grafiikoiden borderless-optiot voisi korjata myöhemmin toimiviksi, tai poistaa

extends Control

## Mutenapeille oman ryhmän toiminta, jos sattuu joskus tarvitsemaan
@onready var mutenapit = get_tree().get_nodes_in_group("mute_napit")

## Haetaan optionbutton, josta voi valita kuvakoon
@onready var kuvakokoValinta = get_node("TabContainer/Graphics/MarginContainer/VBoxContainer/graphics_kuvakoko/kuvakoko_valikko") as OptionButton
## Kuvakokojen valinnat, ja niiden tekstit, tässä määräytyy myös indeksoinnin järjestys, joka tulee kehiin myöhemmin
const kuvakokotaulukko : Array[String] = [
	"Full-screen",
	"Window Mode",
	"Borderless Window", # Nämä toimivat toistaiseksi samalla tavalla kuin..
	"Borderless Full-Screen" # ..ei borderless vaihtoehdot
]


## Ready tapahtuu kun scene avautuu
func _ready():
	taytaKuvakokojenValinta()
	kuvakokoValinta.item_selected.connect(on_window_mode_selected)
	

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

## Lisää optionbuttoniin kuvakoon valinnat
func taytaKuvakokojenValinta() -> void:
	for kuvakoko in kuvakokotaulukko:
		kuvakokoValinta.add_item(kuvakoko) # Automaattisesti indeksoi vaihtoehdot nappiin toimintaa varten 0 - n lisäysjärjestyksessä


## Optionbuttonin toiminta
## param index: optionbuttonin vaihtoehto
func on_window_mode_selected(index : int) -> void:
	match index: # Katsotaan, että mikä vaihtoehto napattiin
		0: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: # Windowed Borderless, pitää korjata myöhemmin
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: # Fullscreen Borderless, pitää korjata myöhemmin
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


##
## KONTROLLIT
##


##
## SAAVUTTETAVUUS
##
