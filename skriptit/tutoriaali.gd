## Käsittelee tutoriaaliruudun tapahtumia
## Harri 9.6.2025
## TODO: kontrollit vielä lisätä teksteineen kansionrakenteeseen
## TODO: värikoodaus ja muu tekstin muotoilu, vähän kuten journalissa nyt on
## TODO: näppäimistökontrollit
## TODO: tähän ei varmaan ole fixiä, mutta itemlist ei osaa visuaalisesti vaihtaa valintaansa, jos se tehdään koodissa. Eli jos painellaan hiirellä valintoja, ja koodissa vaihdetaan listan valinta, se ei näytä siltä käyttöliittymässä

extends Control

## Muuttujat, joilla käsitellään asioita
var aiheet = [] ## Tyhjä lista tutoriaaliaiheista, mikä myöhemmin määräytyy tutoriaalit/tekstitiedostot-kansion mukaan
var uudet_aiheet = [] ## Tyhjä lista uusista aiheista, koska halutaan tutoriaalin avautuvan ensimmäisestä uudesta aiheesta
var luetut_aiheet = [] ## Tyhjä lista jo luetuista aiheista huutomerkkien tarkistusta varten
var sivumaara = 1 ## Vakiona sivumäärä on 1..
var sivu = 1 ## .. ja sivujakin on vain 1
var aihekansioiden_polku = "res://tutoriaali/" ## Aihekansioiden polku vähän enemmän suomen kielellä
var valittu_aihe = "Darkness/" ## Vakio aihe on ensimmäisenä avattu
var tekstitiedostojen_polku = aihekansioiden_polku + valittu_aihe + "tekstitiedostot/" ## Kerrotaan tekstitiedostojen polku suomeksi
var kuvatiedostojen_polku = aihekansioiden_polku + valittu_aihe + "kuvat/" ## Otetaan kuvatiedostojen polku
var videotiedostojen_polku = aihekansioiden_polku + valittu_aihe + "videot/" ## Otetaan videotiedostojen polku

## Tarvittavat nodet
@onready var nappilista = $"%ItemList" ## Itemlist, josta valitaan aihe
@onready var tutoriaaliteksti_nodet = $"%Tutoriaalitekstit".get_children() ## Tämän avulla voidaan käsitellä tutoriaalitekstiin liittyvviä valikkoja
@onready var tutoriaaliteksti = tutoriaaliteksti_nodet[0] ## Tekstikenttä, mihin tekstitiedoston sisältö kirjoitetaan pelaajan näkyville
@onready var tutoriaalikuva_nodet = $"%Tutoriaalikuvat".get_children() ## Tämän avulla muokataan kuvia
@onready var tutoriaalivideo_nodet = $"%Tutoriaalivideot".get_children() ## Tämän avulla muokattaisiin videoita

## Ready tapahtuu, kun scene avautuu
func _ready():
	#aiheet = luo_tiedostolista(aihekansioiden_polku) # Luo tutoriaalin aiheista listan kansioiden mukaan
	aiheet.append("test") # Lisätään testidata
	aiheet.append("Darkness") # Lisätään vakiodata
	aiheet.append("Tutorial")
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
		if not (Globaali.maailma.pauseruutu.visible or Globaali.maailma.journal.visible):
			if visible:
				_on_takaisin_nappi_pressed()
				get_viewport().set_input_as_handled()
			else:
				Globaali.nayta_tutorial()
				Globaali.maailma.uusi_tutorial = false
				Globaali.maailma.pelaaja.paivita_tutorial_label()
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
		nappilista.add_item(kansion_nimi + " !",null,true) # Luodaan itemlistin valikkoon aihe


## Päivittää listaan nimen mukaisen aiheen. Kevyempi funktio kuin luo_valikko
## param nimi: aiheen nimi, joka laitetaan listaan
func paivita_valikko(nimi):
	for aihe in aiheet: # Katsotaan aihelistasta, että onko valikon aihe jo avattu. Toisaalta tämä tarkistus on turha, koska tutoriaalin avaava alue sulkeutuu, kun siitä kuljetaan ekan kerran, mutta hyvä varmistaa vielä täälläkin
		if aihe == nimi: # Jos aihe löytyy listasta..
			return # ..keskeytetään funktio
	nappilista.clear() # Tyhjennetään nappilista, että sen aiheet voidaan laittaa käänteiseen järjestykseen
	aiheet.reverse() # Käännetään taulukko..
	aiheet.append(nimi) # ..lisätään aihe taulukkoon
	aiheet.reverse() # Ja käännetään uusiksi käsittelyä varten
	uudet_aiheet.append(nimi) # Lisätään alue myös uusien aiheiden listaan
	for i in aiheet: # Käydään aiheet läpi
		if luetut_aiheet.has(i): # Jos aihe on jo luettu (eli luettujen listalla)
			nappilista.add_item(i,null,true) # Lisätään aihe myös valikon listaan ilman huutomerkkiä
		else: nappilista.add_item(i + " !",null,true) # Lisätään listaan huutomerkin kera
	valittu_aihe = nimi + "/" # Säädetään avattu tutoriaali valituksi aiheeksi
	var koko = nappilista.get_item_count() # Otetaan itemlistin pituus
	for i in koko: # Iteroidaan itemlistin valinnat läpi, koska itemlist toimii indekseillä
		if nappilista.get_item_text(i) == uudet_aiheet[0] + " !": # Jos valinnan nimi vastaa avatun tutoriaalin nimeä
			valitse_aihe(i) # Asetetaan avattu aihe valituksi listasta, että se avautuu heti


## Poistaa luettu-merkinnän ("!") nykyisestä aiheesta
## Aktivoituu, kun tutorial-ruutu avataan. Valittu aihe muuttuu, kun pelaaja avaa uuden tutoriaalin
## Eli jos pelaaja avaa tutorial-ruudun, ja hänellä on vasta avattu uusi aihe, merkitään se aihe listasta luetuksi
func poista_merkinta():
	var nimi = valittu_aihe.rstrip("/") + " !" # Muokataan valittu_aihe muuttuja tähän funktioon sopivaksi
	for i in nappilista.get_item_count(): # Iteroidaan itemlistin valinnat läpi
		if nappilista.get_item_text(i) == nimi: # Jos itemlistin valinta vastaa valitun aiheen nimeä huutomerkillä..
			nappilista.set_item_text(i,nimi.rstrip(" !")) # ..poistetaan huutomerkki


## Valintalistan toimintaa
## param index: valintalistan kohteen indeksi 0-n eli visuaalisesti ylhäältä alas
func _on_item_list_item_selected(index: int):
	luetut_aiheet.append(nappilista.get_item_text(index).rstrip(" !")) # Lisätään tarkistavaan listaan aihe
	valitse_aihe(index)


## Valitaan aihe valintalistan mukaan
## param index: valintalistan kohteen indeksi
func valitse_aihe(index):
	# Luetaan ja kirjoitetaan tekstitiedoston sisältö tutoriaalisivun tekstikenttään
	# Eli kutsutaan tekstinlukufunktiota ensin polulla, sitten aiheella ja sitten tiedostonnimellä, eli sivulla
	# Esimerkiksi: lue_teksti_tiedosto("res://tutoriaalit/tekstitiedostot/Checkpoint/" + sivu1.txt
	valittu_aihe = aiheet[index] + "/" # Säädetään valittu aihe tutoriaalin aiheen mukaan ja laitetaan kautta-merkki, että godot osaa hakea tiedoston oikein
	tekstitiedostojen_polku = aihekansioiden_polku + valittu_aihe + "tekstitiedostot/" # Päivitetään tekstitiedostojen polku
	sivumaara = laske_tiedostot(tekstitiedostojen_polku) # Lasketaan, että kuinka monta tekstitiedostosivua on jokaisessa aiheessa
	kuvatiedostojen_polku = aihekansioiden_polku + valittu_aihe + "kuvat/" # Päivitetään kuvatiedostojen polku
	tutoriaaliteksti.text = lue_teksti_tiedosto(tekstitiedostojen_polku + "sivu1.txt") # Vaihdetaan tutoriaalisivun teksti jo silloin, kuin aihe vaihtuu
	muokkaa_kuvat(1) # Otetaan kuvien ensimmäinen sivu
	muokkaa_valikkoa() # Muokkaa valikon sivumäärän mukaan
	vaihda_sivua() # Vaihtaa sivua nuolen mukaiseen suuntaan 1-3 välillä
	nappilista.set_item_text(index,aiheet[index])


## Laskee, että montako tiedostoa polun kansiossa on
## param polku: polku, josta tiedostojen määrä lasketaan
func laske_tiedostot(polku) -> int:
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
func muokkaa_kuvat(sivunumero):
	var s = str(sivunumero) # Sivunumero merkkijonoksi käsittelyä varten
	var sivujen_maara = laske_tiedostot(kuvatiedostojen_polku) # Lasketaan, että montako sivua on laitettu aiheeseen
	@warning_ignore("integer_division")
	var kuvamaara = laske_tiedostot(kuvatiedostojen_polku + "sivu"+s+"/") / 2 # Jaetaan kuvatiedostojen määrä kahdella import-tiedostojen takia
	for kuva in tutoriaalikuva_nodet: # Laitetaan aina vakiona kuvien skaala hieman pienemmäksi
		kuva.scale = Vector2(0.4, 0.4)
	if sivujen_maara == 0: # Tarkistus tyhjien aiheiden varalta
		return # Keskeytetään funktio
	# Asetetaan joka nodelle tekstuuri kuvien määrän mukaan
	if kuvamaara == 1: # Jos kuvia on vain yksi
		tutoriaalikuva_nodet[1].texture = load(kuvatiedostojen_polku + "sivu"+s+"/kuva1.png") # Ladataan ensimmäinen kuva keskelle
		tutoriaalikuva_nodet[1].scale = Vector2(0.5, 0.5) # Laitetaan yksinäiselle kuvalle hieman isompi koko
		tutoriaalikuva_nodet[0].texture = null # Nollataan ylimääräiset kuvat pois tieltä
		tutoriaalikuva_nodet[2].texture = null
	if kuvamaara >= 2: # Jos kuvia on kaksi tai enemmän
		tutoriaalikuva_nodet[0].texture = load(kuvatiedostojen_polku + "sivu"+s+"/kuva1.png") # Ladataan ensimmäinen kuva vasemmalle
		tutoriaalikuva_nodet[1].texture = load(kuvatiedostojen_polku + "sivu"+s+"/kuva2.png") # Ladataan toinen kuva
		tutoriaalikuva_nodet[2].texture = null # Nollataan kolmas kuva pois
	if kuvamaara == 3: # Jos kuvia on kolme
		tutoriaalikuva_nodet[2].texture = load(kuvatiedostojen_polku + "sivu"+s+"/kuva3.png") # Ladataan kolmas kuva
	# Eri aiheet tarvitsevat erikoiskäsittelyä kuvien koon vuoksi
	if valittu_aihe == "Vines/" and sivu != 1: # Vines-aiheelle oma käsittely, koska se sisältää isomman kuvan
		tutoriaalikuva_nodet[0].texture = null # Nollataan ei-tarvittu node
		tutoriaalikuva_nodet[1].texture = load(kuvatiedostojen_polku + "sivu"+s+"/kuva1.png") # Asetetaan isompi kuva keskelle, koska se on yksin muutenkin
		tutoriaalikuva_nodet[1].scale = Vector2(0.5, 0.5) # Tehdään iso kuva isommaksi, koska se on yksin keskellä
	if valittu_aihe =="Tutorial/": # Tutoriaali-aiheessa on pienempiä kuvia
		tutoriaalikuva_nodet[1].scale = Vector2(1, 1) # Joten teemme niistä hieman isompia


## Menun sulkemisnapin toiminnallisuus
func _on_takaisin_nappi_pressed():
	uudet_aiheet = [] # Resetoidaan uusien aiheiden lista
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
