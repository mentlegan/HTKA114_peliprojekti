## Harri 4.9.2024
## Käsittelee tutoriaaliruudun tapahtumia
## TODO: H-input voisi olla takaisin-napin sijasta parempi, jos sellaisen saisi toimimaan
## TODO: tekstitiedostojen nimet voisi muokata siistimmiksi vaikkapa samankaltaisella listalla, millaisessa inputit ovat asetuksissa
## TODO: kuvien lisäys

extends Control

@onready var nappilista = $ColorRect/MarginContainer/GridContainer/ScrollContainer/ItemList
@onready var tutoriaaliteksti = $ColorRect/MarginContainer/GridContainer/Tutoriaalitekstit/Label
@onready var input_button_scene = preload ("res://scenet/input_button.tscn")
@onready var tekstitiedostojen_polku = "res://tekstitiedostot/"
var tutoriaalit = null


## Ready tapahtuu, kun scene avautuu
func _ready():
	tutoriaalit = luo_tiedostolista(tekstitiedostojen_polku)
	_luo_valikko(tutoriaalit)


## Luo nappivalikon, josta valikoidaan tarkisteltava tutoriaali, tai resettaa sen
## param tutoriaalit: lista tekstitiedostoista, jonka mukaan tehdään tutoriaalinappien lista valikkoon
func _luo_valikko(tutoriaalit):
	nappilista.clear()
	var indeksi = 0
	for tiedostonimi in tutoriaalit:
		nappilista.add_item(tiedostonimi,null,true)
		indeksi += 1


## Valintalistan toimintaa
## param index: valintalistan kohteen indeksi 0-n eli visuaalisesti ylhäältä alas
## TODO: tänne vielä kuvat
func _on_item_list_item_selected(index: int):
	# Luetaan ja kirjoitetaan tekstitiedoston sisältö tutoriaalisivun tekstikenttään
	# Eli kutsutaan tekstinlukufunktiota ensin polulla, ja sitten tiedostonnimellä taulukosta
	# Esimerkiksi: lue_teksti_tiedosto("res://tekstitiedostot/" + 01teksti.txt
	tutoriaaliteksti.text = lue_teksti_tiedosto(tekstitiedostojen_polku + tutoriaalit[index])


## Ottaa teksitiedostoissa olevat tutoriaalit, ja tekee niiden tiedostonnimistä järjestetyn 0-n listan
## param polku: luo tiedostoista taulukon kansion polun mukaan
func luo_tiedostolista(polku) -> Array:
	var tiedostot = [] # Tyhjä taulukko
	var dir = DirAccess.open(polku) # Avataan hakemisto polusta
	if dir: # Jos saatiin hakemisto
		dir.list_dir_begin() # Aloittaa hakemiston listauksen
		var file_name = dir.get_next() # Otetaan tiedoston nimi, tässä tapauksessa seuraava on ensimmäinen listattu tiedosto
		while file_name != "": # Kunhan tiedostonnimi ei ole tyhjä
			if dir.current_is_dir(): # Jos kyseessä onkin kansio
				print("Found directory: " + file_name)
			else: # Jos kysesssä on tiedosto
				#print("Found file: " + file_name)
				#print(lue_teksti_tiedosto(polku + file_name))
				tiedostot.append(file_name) # Laitetaan tiedoston nimi taulukkoon
			file_name = dir.get_next() # Ottaa seuraavan tiedoston hakemistosta
	else: # Jos ei saatu hakemistoa
		print("Virhe tiedoston haussa")
	return tiedostot # Palautetaan tehty taulukko


## Lukee tekstitiedoston sisällön tiedostopolun mukaan
## param file: tekstitiedosto, jonka sisältö luetaan ja tallennetaan merkkijonoksi
func lue_teksti_tiedosto(file) -> String:
	var f = FileAccess.open(file, FileAccess.READ)
	var sisalto = f.get_as_text()
	return sisalto


## Menun sulkemisnappi
func _on_takaisin_nappi_pressed():
	Globaali.sulje_tutorial() # Kutsutaan globaalista hauskaa fukntiota, joka piilottaa tutoriaalimenun
