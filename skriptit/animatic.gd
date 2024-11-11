## Harri 18.6.2024
## Alkuanimaticia hoitava script
## TODO: Voisi vielä laittaa äänet pysähtymään, kun kuvaa vaihtaa, jos ihmiset kokevat sen häiritsevänä
extends Control

## Alustetaan kuvat ja äänet
@onready var kuvat = %kuvat.get_children()
@onready var aanet = %aanet.get_children()
@onready var animatic_musiikki = %animatic_musiikki
@onready var title_musiikki = %title_musiikki

@onready var nykyinen_kuva = 0 ## Nykyisen kuvan indeksi
var soitetaanko

## Ready tapahtuu, kun scene avautuu
func _ready():
	await Globaali.maailma.ready
	soitetaanko = Globaali.maailma.soitetaan_animatic ## Otetaan globaalilta varmistus

	# Kysytään globaalilta, että halutaanko animatic soittaa
	if soitetaanko != null and soitetaanko == true:
		animatic_musiikki.play()
		aanet[0].play() # Soitetaan ensimmäinen ääni ..
		kuvat[0].visible = true # .. ja näytetään ensimmäinen kuva
	else: Globaali.soita_musiikki()


## Delta kutsutaan joka framella. Tässä scriptissä ei taida tarvita, mutta jätetään tältä erää, jos tuleekin myöhemmin tarvetta
func _process(_delta):
	pass


## Kun painetaan next-nappia
func _on_next_nappi_pressed():
	vaihda_kuva(nykyinen_kuva+1) # Vaihdetaan seuraavaan kuvaan


## Vaihtaa kuvan ja soitaa äänen indeksin perusteella
func vaihda_kuva(indeksi):
	if kuvat[nykyinen_kuva] == kuvat[5]: # Jos tullaan title-screeniin..
		animatic_musiikki.stop() # ..lopetetaan aiempi musiikki toisen tieltä
	if kuvat[nykyinen_kuva] != kuvat[6]: # Varmistetaan, että ei olla viimeisessä kuvassa
		kuvat[nykyinen_kuva].visible = false # Nykyinen kuva suljetaan
		kuvat[indeksi].visible = true # Otetaan indeksin kuva, ja esitetään se
		aanet[indeksi].play() # Soitetaan oikea ääni
		nykyinen_kuva+=1 # Nykyinen kuva on nyt seuraava kuva
	else: skippaa() # Muuten tehdään sama, kuin cutscenen skippaus


## Kun painetaan skip-nappia
func _on_skip_nappi_pressed():
	skippaa() # Skipataan animatic


## Karkeasti sulkee kaiken animaticiin liittyvän
func skippaa():
	self.visible = false # Napit piiloon
	for n in kuvat: # Mennään kuvat läpi
		n.visible = false # Laitetaan kuvat piiloon
	for n in aanet: # Mennään äänet läpi
		if n.is_playing(): # Jos ääni soi ..
			n.stop() # .. pysäytetään se
	get_tree().paused = false # Peli pois pauselta
	animatic_musiikki.stop()
	title_musiikki.stop()
	Globaali.soita_musiikki()


## Kun painetaan quit-nappia
func _on_quit_nappi_pressed():
	get_tree().quit() # Kutsutaan treen quit, ja peli päättyy
