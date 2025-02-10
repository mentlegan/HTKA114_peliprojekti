extends Area2D
class_name Tooltip

var ohjain_ui = Array()
var kbm_ui = Array()

var tween: Tween

var aloitus_sijainti: Vector2

const ANIMAATIO_SIJAINNIN_SIIRROS = Vector2(0, -10)
const ANIMAATIO_KESTO = 0.5
const ANIMAATIO_TWEEN = Tween.TRANS_CUBIC
const ANIMAATIO_EASE = Tween.EASE_OUT

## Piilotetaan tooltip pelin alussa
func _ready():
	modulate.a = 0
	aloitus_sijainti = position
	position += ANIMAATIO_SIJAINNIN_SIIRROS
	kategorisoi_ui()
	vaihda_ui(true)


## Vaihtaa UI-elementtejen näkyvyyden käytettävissä annetun ohjaimen mukaan.
func vaihda_ui(nappaimisto):
	var piilota = ohjain_ui
	var nayta = kbm_ui

	if not nappaimisto:
		piilota = kbm_ui
		nayta = ohjain_ui
	
	for node in piilota:
		node.visible = false

	for node in nayta:
		node.visible = true


## Kategorisoi UI-nodet lisäämällä ne joko ohjain_ui- tai kbm_ui-taulukkoon
func kategorisoi_ui():
	for lapsi in self.get_children():
		if keskipiste(lapsi).x < -2:
			ohjain_ui.append(lapsi)
			aseta_keskelle(lapsi)
		elif keskipiste(lapsi).x > 2:
			kbm_ui.append(lapsi)
			aseta_keskelle(lapsi)


## Asettaa annetun noden vaakasuunnassa keskelle
func aseta_keskelle(node):
	if node is Sprite2D:
		node.position.x = 0
	if node is Label:
		node.position.x = node.size.x * -0.5


## Palauttaa annetun noden keskipisteen
func keskipiste(node):
	if node is Sprite2D:
		return node.position
	if node is Label:
		return node.position + node.size * 0.5
	return Vector2(0, 0)


## Asettaa tooltipille uuden läpinäkyvyyden ja sijainnin Tween-animaation avulla
func aseta_lapinakyvyys(lapinakyvyys):
	if tween:
		tween.kill()
	
	tween = create_tween().set_parallel(true).set_trans(ANIMAATIO_TWEEN)
	tween.set_ease(ANIMAATIO_EASE)
	
	tween.tween_property(
		self, "modulate:a", lapinakyvyys, ANIMAATIO_KESTO
	)
	tween.tween_property(
		self,
		"position",
		aloitus_sijainti + (1 - lapinakyvyys) * ANIMAATIO_SIJAINNIN_SIIRROS,
		ANIMAATIO_KESTO
	)


## Asetetaan tooltip näkyviin, kun pelaaja astuu sen alueelle
func _on_body_entered(body):
	if body is Pelaaja:
		aseta_lapinakyvyys(1)
		if not body.nykyiset_tooltipit.has(self):
			body.nykyiset_tooltipit.append(self)


## Piilotetaan tooltip, kun pelaaja poistuu sen alueelta
func _on_body_exited(body):
	if body is Pelaaja:
		aseta_lapinakyvyys(0)
		body.nykyiset_tooltipit.erase(self)


## Dekaktivoi tooltipin poistamalla pelaajaa maskaavan layerin
func deaktivoi():
	self.set_collision_mask_value(2, false)
