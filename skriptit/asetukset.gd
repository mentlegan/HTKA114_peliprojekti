## Harri 11.3.2025
## Tässä säädetään pelin asetuksia pelaajan syötteistä
## Mutenapit toimivat suomeksi näin: 
## 	nappi on pohjassa, jos jokin ääni halutaan peliin mukaan
## TODO: Grafiikoiden borderless-optiot voisi korjata myöhemmin toimiviksi, tai poistaa
## TODO: nimiä voisi vaihdella fiksummiksi
## TODO: input-asetukset toimimaan tallentamisen kanssa

extends Control

## Mutenapeille oman ryhmän toiminta, jos sattuu joskus tarvitsemaan
@onready var mutenapit = get_tree().get_nodes_in_group("mute_napit")

@onready var volume_slider = $TabContainer/Sound/MarginContainer/VBoxContainer/sound_volume/VolumeSlider
@onready var volume_slider_musiikki = $TabContainer/Sound/MarginContainer/VBoxContainer/sound_musiikki/VolumeSliderMusiikki
@onready var vaikeusaste_valinta = get_node("TabContainer/Accessibility/MarginContainer/VBoxContainer/accessibility_vaikeusaste/vaikeusaste_valikko") as OptionButton

## Haetaan optionbutton, josta voi valita kuvakoon
@onready var kuvakoko_valinta = get_node("TabContainer/Graphics/MarginContainer/ScrollContainer/VBoxContainer/graphics_kuvakoko/kuvakoko_valikko") as OptionButton
## Kuvakokojen valinnat, ja niiden tekstit, tässä määräytyy myös indeksoinnin järjestys, joka tulee kehiin myöhemmin
const kuvakokotaulukko : Array[String] = [
	"Full-screen",
	"Window Mode",
	"Borderless Window", # Nämä toimivat toistaiseksi samalla tavalla kuin..
	"Borderless Full-Screen" # ..ei borderless vaihtoehdot
]

## Ladataan input-button scene ja tarvittavat nodet
@onready var input_button_scene = preload ("res://scenet/input_button.tscn")
@onready var toimintolista = $TabContainer/Controls/MarginContainer/ScrollContainer/Toiminnot

## Ladataan checkbutton taustaelementtien togglelle
@onready var tausta_nappi = $TabContainer/Graphics/MarginContainer/ScrollContainer/VBoxContainer/graphics_taustaelementit/tausta_nappi

## Keybind-apumuuttujat
var asetetaan_control = false
var toiminto_asettamiseen = null
var asettava_nappi = null
## Emme suinkaan halua, että ihan kaikki kontrollit ovat suomeksi, tai voidaan edes muuttaa, joten tämä lista kääntää englanniksi ja filtteröi
var muutettavat_toiminnot = { ## Tänne voi siis lisätä kontrolleja sitä mukaa, kun niitä tulee
	"liiku_vasen": "Move Left",
	"liiku_oikea": "Move Right",
	"hyppaa": "Jump",
	"juoksu": "Sprint",
	"kayta": "Use",
	"kiipea": "Climb/Swim Up",
	"putoa": "Climb/Swim Down",
	"kiipeamis_toggle": "Climb Toggle",
	"nosta_taajuutta": "Flute Frequency",
	"journal": "Journal",
	"tutorial": "Tutorial"
}


## Ready tapahtuu kun scene avautuu
func _ready():
	taytaKuvakokojenValinta()
	kuvakoko_valinta.item_selected.connect(on_window_mode_selected)
	_luo_toiminto_lista()
	_on_volume_slider_value_changed(volume_slider.value)
	_on_volume_music_slider_value_changed(volume_slider_musiikki.value)
	vaikeusaste_valinta.item_selected.connect(on_difficulty_mode_item_selected)


##
## ÄÄNET
##

## Volume-sliderin toiminta
func _on_volume_slider_value_changed(volume_setting):
	# volume_setting arvo  0 ... 1,5
	var volume_db = linear_to_db(volume_setting) # Volume desibeleissä
	AudioServer.set_bus_volume_db(0, volume_db)


## Musiikin volume slider
func _on_volume_music_slider_value_changed(volume_setting):
	var volume_db = linear_to_db(volume_setting) # Volume desibeleissä
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musiikki"), volume_db)


## Ääniefektien mykistys-napin toiminta
## EI KÄYTÖSSÄ
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
		kuvakoko_valinta.add_item(kuvakoko) # Automaattisesti indeksoi vaihtoehdot nappiin toimintaa varten 0 - n lisäysjärjestyksessä


## Optionbuttonin toiminta
## param index: optionbuttonin vaihtoehto
func on_window_mode_selected(index : int) -> void:
	match index: # Katsotaan, että mikä vaihtoehto napattiin
		0: # Fullscreen, vaihdettu exclusive, jotta saa pois valkoiset reunat
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: # Windowed Borderless, pitää korjata myöhemmin
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: # Fullscreen Borderless, pitää korjata myöhemmin
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


## Taustaelementtejä hallitsevan napin toiminta
func _on_tausta_nappi_toggled(button_pressed):
	if button_pressed == true:
		Globaali.maailma.taustaelementit_paalla = true
		Globaali.paivita_grafiikat()
	else:
		Globaali.maailma.taustaelementit_paalla = false
		Globaali.paivita_grafiikat()


##
## KONTROLLIT
##

## Luo input-menun toiminnoille listan, tai resetoi sen
func _luo_toiminto_lista():
	InputMap.load_from_project_settings() # Ladataan projektin vakio input-asetukset
	for i in toimintolista.get_children(): # Iteroidaan node läpi..
		i.queue_free() # .. ja poistetaan turhat nodet, jotka toimivat referenssinä, tai jotka on asetettu uudelleen aiemmin
	
	# Iteroidaan haluttava kontrollilista läpi
	for action in muutettavat_toiminnot:
		var nappi = input_button_scene.instantiate() # Luodaan inputille oma nappula
		 # Otetaan scenestä nodet, joita muokataan myöhemmin
		var toiminto_label = nappi.find_child("LabelToiminto")
		var input_label = nappi.find_child("LabelInput")
		toiminto_label.text = muutettavat_toiminnot[action]
		var tapahtumat = InputMap.action_get_events(action) # Tapahtumat ovat näppäimet (key) jotka ovat sidottu toimintoihin
		if tapahtumat.size() > 0: # Katsotaan, onko mikään tapahtuma sidottu tälle toiminnolle
			input_label.text = tapahtumat[0].as_text().trim_suffix(" (Physical)") # Asetetaan menussa näkyvä näppäin. Godot tykkää käyttää inputeissaan sanaa Physical, joten poistetaan tämä visuaalisesti ruma ominaisuus
		else: input_label.text = ""
		toimintolista.add_child(nappi) # Lisätään nappi noden lapseksi
		nappi.pressed.connect(_on_input_button_pressed.bind(nappi, action))


## Kun painetaan nappia, joka asettaa kontrollin
func _on_input_button_pressed(nappi, toiminto):
	if !asetetaan_control: # Katsotaan, että eihän kontrollin asetus ole jostain muusta päällä, eli kahta kontrollia ei voi asettaa samaan aikaan
		asetetaan_control = true # Asetetaan yllä mainittu tarkistus päälle, koska nyt ollaan asettamassa uutta inputtia
		toiminto_asettamiseen = toiminto # Mikä toiminto halutaan asettaa
		asettava_nappi = nappi # Mikä nappula asettaa keybindin toiminnolle
		nappi.find_child("LabelInput").text = "Press key to bind..." # Asetetaan input-keyn kohdalle teksti, jossa pelaajalle kerrotaan, että nyt voi asettaa halutun keyn


## Kontrollin vaihdon toiminnallisuus
func _input(event):
	if asetetaan_control:
		if (
			event is InputEventKey || # Tarkistetaan näppäimistö.. 
			(event is InputEventMouseButton && event.pressed) # .. ja hiiren nappulat
		): # Ohjaimen inputit voisi kenties tulla myöhemmin jos jaksaa tehdä
			# Jos halutaan vasen painike näppäimeksi, voidaan vahingossa painaista liian nopeasti, jolloin godot luulee, että haluammekin kaksoisklikkauksen
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false # Estetään hiiren kaksoisklikkaus, koska sekin on ärsyttävä ominaisuus godotissa
			
			InputMap.action_erase_events(toiminto_asettamiseen) # Poistetaan vanha input..
			InputMap.action_add_event(toiminto_asettamiseen, event) # .. ja laitetaan uusi tilalle
			_update_action_list(asettava_nappi, event)
			# Resetoidaan apumuuttujat seuraava käyttöä varten
			asetetaan_control = false
			toiminto_asettamiseen = null
			asettava_nappi = null
			
			accept_event() # Estää muutostapahtumaamme aiheuttamasta joitain ei-haluttuja asioita. Ts. estämme tilannetta eskaloitumasta liikaa


## Päivitetään toimintojen lista nodessa/menussa
func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)") # Päivitetään label ja jälleen poistetaan sana Physical (soo soo, godot)


## Kun halutaan vakioasetukset takaisin, painetaan tätä nappulaa
func _on_reset_button_pressed():
	_luo_toiminto_lista() # Luodaan toimintolista uusiksi projektin input-asetuksista


##
## SAAVUTTETAVUUS
##

## Vaikeusasteen säätävän valikon toiminnallisuus
func on_difficulty_mode_item_selected(index: int) -> void:
	match index: # Katsotaan, että mikä vaihtoehto napattiin
		0: # Easy
			Globaali.maailma.vaikeusaste = 0
			print("Vaikeusaste Easy valittu")
		1: # Normal
			Globaali.maailma.vaikeusaste = 1
			print("Vaikeusaste Normal valittu")
		2: # Hard
			Globaali.maailma.vaikeusaste = 2
			print("Vaikeusaste Hard valittu")
		3: # Ultra Hard
			Globaali.maailma.vaikeusaste = 3
			print("Vaikeusaste Ultra Hard valittu")
	Globaali.paivita_vaikeusaste()
