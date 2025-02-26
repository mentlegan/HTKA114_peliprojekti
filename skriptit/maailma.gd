extends Node2D
## Node, joka sisältää globaalit muttujat.
## Muuttujia voi asettaa ja hakea Globaali.maailma-muuttujan kautta.

## Käytössä olevat pallot
var palloja = 0
## Onko alkuanimatic nähty
var alkuanimatic_nahty = false
## Maailmassa olevat pallot
var nykyiset_pallot = 0
## Signaaleja varten
var pelaaja: Pelaaja = null
var uusi_vihollinen = null
var tutoriaali = null
## Sekunnissa päivittämiseen käytettävät muuttujat (kts. process delta)
var aika_vali = 1.0
var aika = 0
## UI-näkyvyyden ajastin
var ui_ajastin = Timer.new()
var kuoltiinko_viholliseen
## Taulukko tooltipeille
@onready var tooltip_node = get_node("/root/Maailma/Tooltipit")
var tooltipit = Array()

## Nykyinen aktivoitu cp ja pelaajan aloituspaikka
var nykyinen_cp: Checkpoint = null
var pelaaja_aloitus: Vector2

var soitetaan_animatic

var vaikeusaste = 1

@export var teleportit: Array[Node2D]
## Teleportit ruohoalue
#@onready var pelaaja_taso1 = get_node("/root/Maailma/%Muuta/%Taso1Teleport").position
#@onready var pelaaja_taso2 = get_node("/root/Maailma/%Muuta/%Taso2Teleport").position
#@onready var pelaaja_taso3 = get_node("/root/Maailma/%Muuta/%Taso3Teleport").position
#@onready var pelaaja_taso45 = get_node("/root/Maailma/%Muuta/%Taso45Teleport").position

## Vesialue
#@onready var pelaaja_vesitutoriaali = get_node("/root/Maailma/Taso2/%VesitutoriaaliTP").position
#@onready var pelaaja_vesitutoriaali_ennen = get_node("/root/Maailma/Taso2/%VesitutoriaaliEnnenTP").position
#@onready var pelaaja_vesitutoriaalilapi = get_node("/root/Maailma/Taso2/%VesitutoriaaliLapiTP").position
#@onready var pelaaja_perhospesa = get_node("/root/Maailma/Taso2/%PerhosPesaTP").position

@onready var tiilet_taso_2 = get_node("/root/Maailma/Taso2/%TiiletTaso2")
@onready var ovi_seina_2 = get_node("/root/Maailma/Taso2/%OviSeina2")

## Valot ja indikaattorit köynnösoville ja niiden taulukko
const OVEN_VALO = preload("res://scenet/oven_valo.tscn")
const OVEN_INDIKAATTORI = preload("res://scenet/oven_indikaattori.tscn")
const OVEN_INDIKAATTORI_PUNAINEN = preload("res://resurssit/oven_indikaattorit/oven_indikaattori_punainen.tres")
const OVEN_INDIKAATTORI_SININEN = preload("res://resurssit/oven_indikaattorit/oven_indikaattori_sininen.tres")
const OVEN_INDIKAATTORI_LILA = preload("res://resurssit/oven_indikaattorit/oven_indikaattori_lila.tres")

var ovien_valot = Array()
var ovien_indikaattorit = Array()
@onready var koynnosovet = get_node("/root/Maailma/Koynnosovet")

## Köynnösovien scenet
@onready var ovi_vasen_x = preload("res://scenet/ovet/ovi_vasen_x.tscn")
@onready var ovi_oikea_x = preload("res://scenet/ovet/ovi_oikea_x.tscn")
@onready var ovi_vasen_y = preload("res://scenet/ovet/ovi_vasen_y.tscn")
@onready var ovi_oikea_y = preload("res://scenet/ovet/ovi_oikea_y.tscn")
@onready var ovi_vasen_z = preload("res://scenet/ovet/ovi_vasen_z.tscn")
@onready var ovi_oikea_z = preload("res://scenet/ovet/ovi_oikea_z.tscn")

@onready var ovi_pysty_oikea = preload("res://scenet/ovet/ovi_pysty_oikea.tscn")
@onready var ovi_vaaka_vasen = preload("res://scenet/ovet/ovi_vaaka_vasen.tscn")

## Taulukko Tasot-nodelle
var tasot = Array()
@onready var tasot_node = get_node("/root/Maailma/Tasot")

## Ristiovelle oma kohtelu vielä tässä vaiheessa
@onready var ovi_risti = get_tree().get_first_node_in_group("risti")
var pystyssa = true

## Tässä otetaan käyttöliittymän pauseruutu groupin avulla. Alla on toinen tapa ottaa
## @onready var pauseruutu = get_tree().get_first_node_in_group("pauseruutu")

## /root/Maailma/[uniquenimi] näyttäisi toimivan:
## huom. uniikki nimi toimii vain, jos ei ole aikomusta tehdä useaa instanssia
## pitää vaan muistaa kaikille käsiteltäville nodeille laittaa unique nimi nodepuusta:
## oikea näppäin ja % merkillä oleva valinta Access as unique name 
## ja kutsua sitä % merkillä scriptissä, kuten alla:
@onready var gameover_ruutu = get_node("/root/Maailma/%KayttoLiittyma/%GameOverRuutu")
@onready var credits = get_node("/root/Maailma/%KayttoLiittyma/%Credits")
@onready var journal = get_node("/root/Maailma/%KayttoLiittyma/Journal")
@onready var pauseruutu = get_node("/root/Maailma/%KayttoLiittyma/%pause_ruutu")
@onready var asetuksetruutu = get_node("/root/Maailma/%KayttoLiittyma/%asetukset_ruutu")
@onready var tutoriaali_ruutu = get_node("/root/Maailma/%KayttoLiittyma/%Tutoriaali")
@onready var pimeyskuolema_animaatio = get_node("/root/Maailma/%KayttoLiittyma/%PimeysKuolema")
@onready var teleport_menu: TeleportMenu = $KayttoLiittyma/TeleportMenu

@onready var uudetViholliset = get_node("/root/Maailma/%uudetViholliset").get_children()
@onready var kukat = get_node("/root/Maailma/%Kukat").get_children()
@onready var piikit = get_node("/root/Maailma/%Piikit").get_children()
@onready var tutoriaali_alueet = get_node("/root/Maailma/%TutoriaaliUnlock")
var tutorial_paalla = false
var uusi_tutorial = false

## Musiikit:
@onready var musiikki = get_node("/root/Maailma/Musiikki")
@onready var audio_journal = get_node("/root/Maailma/%KayttoLiittyma/Journal/%AudioJournal")
@onready var audio_oven_resonanssi = get_node("/root/Maailma/Koynnosovet/%AudioOvenResonanssi")
## Minecartit tuhotaan, kun jompi kumpi käytetään
@onready var minecartit = get_node("/root/Maailma/%Minecartit")

## Lisätään sceneen tausta pelin alussa
var tausta = preload("res://scenet/tausta.tscn")
var tausta2 = preload("res://scenet/tausta2.tscn")
var tausta_node
var tausta2_node
## Totuusarvo journalin aktivoimiselle ja minecartin käytölle
var journal_keratty = false
var minecart_kaytetty = false
## Onko pimeyskuolema päällä, ei ole tutoriaalissa
var pimeyskuolema_paalla = false

@onready var animatic = get_node("/root/Maailma/%KayttoLiittyma/%Animatic")

## Kutsutaan Globaalin alustusfunktiota luomisen yhteydessä
func _ready():
	teleport_menu.luo_teleport_painikkeet(teleportit)
	Globaali.init()


func tallenna():
	return {
		"alkuanimatic_nahty": alkuanimatic_nahty,
		"palloja": palloja,
	}


## Kutsutaan joka framella
func _process(_delta):
	# Päivitetään peliä joka sekuntti
	aika += _delta
	if aika > aika_vali:
		# Tähän lisätään joka sekuntti tapahtuva asia
		Globaali.lisaa_viholliset() # Viholliset päivittyvät pois ja päälle riippuen pelaajan positiosta
		aika = 0
