## Harri 5.9.2024
## Käsittelee tutoriaaliruudun tapahtumia
## TODO: H-input voisi olla takaisin-napin sijasta parempi, jos sellaisen saisi toimimaan
## TODO: kuvien lisäys
## TODO: eri tutoriaalien avaus eri alueilta, ne pitäisi laittaa unlock-järjestykseen
## TODO: kontrollit vielä lisätä teksteineen kansionrakenteeseen

extends Control

## Muuttujat, joilla käsitellään asioita
var aiheet = null ## Tyhjä lista tutoriaaliaiheista, mikä myöhemmin määräytyy tutoriaalit/tekstitiedostot-kansion mukaan
var sivumaara = 1 ## Vakiona sivumäärä on 1..
var sivu = 1 ## .. ja sivujakin on vain 1
var aihekansioiden_polku = "res://tutoriaali/" ## Aihekansioiden polku vähän enemmän suomen kielellä
var valittu_aihe = "Checkpoint/" ## Vakio aihe on aakkoslistan eka
var tekstitiedostojen_polku = aihekansioiden_polku + valittu_aihe + "tekstitiedostot/" ## Kerrotaan tekstitiedostojen polku suomeksi


## Tarvittavat nodet
@onready var nappilista = $ColorRect/MarginContainer/GridContainer/ScrollContainer/ItemList ## Itemlist, josta valitaan aihe
@onready var tutoriaaliteksti_nodet = $ColorRect/MarginContainer/Tutoriaalitekstit.get_children() ## Tämän avulla voidaan käsitellä tutoriaalitekstiin liittyvviä valikkoja
@onready var tutoriaaliteksti = tutoriaaliteksti_nodet[0] ## Tekstikenttä, mihin tekstitiedoston sisältö kirjoitetaan pelaajan näkyville


## Ready tapahtuu, kun scene avautuu
func _ready():
	aiheet = luo_tiedostolista(aihekansioiden_polku) # Luo tutoriaalin aiheista listan kansioiden mukaan
	luo_valikko() # Luo valikon valinnat aiheiden mukaan
	muokkaa_valikkoa() # Muokkaa valikon nappuloita ja grafiikkaa aiheen sivujen mukaisesti
	vaihda_sivua() # Vaihtaa sivun automaattisesti vakioiden mukaan


## Ottaa kansiossa olevat tutoriaalit, ja tekee niiden kansionnimistä järjestetyn 0-n taulukon
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
				tiedostot.append(file_name) # Laitetaan tiedoston nimi taulukkoon
			else: # Jos kysesssä on tiedosto
				print("Found file: " + file_name)
				#print(lue_teksti_tiedosto(polku + file_name))
			file_name = dir.get_next() # Ottaa seuraavan tiedoston hakemistosta
	else: # Jos ei saatu hakemistoa
		print("Virhe tiedoston haussa")
	return tiedostot # Palautetaan tehty taulukko


## Luo nappivalikon, josta valikoidaan tarkisteltava tutoriaali, tai resettaa sen
func luo_valikko():
	nappilista.clear() # Ensin puhdistetaan nappivalikko, ettei referenssidata jää sinne
	for kansion_nimi in aiheet: # Käydään tutoriaaliaiheet läpi
		nappilista.add_item(kansion_nimi,null,true) # Luodaan itemlistin valikkoon lista aiheesta


## Valintalistan toimintaa
## param index: valintalistan kohteen indeksi 0-n eli visuaalisesti ylhäältä alas
## TODO: tänne vielä kuvat
func _on_item_list_item_selected(index: int):
	# Luetaan ja kirjoitetaan tekstitiedoston sisältö tutoriaalisivun tekstikenttään
	# Eli kutsutaan tekstinlukufunktiota ensin polulla, sitten aiheella ja sitten tiedostonnimellä, eli sivulla
	# Esimerkiksi: lue_teksti_tiedosto("res://tutoriaalit/tekstitiedostot/Checkpoint/" + sivu1.txt
	valittu_aihe = aiheet[index] + "/" # Säädetään valittu aihe tutoriaalin aiheen mukaan ja laitetaan kautta-merkki, että godot osaa hakea tiedoston oikein
	tekstitiedostojen_polku = aihekansioiden_polku + valittu_aihe + "tekstitiedostot/" # Päivitetään tekstitiedostojen polku
	sivumaara = laskesivut(tekstitiedostojen_polku) # Lasketaan, että kuinka monta tekstitiedostosivua on jokaisessa aiheessa
	tutoriaaliteksti.text = lue_teksti_tiedosto(tekstitiedostojen_polku + "sivu1.txt") # Vaihdetaan tutoriaalisivun teksti jo silloin, kuin aihe vaihtuu
	muokkaa_valikkoa() # Muokkaa valikon sivumäärän mukaan
	vaihda_sivua() # Vaihtaa sivua nuolen mukaiseen suuntaan 1-3 välillä


## Laskee, että montako tiedostoa polun kansiossa on
## param polku: polku, josta tiedostojen määrä lasketaan
func laskesivut(polku) -> int:
	var tiedostoja = 0 # Ennen laskua tiedostoja on 0
	var dir = DirAccess.open(polku) # Avataan hakemisto
	dir.list_dir_begin() # Aloitetaan läpikäynti
	var file_name = dir.get_next() # Otetaan "seuraava" eli tässä tapauksessa ensimmäinen tiedosto
	while file_name != "": # Kunhan meillä on tiedosto..
		tiedostoja += 1 # ..lasketaan tiedosto mukaan
		file_name = dir.get_next() # Otetaan seuraava tiedosto
	return tiedostoja # Lopuksi otetaan kaikki lasketut tiedostot


## Lukee tekstitiedoston sisällön tiedostopolun mukaan
## param file: tekstitiedosto, jonka sisältö luetaan ja tallennetaan merkkijonoksi
func lue_teksti_tiedosto(file) -> String:
	var f = FileAccess.open(file, FileAccess.READ) # Luetaan tekstitiedosto
	var sisalto = f.get_as_text() # Muutetaan se merkkijonoksi
	return sisalto # Palautetaan merkkijonoversio


## Menun sulkemisnappi
func _on_takaisin_nappi_pressed():
	Globaali.sulje_tutorial() # Kutsutaan globaalista hauskaa funktiota, joka piilottaa tutoriaalimenun


## Kun painetaan oikealle-nuolta
func _on_oikealle_nuoli_pressed():
	if sivu != 3: # Kunhan emme ole jo saavuttaneet maksimisivumäärää
		sivu += 1 # Nostetaan sivunumeroa yhdellä
		vaihda_sivua() # Lopuksi vaihdetaan sivua


## Kun painetaan vasemmalle-nuolta
func _on_vasemmalle_nuoli_pressed():
	if sivu != 1: # Kunhan emme ole saavuttaneet minimisivumäärää
		sivu -= 1 # Lasketaan sivunumeroa yhdellä
		vaihda_sivua() # Vaihdetaan sivu


## Muokataan tai päivitetään sivunvaihtovalikko käytännöllisemmäksi ja bugeja välttäväksi sivumäärän perusteella
func muokkaa_valikkoa():
	sivu = 1 # Kun vaihdamme aihetta, otamme aina sivun 1
	if sivumaara == 1: # Jos aiheessa on yksi sivu
		tutoriaaliteksti_nodet[7].visible = false # Laitamme piiloon..
		tutoriaaliteksti_nodet[8].visible = false # ..muut vaihtoehdot..
		piilota_napit() # ..ja napit, koska niitä ei tarvita
	else: naytanapit() # Jos sivumääriä on enemmän kuin 1, nappeja tarvitaan
	if sivumaara == 2: # Jos aiheesta on kaksi sivua
		tutoriaaliteksti_nodet[7].visible = true # Laitamme esille yhden..
		tutoriaaliteksti_nodet[8].visible = false # ..ja piiloon yhden vaihtoehdon
	if sivumaara == 3: # Jos aiheesta on maksimimäärän 3 sivua
		tutoriaaliteksti_nodet[7].visible = true # Laitamme esille..
		tutoriaaliteksti_nodet[8].visible = true # ..kaikki vaihtoehdot


## Vaihdetaan sivua, tai päivitetään se
func vaihda_sivua():
	if sivu == 1: # Jos ollaan sivulla 1
		tutoriaaliteksti_nodet[3].visible = true # Haluttu sivu on korostettu
		tutoriaaliteksti_nodet[4].visible = false
		tutoriaaliteksti_nodet[5].visible = false
		tutoriaaliteksti_nodet[2].visible = false # Vasemmalle-nappia ei tarvita
		tutoriaaliteksti.text = lue_teksti_tiedosto(tekstitiedostojen_polku + "sivu1.txt") # Otetaan oikea tekstiedosto, ja laitetaan sen sisältö tekstikenttään
	if sivu == 2: # Jos ollaan sivulla 2
		tutoriaaliteksti_nodet[3].visible = false
		tutoriaaliteksti_nodet[4].visible = true # Haluttu sivu on korostettu
		tutoriaaliteksti_nodet[5].visible = false
		naytanapit() # Molempia nappeja tarvitaan aina, kun ollaan sivulla 2
		tutoriaaliteksti.text = lue_teksti_tiedosto(tekstitiedostojen_polku + "sivu2.txt") # Otetaan oikea tekstiedosto, ja laitetaan sen sisältö tekstikenttään
	if sivu == 3: # Jos ollaan sivulla 3
		tutoriaaliteksti_nodet[3].visible = false
		tutoriaaliteksti_nodet[4].visible = false
		tutoriaaliteksti_nodet[5].visible = true # Haluttu sivu on korostettu
		tutoriaaliteksti.text = lue_teksti_tiedosto(tekstitiedostojen_polku + "sivu3.txt") # Otetaan oikea tekstiedosto, ja laitetaan sen sisältö tekstikenttään
	if sivu == sivumaara: # Jos tarkasteltava sivu onkin viimeinen
		tutoriaaliteksti_nodet[1].visible = false # Ei voida siirtyä oikealle
	else: tutoriaaliteksti_nodet[1].visible = true # Muutoin voidaan, ja pitääkin


## Piilottaa molemmat sivunvaihtonapit
func piilota_napit():
	tutoriaaliteksti_nodet[1].visible = false
	tutoriaaliteksti_nodet[2].visible = false


## Nayttää molemmat sivunvaihtonapit
func naytanapit():
	tutoriaaliteksti_nodet[1].visible = true
	tutoriaaliteksti_nodet[2].visible = true
