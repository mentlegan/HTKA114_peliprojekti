extends Control


@onready var sivut_sprite = $Sivut
@onready var sivunumero_label = $SivuLabel

@onready var vasen_sivu = $VasenSivu
@onready var oikea_sivu = $OikeaSivu


var sivut = {}
var otsikot = {}
var viimeisin_sivu = 1
var nykyinen_sivu = 1


func _ready():
	paivita_sivunumero()
	#lisaa_sivu("Page text 1", "Title 1", 1)
	#lisaa_sivu("Page text 2", "Title 2", 2)
	#lisaa_sivu("Page text 4", "Title 4", 4)
	#lisaa_sivu("Page text 6", "Title 6", 6)


## Lisää journaliin tekstipätkän annettuun sivunumeroon. Sivunumeron on oltava >= 1.
func lisaa_sivu(teksti: String, otsikko: String, sivunumero: int):
	# Ei lisätä duplikaatteja sivuja tai sivuja <= 1
	if sivut.has(sivunumero) or sivunumero < 1:
		return

	sivut[sivunumero] = teksti
	otsikot[sivunumero] = otsikko
	
	if sivunumero > viimeisin_sivu:
		viimeisin_sivu = sivunumero
	
	paivita_sivunumero()


## Päivittää sivunumero-labelin arvon ja sivujen tekstin.
func paivita_sivunumero():
	var otsikko = "???"
	if otsikot.has(nykyinen_sivu):
		otsikko = otsikot[nykyinen_sivu]

	sivunumero_label.set_text("%s/%s - %s" % [nykyinen_sivu, viimeisin_sivu, otsikko])

	var teksti = " "
	if sivut.has(nykyinen_sivu):
		teksti = sivut[nykyinen_sivu]

	vasen_sivu.text = teksti
	oikea_sivu.text = " "
	if vasen_sivu.get_content_height() > vasen_sivu.size.y:
		vasen_sivu.text = teksti.substr(0, floor(teksti.length() * 0.5))
		oikea_sivu.text = teksti.substr(floor(teksti.length() * 0.5), ceil(teksti.length() * 0.5))



## Käsitellään input journalin ollessa aktiivinen
func _input(_event: InputEvent) -> void:
	# Peli jatkumaan J:llä
	if Input.is_action_just_pressed("journal"):
		Globaali.toggle_journal()
	
	if visible:
		if Input.is_action_just_pressed("liiku_vasen"):
			vaihda_sivua(-1)
		if Input.is_action_just_pressed("liiku_oikea"):
			vaihda_sivua(1)


## Vaihtaa sivua eteen- tai taaksepäin annetun kokonaisluvun verran.
## Vaihtaa samalla sivun spriteä.
func vaihda_sivua(delta):
	var viime_sivu = nykyinen_sivu

	nykyinen_sivu += delta
	if nykyinen_sivu > viimeisin_sivu:
		nykyinen_sivu = 1
	elif nykyinen_sivu < 1:
		nykyinen_sivu = viimeisin_sivu

	if nykyinen_sivu != viime_sivu:
		sivut_sprite.texture.set_current_frame(
			(sivut_sprite.texture.get_current_frame() + 1) % sivut_sprite.texture.get_frames()
		)

	paivita_sivunumero()
