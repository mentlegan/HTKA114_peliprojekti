extends Control


@onready var sivut_sprite = $Sivut
@onready var sivunumero_label = $SivuLabel


var sivut = {
	"viimeisin_sivu": 0,
	"nykyinen_sivu": 0
}


func _ready():
	paivita_sivunumero()


## Lisää journaliin tekstipätkän annettuun sivunumeroon.
func lisaa_sivu(teksti: String, sivunumero: int):
	# Ei lisätä duplikaatteja sivuja
	if sivut.has(sivunumero):
		return

	sivut[sivunumero] = teksti
	if sivunumero > sivut["viimeisin_sivu"]:
		sivut["viimeisin_sivu"] = sivunumero
	
	paivita_sivunumero()


## Päivittää sivunumero-labelin arvon.
func paivita_sivunumero():
	sivunumero_label.set_text(str(sivut["nykyinen_sivu"]) + "/" + str(sivut["viimeisin_sivu"]))


## Käsitellään input journalin ollessa aktiivinen
func _input(_event: InputEvent) -> void:
	# Peli jatkumaan J:llä
	if Input.is_action_just_pressed("journal"):
		Globaali.toggle_journal()
	
	if Input.is_action_just_pressed("liiku_vasen"):
		vaihda_sivua(-1)
	if Input.is_action_just_pressed("liiku_oikea"):
		vaihda_sivua(1)


## Vaihtaa sivua eteen- tai taaksepäin annetun kokonaisluvun verran.
## Vaihtaa samalla sivun spriteä.
func vaihda_sivua(_delta):
	sivut_sprite.texture.set_current_frame(
		(sivut_sprite.texture.get_current_frame() + 1) % sivut_sprite.texture.get_frames()
	)
