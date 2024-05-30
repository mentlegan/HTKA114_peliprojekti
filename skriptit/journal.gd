extends Control


@export var sivut_sprite: TextureRect
@export var sivu_label: Label
@export var ohjeet: Node2D
@export var audio_sivunvaihto: AudioStreamPlayer
@export var ohjain_tooltipit: Array[Node]
@export var kbm_tooltipit: Array[Node]

var sivut = {}
var otsikot = {}
var viimeisin_sivu = 1
var nykyinen_sivu = 1

var sivun_vaihto_ajastin: Timer


func _ready():
	paivita_sivunumero()
	journal_nakyviin()
	
	kbm_tooltipit_nakyviin(true)

	sivun_vaihto_ajastin = Timer.new()
	sivun_vaihto_ajastin.wait_time = 0.05
	sivun_vaihto_ajastin.one_shot = true
	self.add_child(sivun_vaihto_ajastin)


## Asettaa journalin tooltipit näkyviin näppäimistölle ja hiirelle.
## Jos kbm_kaytossa on false, ohjaimen tooltipit asetetaan näkyviin kbm sijaan.
func kbm_tooltipit_nakyviin(kbm_kaytossa):
	for node in ohjain_tooltipit:
		node.visible = not kbm_kaytossa
	for node in kbm_tooltipit:
		node.visible = kbm_kaytossa


## Lisää journaliin tekstipätkän annettuun sivunumeroon. Sivunumeron on oltava >= 1.
func lisaa_sivu(sivun_sisalto: SivunSisalto, otsikko: String, sivunumero: int):
	# Ei lisätä duplikaatteja sivuja tai sivuja <= 1
	if sivut.has(sivunumero) or sivunumero < 1:
		return

	sivut[sivunumero] = sivun_sisalto
	sivun_sisalto.get_parent().remove_child(sivun_sisalto)
	sivut_sprite.add_child(sivun_sisalto)
	otsikot[sivunumero] = otsikko
	
	if sivunumero > viimeisin_sivu:
		viimeisin_sivu = sivunumero
	
	paivita_sivunumero()


## Päivittää sivunumero-labelin arvon ja sivujen tekstin.
func paivita_sivunumero():
	var otsikko = "???"
	if otsikot.has(nykyinen_sivu):
		otsikko = otsikot[nykyinen_sivu]

	sivu_label.set_text("%s/%s - %s" % [nykyinen_sivu, viimeisin_sivu, otsikko])

	for i in range(1, viimeisin_sivu + 1):
		if not sivut.has(i):
			continue
		sivut[i].visible = false
		if nykyinen_sivu == i:
			sivut[i].visible = true


## Käsitellään input journalin ollessa aktiivinen
func _input(event: InputEvent) -> void:
	# Peli jatkumaan J:llä
	if (Input.is_action_just_pressed("journal")
	or (self.visible and (
		Input.is_action_just_pressed("abxy_oikea") or 
		Input.is_action_just_pressed("pause")
	))):
		Globaali.toggle_journal()
	
	if visible:
		if (event is InputEventKey or event is InputEventMouseButton):
			kbm_tooltipit_nakyviin(true)
		elif (event is InputEventJoypadButton or event is InputEventJoypadMotion):
			kbm_tooltipit_nakyviin(false)

		if Input.is_action_just_pressed("liiku_vasen"):
			vaihda_sivua(-1)
		if Input.is_action_just_pressed("liiku_oikea"):
			vaihda_sivua(1)


## Vaihtaa sivua eteen- tai taaksepäin annetun kokonaisluvun verran.
## Vaihtaa samalla sivun spriteä.
func vaihda_sivua(delta):
	if ohjeet.visible:
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
	sivu_label.visible = false
	for i in range(1, viimeisin_sivu + 1):
		sivut[i].visible = false
	ohjeet.visible = true


## Asettaa journalin näkyviin
func journal_nakyviin():
	sivu_label.visible = true
	ohjeet.visible = false
	paivita_sivunumero()
