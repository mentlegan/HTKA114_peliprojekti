extends Area2D
class_name Tooltip


var ohjain_ui = Array()
var kbm_ui = Array()


## Piilotetaan tooltip pelin alussa
func _ready():
	visible = false
	kategorisoi_ui()


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


## Asetetaan tooltip näkyviin, kun pelaaja astuu sen alueelle
func _on_body_entered(body):
	if body is Pelaaja:
		visible = true


## Piilotetaan tooltip, kun pelaaja poistuu sen alueelta
func _on_body_exited(body):
	if body is Pelaaja:
		visible = false
