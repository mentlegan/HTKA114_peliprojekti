## Harri 24.9.2024
## Käsittelee tutoriaaliruudun tapahtumia
## TODO: kontrollit vielä lisätä teksteineen kansionrakenteeseen
## TODO: värikoodaus ja muu tekstin muotoilu, vähän kuten journalissa nyt on
## TODO: näppäimistökontrollit

extends Control

## Muuttujat, joilla käsitellään asioita
var aiheet = [] ## Tyhjä lista tutoriaaliaiheista, mikä myöhemmin määräytyy tutoriaalit/tekstitiedostot-kansion mukaan
var sivumaara = 1 ## Vakiona sivumäärä on 1..
var sivu = 1 ## .. ja sivujakin on vain 1
var aihekansioiden_polku = "res://tutoriaali/" ## Aihekansioiden polku vähän enemmän suomen kielellä
var valittu_aihe = "Tutorial/" ## Vakio aihe on ensimmäisenä avattu
var tekstitiedostojen_polku = aihekansioiden_polku + valittu_aihe + "tekstitiedostot/" ## Kerrotaan tekstitiedostojen polku suomeksi
var kuvatiedostojen_polku = aihekansioiden_polku + valittu_aihe + "kuvat/" ## Otetaan kuvatiedostojen polku

## Tarvittavat nodet
@onready var nappilista = $ColorRect/MarginContainer/GridContainer/ScrollContainer/ItemList ## Itemlist, josta valitaan aihe
@onready var tutoriaaliteksti_nodet = $ColorRect/MarginContainer/Tutoriaalitekstit.get_children() ## Tämän avulla voidaan käsitellä tutoriaalitekstiin liittyvviä valikkoja
@onready var tutoriaaliteksti = tutoriaaliteksti_nodet[0] ## Tekstikenttä, mihin tekstitiedoston sisältö kirjoitetaan pelaajan näkyville
@onready var tutoriaalikuva_nodet = $ColorRect/MarginContainer/Tutoriaalikuvat.get_children() ## Tämän avulla muokataan kuvia


## Ready tapahtuu, kun scene avautuu
func _ready():
	#aiheet = luo_tiedostolista(aihekansioiden_polku) # Luo tutoriaalin aiheista listan kansioiden mukaan
	aiheet.append("Tutorial") # Lisätään vakiodata, eli tutoriaalin tutoriaali listaan
	luo_valikko() # Luo valikon valinnat aiheiden mukaan
	muokkaa_valikkoa() # Muokkaa valikon nappuloita ja grafiikkaa aiheen sivujen mukaisesti
	vaihda_sivua() # Vaihtaa sivun automaattisesti vakioiden mukaan
	_on_item_list_item_selected(0)


## Tutoriaali sulkeutuu escillä
func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	# PC Escape
	if event.is_action_pressed("pause"):
		if visible:
			_on_takaisin_nappi_pressed()
			get_viewport().set_input_as_handled()
	# PC H
	elif event.is_action_pressed("tutorial"):
		if not (Globaali.pauseruutu.visible or Globaali.journal.visible):
			if visible:
				_on_takaisin_nappi_pressed()
				get_viewport().set_input_as_handled()
			else:
				Globaali.nayta_tutorial()
				Globaali.uusi_tutorial = false
				Globaali.pelaaja.paivita_tutorial_label()
				get_viewport().set_input_as_handled()


## Ottaa kansiossa olevat tutoriaalit, ja tekee niiden kansionnimistä järjestetyn 0-n taulukon
## Käytetään lähinnä testaukseen, koska pelissä kaikki tutoriaalit eivät ole heti saatavilla
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
## Käytetään lähinnä niiden tutoriaalien laittoon, jotka ovat saatavilla pelin alkaessa
func luo_valikko():
	nappilista.clear() # Ensin puhdistetaan nappivalikko, ettei referenssidata jää sinne
	for kansion_nimi in aiheet: # Käydään tutoriaaliaiheet läpi
		nappilista.add_item(kansion_nimi,null,true) # Luodaan itemlistin valikkoon lista aiheesta


## Päivittää listaan nimen mukaisen aiheen. Kevyempi funktio kuin luo_valikko
## param nimi: aiheen nimi, joka laitetaan listaan
func paivita_valikko(nimi):
	for aihe in aiheet: # Katsotaan aihelistasta, että onko valikon aihe jo avattu. Toisaalta tämä tarkistus on turha, koska tutoriaalin avaava alue sulkeutuu, kun siitä kuljetaan ekan kerran, mutta hyvä varmistaa vielä täälläkin
		if aihe == nimi: # Jos aihe löytyy listasta..
			return # ..keskeytetään funktio
	aiheet.append(nimi) # Lisätään aihe taulukkoon
	nappilista.add_item(nimi,null,true) # Lisätään aihe myös valikon listaan


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
	kuvatiedostojen_polku = aihekansioiden_polku + valittu_aihe + "kuvat/" # Päivitetään kuvatiedostojen polku
	tutoriaaliteksti.text = lue_teksti_tiedosto(tekstitiedostojen_polku + "sivu1.txt") # Vaihdetaan tutoriaalisivun teksti jo silloin, kuin aihe vaihtuu
	muokkaa_kuvat(1)
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


## Resetoi kuvanäkymän, ja muokkaa kuvat valikkoon oikein
## param sivu: sivunumero, jonka perusteella kuvat valitaan
func muokkaa_kuvat(sivu):
	var s = str(sivu) # Sivunumero merkkijonoksi käsittelyä varten
	for kuva in tutoriaalikuva_nodet: # Laitetaan aina vakiona kuvien skaala hieman pienemmäksi
		kuva.scale = Vector2(0.4, 0.4)
	tutoriaalikuva_nodet[3].texture = null # Nollataan isommalle kuvalle suunnatun noden texture
	# Asetetaan joka nodelle tekstuuri
	tutoriaalikuva_nodet[0].texture = load(kuvatiedostojen_polku + "sivu"+s+"/kuva1.png")
	tutoriaalikuva_nodet[1].texture = load(kuvatiedostojen_polku + "sivu"+s+"/kuva2.png")
	tutoriaalikuva_nodet[2].texture = load(kuvatiedostojen_polku + "sivu"+s+"/kuva3.png")
	# Eri aiheet tarvitsevat erikoiskäsittelyä kuvien koon vuoksi
	if valittu_aihe == "Vines/" and sivu != 1: # Vines-aiheelle oma käsittely, koska se sisältää isomman kuvan
		tutoriaalikuva_nodet[0].texture = null # Nollataan ei-tarvittu node
		tutoriaalikuva_nodet[1].texture = load(kuvatiedostojen_polku + "sivu"+s+"/kuva1.png") # Asetetaan isompi kuva keskelle, koska se on yksin muutenkin
		tutoriaalikuva_nodet[1].scale = Vector2(0.5, 0.5) # Tehdään iso kuva isommaksi, koska se on yksin keskellä TODO: näin voisi tehdä myös muille sivuille, jossa asia on näin
	if valittu_aihe =="Tutorial/": # Tutoriaali-aiheessa on pienempiä kuvia
		tutoriaalikuva_nodet[0].scale = Vector2(1, 1) # Joten teemme niistä hieman isompia


## Menun sulkemisnapin toiminnallisuus
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
		muokkaa_kuvat(sivu) # Muokataan kuvat oikein sivun perusteella
	if sivu == 2: # Jos ollaan sivulla 2
		tutoriaaliteksti_nodet[3].visible = false
		tutoriaaliteksti_nodet[4].visible = true # Haluttu sivu on korostettu
		tutoriaaliteksti_nodet[5].visible = false
		naytanapit() # Molempia nappeja tarvitaan aina, kun ollaan sivulla 2
		tutoriaaliteksti.text = lue_teksti_tiedosto(tekstitiedostojen_polku + "sivu2.txt") # Otetaan oikea tekstiedosto, ja laitetaan sen sisältö tekstikenttään
		muokkaa_kuvat(sivu) # Muokataan kuvat oikein sivun perusteella
	if sivu == 3: # Jos ollaan sivulla 3
		tutoriaaliteksti_nodet[3].visible = false
		tutoriaaliteksti_nodet[4].visible = false
		tutoriaaliteksti_nodet[5].visible = true # Haluttu sivu on korostettu
		tutoriaaliteksti.text = lue_teksti_tiedosto(tekstitiedostojen_polku + "sivu3.txt") # Otetaan oikea tekstiedosto, ja laitetaan sen sisältö tekstikenttään
		muokkaa_kuvat(sivu) # Muokataan kuvat oikein sivun perusteella
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
