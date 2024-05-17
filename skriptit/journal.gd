extends Control


@onready var sivut_sprite = $Sivut
@onready var sivunumero_label = $SivuLabel
@onready var ohjeet_kbm = $OhjeetKBM
@onready var ohjeet_controller = $OhjeetController

@onready var vasen_sivu = $VasenSivu
@onready var oikea_sivu = $OikeaSivu

@onready var audio_sivunvaihto = $AudioSivunvaihto

var sivut = {}
var otsikot = {}
var viimeisin_sivu = 1
var nykyinen_sivu = 1

var sivun_vaihto_ajastin: Timer


func _ready():
	paivita_sivunumero()
	journal_nakyviin()

	sivun_vaihto_ajastin = Timer.new()
	sivun_vaihto_ajastin.wait_time = 0.05
	sivun_vaihto_ajastin.one_shot = true
	self.add_child(sivun_vaihto_ajastin)


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
	if (Input.is_action_just_pressed("journal")
	or (self.visible and (
		Input.is_action_just_pressed("abxy_oikea") or 
		Input.is_action_just_pressed("pause")
	))):
		Globaali.toggle_journal()
	
	if visible:
		if Input.is_action_just_pressed("liiku_vasen"):
			vaihda_sivua(-1)
		if Input.is_action_just_pressed("liiku_oikea"):
			vaihda_sivua(1)


## Vaihtaa sivua eteen- tai taaksepäin annetun kokonaisluvun verran.
## Vaihtaa samalla sivun spriteä.
func vaihda_sivua(delta):
	if ohjeet_kbm.visible or ohjeet_controller.visible:
		return
	if not sivun_vaihto_ajastin.is_stopped():
		return
	sivun_vaihto_ajastin.start()

	var viime_sivu = nykyinen_sivu

	nykyinen_sivu = clamp(nykyinen_sivu + delta, 1, viimeisin_sivu)
	
	if nykyinen_sivu != viime_sivu:
		audio_sivunvaihto.play()
		sivut_sprite.texture.set_current_frame(
			(sivut_sprite.texture.get_current_frame() + 1) % sivut_sprite.texture.get_frames()
		)

	paivita_sivunumero()


## Asettaa ohjeet näkyviin
func ohjeet_nakyviin():
	sivunumero_label.visible = false
	vasen_sivu.visible = false
	oikea_sivu.visible = false
	if Globaali.pelaaja.hiiri_kaytossa:
		ohjeet_kbm.visible = true
		ohjeet_controller.visible = false
	else:
		ohjeet_kbm.visible = false
		ohjeet_controller.visible = true


## Asettaa journalin näkyviin
func journal_nakyviin():
	sivunumero_label.visible = true
	vasen_sivu.visible = true
	oikea_sivu.visible = true
	ohjeet_kbm.visible = false
	ohjeet_controller.visible = false
